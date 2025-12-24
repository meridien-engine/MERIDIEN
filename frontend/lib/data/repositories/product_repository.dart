import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/product_model.dart';

part 'product_repository.g.dart';

@RestApi()
abstract class ProductRepository {
  factory ProductRepository(Dio dio, {String baseUrl}) = _ProductRepository;

  @GET('/products')
  Future<List<ProductModel>> getProducts({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
    @Query('category') String? category,
    @Query('active') bool? active,
    @Query('in_stock') bool? inStock,
  });

  @GET('/products/{id}')
  Future<ProductModel> getProductById(@Path('id') String id);

  @POST('/products')
  Future<ProductModel> createProduct(@Body() CreateProductRequest request);

  @PUT('/products/{id}')
  Future<ProductModel> updateProduct(
    @Path('id') String id,
    @Body() UpdateProductRequest request,
  );

  @DELETE('/products/{id}')
  Future<void> deleteProduct(@Path('id') String id);
}
