import 'package:flutter/material.dart';
import 'package:court_finder_mobile/models/complain/complaint_entry.dart';
import 'package:court_finder_mobile/widgets/complain/complaint_card.dart';
import 'package:court_finder_mobile/screens/complain/complaint_entryform.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final Color primaryGreen = const Color(0xFF6B8E72);
  final Color darkGreen = const Color(0xFF5E7A5E);
  final Color textGreen = const Color(0xFF4A614A);
  final Color bgGreen = const Color(0xFFF2F7F2);

  Future<List<ComplaintEntry>> fetchComplaints(CookieRequest request) async {
    // Gunakan 10.0.2.2 untuk emulator Android
    var url = 'http://10.0.2.2:8000/complaint/json-flutter/';
    var response = await request.get(url);

    List<ComplaintEntry> listComplaint = [];
    for (var d in response) {
      if (d != null) {
        listComplaint.add(ComplaintEntry.fromJson(d));
      }
    }
    return listComplaint;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      
      // 1. SOLUSI TOMBOL + HILANG
      // Hapus bagian floatingActionButton dan floatingActionButtonLocation
      
      body: Column(
        children: [
          // ========== HEADER SECTION ==========
          _buildHeader(request), // Pass request ke header untuk navigasi

          // ========== BODY CONTENT (FUTURE BUILDER) ==========
          Expanded(
            child: FutureBuilder(
              future: fetchComplaints(request), 
              builder: (context, AsyncSnapshot<List<ComplaintEntry>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error fetching data:\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                } else {
                  return _buildListState(snapshot.data!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HEADER (DIUPDATE) ---
  // Terima parameter request agar bisa dipakai kalau butuh validasi di masa depan
  Widget _buildHeader(CookieRequest request) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 25),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
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
          const Text(
            "Complain System",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Report the issue around you",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              // 2. SOLUSI NAVBAR HILANG (NAVIGASI)
              // Pastikan saat push, kita menggunakan Navigator yang benar.
              // Biasanya Navigator.push akan menumpuk halaman baru DI ATAS navbar (jika navbar ada di parent).
              // Saat di-pop (kembali), navbar akan terlihat lagi.
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddComplaintPage(),
                  ),
                );
                // setState di sini memastikan tampilan direfresh setelah balik dari form
                if (mounted) {
                   setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: bgGreen,
                foregroundColor: textGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                "+ Add Report",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'static/images/logo_court_finder.png',
          height: 220,
          fit: BoxFit.contain,
          color: primaryGreen.withOpacity(0.4),
          colorBlendMode: BlendMode.srcIn,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.image_not_supported,
            size: 100,
            color: Colors.grey[300],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "You never submitted a report",
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildListState(List<ComplaintEntry> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
          child: const Text(
            "Report Archive",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F5940),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final complaint = data[index];
              return ComplaintCard(
                complaint: complaint,
                onTap: () {
                },
              );
            },
          ),
        ),
      ],
    );
  }
}