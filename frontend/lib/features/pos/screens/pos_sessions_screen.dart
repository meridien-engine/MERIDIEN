import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/pos_model.dart';
import '../../../data/providers/repository_providers.dart';

final _sessionsProvider = FutureProvider<List<PosSessionModel>>((ref) async {
  final repo = ref.watch(posRepositoryProvider);
  return repo.listSessions();
});

class PosSessionsScreen extends ConsumerWidget {
  const PosSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(_sessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('POS Session History')),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('No sessions found'));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date Opened')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Float')),
                DataColumn(label: Text('Expected')),
                DataColumn(label: Text('Actual')),
                DataColumn(label: Text('Diff')),
              ],
              rows: sessions
                  .map(
                    (s) => DataRow(
                      cells: [
                        DataCell(Text(
                          '${s.openedAt.year}-'
                          '${s.openedAt.month.toString().padLeft(2, '0')}-'
                          '${s.openedAt.day.toString().padLeft(2, '0')} '
                          '${s.openedAt.hour.toString().padLeft(2, '0')}:'
                          '${s.openedAt.minute.toString().padLeft(2, '0')}',
                        )),
                        DataCell(Chip(
                          label: Text(s.status),
                          backgroundColor: s.isOpen
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                        )),
                        DataCell(Text('EGP ${s.openingFloat}')),
                        DataCell(Text(
                          s.expectedCash != null
                              ? 'EGP ${s.expectedCash}'
                              : '-',
                        )),
                        DataCell(Text(
                          s.closingCash != null
                              ? 'EGP ${s.closingCash}'
                              : '-',
                        )),
                        DataCell(Text(
                          s.cashDifference != null
                              ? 'EGP ${s.cashDifference}'
                              : '-',
                          style: TextStyle(
                            color: _diffColor(s.cashDifference),
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ],
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  Color? _diffColor(String? diff) {
    if (diff == null) return null;
    final v = double.tryParse(diff) ?? 0.0;
    if (v > 0) return Colors.green;
    if (v < 0) return Colors.red;
    return null;
  }
}
