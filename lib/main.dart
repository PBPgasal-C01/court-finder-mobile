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
  const MainPage({super.key, this.user, this.initialIndex = 0});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 5).toInt();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      // No authenticated user; redirect to login rather than showing placeholders.
      return const LoginPage();
    }

    final List<Widget> pages = [
      MyHomePage(user: widget.user!),
      ManageCourtScreen(user: widget.user!),
      GameSchedulerPage(user: widget.user!),
      const CourtFinderScreen(),
      BlogPage(user: widget.user!),
      widget.user!.isSuperuser
          ? const AdminHomeScreen()
          : const ComplaintScreen(),
    ];

    final int activeIndex = _selectedIndex.clamp(0, pages.length - 1).toInt();

    return Scaffold(
      drawer: widget.user != null ? LeftDrawer(user: widget.user!) : null,
      body: IndexedStack(index: activeIndex, children: pages),
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
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.edit, 'Manage', 1),
              _buildNavItem(Icons.event, 'Event', 2),
              _buildCenterLogo(),
              _buildNavItem(Icons.article, 'Blog', 4),
              _buildNavItem(Icons.comment, 'Report', 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color color = isSelected ? Colors.white : Colors.white70;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
          _selectedIndex = 3;
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
