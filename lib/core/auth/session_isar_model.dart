import 'package:isar/isar.dart';

part 'session_isar_model.g.dart';

/// Una sola fila (`id == 1`) con token y usuario serializado (sesión local).
@collection
class SessionIsarModel {
  Id id = 1;

  String? accessToken;
  String? userJson;
}
