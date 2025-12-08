import 'package:flutter/material.dart';
import 'package:court_finder_mobile/models/complain/complaint_entry.dart';
import 'dart:io';

class AdminComplaintCard extends StatelessWidget {
  final ComplaintEntry complaint;
  final VoidCallback onSeeDetail;

  const AdminComplaintCard({
    super.key,
    required this.complaint,
    required this.onSeeDetail,
  });

  final Color _textDarkGreen = const Color(0xFF3F5940);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- 1. HEADER SECTION ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '${complaint.courtName.toUpperCase()} - ${complaint.masalah.toUpperCase()}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textDarkGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Garis Pembatas
          const Divider(thickness: 1, height: 1, color: Colors.black26),
          
          const SizedBox(height: 12),

          // --- 2. CONTENT SECTION (Image & Info) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 100,
                    height: 75,
                    color: Colors.grey[200],
                    child: _buildImage(),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Detail Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow("Court Name", complaint.courtName),
                      const SizedBox(height: 6),
                      _buildInfoRow("Deskripsi", complaint.masalah), // Menggunakan masalah sbg judul pendek
                      const SizedBox(height: 6),
                      _buildInfoRow("Status", complaint.status),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- 3. FOOTER BUTTON (SEE DETAIL) ---
          OutlinedButton(
            onPressed: onSeeDetail,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _textDarkGreen.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
            ),
            child: Text(
              "SEE DETAIL",
              style: TextStyle(
                color: _textDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk menampilkan gambar (Network / Asset / Placeholder)
  Widget _buildImage() {
    if (complaint.fotoUrl.isEmpty) {
      return const Icon(Icons.image, color: Colors.grey);
    }
    
    // Cek apakah URL web atau Path lokal
    if (complaint.fotoUrl.startsWith('http')) {
      return Image.network(
        complaint.fotoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    } else {
      return Image.file(
        File(complaint.fotoUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
  }

  // Helper untuk baris teks "Label : Value"
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80, // Lebar label tetap agar sejajar
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: _textDarkGreen,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Text(
          ": ",
          style: TextStyle(fontSize: 12, color: _textDarkGreen),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: _textDarkGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}