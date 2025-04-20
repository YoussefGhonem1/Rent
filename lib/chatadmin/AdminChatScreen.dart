import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rento/chat/chat_service.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import '../chat/message_model.dart';
import '../crud.dart';
import 'Chat.dart';


class AdminChatScreen extends StatefulWidget {
  final Chat chat;

  const AdminChatScreen({super.key, required this.chat});

  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  final Crud _crud = Crud();
  late StreamSubscription _messageSubscription;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupMessageListener();
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    super.dispose();
  }

  void _setupMessageListener() {
    // استبدل هذا بآلية الاستماع الفعلية التي تستخدمها
    // يمكنك استخدام StreamController أو أي وسيلة أخرى
    _messageSubscription = Stream.periodic(Duration(seconds: 2)).listen((_) {
      _loadMessages();
    });
  }

  Future<void> _loadMessages() async {
  try {
    final response = await _crud.postRequest(linkGetMessage, {
      'chat_id': widget.chat.id.toString(),
    });

    setState(() {
      _messages = (response['messages'] as List)
          .map((msg) => Message(
                id: msg['id'],
                content: msg['message'],
                timestamp: DateTime.parse(msg['created_at']),
                isRead: msg['is_read'] == 1 || msg['is_read'] == true,
                isSentByMe: msg['sender_type'] == 'admin', // تغيير هنا
              ))
          .toList();
    });
    _scrollToBottom();
    _markAsRead();
  } catch (e) {
    print('Error loading messages: $e');
  }
}

  void _markAsRead() async {
  try {
    final response = await _crud.postRequest(linkMarkAsRead, {
      'chat_id': widget.chat.id.toString(),
      'admin_id': sharedPref.getString("id")!,
    });
    
    if (response['status'] == 'success') {
      // تحديث حالة الرسائل محلياً
      setState(() {
        for (var msg in _messages) {
          msg.isRead = true;
        }
      });
    }
  } catch (e) {
    print('Error marking as read: $e');
  }
}
  Future<void> _sendMessage() async {
  if (_messageController.text.trim().isEmpty) return;

  final message = _messageController.text;
  _messageController.clear();

  setState(() {
    _messages.add(Message(
      id: DateTime.now().millisecondsSinceEpoch,
      content: message,
      timestamp: DateTime.now(),
      isRead: true,
      isSentByMe: true,
    ));
  });

  try {
    await ChatService.sendMessage(
      chatId: widget.chat.id,
      senderId: int.parse(sharedPref.getString("id")!),
      message: message,
      isAdmin: true,
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to send message: $e')),
    );
    setState(() {
      _messages.removeLast();
      _messageController.text = message;
    });
  }

  _scrollToBottom();
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

  void _showUserInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${widget.chat.userName}'),
            Text('User ID: ${widget.chat.userId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Message message) {
  final isMe = message.isSentByMe;
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    child: Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Color.fromARGB(157, 42, 202, 181) : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(message.timestamp),
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
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
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
       onWillPop: () async {
        _loadMessages();
      Navigator.pop(context, widget.chat.copyWith(unreadCount: 0));
      return false;
    },
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
    icon: Icon(Icons.arrow_back , color: Colors.white), // أو أيقونة تانية تعجبك
    onPressed: () {
      Navigator.pop(context); // الرجوع للصفحة السابقة
    },
  ),
          title: Text(widget.chat.userName  , style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ), ),
          backgroundColor:Color.fromARGB(157, 37, 184, 164),
          actions: [
            IconButton(
              icon: Icon(Icons.info , color: Colors.white,),
              onPressed: _showUserInfo,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (ctx, index) => _buildMessage(_messages[index]),
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }
}