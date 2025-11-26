import 'package:flutter/material.dart';

class ComplaintHeader extends StatelessWidget {
  final VoidCallback onAddReportPressed;

  const ComplaintHeader({
    super.key,
    required this.onAddReportPressed,
  });

  final Color primaryGreen = const Color(0xFF7FA580);
  final Color textGreen = const Color(0xFF4A614A);
  final Color bgGreen = const Color(0xFFF2F7F2);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 45, 24, 25), 
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.sort, color: Colors.white, size: 28),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 15),

          const Text(
            "Complain System",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          const Text(
            "Report the issue around you",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5, 
            height: 48, 
            child: ElevatedButton(
              onPressed: onAddReportPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgGreen,
                foregroundColor: Colors.black87,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                "+ Add Report",
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w600,
                  color: textGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}