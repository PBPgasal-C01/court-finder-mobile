import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:court_finder_mobile/models/complain/complaint_entry.dart';
import 'package:court_finder_mobile/widgets/complain/admin_complaint_card.dart';

import 'package:court_finder_mobile/screens/complain/edit_complain.dart'; 

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final Color primaryGreen = const Color(0xFF7FA580);

  String _selectedFilter = 'ALL'; 

  Future<List<ComplaintEntry>> fetchComplaints() async {

    String baseUrl = "https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id";

    var url = Uri.parse('$baseUrl/complain/admin/json-flutter/'); 
    
    try {
      var response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal ambil data. Status: ${response.statusCode}');
      }

      var data = jsonDecode(utf8.decode(response.bodyBytes));

      List<ComplaintEntry> listComplaint = [];
      for (var d in data) {
        if (d != null) {
          try {
             listComplaint.add(ComplaintEntry.fromJson(d));
          } catch (e) {
             print("Gagal parsing item ini: $d | Error: $e");
          }
        }
      }
      return listComplaint;

    } catch (e) {
      print("Error fetching complaints utama: $e");
      return []; 
    }
  }

  List<ComplaintEntry> _filterData(List<ComplaintEntry> allData) {
    if (_selectedFilter == 'ALL') {
      return allData;
    } 

    else if (_selectedFilter == 'REVIEW') {
      return allData.where((item) {
        return item.status.toLowerCase() == 'in review';
      }).toList();
    } 

    else if (_selectedFilter == 'PROCESS') {
      return allData.where((item) {
        String status = item.status.toLowerCase();

        return status == 'in process';
      }).toList();
    } 
    else if (_selectedFilter == 'DONE') {
      return allData.where((item) {
        return item.status.toLowerCase() == 'done';
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


          SingleChildScrollView(
            scrollDirection: Axis.horizontal, 
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
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

          const SizedBox(height: 10),

          Expanded(
            child: FutureBuilder(
              future: fetchComplaints(),
              builder: (context, AsyncSnapshot<List<ComplaintEntry>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Error: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                } else {
                  List<ComplaintEntry> filteredList = _filterData(snapshot.data!);

                  if (filteredList.isEmpty) {
                    return _buildEmptyState(); 
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final complaint = filteredList[index];
                      return AdminComplaintCard(
                        complaint: complaint,
                        onSeeDetail: () async {
                          final bool? shouldRefresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComplaintDetailEditPage(
                                complaintId: complaint.id, 
                                complaint: complaint,      
                              ),
                            ),
                          );

                          if (shouldRefresh == true) {
                            setState(() {
                              print("Data updated, refreshing list...");
                            });
                          }
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

  Widget _buildFilterTab(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(

        constraints: const BoxConstraints(minWidth: 80),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 35,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryGreen : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'static/images/logo_court_finder.png',
          width: 150,
          height: 150,
          fit: BoxFit.contain,
          color: Colors.grey[300], 
          colorBlendMode: BlendMode.srcIn,
          errorBuilder: (_,__,___) => Icon(Icons.folder_open, size: 80, color: Colors.grey[300]),
        ),
        const SizedBox(height: 20),
        Text(
          "No reports found",
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