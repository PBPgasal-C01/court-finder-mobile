
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:court_finder_mobile/models/game_scheduler/event_entry.dart';

class EventDetailPage extends StatefulWidget {
  final EventEntry event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late List<int> currentParticipants;
  
  // State to store the User ID once fetched
  int? _userId; 
  bool _isLoadingUser = true;

  // Variable to force UI state if server says "Already Joined"
  bool _forceJoinedState = false; 

  @override
  void initState() {
    super.initState();
    currentParticipants = List.from(widget.event.fields.participants);

    // Fetch User ID immediately after the widget mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = Provider.of<CookieRequest>(context, listen: false);
      _fetchUserId(request);
    });
  }

  // Separate function to fetch ID and update state
  Future<void> _fetchUserId(CookieRequest request) async {
    if (!request.loggedIn) {
      setState(() => _isLoadingUser = false);
      return;
    }

    // Adjust URL as needed (localhost vs 10.0.2.2)
    final url = "https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/auth/get-user"; 
    
    try {
      final response = await request.get(url);
      var id = response['id'];
      int? parsedId;

      if (id is int) {
        parsedId = id;
      } else if (id is String) {
        parsedId = int.tryParse(id);
      }

      if (mounted) {
        setState(() {
          _userId = parsedId;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      print("Error fetching user: $e");
      if (mounted) setState(() => _isLoadingUser = false);
    }
  }

  Future<void> _handleEventAction(CookieRequest request, bool isJoining) async {
    // Use the state variable _userId
    if (_userId == null) return;
    
    final endpoint = isJoining ? 'join-flutter' : 'leave-flutter';
    final url = "https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/event_list/$endpoint/${widget.event.pk}/";

    try {
      final response = await request.post(url, {});

      if (response['status'] == 'success') {
        setState(() {
          if (isJoining) {
            _forceJoinedState = true;
            if (!currentParticipants.contains(_userId)) {
              currentParticipants.add(_userId!);
            }
          } else {
            _forceJoinedState = false;
            currentParticipants.remove(_userId);
          }
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isJoining ? "Berhasil Join!" : "Berhasil Leave!"),
              backgroundColor: const Color(0xFF547254),
            ),
          );
        }
      } 
      else if (response['status'] == 'failed' || response['status'] == 'error') {
          String message = (response['message'] ?? "").toString().toLowerCase();

          if (message.contains("already joined")) {
             setState(() {
               _forceJoinedState = true;
               if (!currentParticipants.contains(_userId)) {
                   currentParticipants.add(_userId!); 
               }
             });
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text("Sinkronisasi: Anda sudah terdaftar.")),
               );
             }
          } 
          else if (message.contains("not in this event")) {
            setState(() {
              _forceJoinedState = false;
              currentParticipants.remove(_userId);
            });
          }
          else {
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(response['message'] ?? "Gagal")),
               );
             }
          }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error koneksi: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final fields = widget.event.fields;

    // LOGIC FIX: Determine if joined based on List OR Force flag
    bool isJoined = false;
    if (_userId != null) {
      isJoined = currentParticipants.contains(_userId) || _forceJoinedState;
    }

    String dateStr = "${fields.scheduledDate.day}-${fields.scheduledDate.month}-${fields.scheduledDate.year}";
    String timeStr = "${fields.startTime} - ${fields.endTime}";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER HIJAU ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 40),
              decoration: const BoxDecoration(
                color: Color(0xFF547254),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol Back
                  InkWell(
                    onTap: () => Navigator.pop(context, true), 
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text("BACK", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF547254))),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    fields.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3E4F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      fields.eventType.toUpperCase(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C5E9E)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildParticipantStack(),
                ],
              ),
            ),

            // --- KONTEN DETAIL ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(Icons.location_on_outlined, "Location", fields.location),
                  const SizedBox(height: 20),
                  _buildDetailItem(Icons.calendar_today_outlined, "Date", dateStr),
                  const SizedBox(height: 20),
                  _buildDetailItem(Icons.access_time, "Time", timeStr),
                  const SizedBox(height: 20),
                  _buildDetailItem(Icons.sports_basketball, "Sport Type", fields.sportType),
                  
                  const SizedBox(height: 30),
                  const Text("ABOUT EVENT", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  Text(fields.description, style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[700])),

                  const SizedBox(height: 40),

                  // --- TOMBOL ACTION ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                          if (!request.loggedIn) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silakan Login terlebih dahulu.")));
                            return;
                          }

                          if (currentParticipants.length >= 10 && !isJoined) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event Penuh!")));
                            return;
                          }

                          // Use the stored _userId
                          _handleEventAction(request, !isJoined);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: isJoined ? Colors.red.shade700 : const Color(0xFF547254), 
                          width: 2
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        currentParticipants.length >= 10 && !isJoined
                            ? "FULL BOOKED" 
                            : isJoined 
                                ? "LEAVE EVENT" 
                                : "JOIN EVENT",
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: isJoined ? Colors.red.shade700 : const Color(0xFF547254)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Keep your existing _buildParticipantStack and _buildDetailItem methods exactly as they were) ...
  Widget _buildParticipantStack() {
    int total = currentParticipants.length;
    const int maxFaces = 4; 
    bool showCounter = total > maxFaces;
    int renderCount = showCounter ? maxFaces + 1 : total;
    const double circleSize = 42.0;
    const double offset = 32.0; 
    // Fix: Handle case where renderCount is 0 to avoid negative width
    double stackWidth = (renderCount > 0) ? ((renderCount - 1) * offset) + circleSize : 0;

    return Row(
      children: [
        SizedBox(
          height: circleSize,
          width: stackWidth,
          child: Stack(
            children: List.generate(renderCount, (index) {
              bool isLastBubble = index == renderCount - 1;
              int remainingCount = total - maxFaces;
              return Positioned(
                left: index * offset,
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    color: Colors.grey[300], 
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF547254), width: 2), 
                  ),
                  child: Center(
                    child: (isLastBubble && showCounter)
                        ? Container(
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text("+$remainingCount", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF547254))),
                          )
                        : const Icon(Icons.person, size: 24, color: Colors.grey),
                  ),
                ),
              );
            }),
          ),
        ),
        if (total > 0) const SizedBox(width: 12), // Add conditional spacing
        Text("$total/10", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))
      ],
    );
  }
  
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }
}