import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  bool? _activeOnly;
  bool? _inStockOnly;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    ref.read(productListProvider.notifier).loadProducts(
          search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
          category: _selectedCategory,
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
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
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
              ),
              onChanged: _handleSearch,
            ),
          ),

          // Product List
          Expanded(
            child: state.when(
              initial: () => const Center(
                child: Text('Search for products'),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              loaded: (products, total, page, hasMore) {
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start by creating your first product',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(productListProvider.notifier).refresh(),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push('/products/${product.id}'),
                      );
                    },
                  ),
                );
              },
              error: (message) => Center(
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
                      'Error loading products',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProducts,
                      child: const Text('Retry'),
                    ),
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
        title: const Text('Filter Products'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'electronics', child: Text('Electronics')),
                DropdownMenuItem(value: 'clothing', child: Text('Clothing')),
                DropdownMenuItem(value: 'food', child: Text('Food')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active only'),
              value: _activeOnly ?? false,
              onChanged: (value) {
                setState(() => _activeOnly = value ? true : null);
              },
            ),
            SwitchListTile(
              title: const Text('In stock only'),
              value: _inStockOnly ?? false,
              onChanged: (value) {
                setState(() => _inStockOnly = value ? true : null);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _activeOnly = null;
                _inStockOnly = null;
              });
              Navigator.pop(context);
              _loadProducts();
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadProducts();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
