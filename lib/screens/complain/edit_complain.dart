import 'package:flutter/material.dart';
import 'package:court_finder_mobile/models/complain/complaint_entry.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class AdminEditComplaintPage extends StatefulWidget {
  final ComplaintEntry complaint;

  const AdminEditComplaintPage({super.key, required this.complaint});

  @override
  State<AdminEditComplaintPage> createState() => _AdminEditComplaintPageState();
}

class _AdminEditComplaintPageState extends State<AdminEditComplaintPage> {
  // Warna sesuai request
  final Color _headerColor = const Color(0xFF3F5940);
  final Color _inputBoxColor = const Color(0xFFF3F3F3);
  final Color _btnColor = const Color(0xFFE8D8C1); // Warna tombol cream/gold di gambar
  final Color _btnTextColor = const Color(0xFF8D6E63);

  late String _selectedStatus;
  late TextEditingController _commentController;
  bool _isLoading = false;

  // Daftar Status sesuai tuple Django
  final List<Map<String, String>> _statusOptions = [
    {'label': 'IN REVIEW', 'value': 'in review'},
    {'label': 'IN PROCESS', 'value': 'in process'},
    {'label': 'DONE', 'value': 'done'},
  ];

  @override
  void initState() {
    super.initState();

    String initialStatus = widget.complaint.status.toLowerCase();
    var exists = _statusOptions.any((element) => element['value'] == initialStatus);
    _selectedStatus = exists ? initialStatus : 'in review';

    _commentController = TextEditingController(text: widget.complaint.komentar ?? "");
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    setState(() {
      _isLoading = true;
    });


    await Future.delayed(const Duration(seconds: 1));
    print("Update ID: ${widget.complaint.id}");
    print("New Status: $_selectedStatus");
    print("Comment: ${_commentController.text}");
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil diperbarui (Simulasi)")),
      );
      Navigator.pop(context, true); 
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. HEADER SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
              decoration: BoxDecoration(
                color: _headerColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Expanded(
                        child: Text(
                          "REPORT DETAIL",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24), // Penyeimbang layout
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.complaint.courtName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. CONTENT SECTION ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Problem Title
                  _buildSectionLabel("Problem Title:"),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _inputBoxColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.complaint.masalah,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // User Description
                  _buildSectionLabel("User Description:"),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _inputBoxColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.complaint.deskripsi,
                      style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Image Evidence
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: widget.complaint.fotoUrl.isNotEmpty
                        ? (widget.complaint.fotoUrl.startsWith('http')
                            ? Image.network(
                                widget.complaint.fotoUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholder(),
                              )
                            : Image.file(
                                File(widget.complaint.fotoUrl),
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ))
                        : _buildPlaceholder(),
                  ),

                  const SizedBox(height: 30),
                  const Divider(thickness: 1),
                  const SizedBox(height: 10),

                  // --- 3. ADMIN ACTION SECTION ---
                  const Text(
                    "Update Status & Response",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F5940),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Dropdown Status
                  _buildSectionLabel("Status:"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _inputBoxColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        items: _statusOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option['value'],
                            child: Text(
                              option['label']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(option['value']!),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue!;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Comment Field
                  _buildSectionLabel("Admin Comment (Optional):"),
                  Container(
                    decoration: BoxDecoration(
                      color: _inputBoxColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: "Write a response or note...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Button Save
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _btnColor,
                        foregroundColor: _btnTextColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: _btnTextColor, width: 1.5),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              "PROCESS UPDATE",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'in review': return Colors.orange;
      case 'in process': return Colors.blue;
      case 'done': return Colors.green;
      default: return Colors.black;
    }
  }
}