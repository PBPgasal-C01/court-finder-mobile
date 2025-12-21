import 'package:flutter/material.dart';
import 'package:court_finder_mobile/models/complain/complaint_entry.dart';
import 'package:court_finder_mobile/widgets/complain/complaint_card.dart';
import 'package:court_finder_mobile/screens/complain/complaint_entryform.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final Color primaryGreen = const Color(0xFF6B8E72);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  Future<void> _refreshComplaints() async {
    setState(() {});
    return Future.delayed(const Duration(seconds: 1));
  }

  Future<List<ComplaintEntry>> fetchComplaints(CookieRequest request) async {
    String baseUrl = kIsWeb
        ? 'https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id'
        : 'http://10.0.2.2:8000';
        
    var url = '$baseUrl/complain/json-flutter/';
    var response = await request.get(url);
    
    List<ComplaintEntry> list = [];
    for (var d in response) {
      if (d != null) {
        list.add(ComplaintEntry.fromJson(d));
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddComplaintPage()),
          );
          if (mounted && result == true) _refreshComplaints();
        },
        label: const Text("Add Report"),
        icon: const Icon(Icons.add),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),

      body: RefreshIndicator(
        onRefresh: _refreshComplaints,
        child: FutureBuilder(
          future: fetchComplaints(request),
          builder: (context, AsyncSnapshot<List<ComplaintEntry>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No reports yet"));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 80),
              itemCount: snapshot.data!.length + 1,
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
                
                final complaint = snapshot.data![index - 1];
                
                return ComplaintCard(
                  complaint: complaint,
                  onTap: () {
                  },
                  onDelete: () async {
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}