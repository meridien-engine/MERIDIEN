import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer_state.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/providers/repository_providers.dart';

// Customer List Provider
class CustomerListNotifier extends StateNotifier<CustomerListState> {
  final CustomerRepository _repository;

  CustomerListNotifier(this._repository) : super(const CustomerListState.initial());

  Future<void> loadCustomers({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? customerType,
  }) async {
    try {
      if (page == 1) {
        state = const CustomerListState.loading();
      }

      final customers = await _repository.getCustomers(
        page: page,
        limit: limit,
        search: search,
        status: status,
        customerType: customerType,
      );

      state = CustomerListState.loaded(
        customers: customers,
        total: customers.length,
        page: page,
        hasMore: customers.length >= limit,
      );
    } catch (e) {
      state = CustomerListState.error(_extractErrorMessage(e));
    }
  }

  Future<void> refresh() async {
    await loadCustomers(page: 1);
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _repository.deleteCustomer(id);
      await refresh();
    } catch (e) {
      state = CustomerListState.error(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map) {
        final data = error.response!.data as Map<String, dynamic>;
        return data['error'] ?? data['message'] ?? 'An error occurred';
      }
      return error.message ?? 'Network error occurred';
    }
    return error.toString();
  }
}

final customerListProvider = StateNotifierProvider<CustomerListNotifier, CustomerListState>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CustomerListNotifier(repository);
});

// Customer Detail Provider
class CustomerDetailNotifier extends StateNotifier<CustomerDetailState> {
  final CustomerRepository _repository;

  CustomerDetailNotifier(this._repository) : super(const CustomerDetailState.initial());

  Future<void> loadCustomer(String id) async {
    try {
      state = const CustomerDetailState.loading();
      final customer = await _repository.getCustomerById(id);
      state = CustomerDetailState.loaded(customer);
    } catch (e) {
      state = CustomerDetailState.error(_extractErrorMessage(e));
    }
  }

  Future<CustomerModel?> createCustomer(CreateCustomerRequest request) async {
    try {
      final customer = await _repository.createCustomer(request);
      return customer;
    } catch (e) {
      state = CustomerDetailState.error(_extractErrorMessage(e));
      return null;
    }
  }

  Future<CustomerModel?> updateCustomer(String id, UpdateCustomerRequest request) async {
    try {
      final customer = await _repository.updateCustomer(id, request);
      state = CustomerDetailState.loaded(customer);
      return customer;
    } catch (e) {
      state = CustomerDetailState.error(_extractErrorMessage(e));
      return null;
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map) {
        final data = error.response!.data as Map<String, dynamic>;
        return data['error'] ?? data['message'] ?? 'An error occurred';
      }
      return error.message ?? 'Network error occurred';
    }
    return error.toString();
  }
}

final customerDetailProvider = StateNotifierProvider<CustomerDetailNotifier, CustomerDetailState>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CustomerDetailNotifier(repository);
});
