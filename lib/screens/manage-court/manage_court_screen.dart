
// lib/screens/manage_court_screen.dart

import 'package:flutter/material.dart';
import '../../models/manage-court/court.dart';
import '../../services/manage_court_service.dart';

class ManageCourtScreen extends StatefulWidget {
  final String sessionCookie;
  
  const ManageCourtScreen({super.key, required this.sessionCookie});

  @override
  State<ManageCourtScreen> createState() => _ManageCourtScreenState();
}

class _ManageCourtScreenState extends State<ManageCourtScreen> {
  late Future<List<Court>> _courtsFuture;
  final ManageCourtService _service = ManageCourtService();

  @override
  void initState() {
    super.initState();
    _courtsFuture = _service.fetchMyCourts(widget.sessionCookie);
  }

  void _refreshCourts() {
    setState(() {
      _courtsFuture = _service.fetchMyCourts(widget.sessionCookie);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF6B8E72);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- HEADER HIJAU (Sama seperti Game Scheduler) ---
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar (Menu & Profile)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Title (Centered)
                const Center(
                  child: Text(
                    "Manage Your Court",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Search Bar & Add Button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: "Search Court",
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Add New Button (Konsisten dengan style)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        onTap: () {
                          // TODO: Navigasi ke AddCourtScreen
                          print('Navigasi ke halaman Tambah Lapangan');
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.add, color: Color(0xFF6B8E72), size: 20),
                            SizedBox(width: 4),
                            Text(
                              "ADD",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B8E72),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- CONTENT SECTION ---
          Expanded(
            child: FutureBuilder<List<Court>>(
              future: _courtsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: primaryGreen,
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load data',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshCourts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Empty State Logo (Konsisten dengan Game Scheduler)
                        Image.asset(
                          'static/images/cflogo2.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback jika image tidak ada
                            return Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: primaryGreen.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.sports_soccer,
                                size: 50,
                                color: primaryGreen,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "You don't have any court yet.",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Click ADD to create your first court.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Data berhasil dimuat - Tampilkan Grid Cards
                final courts = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshCourts();
                  },
                  color: primaryGreen,
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: courts.length,
                    itemBuilder: (context, index) {
                      final court = courts[index];
                      
                      // Logika URL Gambar
                      String baseUrl = 'http://10.0.2.2:8000';
                      String imageUrl;
                      if (court.photoUrl != null) {
                        if (court.photoUrl!.startsWith('http')) {
                          imageUrl = court.photoUrl!;
                        } else {
                          imageUrl = '$baseUrl${court.photoUrl}';
                        }
                      } else {
                        imageUrl = "";
                      }

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () {
                            // TODO: Navigate to detail
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Detail ${court.name}"),
                                backgroundColor: primaryGreen,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Image Section
                              Expanded(
                                flex: 3,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: (court.photoUrl != null && court.photoUrl!.isNotEmpty)
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => 
                                          Container(
                                            color: primaryGreen.withOpacity(0.1),
                                            child: Icon(
                                              Icons.sports_soccer,
                                              size: 50,
                                              color: primaryGreen,
                                            ),
                                          ),
                                      )
                                    : Container(
                                        color: primaryGreen.withOpacity(0.1),
                                        child: Icon(
                                          Icons.sports_soccer,
                                          size: 50,
                                          color: primaryGreen,
                                        ),
                                      ),
                                ),
                              ),
                              // Info Section
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            court.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            court.courtType,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Rp ${court.pricePerHour.toStringAsFixed(0)}/jam',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: primaryGreen,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Action Buttons
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          // Edit Button
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20),
                                            color: Colors.blue,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              // TODO: Navigate to edit
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Edit feature coming soon")),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          // Delete Button
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20),
                                            color: Colors.red,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              _showDeleteDialog(context, court, primaryGreen);
                                            },
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
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Court court, Color primaryGreen) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Delete Court"),
          content: Text("Are you sure you want to delete ${court.name}?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                
                // TODO: Panggil Service Delete
                // await _service.deleteCourt(court.pk, widget.sessionCookie);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${court.name} deleted successfully (Simulation)"),
                    backgroundColor: primaryGreen,
                  ),
                );
                
                _refreshCourts();
              },
            ),
          ],
        );
      },
    );
  }
}