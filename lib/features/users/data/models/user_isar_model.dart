import 'package:isar/isar.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/enums/user_role_enum.dart';

part 'user_isar_model.g.dart';

@collection
class UserIsarModel {
  Id get isarId => id.hashCode; // clave primaria en Isar
  late String id;
  late String name;
  late String role;

  /// SHA-256 en hex. Vacío = usuario creado por sincronización sin login local.
  late String passwordHash;

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      role: role == 'ADMIN' ? UserRole.admin : UserRole.seller,
    );
  }

  static UserIsarModel fromEntity(UserEntity entity) {
    return UserIsarModel()
      ..id = entity.id
      ..name = entity.name
      ..role = entity.role == UserRole.admin ? 'ADMIN' : 'SELLER'
      ..passwordHash = '';
  }
}
