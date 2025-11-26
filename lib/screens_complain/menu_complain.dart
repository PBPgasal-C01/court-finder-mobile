import 'package:flutter/material.dart';
import 'package:court_finder_mobile/widgets_complain/complaint_header.dart';

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});
  final Color primaryGreen = const Color(0xFF7FA580);
  final Color darkGreen = const Color(0xFF5E7A5E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          ComplaintHeader(
            onAddReportPressed: () {
              print("Tombol Add Report Ditekan");
            },
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_court_finder.png',
                  height: 220,
                  fit: BoxFit.contain,
                  color: primaryGreen.withOpacity(0.4),
                  colorBlendMode: BlendMode.srcIn,
                ),
                const SizedBox(height: 20),
                Text(
                  "You never submitted a report",
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  "CLICK ADD REPORT",
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 50), 
              ],
            ),
          ),
        ],
      ),
    );
  }
}