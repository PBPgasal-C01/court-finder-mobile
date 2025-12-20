import 'package:court_finder_mobile/screens/login.dart';
import 'package:court_finder_mobile/screens/register.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ======================= TOP IMAGE + WAVE =========================
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: ClipPath(
              clipper: _BottomWaveClipper(),
              child: Container(
                width: double.infinity,
                height: 500,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6FAF6),
                  image: DecorationImage(
                    image: AssetImage("assets/images/welcome_header.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // ======================= TITLE =========================
          Positioned(
            top: 541,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "FIND THE TOP COURT",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF547254),
                ),
              ),
            ),
          ),

          // ======================= SUBTEXT =========================
          Positioned(
            top: 599,
            left: 20,
            right: 20,
            child: Center(
              child: Text(
                "Your easiest way to discover, compare, and\nreserve courts nearby.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: const Color(0xFFCACACA),
                ),
              ),
            ),
          ),

          // ======================= SIGN UP BUTTON =========================
          Positioned(
            top: 707,
            left: 45,
            right: 45,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // GANTI HALAMAN DI SINI:
                    builder: (context) => RegisterPage(),
                  ),
                );
              },
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6FAF6),
                  borderRadius: BorderRadius.circular(54),
                  border: Border.all(
                    color: const Color(0xFF547254),
                    width: 1.8,
                  ),
                ),
                child: Center(
                  child: Text(
                    "SIGN UP",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF547254),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ======================= LOGIN TEXT =========================
          Positioned(
            top: 788,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // GANTI HALAMAN DI SINI:
                      builder: (context) => LoginPage(),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "ALREADY HAVE AN ACCOUNT? ",
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFFCACACA),
                      ),
                    ),
                    Text(
                      "LOG IN",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ======================= HOME INDICATOR =========================
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 143,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E6E6),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wave clipper
class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 30,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 60,
      size.width,
      size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
