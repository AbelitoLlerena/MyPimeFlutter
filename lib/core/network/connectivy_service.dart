import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mypime/core/sync/application/sync_service.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  final SyncService _syncService;

  StreamSubscription? _subscription;

  ConnectivityService({
    required Connectivity connectivity,
    required SyncService syncService,
  })  : _connectivity = connectivity,
        _syncService = syncService;

  void start() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _syncService.processQueue();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}