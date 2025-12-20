// To parse this JSON data, do
//
//     final blogPost = blogPostFromJson(jsonString);

import 'dart:convert';

List<BlogPost> blogPostListFromJson(String str) =>
    List<BlogPost>.from(json.decode(str).map((x) => BlogPost.fromJson(x)));

BlogPost blogPostFromJson(String str) => BlogPost.fromJson(json.decode(str));

String blogPostToJson(BlogPost data) => json.encode(data.toJson());

class BlogPost {
  int id;
  String title;
  String author;
  String content;
  String thumbnailUrl;
  DateTime createdAt;
  dynamic readingTime;
  DateTime? updatedAt;

  BlogPost({
    required this.id,
    required this.title,
    required this.author,
    required this.content,
    required this.thumbnailUrl,
    required this.createdAt,
    this.readingTime,
    this.updatedAt,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) => BlogPost(
    id: json["id"],
    title: json["title"],
    author: json["author"],
    content: json["content"],
    // Clean thumbnail URL from any whitespace, line breaks
    thumbnailUrl: (json["thumbnail_url"] ?? '')
        .toString()
        .trim()
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .replaceAll(' ', ''),
    createdAt: DateTime.parse(json["created_at"]),
    readingTime: json["reading_time"],
    updatedAt: json["updated_at"] != null
        ? DateTime.parse(json["updated_at"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "author": author,
    "content": content,
    "thumbnail_url": thumbnailUrl,
    "created_at": createdAt.toIso8601String(),
    "reading_time": readingTime,
    if (updatedAt != null) "updated_at": updatedAt!.toIso8601String(),
  };

  // Helper getter untuk reading time dalam menit
  int get readingTimeMinutes {
    if (readingTime == null) return 5;
    // Handle both int and double from JSON
    if (readingTime is int) return readingTime as int;
    if (readingTime is double) return (readingTime as double).round();
    // Try parse if string
    if (readingTime is String) {
      return int.tryParse(readingTime as String) ?? 5;
    }
    return 5;
  }
}
