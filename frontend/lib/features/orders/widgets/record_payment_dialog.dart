import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../providers/order_provider.dart';

class RecordPaymentDialog extends ConsumerStatefulWidget {
  final String orderId;
  final double balanceDue;
  final VoidCallback? onPaymentRecorded;

  const RecordPaymentDialog({
    super.key,
    required this.orderId,
    required this.balanceDue,
    this.onPaymentRecorded,
  });

  @override
  ConsumerState<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _transactionReferenceController = TextEditingController();
  final _notesController = TextEditingController();

  String _paymentMethod = 'cash';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.balanceDue.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transactionReferenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final request = RecordPaymentRequest(
      amount: _amountController.text.trim(),
      paymentMethod: _paymentMethod,
      transactionReference: _transactionReferenceController.text.trim().isEmpty
          ? null
          : _transactionReferenceController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final result = await ref
        .read(orderDetailProvider.notifier)
        .recordPayment(widget.orderId, request);

    setState(() => _isSubmitting = false);

    if (result != null && mounted) {
      Navigator.pop(context);
      widget.onPaymentRecorded?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.loc.recordPayment),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Due
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${context.loc.balanceDue}:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '\$${widget.balanceDue.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: '${context.loc.amount} *',
                  prefixText: '\$ ',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.loc.amountRequired;
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return context.loc.enterValidAmount;
                  }
                  if (amount > widget.balanceDue) {
                    return context.loc.amountExceedsBalance;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Payment Method
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: InputDecoration(
                  labelText: '${context.loc.paymentMethod} *',
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'cash', child: Text(context.loc.cash)),
                  DropdownMenuItem(value: 'card', child: Text(context.loc.card)),
                  DropdownMenuItem(value: 'bank_transfer', child: Text(context.loc.bankTransfer)),
                  DropdownMenuItem(value: 'check', child: Text(context.loc.check)),
                  DropdownMenuItem(value: 'other', child: Text(context.loc.other)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _paymentMethod = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Transaction Reference
              TextFormField(
                controller: _transactionReferenceController,
                decoration: InputDecoration(
                  labelText: context.loc.transactionReferenceOptional,
                  hintText: context.loc.transactionReferenceHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: context.loc.notes,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text(context.loc.cancel),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitPayment,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.loc.recordPayment),
        ),
      ],
    );
  }
}
