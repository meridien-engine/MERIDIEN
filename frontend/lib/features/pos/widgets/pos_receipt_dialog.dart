import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../data/models/pos_model.dart';

class PosReceiptDialog extends StatelessWidget {
  final PosCheckoutResult result;

  const PosReceiptDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final order = result.order;
    final change = double.tryParse(result.change) ?? 0.0;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 32),
          const SizedBox(width: 8),
          Text(context.loc.saleComplete),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReceiptRow(
              label: context.loc.orderNumber,
              value: order.orderNumber,
            ),
            _ReceiptRow(
              label: context.loc.items,
              value: '${order.items?.length ?? 0}',
            ),
            _ReceiptRow(
              label: context.loc.total,
              value: 'EGP ${order.totalAmount}',
            ),
            const Divider(),
            _ReceiptRow(
              label: context.loc.tendered,
              value: 'EGP ${order.totalAmount}',
            ),
            _ReceiptRow(
              label: context.loc.change.toUpperCase(),
              value: 'EGP ${change.toStringAsFixed(2)}',
              highlight: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.loc.newSale),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.receipt_rounded),
          label: Text(context.loc.viewOrder),
          onPressed: () {
            Navigator.pop(context);
            context.push('/orders/${order.id}');
          },
        ),
      ],
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              fontSize: highlight ? 20 : 14,
              color: highlight ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
