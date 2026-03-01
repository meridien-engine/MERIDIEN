import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/courier_model.dart';
import '../providers/courier_provider.dart';

class CourierReconciliationScreen extends ConsumerStatefulWidget {
  const CourierReconciliationScreen({super.key});

  @override
  ConsumerState<CourierReconciliationScreen> createState() =>
      _CourierReconciliationScreenState();
}

class _CourierReconciliationScreenState
    extends ConsumerState<CourierReconciliationScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(courierReconciliationProvider.notifier).loadReconciliation();
    });
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'Select';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'From Date',
    );
    if (picked != null) {
      setState(() => _fromDate = picked);
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'To Date',
    );
    if (picked != null) {
      setState(() => _toDate = picked);
    }
  }

  Future<void> _applyFilter() async {
    await ref
        .read(courierReconciliationProvider.notifier)
        .loadReconciliation(
          fromDate: _fromDate == null ? null : _formatDate(_fromDate),
          toDate: _toDate == null ? null : _formatDate(_toDate),
        );
  }

  void _clearFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
    ref.read(courierReconciliationProvider.notifier).loadReconciliation();
  }

  /// Generate a simple CSV string and display it in a dialog
  /// (Real export would use the `csv` or `share_plus` package)
  void _exportCsv(List<CourierReconciliationModel> items) {
    final buffer = StringBuffer();
    buffer.writeln('Courier,Delivered Amount,Collected Amount,Pending Amount');
    for (final item in items) {
      buffer.writeln(
          '${_csvEscape(item.courierName)},${item.deliveredAmount},${item.collectedAmount},${item.pendingAmount}');
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('CSV Export'),
        content: SingleChildScrollView(
          child: SelectableText(
            buffer.toString(),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _csvEscape(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courierReconciliationProvider);

    // Compute totals
    double totalDelivered = 0;
    double totalCollected = 0;
    double totalPending = 0;
    for (final item in state.items) {
      totalDelivered += item.deliveredAmountValue;
      totalCollected += item.collectedAmountValue;
      totalPending += item.pendingAmountValue;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courier Reconciliation'),
        actions: [
          if (state.items.isNotEmpty)
            IconButton(
              tooltip: 'Export CSV',
              icon: const Icon(Icons.file_download_rounded),
              onPressed: () => _exportCsv(state.items),
            ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _applyFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Date-Range Filter Card ──────────────────────────────────
          Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date Range Filter',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.date_range_rounded, size: 18),
                          label: Text('From: ${_formatDate(_fromDate)}'),
                          onPressed: _pickFromDate,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.date_range_rounded, size: 18),
                          label: Text('To: ${_formatDate(_toDate)}'),
                          onPressed: _pickToDate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.filter_alt_rounded, size: 18),
                          label: const Text('Apply Filter'),
                          onPressed: _applyFilter,
                        ),
                      ),
                      if (_fromDate != null || _toDate != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Clear filters',
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: _clearFilters,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Summary Cards ─────────────────────────────────────────────
          if (state.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _SummaryCard(
                    label: 'Total Delivered',
                    amount: totalDelivered,
                    color: Colors.blue,
                    icon: Icons.local_shipping_rounded,
                  ),
                  const SizedBox(width: 8),
                  _SummaryCard(
                    label: 'Total Collected',
                    amount: totalCollected,
                    color: Colors.green,
                    icon: Icons.payments_rounded,
                  ),
                  const SizedBox(width: 8),
                  _SummaryCard(
                    label: 'Pending',
                    amount: totalPending,
                    color: Colors.orange,
                    icon: Icons.pending_actions_rounded,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // ── Content ───────────────────────────────────────────────────
          Expanded(
            child: Builder(builder: (context) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null) {
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
                        onPressed: _applyFilter,
                        child: const Text('Retry'),
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
                      Icon(Icons.receipt_long_rounded,
                          size: 80, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'No reconciliation data',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'There are no delivered orders in the selected range.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return _ReconciliationRow(item: item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Reconciliation Row ───────────────────────────────────────────────────────

class _ReconciliationRow extends StatelessWidget {
  final CourierReconciliationModel item;

  const _ReconciliationRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(
                    item.courierName.isNotEmpty
                        ? item.courierName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.courierName,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.pendingAmountValue > 0
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.pendingAmountValue > 0 ? 'Pending' : 'Settled',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: item.pendingAmountValue > 0
                              ? Colors.orange.shade700
                              : Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AmountColumn(
                  label: 'Delivered',
                  amount: item.deliveredAmountValue,
                  color: Colors.blue,
                ),
                _AmountColumn(
                  label: 'Collected',
                  amount: item.collectedAmountValue,
                  color: Colors.green,
                ),
                _AmountColumn(
                  label: 'Pending',
                  amount: item.pendingAmountValue,
                  color: item.pendingAmountValue > 0
                      ? Colors.orange
                      : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _AmountColumn({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}
