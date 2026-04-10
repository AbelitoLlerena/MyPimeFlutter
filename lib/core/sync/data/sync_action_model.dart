import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:mypime/core/sync/domain/sync_action.dart';

part 'sync_action_model.g.dart';

@collection
class SyncActionModel {
  Id id = Isar.autoIncrement;

  late String entityId;
  late String actionType;
  late String payloadJson;
  late DateTime createdAt;

  static SyncActionModel fromAction(SyncAction action) {
    return SyncActionModel()
      ..entityId = action.id
      ..actionType = action.type
      ..payloadJson = jsonEncode(action.payload)
      ..createdAt = action.createdAt;
  }
}
