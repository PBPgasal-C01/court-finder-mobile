import 'package:flutter/material.dart';
import 'package:court_finder_mobile/widgets/report/admin_header.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  final Color primaryGreen = const Color(0xFF7FA580);
  final Color processedTabColor = const Color(0xFFE8D8C1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          const AdminHeader(),

          const SizedBox(height: 25),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterTab("ALL", isSelected: false),
                _buildFilterTab("PROCESSED", isSelected: true),
                _buildFilterTab("DONE", isSelected: false),
              ],
            ),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'static/images/logo_court_finder.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  "Don't have any report",
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  "GOOD JOB",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
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

  Widget _buildFilterTab(String label, {required bool isSelected}) {
    return Container(
      width: 100,
      height: 35,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? processedTabColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? processedTabColor : Colors.grey[300]!),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF8D6E63) : Colors.grey[600],
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}