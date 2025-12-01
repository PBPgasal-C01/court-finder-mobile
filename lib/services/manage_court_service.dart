// lib/services/manage_court_service.dart

import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/manage-court/court.dart';

class ManageCourtService {
  // [UBAH DI SINI] 
  // Karena pakai Chrome & Local, gunakan http://127.0.0.1:8000
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  static const String jsonEndpoint = '/manage-court/get-all-json/';

  Future<List<Court>> fetchMyCourts(CookieRequest request) async {
    final response = await request.get('$baseUrl$jsonEndpoint');

    if (response is Map<String, dynamic>) {
        if (response['status'] == 'success') {
            // Encode balik ke String agar bisa masuk ke courtEntryFromJson
            final jsonString = json.encode(response);
            final CourtEntry courtEntry = courtEntryFromJson(jsonString);
            return courtEntry.courts;
        } else {
            throw Exception('Gagal memuat data: ${response['message']}');
        }
    } else {
        throw Exception('Format response tidak valid');
    }
  }

  Future<bool> deleteCourt(CookieRequest request, int id) async {
    // URL Delete
    final url = '$baseUrl/manage-court/delete/$id/'; 
    
    try {
      final response = await request.post(url, {}); 

      if (response['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error deleting court: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchCourtConstants(CookieRequest request) async {
    // [UBAH DI SINI]
    // Jangan hardcode URL, pakai variabel baseUrl di atas biar konsisten.
    // baseUrl sudah kita set ke 127.0.0.1:8000
    final response = await request.get('$baseUrl/manage-court/get-constants/');
    
    return response; 
  }

  Future<Map<String, dynamic>> createCourt(CookieRequest request, Map<String, dynamic> data) async {
    // Sesuaikan URL dengan urls.py kamu
    // Ingat: baseUrl sudah kamu set ke 127.0.0.1:8000
    final response = await request.postJson(
      '$baseUrl/manage-court/create-flutter/', 
      jsonEncode(data),
    );
    return response;
  }

  Future<Map<String, dynamic>> editCourt(CookieRequest request, int id, Map<String, dynamic> data) async {
    final response = await request.postJson(
      '$baseUrl/manage-court/edit-flutter/$id/', 
      jsonEncode(data),
    );
    return response;
  }
}