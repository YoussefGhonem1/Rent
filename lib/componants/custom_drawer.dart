// lib/componants/custom_drawer.dart

import 'package:flutter/material.dart';
import 'package:rento/admin/approve_screen.dart';
import 'package:rento/admin/control_admin.dart';
import 'package:rento/admin/home_admin.dart';
import 'package:rento/admin/order_admin_screen.dart';
import 'package:rento/chatadmin/AdminChatList.dart'; // لو هتستخدمها للأدمن
import 'package:rento/chat/chat_screen.dart'; // لو هتستخدمها للمستخدم العادي
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart'; // عشان sharedPref
import 'package:rento/owner/home_owner.dart';
import 'package:rento/owner/owner_orders_screen.dart';
import 'package:rento/owner/ownerrealstates.dart';
import 'package:rento/renter/favorites.dart';
import 'package:rento/renter/renter_orders_screen.dart';
import 'package:url_launcher/url_launcher.dart'; // عشان فتح رقم التليفون
import '../auth/login.dart';
import '../crud.dart';

class CustomDrawer extends StatelessWidget {
  // ✅ Crud object لازم يتم تمريره
  final Crud crud;
  // ✅ userType لازم يتم تمريره عشان الـ Drawer يبني نفسه صح
  final String userType;

  const CustomDrawer({super.key, required this.crud, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.teal[900],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white, width: 0.3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: Image.asset("images/Capture.PNG", fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  sharedPref.getString("username").toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.teal.shade50,
                  ),
                ),
              ],
            ),

            // Menu Items
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(
                    context,
                    title: "الصفحه الرئيسية",
                    icon: Icons.home,
                    onTap: () {
                      // بناءً على نوع المستخدم، يروح للصفحة الرئيسية بتاعته
                      if (userType == "admin") {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeAdmin(),
                          ),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeOwner(),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),

                  // صفحة الحساب
                  _buildDrawerItem(
                    context,
                    title: "حساب",
                    icon: Icons.account_circle,
                    onTap: () {
                      if (userType == "owner") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OwnerRealstate(),
                          ),
                        );
                      } else if (userType == "admin") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ControlAdmin(),
                          ),
                        );
                      }
                      // لو renter ممكن ميكنش ليها صفحة حساب منفصلة
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),

                  // صفحة الطلبات
                  _buildDrawerItem(
                    context,
                    title: "الطلبات",
                    icon: Icons.list_alt,
                    onTap: () {
                      if (userType == "admin") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderAdminScreen(),
                          ),
                        );
                      } else if (userType == "owner") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OwnerOrdersScreen(),
                          ),
                        );
                      } else {
                        // renter
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RenterOrdersScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),

                  // صفحة المفضلة
                  _buildDrawerItem(
                    context,
                    title: "المفضلة",
                    icon: Icons.favorite,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Favorite(),
                        ),
                      );
                    },
                  ),
                  // شرط عرض "طلبات التأكيد" للأدمن فقط
                  if (userType == "admin") ...[
                    // ✅ استخدام spread operator لتضمين عناصر مشروطة
                    const Divider(color: Colors.white54, height: 10),
                    _buildDrawerItem(
                      context,
                      title: "طلبات التاكيد",
                      icon: Icons.approval,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Approve(),
                          ),
                        );
                      },
                    ),
                  ],
                  const Divider(color: Colors.white54, height: 10),

                  // تواصل معنا
                  _buildDrawerItem(
                    context,
                    title: "تواصل معنا",
                    icon: Icons.contact_support,
                    onTap: () async {
                      try {
                        // استخدام الـ crud object الممرر
                        var response = await crud.postRequest(linkCreateChat, {
                          "user_id": sharedPref.getString("id").toString(),
                        });

                        if (response['status'] == "success" &&
                            response.containsKey('chat_id')) {
                          // توجيه لصفحة الشات الخاصة بالأدمن لو المستخدم أدمن
                          if (userType == "admin") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminChatList(),
                              ),
                            );
                          } else {
                            // للمالك والمستأجر
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatScreen(
                                      chatId: int.parse(
                                        response['chat_id'].toString(),
                                      ),
                                      userId: int.parse(
                                        sharedPref.getString("id")!,
                                      ),
                                    ),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                response['message'] ?? "فشل إنشاء المحادثة",
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("حدث خطأ: ${e.toString()}")),
                        );
                      }
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),

                  // ✅ جديد: رقم التواصل للشركة
                  _buildDrawerItem(
                    context,
                    title: "تواصل مع الشركة",
                    icon: Icons.phone,
                    onTap: () async {
                      const phoneNumber = '01014395851'; // رقم الهاتف المطلوب
                      final url = 'tel:$phoneNumber';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('لا يمكن الاتصال بالرقم المحدد.'),
                          ),
                        );
                      }
                    },
                  ),
                  if (userType != "admin") ...[const SizedBox(height: 60)],
                  const SizedBox(
                    height: 120,
                  ), // أو SpaceAround لو حبيت المسافات تتوزع

                  _buildDrawerItem(
                    context,
                    title: "تسجيل الخروج",
                    icon: Icons.logout,
                    onTap: () async {
                      // ✅ جعلها async عشان FCM Token

                      sharedPref.clear();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      title: Text(
        title,
        style: TextStyle(fontSize: 18, color: Colors.teal.shade50),
      ),
      leading: Icon(icon, color: Colors.teal.shade50, size: 26),
      minLeadingWidth: 30,
      onTap: onTap,
    );
  }
}
