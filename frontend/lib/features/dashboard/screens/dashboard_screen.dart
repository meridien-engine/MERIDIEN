import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../shared/widgets/language_toggle_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/auth_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.maybeWhen(
      authenticated: (user, tenant) => Scaffold(
        appBar: AppBar(
          title: Text(context.loc.appName),
          actions: [
            const LanguageToggleButton(),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  user.firstName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        tenant?.name ?? 'No Tenant',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded),
                      const SizedBox(width: 8),
                      Text(context.loc.logout),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    });
                  },
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.dashboard_rounded,
                  size: 80,
                  color: AppColors.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  '${context.loc.welcome} ${context.loc.appName}!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  context.loc.quickActions,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _QuickActionCard(
                      icon: Icons.people_rounded,
                      label: context.loc.customers,
                      color: AppColors.primary,
                      onTap: () => context.push('/customers'),
                    ),
                    _QuickActionCard(
                      icon: Icons.inventory_2_rounded,
                      label: context.loc.products,
                      color: AppColors.secondary,
                      onTap: () => context.push('/products'),
                    ),
                    _QuickActionCard(
                      icon: Icons.shopping_cart_rounded,
                      label: context.loc.orders,
                      color: AppColors.warning,
                      onTap: () => context.push('/orders'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'User',
                          value: user.fullName,
                        ),
                        const Divider(),
                        _InfoRow(
                          label: 'Email',
                          value: user.email,
                        ),
                        const Divider(),
                        _InfoRow(
                          label: 'Tenant',
                          value: tenant?.name ?? 'No Tenant',
                        ),
                        const Divider(),
                        _InfoRow(
                          label: 'Role',
                          value: user.role,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      orElse: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 140,
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
