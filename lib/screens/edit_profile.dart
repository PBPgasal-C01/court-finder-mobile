import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/user_entry.dart';
import 'user_profile.dart';

class EditProfilePage extends StatefulWidget {
  final UserEntry user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  String _preference = "Both";

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _preference = widget.user.preference;
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF3F6E48);
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Edit Profile"), backgroundColor: green),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ===================== USERNAME =====================
              TextFormField(
                controller: _usernameController,
                decoration: _fieldStyle("Display Name"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Name required" : null,
              ),
              const SizedBox(height: 20),

              // ===================== EMAIL =====================
              TextFormField(
                controller: _emailController,
                decoration: _fieldStyle("Email"),
                validator: (v) =>
                    v == null || !v.contains("@") ? "Invalid email" : null,
              ),
              const SizedBox(height: 20),

              // ===================== PREFERENCE =====================
              DropdownButtonFormField<String>(
                decoration: _fieldStyle("Court Preference"),
                value: _preference,
                items: const [
                  DropdownMenuItem(value: "Outdoor", child: Text("Outdoor")),
                  DropdownMenuItem(value: "Indoor", child: Text("Indoor")),
                  DropdownMenuItem(value: "Both", child: Text("Both")),
                ],
                onChanged: (v) => setState(() => _preference = v!),
              ),
              const SizedBox(height: 30),

              // ================= SAVE BUTTON ==================
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final response = await request.postJson(
                    "https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/auth/edit-profile/",
                    jsonEncode({
                      "username": _usernameController.text.trim(),
                      "email": _emailController.text.trim(),
                      "preference": _preference,
                    }),
                  );

                  if (!mounted) return;

                  if (response["status"] == "success") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile updated!")),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(
                          user: UserEntry(
                            email: _emailController.text.trim(),
                            username: _usernameController.text.trim(),
                            preference: _preference,
                            photo: widget.user.photo,
                            isSuperuser: widget.user.isSuperuser,
                            isStaff: widget.user.isStaff,
                            role: widget.user.role,
                          ),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 30,
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldStyle(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }
}
