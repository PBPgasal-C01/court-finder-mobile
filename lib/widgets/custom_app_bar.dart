import 'package:flutter/material.dart';
import '../models/user_entry.dart';
import '../screens/user_profile.dart';

class CustomTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final UserEntry user;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomTopAppBar({
    super.key,
    required this.title,
    required this.user,
    required this.scaffoldKey,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      centerTitle: false,

      // LENGKUNGAN HIJAU
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF6B8E72), // Warna Hijau Tema
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
      ),

      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 10),
        child: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
          tooltip: 'Menu',
        ),
      ),

      title: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0, top: 10),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage(user: user)),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: ClipOval(
                  child: user.photo != null
                      ? Image.network(
                    user.photo!,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.person, color: Colors.white, size: 20),
                  )
                      : const Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}