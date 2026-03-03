import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/membership_model.dart';
import '../../../data/providers/repository_providers.dart';

/// Screen shown when a user opens an invitation link with a token.
/// Validates the token and lets the user accept.
class AcceptInvitationScreen extends ConsumerStatefulWidget {
  final String token;
  const AcceptInvitationScreen({super.key, required this.token});

  @override
  ConsumerState<AcceptInvitationScreen> createState() =>
      _AcceptInvitationScreenState();
}

class _AcceptInvitationScreenState
    extends ConsumerState<AcceptInvitationScreen> {
  InvitationModel? _invitation;
  bool _isValidating = true;
  bool _isAccepting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _validate();
  }

  Future<void> _validate() async {
    setState(() {
      _isValidating = true;
      _error = null;
    });
    try {
      final repo = ref.read(membershipRepositoryProvider);
      final inv = await repo.validateInvitation(widget.token);
      setState(() {
        _invitation = inv;
        _isValidating = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isValidating = false;
      });
    }
  }

  Future<void> _accept() async {
    setState(() => _isAccepting = true);
    try {
      final repo = ref.read(membershipRepositoryProvider);
      await repo.acceptInvitation(widget.token);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'You have joined ${_invitation?.displayBusiness ?? 'the business'}!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/business-select');
      }
    } catch (e) {
      setState(() => _isAccepting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.invitation)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _isValidating
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorBody(error: _error!, onRetry: _validate)
                : _InvitationBody(
                    invitation: _invitation!,
                    isAccepting: _isAccepting,
                    onAccept: _accept,
                    onDecline: () => context.go('/dashboard'),
                  ),
      ),
    );
  }
}

class _InvitationBody extends StatelessWidget {
  final InvitationModel invitation;
  final bool isAccepting;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _InvitationBody({
    required this.invitation,
    required this.isAccepting,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
        const Icon(Icons.mark_email_unread_rounded,
            size: 80, color: Colors.indigo),
        const SizedBox(height: 24),

        // Title
        Text(
          'You\'re Invited!',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        Text(
          'You have been invited to join',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Business card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    invitation.displayBusiness.isNotEmpty
                        ? invitation.displayBusiness[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  invitation.displayBusiness,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Role: ${invitation.role}',
                    style: const TextStyle(
                        color: Colors.indigo,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                if (invitation.expiresAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Expires: ${_formatDate(invitation.expiresAt!)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Accept button
        FilledButton.icon(
          onPressed: isAccepting ? null : onAccept,
          icon: isAccepting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_rounded),
          label: const Text('Accept Invitation'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        const SizedBox(height: 8),

        OutlinedButton(
          onPressed: onDecline,
          style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48)),
          child: const Text('Decline'),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

class _ErrorBody extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorBody({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.link_off_rounded, size: 80, color: Colors.red),
        const SizedBox(height: 24),
        Text(
          'Invalid Invitation',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(error, textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => context.go('/dashboard'),
          style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48)),
          child: const Text('Go to Dashboard'),
        ),
      ],
    );
  }
}
