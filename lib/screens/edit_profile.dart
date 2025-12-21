import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
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

  File? _newPhoto;
  String _preference = "Both";

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _preference = widget.user.preference;
  }

  Future<void> pickNewPhoto() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newPhoto = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF6CA06E);
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
         title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: green,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // === PROFILE PICTURE PREVIEW ===
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _newPhoto != null
                          ? FileImage(_newPhoto!)
                          : (widget.user.photo != ""
                              ? NetworkImage(widget.user.photo ?? "")
                              : null) as ImageProvider?,
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: pickNewPhoto,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Color(0xFFF2F3F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.photo_camera, size: 20),
                            SizedBox(width: 8),
                            Text("Choose New Photo",
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ===================== USERNAME =====================
              _styledField(
                controller: _usernameController,
                hint: "Display Name",
                validator: (v) =>
                    v == null || v.isEmpty ? "Name required" : null,
              ),
              const SizedBox(height: 20),

              // ===================== EMAIL =====================
              _styledField(
                controller: _emailController,
                hint: "Email",
                validator: (v) =>
                    v == null || !v.contains("@") ? "Invalid email" : null,
              ),
              const SizedBox(height: 20),

              // ===================== PREFERENCE =====================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                height: 63,
                decoration: BoxDecoration(
                  color: Color(0xFFF2F3F7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _preference,
                    style: const TextStyle(
                        color: Color(0xFF3F414E), fontSize: 16),
                    items: const [
                      DropdownMenuItem(value: "Outdoor", child: Text("Outdoor")),
                      DropdownMenuItem(value: "Indoor", child: Text("Indoor")),
                      DropdownMenuItem(value: "Both", child: Text("Indoor & Outdoor")),
                    ],
                    onChanged: (v) {
                      setState(() => _preference = v!);
                    },
                    icon: const Icon(Icons.expand_more),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ===================== SAVE BUTTON ==================
              GestureDetector(
                onTap: () async {
                  if (!_formKey.currentState!.validate()) return;

                  // --- MULTIPART UPDATE ---
                  var url = Uri.parse(
                      "https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/auth/edit-profile/");
                  var req = http.MultipartRequest("POST", url);

                  req.headers.addAll(request.headers);

                  req.fields["username"] = _usernameController.text.trim();
                  req.fields["email"] = _emailController.text.trim();
                  req.fields["preference"] = _preference;

                  if (_newPhoto != null) {
                    req.files.add(await http.MultipartFile.fromPath(
                        "photo", _newPhoto!.path));
                  }

                  var res = await req.send();
                  var body = await res.stream.bytesToString();
                  var data = jsonDecode(body);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data["message"])));

                  final userData = await request.get("https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/auth/user-flutter/");
                  UserEntry user = UserEntry.fromJson(userData);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(user: user),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Color(0xFFF6FAF6),
                    borderRadius: BorderRadius.circular(54),
                    border: Border.all(color: green, width: 1.8),
                  ),
                  child: const Center(
                    child: Text(
                      "SAVE CHANGES",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3F6E48),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom styled input fields
  Widget _styledField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return Container(
      width: double.infinity,
      height: 63,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Color(0xFFF2F3F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            hintStyle: const TextStyle(
              color: Color(0xFFA1A4B2),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
