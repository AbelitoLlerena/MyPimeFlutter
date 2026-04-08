abstract class SyncHandler {
  String get type;
  Future<void> handle(Map<String, dynamic> payload);
}