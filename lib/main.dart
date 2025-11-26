import 'package:flutter/material.dart';
import 'package:court_finder_mobile/screens_complain/menu_complain.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Court Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7FA580), 
          primary: const Color(0xFF7FA580),
          secondary: const Color(0xFF4E634B),
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      
      home: const ComplaintScreen(), 
    );
  }
}