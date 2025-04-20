class Chat {
  final int id;
  final int userId;
  final String userName;
  final String? lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  Chat({
    required this.id,
    required this.userId,
    required this.userName,
    this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      lastMessage: json['last_message'],
      lastMessageAt: DateTime.parse(json['last_message_at']),
      unreadCount: json['unread_count'] ?? 0,
    );
  }
  Chat copyWith({
  int? id,
  int? userId,
  String? userName,
  String? lastMessage,
  DateTime? lastMessageAt,
  int? unreadCount,
}) {
  return Chat(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    userName: userName ?? this.userName,
    lastMessage: lastMessage ?? this.lastMessage,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    unreadCount: unreadCount ?? this.unreadCount,
  );
}
}