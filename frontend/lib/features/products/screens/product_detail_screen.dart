import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/localization_extension.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/repository_providers.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  ProductModel? _product;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(productRepositoryProvider);
      final product = await repository.getProductById(widget.productId);

      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.loc.deleteProduct),
        content: Text(context.loc.deleteProductConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.loc.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(context.loc.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final repository = ref.read(productRepositoryProvider);
        await repository.deleteProduct(widget.productId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.loc.productDeleted)),
          );
          ref.read(productListProvider.notifier).refresh();
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${context.loc.error}: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _editProduct() {
    if (_product != null) {
      context.push('/products/${widget.productId}/edit', extra: _product);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(context.loc.productDetails)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.loc.productDetails)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                context.loc.errorLoadingProduct,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error ?? context.loc.productNotFound,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProduct,
                child: Text(context.loc.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.productDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: _editProduct,
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded),
            onPressed: _deleteProduct,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProduct,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Card
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (product.sku != null)
                                    Text(
                                      '${context.loc.sku}: ${product.sku}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            _StatusChip(active: product.isActive),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _PriceCard(
                                label: context.loc.sellingPrice,
                                price: product.sellingPrice,
                                color: AppColors.primary,
                              ),
                            ),
                            if (product.costPrice != null) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PriceCard(
                                  label: context.loc.costPrice,
                                  price: product.costPrice!,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (product.trackInventory) ...[
                          const SizedBox(height: 12),
                          _StockIndicator(product: product),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Basic Information
            _SectionCard(
              title: context.loc.basicInformation,
              children: [
                _InfoRow(label: context.loc.name, value: product.name),
                const Divider(),
                _InfoRow(label: context.loc.sku, value: product.sku ?? 'N/A'),
                if (product.description != null &&
                    product.description!.isNotEmpty) ...[
                  const Divider(),
                  _InfoRow(label: context.loc.description, value: product.description!),
                ],
                const Divider(),
                _InfoRow(
                  label: context.loc.category,
                  value: product.category?.name ?? 'N/A',
                ),
                if (product.barcode != null && product.barcode!.isNotEmpty) ...[
                  const Divider(),
                  _InfoRow(label: context.loc.barcode, value: product.barcode!),
                ],
                const Divider(),
                _InfoRow(
                  label: context.loc.created,
                  value: product.createdAt != null
                      ? dateFormat.format(product.createdAt!)
                      : 'N/A',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pricing Details
            _SectionCard(
              title: context.loc.pricing,
              children: [
                _InfoRow(
                  label: context.loc.sellingPrice,
                  value: currencyFormat.format(
                    double.tryParse(product.sellingPrice) ?? 0,
                  ),
                ),
                const Divider(),
                _InfoRow(
                  label: context.loc.costPrice,
                  value: currencyFormat.format(
                    double.tryParse(product.costPrice) ?? 0,
                  ),
                ),
                if (product.discountPrice != null && product.discountPrice!.isNotEmpty) ...[
                  const Divider(),
                  _InfoRow(
                    label: context.loc.discountPrice,
                    value: currencyFormat.format(
                      double.tryParse(product.discountPrice!) ?? 0,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Inventory
            if (product.trackInventory)
              _SectionCard(
                title: context.loc.inventory,
                children: [
                  _InfoRow(
                    label: context.loc.stockStatus,
                    value: product.stockStatus,
                  ),
                  const Divider(),
                  _InfoRow(
                    label: context.loc.stockQuantity,
                    value: product.stockQuantity.toString(),
                  ),
                  const Divider(),
                  _InfoRow(
                    label: context.loc.lowStockAlert,
                    value: product.lowStockThreshold.toString(),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Physical Properties
            if (product.weight != null && product.weight!.isNotEmpty)
              _SectionCard(
                title: context.loc.physicalProperties,
                children: [
                  _InfoRow(label: context.loc.weight, value: '${product.weight} ${product.weightUnit}'),
                  if (product.notes != null && product.notes!.isNotEmpty) ...[
                    const Divider(),
                    _InfoRow(label: context.loc.notes, value: product.notes!),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool active;

  const _StatusChip({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.green : Colors.grey;
    final label = active ? context.loc.active.toUpperCase() : context.loc.inactive.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String label;
  final String price;
  final Color color;

  const _PriceCard({
    required this.label,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final priceValue = double.tryParse(price) ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(priceValue),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _StockIndicator extends StatelessWidget {
  final ProductModel product;

  const _StockIndicator({required this.product});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (product.isOutOfStock) {
      statusColor = AppColors.error;
      statusIcon = Icons.error_outline_rounded;
      statusText = context.loc.outOfStock;
    } else if (product.isLowStock) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber_rounded;
      statusText = '${context.loc.lowStock} (${product.stockQuantity})';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline_rounded;
      statusText = '${context.loc.inStock} (${product.stockQuantity})';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
