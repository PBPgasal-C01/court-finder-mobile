import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _password1Controller = TextEditingController();
  final _password2Controller = TextEditingController();

  File? _selectedImage;
  String _preference = "Both";

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> registerUser() async {
  print("REGISTER BUTTON PRESSED");

  bool valid = _formKey.currentState!.validate();
  print("FORM VALID? $valid");

  if (!valid) {
    setState(() {});   // <-- IMPORTANT: forces error messages to appear
    print("FORM INVALID - STOP");
    return;
  }

  print("FORM IS VALID - CONTINUING");

  // "https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/auth/register-flutter/"

  final url = Uri.parse("https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/auth/register-flutter/"); 

  print("SENDING MULTIPART REQUEST...");

  var request = http.MultipartRequest("POST", url);
  request.fields['email'] = _emailController.text.trim();
  request.fields['username'] = _usernameController.text.trim();
  request.fields['preference'] = _preference;
  request.fields['password1'] = _password1Controller.text.trim();
  request.fields['password2'] = _password2Controller.text.trim();

  if (_selectedImage != null) {
    print("ATTACHING IMAGE: ${_selectedImage!.path}");
    request.files.add(await http.MultipartFile.fromPath(
      "photo",
      _selectedImage!.path,
    ));
  } else {
    print("NO IMAGE SELECTED");
  }

  print("AWAITING RESPONSE...");
  var response = await request.send();

  print("RESPONSE RECEIVED: status=${response.statusCode}");

  var body = await response.stream.bytesToString();
  print("RAW BODY: $body");

  var data = jsonDecode(body);
  print("DECODED DATA:");
  print(data);

  if (!mounted) return;

  if (data["status"] == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data["message"] ?? "Successfully registered!")),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data["message"] ?? "Failed to register")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ===================== BACKGROUND GREEN SHAPES =====================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/register_login_bg.png",
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),

          // ========================== MAIN CONTENT ===========================
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // BACK BUTTON
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFEBEAEC)),
                          borderRadius: BorderRadius.circular(38),
                        ),
                        child: const Center(
                          child: Icon(Icons.arrow_back, color: Color(0xFF3F414E)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // TITLE
                  Text(
                    "CREATE YOUR ACCOUNT",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3F5940),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // GOOGLE SIGNUP BUTTON
                  GestureDetector(
                    onTap: () {
                      // OPTIONAL: Integrate Google register if needed
                    },
                    child: Container(
                      width: double.infinity,
                      height: 63,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFEBEAEC)),
                        borderRadius: BorderRadius.circular(38),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/google_logo.png",
                            width: 22,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "CONTINUE WITH GOOGLE",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF3F414E),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // OR
                  const Text(
                    "OR LOG IN WITH EMAIL",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFA1A4B2),
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ===================== FORM START =====================
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // NAME
                        buildInputBox(
                          controller: _usernameController,
                          hint: "Display Name",
                          validator: null,
                        ),

                        const SizedBox(height: 20),

                        // EMAIL
                        buildInputBox(
                          controller: _emailController,
                          hint: "Email address",
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Email required";
                            if (!v.contains("@")) return "Invalid email";
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // PASSWORD
                        buildPasswordBox(_password1Controller),

                        const SizedBox(height: 20),

                        // CONFIRM PASSWORD
                        buildPasswordBox(_password2Controller,
                            label: "Confirm Password",
                            validator: (v) {
                              if (v != _password1Controller.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            }),

                        const SizedBox(height: 20),

                        // PREFERENCE DROPDOWN
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
                              items: const [
                                DropdownMenuItem(
                                    value: "Outdoor", child: Text("Outdoor")),
                                DropdownMenuItem(
                                    value: "Indoor", child: Text("Indoor")),
                                DropdownMenuItem(
                                    value: "Both", child: Text("Indoor & Outdoor")),
                              ],
                              onChanged: (v) =>
                                  setState(() => _preference = v!),
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFA1A4B2),
                              ),
                              icon: const Icon(Icons.expand_more),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // PHOTO UPLOAD
                        GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 63,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Color(0xFFF2F3F7),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.photo_camera_back, color: Color(0xFF3F414E)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedImage == null
                                        ? "Choose Photo"
                                        : _selectedImage!.path.split("/").last,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _selectedImage == null
                                          ? Color(0xFFA1A4B2)
                                          : Color(0xFF3F414E),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // PRIVACY POLICY CHECK
                        Row(
                          children: [
                            Checkbox(
                              value: true,
                              activeColor: Color(0xFF547254),
                              onChanged: (v) {},
                            ),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  text: "I have read the ",
                                  style: TextStyle(
                                    color: Color(0xFFA1A4B2),
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Privacy Policy",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // REGISTER BUTTON
                        GestureDetector(
                          onTap: registerUser,
                          child: Container(
                            width: double.infinity,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Color(0xFFF6FAF6),
                              borderRadius: BorderRadius.circular(54),
                              border: Border.all(
                                  color: Color(0xFF547254), width: 1.8),
                            ),
                            child: const Center(
                              child: Text(
                                "LOG IN",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF547254),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildInputBox({
  required TextEditingController controller,
  required String hint,
  String? Function(String?)? validator,
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
          hintStyle: TextStyle(
            color: Color(0xFFA1A4B2),
            letterSpacing: 0.5,
            fontSize: 16,
          ),
          border: InputBorder.none,
        ),
      ),
    ),
  );
}

Widget buildPasswordBox(
  TextEditingController controller, {
  String label = "Password",
  String? Function(String?)? validator,
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
        obscureText: true,
        validator: validator,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            color: Color(0xFFA1A4B2),
            fontSize: 16,
          ),
          border: InputBorder.none,
        ),
      ),
    ),
  );
}

