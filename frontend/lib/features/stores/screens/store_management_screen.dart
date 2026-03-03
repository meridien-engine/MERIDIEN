import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../data/models/store_model.dart';
import '../providers/store_provider.dart';

class StoreManagementScreen extends ConsumerStatefulWidget {
  const StoreManagementScreen({super.key});

  @override
  ConsumerState<StoreManagementScreen> createState() =>
      _StoreManagementScreenState();
}

class _StoreManagementScreenState
    extends ConsumerState<StoreManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(storeProvider.notifier).listStores());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.stores),
        actions: [
          IconButton(
            tooltip: context.loc.refresh,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(storeProvider.notifier).listStores(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStoreDialog(context),
        icon: const Icon(Icons.add_business_rounded),
        label: Text(context.loc.addStore),
      ),
      body: Builder(builder: (context) {
        if (state.isLoading && state.stores.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.stores.isEmpty) {
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
                  onPressed: () =>
                      ref.read(storeProvider.notifier).listStores(),
                  child: Text(context.loc.tryAgain),
                ),
              ],
            ),
          );
        }

        if (state.stores.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront_outlined,
                    size: 80, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  context.loc.noStoresYet,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.loc.noStoresDesc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showStoreDialog(context),
                  icon: const Icon(Icons.add_business_rounded),
                  label: Text(context.loc.addStore),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(storeProvider.notifier).listStores(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: state.stores.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final store = state.stores[index];
              return _StoreTile(
                store: store,
                onEdit: () => _showStoreDialog(context, store: store),
                onDelete: () => _confirmDelete(context, store),
                onToggleActive: () => _toggleActive(store),
              );
            },
          ),
        );
      }),
    );
  }

  void _showStoreDialog(BuildContext context, {StoreModel? store}) {
    showDialog(
      context: context,
      builder: (_) => _StoreFormDialog(
        store: store,
        onSave: (name, address, city, phone, isActive) async {
          if (store == null) {
            final result = await ref.read(storeProvider.notifier).createStore(
                  CreateStoreRequest(
                    name: name,
                    address: address.isEmpty ? null : address,
                    city: city.isEmpty ? null : city,
                    phone: phone.isEmpty ? null : phone,
                    isActive: isActive,
                  ),
                );
            if (mounted) {
              _showSnack(
                context,
                result != null
                    ? context.loc.storeCreated
                    : ref.read(storeProvider).error ?? context.loc.somethingWentWrong,
                isError: result == null,
              );
            }
          } else {
            final result = await ref.read(storeProvider.notifier).updateStore(
                  store.id,
                  UpdateStoreRequest(
                    name: name,
                    address: address.isEmpty ? null : address,
                    city: city.isEmpty ? null : city,
                    phone: phone.isEmpty ? null : phone,
                    isActive: isActive,
                  ),
                );
            if (mounted) {
              _showSnack(
                context,
                result != null
                    ? context.loc.storeUpdated
                    : ref.read(storeProvider).error ?? context.loc.somethingWentWrong,
                isError: result == null,
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, StoreModel store) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.loc.deleteStore),
        content: Text(
            '${context.loc.deleteConfirmation} "${store.name}"?'),
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
      final ok =
          await ref.read(storeProvider.notifier).deleteStore(store.id);
      if (mounted) {
        _showSnack(
          context,
          ok
              ? context.loc.storeDeleted
              : ref.read(storeProvider).error ?? context.loc.somethingWentWrong,
          isError: !ok,
        );
      }
    }
  }

  Future<void> _toggleActive(StoreModel store) async {
    await ref.read(storeProvider.notifier).updateStore(
          store.id,
          UpdateStoreRequest(isActive: !store.isActive),
        );
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

// ─── Store Tile ────────────────────────────────────────────────────────────────

class _StoreTile extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _StoreTile({
    required this.store,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: store.isActive
              ? AppColors.primary.withOpacity(0.12)
              : AppColors.textSecondary.withOpacity(0.12),
          child: Icon(
            Icons.storefront_rounded,
            color: store.isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        title: Text(
          store.name,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (store.city != null && store.city!.isNotEmpty)
              Text(
                store.city!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            if (store.phone != null && store.phone!.isNotEmpty)
              Text(
                store.phone!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
          ],
        ),
        isThreeLine:
            store.city != null && store.phone != null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusChip(isActive: store.isActive, onTap: onToggleActive),
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

class _StatusChip extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _StatusChip({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.green.shade300 : Colors.grey.shade400,
            width: 0.5,
          ),
        ),
        child: Text(
          isActive ? 'Active' : 'Inactive',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

// ─── Store Form Dialog ─────────────────────────────────────────────────────────

class _StoreFormDialog extends StatefulWidget {
  final StoreModel? store;
  final Future<void> Function(
      String name, String address, String city, String phone, bool isActive)
      onSave;

  const _StoreFormDialog({this.store, required this.onSave});

  @override
  State<_StoreFormDialog> createState() => _StoreFormDialogState();
}

class _StoreFormDialogState extends State<_StoreFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _phoneCtrl;
  late bool _isActive;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.store?.name ?? '');
    _addressCtrl = TextEditingController(text: widget.store?.address ?? '');
    _cityCtrl = TextEditingController(text: widget.store?.city ?? '');
    _phoneCtrl = TextEditingController(text: widget.store?.phone ?? '');
    _isActive = widget.store?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.store == null
          ? context.loc.addStore
          : context.loc.editStore),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: '${context.loc.storeName} *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.storefront_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return context.loc.fieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityCtrl,
                decoration: InputDecoration(
                  labelText: context.loc.city,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_city_rounded),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: InputDecoration(
                  labelText: context.loc.address,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.pin_drop_rounded),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: InputDecoration(
                  labelText: context.loc.phone,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone_rounded),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(context.loc.active),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
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
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isSaving = true);
                  await widget.onSave(
                    _nameCtrl.text.trim(),
                    _addressCtrl.text.trim(),
                    _cityCtrl.text.trim(),
                    _phoneCtrl.text.trim(),
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
              : Text(widget.store == null ? context.loc.add : context.loc.save),
        ),
      ],
    );
  }
}
