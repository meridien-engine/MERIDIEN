import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/product_model.dart';

part 'product_state.freezed.dart';

@freezed
class ProductListState with _$ProductListState {
  const factory ProductListState.initial() = _Initial;
  const factory ProductListState.loading() = _Loading;
  const factory ProductListState.loaded({
    required List<ProductModel> products,
    required int total,
    required int page,
    required bool hasMore,
  }) = _Loaded;
  const factory ProductListState.error(String message) = _Error;
}

@freezed
class ProductDetailState with _$ProductDetailState {
  const factory ProductDetailState.initial() = _DetailInitial;
  const factory ProductDetailState.loading() = _DetailLoading;
  const factory ProductDetailState.loaded(ProductModel product) = _DetailLoaded;
  const factory ProductDetailState.error(String message) = _DetailError;
}
