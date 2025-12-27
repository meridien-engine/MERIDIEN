import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../providers/order_provider.dart';
import '../widgets/record_payment_dialog.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadOrder());
  }

  void _loadOrder() {
    ref.read(orderDetailProvider.notifier).loadOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDetailProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadOrder,
          ),
        ],
      ),
      body: state.when(
        initial: () => const Center(child: Text('Loading...')),
        loading: () => const Center(child: CircularProgressIndicator()),
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
                'Error loading order',
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
                onPressed: _loadOrder,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        loaded: (order) => _buildOrderDetails(context, order),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, OrderModel order) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header Card
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
                        order.orderNumber,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      _buildStatusBadge(order.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.calendar_today_outlined,
                    'Order Date',
                    dateFormat.format(order.orderDate),
                  ),
                  if (order.customer != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.person_outline_rounded,
                      'Customer',
                      '${order.customer!.firstName ?? ''} ${order.customer!.lastName ?? ''}'.trim(),
                    ),
                    if (order.customer!.email != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.email_outlined,
                        'Email',
                        order.customer!.email!,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Order Items
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Items',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (order.items != null && order.items!.isNotEmpty)
                    ...order.items!.map((item) => _buildOrderItem(context, item))
                  else
                    Text(
                      'No items',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Shipping Address
          if (order.shippingAddressFull.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Shipping Address',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      order.shippingAddressFull,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          if (order.shippingAddressFull.isNotEmpty) const SizedBox(height: 16),

          // Order Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow('Subtotal', '\$${order.subtotal}'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Tax', '\$${order.taxAmount}'),
                  if (order.shippingAmount != '0.00') ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow('Shipping', '\$${order.shippingAmount}'),
                  ],
                  if (order.discountAmount != null && order.discountAmount != '0') ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Discount',
                      '-\$${order.discountAmount}',
                      color: AppColors.success,
                    ),
                  ],
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Total',
                    '\$${order.totalAmount}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Payment Status
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
                        'Payment Status',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      _buildPaymentStatusBadge(order.paymentStatus),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow('Total Amount', '\$${order.totalAmount}'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Paid Amount', '\$${order.paidAmount}'),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Balance Due',
                    '\$${order.balanceDue.toStringAsFixed(2)}',
                    color: order.balanceDue > 0 ? AppColors.error : AppColors.success,
                  ),
                  if (!order.isPaid) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showRecordPaymentDialog(context, order),
                        icon: const Icon(Icons.payment_rounded),
                        label: const Text('Record Payment'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notes
          if (order.notes != null && order.notes!.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.notes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          if (order.notes != null && order.notes!.isNotEmpty) const SizedBox(height: 16),

          // Action Buttons
          _buildActionButtons(context, order),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                if (item.productSku != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'SKU: ${item.productSku}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '${item.quantity} × \$${item.unitPrice}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            '\$${item.lineTotal}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                fontSize: isTotal ? 18 : 14,
                color: color ?? (isTotal ? AppColors.primary : null),
              ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'draft':
        color = AppColors.textSecondary;
        break;
      case 'pending':
        color = AppColors.orderStatusPending;
        break;
      case 'confirmed':
        color = AppColors.orderStatusConfirmed;
        break;
      case 'processing':
        color = AppColors.orderStatusProcessing;
        break;
      case 'shipped':
        color = AppColors.orderStatusShipped;
        break;
      case 'delivered':
        color = AppColors.orderStatusDelivered;
        break;
      case 'cancelled':
        color = AppColors.orderStatusCancelled;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'paid':
        color = AppColors.paymentStatusPaid;
        break;
      case 'partial':
        color = AppColors.paymentStatusPartial;
        break;
      case 'unpaid':
        color = AppColors.paymentStatusUnpaid;
        break;
      case 'overdue':
        color = AppColors.paymentStatusOverdue;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderModel order) {
    return Column(
      children: [
        // Draft orders can be confirmed
        if (order.status == 'draft' || order.status == 'pending')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _confirmOrder(order.id),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Confirm Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orderStatusConfirmed,
              ),
            ),
          ),
        if (order.status == 'confirmed' || order.status == 'processing') ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _shipOrder(order.id),
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Text('Mark as Shipped'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orderStatusShipped,
              ),
            ),
          ),
        ],
        if (order.status == 'shipped') ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _deliverOrder(order.id),
              icon: const Icon(Icons.done_all_rounded),
              label: const Text('Mark as Delivered'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orderStatusDelivered,
              ),
            ),
          ),
        ],
        // Cancel button for draft, pending, confirmed orders
        if (order.status == 'draft' ||
            order.status == 'pending' ||
            order.status == 'confirmed') ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _cancelOrder(order.id),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Order'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],

        // Reject button for shipped orders (receiver rejects delivery)
        if (order.status == 'shipped') ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _rejectOrder(order.id),
              icon: const Icon(Icons.block_outlined),
              label: const Text('Reject Delivery'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: BorderSide(color: AppColors.warning),
              ),
            ),
          ),
        ],

        // Return button for delivered orders
        if (order.status == 'delivered') ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _returnOrder(order.id),
              icon: const Icon(Icons.keyboard_return_outlined),
              label: const Text('Return Order'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmOrder(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: const Text('Are you sure you want to confirm this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await ref.read(orderDetailProvider.notifier).confirmOrder(id);
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order confirmed successfully')),
        );
      }
    }
  }

  Future<void> _shipOrder(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ship Order'),
        content: const Text('Mark this order as shipped? This will deduct inventory.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ship'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await ref.read(orderDetailProvider.notifier).shipOrder(id);
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order marked as shipped')),
        );
      }
    }
  }

  Future<void> _deliverOrder(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deliver Order'),
        content: const Text('Mark this order as delivered?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deliver'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await ref.read(orderDetailProvider.notifier).deliverOrder(id);
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order marked as delivered')),
        );
      }
    }
  }

  Future<void> _cancelOrder(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await ref.read(orderDetailProvider.notifier).cancelOrder(id);
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled')),
        );
      }
    }
  }

  Future<void> _rejectOrder(String id) async {
    final TextEditingController reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Delivery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to reject this delivery?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason (Optional)',
                hintText: 'e.g., Damaged package, incorrect items',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await ref.read(orderDetailProvider.notifier).cancelOrder(id);
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              reasonController.text.isEmpty
                  ? 'Delivery rejected'
                  : 'Delivery rejected: ${reasonController.text}',
            ),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
    reasonController.dispose();
  }

  Future<void> _returnOrder(String id) async {
    final TextEditingController reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to return this order?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Return Reason (Optional)',
                hintText: 'e.g., Defective product, wrong item',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Return'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await ref.read(orderDetailProvider.notifier).cancelOrder(id);
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              reasonController.text.isEmpty
                  ? 'Order returned successfully'
                  : 'Order returned: ${reasonController.text}',
            ),
          ),
        );
      }
    }
    reasonController.dispose();
  }

  void _showRecordPaymentDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => RecordPaymentDialog(
        orderId: order.id,
        balanceDue: order.balanceDue,
        onPaymentRecorded: () {
          _loadOrder();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment recorded successfully')),
          );
        },
      ),
    );
  }
}
