import 'package:flutter/material.dart';
import 'package:court_finder_mobile/screens/complain/menu_complaint.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http; // Import untuk HTTP request
import 'dart:convert'; // Import untuk JSON decoding

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

  final Color _headerColor = const Color(0xFF3F5940);
  final Color _inputBoxColor = const Color(0xFFF3F3F3);

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Flag untuk mencegah double submit saat loading
  bool _isLoading = false;

  @override
  void dispose() {
    _courtNameController.dispose();
    _masalahController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memilih gambar: $e")),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Pilih Sumber Gambar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF3F5940)),
              title: const Text("Kamera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF3F5940)),
              title: const Text("Galeri"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIKA SUBMIT KE DJANGO ---
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Tampilkan feedback loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sending report...")),
      );

      // URL Endpoint Django (Ganti 10.0.2.2 dengan IP Laptop jika di HP fisik)
      final Uri url = Uri.parse('http://10.0.2.2:8000/complaint/create-flutter/');

      // Gunakan MultipartRequest untuk kirim File + Teks
      final request = http.MultipartRequest('POST', url);

      // Isi Data Teks
      request.fields['court_name'] = _courtNameController.text;
      request.fields['masalah'] = _masalahController.text;
      request.fields['deskripsi'] = _deskripsiController.text;

      // Isi Data File (Jika ada gambar dipilih)
      if (_selectedImage != null) {
        final file = await http.MultipartFile.fromPath(
          'foto', // Harus sesuai nama field di Django request.FILES['foto']
          _selectedImage!.path,
        );
        request.files.add(file);
      }

      try {
        // Kirim Request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            if (!mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Laporan berhasil disimpan!"),
                backgroundColor: Colors.green,
              ),
            );

            // Kembali ke halaman list dengan sinyal refresh
            Navigator.pop(context, true);
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Gagal: ${data['message']}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error Server: ${response.statusCode}")),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan koneksi: $e")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION (DIKECILKAN) ---
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
                children: const [
                  Icon(Icons.edit_note, size: 35, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    "MAKE NEW REPORT",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Sampaikan keluhan fasilitas lapangan",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
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
                      hint: "Contoh: Lapangan Futsal A",
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Problem Title"),
                    _buildTextField(
                      controller: _masalahController,
                      hint: "Contoh: Lampu Mati / Jaring Rusak",
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Description"),
                    _buildTextField(
                      controller: _deskripsiController,
                      hint: "Jelaskan detail kerusakan...",
                      maxLines: 5,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Upload Image"),
                    
                    // IMAGE UPLOAD SECTION
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: _inputBoxColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Tap to upload image",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Camera or Gallery",
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _selectedImage!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImage = null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- BUTTONS SECTION ---
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const ComplaintScreen()),
                              );
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
                            onPressed: _isLoading ? null : _submitForm, // Disable button saat loading
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