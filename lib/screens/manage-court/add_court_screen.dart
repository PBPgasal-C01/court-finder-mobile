import 'dart:convert'; // WAJIB ADA: Untuk base64Encode
import 'dart:io';      // WAJIB ADA: Untuk File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // WAJIB ADA
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../services/manage_court_service.dart';

class AddCourtScreen extends StatefulWidget {
  const AddCourtScreen({super.key});

  @override
  State<AddCourtScreen> createState() => _AddCourtScreenState();
}

class _AddCourtScreenState extends State<AddCourtScreen> {
  final _formKey = GlobalKey<FormState>();
  final ManageCourtService _service = ManageCourtService();
  
  bool _isLoadingConstants = true;
  List<dynamic> _provinces = [];
  List<dynamic> _facilities = [];
  List<dynamic> _sportTypes = [];

  // Data Form
  String _name = "";
  String _address = "";
  double _price = 0;
  String? _selectedProvince;
  String? _selectedSportType;
  final Set<int> _selectedFacilities = {};
  String _operationalHours = "";
  String _phoneNumber = "";
  String _description = "";
  
  // --- VARIABEL UNTUK GAMBAR ---
  String? _imageBase64; // Ini yang dikirim ke Django
  String _fileName = "No file chosen"; // Ini untuk tampilan UI
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchConstants();
  }

  Future<void> _fetchConstants() async {
    final request = context.read<CookieRequest>();
    try {
      final data = await _service.fetchCourtConstants(request);
      if (data['status'] == 'success') {
        setState(() {
          _provinces = data['provinces'];
          _facilities = data['facilities'];
          _sportTypes = data['sport_types'];
          _isLoadingConstants = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingConstants = false);
    }
  }

  // --- FUNGSI PILIH GAMBAR ---
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // 1. Baca file sebagai bytes
        final bytes = await image.readAsBytes();
        // 2. Encode jadi Base64
        final String base64Image = base64Encode(bytes);
        // 3. Tambahkan header data (penting buat Django tau ini jpg/png)
        // Kita asumsikan jpeg/png.
        final String formattedBase64 = "data:image/jpeg;base64,$base64Image";

        setState(() {
          _fileName = image.name; // Update nama file di UI
          _imageBase64 = formattedBase64; // Simpan string panjangnya
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick image")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryGreen = const Color(0xFF4F6F52); 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(toolbarHeight: 0, backgroundColor: primaryGreen, elevation: 0),
      body: _isLoadingConstants
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // HEADER (Sama seperti sebelumnya)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.edit_note, color: Colors.white, size: 40),
                        SizedBox(height: 10),
                        Text("ADD NEW COURT", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        SizedBox(height: 5),
                        Text("Own a Court? Share it Here!", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // FORM INPUTS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Court Name", required: true),
                        TextFormField(
                          decoration: _inputDecor(Icons.stadium, "Enter court name"),
                          onChanged: (val) => setState(() => _name = val),
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel("Address", required: true),
                        TextFormField(
                          decoration: _inputDecor(Icons.location_on, "Enter address"),
                          maxLines: 2,
                          onChanged: (val) => setState(() => _address = val),
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel("Type Sport", required: true),
                        DropdownButtonFormField<String>(
                          decoration: _inputDecor(Icons.sports, "Select sport type"),
                          value: _selectedSportType,
                          items: _sportTypes.map((item) => DropdownMenuItem<String>(value: item['value'], child: Text(item['label']))).toList(),
                          onChanged: (val) => setState(() => _selectedSportType = val),
                          validator: (val) => val == null ? "Required" : null,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel("Operational Time"),
                        TextFormField(
                          decoration: _inputDecor(Icons.access_time, "e.g. 09.00 - 22.00"),
                          onChanged: (val) => setState(() => _operationalHours = val),
                        ),
                        const SizedBox(height: 16),

                        _buildLabel("Price/Hours (Rp)", required: true),
                        TextFormField(
                          decoration: _inputDecor(Icons.attach_money, "e.g. 200000"),
                          keyboardType: TextInputType.number,
                          onChanged: (val) => setState(() => _price = double.tryParse(val) ?? 0),
                          validator: (val) {
                            if (val == null || val.isEmpty) return "Required";
                            if (double.tryParse(val) == null) return "Must be a valid number";
                            if (double.parse(val) <= 0) return "Price must be positive";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel("Province", required: true),
                        DropdownButtonFormField<String>(
                          decoration: _inputDecor(Icons.map, "Select province"),
                          value: _selectedProvince,
                          items: _provinces.map((item) => DropdownMenuItem<String>(value: item['pk'].toString(), child: Text(item['name']))).toList(),
                          onChanged: (val) => setState(() => _selectedProvince = val),
                          validator: (val) => val == null ? "Required" : null,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel("Facilities"),
                        Container(
                          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                          child: _facilities.isEmpty
                              ? const Padding(padding: EdgeInsets.all(16), child: Text("No facilities"))
                              : Column(
                                  children: _facilities.map((item) {
                                    final int id = item['pk'];
                                    return CheckboxListTile(
                                      title: Text(item['name']),
                                      value: _selectedFacilities.contains(id),
                                      activeColor: primaryGreen,
                                      dense: true,
                                      controlAffinity: ListTileControlAffinity.trailing,
                                      onChanged: (val) => setState(() => val! ? _selectedFacilities.add(id) : _selectedFacilities.remove(id)),
                                    );
                                  }).toList(),
                                ),
                        ),
                        const SizedBox(height: 16),

                        _buildLabel("Phone Number"),
                        TextFormField(
                          decoration: _inputDecor(Icons.phone, "Enter phone number"),
                          keyboardType: TextInputType.phone,
                          onChanged: (val) => setState(() => _phoneNumber = val),
                          validator: (val) {
                            if (val == null || val.isEmpty) return "Required"; // Atau null kalau opsional
                            if (!RegExp(r'^[0-9]+$').hasMatch(val)) return "Numbers only"; // Cuma boleh angka
                            if (val.length < 10 || val.length > 15) return "Invalid phone number length";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel("Description"),
                        TextFormField(
                          decoration: _inputDecor(Icons.description, "Enter description"),
                          maxLines: 4,
                          onChanged: (val) => setState(() => _description = val),
                        ),
                        const SizedBox(height: 16),

                        // --- IMAGE PICKER UI ---
                        _buildLabel("Image"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.image, color: Colors.grey[400]),
                              const SizedBox(width: 12),
                              // Tampilkan nama file atau truncate jika kepanjangan
                              Expanded(
                                child: Text(
                                  _fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              TextButton(
                                onPressed: _pickImage, // Panggil fungsi pick
                                child: const Text("Choose"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // BUTTONS
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: Colors.red.shade300),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text("CANCEL", style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: primaryGreen, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final request = context.read<CookieRequest>();
                                    final data = {
                                      'name': _name,
                                      'address': _address,
                                      'price': _price,
                                      'sport_type': _selectedSportType,
                                      'province': _selectedProvince,
                                      'facilities': _selectedFacilities.toList(),
                                      'operational_hours': _operationalHours,
                                      'phone_number': _phoneNumber,
                                      'description': _description,
                                      // Tambahkan data gambar
                                      'image': _imageBase64, 
                                    };

                                    try {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Processing Data...")));
                                      final response = await _service.createCourt(request, data);
                                      if (context.mounted) {
                                        if (response['status'] == 'success') {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Court saved successfully!")));
                                          Navigator.pop(context);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: ${response['message']}"), backgroundColor: Colors.red));
                                        }
                                      }
                                    } catch (e) {
                                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                                    }
                                  }
                                },
                                child: Text("SAVE", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Helpers (Sama seperti sebelumnya)
  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(color: Colors.grey[800], fontSize: 14, fontWeight: FontWeight.w600),
          children: [if (required) const TextSpan(text: " *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))],
        ),
      ),
    );
  }

  InputDecoration _inputDecor(IconData icon, String hint) {
    return InputDecoration(
      hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14), filled: true, fillColor: Colors.grey[50],
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F6F52), width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
    );
  }
}