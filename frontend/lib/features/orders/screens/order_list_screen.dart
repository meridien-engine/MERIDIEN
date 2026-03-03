import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/order_provider.dart';
import '../widgets/order_card.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  final _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedPaymentStatus;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadOrders());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    ref.read(orderListProvider.notifier).loadOrders(
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          status: _selectedStatus,
          paymentStatus: _selectedPaymentStatus,
          sortBy: 'order_date',
          sortOrder: 'desc',
        );
  }

  void _handleSearch(String value) {
    if (value.trim().isEmpty || value.trim().length >= 2) {
      _loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.orders),
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
                hintText: context.loc.searchOrders,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _loadOrders();
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

          // Filter Chips
          if (_selectedStatus != null || _selectedPaymentStatus != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_selectedStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text('${context.loc.orderStatus}: $_selectedStatus'),
                        onDeleted: () {
                          setState(() => _selectedStatus = null);
                          _loadOrders();
                        },
                      ),
                    ),
                  if (_selectedPaymentStatus != null)
                    Chip(
                      label: Text('${context.loc.paymentStatus}: $_selectedPaymentStatus'),
                      onDeleted: () {
                        setState(() => _selectedPaymentStatus = null);
                        _loadOrders();
                      },
                    ),
                ],
              ),
            ),

          // Order List
          Expanded(
            child: state.when(
              initial: () => Center(
                child: Text(context.loc.searchOrdersInitial),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              loaded: (orders, total, page, hasMore) {
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.loc.noOrdersFound,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.loc.noOrdersDesc,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(orderListProvider.notifier).refresh(),
                  child: ListView.builder(
                    itemCount: orders.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderCard(
                        order: order,
                        onTap: () => context.push('/orders/${order.id}'),
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
                      context.loc.errorLoadingOrders,
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
                      onPressed: _loadOrders,
                      child: Text(context.loc.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/orders/new'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.loc.filterOrders),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: context.loc.orderStatus,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(context.loc.all)),
                DropdownMenuItem(value: 'draft', child: Text(context.loc.draft)),
                DropdownMenuItem(value: 'pending', child: Text(context.loc.pending)),
                DropdownMenuItem(value: 'confirmed', child: Text(context.loc.confirmed)),
                DropdownMenuItem(value: 'processing', child: Text(context.loc.processing)),
                DropdownMenuItem(value: 'shipped', child: Text(context.loc.shipped)),
                DropdownMenuItem(value: 'delivered', child: Text(context.loc.delivered)),
                DropdownMenuItem(value: 'cancelled', child: Text(context.loc.cancelled)),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPaymentStatus,
              decoration: InputDecoration(
                labelText: context.loc.paymentStatus,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(context.loc.all)),
                DropdownMenuItem(value: 'unpaid', child: Text(context.loc.unpaid)),
                DropdownMenuItem(value: 'partial', child: Text(context.loc.partiallyPaid)),
                DropdownMenuItem(value: 'paid', child: Text(context.loc.paymentPaid)),
                DropdownMenuItem(value: 'overdue', child: Text(context.loc.overdue)),
              ],
              onChanged: (value) {
                setState(() => _selectedPaymentStatus = value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = null;
                _selectedPaymentStatus = null;
              });
              Navigator.pop(context);
              _loadOrders();
            },
            child: Text(context.loc.clear),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadOrders();
            },
            child: Text(context.loc.apply),
          ),
        ],
      ),
    );
  }
}
