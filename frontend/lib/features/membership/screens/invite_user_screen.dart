import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../providers/membership_provider.dart';

class InviteUserScreen extends ConsumerStatefulWidget {
  final String businessId;
  const InviteUserScreen({super.key, required this.businessId});

  @override
  ConsumerState<InviteUserScreen> createState() => _InviteUserScreenState();
}

class _InviteUserScreenState extends ConsumerState<InviteUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String _selectedRole = 'viewer';

  static const _roles = [
    'viewer',
    'cashier',
    'operator',
    'manager',
    'admin',
  ];

  @override
  void dispose() {
    _emailController.dispose();
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
              backgroundColor: Colors.green),
        );
        ref.read(membershipProvider.notifier).clearMessages();
        Navigator.of(context).pop(true);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(loc.inviteUser)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.inviteInfo,
                        style: TextStyle(color: Colors.blue[700], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: loc.email,
                  hintText: 'user@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return loc.fieldRequired;
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailRegex.hasMatch(v.trim())) return loc.invalidEmail;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Role selector
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: loc.role,
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: const OutlineInputBorder(),
                ),
                items: _roles
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(_roleLabel(r)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),
              const SizedBox(height: 8),

              // Role description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  _roleDescription(_selectedRole),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              const SizedBox(height: 32),

              // Send button
              FilledButton.icon(
                onPressed: state.isLoading ? null : _send,
                icon: state.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(loc.sendInvitation),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(membershipProvider.notifier).sendInvitation(
          businessId: widget.businessId,
          email: _emailController.text.trim(),
          role: _selectedRole,
        );
  }

  String _roleLabel(String role) {
    switch (role) {
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
        return 'Viewer (Read-only)';
    }
  }

  String _roleDescription(String role) {
    switch (role) {
      case 'admin':
        return 'Can manage members, settings, and all operations.';
      case 'manager':
        return 'Can manage products, orders, and customers.';
      case 'cashier':
        return 'Can operate POS and process payments.';
      case 'operator':
        return 'Can create and manage orders.';
      case 'viewer':
      default:
        return 'Can view data but cannot make changes.';
    }
  }
}
