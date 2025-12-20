import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../models/manage-court/court.dart';
import '../../models/user_entry.dart';
import '../../services/manage_court_service.dart';
import 'add_court_screen.dart';
import 'edit_court_screen.dart';
import 'court_detail_screen.dart';

class ManageCourtScreen extends StatefulWidget {
  final UserEntry user;

  const ManageCourtScreen({super.key, required this.user});

  @override
  State<ManageCourtScreen> createState() => _ManageCourtScreenState();
}

class _ManageCourtScreenState extends State<ManageCourtScreen> {
  late Future<List<Court>> _courtsFuture;
  final ManageCourtService _service = ManageCourtService();
  final Color primaryGreen = const Color(0xFF6B8E72);

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
    return Scaffold(
      backgroundColor: Colors.white,

      // TOMBOL ADD DIPINDAH KE FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCourtScreen(),
            ),
          );
          _refreshCourts();
        },
        label: const Text("Add Court"),
        icon: const Icon(Icons.add),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),

      body: FutureBuilder<List<Court>>(
        future: _courtsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryGreen));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Failed to load data: ${snapshot.error}'));
          }

          final courts = snapshot.data ?? [];

          if (courts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 80, color: primaryGreen.withOpacity(0.5)),
                  const SizedBox(height: 20),
                  const Text(
                    "Don't have any Court",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshCourts(),
            color: primaryGreen,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: courts.length,
              itemBuilder: (context, index) {
                final court = courts[index];

                final String baseUrl = kIsWeb
                    ? 'https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id'
                    : 'http://10.0.2.2:8000';

                String imageUrl = "";
                if (court.photoUrl != null && court.photoUrl!.isNotEmpty) {
                  imageUrl = court.photoUrl!.startsWith('http')
                      ? court.photoUrl!
                      : '$baseUrl${court.photoUrl}';
                }

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              court.name.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            Text(court.courtType, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                          ],
                        ),
                      ),

                      Expanded(
                        child: (imageUrl.isNotEmpty)
                            ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey[200]))
                            : Container(color: Colors.grey[200], child: const Icon(Icons.sports_soccer, color: Colors.grey)),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(court.address, style: const TextStyle(fontSize: 10), maxLines: 2),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourtDetailScreen(court: court))),
                              child: const Text('DETAIL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => _showDeleteDialog(context, court),
                                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () async {
                                    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditCourtScreen(court: court)));
                                    _refreshCourts();
                                  },
                                  child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                ),
                              ],
                            )
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
    );
  }

  void _showDeleteDialog(BuildContext context, Court court) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Delete Court"),
          content: Text("Are you sure you want to delete '${court.name}'?"),
          actions: <Widget>[
            TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(dialogContext).pop()),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final request = context.read<CookieRequest>();
                await _service.deleteCourt(request, court.pk);
                _refreshCourts();
              },
            ),
          ],
        );
      },
    );
  }
}