import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/role_provider.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/order_model.dart' hide CustomerModel;
import '../../../data/models/product_model.dart';
import '../../../data/models/location_model.dart';
import '../../../data/providers/repository_providers.dart';
import '../../locations/providers/location_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/barcode_scanner_sheet.dart';
import '../widgets/customer_search_field.dart';
import '../widgets/product_search_picker.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  CustomerModel? _selectedCustomer;
  String? _customerError;
  final List<OrderItemData> _items = [];
  bool _isSubmitting = false;

  // Shipping address fields
  final _shippingLine1Controller = TextEditingController();
  final _shippingLine2Controller = TextEditingController();
  final _shippingStateController = TextEditingController();
  final _shippingPostalCodeController = TextEditingController();
  final _shippingCountryController = TextEditingController();
  final _notesController = TextEditingController();
  final _shippingFeeController = TextEditingController(text: '0.00');

  // Location dropdown selection
  String? _selectedLocationId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(locationProvider.notifier).listLocations();
    });
  }

  @override
  void dispose() {
    _shippingLine1Controller.dispose();
    _shippingLine2Controller.dispose();
    _shippingStateController.dispose();
    _shippingPostalCodeController.dispose();
    _shippingCountryController.dispose();
    _notesController.dispose();
    _shippingFeeController.dispose();
    super.dispose();
  }

  void _onLocationSelected(String? locationId) {
    setState(() {
      _selectedLocationId = locationId;
      if (locationId != null) {
        final location =
            ref.read(locationProvider).locations.firstWhere((l) => l.id == locationId,
                orElse: () => const LocationModel(
                      id: '',
                      businessId: '',
                      city: '',
                      shippingFee: '0.00',
                    ));
        _shippingFeeController.text =
            location.shippingFeeValue.toStringAsFixed(2);
      } else {
        _shippingFeeController.text = '0.00';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final isOwner = ref.isOwner;
    final isOperator = ref.isOperator;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.createOrder),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Customer Selection ────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.loc.customer,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      CustomerSearchField(
                        initialValue: _selectedCustomer,
                        errorText: _customerError,
                        onSelected: (c) => setState(() {
                          _selectedCustomer = c;
                          _customerError = null;
                        }),
                        onCleared: () =>
                            setState(() => _selectedCustomer = null),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Order Items ───────────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.loc.orderItems,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _showBarcodeScanner(context),
                                icon: const Icon(
                                    Icons.qr_code_scanner_rounded),
                                tooltip: context.loc.scanBarcodeOrSku,
                              ),
                              IconButton(
                                onPressed: () => showProductSearchPicker(
                                  context,
                                  onAdd: (product, qty) {
                                    _addOrIncrementItem(product);
                                    // Adjust quantity if user requested > 1
                                    if (qty > 1) {
                                      final idx = _items.indexWhere(
                                          (i) => i.productId == product.id);
                                      if (idx >= 0) {
                                        final cur = _items[idx];
                                        setState(() {
                                          _items[idx] = OrderItemData(
                                            productId: cur.productId,
                                            productName: cur.productName,
                                            quantity: qty,
                                            unitPrice: cur.unitPrice,
                                          );
                                        });
                                      }
                                    }
                                    _showAddedSnack(product.name);
                                  },
                                ),
                                icon: const Icon(
                                    Icons.add_circle_outline_rounded),
                                tooltip: context.loc.addItem,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_items.isEmpty)
                        Text(
                          context.loc.noItemsAdded,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        )
                      else
                        ..._items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return _buildOrderItem(index, item);
                        }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── City / Location Dropdown ──────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.loc.deliveryLocation,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.loc.deliveryLocationHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 12),

                      if (locationState.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(),
                        )
                      else if (locationState.locations.isEmpty)
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              context.loc.noResults,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: _selectedLocationId,
                          decoration: InputDecoration(
                            labelText: context.loc.cityZone,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.location_on_rounded),
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(context.loc.noneOption),
                            ),
                            ...locationState.locations.map((loc) {
                              return DropdownMenuItem<String>(
                                value: loc.id,
                                child: Text(loc.displayName),
                              );
                            }),
                          ],
                          onChanged: _onLocationSelected,
                        ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _shippingFeeController,
                        decoration: InputDecoration(
                          labelText: context.loc.shippingFee,
                          border: const OutlineInputBorder(),
                          prefixText: '\$ ',
                          prefixIcon: const Icon(Icons.local_shipping_rounded),
                          helperText: _selectedLocationId != null
                              ? '${context.loc.autoFilledFromLocation} '
                                '${isOwner || isOperator ? context.loc.canOverrideShipping : ''}'
                              : null,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        enabled: isOwner || isOperator || _selectedLocationId == null,
                        readOnly: !isOwner && !isOperator,
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final parsed = double.tryParse(v);
                          if (parsed == null) return context.loc.invalidDecimal;
                          if (parsed < 0) return context.loc.cannotBeNegative;
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),
                      Text(
                        context.loc.additionalAddress,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _shippingLine1Controller,
                        decoration: InputDecoration(
                          labelText: context.loc.addressLine1,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _shippingStateController,
                              decoration: InputDecoration(
                                labelText: context.loc.stateProvince,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _shippingPostalCodeController,
                              decoration: InputDecoration(
                                labelText: context.loc.postalCode,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _shippingCountryController,
                        decoration: InputDecoration(
                          labelText: context.loc.country,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Notes ─────────────────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: context.loc.orderNotesOptional,
                      border: const OutlineInputBorder(),
                      hintText: context.loc.orderNotesHint,
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Order Summary ─────────────────────────────────────────
              if (_items.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.loc.orderSummary,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow(context.loc.subtotal, _calculateSubtotal()),
                        const SizedBox(height: 8),
                        _buildSummaryRow(context.loc.taxPercent, _calculateTax()),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                            context.loc.shipping,
                            '\$${double.tryParse(_shippingFeeController.text)?.toStringAsFixed(2) ?? '0.00'}'),
                        const Divider(height: 24),
                        _buildSummaryRow(context.loc.total, _calculateTotal(),
                            isTotal: true),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // ── Submit Button ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _items.isEmpty
                      ? null
                      : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.loc.createOrder),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(int index, OrderItemData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} × \$${item.unitPrice}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '\$${(item.quantity * double.parse(item.unitPrice)).toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            onPressed: () {
              setState(() => _items.removeAt(index));
            },
            icon: Icon(Icons.delete_outline_rounded, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isTotal ? AppColors.primary : null,
              ),
        ),
      ],
    );
  }

  String _calculateSubtotal() {
    final subtotal = _items.fold<double>(
      0,
      (sum, item) => sum + (item.quantity * double.parse(item.unitPrice)),
    );
    return '\$${subtotal.toStringAsFixed(2)}';
  }

  String _calculateTax() {
    final subtotal = _items.fold<double>(
      0,
      (sum, item) => sum + (item.quantity * double.parse(item.unitPrice)),
    );
    return '\$${(subtotal * 0.1).toStringAsFixed(2)}';
  }

  String _calculateTotal() {
    final subtotal = _items.fold<double>(
      0,
      (sum, item) => sum + (item.quantity * double.parse(item.unitPrice)),
    );
    final tax = subtotal * 0.1;
    final shipping =
        double.tryParse(_shippingFeeController.text) ?? 0.0;
    return '\$${(subtotal + tax + shipping).toStringAsFixed(2)}';
  }

  void _showBarcodeScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BarcodeScannerSheet(
        onScanned: (query) => _lookupAndAddProduct(query),
      ),
    );
  }

  Future<void> _lookupAndAddProduct(String query) async {
    // API lookup by barcode / SKU
    try {
      final product =
          await ref.read(productRepositoryProvider).lookupProduct(query);
      _addOrIncrementItem(product);
      if (mounted) _showAddedSnack(product.name);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product not found: $query'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addOrIncrementItem(ProductModel product) {
    setState(() {
      final idx = _items.indexWhere((i) => i.productId == product.id);
      if (idx >= 0) {
        final existing = _items[idx];
        _items[idx] = OrderItemData(
          productId: existing.productId,
          productName: existing.productName,
          quantity: existing.quantity + 1,
          unitPrice: existing.unitPrice,
        );
      } else {
        _items.add(OrderItemData(
          productId: product.id,
          productName: product.name,
          quantity: 1,
          unitPrice: product.displayPrice,
        ));
      }
    });
  }

  void _showAddedSnack(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name ${context.loc.productAddedToOrder}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }


  Future<void> _submitOrder() async {
    if (_selectedCustomer == null) {
      setState(() => _customerError = context.loc.selectCustomerRequired);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.loc.addAtLeastOneItem)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final subtotalValue = _items.fold<double>(
      0,
      (sum, item) => sum + (item.quantity * double.parse(item.unitPrice)),
    );
    final taxAmount = (subtotalValue * 0.1).toStringAsFixed(2);
    final shippingAmount =
        double.tryParse(_shippingFeeController.text)?.toStringAsFixed(2) ??
            '0.00';

    String? cityValue;
    if (_selectedLocationId != null) {
      final loc = ref.read(locationProvider).locations.firstWhere(
            (l) => l.id == _selectedLocationId,
            orElse: () => const LocationModel(
                id: '', businessId: '', city: '', shippingFee: '0.00'),
          );
      cityValue = loc.city.isNotEmpty ? loc.city : null;
    }

    ShippingAddressRequest? shippingAddress;
    final hasShippingData = _shippingLine1Controller.text.isNotEmpty ||
        cityValue != null ||
        _shippingStateController.text.isNotEmpty ||
        _shippingCountryController.text.isNotEmpty;

    if (hasShippingData) {
      shippingAddress = ShippingAddressRequest(
        addressLine1: _shippingLine1Controller.text.isEmpty
            ? null
            : _shippingLine1Controller.text,
        city: cityValue,
        state: _shippingStateController.text.isEmpty
            ? null
            : _shippingStateController.text,
        postalCode: _shippingPostalCodeController.text.isEmpty
            ? null
            : _shippingPostalCodeController.text,
        country: _shippingCountryController.text.isEmpty
            ? null
            : _shippingCountryController.text,
      );
    }

    final request = CreateOrderRequest(
      customerId: _selectedCustomer!.id,
      items: _items.map((item) {
        return CreateOrderItemRequest(
          productId: item.productId,
          quantity: item.quantity,
          discountAmount: '0.00',
          taxAmount: '0.00',
        );
      }).toList(),
      taxAmount: taxAmount,
      discountAmount: '0.00',
      shippingAmount: shippingAmount,
      shippingAddress: shippingAddress,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    try {
      final result =
          await ref.read(orderDetailProvider.notifier).createOrder(request);

      setState(() => _isSubmitting = false);

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.loc.orderCreated),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/orders/${result.id}');
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.loc.error}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class OrderItemData {
  final String productId;
  final String productName;
  final int quantity;
  final String unitPrice;

  OrderItemData({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });
}
