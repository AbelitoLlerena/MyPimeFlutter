class SyncAction {
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  SyncAction({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
  });
}