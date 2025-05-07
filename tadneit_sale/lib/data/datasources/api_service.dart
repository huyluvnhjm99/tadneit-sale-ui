import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:tadneit_sale/data/models/auth/auth_token.dart';
import 'package:tadneit_sale/data/models/auth/login_request.dart';
import 'package:tadneit_sale/data/models/auth/login_response.dart';
import 'package:tadneit_sale/data/models/auth/refresh_token_request.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Authentication
  @POST('/auth/login')
  Future<String> login(@Body() LoginRequestDTO request);

  @POST('/auth/refresh')
  Future<AuthTokenDTO> refreshToken(@Body() RefreshTokenRequest request);

  // Example of a protected endpoint
  // @GET('/users/me')
  // Future<Map<String, dynamic>> getUserProfile();

  // Example of a public endpoint
  // @GET('/products')
  // Future<List<dynamic>> getProducts();
}