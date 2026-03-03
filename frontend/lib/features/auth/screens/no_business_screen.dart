import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class NoBusinessScreen extends ConsumerWidget {
  const NoBusinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to MERIDIEN'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_outlined,
                size: 80,
                color: AppColors.primary.withOpacity(0.6),
              ),
              const SizedBox(height: 24),
              Text(
                "You don't belong to any business yet",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Create a new business or ask an admin to invite you.",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => context.push('/business/create'),
                icon: const Icon(Icons.add_business_rounded),
                label: const Text('Create Business'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: null, // Phase 2
                icon: const Icon(Icons.group_add_rounded),
                label: const Text('Join Business (Coming Soon)'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
