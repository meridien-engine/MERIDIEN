import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/role_provider.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/location_model.dart';
import '../../customers/providers/customer_provider.dart';
import '../../products/providers/product_provider.dart';
import '../../locations/providers/location_provider.dart';
import '../providers/order_provider.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCustomerId;
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
      ref.read(customerListProvider.notifier).loadCustomers();
      ref.read(productListProvider.notifier).loadProducts();
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
        // Auto-populate city field from location
        _shippingFeeController.text =
            location.shippingFeeValue.toStringAsFixed(2);
      } else {
        _shippingFeeController.text = '0.00';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerListProvider);
    final productState = ref.watch(productListProvider);
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
                        'Customer',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      customerState.when(
                        initial: () => const CircularProgressIndicator(),
                        loading: () => const CircularProgressIndicator(),
                        loaded: (customers, _, __, ___) {
                          if (customers.isEmpty) {
                            return const Text('No customers available');
                          }
                          return DropdownButtonFormField<String>(
                            value: _selectedCustomerId,
                            decoration: const InputDecoration(
                              labelText: 'Select Customer *',
                              border: OutlineInputBorder(),
                            ),
                            items: customers.map((customer) {
                              return DropdownMenuItem(
                                value: customer.id,
                                child: Text(customer.fullName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedCustomerId = value);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a customer';
                              }
                              return null;
                            },
                          );
                        },
                        error: (message) => Text(
                          'Error loading customers: $message',
                          style: TextStyle(color: AppColors.error),
                        ),
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
                            'Order Items',
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _showAddItemDialog(context, productState),
                            icon: const Icon(Icons.add_circle_outline_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_items.isEmpty)
                        Text(
                          'No items added. Tap + to add items.',
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
                        'Delivery Location',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select a city/zone to auto-fill the shipping fee.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Location dropdown
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
                              'No locations configured yet.',
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
                          decoration: const InputDecoration(
                            labelText: 'City / Zone',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on_rounded),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('— None —'),
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

                      // Shipping fee (auto-populated, owners can edit manually)
                      TextFormField(
                        controller: _shippingFeeController,
                        decoration: InputDecoration(
                          labelText: 'Shipping Fee',
                          border: const OutlineInputBorder(),
                          prefixText: '\$ ',
                          prefixIcon: const Icon(Icons.local_shipping_rounded),
                          helperText: _selectedLocationId != null
                              ? 'Auto-populated from location. '
                                '${isOwner || isOperator ? 'You can override.' : ''}'
                              : null,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        // Collectors cannot manually override the shipping fee
                        enabled: isOwner || isOperator || _selectedLocationId == null,
                        readOnly: !isOwner && !isOperator,
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final parsed = double.tryParse(v);
                          if (parsed == null) return 'Invalid decimal number';
                          if (parsed < 0) return 'Cannot be negative';
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),
                      Text(
                        'Additional Address',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _shippingLine1Controller,
                        decoration: const InputDecoration(
                          labelText: 'Address Line 1',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _shippingStateController,
                              decoration: const InputDecoration(
                                labelText: 'State / Province',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _shippingPostalCodeController,
                              decoration: const InputDecoration(
                                labelText: 'Postal Code',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _shippingCountryController,
                        decoration: const InputDecoration(
                          labelText: 'Country',
                          border: OutlineInputBorder(),
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
                    decoration: const InputDecoration(
                      labelText: 'Order Notes (Optional)',
                      border: OutlineInputBorder(),
                      hintText: 'Add any special instructions or notes',
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
                          'Order Summary',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow('Subtotal', _calculateSubtotal()),
                        const SizedBox(height: 8),
                        _buildSummaryRow('Tax (10%)', _calculateTax()),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                            'Shipping',
                            '\$${double.tryParse(_shippingFeeController.text)?.toStringAsFixed(2) ?? '0.00'}'),
                        const Divider(height: 24),
                        _buildSummaryRow('Total', _calculateTotal(),
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
                      : const Text('Create Order'),
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

  void _showAddItemDialog(BuildContext context, dynamic productState) {
    productState.when(
      initial: () {},
      loading: () {},
      loaded: (products, _, __, ___) {
        if (products.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No products available')),
          );
          return;
        }

        String? selectedProductId;
        int quantity = 1;

        showDialog(
          context: context,
          builder: (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: const Text('Add Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedProductId,
                    decoration: const InputDecoration(
                      labelText: 'Product',
                      border: OutlineInputBorder(),
                    ),
                    items: products.map<DropdownMenuItem<String>>((product) {
                      return DropdownMenuItem<String>(
                        value: product.id,
                        child: Text('${product.name} (\$${product.displayPrice})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedProductId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: quantity.toString(),
                    decoration: InputDecoration(
                      labelText: context.loc.quantity,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      quantity = int.tryParse(value) ?? 1;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedProductId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a product'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (quantity <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Quantity must be greater than 0'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final product = products.firstWhere(
                      (p) => p.id == selectedProductId,
                    );

                    // Check stock availability
                    if (product.trackInventory &&
                        quantity > product.stockQuantity) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Insufficient stock! Available: ${product.stockQuantity}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _items.add(OrderItemData(
                        productId: product.id,
                        productName: product.name,
                        quantity: quantity,
                        unitPrice: product.displayPrice,
                      ));
                    });
                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to order'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
        );
      },
      error: (_) {},
    );
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
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

    // Derive city from selected location (or leave blank)
    String? cityValue;
    if (_selectedLocationId != null) {
      final loc = ref.read(locationProvider).locations.firstWhere(
            (l) => l.id == _selectedLocationId,
            orElse: () => const LocationModel(
                id: '', businessId: '', city: '', shippingFee: '0.00'),
          );
      cityValue = loc.city.isNotEmpty ? loc.city : null;
    }

    // Build shipping address if any field is filled
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
      customerId: _selectedCustomerId!,
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
          const SnackBar(
            content: Text('Order created successfully'),
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
            content: Text('Failed to create order: $e'),
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
