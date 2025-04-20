import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../crud.dart';
import '../linkapi.dart';
import 'AdminChatScreen.dart';
import 'Chat.dart';

class AdminChatList extends StatefulWidget {
  const AdminChatList({super.key});

  @override
  _AdminChatListState createState() => _AdminChatListState();
}

class _AdminChatListState extends State<AdminChatList> {
  List<Chat> _chats = [];
  bool _isLoading = true;
  final Crud _crud = Crud();

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final response = await _crud.postRequest(linkGetAdminChats, {});

      setState(() {
        _chats =
            (response['chats'] as List)
                .map((chat) => Chat.fromJson(chat))
                .toList()
              // ترتيب المحادثات بحيث تكون التي بها رسائل غير مقروءة في الأعلى
              ..sort((a, b) => b.unreadCount.compareTo(a.unreadCount));
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading chats: $e');
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
          "المحادثات الواردة",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(157, 42, 202, 181),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _chats.length,
                itemBuilder: (context, index) => _buildChatItem(_chats[index]),
              ),
    );
  }

  Widget _buildChatItem(Chat chat) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color.fromARGB(157, 42, 202, 181),
        child: Text(chat.userName[0], style: TextStyle(color: Colors.black)),
      ),
      title: Row(
        children: [
          Expanded(child: Text(chat.userName)),
          if (chat.unreadCount > 0)
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      subtitle: Text(
        chat.lastMessage ?? '',
        style: TextStyle(
          fontWeight:
              chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Text(DateFormat('HH:mm').format(chat.lastMessageAt)),
      onTap: () async {
        final updatedChat = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminChatScreen(chat: chat)),
        );

        if (updatedChat != null) {
          setState(() {
            final index = _chats.indexWhere((c) => c.id == updatedChat.id);
            if (index != -1) {
              _chats[index] = updatedChat;
            }
          });
        }
      },
    );
  }
}
