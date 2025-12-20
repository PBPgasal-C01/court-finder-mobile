import 'package:court_finder_mobile/screens/menu.dart';
import 'package:flutter/material.dart';
import '../models/user_entry.dart';
import 'edit_profile.dart';

class ProfilePage extends StatelessWidget {
  final UserEntry user;

  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF6CA06E);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ================= BACKGROUND PNG (TOP ONLY) =================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/register_login_bg.png",
              height: 330,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),

          // ================= BACK BUTTON =================
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pushReplacement(
                            context, 
                            MaterialPageRoute(
                                builder: (_) => MyHomePage(
                                  user: user
                                ),
                              ),
                            ),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.white.withOpacity(0.65),
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF3F414E)),
              ),
            ),
          ),

          // ================= MAIN CONTENT =================
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // TITLE
                const Text(
                  "PROFILE",
                  style: TextStyle(
                    fontSize: 22,
                    color: green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // PROFILE PICTURE WITH EDIT BUTTON
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: user.photo != null && user.photo!.isNotEmpty
                          ? NetworkImage(user.photo!)
                          : const AssetImage("assets/default.png") as ImageProvider,
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfilePage(user: user),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                _infoTile(
                  icon: Icons.person,
                  label: "NAME",
                  value: user.username,
                ),
                _infoTile(
                  icon: Icons.email,
                  label: "EMAIL",
                  value: user.email,
                ),
                _infoTile(
                  icon: Icons.my_location,
                  label: "COURT PREFERENCE",
                  value: user.preference,
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    const green = Color(0xFF3F6E48);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: green, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
