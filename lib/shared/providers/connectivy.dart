import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/core/network/connectivy_service.dart';
import 'package:mypime/shared/providers/sync_providers.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final connectivity = Connectivity();

  final service = ConnectivityService(
    syncService: ref.watch(syncServiceProvider),
    connectivity: connectivity,
  );

  // Mantenerlo activo
  service.start();

  // Cancelar al liberar
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
