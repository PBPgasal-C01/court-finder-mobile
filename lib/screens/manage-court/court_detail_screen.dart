import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../models/manage-court/court.dart';
import '../../services/manage_court_service.dart';

class CourtDetailScreen extends StatefulWidget {
  final Court court;

  const CourtDetailScreen({super.key, required this.court});

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  final ManageCourtService _service = ManageCourtService();

  List<dynamic> _allFacilities = [];
  bool _isLoading = true;

  // Daftar warna untuk balon facilities
  final List<Color> _facilityColors = [
    const Color(0xFF81C784), // Hijau muda
    const Color(0xFF64B5F6), // Biru muda
    const Color(0xFFFFB74D), // Orange muda
    const Color(0xFFE57373), // Merah muda
    const Color(0xFF9575CD), // Ungu muda
    const Color(0xFF4DB6AC), // Teal
    const Color(0xFFFFD54F), // Kuning
    const Color(0xFFA1887F), // Coklat muda
  ];

  @override
  void initState() {
    super.initState();
    _fetchFacilitiesData();
  }

  Future<void> _fetchFacilitiesData() async {
    final request = context.read<CookieRequest>();
    try {
      final data = await _service.fetchCourtConstants(request);
      if (data['status'] == 'success') {
        setState(() {
          _allFacilities = data['facilities'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getFacilityName(dynamic id) {
    try {
      final facility = _allFacilities.firstWhere((item) => item['pk'] == id);
      return facility['name'];
    } catch (e) {
      return "Unknown ($id)";
    }
  }

  // Fungsi untuk mendapatkan warna berdasarkan index
  Color _getFacilityColor(int index) {
    return _facilityColors[index % _facilityColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final primaryGreen = const Color(0xFF6B8E72);

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. HEADER HIJAU dengan info court
                  Container(
                    padding: const EdgeInsets.only(
                      top: 50,
                      left: 20,
                      right: 20,
                      bottom: 30,
                    ),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Back button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Nama Court
                        Text(
                          widget.court.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Type Court
                        Text(
                          widget.court.courtType,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Alamat
                        Text(
                          widget.court.address,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. GAMBAR COURT
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child:
                            (widget.court.photoUrl != null &&
                                widget.court.photoUrl!.isNotEmpty)
                            ? Image.network(
                                widget.court.photoUrl!.startsWith('http')
                                    ? widget.court.photoUrl!
                                    : 'https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id${widget.court.photoUrl}',
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) =>
                                    _buildNoImage(),
                              )
                            : _buildNoImage(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. INFO BAR (Jam & Harga)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Jam Operasional
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.court.operationalHours ?? "-",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        // Harga
                        Text(
                          "${widget.court.pricePerHour.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}/H",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 4. FACILITIES SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Facilities",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        widget.court.facilities.isEmpty
                            ? Text(
                                "No facilities available",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              )
                            : Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: List.generate(
                                  widget.court.facilities.length,
                                  (index) {
                                    final facilId =
                                        widget.court.facilities[index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getFacilityColor(index),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _getFacilityColor(
                                              index,
                                            ).withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        _getFacilityName(facilId),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 5. CONTACT SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Contact",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 18,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.court.phoneNumber ?? "-",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 6. DESCRIPTION SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (widget.court.description != null &&
                                  widget.court.description!.isNotEmpty)
                              ? widget.court.description!
                              : "No description available.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildNoImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image_not_supported_outlined,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          "No Image Available",
          style: TextStyle(color: Colors.grey[500], fontSize: 16),
        ),
      ],
    );
  }
}
