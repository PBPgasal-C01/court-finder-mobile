import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:court_finder_mobile/models/complain/complaint_entry.dart';

class ComplaintDetailEditPage extends StatefulWidget {
  final String complaintId;
  final ComplaintEntry complaint;

  const ComplaintDetailEditPage({
    super.key,
    required this.complaintId,
    required this.complaint,
  });

  @override
  State<ComplaintDetailEditPage> createState() => _ComplaintDetailEditPageState();
}

class _ComplaintDetailEditPageState extends State<ComplaintDetailEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _komentarController = TextEditingController();

  final Color _headerColor = const Color(0xFF3F5940);
  final Color _inputBoxColor = const Color(0xFFF3F3F3);

  String? _selectedStatus;
  bool _isLoading = false;

  // REVISI: Menghapus 'REJECTED' sesuai model Django Anda
  final List<String> _statusOptions = [
    'IN REVIEW',
    'IN PROCESS',
    'DONE',
  ];

  @override
  void initState() {
    super.initState();
    
    // Logika untuk memastikan status awal terpilih dengan benar
    String currentStatus = widget.complaint.status;
    
    // Cek apakah status dari database ada di list opsi kita
    // Kita cek exact match atau case-insensitive match
    var matchingStatus = _statusOptions.firstWhere(
      (element) => element.toUpperCase() == currentStatus.toUpperCase(),
      orElse: () => '',
    );

    if (matchingStatus.isNotEmpty) {
      _selectedStatus = matchingStatus;
    } else {
      // Jika status di database berbeda (misal: "Ditinjau"), default ke 'IN REVIEW'
      _selectedStatus = _statusOptions[0];
    }
    
    _komentarController.text = widget.complaint.komentar?.toString() ?? '';
  }

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final request = context.read<CookieRequest>();

      try {
        // 1. Tentukan Base URL
        String baseUrl;
        if (kIsWeb) {
          baseUrl = "http://127.0.0.1:8000";
        } else {
          baseUrl = "http://10.0.2.2:8000";
        }
        
        // 2. Endpoint update
        final String url = '$baseUrl/complain/update-flutter/${widget.complaintId}/';

        // 3. Kirim Request
        final response = await request.postJson(
          url,
          jsonEncode(<String, dynamic>{
            'status': _selectedStatus,
            'komentar': _komentarController.text,
          }),
        );

        if (!mounted) return;

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Laporan berhasil diperbarui!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal: ${response['message']}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'IN REVIEW':
        return 'In Review';
      case 'IN PROCESS':
        return 'In Process';
      case 'DONE':
        return 'Done';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: BoxDecoration(
                color: _headerColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, size: 35, color: Colors.white),
                  const SizedBox(height: 8),
                  const Text(
                    "REPORT DETAIL",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.complaint.courtName,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Problem Title (Read-only)
                    _buildLabel("Problem Title:"),
                    _buildReadOnlyField(widget.complaint.masalah),
                    const SizedBox(height: 20),

                    // User Description (Read-only)
                    _buildLabel("User Description:"),
                    _buildReadOnlyField(
                      widget.complaint.deskripsi,
                      maxLines: 6,
                    ),
                    const SizedBox(height: 20),

                    // Image (if exists)
                    if (widget.complaint.fotoUrl.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.complaint.fotoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: _inputBoxColor,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: _inputBoxColor,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // Status Dropdown
                    _buildLabel("Status"),
                    Container(
                      decoration: BoxDecoration(
                        color: _inputBoxColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        items: _statusOptions.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(_getStatusDisplayText(status)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih status laporan';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Komentar
                    _buildLabel("Comment"),
                    _buildTextField(
                      controller: _komentarController,
                      hint: "Add your comment here (optional)",
                      maxLines: 4,
                      isRequired: false,
                    ),
                    const SizedBox(height: 40),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF8D7DA),
                              foregroundColor: const Color(0xFF721C24),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: const BorderSide(color: Color(0xFFF5C6CB)),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "CANCEL",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitUpdate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _headerColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(color: _headerColor, width: 2),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text(
                                    "UPDATE",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF4A4A4A),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String text, {int maxLines = 1}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _inputBoxColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF4A4A4A),
        ),
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputBoxColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Field ini tidak boleh kosong';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}