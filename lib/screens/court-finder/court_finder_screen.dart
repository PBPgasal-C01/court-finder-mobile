import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:intl/intl.dart';

// Sesuaikan path import ini dengan struktur projectmu
import '../../models/court-finder/court.dart';
import '../../models/court-finder/court_filter.dart';
import '../../models/court-finder/province.dart';
import '../../services/court-finder/api_service.dart';
import '../../services/court-finder/location_service.dart';
import '../../widgets/court-finder/filter_bottom_sheet.dart';
import '../login.dart';
import '../menu.dart';

class CourtFinderScreen extends StatefulWidget {
  const CourtFinderScreen({Key? key}) : super(key: key);

  @override
  State<CourtFinderScreen> createState() => _CourtFinderScreenState();
}

class _CourtFinderScreenState extends State<CourtFinderScreen> {
  // --- Services ---
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();

  // --- Controllers ---
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // --- State Variables ---
  LatLng _currentPosition = LatLng(-6.2088, 106.8456); // Default Jakarta
  // _selectedPosition adalah koordinat tengah peta (pointer)
  LatLng _selectedPosition = LatLng(-6.2088, 106.8456);

  List<Court> _courts = [];
  List<Province> _provinces = [];
  CourtFilter _filter = CourtFilter();

  bool _isLoading = false;
  bool _isMapMovedByUser = false;
  int _selectedTab = 0; // 0: All, 1: Bookmark
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- 1. INITIALIZATION ---
  Future<void> _initializeData() async {
    await _loadProvinces();
    await _getCurrentLocation();
  }

  Future<void> _loadProvinces() async {
    try {
      final provinces = await _apiService.getProvinces();
      setState(() => _provinces = provinces);
    } catch (e) {
      print("Error loading provinces: $e");
    }
  }

  // --- 2. LOGIC: SEARCH MANUAL (USER INPUT) ---
  Future<void> _searchLocation() async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus(); // Tutup keyboard

    // Menggunakan geocodeAddress dari api_service.dart milikmu
    final coords = await _apiService.geocodeAddress(query);

    if (coords != null) {
      final newPos = LatLng(coords['latitude']!, coords['longitude']!);

      setState(() {
        _selectedPosition = newPos;
        _isMapMovedByUser = true; // Menandakan user custom lokasi

        // Pindah ke tab All jika sedang di bookmark agar hasil terlihat
        if (_selectedTab == 1) _selectedTab = 0;
      });

      // Pindahkan Peta & Pointer ke lokasi hasil search
      _mapController.move(newPos, 15.0);

      // Load lapangan di lokasi baru
      _loadCourts();

      // Animasi buka sheet sedikit
      if (_sheetController.isAttached) {
        _sheetController.animateTo(
          0.4,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lokasi tidak ditemukan")));
    }
    setState(() => _isLoading = false);
  }

  // --- 3. LOGIC: GPS LOCATION ---
  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      final newPos = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = newPos;
        _selectedPosition = newPos; // Pointer ikut GPS
        _isMapMovedByUser = false;
      });
      _mapController.move(newPos, 15.0);
      _loadCourts();
    }
  }

  // --- 4. LOGIC: LOAD COURTS (POINTER BASED) ---
  Future<void> _loadCourts() async {
    // 1. Cancel timer sebelumnya jika user masih menggeser peta
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 2. Tunggu 800ms setelah user BERHENTI menggeser peta
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      if (!mounted) return;

      final request = context.read<CookieRequest>();

      try {
        List<Court> courts;

        // --- STEP 1: SIAPKAN FILTER ---
        // Gabungkan Filter dari BottomSheet (_filter) dengan Posisi Map (_selectedPosition)
        // Ini supaya Bookmark juga bisa diurutkan berdasarkan jarak/filter lokasi jika backend mendukung
        CourtFilter activeFilter = _filter.copyWith(
          latitude: _selectedPosition.latitude,
          longitude: _selectedPosition.longitude,
        );

        // Debugging
        print("Loading courts with filter. Tab: $_selectedTab");

        if (_selectedTab == 1) {
          // --- TAB BOOKMARK ---
          if (!request.loggedIn) {
            courts = [];
          } else {
            // PERUBAHAN DISINI:
            // Sekarang kita kirim 'activeFilter' ke fungsi getBookmarkedCourts
            // ApiService akan menggabungkan ini dengan 'bookmarkedOnly: true'
            courts = await _apiService.getBookmarkedCourts(
              request,
              filter: activeFilter,
            );
          }
        } else {
          // --- TAB NEARBY/ALL ---
          // Ini tetap sama, kirim activeFilter biasa
          courts = await _apiService.searchCourts(request, activeFilter);
        }

        setState(() {
          _courts = courts;
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading courts: $e');
        setState(() => _isLoading = false);
      }
    });
  }

  // --- 5. LOGIC: MAP MOVEMENT ---
  void _onMapPositionChanged(MapPosition position, bool hasGesture) {
    if (position.center != null) {
      // 1. Update posisi pointer secara real-time agar pin merah tidak ketinggalan
      setState(() {
        _selectedPosition = position.center!;
        if (hasGesture) {
          _isMapMovedByUser = true; // Munculkan tombol "Back to GPS"
        }
      });

      // 2. Jika pergerakan disebabkan oleh user (geser jari), panggil load data
      // Kita pakai debounce di dalam _loadCourts agar server tidak jebol
      if (hasGesture && _selectedTab == 0) {
        _loadCourts();
      }
    }
  }

  Future<void> _toggleBookmark(Court court) async {
    final request = context.read<CookieRequest>();

    // --- CEK LOGIN SAAT KLIK BINTANG ---
    if (!request.loggedIn) {
      _showLoginDialog(); // Panggil Popup
      return; // Stop, jangan lanjut request ke server
    }
    // -----------------------------------

    try {
      final newStatus = await _apiService.toggleBookmark(request, court.id);
      setState(() {
        final index = _courts.indexWhere((c) => c.id == court.id);
        if (index != -1) {
          _courts[index] = court.copyWith(isBookmarked: newStatus);
        }
      });

      // Feedback Snackbar kecil saja kalau sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus ? 'Disimpan ke Bookmark' : 'Dihapus dari Bookmark',
          ),
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Map tetap full saat keyboard muncul
      body: Stack(
        children: [
          // LAYER 1: PETA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 15.0,
              onPositionChanged: _onMapPositionChanged, // Logic pointer geser
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.court_finder',
              ),
            ],
          ),

          // LAYER 2: POINTER TENGAH (Statis)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0), // Ujung pin pas di tengah
              child: Icon(
                Icons.location_pin,
                size: 50,
                color: Colors.redAccent,
              ),
            ),
          ),
          // LAYER 3: SEARCH BAR (Input Manual)
          Positioned(
            top:
                MediaQuery.of(context).padding.top + 70, // Di bawah tombol back
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchLocation(), // <--- TRIGGER PENCARIAN
                decoration: InputDecoration(
                  hintText: "Search Location...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.grey),
                    onPressed: _showFilterSheet,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // LAYER 4: TOMBOL GPS (Jika peta digeser)
          if (_isMapMovedByUser)
            Positioned(
              right: 16,
              bottom: MediaQuery.of(context).size.height * 0.45,
              child: FloatingActionButton.small(
                backgroundColor: Colors.white,
                onPressed: _getCurrentLocation,
                child: const Icon(Icons.my_location, color: Colors.green),
              ),
            ),

          // LAYER 5: BOTTOM SHEET (Hasil Pencarian)
          Positioned.fill(child: _buildBottomSheet()),

          // LAYER 6: LOADING INDICATOR
          if (_isLoading)
            Positioned(
              top: MediaQuery.of(context).padding.top + 130,
              left: 0,
              right: 0,
              child: const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            children: [
              // Handle Bar
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Tabs (All / Bookmark)
              Row(
                children: [
                  _buildTabItem("All", 0),
                  _buildTabItem("Bookmark", 1),
                ],
              ),
              const Divider(height: 1),
              // List Content
              Expanded(
                child: _courts.isEmpty && !_isLoading
                    ? Center(
                        child: Text(
                          "Tidak ada lapangan ditemukan",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _courts.length,
                        itemBuilder: (context, index) =>
                            _buildCourtCard(_courts[index]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          final request = context.read<CookieRequest>();

          // --- CEK LOGIN UNTUK TAB BOOKMARK ---
          if (index == 1 && !request.loggedIn) {
            _showLoginDialog(); // Panggil Popup
            return; // Stop, jangan ganti tab
          }
          // ------------------------------------

          setState(() {
            _selectedTab = index;
            _loadCourts();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 2,
                color: isSelected ? Colors.green : Colors.transparent,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.green : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourtCard(Court court) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return InkWell(
      onTap: () => _showCourtDetails(court),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // Padding disesuaikan
        // height: 110, // Hapus height fix agar flexibel mengikuti isi teks
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Rata atas
          children: [
            // --- BAGIAN 1: TEXT INFO (Tanpa Gambar) ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge Tipe Lapangan
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      court.courtTypeDisplay,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Nama Lapangan
                  Text(
                    court.name,
                    maxLines: 2, // Izinkan 2 baris kalau nama panjang
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Alamat
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          court.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Harga
                  Text(
                    "${formatCurrency.format(court.pricePerHour)} / jam",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // --- BAGIAN 2: TOMBOL BOOKMARK ---
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(
                  court.isBookmarked ? Icons.star : Icons.star_border,
                  color: court.isBookmarked ? Colors.amber : Colors.grey,
                  size: 28,
                ),
                onPressed: () => _toggleBookmark(court),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER FUNCTIONS ---

  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<CourtFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          FilterBottomSheet(currentFilter: _filter, provinces: _provinces),
    );

    if (result != null) {
      setState(() => _filter = result);
      _loadCourts();
    }
  }

  void _showCourtDetails(Court court) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Supaya bisa full screen/tinggi menyesuaikan konten
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75, // Mulai dari 75% layar
        minChildSize: 0.5,
        maxChildSize: 0.95, // Bisa ditarik sampai hampir full
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Column(
              children: [
                // --- HANDLE BAR (Garis kecil di atas) ---
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // --- CONTENT (Scrollable) ---
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    children: [
                      // 1. JUDUL & TYPE (Tengah)
                      Column(
                        children: [
                          Text(
                            court.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${court.courtTypeDisplay} Court",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            court.address,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // 2. CONTACT & PRICE (Kiri & Kanan)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Kiri: Contact
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Contact",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                court.phoneNumber.isNotEmpty
                                    ? court.phoneNumber
                                    : "-",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),

                          // Kanan: Price (Hijau Besar)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${formatCurrency.format(court.pricePerHour)}",
                                style: TextStyle(
                                  fontSize: 20, // Besar sesuai screenshot
                                  fontWeight: FontWeight.bold,
                                  color: const Color(
                                    0xFF698C6A,
                                  ), // Warna Hijau Web Django kamu
                                ),
                              ),
                              Text(
                                "/hour",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // 3. FACILITIES (Chips Hijau)
                      const Text(
                        "Facilities",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      court.facilities.isNotEmpty
                          ? Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: court.facilities.map((facility) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .green
                                        .shade50, // Background hijau muda
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    facility,
                                    style: TextStyle(
                                      color: Colors
                                          .green
                                          .shade800, // Teks hijau tua
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            )
                          : Text(
                              "No facilities listed.",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),

                      const SizedBox(height: 24),

                      // 4. DESCRIPTION
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        court.description != null &&
                                court.description!.isNotEmpty
                            ? court.description!
                            : "No description available.",
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5, // Line height biar enak dibaca
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.justify,
                      ),

                      // Extra space di bawah biar gak kepentok
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Login Diperlukan"),
        content: const Text(
          "Silakan login terlebih dahulu untuk menyimpan bookmark.",
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          // Tombol Cancel
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          // Tombol Login
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }
}
