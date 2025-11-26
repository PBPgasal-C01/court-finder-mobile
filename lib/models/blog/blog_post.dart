class BlogPost {
  final int id;
  final String author;
  final String thumbnailUrl;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  BlogPost({
    required this.id,
    required this.author,
    required this.thumbnailUrl,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'],
      author: json['author'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'thumbnail_url': thumbnailUrl,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  int get readingTimeMinutes {
    final words = content.split(' ').length;
    final minutes = (words / 200).ceil();
    return minutes > 0 ? minutes : 1;
  }

  String summary({int words = 40}) {
    if (content.isEmpty) return '';
    final parts = content.split(' ');
    if (parts.length <= words) return content;
    return '${parts.take(words).join(' ')}…';
  }
}
