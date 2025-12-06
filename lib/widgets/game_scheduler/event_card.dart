import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:court_finder_mobile/models/game_scheduler/event_entry.dart';
import 'package:court_finder_mobile/models/user_entry.dart';
import 'package:court_finder_mobile/screens/game_scheduler/event_detail_page.dart';
import 'package:court_finder_mobile/screens/game_scheduler/game_scheduler_form.dart';

class EventCard extends StatelessWidget {
  final EventEntry event;
  final bool isLoggedIn;
  final bool showActions;
  final VoidCallback? onRefresh;
  final UserEntry? user;
  final int? currentUserId;

  const EventCard({
    super.key,
    required this.event,
    required this.isLoggedIn,
    required this.showActions,
    this.onRefresh,
    this.user,
    this.currentUserId,
  });

  Future<void> _handleDelete(BuildContext context, CookieRequest request) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Event"),
        content: const Text("Are you sure you want to delete this event?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      // Pastikan URL ini benar sesuai environment Anda (localhost/127.0.0.1)
      final url = "http://127.0.0.1:8000/event_list/delete-flutter/${event.pk}/";
      try {
        final response = await request.post(url, {});
        if (response['status'] == 'success') {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event deleted successfully!")));
           onRefresh?.call();
        } else {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: ${response['message']}")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final fields = event.fields;
    bool isPublic = fields.eventType.toLowerCase() == "public";

    Color badgeColor = isPublic ? const Color(0xFFD3E4F8) : const Color(0xFFF8D3D3);
    Color badgeTextColor = isPublic ? const Color(0xFF2C5E9E) : const Color(0xFF9E2C2C);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN ATAS: BADGE ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    fields.eventType.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeTextColor),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF547254), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    fields.sportType,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            Text(fields.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            
            const SizedBox(height: 8),
            
            _buildInfoRow(Icons.location_on_outlined, fields.location),
            const SizedBox(height: 4),
            _buildInfoRow(Icons.calendar_today_outlined, "${fields.scheduledDate.day}-${fields.scheduledDate.month}-${fields.scheduledDate.year}"),
            const SizedBox(height: 4),
            _buildInfoRow(Icons.access_time, "${fields.startTime.substring(0,5)} - ${fields.endTime.substring(0,5)}"),
            
            const SizedBox(height: 12),
            _buildParticipantStack(fields.participants),
            
            const SizedBox(height: 16), // Jarak fix
            Divider(color: Colors.grey[200], height: 1), 
            const SizedBox(height: 12),

            // ============================================================
            // LOGIKA TAMPILAN BAWAH (FIX REFRESH & WRAP)
            // ============================================================
            
            if (isLoggedIn && showActions)
              // --- TAMPILAN "MY EVENTS" ---
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8.0, 
                  runSpacing: 8.0,
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GameSchedulerFormPage(event: event)),
                        );
                        // Refresh jika ada perubahan (Edit)
                        if (result == true) onRefresh?.call();
                      },
                      child: _actionButton("Edit", const Color(0xFFFFE9CC), const Color(0xFFA16E27)),
                    ),
                    InkWell(
                      onTap: () => _handleDelete(context, request),
                      child: _actionButton("Delete", const Color(0xFFFFD9D1), const Color(0xFF8B483A)),
                    ),
                    _buildDetailButton(context),
                  ],
                ),
              )
            else 
              // --- TAMPILAN "ALL EVENTS" ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: (fields.creatorPhoto.isNotEmpty) ? NetworkImage(fields.creatorPhoto) : null,
                          child: (fields.creatorPhoto.isEmpty) ? const Icon(Icons.person, size: 12, color: Colors.grey) : null,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            fields.creatorUsername, 
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDetailButton(context),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventDetailPage(event: event)),
        );
        
        onRefresh?.call(); 
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
           color: Colors.white, 
           border: Border.all(color: const Color(0xFF547254)),
           borderRadius: BorderRadius.circular(8)
        ),
        child: const Text("DETAIL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF547254))),
      ),
    );
  }

  Widget _actionButton(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textCol)),
    );
  }

  Widget _buildParticipantStack(List<int> participants) {
    int total = participants.length;
    
    // ATURAN: Maksimal lingkaran yang berjejer adalah 5
    // (4 Wajah + 1 Angka Sisa) atau (5 Wajah kalau pas 5 orang)
    const int maxCircles = 5; 
    
    // Tentukan berapa lingkaran yang harus digambar
    // Kalau total 3 -> gambar 3. Kalau total 10 -> gambar 5 (mentok).
    int renderCount = total > maxCircles ? maxCircles : total;

    const double circleSize = 34.0;
    const double offset = 22.0;
    
    // Hitung lebar Stack biar pas (tidak kepotong)
    // Rumus: (JumlahLingkaran - 1) * Jarak + LebarSatuLingkaran
    double stackWidth = (renderCount > 0) 
        ? ((renderCount - 1) * offset) + circleSize 
        : 0;

    return Row(
      children: [
        SizedBox(
          width: stackWidth,
          height: circleSize,
          child: Stack(
            children: List.generate(renderCount, (index) {
              // Cek apakah ini lingkaran paling terakhir yang digambar?
              bool isLastBubble = index == maxCircles - 1;
              
              // Cek apakah total aslinya melebihi kapasitas?
              bool isOverflow = total > maxCircles;

              // Hitung sisanya
              // Contoh: Total 6. Max 5. 
              // Kita gambar 4 wajah. Sisa = 6 - 4 = 2.
              int remaining = total - (maxCircles - 1);

              return Positioned(
                left: index * offset,
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Border putih biar efek tumpuknya rapi
                    border: Border.all(color: Colors.white, width: 2), 
                    // Kalau ini bubble terakhir DAN ada sisa -> warnanya beda
                    color: (isLastBubble && isOverflow) 
                        ? const Color(0xFFE0E0E0) 
                        : Colors.grey[300],
                  ),
                  child: Center(
                    child: (isLastBubble && isOverflow)
                        ? Text(
                            "+$remaining", // Tampilkan sisa (+2)
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F6E48), // Warna hijau teks
                            ),
                          )
                        // TODO: Kalau JSON sudah ada foto, ganti Icon ini dengan Image.network
                        : const Icon(Icons.person, size: 20, color: Colors.grey),
                  ),
                ),
              );
            }),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Teks Total di sebelah kanan (contoh: 6/10)
        Text(
          "$total/10",
          style: const TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.bold, 
            color: Colors.grey
          ),
        )
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(child: Text(text, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[800]))),
      ],
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 4;
    double dashSpace = 4;
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    var path = Path();
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));

    Path dashPath = Path();
    double distance = 0.0;
    
    for (var pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}