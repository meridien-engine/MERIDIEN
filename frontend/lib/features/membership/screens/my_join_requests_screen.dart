import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/membership_model.dart';
import '../providers/membership_provider.dart';

class MyJoinRequestsScreen extends ConsumerStatefulWidget {
  const MyJoinRequestsScreen({super.key});

  @override
  ConsumerState<MyJoinRequestsScreen> createState() =>
      _MyJoinRequestsScreenState();
}

class _MyJoinRequestsScreenState extends ConsumerState<MyJoinRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(membershipProvider.notifier).loadMyJoinRequests());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(membershipProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.myJoinRequests),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: loc.refresh,
            onPressed: () =>
                ref.read(membershipProvider.notifier).loadMyJoinRequests(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final joined = await context.push<bool>('/membership/find');
          if (joined == true && mounted) {
            ref.read(membershipProvider.notifier).loadMyJoinRequests();
          }
        },
        icon: const Icon(Icons.search_rounded),
        label: Text(loc.findBusiness),
      ),
      body: Builder(builder: (context) {
        if (state.isLoading && state.myRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.myRequests.isEmpty) {
          return _ErrorView(
            message: state.error!,
            onRetry: () =>
                ref.read(membershipProvider.notifier).loadMyJoinRequests(),
          );
        }

        if (state.myRequests.isEmpty) {
          return _EmptyView(
            loc: loc,
            onFind: () => context.push('/membership/find'),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(membershipProvider.notifier).loadMyJoinRequests(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: state.myRequests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) =>
                _JoinRequestTile(request: state.myRequests[index]),
          ),
        );
      }),
    );
  }
}

class _JoinRequestTile extends StatelessWidget {
  final JoinRequestModel request;

  const _JoinRequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(request.status).withOpacity(0.12),
          child: Icon(_statusIcon(request.status),
              color: _statusColor(request.status), size: 20),
        ),
        title: Text(
          request.displayBusiness,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (request.role != null && request.role!.isNotEmpty)
              Text('Requested role: ${request.role}'),
            if (request.createdAt != null)
              Text(
                _formatDate(request.createdAt!),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
        isThreeLine: request.role != null,
        trailing: _StatusChip(status: request.status),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'approved':
        color = Colors.green;
        label = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      default:
        color = Colors.orange;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final AppLocalizations loc;
  final VoidCallback onFind;
  const _EmptyView({required this.loc, required this.onFind});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(loc.noJoinRequests,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(
              loc.noJoinRequestsDesc,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onFind,
              icon: const Icon(Icons.search_rounded),
              label: Text(loc.findBusiness),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}
