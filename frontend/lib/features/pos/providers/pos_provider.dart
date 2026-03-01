import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/pos_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/pos_repository.dart';
import '../../../data/providers/repository_providers.dart';

// ── Session state ─────────────────────────────────────────────────────────────
enum PosSessionStatus { initial, loading, noSession, sessionOpen, error }

class PosSessionState {
  final PosSessionStatus status;
  final PosSessionModel? session;
  final String? errorMessage;

  const PosSessionState({
    this.status = PosSessionStatus.initial,
    this.session,
    this.errorMessage,
  });

  PosSessionState copyWith({
    PosSessionStatus? status,
    PosSessionModel? session,
    String? errorMessage,
  }) {
    return PosSessionState(
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PosSessionNotifier extends StateNotifier<PosSessionState> {
  final PosRepository _repo;

  PosSessionNotifier(this._repo) : super(const PosSessionState());

  Future<void> checkCurrentSession() async {
    state = state.copyWith(status: PosSessionStatus.loading);
    try {
      final session = await _repo.getCurrentSession();
      if (session != null) {
        state = state.copyWith(
          status: PosSessionStatus.sessionOpen,
          session: session,
        );
      } else {
        state = state.copyWith(
          status: PosSessionStatus.noSession,
          session: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: PosSessionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> openSession(String openingFloat) async {
    state = state.copyWith(status: PosSessionStatus.loading);
    try {
      final session = await _repo.openSession(openingFloat);
      state = state.copyWith(
        status: PosSessionStatus.sessionOpen,
        session: session,
      );
    } catch (e) {
      state = state.copyWith(
        status: PosSessionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> closeSession(String sessionId, String closingCash) async {
    state = state.copyWith(status: PosSessionStatus.loading);
    try {
      await _repo.closeSession(sessionId, closingCash);
      state = state.copyWith(
        status: PosSessionStatus.noSession,
        session: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: PosSessionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// ── Cart state ────────────────────────────────────────────────────────────────

// Sentinel object for nullable copyWith fields
const Object _sentinel = Object();

class PosCartState {
  final List<PosCartItem> items;
  final String scanQuery;
  final String? scanError;
  final String customerName;
  final String cashTendered;
  final bool isCheckingOut;
  final PosCheckoutResult? lastReceipt;
  final String? checkoutError;

  const PosCartState({
    this.items = const [],
    this.scanQuery = '',
    this.scanError,
    this.customerName = 'Walk-in',
    this.cashTendered = '',
    this.isCheckingOut = false,
    this.lastReceipt,
    this.checkoutError,
  });

  PosCartState copyWith({
    List<PosCartItem>? items,
    String? scanQuery,
    Object? scanError = _sentinel,
    String? customerName,
    String? cashTendered,
    bool? isCheckingOut,
    Object? lastReceipt = _sentinel,
    Object? checkoutError = _sentinel,
  }) {
    return PosCartState(
      items: items ?? this.items,
      scanQuery: scanQuery ?? this.scanQuery,
      scanError:
          scanError == _sentinel ? this.scanError : scanError as String?,
      customerName: customerName ?? this.customerName,
      cashTendered: cashTendered ?? this.cashTendered,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
      lastReceipt: lastReceipt == _sentinel
          ? this.lastReceipt
          : lastReceipt as PosCheckoutResult?,
      checkoutError: checkoutError == _sentinel
          ? this.checkoutError
          : checkoutError as String?,
    );
  }

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.lineTotal);
  double get total => subtotal; // discount handled separately if needed
}

class PosCartNotifier extends StateNotifier<PosCartState> {
  final PosRepository _repo;

  PosCartNotifier(this._repo) : super(const PosCartState());

  Future<void> scan(String query) async {
    if (query.trim().isEmpty) return;
    state = state.copyWith(scanQuery: query, scanError: null);
    try {
      final product = await _repo.lookupProduct(query.trim());
      addItem(product);
    } catch (_) {
      state = state.copyWith(scanError: 'Product not found: $query');
    }
  }

  void addItem(ProductModel product) {
    final existing = state.items.cast<PosCartItem?>().firstWhere(
          (i) => i!.productId == product.id,
          orElse: () => null,
        );
    if (existing != null) {
      final updated = state.items.map((i) {
        if (i.productId == product.id) {
          return PosCartItem(
            productId: i.productId,
            productName: i.productName,
            sku: i.sku,
            unitPrice: i.unitPrice,
            quantity: i.quantity + 1,
          );
        }
        return i;
      }).toList();
      state = state.copyWith(items: updated, scanError: null);
    } else {
      final price = double.tryParse(product.sellingPrice) ??
          double.tryParse(product.costPrice) ??
          0.0;
      final newItem = PosCartItem(
        productId: product.id,
        productName: product.name,
        sku: product.sku ?? '',
        unitPrice: price,
        quantity: 1,
      );
      state = state.copyWith(
        items: [...state.items, newItem],
        scanError: null,
      );
    }
  }

  void incrementItem(String productId) {
    final updated = state.items.map((i) {
      if (i.productId == productId) {
        return PosCartItem(
          productId: i.productId,
          productName: i.productName,
          sku: i.sku,
          unitPrice: i.unitPrice,
          quantity: i.quantity + 1,
        );
      }
      return i;
    }).toList();
    state = state.copyWith(items: updated);
  }

  void decrementItem(String productId) {
    final updated = state.items
        .map((i) {
          if (i.productId == productId) {
            if (i.quantity <= 1) return null;
            return PosCartItem(
              productId: i.productId,
              productName: i.productName,
              sku: i.sku,
              unitPrice: i.unitPrice,
              quantity: i.quantity - 1,
            );
          }
          return i;
        })
        .whereType<PosCartItem>()
        .toList();
    state = state.copyWith(items: updated);
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.productId != productId).toList(),
    );
  }

  void setCustomerName(String name) =>
      state = state.copyWith(customerName: name);

  void setCashTendered(String value) =>
      state = state.copyWith(cashTendered: value);

  void clearCart() => state = const PosCartState();

  Future<void> checkout(String sessionId) async {
    if (state.items.isEmpty) return;
    state = state.copyWith(isCheckingOut: true, checkoutError: null);
    try {
      final request = PosCheckoutRequest(
        sessionId: sessionId,
        customerName:
            state.customerName.isEmpty ? 'Walk-in' : state.customerName,
        items: state.items
            .map((i) => PosCheckoutItem(
                  productId: i.productId,
                  quantity: i.quantity,
                ))
            .toList(),
        cashTendered: state.cashTendered,
        discountAmount: '0',
      );
      final result = await _repo.checkout(request);
      state = state.copyWith(
        isCheckingOut: false,
        lastReceipt: result,
        checkoutError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isCheckingOut: false,
        checkoutError: e.toString(),
      );
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────
final posSessionProvider =
    StateNotifierProvider<PosSessionNotifier, PosSessionState>((ref) {
  final repo = ref.watch(posRepositoryProvider);
  return PosSessionNotifier(repo);
});

final posCartProvider =
    StateNotifierProvider<PosCartNotifier, PosCartState>((ref) {
  final repo = ref.watch(posRepositoryProvider);
  return PosCartNotifier(repo);
});
