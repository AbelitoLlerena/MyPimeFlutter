import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:mypime/core/auth/session_isar_model.dart';
import 'package:mypime/features/users/domain/entities/user_entity.dart';
import 'package:mypime/features/users/domain/enums/user_role_enum.dart';

class TokenStorage {
  TokenStorage(this._isar);

  final Isar _isar;

  Future<void> saveToken(String token) async {
    await _isar.writeTxn(() async {
      final cur = await _isar.sessionIsarModels.get(1);
      final s = cur ?? (SessionIsarModel()..id = 1);
      s.accessToken = token;
      await _isar.sessionIsarModels.put(s);
    });
  }

  Future<String?> getToken() async {
    final s = await _isar.sessionIsarModels.get(1);
    return s?.accessToken;
  }

  Future<void> saveUser(UserEntity user) async {
    await _isar.writeTxn(() async {
      final cur = await _isar.sessionIsarModels.get(1);
      final s = cur ?? (SessionIsarModel()..id = 1);
      s.userJson = jsonEncode({
        'id': user.id,
        'name': user.name,
        'role': user.role == UserRole.admin ? 'ADMIN' : 'SELLER',
      });
      await _isar.sessionIsarModels.put(s);
    });
  }

  Future<UserEntity?> getUser() async {
    final s = await _isar.sessionIsarModels.get(1);
    final raw = s?.userJson;
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserEntity(
        id: map['id'] as String,
        name: map['name'] as String,
        role: (map['role'] == 'ADMIN') ? UserRole.admin : UserRole.seller,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.sessionIsarModels.delete(1);
    });
  }
}
