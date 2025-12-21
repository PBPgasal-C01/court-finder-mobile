import 'package:court_finder_mobile/screens/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '/models/user_entry.dart';
import '../models/court-finder/court.dart' as cf;
import '../models/court-finder/court_filter.dart';
import '../services/court-finder/api_service.dart';
import '../widgets/left_drawer.dart';

class MyHomePage extends StatefulWidget {
  final UserEntry user;
  const MyHomePage({super.key, required this.user});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late UserEntry user;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ApiService _courtService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  Future<List<cf.Court>>? _courtsFuture;
  final List<String> _selectedCourtTypes = [];

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Init future once we have access to Provider context.
    _courtsFuture ??= _courtService.searchCourts(
      context.read<CookieRequest>(),
      CourtFilter(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reloadCourts() {
    setState(() {
      _courtsFuture = _courtService.searchCourts(
        context.read<CookieRequest>(),
        CourtFilter(courtTypes: List<String>.from(_selectedCourtTypes)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: LeftDrawer(user: user),
      // ============================ BODY ============================
      body: Column(
        children: [
          _buildHeader(context, request),
          const SizedBox(height: 20),
          _buildPopularSports(),
          const SizedBox(height: 20),
          Expanded(child: _buildCourtList(request)),
        ],
      ),
    );
  }

  // ===================== HEADER SECTION ============================
  Widget _buildHeader(BuildContext context, CookieRequest request) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8CB685), Color(0xFF6CA06E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= TOP BAR =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfilePage(user: user)),
                  );
                },
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF6B8E72),
                  child: user.photo != null
                      ? ClipOval(
                          child: Image.network(
                            user.photo!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: Colors.white,
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // =============== USER GREETING =================
          Text(
            "Welcome back,",
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 18,
            ),
          ),
          Text(
            user.username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 20),

          // =============== SEARCH BAR =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: "Search Court",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================== POPULAR SPORTS ===========================
  Widget _buildPopularSports() {
    final popularTypes = <({String value, String label, IconData icon})>[
      (value: 'basketball', label: 'Basketball', icon: Icons.sports_basketball),
      (value: 'futsal', label: 'Futsal', icon: Icons.sports_soccer),
      (value: 'badminton', label: 'Badminton', icon: Icons.sports_tennis),
      (value: 'tennis', label: 'Tennis', icon: Icons.sports_tennis),
      (value: 'baseball', label: 'Baseball', icon: Icons.sports_baseball),
      (value: 'volleyball', label: 'Volleyball', icon: Icons.sports_volleyball),
      (value: 'padel', label: 'Padel', icon: Icons.sports_tennis),
      (value: 'golf', label: 'Golf', icon: Icons.sports_golf),
      (value: 'football', label: 'Football', icon: Icons.sports_football),
      (value: 'softball', label: 'Softball', icon: Icons.sports_baseball),
      (value: 'other', label: 'Other', icon: Icons.sports),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Filter by Court Type",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final t in popularTypes)
                _sportIcon(
                  icon: t.icon,
                  label: t.label,
                  selected: _selectedCourtTypes.contains(t.value),
                  onTap: () {
                    setState(() {
                      if (_selectedCourtTypes.contains(t.value)) {
                        _selectedCourtTypes.remove(t.value);
                      } else {
                        _selectedCourtTypes.add(t.value);
                      }
                    });
                    _reloadCourts();
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sportIcon({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: selected
                  ? const Color(0xFF6CA06E)
                  : const Color(0xFF6CA06E).withOpacity(0.18),
              child: Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFF6CA06E),
                size: 28,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== COURT LIST (CONNECTED) ====================
  Widget _buildCourtList(CookieRequest request) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.07),
              spreadRadius: 1,
              blurRadius: 6,
            ),
          ],
        ),
        child: FutureBuilder<List<cf.Court>>(
          future: _courtsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Failed to load courts',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _reloadCourts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final courts = snapshot.data ?? [];
            final q = _searchController.text.trim().toLowerCase();
            final filtered = q.isEmpty
                ? courts
                : courts.where((c) {
                    final haystack = [
                      c.name,
                      c.address,
                      c.courtType,
                    ].join(' ').toLowerCase();
                    return haystack.contains(q);
                  }).toList();

            if (courts.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Belum ada court ditemukan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            if (filtered.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Tidak ada court yang cocok dengan pencarian.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _reloadCourts();
                await _courtsFuture;
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final court = filtered[index];

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.sports,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                court.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                court.address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF6CA06E,
                                      ).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      court.courtTypeDisplay,
                                      style: const TextStyle(
                                        color: Color(0xFF6CA06E),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Rp ${court.pricePerHour.toStringAsFixed(0)}/jam',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
    );
  }
}
