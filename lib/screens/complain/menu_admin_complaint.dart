import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:court_finder_mobile/models/complain/complaint_entry.dart';
import 'package:court_finder_mobile/widgets/complain/admin_complaint_card.dart';
import 'package:court_finder_mobile/screens/complain/edit_complain.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final Color primaryGreen = const Color(0xFF6B8E72);
  String _selectedFilter = 'ALL';

  Future<List<ComplaintEntry>> fetchComplaints() async {
    // ... logic fetch tetap sama (copy dari file lamamu) ...
    return []; // Placeholder biar kode jalan
  }

  List<ComplaintEntry> _filterData(List<ComplaintEntry> allData) {
    // ... logic filter tetap sama ...
    if (_selectedFilter == 'ALL') return allData;
    return allData.where((i) => i.status.toUpperCase() == _selectedFilter && _selectedFilter != 'PROCESS' ? true : i.status.toUpperCase() == 'IN PROCESS').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 50,
            margin: const EdgeInsets.only(top: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                _buildFilterTab("ALL"),
                const SizedBox(width: 8),
                _buildFilterTab("REVIEW"),
                const SizedBox(width: 8),
                _buildFilterTab("PROCESS"),
                const SizedBox(width: 8),
                _buildFilterTab("DONE"),
              ],
            ),
          ),

          const Divider(),

          // LIST DATA
          Expanded(
            child: FutureBuilder(
              future: fetchComplaints(),
              builder: (context, AsyncSnapshot<List<ComplaintEntry>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No data"));

                List<ComplaintEntry> filteredList = _filterData(snapshot.data!);
                return ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final complaint = filteredList[index];
                      return AdminComplaintCard(
                          complaint: complaint,
                          onSeeDetail: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => ComplaintDetailEditPage(complaintId: complaint.id, complaint: complaint)));
                            setState((){});
                          }
                      );
                    }
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        constraints: const BoxConstraints(minWidth: 80),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryGreen : Colors.grey.shade300),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}