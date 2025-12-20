import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/court-finder/court.dart';
import '../../models/court-finder/court_filter.dart';
import '../../models/court-finder/province.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ApiService {
  static const String baseUrl = 'https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/courts';

  Future<List<Court>> searchCourts(CookieRequest request, CourtFilter filter) async {
    try {
      print("Sending request to: $baseUrl/api/search/");

      final url = Uri.parse('$baseUrl/api/search/');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (request.cookies.isNotEmpty) {
        String cookieHeader = "";
        request.cookies.forEach((key, value) {
          cookieHeader += "$key=${value.value}; ";
        });
        headers['Cookie'] = cookieHeader;
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(filter.toRequestBody()),
      ).timeout(const Duration(seconds: 15));

      print("Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is! Map<String, dynamic>) {
          print("Error: Response server bukan format JSON Object yang valid.");
          return [];
        }

        if (decodedData['courts'] == null) {
          print("Warning: Key 'courts' tidak ditemukan atau null.");
          return [];
        }

        if (decodedData['courts'] is! List) {
          print("Error: Data 'courts' bukan berbentuk List.");
          return [];
        }

        final List<dynamic> courtsJson = decodedData['courts'];
        return courtsJson.map((json) => Court.fromJson(json)).toList();

      } else {
        print("Server Error: ${response.statusCode}");
        print("Body: ${response.body}");
        return [];
      }

    } catch (e) {
      print("Exception in searchCourts: $e");
      return [];
    }
  }

  Future<List<Court>> getNearbyCourts(
      CookieRequest request,
      double latitude,
      double longitude,
      ) async {
    final filter = CourtFilter(
      latitude: latitude,
      longitude: longitude,
    );
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

  Future<bool> toggleBookmark(CookieRequest request, String courtId) async {
    final url = '${baseUrl}/api/bookmark/$courtId/';

    try {
      final response = await request.post(url, {});

      if (response['bookmarked'] != null) {
        return response['bookmarked'];
      }

      return false; // Default kalau error
    } catch (e) {
      print("Error toggle: $e");
      rethrow;
    }
  }

  Future<List<Court>> getBookmarkedCourts(CookieRequest request, {CourtFilter? filter}) async {
    final effectiveFilter = (filter ?? CourtFilter()).copyWith(bookmarkedOnly: true);

    return searchCourts(request, effectiveFilter);
  }

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