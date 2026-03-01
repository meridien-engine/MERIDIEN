import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/localization_extension.dart';
import '../providers/auth_provider.dart';
import '../models/auth_state.dart';
import '../../../data/models/tenant_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).discoverWorkspaces(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  void _selectWorkspace(TenantModel workspace, String email, String password) {
    ref.read(authProvider.notifier).selectWorkspace(
          workspace.slug,
          email,
          password,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      next.maybeWhen(
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
            ),
          );
        },
        authenticated: (user, tenant) {
          context.go('/dashboard');
        },
        orElse: () {},
      );
    });

    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    final workspaces = authState.maybeWhen(
      workspaceSelection: (email, password, workspaces) => workspaces,
      orElse: () => null,
    );

    final workspaceCredentials = authState.maybeWhen(
      workspaceSelection: (email, password, workspaces) =>
          (email: email, password: password),
      orElse: () => null,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and Title
                  Image.asset(
                    'assets/images/isometric.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.loc.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.loc.login,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Credentials form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: context.loc.email,
                            hintText: 'john@example.com',
                            prefixIcon: const Icon(Icons.email_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isLoading && workspaces == null,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return context.loc.fieldRequired;
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return context.loc.invalidEmail;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: context.loc.password,
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          enabled: !isLoading && workspaces == null,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) =>
                              workspaces == null ? _handleSubmit() : null,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.loc.fieldRequired;
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        if (workspaces == null) ...[
                          ElevatedButton(
                            onPressed: isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Continue',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Workspace selection
                  if (workspaces != null) ...[
                    _WorkspaceList(
                      workspaces: workspaces,
                      isLoading: isLoading,
                      onSelect: (workspace) => _selectWorkspace(
                        workspace,
                        workspaceCredentials!.email,
                        workspaceCredentials.password,
                      ),
                      onBack: () =>
                          ref.read(authProvider.notifier).logout(),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Register link (only shown on step 1)
                  if (workspaces == null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        TextButton(
                          onPressed:
                              isLoading ? null : () => context.push('/register'),
                          child: Text(context.loc.register),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkspaceList extends StatelessWidget {
  final List<TenantModel> workspaces;
  final bool isLoading;
  final void Function(TenantModel) onSelect;
  final VoidCallback onBack;

  const _WorkspaceList({
    required this.workspaces,
    required this.isLoading,
    required this.onSelect,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.business_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              'Select your workspace',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...workspaces.map(
          (workspace) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: isLoading ? null : () => onSelect(workspace),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                alignment: Alignment.centerLeft,
                side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      workspace.name.isNotEmpty
                          ? workspace.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workspace.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          workspace.slug,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: isLoading ? null : onBack,
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Use a different account'),
        ),
      ],
    );
  }
}
