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
import 'screens/welcome_screen.dart';
import 'package:court_finder_mobile/screens/complain/menu_complaint.dart';
import 'package:court_finder_mobile/screens/complain/menu_admin_complaint.dart';
import 'package:court_finder_mobile/widgets/bottom_nav.dart';
import 'package:court_finder_mobile/widgets/custom_app_bar.dart';

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
        home: WelcomePage(),
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
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 5).toInt();
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0: return "Home";
      case 1: return "Manage Court";
      case 2: return "Game Scheduler"; // Atau "Event"
      case 3: return "Court Finder";
      case 4: return "Blog";
      case 5: return "Report";
      default: return "Court Finder";
    }
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
      CourtFinderScreen(),
      BlogPage(user: widget.user!),
      widget.user!.isSuperuser
          ? const AdminHomeScreen()
          : const ComplaintScreen(),
    ];

    final int activeIndex = _selectedIndex.clamp(0, pages.length - 1).toInt();

    return Scaffold(
      key: _scaffoldKey,
      drawer: widget.user != null ? LeftDrawer(user: widget.user!) : null,

      // --- PASANG NAV ATAS DISINI ---
      // Kita sembunyikan AppBar kalau di Home (Index 0) KARENA
      // biasanya Home punya header besar sendiri (seperti di menu.dart kamu).
      // TAPI kalau kamu mau Home juga pake navbar kecil ini, hapus kondisi "if" nya.
      appBar: _selectedIndex == 0
          ? null // Home pakai header sendiri (opsional)
          : CustomTopAppBar(
        title: _getPageTitle(_selectedIndex),
        user: widget.user!,
        scaffoldKey: _scaffoldKey,
      ),

      body: IndexedStack(index: _selectedIndex, children: pages),

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
