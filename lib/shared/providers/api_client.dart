import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/core/network/api_client.dart';
import 'package:mypime/core/network/dio_client.dart';
import 'package:mypime/shared/providers/token_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(tokenStorageProvider);

  final dioClient = DioClient.create(
    baseUrl: 'http://localhost:3000',
    storage: storage,
  );

  return dioClient.dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
