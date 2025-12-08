import 'package:flutter/material.dart';
import 'package:court_finder_mobile/screens/complain/complaint_entryform.dart';

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});
  
  final Color primaryGreen = const Color(0xFF6B8E72);
  final Color darkGreen = const Color(0xFF5E7A5E);
  final Color textGreen = const Color(0xFF4A614A);
  final Color bgGreen = const Color(0xFFF2F7F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("🔥 FAB Clicked!"); // DEBUG
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddComplaintPage(),
            ),
          );
        },
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          // ========== HEADER SECTION ==========
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 25), 
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Baris Atas: Icon Menu & Avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.sort, color: Colors.white, size: 28),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),

                // Teks Judul
                const Text(
                  "Report System",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                
                // Teks Subjudul
                const Text(
                  "Report the issue around you",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // Tombol Add Report
                SizedBox(
                  width: double.infinity,
                  height: 50, 
                  child: ElevatedButton(
                    onPressed: () {
                      print("🔥 Button clicked!"); // DEBUG
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddComplaintPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bgGreen,
                      foregroundColor: textGreen,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "+ Add Report",
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: textGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ========== EMPTY STATE SECTION ==========
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
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image_not_supported, 
                    size: 100, 
                    color: Colors.grey[300]
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "You never submitted a report",
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    print("🔥 Text clicked!"); // DEBUG
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddComplaintPage(),
                      ),
                    );
                  },
                  child: Text(
                    "CLICK ADD REPORT",
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
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