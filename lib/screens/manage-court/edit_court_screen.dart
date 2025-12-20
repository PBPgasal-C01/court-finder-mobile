import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../models/manage-court/court.dart'; // Import Model Court
import '../../services/manage_court_service.dart';

class EditCourtScreen extends StatefulWidget {
  final Court court; // Kita butuh data Court yang mau diedit

  const EditCourtScreen({super.key, required this.court});

  @override
  State<EditCourtScreen> createState() => _EditCourtScreenState();
}

class _EditCourtScreenState extends State<EditCourtScreen> {
  final _formKey = GlobalKey<FormState>();
  final ManageCourtService _service = ManageCourtService();
  
  bool _isLoadingConstants = true;
  List<dynamic> _provinces = [];
  List<dynamic> _facilities = [];
  List<dynamic> _sportTypes = [];

  // Variable Form
  late String _name;
  late String _address;
  late double _price;
  String? _selectedProvince;
  String? _selectedSportType;
  final Set<int> _selectedFacilities = {};
  
  late String _operationalHours;
  late String _phoneNumber;
  late String _description;

  @override
  void initState() {
    super.initState();
    // 1. Isi form dengan data lama (dari widget.court)
    _name = widget.court.name;
    _address = widget.court.address;
    _price = widget.court.pricePerHour;
    _selectedSportType = widget.court.courtType; 
    _operationalHours = widget.court.operationalHours ?? "";
    _phoneNumber = widget.court.phoneNumber ?? "";
    _description = widget.court.description ?? "";

    // 2. Ambil Constants dari Django
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
          
          // --- LOGIKA MENGISI DROPDOWN PROVINSI ---
          try {
             final foundProv = _provinces.firstWhere(
               (prov) => prov['name'] == widget.court.province
             );
             _selectedProvince = foundProv['pk'].toString();
          } catch (e) {
             _selectedProvince = null;
          }

          // --- LOGIKA MENGISI CHECKBOX FASILITAS ---
          for (var courtFacil in widget.court.facilities) {
             for (var apiFacil in _facilities) {
                if (apiFacil['name'] == courtFacil) {
                   _selectedFacilities.add(apiFacil['pk']);
                }
             }
          }

          _isLoadingConstants = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingConstants = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Warna Hijau Konsisten (Army Green)
    final primaryGreen = const Color(0xFF4F6F52); 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0, // Sembunyikan default AppBar
        backgroundColor: primaryGreen,
        elevation: 0,
      ),
      body: _isLoadingConstants
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // --- 1. CUSTOM HEADER HIJAU ---
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
                      children: [
                        const Icon(Icons.edit, color: Colors.white, size: 40),
                        const SizedBox(height: 10),
                        const Text(
                          "EDIT COURT",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Update details for '${widget.court.name}'",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- 2. FORM FIELDS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        _buildLabel("Court Name", required: true),
                        TextFormField(
                          initialValue: _name,
                          decoration: _inputDecor(Icons.stadium, "Enter court name"),
                          onChanged: (val) => _name = val,
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 16),

                        // Address
                        _buildLabel("Address", required: true),
                        TextFormField(
                          initialValue: _address,
                          decoration: _inputDecor(Icons.location_on, "Enter address"),
                          maxLines: 2,
                          onChanged: (val) => _address = val,
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 16),

                        // Sport Type
                        _buildLabel("Type Sport", required: true),
                        DropdownButtonFormField<String>(
                          decoration: _inputDecor(Icons.sports, "Select sport type"),
                          value: _selectedSportType,
                          items: _sportTypes.map((item) {
                            return DropdownMenuItem<String>(
                              value: item['value'],
                              child: Text(item['label']),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedSportType = val),
                          validator: (val) => val == null ? "Required" : null,
                        ),
                        const SizedBox(height: 16),

                        // Operational Hours
                        _buildLabel("Operational Hours"),
                        TextFormField(
                          initialValue: _operationalHours,
                          decoration: _inputDecor(Icons.access_time, "e.g. 09.00 - 22.00"),
                          onChanged: (val) => _operationalHours = val,
                        ),
                        const SizedBox(height: 16),

                        // Price
                        _buildLabel("Price/Hours (Rp)", required: true),
                        TextFormField(
                          initialValue: _price.toStringAsFixed(0),
                          decoration: _inputDecor(Icons.attach_money, "e.g. 200000"),
                          keyboardType: TextInputType.number,
                          onChanged: (val) => _price = double.tryParse(val) ?? 0,
                          validator: (val) {
                            if (val == null || val.isEmpty) return "Required";
                            if (double.tryParse(val) == null) return "Must be a valid number";
                            if (double.parse(val) <= 0) return "Price must be positive";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        _buildLabel("Phone Number"),
                        TextFormField(
                          initialValue: _phoneNumber,
                          decoration: _inputDecor(Icons.phone, "Enter phone number"),
                          onChanged: (val) => _phoneNumber = val,
                          validator: (val) {
                            if (val == null || val.isEmpty) return "Required"; // Atau null kalau opsional
                            if (!RegExp(r'^[0-9]+$').hasMatch(val)) return "Numbers only"; // Cuma boleh angka
                            if (val.length < 10 || val.length > 15) return "Invalid phone number length";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Province
                        _buildLabel("Province", required: true),
                        DropdownButtonFormField<String>(
                          decoration: _inputDecor(Icons.map, "Select province"),
                          value: _selectedProvince,
                          items: _provinces.map((item) {
                            return DropdownMenuItem<String>(
                              value: item['pk'].toString(), 
                              child: Text(item['name']),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedProvince = val),
                          validator: (val) => val == null ? "Required" : null,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        _buildLabel("Description"),
                        TextFormField(
                          initialValue: _description,
                          decoration: _inputDecor(Icons.description, "Enter description"),
                          maxLines: 3,
                          onChanged: (val) => _description = val,
                        ),
                        const SizedBox(height: 16),

                        // Facilities
                        _buildLabel("Facilities"),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: _facilities.map((item) {
                              final int id = item['pk'];
                              return CheckboxListTile(
                                title: Text(item['name'], style: TextStyle(color: Colors.grey[800])),
                                value: _selectedFacilities.contains(id),
                                activeColor: primaryGreen,
                                dense: true,
                                controlAffinity: ListTileControlAffinity.trailing,
                                onChanged: (bool? checked) {
                                  setState(() {
                                    if (checked == true) _selectedFacilities.add(id);
                                    else _selectedFacilities.remove(id);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        
                        const SizedBox(height: 40),

                        // --- 3. BUTTONS (CANCEL & SAVE) ---
                        Row(
                          children: [
                            // CANCEL
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: Colors.red.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "CANCEL",
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // SAVE CHANGE
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: primaryGreen, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  // LOGIKA ASLI (Tidak Diubah)
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
                                    };

                                    try {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updating...")));
                                      
                                      final response = await _service.editCourt(request, widget.court.pk, data);

                                      if (context.mounted) {
                                        if (response['status'] == 'success') {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Court updated!")),
                                          );
                                          Navigator.pop(context); 
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Failed: ${response['message']}")),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      print(e);
                                    }
                                  }
                                },
                                child: Text(
                                  "SAVE CHANGES",
                                  style: TextStyle(
                                    color: primaryGreen,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
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

  // --- WIDGET HELPER (Sama dengan Add Page) ---
  
  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(color: Colors.grey[800], fontSize: 14, fontWeight: FontWeight.w600),
          children: [
            if (required)
              const TextSpan(text: " *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecor(IconData icon, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.grey[50],
      
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4F6F52), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}