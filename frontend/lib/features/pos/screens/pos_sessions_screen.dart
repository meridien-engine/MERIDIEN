import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/localization_extension.dart';
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
      appBar: AppBar(title: Text(context.loc.posSessionHistory)),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('${context.loc.error}: $e'),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(child: Text(context.loc.noSessionsFound));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(context.loc.dateOpened)),
                DataColumn(label: Text(context.loc.status)),
                DataColumn(label: Text(context.loc.posFloat)),
                DataColumn(label: Text(context.loc.expectedCash)),
                DataColumn(label: Text(context.loc.actualCash)),
                DataColumn(label: Text(context.loc.cashDifference)),
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
                          label: Text(s.isOpen
                              ? context.loc.active
                              : context.loc.close),
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
