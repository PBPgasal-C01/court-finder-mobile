import 'package:flutter/material.dart';
import 'package:court_finder_mobile/models/complain/complaint_entry.dart';
import 'package:court_finder_mobile/widgets/complain/complaint_card.dart';
import 'package:court_finder_mobile/screens/complain/complaint_entryform.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final Color primaryGreen = const Color(0xFF6B8E72);
  final Color darkGreen = const Color(0xFF5E7A5E);
  final Color textGreen = const Color(0xFF4A614A);
  final Color bgGreen = const Color(0xFFF2F7F2);

  // Fungsi Refresh Data (Dipanggil saat tarik ke bawah)
  Future<void> _refreshComplaints() async {
    // setState akan memicu build ulang, sehingga fetchComplaints jalan lagi
    setState(() {});
    // Delay sedikit agar loading spinner terlihat natural
    return Future.delayed(const Duration(seconds: 1));
  }

  Future<List<ComplaintEntry>> fetchComplaints(CookieRequest request) async {
    try {
      // 1. LOGIKA URL ADAPTIF
      String baseUrl;
      if (kIsWeb) {
        baseUrl = 'https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id';
      } else {
        baseUrl = 'http://10.0.2.2:8000';
      }

      // Pastikan URL path sesuai dengan Django (tanpa 't' di complain)
      var url = '$baseUrl/complain/json-flutter/';

      print("🔍 Fetching complaints from: $url");

      var response = await request.get(url);

      // 2. ERROR HANDLING
      if (response is Map && response.containsKey('status')) {
        if (response['status'] == 'error') {
          throw Exception(response['message'] ?? 'Unknown error');
        }
      }

      if (response is! List) {
        throw Exception(
          "Invalid response format. Expected List, got: ${response.runtimeType}",
        );
      }

      // 3. PARSING DATA
      List<ComplaintEntry> listComplaint = [];
      for (var d in response) {
        if (d != null) {
          try {
            // Fix URL Gambar untuk Android
            if (!kIsWeb && d['foto_url'] != null) {
              d['foto_url'] = d['foto_url']
                  .toString()
                  .replaceAll('127.0.0.1', '10.0.2.2')
                  .replaceAll('localhost', '10.0.2.2');
            }
            listComplaint.add(ComplaintEntry.fromJson(d));
          } catch (e) {
            print("⚠️ Error parsing complaint: $e");
          }
        }
      }

      return listComplaint;
    } catch (e) {
      print("❌ Fetch error: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // Kita gunakan Column agar Header tetap diam di atas
      body: Column(
        children: [
          // Header Statis (Tidak ikut scroll refresh)
          _buildHeader(request),

          // Area Konten yang bisa di-Refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshComplaints,
              child: FutureBuilder(
                future: fetchComplaints(request),
                builder: (context, AsyncSnapshot<List<ComplaintEntry>> snapshot) {
                  // State 1: Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // State 2: Error
                  else if (snapshot.hasError) {
                    // Bungkus dengan ListView agar bisa ditarik untuk refresh saat error
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                        Center(
                          child: Text(
                            "Error fetching data:\n${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  }
                  // State 3: Kosong
                  else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Bungkus dengan ListView agar bisa ditarik untuk refresh saat kosong
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
                        _buildEmptyState(),
                      ],
                    );
                  }
                  // State 4: Ada Data (Sukses)
                  else {
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      // Tambah 1 item untuk Judul "Report Archive"
                      itemCount: snapshot.data!.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Item pertama adalah Judul
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                            child: const Text(
                              "Report Archive",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F5940),
                              ),
                            ),
                          );
                        }
                        // Item selanjutnya adalah Data (index - 1)
                        final complaint = snapshot.data![index - 1];
                        return ComplaintCard(
                          complaint: complaint,
                          onTap: () {},

                          // LOGIKA DELETE YANG SINKRON
                          onDelete: () async {
                            // 1. Tampilkan dialog konfirmasi (Opsional tapi disarankan)
                            bool confirm =
                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Report?'),
                                    content: const Text(
                                      'Are you sure you want to delete this report?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;

                            if (confirm) {
                              // 2. Tentukan URL Adaptif
                              String baseUrl = kIsWeb
                                  ? 'http://127.0.0.1:8000'
                                  : 'http://10.0.2.2:8000';
                              var url =
                                  '$baseUrl/complain/delete-flutter/${complaint.id}/'; // Gunakan PK/ID dari complaint

                              // 3. Kirim Request POST
                              try {
                                final response = await request.post(
                                  url,
                                  {},
                                ); // Body kosong tidak apa-apa

                                // 4. Cek Hasil
                                if (response['status'] == 'success') {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Report is successfully deleted",
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  // 5. REFRESH LIST OTOMATIS
                                  _refreshComplaints();
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response['message']),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                print("Error deleting: $e");
                              }
                            }
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(CookieRequest request) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 25),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.sort, color: Colors.white, size: 28),
              // Ganti Image Network yang error dengan Icon Statis
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withOpacity(0.2),
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Report System",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Report the issue around you",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddComplaintPage(),
                  ),
                );
                // Jika kembali dari halaman tambah dengan sukses (true), refresh data
                if (mounted && result == true) {
                  _refreshComplaints();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: bgGreen,
                foregroundColor: textGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                "+ Add Report",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'static/images/logo_court_finder.png',
          height: 220,
          fit: BoxFit.contain,
          color: primaryGreen.withOpacity(0.4),
          colorBlendMode: BlendMode.srcIn,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.image_not_supported,
            size: 100,
            color: Colors.grey[300],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "You never submitted a report",
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          "Pull down to refresh", // Petunjuk user
          style: TextStyle(color: Colors.grey[300], fontSize: 12),
        ),
      ],
    );
  }
}
