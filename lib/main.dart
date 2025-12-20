import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'models/user_entry.dart';
import 'screens/login.dart';
import 'screens/blog/blog_page.dart';
import 'screens/game_scheduler/game_scheduler_page.dart';
import 'screens/menu.dart';
import 'widgets/left_drawer.dart';
import 'screens/manage-court/manage_court_screen.dart';
import 'screens/court-finder/court_finder_screen.dart';

import 'package:court_finder_mobile/screens/complain/menu_complaint.dart';
import 'package:court_finder_mobile/screens/complain/menu_admin_complaint.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Court Finder',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B8E72)),
          useMaterial3: true,
        ),
        home: LoginPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final UserEntry? user;
  final int initialIndex;
  const MainPage({super.key, this.user, this.initialIndex = 2});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final sessionCookie = request.cookies.values
        .firstWhere(
          (cookie) => cookie.name == 'sessionid',
          orElse: () => request.cookies.values.firstWhere(
            (c) => c.name == 'csrftoken',
            orElse: () => Cookie(
              'sessionid',
              '',
              DateTime.now().millisecondsSinceEpoch + 3600000,
            ),
          ),
        )
        .value;

    final List<Widget> pages = [
      const GameSchedulerPage(),
      widget.user != null
          ? ManageCourtScreen(user: widget.user!)
          : const PlaceholderPage(title: 'Manage Court'),
      const CourtFinderScreen(),
      const BlogPage(),
      widget.user == null
          ? const PlaceholderPage(title: 'Report')
          : (widget.user!.isSuperuser
                ? const AdminHomeScreen()
                : const ComplaintScreen()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Court Finder",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6B8E72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: widget.user != null ? LeftDrawer(user: widget.user!) : null,

      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF6B8E72),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.event, 'Event', 0),
              _buildNavItem(Icons.edit, 'Manage', 1),
              _buildCenterLogo(),
              _buildNavItem(Icons.article, 'Blog', 3),
              _buildNavItem(Icons.comment, 'Report', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterLogo() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = 2;
        });
      },
      child: Transform.translate(
        offset: const Offset(0, -10),
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: const Color(0xFF4A6B4E),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipOval(
              child: Image.asset(
                'static/images/cflogo2.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 35,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF6B8E72),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          '$title Page',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
