import 'package:court_finder_mobile/screens/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '/models/user_entry.dart';
import '/widgets/left_drawer.dart';

class MyHomePage extends StatefulWidget {
  final UserEntry user;
  const MyHomePage({super.key, required this.user});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late UserEntry user;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    user = widget.user;
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
          _buildCourtPlaceholder(),
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
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search Court",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF6CA06E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.filter_list, color: Colors.white),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Popular Sport Type",
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
              _sportIcon(Icons.sports_soccer, "Soccer"),
              _sportIcon(
                Icons.sports_tennis,
                "Badminton",
              ), //TODO: ganti icon nanti
              _sportIcon(Icons.sports_tennis, "Tennis"),
              _sportIcon(Icons.sports_basketball, "Basketball"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sportIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF6CA06E).withOpacity(0.18),
            child: Icon(icon, color: const Color(0xFF6CA06E), size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // ===================== COURT PLACEHOLDER ========================
  Widget _buildCourtPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 140,
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
        child: const Center(
          child: Text(
            "Court List Placeholder\n(Add court list later)",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
