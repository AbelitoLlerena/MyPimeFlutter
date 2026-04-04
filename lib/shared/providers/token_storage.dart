import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/core/auth/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});
