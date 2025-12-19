import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/court-finder/court.dart';
import '../../models/court-finder/court_filter.dart';
import '../../models/court-finder/province.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ApiService {
  static const String baseUrl = 'http://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/courts';

  // Headers untuk authenticated requests
  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    // Jika ada authentication token (session/JWT)
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<List<Court>> searchCourts(CookieRequest request, CourtFilter filter) async {
    try {
      print("Sending request to: $baseUrl/api/search/");

      // PERBAIKAN: Gunakan postJson + jsonEncode
      // postJson akan otomatis mengatur header 'Content-Type: application/json'
      // sehingga tidak akan error 415, dan bisa menerima List.
      final response = await request.postJson(
          '$baseUrl/api/search/',
          jsonEncode(filter.toRequestBody())
      );

      // Debugging
      print("Raw Server Response: $response");

      // Validasi response
      if (response != null && response['courts'] != null) {
        final List<dynamic> courtsJson = response['courts'];
        return courtsJson.map((json) => Court.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Exception in searchCourts: $e");
      return [];
    }
  }

  // 2. Update getNearbyCourts juga (karena dia memanggil searchCourts)
  Future<List<Court>> getNearbyCourts(
      CookieRequest request, // <--- Tambah Parameter ini
      double latitude,
      double longitude,
      ) async {
    final filter = CourtFilter(
      latitude: latitude,
      longitude: longitude,
    );
    // Oper request ke searchCourts
    return searchCourts(request, filter);
  }

  // Get provinces
  Future<List<Province>> getProvinces() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/provinces/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Province.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load provinces');
      }
    } catch (e) {
      throw Exception('Error fetching provinces: $e');
    }
  }

  // Toggle bookmark (POST untuk add, DELETE untuk remove)
  Future<bool> addBookmark(String courtId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/bookmark/$courtId/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // Bookmarked
      } else {
        throw Exception('Failed to add bookmark: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding bookmark: $e');
    }
  }

  Future<bool> removeBookmark(String courtId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/bookmark/$courtId/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return false; // Not bookmarked
      } else {
        throw Exception('Failed to remove bookmark: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing bookmark: $e');
    }
  }

  // Toggle bookmark wrapper
  Future<bool> toggleBookmark(CookieRequest request, String courtId) async {
    // Pastikan URL nyambung dengan benar (ada slash di api/bookmark/)
    final url = '${baseUrl}/api/bookmark/$courtId/';

    try {
      // Kirim POST (Apapun yang terjadi, kirim POST)
      final response = await request.post(url, {});

      // Backend akan membalas dengan JSON: {"bookmarked": true/false}
      // Kita kembalikan nilai bool itu ke UI
      if (response['bookmarked'] != null) {
        return response['bookmarked'];
      }

      return false; // Default kalau error
    } catch (e) {
      print("Error toggle: $e");
      rethrow;
    }
  }

  // 3. Update getBookmarkedCourts juga
  Future<List<Court>> getBookmarkedCourts(CookieRequest request, {CourtFilter? filter}) async {
    // Logika:
    // 1. Ambil filter yang dikirim dari UI (misal user pilih "Futsal" & "Indoor").
    // 2. Kalau null (user gak filter apa2), bikin CourtFilter kosong.
    // 3. Apapun yang terjadi, PAKSA 'bookmarkedOnly' jadi true dengan .copyWith()

    final effectiveFilter = (filter ?? CourtFilter()).copyWith(bookmarkedOnly: true);

    // Kirim ke searchCourts (yang sudah kita fix pakai postJson tadi)
    return searchCourts(request, effectiveFilter);
  }

  // Geocode address (convert address to lat/lon)
  Future<Map<String, double>?> geocodeAddress(String address) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/geocode/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'address': address}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'latitude': double.parse(data['latitude'].toString()),
          'longitude': double.parse(data['longitude'].toString()),
        };
      } else {
        return null;
      }
    } catch (e) {
      print('Error geocoding address: $e');
      return null;
    }
  }
}