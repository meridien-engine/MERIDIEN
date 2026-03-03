import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/branch_inventory_model.dart';
import '../../../data/providers/repository_providers.dart';
import '../providers/branch_inventory_provider.dart';

class ActivateProductScreen extends ConsumerStatefulWidget {
  final String branchId;
  final String branchName;

  const ActivateProductScreen({
    super.key,
    required this.branchId,
    required this.branchName,
  });

  @override
  ConsumerState<ActivateProductScreen> createState() =>
      _ActivateProductScreenState();
}

class _ActivateProductScreenState
    extends ConsumerState<ActivateProductScreen> {
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filtered = [];
  Set<String> _activatedProductIds = {};
  bool _isLoading = true;
  String? _error;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_filter);
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final productRepo = ref.read(productRepositoryProvider);
      final products = await productRepo.getProducts(limit: 200);

      // Get already-activated product IDs from current inventory state
      final inventoryState = ref.read(branchInventoryProvider);
      final activatedIds =
          inventoryState.items.map((i) => i.productId).toSet();

      setState(() {
        _allProducts = products;
        _activatedProductIds = activatedIds;
        _filtered = _applyFilter(products, _searchCtrl.text, activatedIds);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filter() {
    setState(() {
      _filtered =
          _applyFilter(_allProducts, _searchCtrl.text, _activatedProductIds);
    });
  }

  List<ProductModel> _applyFilter(
      List<ProductModel> products, String query, Set<String> activated) {
    var list = products.where((p) => !activated.contains(p.id)).toList();
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              (p.sku?.toLowerCase().contains(q) ?? false) ||
              (p.barcode?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return list;
  }

  void _showActivateSheet(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ActivateSheet(
        product: product,
        onActivate: (stockQty, priceOverride, threshold) async {
          final ok = await ref.read(branchInventoryProvider.notifier).activate(
                widget.branchId,
                product.id,
                ActivateProductRequest(
                  stockQuantity: stockQty,
                  priceOverride:
                      priceOverride.isEmpty ? null : priceOverride,
                  lowStockThreshold: threshold,
                ),
              );
          if (mounted) {
            if (ok) {
              Navigator.pop(context); // close sheet
              // Reload to reflect newly activated product
              await _load();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.loc.activateProduct),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              final err = ref.read(branchInventoryProvider).error ?? '';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(err.isEmpty ? context.loc.somethingWentWrong : err),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.activateProduct),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: '${context.loc.search}...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ),
      ),
      body: Builder(builder: (context) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.error)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _load,
                  child: Text(context.loc.tryAgain),
                ),
              ],
            ),
          );
        }

        if (_filtered.isEmpty) {
          return Center(
            child: Text(
              _searchCtrl.text.isEmpty
                  ? context.loc.noInventoryYet
                  : context.loc.noResults,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final product = _filtered[index];
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.inventory_2_rounded,
                      color: AppColors.primary),
                ),
                title: Text(
                  product.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: (product.sku?.isNotEmpty ?? false)
                    ? Text(
                        'SKU: ${product.sku}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      )
                    : null,
                trailing: Text(
                  product.sellingPrice,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                onTap: () => _showActivateSheet(context, product),
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Activate Sheet ────────────────────────────────────────────────────────────

class _ActivateSheet extends StatefulWidget {
  final ProductModel product;
  final Future<void> Function(int stockQty, String priceOverride, int? threshold)
      onActivate;

  const _ActivateSheet({required this.product, required this.onActivate});

  @override
  State<_ActivateSheet> createState() => _ActivateSheetState();
}

class _ActivateSheetState extends State<_ActivateSheet> {
  final _stockCtrl = TextEditingController(text: '0');
  final _priceCtrl = TextEditingController();
  final _thresholdCtrl = TextEditingController(text: '5');
  bool _isSaving = false;

  @override
  void dispose() {
    _stockCtrl.dispose();
    _priceCtrl.dispose();
    _thresholdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.product.name,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (widget.product.sku?.isNotEmpty ?? false)
            Text(
              'SKU: ${widget.product.sku}  |  ${context.loc.sellingPrice}: ${widget.product.sellingPrice}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          const SizedBox(height: 20),
          TextField(
            controller: _stockCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.loc.stockQuantity,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.inventory_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: context.loc.priceOverride,
              hintText: context.loc.optional,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.attach_money_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _thresholdCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.loc.lowStockThreshold,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.warning_amber_rounded),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSaving
                ? null
                : () async {
                    setState(() => _isSaving = true);
                    final stock = int.tryParse(_stockCtrl.text) ?? 0;
                    final threshold = int.tryParse(_thresholdCtrl.text);
                    await widget.onActivate(
                        stock, _priceCtrl.text.trim(), threshold);
                    if (mounted) setState(() => _isSaving = false);
                  },
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.loc.activateProduct),
          ),
        ],
      ),
    );
  }
}
