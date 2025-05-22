import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:tadneit_sale/data/models/auth/auth_token.dart';
import 'package:tadneit_sale/data/models/auth/login_request.dart';
import 'package:tadneit_sale/data/models/auth/refresh_token_request.dart';
import 'package:tadneit_sale/data/models/auth/user_profile.dart';
import 'package:tadneit_sale/data/models/file/file.dart';
import 'package:tadneit_sale/data/models/item/category.dart';

part 'api_service.g.dart';
// dart run build_runner build

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Authentication
  @POST('/auth/login')
  Future<String> login(@Body() LoginRequestDTO request);

  @POST('/auth/refresh')
  Future<AuthTokenDTO> refreshToken(@Body() RefreshTokenRequest request);

  // User Management
  @POST('/u/profile')
  Future<UserProfileDTO> getUserProfile();

  @PUT('/u/save')
  Future<UserProfileDTO> saveUserProfile(@Body() UserProfileDTO userProfileDTO);

  // Item Management
  @GET('/c/count')
  Future<int> getCount();

  @GET('/c')
  Future<List<CategoryDTO>> getCategories();

  @POST('/c')
  Future<void> saveCategory(@Body() CategoryDTO categoryDTO);

  @PUT('/c')
  Future<void> updateCategory(@Body() CategoryDTO categoryDTO);

  @DELETE('/c/{id}')
  Future<void> deleteCategory(@Path('id') String id);

  // File Management
  @GET('/f/l')
  Future<String> getLink(@Query('path') String path);

  @POST('/f/u-i')
  @MultiPart()
  Future<FileDTO> uploadFile(@Part(name: 'file') File file);

  // Example of a protected endpoint
  // @GET('/users/me')
  // Future<Map<String, dynamic>> getUserProfile();

  // Example of a public endpoint
  // @GET('/products')
  // Future<List<dynamic>> getProducts();
}