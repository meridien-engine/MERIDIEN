import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/customer_model.dart';

part 'customer_repository.g.dart';

@RestApi()
abstract class CustomerRepository {
  factory CustomerRepository(Dio dio, {String baseUrl}) = _CustomerRepository;

  @GET('/customers')
  Future<List<CustomerModel>> getCustomers({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
    @Query('status') String? status,
    @Query('customer_type') String? customerType,
  });

  @GET('/customers/{id}')
  Future<CustomerModel> getCustomerById(@Path('id') String id);

  @POST('/customers')
  Future<CustomerModel> createCustomer(@Body() CreateCustomerRequest request);

  @PUT('/customers/{id}')
  Future<CustomerModel> updateCustomer(
    @Path('id') String id,
    @Body() UpdateCustomerRequest request,
  );

  @DELETE('/customers/{id}')
  Future<void> deleteCustomer(@Path('id') String id);
}
