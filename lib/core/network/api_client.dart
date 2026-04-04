import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic data) parser,
  }) async {
    final response = await dio.get(path, queryParameters: query);
    return parser(response.data);
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic data) parser,
  }) async {
    final response = await dio.post(path, data: data);
    return parser(response.data);
  }

  Future<T> delete<T>(
    String path, {
    required T Function(dynamic data) parser,
  }) async {
    final response = await dio.delete(path);
    return parser(response.data);
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic data) parser,
  }) async {
    final response = await dio.put(path, data: data);
    return parser(response.data);
  }
}