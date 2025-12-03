import 'package:court_finder_mobile/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:court_finder_mobile/screens/menu.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:court_finder_mobile/models/user_entry.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login', 
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
          .copyWith(secondary: Colors.blueAccent[400]),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigningIn = false;

  Future<void> _handleGoogleLogin(BuildContext context) async {
    final request = context.read<CookieRequest>();
    if (_isSigningIn) return; // prevent double taps
    setState(() {
      _isSigningIn = true;
    });

    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: '297845326726-n5q3f1f29s72j87e34cpft7d8sppivel.apps.googleusercontent.com', // Web/Django
      scopes: ['email', 'profile'],
    );

      // Force chooser by signing out first (this clears any cached account)
      try {
        await googleSignIn.signOut();
        // small delay to ensure sign-out processed on some devices
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        // ignore signOut errors, continue to signIn
        print('Warning: signOut before signIn failed: $e');
      }

      final GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account == null) {
        print("User cancelled Google login");
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      final idToken = auth.idToken;
      print("ID TOKEN = $idToken");

      if (idToken == null) {
        print("Google login failed: no idToken");
        return;
      }

      print("Google ID Token retrieved for ${account.email}. Sending to Django...");

    try {
      final response = await request.post(
        "https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/auth/google-mobile-login/",
        {"id_token": idToken},
      );

      print("Django Response: $response");
      print("Response Type: ${response.runtimeType}");

      if (response is Map && response["status"] == "success") {
        final userJson = await request.get(
          "https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/auth/user-flutter/",
        );

        UserEntry user = UserEntry.fromJson(userJson);

        if (!context.mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MyHomePage(user: user),
          ),
        );
      } else {
        if (!context.mounted) return;
        String errorMsg = "Unknown error";
        if (response is Map) {
          errorMsg = response["error"] ?? response["message"] ?? "Login failed";
        } else {
          errorMsg = "Unexpected response: $response";
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Google Login Failed"),
            content: Text(errorMsg),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("Error during Google login: $e");
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Exception: $e"),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

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
          // ========================= MAIN CONTENT ============================
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

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

                  const SizedBox(height: 20),

                  // WELCOME BACK
                  Text(
                    "WELCOME BACK!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3F414E),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // GOOGLE LOGIN BUTTON 
                  GestureDetector(
                    onTap: () => _handleGoogleLogin(context),
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

                  const SizedBox(height: 25),

                  // OR TEXT
                  const Text(
                    "OR LOG IN WITH EMAIL",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFA1A4B2),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // EMAIL BOX
                  Container(
                    width: double.infinity,
                    height: 63,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFFF2F3F7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: "Email address",
                          hintStyle: TextStyle(
                            color: Color(0xFFA1A4B2),
                            letterSpacing: 0.5,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD BOX
                  Container(
                    width: double.infinity,
                    height: 63,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFFF2F3F7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(
                            color: Color(0xFFA1A4B2),
                            letterSpacing: 0.5,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // LOGIN BUTTON (your logic preserved!)
                  GestureDetector(
                    onTap: () async {
                      String username = _usernameController.text;
                      String password = _passwordController.text;

                      final response = await request.login(
                        "https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/auth/login-flutter/",
                        {'username': username, 'password': password},
                      );

                      if (request.loggedIn) {
                        final userData = await request.get("https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/auth/user-flutter/");
                        UserEntry user = UserEntry.fromJson(userData);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => MyHomePage(user: user)),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Login Failed"),
                            content: Text(response['message']),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"))
                            ],
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Color(0xFFF6FAF6),
                        borderRadius: BorderRadius.circular(54),
                        border: Border.all(
                          color: Color(0xFF547254),
                          width: 1.8,
                        ),
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

                  const SizedBox(height: 16),

                  // FORGOT PASSWORD
                  const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3F414E),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // SIGN UP REDIRECT
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      "DON’T HAVE AN ACCOUNT? SIGN UP",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFCACACA),
                      ),
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