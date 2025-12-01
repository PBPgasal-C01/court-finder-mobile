import 'package:flutter/material.dart';

class GameSchedulerPage extends StatefulWidget {
  const GameSchedulerPage({super.key});

  @override
  State<GameSchedulerPage> createState() => _GameSchedulerPageState();
}

class _GameSchedulerPageState extends State<GameSchedulerPage> {
  @override
  Widget build(BuildContext context) {
    // Definisi warna
    final Color primaryGreen = const Color(0xFF6B8E72); 
    final Color lightGreen = const Color(0xFF6B8E72); 

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- HEADER HIJAU ---
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.menu, color: Colors.white, size: 28),
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white), 
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                const Center(
                   child: Text(
                  "Game Scheduler",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ),
                const SizedBox(height: 20),

                // Search Bar & Tombol Kecil
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: "Search Event",
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        // Tombol Biru (Public)
                        _buildSmallButton("PUBLIC", const Color(0xFF5D8190)), 
                        const SizedBox(height: 4),
                        // Tombol Putih (Private)
                        _buildSmallButton("PRIVATE", Colors.white),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- TOMBOL FILTER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterButton("ALL EVENTS", true),
              const SizedBox(width: 15),
              _buildFilterButton("MY EVENTS", false),
            ],
          ),

          // --- KONTEN KOSONG (EMPTY STATE) ---
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // PERBAIKAN DI SINI: Ganti Icon jadi Image.asset
                  Image.asset(
                    'static/images/cflogo2.png', // Pastikan path benar
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "You have to login to add new event.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "No events found matching your criteria.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget kecil untuk tombol PUBLIC/PRIVATE
  Widget _buildSmallButton(String text, Color colorParam) {
    // Cek apakah backgroundnya putih
    bool isWhite = colorParam == Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colorParam, // Pakai warna yang dikirim dari atas
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          // Kalau background putih, teks hitam. Kalau background warna, teks putih.
          color: isWhite ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  // Widget untuk tombol ALL EVENTS / MY EVENTS
  Widget _buildFilterButton(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6B8E72) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6B8E72)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.white : const Color(0xFF6B8E72),
        ),
      ),
    );
  }
}