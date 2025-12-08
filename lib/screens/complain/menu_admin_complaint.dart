import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:court_finder_mobile/models/complain/complaint_entry.dart';
import 'package:court_finder_mobile/widgets/complain/admin_complaint_card.dart';
// Pastikan kamu sudah membuat file halaman edit, atau comment import ini jika belum ada
// import 'package:court_finder_mobile/screens/complain/admin_edit_complaint.dart'; 

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final Color primaryGreen = const Color(0xFF7FA580);
  final Color processedTabColor = const Color(0xFFE8D8C1);
  final Color textBrown = const Color(0xFF8D6E63);

  // State untuk Filter
  String _selectedFilter = 'ALL'; // Pilihan: 'ALL', 'PROCESSED', 'DONE'

  // --- FUNGSI FETCH DATA ---
  Future<List<ComplaintEntry>> fetchComplaints() async {
    // Ganti URL sesuai endpoint Django kamu
    var url = Uri.parse('http://10.0.2.2:8000/complaint/json/'); 
    
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    var data = jsonDecode(utf8.decode(response.bodyBytes));

    List<ComplaintEntry> listComplaint = [];
    for (var d in data) {
      if (d != null) {
        listComplaint.add(ComplaintEntry.fromJson(d));
      }
    }
    return listComplaint;
  }

  // --- LOGIKA FILTER DATA ---
  List<ComplaintEntry> _filterData(List<ComplaintEntry> allData) {
    if (_selectedFilter == 'ALL') {
      return allData;
    } else if (_selectedFilter == 'PROCESSED') {
      // Menampilkan yang sedang berjalan (In Review / In Process)
      return allData.where((item) {
        String status = item.status.toLowerCase();
        return status == 'in review' || status == 'in process' || status == 'ditinjau';
      }).toList();
    } else if (_selectedFilter == 'DONE') {
      // Menampilkan yang sudah selesai
      return allData.where((item) {
        return item.status.toLowerCase() == 'done' || item.status.toLowerCase() == 'selesai';
      }).toList();
    }
    return allData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ========== HEADER SECTION ==========
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 15),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.menu, color: Colors.white, size: 28),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://i.pravatar.cc/150?img=11',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Report Dashboard",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                const Text(
                  "Admin",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ========== FILTER TABS ==========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterTab("ALL"),
                _buildFilterTab("PROCESSED"),
                _buildFilterTab("DONE"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ========== LIST DATA SECTION ==========
          Expanded(
            child: FutureBuilder(
              future: fetchComplaints(),
              builder: (context, AsyncSnapshot<List<ComplaintEntry>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                } else {
                  // Filter data berdasarkan tab yang dipilih
                  List<ComplaintEntry> filteredList = _filterData(snapshot.data!);

                  if (filteredList.isEmpty) {
                    return _buildEmptyState(); // Jika hasil filter kosong
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final complaint = filteredList[index];
                      return AdminComplaintCard(
                        complaint: complaint,
                        onSeeDetail: () {
                          // TODO: Navigasi ke halaman Edit
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => AdminEditComplaintPage(complaint: complaint),
                          //   ),
                          // );
                          print("Navigasi ke edit ID: ${complaint.id}");
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Tombol Filter
  Widget _buildFilterTab(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        width: 100,
        height: 35,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? processedTabColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? processedTabColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? textBrown : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Widget Tampilan Kosong
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'static/images/logo_court_finder.png', // Pastikan path ini benar
          width: 150,
          height: 150,
          fit: BoxFit.contain,
          color: Colors.grey[300], // Opsional: memberi tint abu
          colorBlendMode: BlendMode.srcIn,
          errorBuilder: (_,__,___) => Icon(Icons.folder_open, size: 80, color: Colors.grey[300]),
        ),
        const SizedBox(height: 20),
        Text(
          "No $_selectedFilter reports found",
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
        if (_selectedFilter == 'ALL') ...[
          const SizedBox(height: 5),
          const Text(
            "GOOD JOB",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ]
      ],
    );
  }
}