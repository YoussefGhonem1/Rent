// services/chat_service.dart
import 'package:rento/main.dart';

import '../crud.dart';
import '../linkapi.dart';
import 'message_model.dart';

Crud _crud = Crud();

class ChatService {

static Future<List<Message>> getMessages(int chatId, int userId) async {
  try {
    var response = await _crud.postRequest(linkGetMessage, {
      'chat_id': chatId.toString(),
      'admin_id': userId.toString() // تغيير من user_id إلى admin_id
    });

    if (response['status'] == "success") {
      return (response['messages'] as List)
          .map((msg) => Message(
                id: msg['id'],
                content: msg['message'],
                timestamp: DateTime.parse(msg['created_at']),
                isRead: msg['is_read'] == 1 || msg['is_read'] == true,
                isSentByMe: msg['sender_type'] == 'admin', // تغيير هنا
              ))
          .toList();
    }
    return [];
  } catch (e) {
    print('Error fetching messages: $e');
    return [];
  }
}
  static Future<bool> sendMessage({
    required int chatId,
    required int senderId,
    required String message,
    required bool isAdmin,
  }) async {
    try {
    var response = await _crud.postRequest(linkSendMessage, {
      'chat_id': chatId.toString(),
      'sender_id': senderId.toString(),
      'sender_type': isAdmin ?'admin' : '${sharedPref.getString("type")}',
      'message': message,
    });
    return response['status'] == 'success'; // تغيير هنا
  } catch (e) {
    print('Error sending message: $e');
    return false;
  }
  }
}
