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
  final Color primaryGreen = const Color(0xFF6B8E72);

  String _selectedFilter = 'ALL';
  late Future<List<ComplaintEntry>> _complaintFuture;

  // LANGSUNG URL PRODUCTION
  final String baseUrl = 'https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id';

  @override
  void initState() {
    super.initState();
    _complaintFuture = fetchComplaints();
  }

  Future<List<ComplaintEntry>> fetchComplaints() async {
    var url = Uri.parse('$baseUrl/complain/admin/json-flutter/');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        List<ComplaintEntry> listComplaint = [];
        for (var d in data) {
          if (d != null) listComplaint.add(ComplaintEntry.fromJson(d));
        }
        return listComplaint;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching data: $e");
      return []; 
    }
  }

  List<ComplaintEntry> _filterData(List<ComplaintEntry> allData) {
    if (_selectedFilter == 'ALL') return allData;
    return allData.where((item) {
      String status = item.status.toUpperCase();
      if (_selectedFilter == 'PROCESS') return status == 'IN PROCESS';
      if (_selectedFilter == 'REVIEW') return status == 'IN REVIEW';
      return status == _selectedFilter;
    }).toList();
  }

  Future<void> refreshData() async {
    setState(() {
      _complaintFuture = fetchComplaints();
    });
    await _complaintFuture; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
          Expanded(
            child: FutureBuilder(
              future: _complaintFuture,
              builder: (context, AsyncSnapshot<List<ComplaintEntry>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return RefreshIndicator(
                    onRefresh: refreshData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(child: Text("Error: ${snapshot.error}")),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: refreshData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: const Center(child: Text("No data available")),
                      ),
                    ),
                  );
                }

                List<ComplaintEntry> filteredList = _filterData(snapshot.data!);

                if (filteredList.isEmpty) {
                   return RefreshIndicator(
                     onRefresh: refreshData,
                     child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const Center(child: Text("No reports in this category")),
                        ),
                     ),
                   );
                }

                return RefreshIndicator(
                  onRefresh: refreshData,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                    },
                  ),
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