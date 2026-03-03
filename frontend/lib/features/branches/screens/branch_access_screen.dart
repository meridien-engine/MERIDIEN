import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/providers/repository_providers.dart';

class BranchAccessScreen extends ConsumerStatefulWidget {
  final String branchId;

  const BranchAccessScreen({super.key, required this.branchId});

  @override
  ConsumerState<BranchAccessScreen> createState() => _BranchAccessScreenState();
}

class _BranchAccessScreenState extends ConsumerState<BranchAccessScreen> {
  List<BranchUserModel> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(branchRepositoryProvider);
      final users = await repo.listAccess(widget.branchId);
      if (mounted) setState(() => _users = users);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.branchAccess),
        actions: [
          IconButton(
            tooltip: context.loc.refresh,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGrantDialog(context),
        icon: const Icon(Icons.person_add_rounded),
        label: Text(context.loc.grantAccess),
      ),
      body: Builder(builder: (context) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _load,
                  child: Text(context.loc.tryAgain),
                ),
              ],
            ),
          );
        }

        if (_users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline_rounded,
                    size: 80, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  context.loc.noUsersWithAccess,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showGrantDialog(context),
                  icon: const Icon(Icons.person_add_rounded),
                  label: Text(context.loc.grantAccess),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _load,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: _users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = _users[index];
              final user = record.user;
              final displayName = user != null
                  ? '${user.firstName} ${user.lastName}'.trim()
                  : record.userId;
              final email = user?.email ?? '';

              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                  title: Text(
                    displayName,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: email.isNotEmpty ? Text(email) : null,
                  trailing: IconButton(
                    tooltip: context.loc.revokeAccess,
                    icon: Icon(Icons.person_remove_rounded,
                        color: AppColors.error),
                    onPressed: () =>
                        _confirmRevoke(context, record),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showGrantDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.loc.grantAccess),
        content: SizedBox(
          width: 360,
          child: TextFormField(
            controller: ctrl,
            decoration: InputDecoration(
              labelText: 'User ID',
              hintText: 'Enter the user UUID',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_rounded),
            ),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final userId = ctrl.text.trim();
              if (userId.isEmpty) return;
              Navigator.pop(ctx);
              await _grantAccess(userId);
            },
            child: Text(context.loc.grantAccess),
          ),
        ],
      ),
    );
  }

  Future<void> _grantAccess(String userId) async {
    try {
      final repo = ref.read(branchRepositoryProvider);
      await repo.grantAccess(widget.branchId, userId);
      await _load();
      if (mounted) {
        _showSnack(context, context.loc.accessGranted, isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showSnack(context, e.toString());
      }
    }
  }

  Future<void> _confirmRevoke(
      BuildContext context, BranchUserModel record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.loc.revokeAccess),
        content: Text(context.loc.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.loc.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.loc.revokeAccess),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(branchRepositoryProvider);
        await repo.revokeAccess(widget.branchId, record.userId);
        await _load();
        if (mounted) {
          _showSnack(context, context.loc.accessRevoked, isError: false);
        }
      } catch (e) {
        if (mounted) {
          _showSnack(context, e.toString());
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
