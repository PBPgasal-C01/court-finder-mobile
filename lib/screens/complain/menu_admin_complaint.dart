import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb; // Pastikan ini ada
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

  late Future<List<ComplaintEntry>> _complaintFuture;

  @override
  void initState() {
    super.initState();

    _complaintFuture = fetchComplaints();
  }

  Future<List<ComplaintEntry>> fetchComplaints() async {
    String baseUrl = kIsWeb
        ? 'https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id' // Production
        : 'http://10.0.2.2:8000'; // Android Emulator Local

    var url = Uri.parse('$baseUrl/complain/admin/json-flutter/');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        // Decode JSON
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        List<ComplaintEntry> listComplaint = [];
        
        for (var d in data) {
          if (d != null) {
            listComplaint.add(ComplaintEntry.fromJson(d));
          }
        }
        return listComplaint;
      } else {
        throw Exception('Gagal load data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching data: $e");

      return []; 
    }
  }

  List<ComplaintEntry> _filterData(List<ComplaintEntry> allData) {

    if (_selectedFilter == 'ALL') {
      return allData;
    }

    return allData.where((item) {

      String status = item.status.toUpperCase();

      if (_selectedFilter == 'PROCESS') {
        return status == 'IN PROCESS';
      }

      return status == _selectedFilter;
    }).toList();
  }

  void refreshData() {
    setState(() {
      _complaintFuture = fetchComplaints();
    });
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
              future: _complaintFuture, // Gunakan variable future, bukan fungsi langsung
              builder: (context, AsyncSnapshot<List<ComplaintEntry>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No data"));
                }

                List<ComplaintEntry> filteredList = _filterData(snapshot.data!);

                if (filteredList.isEmpty) {
                   return const Center(child: Text("No complaints in this category"));
                }

                return ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final complaint = filteredList[index];
                      return AdminComplaintCard(
                          complaint: complaint,
                          onSeeDetail: () async {

                            await Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => ComplaintDetailEditPage(
                                complaintId: complaint.id, 
                                complaint: complaint
                              ))
                            );

                            refreshData();
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