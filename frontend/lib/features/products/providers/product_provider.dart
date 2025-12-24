import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_state.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/providers/repository_providers.dart';

// Product List Provider
class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductRepository _repository;

  ProductListNotifier(this._repository) : super(const ProductListState.initial());

  Future<void> loadProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    bool? active,
    bool? inStock,
  }) async {
    try {
      if (page == 1) {
        state = const ProductListState.loading();
      }

      final products = await _repository.getProducts(
        page: page,
        limit: limit,
        search: search,
        category: category,
        active: active,
        inStock: inStock,
      );

      state = ProductListState.loaded(
        products: products,
        total: products.length,
        page: page,
        hasMore: products.length >= limit,
      );
    } catch (e) {
      state = ProductListState.error(_extractErrorMessage(e));
    }
  }

  Future<void> refresh() async {
    await loadProducts(page: 1);
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      await refresh();
    } catch (e) {
      state = ProductListState.error(_extractErrorMessage(e));
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

final productListProvider = StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductListNotifier(repository);
});

// Product Detail Provider
class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  final ProductRepository _repository;

  ProductDetailNotifier(this._repository) : super(const ProductDetailState.initial());

  Future<void> loadProduct(String id) async {
    try {
      state = const ProductDetailState.loading();
      final product = await _repository.getProductById(id);
      state = ProductDetailState.loaded(product);
    } catch (e) {
      state = ProductDetailState.error(_extractErrorMessage(e));
    }
  }

  Future<ProductModel?> createProduct(CreateProductRequest request) async {
    try {
      final product = await _repository.createProduct(request);
      return product;
    } catch (e) {
      state = ProductDetailState.error(_extractErrorMessage(e));
      return null;
    }
  }

  Future<ProductModel?> updateProduct(String id, UpdateProductRequest request) async {
    try {
      final product = await _repository.updateProduct(id, request);
      state = ProductDetailState.loaded(product);
      return product;
    } catch (e) {
      state = ProductDetailState.error(_extractErrorMessage(e));
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

final productDetailProvider = StateNotifierProvider<ProductDetailNotifier, ProductDetailState>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductDetailNotifier(repository);
});
