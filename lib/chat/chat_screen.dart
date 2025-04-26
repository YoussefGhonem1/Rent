// screens/chat_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../crud.dart';
import '../linkapi.dart';
import '../main.dart';
import 'chat_service.dart';
import 'message_model.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;
  final int userId;

  const ChatScreen({super.key, required this.chatId, required this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();

  final Crud _crud = Crud();

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // يمكنك إضافة WebSocket هنا للتحديث الفوري
    // في initState
    Timer.periodic(Duration(seconds: 2), (timer) {
      _loadMessages(); // جلب الرسائل كل 5 ثواني
    });
    // أضف هذا في initState
    _messageController.addListener(() {
      setState(() {}); // يُحدث الواجهة عند كل تغيير في النص
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadMessages() async {
    final messages = await ChatService.getMessages(
      widget.chatId,
      widget.userId,
    );
    setState(() => _messages = messages);
    _scrollToBottom();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    // 1. احفظ النص المؤقت
    final messageText = _messageController.text;

    // 2. امسح الحقل فورًا
    _messageController.clear(); // هذه السطر يفرغ حقل الإدخال
    setState(() {}); // يُحدث الواجهة فورًا

    try {
      // 3. أضف الرسالة إلى القائمة
      setState(() {
        _messages.add(
          Message(
            id: DateTime.now().millisecondsSinceEpoch,
            content: messageText,
            timestamp: DateTime.now(),
            isRead: false,
            isSentByMe: true,
          ),
        );
      });

      // 4. أرسل إلى السيرفر
      await _sendMessageToServer(chatId: widget.chatId, message: messageText);
    } catch (e) {
      // إذا فشل الإرسال، أعد النص إلى الحقل
      _messageController.text = messageText;
      setState(() {});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل الإرسال: ${e.toString()}')));
    }
  }

  Future<void> _sendMessageToServer({
    required int chatId,
    required String message,
  }) async {
    final response = await _crud.postRequest(linkSendMessage, {
      'chat_id': chatId.toString(),
      'sender_id': widget.userId.toString(),
      'sender_type': sharedPref.getString("type").toString(),
      'message': message,
    });

    if (response['status'] != 'success') {
      throw Exception('Failed to send message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // أو أيقونة تانية تعجبك
          onPressed: () {
            Navigator.pop(context); // الرجوع للصفحة السابقة
          },
        ),
        title: Text(
          "الدعم الفني",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal[800],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment:
          message.isSentByMe == false
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              message.isSentByMe == false
                  ? Colors.teal[100]
                  : Colors.teal[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [Text(message.content , style: TextStyle(
                  color: message.isSentByMe == false
                  ? Colors.teal[900]
                  : Colors.teal[100],
                  fontSize: 15,
                    fontWeight: FontWeight.bold,

                ),),SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(message.timestamp),
                style: TextStyle(
                  color: message.isSentByMe == false
                  ? Colors.teal[900]
                  : Colors.teal[100],
                  fontSize: 12,
                ),
              ),]),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك...',
                border: OutlineInputBorder(),
                // إضافة هذا لإفراغ الحقل عند الإرسال
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ),
              onSubmitted: (_) => _sendMessage(), // للإرسال عند الضغط على Enter
            ),
          ),
        ],
      ),
    );
  }
}
