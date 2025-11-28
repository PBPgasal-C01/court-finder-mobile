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

  final url = Uri.parse("http://127.0.0.1:8000/auth/register-flutter/"); 

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
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // DESAIN MENGIKUTI CONTOH KAMU
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),

              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30.0),

                    // ================= EMAIL ==================
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Email required";
                        if (!v.contains("@")) return "Invalid email";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),

                    // ================= USERNAME ==================
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        hintText: 'Enter your display name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // ================= PREFERENCE ==================
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Preference',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                      ),
                      value: _preference,
                      items: const [
                        DropdownMenuItem(
                            value: "Outdoor", child: Text("Outdoor")),
                        DropdownMenuItem(
                            value: "Indoor", child: Text("Indoor")),
                        DropdownMenuItem(
                            value: "Both", child: Text("Indoor & Outdoor")),
                      ],
                      onChanged: (v) => setState(() => _preference = v!),
                    ),
                    const SizedBox(height: 12.0),

                    // ================= PHOTO ==================
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: pickImage,
                          child: const Text("Choose Photo"),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedImage == null
                                ? "No file chosen"
                                : _selectedImage!.path.split("/").last,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),

                    // ================= PASSWORD ==================
                    TextFormField(
                      controller: _password1Controller,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Password required";
                        if (v.length < 8) return "Min 8 chars";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),

                    // ================= CONFIRM PASSWORD ==================
                    TextFormField(
                      controller: _password2Controller,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Confirm password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                      ),
                      validator: (v) {
                        if (v != _password1Controller.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),

                    // ================= BUTTON ==================
                    ElevatedButton(
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
