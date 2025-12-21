import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:court_finder_mobile/models/game_scheduler/event_entry.dart';
import 'package:court_finder_mobile/widgets/game_scheduler/event_card.dart';
import 'package:court_finder_mobile/screens/game_scheduler/game_scheduler_form.dart';
import 'package:court_finder_mobile/models/user_entry.dart';

class GameSchedulerPage extends StatefulWidget {
  final UserEntry? user;
  const GameSchedulerPage({super.key, this.user});

  @override
  State<GameSchedulerPage> createState() => _GameSchedulerPageState();
}

class _GameSchedulerPageState extends State<GameSchedulerPage> {
  String _activeType = 'public';
  bool _showMyEventsOnly = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSport;
  final Color primaryGreen = const Color(0xFF6B8E72);

  final Map<String, String> _sportOptions = {
    'basketball': 'Basketball', 'futsal': 'Futsal', 'soccer': 'Soccer',
    'badminton': 'Badminton', 'tennis': 'Tennis', 'baseball': 'Baseball',
    'volleyball': 'Volleyball', 'padel': 'Padel', 'golf': 'Golf',
    'football': 'Football', 'softball': 'Softball', 'table_tennis': 'Table Tennis',
  };

  Future<List<EventEntry>> fetchEvents(CookieRequest request) async {
    String url = 'https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/event_list/json/';
    if (_showMyEventsOnly) url += '?only_me=true';

    final response = await request.get(url);
    List<EventEntry> listEvents = [];
    for (var d in response) {
      if (d != null) listEvents.add(EventEntry.fromJson(d));
    }

    return listEvents.where((element) {
      bool matchType = element.fields.eventType.toLowerCase() == _activeType;
      bool matchSearch = _searchQuery.isEmpty || element.fields.title.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchSport = _selectedSport == null || element.fields.sportType.toLowerCase() == _selectedSport;
      return matchType && matchSearch && matchSport;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: request.loggedIn
          ? FloatingActionButton(
        heroTag: null,
        backgroundColor: primaryGreen,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const GameSchedulerFormPage()));
          setState((){});
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,

      body: Column(
        children: [
          // FILTER AREA (Pengganti Header Hijau)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Baris 1: Search & Public Button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                        child: TextField(
                          controller: _searchController,
                          textAlignVertical: TextAlignVertical.center,
                          onSubmitted: (value) => setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: "Search event...",
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildSmallButton("PUBLIC", _activeType == 'public' ? primaryGreen : Colors.grey.shade300, () {
                      setState(() => _activeType = 'public');
                    }, _activeType == 'public'),
                  ],
                ),
                const SizedBox(height: 10),

                // Baris 2: Dropdown & Private Button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSport,
                            hint: const Text("All Sports", style: TextStyle(color: Colors.white, fontSize: 13)),
                            dropdownColor: primaryGreen,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            onChanged: (val) => setState(() => _selectedSport = val),
                            items: [
                              const DropdownMenuItem(value: null, child: Text("All Sports")),
                              ..._sportOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildSmallButton("PRIVATE", _activeType == 'private' ? primaryGreen : Colors.grey.shade300, () {
                      setState(() => _activeType = 'private');
                    }, _activeType == 'private'),
                  ],
                ),
              ],
            ),
          ),

          // Tabs My Event
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterButton("ALL EVENTS", !_showMyEventsOnly, () => setState(() => _showMyEventsOnly = false)),
              const SizedBox(width: 15),
              _buildFilterButton("MY EVENTS", _showMyEventsOnly, () => setState(() => _showMyEventsOnly = true)),
            ],
          ),

          const SizedBox(height: 10),

          // LIST DATA
          Expanded(
            child: FutureBuilder(
                future: fetchEvents(request),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No events found.", style: TextStyle(color: Colors.grey)));
                  }
                  return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.58,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) {
                        return EventCard(
                          event: snapshot.data![index],
                          isLoggedIn: request.loggedIn,
                          showActions: _showMyEventsOnly,
                          user: widget.user,
                          currentUserId: request.loggedIn ? request.jsonData['id'] : null,
                          onRefresh: () => setState((){}),
                        );
                      }
                  );
                }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(String text, Color bgColor, VoidCallback onTap, bool isActive) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 80, height: 40, alignment: Alignment.center,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.black54)),
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryGreen),
        ),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.white : primaryGreen)),
      ),
    );
  }
}