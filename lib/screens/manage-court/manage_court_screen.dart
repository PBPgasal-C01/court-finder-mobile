// lib/screens/manage-court/manage_court_screen.dart

import 'package:flutter/foundation.dart' show kIsWeb; // TAMBAHAN PENTING
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../models/manage-court/court.dart';
import '../../models/user_entry.dart';
import '../../services/manage_court_service.dart';
import '../../widgets/left_drawer.dart';
import 'add_court_screen.dart';
import 'edit_court_screen.dart';
import 'court_detail_screen.dart';

class ManageCourtScreen extends StatefulWidget {
  final UserEntry user;
  
  const ManageCourtScreen({
    super.key,
    required this.user,
  });

  @override
  State<ManageCourtScreen> createState() => _ManageCourtScreenState();
}

class _ManageCourtScreenState extends State<ManageCourtScreen> {
  late Future<List<Court>> _courtsFuture;
  final ManageCourtService _service = ManageCourtService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourts();
    });
  }

  void _loadCourts() {
    final request = context.read<CookieRequest>();
    setState(() {
      _courtsFuture = _service.fetchMyCourts(request);
    });
  }

  void _refreshCourts() {
    setState(() {
      _loadCourts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF6B8E72);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: LeftDrawer(user: widget.user),
      body: Column(
        children: [
          // --- HEADER HIJAU ---
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
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: widget.user.photo != null
                        ? ClipOval(
                            child: Image.network(
                              widget.user.photo!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, color: Colors.white),
                            ),
                          )
                        : const Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Title & Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    const Text(
                      "Manage\nYour\nCourt",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    // Add New Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddCourtScreen()),
                          );
                          _refreshCourts();
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.add, color: Color(0xFF6B8E72), size: 20),
                            SizedBox(width: 4),
                            Text(
                              "Add New",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B8E72),
                                fontSize: 14,
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
                
                final courts = snapshot.data ?? [];
                
                if (courts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Empty State Logo (Ganti Icon biar aman)
                        Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on,
                              size: 80,
                              color: primaryGreen,
                            ),
                          ),
                        const SizedBox(height: 20),
                        const Text(
                          "Don't have any Court",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Click ADD NEW",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Tampilkan Grid Cards
                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshCourts();
                  },
                  color: primaryGreen,
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: courts.length,
                    itemBuilder: (context, index) {
                      final court = courts[index];
                      
                      // --- PERBAIKAN 1: LOGIKA URL GAMBAR (WEB VS ANDROID) ---
                      // Jika Web (Chrome), pakai localhost. Jika Android, pakai 10.0.2.2.
                      final String baseUrl = kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';
                      
                      String imageUrl;
                      if (court.photoUrl != null && court.photoUrl!.isNotEmpty) {
                        if (court.photoUrl!.startsWith('http')) {
                          imageUrl = court.photoUrl!;
                        } else {
                          imageUrl = '$baseUrl${court.photoUrl}';
                        }
                      } else {
                        imageUrl = "";
                      }

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header dengan nama dan type
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    court.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    court.courtType,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Tanggal dan ID
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year.toString().substring(2)}',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '${court.pricePerHour.toStringAsFixed(0)}H',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Image Section
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: (imageUrl.isNotEmpty)
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => 
                                        Container(
                                          color: Colors.grey.shade200,
                                          child: Icon(
                                            Icons.sports_soccer,
                                            size: 40,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                    )
                                  : Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.sports_soccer,
                                        size: 40,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                              ),
                            ),

                            // Alamat
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Text(
                                court.address,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Action Buttons Section
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // See Detail Button
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CourtDetailScreen(court: court),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.black, width: 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      child: const Text(
                                        'SEE DETAIL',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 8),
                                  
                                  // --- PERBAIKAN 2: GANTI GAMBAR SAMPAH JADI ICON ---
                                  // Biar ga error 404 karena file 'transh.png' ga ketemu
                                  InkWell(
                                    onTap: () {
                                      _showDeleteDialog(context, court, primaryGreen);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1), // Background merah muda dikit
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline, // Pakai Icon bawaan Flutter
                                        color: Colors.red, 
                                        size: 20
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 8),

                                  // Edit Button (Ganti jadi Icon juga biar seragam & aman)
                                  InkWell(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditCourtScreen(court: court),
                                        ),
                                      );
                                      _refreshCourts();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
          content: Text("Are you sure you want to delete '${court.name}'?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final request = context.read<CookieRequest>();
                
                try {
                    final success = await _service.deleteCourt(request, court.pk);
                    
                    if (context.mounted) { 
                        if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("${court.name} deleted successfully!"),
                                    backgroundColor: primaryGreen,
                                ),
                            );
                            _refreshCourts();
                        } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Failed to delete court. Please try again."),
                                    backgroundColor: Colors.red,
                                ),
                            );
                        }
                    }
                } catch (e) {
                    if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                        );
                    }
                }
              },
            ),
          ],
        );
      },
    );
  }
}