import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../data/models/branch_model.dart';
import '../providers/branch_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';

class BranchManagementScreen extends ConsumerStatefulWidget {
  const BranchManagementScreen({super.key});

  @override
  ConsumerState<BranchManagementScreen> createState() =>
      _BranchManagementScreenState();
}

class _BranchManagementScreenState
    extends ConsumerState<BranchManagementScreen> {
  String? _businessId;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  void _load() {
    final authState = ref.read(authProvider);
    authState.maybeWhen(
      authenticated: (_, business, __) {
        _businessId = business.id;
        ref.read(branchProvider.notifier).listBranches(business.id);
      },
      orElse: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(branchProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.branches),
        actions: [
          IconButton(
            tooltip: context.loc.refresh,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBranchDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.loc.addBranch),
      ),
      body: Builder(builder: (context) {
        if (state.isLoading && state.branches.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.branches.isEmpty) {
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
                  onPressed: _load,
                  child: Text(context.loc.tryAgain),
                ),
              ],
            ),
          );
        }

        if (state.branches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_tree_outlined,
                    size: 80, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  context.loc.noBranchesYet,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.loc.noBranchesDesc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showBranchDialog(context),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(context.loc.addBranch),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _load(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: state.branches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final branch = state.branches[index];
              return _BranchTile(
                branch: branch,
                onEdit: () => _showBranchDialog(context, branch: branch),
                onDelete: () => _confirmDelete(context, branch),
                onManageAccess: () =>
                    context.push('/branches/${branch.id}/access'),
                onInventory: () => context.push(
                  '/branches/${branch.id}/inventory',
                  extra: branch.name,
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showBranchDialog(BuildContext context, {BranchModel? branch}) {
    showDialog(
      context: context,
      builder: (_) => _BranchFormDialog(
        branch: branch,
        onSave: (name, address, city, phone) async {
          if (branch == null) {
            if (_businessId == null) return;
            final result =
                await ref.read(branchProvider.notifier).createBranch(
                      _businessId!,
                      CreateBranchRequest(
                        name: name,
                        address: address.isEmpty ? null : address,
                        city: city.isEmpty ? null : city,
                        phone: phone.isEmpty ? null : phone,
                      ),
                    );
            if (mounted) {
              _showSnack(
                context,
                result != null
                    ? context.loc.branchCreated
                    : ref.read(branchProvider).error ??
                        context.loc.somethingWentWrong,
                isError: result == null,
              );
            }
          } else {
            final result =
                await ref.read(branchProvider.notifier).updateBranch(
                      branch.id,
                      UpdateBranchRequest(
                        name: name,
                        address: address.isEmpty ? null : address,
                        city: city.isEmpty ? null : city,
                        phone: phone.isEmpty ? null : phone,
                      ),
                    );
            if (mounted) {
              _showSnack(
                context,
                result != null
                    ? context.loc.branchUpdated
                    : ref.read(branchProvider).error ??
                        context.loc.somethingWentWrong,
                isError: result == null,
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, BranchModel branch) async {
    if (branch.isMain) {
      _showSnack(context, context.loc.cannotDeleteMainBranch, isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.loc.deleteBranch),
        content: Text(
            '${context.loc.deleteConfirmation} "${branch.name}"?'),
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
      final ok = await ref.read(branchProvider.notifier).deleteBranch(branch.id);
      if (mounted) {
        _showSnack(
          context,
          ok
              ? context.loc.branchDeleted
              : ref.read(branchProvider).error ??
                  context.loc.somethingWentWrong,
          isError: !ok,
        );
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

// ─── Branch Tile ─────────────────────────────────────────────────────────────

class _BranchTile extends StatelessWidget {
  final BranchModel branch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManageAccess;
  final VoidCallback onInventory;

  const _BranchTile({
    required this.branch,
    required this.onEdit,
    required this.onDelete,
    required this.onManageAccess,
    required this.onInventory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: branch.isActive
              ? AppColors.primary.withOpacity(0.12)
              : AppColors.textSecondary.withOpacity(0.12),
          child: Icon(
            Icons.account_tree_rounded,
            color:
                branch.isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                branch.name,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (branch.isMain)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade400, width: 0.5),
                ),
                child: Text(
                  context.loc.mainBranch,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (branch.city != null && branch.city!.isNotEmpty)
              Text(
                branch.city!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            if (branch.phone != null && branch.phone!.isNotEmpty)
              Text(
                branch.phone!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
          ],
        ),
        isThreeLine: branch.city != null && branch.phone != null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusChip(status: branch.status),
            IconButton(
              tooltip: context.loc.branchInventory,
              icon: const Icon(Icons.inventory_2_rounded, size: 18),
              onPressed: onInventory,
            ),
            IconButton(
              tooltip: context.loc.branchAccess,
              icon: const Icon(Icons.people_outline_rounded, size: 18),
              onPressed: onManageAccess,
            ),
            IconButton(
              tooltip: context.loc.edit,
              icon: const Icon(Icons.edit_rounded, size: 18),
              onPressed: onEdit,
            ),
            if (!branch.isMain)
              IconButton(
                tooltip: context.loc.delete,
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
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    return Container(
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
        isActive ? context.loc.active : context.loc.inactive,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ─── Branch Form Dialog ───────────────────────────────────────────────────────

class _BranchFormDialog extends StatefulWidget {
  final BranchModel? branch;
  final Future<void> Function(
      String name, String address, String city, String phone) onSave;

  const _BranchFormDialog({this.branch, required this.onSave});

  @override
  State<_BranchFormDialog> createState() => _BranchFormDialogState();
}

class _BranchFormDialogState extends State<_BranchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _phoneCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.branch?.name ?? '');
    _addressCtrl = TextEditingController(text: widget.branch?.address ?? '');
    _cityCtrl = TextEditingController(text: widget.branch?.city ?? '');
    _phoneCtrl = TextEditingController(text: widget.branch?.phone ?? '');
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
      title: Text(widget.branch == null
          ? context.loc.addBranch
          : context.loc.editBranch),
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
                  labelText: '${context.loc.branchName} *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.account_tree_rounded),
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
              : Text(widget.branch == null ? context.loc.add : context.loc.save),
        ),
      ],
    );
  }
}
