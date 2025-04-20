// models/message_model.dart
class Message {
  final int id;
  final String content;
  final DateTime timestamp;
  late final bool isRead;
  final bool isSentByMe;

  Message({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.isSentByMe,
  });
}