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
      final url = "https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/event_list/delete-flutter/${event.pk}/";
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
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Penting agar tidak memaksa tinggi
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
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF547254), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        fields.sportType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // JUDUL
            Text(
              fields.title, 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.2)
            ),
            
            const SizedBox(height: 8),
            
            // INFO ROW
            _buildInfoRow(Icons.location_on_outlined, fields.location),
            const SizedBox(height: 4),
            _buildInfoRow(Icons.calendar_today_outlined, "${fields.scheduledDate.day}-${fields.scheduledDate.month}-${fields.scheduledDate.year}"),
            const SizedBox(height: 4),
            
            // Jam (Safe Substring)
            Builder(builder: (context) {
              String s = fields.startTime;
              String e = fields.endTime;
              if (s.length > 5) s = s.substring(0, 5);
              if (e.length > 5) e = e.substring(0, 5);
              return _buildInfoRow(Icons.access_time, "$s - $e");
            }),
            
            const SizedBox(height: 10),
            
            // --- PARTICIPANT STACK (FIXED) ---
            _buildParticipantStack(fields.participants),
            
            const Spacer(), // Mendorong bagian bawah agar nempel di dasar
            const SizedBox(height: 8),
            Divider(color: Colors.grey[200], height: 1), 
            const SizedBox(height: 8),
            
            if (isLoggedIn && showActions)
              // --- LAYOUT MY EVENTS: Susun Vertikal ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Baris 1: Edit & Delete (Bagi 2 kolom)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GameSchedulerFormPage(event: event)),
                            );
                            if (result == true) onRefresh?.call();
                          },
                          child: _actionButton("Edit", const Color(0xFFFFE9CC), const Color(0xFFA16E27)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => _handleDelete(context, request),
                          child: _actionButton("Delete", const Color(0xFFFFD9D1), const Color(0xFF8B483A)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Baris 2: Detail (Full Width)
                  InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EventDetailPage(event: event)),
                      );
                      onRefresh?.call(); 
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        border: Border.all(color: const Color(0xFF547254)),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: const Text("DETAIL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF547254))),
                    ),
                  )
                ],
              )
            else 
              // --- LAYOUT ALL EVENTS ---
              Row(
                children: [
                  // Profile Section
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: (fields.creatorPhoto.isNotEmpty) ? NetworkImage(fields.creatorPhoto) : null,
                    child: (fields.creatorPhoto.isEmpty) ? const Icon(Icons.person, size: 12, color: Colors.grey) : null,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      fields.creatorUsername, 
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, 
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                    ),
                  ),
                  
                  // Tombol Detail di Kanan
                  InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EventDetailPage(event: event)),
                      );
                      onRefresh?.call(); 
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF547254), 
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: const Text("DETAIL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8), // Padding sedikit diperbesar
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textCol)),
    );
  }

  Widget _buildParticipantStack(List<int> participants) {
    int total = participants.length;
    
    const int maxCircles = 4; 
    
    int renderCount = total > maxCircles ? maxCircles : total;
    
    // Ukuran diperkecil sedikit agar muat
    const double circleSize = 26.0; 
    const double offset = 18.0; 
    
    // Kalkulasi lebar stack
    double stackWidth = (renderCount > 0) ? ((renderCount - 1) * offset) + circleSize : 0;

    return Row(
      children: [
        // Gunakan Container dengan constraints width max
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140), // Safety net
          child: SizedBox(
            width: stackWidth,
            height: circleSize,
            child: Stack(
              children: List.generate(renderCount, (index) {
                bool isLastBubble = index == maxCircles - 1;
                bool isOverflow = total > maxCircles;
                int remaining = total - (maxCircles - 1);

                return Positioned(
                  left: index * offset,
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2), 
                      color: (isLastBubble && isOverflow) ? const Color(0xFFE0E0E0) : Colors.grey[300],
                    ),
                    child: Center(
                      child: (isLastBubble && isOverflow)
                          ? Text("+$remaining", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF3F6E48)))
                          : const Icon(Icons.person, size: 14, color: Colors.grey),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text("$total/10", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey[800]))),
      ],
    );
  }
}