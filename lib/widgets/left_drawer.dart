import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '/models/user_entry.dart';
import '/screens/login.dart';
import '/screens/user_profile.dart';
import '/screens/admin_dashboard.dart';
import 'package:court_finder_mobile/main.dart';
import 'package:court_finder_mobile/screens/game_scheduler/game_scheduler_page.dart';
import 'package:court_finder_mobile/screens/complain/menu_complaint.dart'; // Untuk User Biasa
import 'package:court_finder_mobile/screens/complain/menu_admin_complaint.dart'; // Untuk Admin
import '/screens/welcome_screen.dart';

class LeftDrawer extends StatelessWidget {
  final UserEntry user;
  const LeftDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    const green = Color(0xFF3F6E48);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF6B8E72),
                    child: user.photo != null
                        ? ClipOval(
                            child: Image.network(
                              user.photo!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.white,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.white,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            const Divider(),

            // ================= MENU ITEMS =================
            _drawerItem(
              icon: Icons.person_outline,
              label: "Profile",
              onTap: () {
                Navigator.pop(context);
                // Navigate to Profile Page (remove `const` because `user` is runtime)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfilePage(user: user)),
                );
              },
            ),

            _drawerItem(
              icon: Icons.article_outlined,
              label: "Blog",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainPage(
                      user: user,
                      initialIndex: 4, // 4 = Blog
                    ),
                  ),
                );
              },
            ),

            _drawerItem(
              icon: Icons.location_on_outlined,
              label: "Finder",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainPage(
                      user: user,
                      initialIndex: 3, // 3 = Court Finder
                    ),
                  ),
                );
              },
            ),

            _drawerItem(
              icon: Icons.edit_outlined,
              label: "Manage",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainPage(
                      user: user,
                      initialIndex: 1, // 1 = Manage Court
                    ),
                  ),
                );
              },
            ),

            _drawerItem(
              icon: Icons.event_outlined,
              label: "Event",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainPage(
                      user: user,
                      initialIndex: 2, // 2 = Event tab
                    ),
                  ),
                );
              },
            ),

            _drawerItem(
              icon: Icons.warning_amber_rounded, // Icon yang cocok untuk report
              label: "Report",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainPage(
                      user: user,
                      initialIndex: 5, // 5 = Report/Complaint
                    ),
                  ),
                );
              },
            ),

            // ======== ADMIN ONLY: MANAGE USERS =========
            if (user.isSuperuser)
              _drawerItem(
                icon: Icons.admin_panel_settings_outlined,
                label: "Manage Users",
                onTap: () {
                  // TODO: Navigate to Admin Manage Users Page
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminDashboardPage()),
                  );
                },
              ),

            const Spacer(),

            // ================= LOGOUT =================
            _drawerItem(
              icon: Icons.logout,
              label: "Logout",
              onTap: () async {
                await request.logout(
                  "https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/auth/logout-flutter/",
                );
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    const green = Color(0xFF3F6E48);

    return ListTile(
      leading: Icon(icon, color: green),
      title: Text(label, style: const TextStyle(color: green, fontSize: 16)),
      onTap: onTap,
    );
  }
}
