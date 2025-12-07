import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';
import '../models/blog/blog_post.dart';

class BlogService {
  static const String baseUrl =
      'https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id';

  /// Fetch all blog posts
  static Future<List<BlogPost>> fetchBlogPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/blog/api/posts/'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => BlogPost.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load blog posts: ${response.statusCode}');
    }
  }

  /// Fetch user's favorite post IDs
  static Future<Set<int>> fetchFavorites(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/blog/api/favorites/');
      if (response != null && response['favorite_ids'] != null) {
        return Set<int>.from(response['favorite_ids']);
      }
      return <int>{};
    } catch (e) {
      print('Failed to fetch favorites: $e');
      return <int>{};
    }
  }

  /// Toggle favorite status for a post
  static Future<Map<String, dynamic>> toggleFavorite(
    CookieRequest request,
    int postId,
  ) async {
    try {
      final response = await request.post(
        '$baseUrl/blog/api/posts/$postId/favorite/',
        {},
      );
      return response ?? {'ok': false, 'error': 'No response'};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  /// Delete a blog post (admin only)
  static Future<Map<String, dynamic>> deletePost(
    CookieRequest request,
    int postId,
  ) async {
    try {
      final response = await request.post(
        '$baseUrl/blog/api/posts/$postId/delete/',
        {},
      );
      return response ?? {'ok': false, 'error': 'No response'};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }
}
