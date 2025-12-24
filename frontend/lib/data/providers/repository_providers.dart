import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../repositories/customer_repository.dart';
import 'dio_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CustomerRepository(dio);
});
