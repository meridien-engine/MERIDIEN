import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../providers/product_provider.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();
  bool? _activeOnly;
  bool? _inStockOnly;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    ref.read(productListProvider.notifier).loadProducts(
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          active: _activeOnly,
          inStock: _inStockOnly,
        );
  }

  void _handleSearch(String value) {
    if (value.trim().isEmpty || value.trim().length >= 2) {
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.products),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.loc.searchProducts,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _loadProducts();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              onChanged: _handleSearch,
            ),
          ),
          Expanded(
            child: state.when(
              initial: () => Center(
                child: Text(
                  context.loc.searchProducts,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (products, total, page, hasMore) {
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text(context.loc.noDataFound,
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(productListProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) => _ProductTile(
                      product: products[index],
                      onTap: () =>
                          context.push('/products/${products[index].id}'),
                    ),
                  ),
                );
              },
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: _loadProducts,
                        child: Text(context.loc.tryAgain)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/products/new'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.loc.filters),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text(context.loc.active),
              value: _activeOnly ?? false,
              onChanged: (v) =>
                  setState(() => _activeOnly = v ? true : null),
            ),
            SwitchListTile(
              title: Text(context.loc.inStock),
              value: _inStockOnly ?? false,
              onChanged: (v) =>
                  setState(() => _inStockOnly = v ? true : null),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _activeOnly = null;
                _inStockOnly = null;
              });
              Navigator.pop(context);
              _loadProducts();
            },
            child: Text(context.loc.clearFilters),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadProducts();
            },
            child: Text(context.loc.applyFilters),
          ),
        ],
      ),
    );
  }
}

// ─── Product Tile ─────────────────────────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ProductTile({required this.product, required this.onTap});

  Color get _stockColor {
    if (product.isOutOfStock) return AppColors.error;
    if (product.isLowStock) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Icon placeholder (no image)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 22,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 12),

              // Name + SKU
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.sku != null && product.sku!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.sku!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Price + stock dot
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product.sellingPrice}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (product.trackInventory) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _stockColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.stockQuantity.toString(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _stockColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
