import 'package:flutter/material.dart';
import 'package:court_finder_mobile/models/complain/complaint_entry.dart';
import 'package:court_finder_mobile/screens/complain/menu_complaint.dart';

class AddComplaintPage extends StatefulWidget {
  const AddComplaintPage({super.key});

  @override
  State<AddComplaintPage> createState() => _AddComplaintPageState();
}

class _AddComplaintPageState extends State<AddComplaintPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _courtNameController = TextEditingController();
  final TextEditingController _masalahController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _fotoUrlController = TextEditingController();

  final Color _headerColor = const Color(0xFF3F5940);
  final Color _inputBoxColor = const Color(0xFFF3F3F3);

  @override
  void dispose() {
    _courtNameController.dispose();
    _masalahController.dispose();
    _deskripsiController.dispose();
    _fotoUrlController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newComplaint = ComplaintEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        courtName: _courtNameController.text,
        masalah: _masalahController.text,
        deskripsi: _deskripsiController.text,
        fotoUrl: _fotoUrlController.text,
        status: "Ditinjau",
        komentar: null,
        createdAt: DateTime.now(),
      );

      print("Data Disimpan: ${newComplaint.toJson()}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Laporan berhasil dibuat!")),
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ComplaintScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: BoxDecoration(
                color: _headerColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: const [
                  Icon(Icons.edit_note, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "MAKE NEW REPORT",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Share your problem about the court",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // --- FORM SECTION ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Court Name"),
                    _buildTextField(
                      controller: _courtNameController,
                      hint: "example : Lapangan Futsal A",
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Problem Title"),
                    _buildTextField(
                      controller: _masalahController,
                      hint: "Example : Lampu Mati / Jaring Rusak",
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Description"),
                    _buildTextField(
                      controller: _deskripsiController,
                      hint: "Share the detail",
                      maxLines: 5,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Upload Image (URL)"),
                    _buildTextField(
                      controller: _fotoUrlController,
                      hint: "Upload Image",
                      icon: Icons.link,
                    ),

                    const SizedBox(height: 40),

                    // --- BUTTONS SECTION ---
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
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 20),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitForm,
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
                            child: const Text(
                              "SAVE",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    IconData? icon,
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
          if (value == null || value.isEmpty) {
            return 'Field ini tidak boleh kosong';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}