import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/manage-court/court.dart'; // Pastikan path import ini benar

class ManageCourtService {
  // URL ini tidak akan dipanggil saat kita pakai mode mock
  static const String baseUrl = 'https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id';
  static const String jsonEndpoint = '/managecourt/get-all-json/';

  Future<List<Court>> fetchMyCourts(String sessionCookie) async {
    // --- MODE MOCK DATA (Gunakan ini sementara) ---
    
    // 1. Simulasi loading (tunggu 2 detik biar terasa seperti ambil data beneran)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Kembalikan List Court palsu
    // Kita isi dengan data yang sesuai tipe data di model (province int, facilities List<int>)
    return [
      Court(
        pk: 1,
        name: "Lapangan Futsal Garuda",
        address: "Jl. Margonda Raya No. 123, Depok",
        description: "Lapangan rumput sintetis standar internasional. Fasilitas lengkap.",
        courtType: "Futsal",
        operationalHours: "08:00 - 22:00",
        pricePerHour: 150000.0,
        phoneNumber: "08123456789",
        province: 11, // Anggap saja ID 11 = DKI Jakarta
        latitude: -6.3725,
        longitude: 106.8294,
        photoUrl: "https://example.com/dummy-futsal.jpg", // Bisa null atau URL gambar internet
        facilities: [1, 3, 5], // Anggap saja ID 1=WiFi, 3=Toilet, 5=Parkir
      ),
      Court(
        pk: 2,
        name: "Arena Badminton Juara",
        address: "Jl. Kaliurang Km 5, Yogyakarta",
        description: "Lapangan karpet vinyl, pencahayaan terang.",
        courtType: "Badminton",
        operationalHours: "09:00 - 23:00",
        pricePerHour: 75000.0,
        phoneNumber: "08987654321",
        province: 14, // Anggap saja ID 14 = DIY Yogyakarta
        latitude: -7.7605,
        longitude: 110.3840,
        photoUrl: null, // Foto kosong
        facilities: [2, 4], // ID fasilitas dummy
      ),
       Court(
        pk: 3,
        name: "Basket Hall Senayan (Dummy)",
        address: "Komplek GBK",
        description: null,
        courtType: "Basketball",
        operationalHours: "06:00 - 18:00",
        pricePerHour: 200000.0,
        phoneNumber: "021555555",
        province: 11,
        latitude: null,
        longitude: null,
        photoUrl: null, 
        facilities: [], // Tidak ada fasilitas
      ),
    ];

    // --- KODE ASLI (Komen dulu sampai deployment PWS selesai) ---
    /*
    final url = Uri.parse('$baseUrl$jsonEndpoint');
    final response = await http.get(
      url,
      headers: {
        'Cookie': sessionCookie,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final CourtEntry courtEntry = courtEntryFromJson(response.body);
      if (courtEntry.status == 'success') {
        return courtEntry.courts;
      } else {
        throw Exception(courtEntry.status); // Atau pesan error lain
      }
    } else {
      throw Exception('Failed to load courts: Status Code ${response.statusCode}');
    }
    */
  }
}