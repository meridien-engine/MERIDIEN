import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/localization_extension.dart';
import '../providers/pos_provider.dart';
import 'pos_terminal_screen.dart';

class PosSessionGateScreen extends ConsumerStatefulWidget {
  const PosSessionGateScreen({super.key});

  @override
  ConsumerState<PosSessionGateScreen> createState() =>
      _PosSessionGateScreenState();
}

class _PosSessionGateScreenState
    extends ConsumerState<PosSessionGateScreen> {
  final _floatController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(posSessionProvider.notifier).checkCurrentSession(),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(posSessionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.loc.pointOfSale)),
      body: switch (sessionState.status) {
        PosSessionStatus.initial ||
        PosSessionStatus.loading =>
          const Center(child: CircularProgressIndicator()),
        PosSessionStatus.sessionOpen => PosTerminalScreen(
            session: sessionState.session!,
          ),
        PosSessionStatus.noSession =>
          _OpenSessionCard(floatController: _floatController),
        PosSessionStatus.error => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sessionState.errorMessage ?? context.loc.anErrorOccurred,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(posSessionProvider.notifier)
                      .checkCurrentSession(),
                  child: Text(context.loc.retry),
                ),
              ],
            ),
          ),
      },
    );
  }
}

class _OpenSessionCard extends ConsumerWidget {
  final TextEditingController floatController;

  const _OpenSessionCard({required this.floatController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.point_of_sale_rounded,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  context.loc.openCashSession,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.loc.posOpenSessionDesc,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: floatController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.loc.openingFloat,
                    border: const OutlineInputBorder(),
                    prefixText: 'EGP ',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.lock_open_rounded),
                    label: Text(context.loc.openSession),
                    onPressed: () {
                      ref.read(posSessionProvider.notifier).openSession(
                            floatController.text.trim().isEmpty
                                ? '0'
                                : floatController.text.trim(),
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
