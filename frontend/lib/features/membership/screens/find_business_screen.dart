import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../providers/membership_provider.dart';

class FindBusinessScreen extends ConsumerStatefulWidget {
  const FindBusinessScreen({super.key});

  @override
  ConsumerState<FindBusinessScreen> createState() => _FindBusinessScreenState();
}

class _FindBusinessScreenState extends ConsumerState<FindBusinessScreen> {
  final _slugController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedRole = 'viewer';

  static const _roles = ['viewer', 'cashier', 'operator', 'manager', 'admin'];

  @override
  void dispose() {
    _slugController.dispose();
    _messageController.dispose();
    super.dispose();
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
            backgroundColor: Colors.green,
          ),
        );
        ref.read(membershipProvider.notifier).clearMessages();
        Navigator.of(context).pop(true);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(loc.findBusiness)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.findBusinessBySlug,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _slugController,
                            decoration: InputDecoration(
                              labelText: loc.businessSlug,
                              hintText: 'e.g. my-shop',
                              prefixIcon: const Icon(Icons.search_rounded),
                              border: const OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _lookup(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: state.isLoading ? null : _lookup,
                          child: state.isLoading && state.lookedUpBusiness == null
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.search_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Business result
            if (state.lookedUpBusiness != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              state.lookedUpBusiness!.name[0].toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.lookedUpBusiness!.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '@${state.lookedUpBusiness!.slug}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              loc.found,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Role selector
                      Text(loc.requestedRole,
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _roles
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(_roleLabel(r)),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedRole = v!),
                      ),
                      const SizedBox(height: 12),

                      // Message field
                      TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          labelText: loc.messageOptional,
                          hintText: loc.messageHint,
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: state.isLoading ? null : _submitRequest,
                          icon: state.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send_rounded),
                          label: Text(loc.sendJoinRequest),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _lookup() {
    final slug = _slugController.text.trim();
    if (slug.isEmpty) return;
    ref.read(membershipProvider.notifier).lookupBusiness(slug);
  }

  Future<void> _submitRequest() async {
    final business = ref.read(membershipProvider).lookedUpBusiness;
    if (business == null) return;

    await ref.read(membershipProvider.notifier).submitJoinRequest(
          businessSlug: business.slug,
          message: _messageController.text.trim().isEmpty
              ? null
              : _messageController.text.trim(),
          role: _selectedRole,
        );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'owner':
        return 'Owner';
      case 'admin':
        return 'Admin';
      case 'manager':
        return 'Manager';
      case 'cashier':
        return 'Cashier';
      case 'operator':
        return 'Operator';
      case 'viewer':
      default:
        return 'Viewer';
    }
  }
}
