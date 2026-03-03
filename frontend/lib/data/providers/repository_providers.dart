import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../repositories/business_repository.dart';
import '../repositories/customer_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/location_repository.dart';
import '../repositories/courier_repository.dart';
import '../repositories/pos_repository.dart';
import '../repositories/store_repository.dart';
import '../repositories/membership_repository.dart';
import '../repositories/branch_repository.dart';
import 'dio_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BusinessRepository(dio);
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CustomerRepository(dio);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProductRepository(dio);
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return OrderRepository(dio);
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return LocationRepository(dio);
});

final courierRepositoryProvider = Provider<CourierRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CourierRepository(dio);
});

final posRepositoryProvider = Provider<PosRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PosRepository(dio);
});

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return StoreRepository(dio);
});

final membershipRepositoryProvider = Provider<MembershipRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MembershipRepository(dio);
});

final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BranchRepository(dio);
});
