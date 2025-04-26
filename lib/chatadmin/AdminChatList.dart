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
            color: Colors.teal[50],
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
            color: Colors.teal[50],
          ),
        ),
        backgroundColor: Colors.teal[800],
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal[100], // لون الخلفية
          borderRadius: BorderRadius.circular(10), // زوايا مدورة
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(1, 1), // ظل خفيف
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                chat.unreadCount > 0 ? Colors.red : Colors.teal[800],
            child:
                chat.unreadCount > 0
                    ? Text(
                      chat.unreadCount.toString(),
                      style: TextStyle(color: Colors.teal[50], fontSize: 15),
                    )
                    : Text(
                      chat.userName[0],
                      style: TextStyle(color: Colors.teal[50], fontSize: 15),
                    ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  chat.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.teal[900],
                  ),
                ),
              ),
              
              Padding(
                padding: EdgeInsets.only(left: 70),
                child: Flexible(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                       var response = await _crud.postRequest(linkDeleteChat, {
                        "id": chat.id.toString(),
                      });
                      if (response['status'] == "success") {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => AdminChatList()),
                        );
                      } 
                    },
                    icon: const Icon(Icons.delete, size: 14, color: Colors.white),
                    label: const Text(
                      'حذف',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      backgroundColor: Colors.red.shade400,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
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
              MaterialPageRoute(
                builder: (context) => AdminChatScreen(chat: chat),
              ),
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
        ),
      ),
    );
  }
}
