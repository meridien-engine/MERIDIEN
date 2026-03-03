import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/membership_model.dart';
import '../providers/membership_provider.dart';

class JoinRequestsScreen extends ConsumerStatefulWidget {
  final String businessId;
  const JoinRequestsScreen({super.key, required this.businessId});

  @override
  ConsumerState<JoinRequestsScreen> createState() => _JoinRequestsScreenState();
}

class _JoinRequestsScreenState extends ConsumerState<JoinRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(membershipProvider.notifier)
        .loadBusinessJoinRequests(widget.businessId));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(membershipProvider);

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

    final pending = state.businessRequests
        .where((r) => r.isPending)
        .toList();
    final reviewed = state.businessRequests
        .where((r) => !r.isPending)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.joinRequests),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: loc.refresh,
            onPressed: () => ref
                .read(membershipProvider.notifier)
                .loadBusinessJoinRequests(widget.businessId),
          ),
        ],
      ),
      body: Builder(builder: (context) {
        if (state.isLoading && state.businessRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.businessRequests.isEmpty) {
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
                      .loadBusinessJoinRequests(widget.businessId),
                  child: Text(loc.tryAgain),
                ),
              ],
            ),
          );
        }

        if (state.businessRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.how_to_reg_rounded,
                    size: 72, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(loc.noJoinRequests,
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref
              .read(membershipProvider.notifier)
              .loadBusinessJoinRequests(widget.businessId),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                _SectionHeader(title: loc.pendingRequests, count: pending.length),
                const SizedBox(height: 8),
                ...pending.map((r) => _JoinRequestCard(
                      request: r,
                      businessId: widget.businessId,
                      onApprove: (role) => ref
                          .read(membershipProvider.notifier)
                          .approveJoinRequest(widget.businessId, r.id,
                              role: role),
                      onReject: () => ref
                          .read(membershipProvider.notifier)
                          .rejectJoinRequest(widget.businessId, r.id),
                    )),
              ],
              if (reviewed.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionHeader(
                    title: loc.reviewedRequests, count: reviewed.length),
                const SizedBox(height: 8),
                ...reviewed.map((r) => _JoinRequestCard(
                      request: r,
                      businessId: widget.businessId,
                    )),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.grey[700])),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$count',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _JoinRequestCard extends ConsumerStatefulWidget {
  final JoinRequestModel request;
  final String businessId;
  final Future<bool> Function(String? role)? onApprove;
  final Future<bool> Function()? onReject;

  const _JoinRequestCard({
    required this.request,
    required this.businessId,
    this.onApprove,
    this.onReject,
  });

  @override
  ConsumerState<_JoinRequestCard> createState() => _JoinRequestCardState();
}

class _JoinRequestCardState extends ConsumerState<_JoinRequestCard> {
  String _approvalRole = 'viewer';

  static const _roles = [
    'viewer',
    'cashier',
    'operator',
    'manager',
    'admin',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.request.role != null && widget.request.role!.isNotEmpty) {
      _approvalRole = widget.request.role!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final isPending = req.isPending;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    req.displayName.isNotEmpty
                        ? req.displayName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(req.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (req.user?.email != null)
                        Text(req.user!.email,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                if (!isPending)
                  _StatusBadge(status: req.status),
              ],
            ),
            if (req.message != null && req.message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(req.message!,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              ),
            ],
            if (isPending && widget.onApprove != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _approvalRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        isDense: true,
                      ),
                      items: _roles
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text(r, style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _approvalRole = v!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.green),
                    onPressed: () => widget.onApprove?.call(_approvalRole),
                    child: const Text('Approve'),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red),
                    onPressed: () => widget.onReject?.call(),
                    child: const Text('Reject'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isApproved = status == 'approved';
    final color = isApproved ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isApproved ? 'Approved' : 'Rejected',
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
