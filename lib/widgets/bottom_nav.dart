import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF6B8E72),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0), // Hapus padding horizontal biar Expanded yang ngatur
        child: Row(
          // MainAxisAlignment GAK PERLU lagi karena Expanded akan memenuhi ruang
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.edit, 'Manage', 1),
            _buildNavItem(Icons.event, 'Event', 2),
            _buildNavItem(Icons.search, 'Finder', 3),
            _buildNavItem(Icons.article, 'Blog', 4),
            _buildNavItem(Icons.comment, 'Report', 5),
          ],
        ),
      ),
    );
  }

  // Bungkus return widget dengan Expanded
  Widget _buildNavItem(IconData icon, String label, int index) {
    final Color myDarkGreen = const Color(0xFF3F5940);
    final bool isSelected = selectedIndex == index;
    final Color color = isSelected ? myDarkGreen : Colors.white;
    final FontWeight fontWeight = isSelected ? FontWeight.w800 : FontWeight.normal;

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1, // Pastikan teks gak turun baris
              overflow: TextOverflow.visible, // Biarkan terlihat meski mepet dikit
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}