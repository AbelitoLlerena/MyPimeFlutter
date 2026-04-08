import '../../domain/entities/user_entity.dart';
import '../../domain/enums/user_role_enum.dart';

class UserModel {
  final String id;
  final String name;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      role: role == 'ADMIN'
          ? UserRole.admin
          : UserRole.seller,
    );
  }
}