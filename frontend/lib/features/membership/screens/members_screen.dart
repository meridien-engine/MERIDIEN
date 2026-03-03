import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/role_provider.dart';
import '../../../data/models/membership_model.dart';
import '../providers/membership_provider.dart';

class MembersScreen extends ConsumerStatefulWidget {
  final String businessId;
  const MembersScreen({super.key, required this.businessId});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(membershipProvider.notifier).loadMembers(widget.businessId));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(membershipProvider);
    final currentRole = ref.watch(currentUserRoleProvider);
    final isOwner = currentRole == MeridienRole.owner;

    ref.listen<MembershipState>(membershipProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
        ref.read(membershipProvider.notifier).clearMessages();
      }
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.successMessage!),
              backgroundColor: Colors.green),
        );
        ref.read(membershipProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.members),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: loc.refresh,
            onPressed: () =>
                ref.read(membershipProvider.notifier).loadMembers(widget.businessId),
          ),
        ],
      ),
      body: Builder(builder: (context) {
        if (state.isLoading && state.members.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.members.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(membershipProvider.notifier)
                      .loadMembers(widget.businessId),
                  child: Text(loc.tryAgain),
                ),
              ],
            ),
          );
        }

        if (state.members.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.group_rounded, size: 72, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(loc.noMembers,
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(membershipProvider.notifier).loadMembers(widget.businessId),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final member = state.members[index];
              return _MemberCard(
                member: member,
                isOwner: isOwner,
                onChangeRole: isOwner && !member.isOwner
                    ? () => _showRoleDialog(context, member)
                    : null,
                onRemove: isOwner && !member.isOwner
                    ? () => _confirmRemove(context, member)
                    : null,
              );
            },
          ),
        );
      }),
    );
  }

  void _showRoleDialog(BuildContext context, MemberModel member) {
    String selectedRole = member.role;
    const roles = ['viewer', 'cashier', 'operator', 'manager', 'admin'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Change Role — ${member.displayName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: roles
                .map((r) => RadioListTile<String>(
                      value: r,
                      groupValue: selectedRole,
                      title: Text(r),
                      onChanged: (v) =>
                          setDialogState(() => selectedRole = v!),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ref
                    .read(membershipProvider.notifier)
                    .updateMemberRole(widget.businessId, member.userId, selectedRole);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, MemberModel member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
            'Remove ${member.displayName} from this business?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref
          .read(membershipProvider.notifier)
          .removeMember(widget.businessId, member.userId);
    }
  }
}

class _MemberCard extends StatelessWidget {
  final MemberModel member;
  final bool isOwner;
  final VoidCallback? onChangeRole;
  final VoidCallback? onRemove;

  const _MemberCard({
    required this.member,
    required this.isOwner,
    this.onChangeRole,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _roleColor(member.role).withOpacity(0.12),
          child: Text(
            member.displayName.isNotEmpty
                ? member.displayName[0].toUpperCase()
                : '?',
            style: TextStyle(
                color: _roleColor(member.role), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(member.displayName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(member.displayEmail,
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RoleBadge(role: member.role),
            if (onChangeRole != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 18),
                tooltip: 'Change Role',
                onPressed: onChangeRole,
              ),
            ],
            if (onRemove != null)
              IconButton(
                icon: Icon(Icons.remove_circle_outline_rounded,
                    size: 18, color: Colors.red[400]),
                tooltip: 'Remove',
                onPressed: onRemove,
              ),
          ],
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'owner':
        return Colors.purple;
      case 'admin':
        return Colors.indigo;
      case 'manager':
        return Colors.blue;
      case 'operator':
      case 'cashier':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (role) {
      case 'owner':
        color = Colors.purple;
        break;
      case 'admin':
        color = Colors.indigo;
        break;
      case 'manager':
        color = Colors.blue;
        break;
      case 'operator':
      case 'cashier':
        color = Colors.teal;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        role,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
