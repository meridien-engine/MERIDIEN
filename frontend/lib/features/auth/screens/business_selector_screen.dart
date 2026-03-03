import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/business_model.dart';
import '../providers/auth_provider.dart';
import '../models/auth_state.dart';

class BusinessSelectorScreen extends ConsumerWidget {
  const BusinessSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (_, next) {
      next.maybeWhen(
        authenticated: (user, business, role) => context.go('/dashboard'),
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(message), backgroundColor: AppColors.error),
          );
        },
        orElse: () {},
      );
    });

    final businesses = authState.maybeWhen(
      selectingBusiness: (user, businesses) => businesses,
      orElse: () => <BusinessModel>[],
    );

    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Business'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: isLoading
                ? null
                : () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: businesses.isEmpty
                ? const Center(
                    child: Text('No businesses found'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: businesses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final business = businesses[index];
                      return _BusinessCard(
                        business: business,
                        isLoading: isLoading,
                        onTap: () => ref
                            .read(authProvider.notifier)
                            .selectBusiness(business),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed:
                  isLoading ? null : () => context.push('/business/create'),
              icon: const Icon(Icons.add_business_rounded),
              label: const Text('Create New Business'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessCard extends StatelessWidget {
  final BusinessModel business;
  final bool isLoading;
  final VoidCallback onTap;

  const _BusinessCard({
    required this.business,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: isLoading ? null : onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            business.name.isNotEmpty ? business.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          business.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(business.slug),
        trailing: isLoading
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.primary),
      ),
    );
  }
}
