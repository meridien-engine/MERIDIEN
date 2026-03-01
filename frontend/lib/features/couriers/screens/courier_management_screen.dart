import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/courier_model.dart';
import '../providers/courier_provider.dart';

class CourierManagementScreen extends ConsumerStatefulWidget {
  const CourierManagementScreen({super.key});

  @override
  ConsumerState<CourierManagementScreen> createState() =>
      _CourierManagementScreenState();
}

class _CourierManagementScreenState
    extends ConsumerState<CourierManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(courierProvider.notifier).listCouriers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Couriers'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(courierProvider.notifier).listCouriers(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCourierDialog(context),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Courier'),
      ),
      body: Builder(builder: (context) {
        if (state.isLoading && state.couriers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.couriers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(state.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.error)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(courierProvider.notifier).listCouriers(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.couriers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delivery_dining_rounded,
                    size: 80, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'No couriers yet',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add couriers to assign them to orders and track reconciliation.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(courierProvider.notifier).listCouriers(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: state.couriers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final courier = state.couriers[index];
              return _CourierTile(
                courier: courier,
                onEdit: () => _showCourierDialog(context, courier: courier),
                onDelete: () => _confirmDelete(context, courier),
              );
            },
          ),
        );
      }),
    );
  }

  void _showCourierDialog(BuildContext context, {CourierModel? courier}) {
    showDialog(
      context: context,
      builder: (_) => _CourierFormDialog(
        courier: courier,
        onSave: (name) async {
          if (courier == null) {
            final result = await ref
                .read(courierProvider.notifier)
                .createCourier(CreateCourierRequest(name: name));
            if (result != null && mounted) {
              _showSnack(context, 'Courier created successfully', isError: false);
            } else if (mounted) {
              _showSnack(context,
                  ref.read(courierProvider).error ?? 'Failed to create courier');
            }
          } else {
            final result = await ref
                .read(courierProvider.notifier)
                .updateCourier(courier.id, UpdateCourierRequest(name: name));
            if (result != null && mounted) {
              _showSnack(context, 'Courier updated successfully', isError: false);
            } else if (mounted) {
              _showSnack(context,
                  ref.read(courierProvider).error ?? 'Failed to update courier');
            }
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, CourierModel courier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Courier'),
        content: Text(
            'Are you sure you want to delete "${courier.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok =
          await ref.read(courierProvider.notifier).deleteCourier(courier.id);
      if (mounted) {
        if (ok) {
          _showSnack(context, 'Courier deleted', isError: false);
        } else {
          _showSnack(context,
              ref.read(courierProvider).error ?? 'Failed to delete courier');
        }
      }
    }
  }

  void _showSnack(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : Colors.green,
      ),
    );
  }
}

// ─── Courier Tile ─────────────────────────────────────────────────────────────

class _CourierTile extends StatelessWidget {
  final CourierModel courier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CourierTile({
    required this.courier,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.12),
          child: Text(
            courier.name.isNotEmpty
                ? courier.name[0].toUpperCase()
                : '?',
            style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          courier.name,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_rounded, size: 18),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'Delete',
              icon: Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColors.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Courier Form Dialog ──────────────────────────────────────────────────────

class _CourierFormDialog extends StatefulWidget {
  final CourierModel? courier;
  final Future<void> Function(String name) onSave;

  const _CourierFormDialog({this.courier, required this.onSave});

  @override
  State<_CourierFormDialog> createState() => _CourierFormDialogState();
}

class _CourierFormDialogState extends State<_CourierFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.courier?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.courier == null ? 'Add Courier' : 'Edit Courier'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Courier Name *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_rounded),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Name is required';
            if (v.trim().length < 2) return 'Name too short';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isSaving = true);
                  await widget.onSave(_nameCtrl.text.trim());
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
              : Text(widget.courier == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}
