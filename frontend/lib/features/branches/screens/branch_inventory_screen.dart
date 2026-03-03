import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../data/models/branch_inventory_model.dart';
import '../providers/branch_inventory_provider.dart';

class BranchInventoryScreen extends ConsumerStatefulWidget {
  final String branchId;
  final String branchName;

  const BranchInventoryScreen({
    super.key,
    required this.branchId,
    required this.branchName,
  });

  @override
  ConsumerState<BranchInventoryScreen> createState() =>
      _BranchInventoryScreenState();
}

class _BranchInventoryScreenState
    extends ConsumerState<BranchInventoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(branchInventoryProvider.notifier).loadInventory(widget.branchId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(branchInventoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.loc.branchInventory),
            if (widget.branchName.isNotEmpty)
              Text(
                widget.branchName,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white70),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: context.loc.refresh,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref
                .read(branchInventoryProvider.notifier)
                .loadInventory(widget.branchId),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/branches/${widget.branchId}/inventory/activate',
          extra: widget.branchName,
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.loc.activateProduct),
      ),
      body: Builder(builder: (context) {
        if (state.isLoading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref
                      .read(branchInventoryProvider.notifier)
                      .loadInventory(widget.branchId),
                  child: Text(context.loc.tryAgain),
                ),
              ],
            ),
          );
        }

        if (state.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 80, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  context.loc.noInventoryYet,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push(
                    '/branches/${widget.branchId}/inventory/activate',
                    extra: widget.branchName,
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(context.loc.activateProduct),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref
              .read(branchInventoryProvider.notifier)
              .loadInventory(widget.branchId),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _InventoryTile(
                item: item,
                onUpdate: () => _showUpdateDialog(context, item),
                onDeactivate: () => _confirmDeactivate(context, item),
              );
            },
          ),
        );
      }),
    );
  }

  void _showUpdateDialog(BuildContext context, BranchInventoryModel item) {
    showDialog(
      context: context,
      builder: (_) => _UpdateInventoryDialog(
        item: item,
        onSave: (stockQty, priceOverride, threshold, isActive) async {
          final ok = await ref.read(branchInventoryProvider.notifier).update(
                widget.branchId,
                item.productId,
                UpdateInventoryRequest(
                  isActive: isActive,
                  stockQuantity: stockQty,
                  priceOverride: priceOverride,
                  lowStockThreshold: threshold,
                ),
              );
          if (mounted) {
            _showSnack(
              context,
              ok
                  ? context.loc.updated
                  : ref.read(branchInventoryProvider).error ??
                      context.loc.somethingWentWrong,
              isError: !ok,
            );
          }
        },
      ),
    );
  }

  Future<void> _confirmDeactivate(
      BuildContext context, BranchInventoryModel item) async {
    final productName = item.product?.name ?? item.productId;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.loc.deactivateProduct),
        content: Text('${context.loc.deleteConfirmation} "$productName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.loc.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.loc.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await ref
          .read(branchInventoryProvider.notifier)
          .deactivate(widget.branchId, item.productId);
      if (mounted) {
        _showSnack(
          context,
          ok
              ? context.loc.deleted
              : ref.read(branchInventoryProvider).error ??
                  context.loc.somethingWentWrong,
          isError: !ok,
        );
      }
    }
  }

  void _showSnack(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : Colors.green,
      ),
    );
  }
}

// ── Inventory Tile ────────────────────────────────────────────────────────────

class _InventoryTile extends StatelessWidget {
  final BranchInventoryModel item;
  final VoidCallback onUpdate;
  final VoidCallback onDeactivate;

  const _InventoryTile({
    required this.item,
    required this.onUpdate,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final stockColor = item.isOutOfStock
        ? AppColors.error
        : item.isLowStock
            ? AppColors.warning
            : AppColors.success;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.isActive
              ? AppColors.primary.withOpacity(0.12)
              : AppColors.textSecondary.withOpacity(0.12),
          child: Icon(
            Icons.inventory_2_rounded,
            color:
                item.isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                product?.name ?? item.productId,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (!item.isActive)
              _Badge(
                label: context.loc.inactive,
                color: Colors.grey,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product?.sku?.isNotEmpty ?? false)
              Text(
                'SKU: ${product?.sku}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            Row(
              children: [
                Icon(Icons.circle, size: 8, color: stockColor),
                const SizedBox(width: 4),
                Text(
                  '${context.loc.stockQuantity}: ${item.stockQuantity}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: stockColor, fontWeight: FontWeight.w600),
                ),
                if (item.isLowStock) ...[
                  const SizedBox(width: 8),
                  _Badge(
                    label: item.isOutOfStock
                        ? context.loc.outOfStock
                        : context.loc.lowStock,
                    color: item.isOutOfStock ? Colors.red : Colors.orange,
                  ),
                ],
              ],
            ),
            if (item.priceOverride != null && item.priceOverride!.isNotEmpty)
              Text(
                '${context.loc.priceOverride}: ${item.priceOverride}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: context.loc.edit,
              icon: const Icon(Icons.edit_rounded, size: 18),
              onPressed: onUpdate,
            ),
            IconButton(
              tooltip: context.loc.deactivateProduct,
              icon: Icon(Icons.remove_circle_outline_rounded,
                  size: 18, color: AppColors.error),
              onPressed: onDeactivate,
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ── Update Inventory Dialog ───────────────────────────────────────────────────

class _UpdateInventoryDialog extends StatefulWidget {
  final BranchInventoryModel item;
  final Future<void> Function(
    int stockQty,
    String priceOverride,
    int? threshold,
    bool isActive,
  ) onSave;

  const _UpdateInventoryDialog({required this.item, required this.onSave});

  @override
  State<_UpdateInventoryDialog> createState() => _UpdateInventoryDialogState();
}

class _UpdateInventoryDialogState extends State<_UpdateInventoryDialog> {
  late final TextEditingController _stockCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _thresholdCtrl;
  late bool _isActive;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _stockCtrl =
        TextEditingController(text: widget.item.stockQuantity.toString());
    _priceCtrl =
        TextEditingController(text: widget.item.priceOverride ?? '');
    _thresholdCtrl =
        TextEditingController(text: widget.item.lowStockThreshold.toString());
    _isActive = widget.item.isActive;
  }

  @override
  void dispose() {
    _stockCtrl.dispose();
    _priceCtrl.dispose();
    _thresholdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productName = widget.item.product?.name ?? widget.item.productId;
    return AlertDialog(
      title: Text(productName, overflow: TextOverflow.ellipsis),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.loc.active),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _stockCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.loc.stockQuantity,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.inventory_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: context.loc.priceOverride,
                hintText: context.loc.optional,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _thresholdCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.loc.lowStockThreshold,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.warning_amber_rounded),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(context.loc.cancel),
        ),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
                  setState(() => _isSaving = true);
                  final stock = int.tryParse(_stockCtrl.text) ?? 0;
                  final threshold = int.tryParse(_thresholdCtrl.text);
                  await widget.onSave(
                    stock,
                    _priceCtrl.text.trim(),
                    threshold,
                    _isActive,
                  );
                  if (mounted) {
                    setState(() => _isSaving = false);
                    Navigator.pop(context);
                  }
                },
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.loc.save),
        ),
      ],
    );
  }
}
