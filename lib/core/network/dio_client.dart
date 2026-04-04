import 'package:dio/dio.dart';
import '../auth/token_storage.dart';

class DioClient {
  final Dio dio;

  DioClient._internal(this.dio);

  factory DioClient.create({
    required String baseUrl,
    required TokenStorage storage,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(storage), // ✅ ahora sí tiene acceso al token
      _LogInterceptor(),
      _ErrorInterceptor(),
    ]);

    return DioClient._internal(dio);
  }
}

/// -------------------------
/// AUTH INTERCEPTOR
/// -------------------------
class _AuthInterceptor extends Interceptor {
  final TokenStorage storage;

  _AuthInterceptor(this.storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}

/// -------------------------
/// LOG INTERCEPTOR
/// -------------------------
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST: ${options.method} ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('ERROR: ${err.message}');
    super.onError(err, handler);
  }
}

/// -------------------------
/// ERROR INTERCEPTOR
/// -------------------------
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Aquí puedes mapear errores globales (401, 500, etc.)
    super.onError(err, handler);
  }
}

// class _ErrorInterceptor extends Interceptor {
//   final TokenStorage storage;
//   final VoidCallback? onUnauthorized;

//   _ErrorInterceptor(this.storage, {this.onUnauthorized});

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     if (err.response?.statusCode == 401) {
//       await storage.clear();

//       // 🔥 callback global (ej: navegar a login)
//       onUnauthorized?.call();
//     }

//     handler.next(err);
//   }
// }