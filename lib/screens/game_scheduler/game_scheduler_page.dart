import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// --- IMPORTS MODEL & WIDGETS ---
import 'package:court_finder_mobile/models/game_scheduler/event_entry.dart';
import 'package:court_finder_mobile/widgets/game_scheduler/event_card.dart';
import 'package:court_finder_mobile/screens/game_scheduler/game_scheduler_form.dart';

// --- IMPORT UNTUK PROFIL & NAVIGASI ---
import 'package:court_finder_mobile/models/user_entry.dart'; 
import 'package:court_finder_mobile/screens/user_profile.dart'; 
import 'package:court_finder_mobile/main.dart'; 

class GameSchedulerPage extends StatefulWidget {
  final UserEntry? user; 
  const GameSchedulerPage({super.key, this.user});

  @override
  State<GameSchedulerPage> createState() => _GameSchedulerPageState();
}

class _GameSchedulerPageState extends State<GameSchedulerPage> {
  // --- VARIABLE STATE ---
  String _activeType = 'public'; 
  bool _showMyEventsOnly = false; 
  
  // 1. Variable Search
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // 2. Variable Sport Filter
  String? _selectedSport; 

  final Map<String, String> _sportOptions = {
    'basketball': 'Basketball',
    'futsal': 'Futsal',
    'soccer': 'Soccer',
    'badminton': 'Badminton',
    'tennis': 'Tennis',
    'baseball': 'Baseball',
    'volleyball': 'Volleyball',
    'padel': 'Padel',
    'golf': 'Golf',
    'football': 'Football',
    'softball': 'Softball',
    'table_tennis': 'Table Tennis',
  };

  Future<List<EventEntry>> fetchEvents(CookieRequest request) async {
    // Gunakan 127.0.0.1
    String url = 'https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/event_list/json/';

    if (_showMyEventsOnly) {
      url += '?only_me=true';
    }

    final response = await request.get(url);

    List<EventEntry> listEvents = [];
    for (var d in response) {
      if (d != null) {
        listEvents.add(EventEntry.fromJson(d));
      }
    }

    // --- LOGIKA FILTERING ---
    List<EventEntry> filteredEvents = listEvents.where((element) {
      bool matchType = element.fields.eventType.toLowerCase() == _activeType;
      
      bool matchSearch = true;
      if (_searchQuery.isNotEmpty) {
        matchSearch = element.fields.title.toLowerCase().contains(_searchQuery.toLowerCase());
      }

      bool matchSport = true;
      if (_selectedSport != null) {
        matchSport = element.fields.sportType.toLowerCase() == _selectedSport;
      }

      return matchType && matchSearch && matchSport;
    }).toList();

    return filteredEvents;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final Color lightGreen = const Color(0xFF6B8E72); 

    return Scaffold(
      backgroundColor: Colors.white,
      
      body: Column(
        children: [
          // --- HEADER HIJAU ---
          Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 25),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Game Scheduler", 
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    )
                  ),
                ),
                const SizedBox(height: 20),

                // ===============================================
                // FILTER SECTION
                // ===============================================
                
                // BARIS 1: Search Bar (Kiri) & Tombol Public (Kanan)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: TextField(
                          controller: _searchController,
                          textAlignVertical: TextAlignVertical.center,
                          onSubmitted: (value) {
                            setState(() {
                              _searchQuery = value; 
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Search event...",
                            prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.arrow_forward, color: Color(0xFF6B8E72), size: 20),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = _searchController.text;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildSmallButton("PUBLIC", _activeType == 'public' ? const Color(0xFF5D8190) : Colors.white, () {
                      setState(() => _activeType = 'public');
                    }), 
                  ],
                ),
                
                const SizedBox(height: 10),

                // BARIS 2: Sport Dropdown (Kiri) & Tombol Private (Kanan)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF547254), // Hijau Tua
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSport,
                            hint: const Text("All Sports", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            dropdownColor: const Color(0xFF547254),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSport = newValue; 
                              });
                            },
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text("All Sports"),
                              ),
                              ..._sportOptions.entries.map((entry) {
                                return DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Text(entry.value),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildSmallButton("PRIVATE", _activeType == 'private' ? const Color(0xFF5D8190) : Colors.white, () {
                      setState(() => _activeType = 'private');
                    }),
                  ],
                ),
                // ===============================================
              ],
            ),
          ),

          const SizedBox(height: 15),

          // FILTER TABS (ALL / MY EVENTS)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterButton("ALL EVENTS", !_showMyEventsOnly, () {
                setState(() => _showMyEventsOnly = false);
              }),
              const SizedBox(width: 15),
              _buildFilterButton("MY EVENTS", _showMyEventsOnly, () {
                setState(() => _showMyEventsOnly = true);
              }),
            ],
          ),

          // GRID DATA
          Expanded(
            child: FutureBuilder(
              future: fetchEvents(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // MENGGUNAKAN LOGO APLIKASI
                        Image.asset(
                          'static/images/cflogo2.png', // Pastikan path ini benar di pubspec.yaml
                          width: 130, 
                          height: 130,
                          fit: BoxFit.contain,
                          // Fallback jika gambar tidak ditemukan
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.event_busy, size: 100, color: Colors.grey);
                          },
                        ),
                        const SizedBox(height: 20),
                        // Pesan kosong yang informatif
                        Text(
                          _searchQuery.isNotEmpty
                              ? "There are no events found for '$_searchQuery'"
                              : "No ${_activeType} events available.",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                } else {
                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85, 
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) {
                      int? myId;
                      try { myId = request.jsonData['id']; } catch (_) { myId = null; }
                      
                      return EventCard(
                        event: snapshot.data![index],
                        isLoggedIn: request.loggedIn,
                        showActions: _showMyEventsOnly,
                        user: widget.user, 
                        currentUserId: myId,
                        onRefresh: () {
                          setState(() {}); 
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: request.loggedIn 
        ? FloatingActionButton(
            backgroundColor: const Color(0xFF6B8E72),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GameSchedulerFormPage()),
              );
              if (result == true) {
                setState(() {});
              }
            },
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          )
        : null,
    );
  }

  Widget _buildSmallButton(String text, Color colorParam, VoidCallback onTap) {
    bool isWhite = colorParam == Colors.white;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 80, 
        alignment: Alignment.center,
        height: 40,
        decoration: BoxDecoration(
          color: colorParam, 
          borderRadius: BorderRadius.circular(12),
          border: isWhite ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isWhite ? Colors.black : Colors.white)),
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3F6E48) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF3F6E48)),
        ),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.white : const Color(0xFF3F6E48))),
      ),
    );
  }
}