import 'package:flutter/material.dart';
import 'package:court_finder_mobile/models/complain/complaint_entry.dart';
import 'package:court_finder_mobile/widgets/complain/complaint_card.dart';
import 'package:court_finder_mobile/screens/complain/complaint_entryform.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final Color primaryGreen = const Color(0xFF6B8E72);

  List<ComplaintEntry> _listComplaint = [];
  bool _isInitialLoading = true;

  // LANGSUNG URL PRODUCTION
  final String baseUrl = 'https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshComplaints(isSilent: false);
    });
  }

  Future<void> _refreshComplaints({bool isSilent = false}) async {
    final request = context.read<CookieRequest>();

    if (!isSilent) {
      setState(() => _isInitialLoading = true);
    }

    try {
      var url = '$baseUrl/complain/json-flutter/';
      var response = await request.get(url);

      List<ComplaintEntry> tempList = [];
      for (var d in response) {
        if (d != null) {
          tempList.add(ComplaintEntry.fromJson(d));
        }
      }

      if (mounted) {
        setState(() {
          _listComplaint = tempList;
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitialLoading = false);
        print("Error fetching data: $e");
      }
    }
  }

  Future<void> _deleteComplaint(String id) async {
    final request = context.read<CookieRequest>();
    
    try {
      final response = await request.postJson(
        '$baseUrl/complain/delete-flutter/$id/',
        jsonEncode({}),
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Successfully deleted")),
        );
        _refreshComplaints(isSilent: false); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Failed to delete"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("There's an error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddComplaintPage()),
          );
          if (mounted && result == true) _refreshComplaints(isSilent: false);
        },
        label: const Text("Add Report"),
        icon: const Icon(Icons.add),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),

      body: RefreshIndicator(
        onRefresh: () => _refreshComplaints(isSilent: false),
        child: _isInitialLoading
            ? const Center(child: CircularProgressIndicator())
            : _listComplaint.isEmpty
                ? const Center(child: Text("No reports yet"))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 80),
                    itemCount: _listComplaint.length + 1, 
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const Padding(
                          padding: EdgeInsets.fromLTRB(24, 0, 24, 10),
                          child: Text(
                            "Report Archive",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F5940),
                            ),
                          ),
                        );
                      }

                      final complaint = _listComplaint[index - 1];

                      return ComplaintCard(
                        complaint: complaint,
                        onTap: () {},
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Report'),
                              content: const Text('Are you sure you want to delete this report?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ) ?? false;

                          if (confirm) {
                            await _deleteComplaint(complaint.id);
                          }
                        },
                      );
                    },
                  ),
      ),
    );
  }
}