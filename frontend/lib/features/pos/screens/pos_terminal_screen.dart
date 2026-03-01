import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../data/models/pos_model.dart';
import '../providers/pos_provider.dart';
import '../widgets/pos_cart_item_row.dart';
import '../widgets/pos_receipt_dialog.dart';

class PosTerminalScreen extends ConsumerStatefulWidget {
  final PosSessionModel session;

  const PosTerminalScreen({super.key, required this.session});

  @override
  ConsumerState<PosTerminalScreen> createState() => _PosTerminalScreenState();
}

class _PosTerminalScreenState extends ConsumerState<PosTerminalScreen> {
  final _scanController = TextEditingController();
  final _scanFocus = FocusNode();
  final _customerController = TextEditingController();
  final _cashController = TextEditingController();
  final _closeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanFocus.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set locale-aware default customer name
    if (_customerController.text.isEmpty) {
      _customerController.text = context.loc.walkin;
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _scanFocus.dispose();
    _customerController.dispose();
    _cashController.dispose();
    _closeController.dispose();
    super.dispose();
  }

  void _onScan() {
    final query = _scanController.text.trim();
    if (query.isEmpty) return;
    ref.read(posCartProvider.notifier).scan(query);
    _scanController.clear();
    _scanFocus.requestFocus();
  }

  Future<void> _onCheckout() async {
    final cart = ref.read(posCartProvider);
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.loc.cartIsEmpty)),
      );
      return;
    }
    ref
        .read(posCartProvider.notifier)
        .setCashTendered(_cashController.text.trim());
    await ref.read(posCartProvider.notifier).checkout(widget.session.id);

    final updatedCart = ref.read(posCartProvider);
    if (updatedCart.checkoutError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updatedCart.checkoutError!),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (updatedCart.lastReceipt != null && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => PosReceiptDialog(result: updatedCart.lastReceipt!),
      );
      ref.read(posCartProvider.notifier).clearCart();
      _cashController.clear();
      _customerController.text = context.loc.walkin;
      _scanFocus.requestFocus();
    }
  }

  void _onCloseSession() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.loc.closeSession),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.loc.enterClosingCash),
            const SizedBox(height: 16),
            TextField(
              controller: _closeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: context.loc.closingCash,
                border: const OutlineInputBorder(),
                prefixText: 'EGP ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(posSessionProvider.notifier).closeSession(
                    widget.session.id,
                    _closeController.text.trim().isEmpty
                        ? '0'
                        : _closeController.text.trim(),
                  );
            },
            child: Text(context.loc.closeSession),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(posCartProvider);
    final openedAt = widget.session.openedAt;
    final timeStr =
        '${openedAt.hour.toString().padLeft(2, '0')}:${openedAt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          '${context.loc.pos} — ${context.loc.sessionOpened} $timeStr | ${context.loc.posFloat}: ${widget.session.openingFloat} EGP',
        ),
        actions: [
          TextButton.icon(
            onPressed: _onCloseSession,
            icon: const Icon(Icons.lock_rounded, color: Colors.red),
            label: Text(
              context.loc.closeSession,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT: scan + customer
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scan bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _scanController,
                          focusNode: _scanFocus,
                          decoration: InputDecoration(
                            labelText: context.loc.scanBarcodeOrSku,
                            prefixIcon:
                                const Icon(Icons.qr_code_scanner_rounded),
                            border: const OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _onScan(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _onScan,
                        child: Text(context.loc.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Customer name
                  TextField(
                    controller: _customerController,
                    decoration: InputDecoration(
                      labelText: context.loc.customerNameOptional,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) =>
                        ref.read(posCartProvider.notifier).setCustomerName(v),
                  ),
                  const SizedBox(height: 12),
                  // Scan error banner
                  if (cart.scanError != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cart.scanError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          // RIGHT: cart + checkout
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: cart.items.isEmpty
                        ? Center(
                            child: Text(
                              context.loc.cartIsEmptyHint,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: cart.items.length,
                            itemBuilder: (context, index) {
                              return PosCartItemRow(
                                item: cart.items[index],
                                onIncrement: () => ref
                                    .read(posCartProvider.notifier)
                                    .incrementItem(
                                        cart.items[index].productId),
                                onDecrement: () => ref
                                    .read(posCartProvider.notifier)
                                    .decrementItem(
                                        cart.items[index].productId),
                                onRemove: () => ref
                                    .read(posCartProvider.notifier)
                                    .removeItem(cart.items[index].productId),
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  // Totals
                  _TotalRow(
                    label: context.loc.subtotal,
                    value: cart.subtotal.toStringAsFixed(2),
                  ),
                  _TotalRow(
                    label: context.loc.total,
                    value: cart.total.toStringAsFixed(2),
                    bold: true,
                  ),
                  const SizedBox(height: 12),
                  // Cash tendered
                  TextField(
                    controller: _cashController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: context.loc.cashTendered,
                      prefixText: 'EGP ',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Checkout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_rounded),
                      label: cart.isCheckingOut
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(context.loc.checkout),
                      onPressed: cart.isCheckingOut ? null : _onCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('EGP $value', style: style),
        ],
      ),
    );
  }
}
