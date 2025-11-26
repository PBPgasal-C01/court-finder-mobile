import 'package:flutter/material.dart';
import '../models/user_entry.dart';
import 'edit_profile.dart';

class ProfilePage extends StatelessWidget {
  final UserEntry user;

  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF3F6E48);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 60),

          // ================= HEADER TITLE =================
          const Text(
            "PROFILE",
            style: TextStyle(
              fontSize: 22,
              color: green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // ================= PROFILE IMAGE =================
          Stack(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: const Color(0xFF6B8E72),
                child: user.photo != null
                    ? ClipOval(
                        child: Image.network(
                          user.photo!,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 55,
                              color: Colors.white,
                            );
                          },
                        ),
                      )
                    : const Icon(Icons.person, size: 55, color: Colors.white),
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
                      shape: BoxShape.circle,
                      color: green,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // ================= USER INFO LIST =================
          _infoTile(icon: Icons.person, label: "NAME", value: user.username),
          _infoTile(icon: Icons.email, label: "EMAIL", value: user.email),
          _infoTile(
            icon: Icons.phone,
            label: "PHONE NO",
            value: "+62 80000000", // Replace if phone is added later
          ),
          _infoTile(
            icon: Icons.my_location,
            label: "COURT PREFERENCE",
            value: user.preference,
          ),

          const Spacer(),
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
          ),
        ],
      ),
    );
  }
}
