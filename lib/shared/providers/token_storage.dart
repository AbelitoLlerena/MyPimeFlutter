import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/core/auth/token_storage.dart';
import 'package:mypime/shared/providers/sync_providers.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(isarProvider));
});
