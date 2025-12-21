import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../models/blog/blog_post.dart';
import '../../models/user_entry.dart';
import 'blog_edit_page.dart';

class BlogDetailPage extends StatefulWidget {
  final BlogPost post;
  final UserEntry? user;

  const BlogDetailPage({super.key, required this.post, this.user});

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  bool _isFavorited = false;
  List<BlogPost> _relatedPosts = [];
  final Set<int> _favoriteIds = <int>{};
  bool _isLoadingRelated = true;
  bool _favoritesChanged = false;

  static const String _baseUrl =
      'https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id';

  @override
  void initState() {
    super.initState();
    _loadRelatedPosts();
    _checkIfFavorited();
  }

  Future<void> _checkIfFavorited() async {
    if (widget.user == null || !mounted) return;

    try {
      final request = context.read<CookieRequest>();
      final favResponse = await request.get('$_baseUrl/blog/api/favorites/');
      if (favResponse != null && favResponse['favorite_ids'] != null) {
        setState(() {
          _isFavorited = List<int>.from(
            favResponse['favorite_ids'],
          ).contains(widget.post.id);
        });
      }
    } catch (e) {
      debugPrint('Failed to check favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add favorites'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        '$_baseUrl/blog/api/posts/${widget.post.id}/favorite/',
        {},
      );

      if (response['ok'] == true) {
        final bool previous = _isFavorited;
        final bool isFavoritedOnServer = response['favorited'] == true;
        setState(() {
          _isFavorited = isFavoritedOnServer;
          if (previous != isFavoritedOnServer) {
            _favoritesChanged = true;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFavoritedOnServer
                    ? 'Added to favorites'
                    : 'Removed from favorites',
              ),
              duration: const Duration(seconds: 1),
              backgroundColor: const Color(0xFF6B8E72),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response['error'] ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update favorite'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadRelatedPosts() async {
    setState(() => _isLoadingRelated = true);

    try {
      // Fetch all posts
      final postsResponse = await http.get(
        Uri.parse('$_baseUrl/blog/api/posts/'),
        headers: {'Accept': 'application/json'},
      );

      if (postsResponse.statusCode == 200) {
        final List<dynamic> postsData = json.decode(postsResponse.body);
        List<BlogPost> allPosts = postsData
            .map((json) => BlogPost.fromJson(json))
            .toList();

        // Fetch favorites if user logged in
        if (widget.user != null && mounted) {
          try {
            final request = context.read<CookieRequest>();
            final favResponse = await request.get(
              '$_baseUrl/blog/api/favorites/',
            );
            if (favResponse != null && favResponse['favorite_ids'] != null) {
              _favoriteIds.clear();
              _favoriteIds.addAll(List<int>.from(favResponse['favorite_ids']));
            }
          } catch (e) {
            debugPrint('Failed to fetch favorites: $e');
          }
        }

        // Filter: exclude current post and favorited posts
        final filtered = allPosts.where((post) {
          return post.id != widget.post.id && !_favoriteIds.contains(post.id);
        }).toList();

        // Shuffle and take up to 3
        filtered.shuffle();
        setState(() {
          _relatedPosts = filtered.take(3).toList();
          _isLoadingRelated = false;
        });
      } else {
        setState(() => _isLoadingRelated = false);
      }
    } catch (e) {
      debugPrint('Error loading related posts: $e');
      setState(() => _isLoadingRelated = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B8E72),
      floatingActionButton: (widget.user?.isSuperuser ?? false)
          ? FloatingActionButton(
              heroTag: null,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlogEditPage(post: widget.post),
                  ),
                );
                // Refresh if post was updated
                if (result == true && mounted) {
                  // Reload the page with updated data
                  try {
                    final response = await http.get(
                      Uri.parse('$_baseUrl/blog/api/posts/${widget.post.id}/'),
                      headers: {'Accept': 'application/json'},
                    );
                    if (response.statusCode == 200) {
                      final updatedPost = BlogPost.fromJson(
                        json.decode(response.body),
                      );
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlogDetailPage(
                              post: updatedPost,
                              user: widget.user,
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    debugPrint('Error reloading post: $e');
                  }
                }
              },
              backgroundColor: const Color(0xFF6B8E72),
              foregroundColor: Colors.white,
              child: const Icon(Icons.edit),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context, _favoritesChanged),
                  ),
                  const Text(
                    'Back to Blog',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child:
                            widget.post.thumbnailUrl.isNotEmpty &&
                                Uri.tryParse(
                                      widget.post.thumbnailUrl,
                                    )?.hasAbsolutePath ==
                                    true
                            ? Image.network(
                                widget.post.thumbnailUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                headers: const {
                                  'User-Agent':
                                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                                  'Accept':
                                      'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
                                  'Referer': 'https://www.npr.org/',
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: double.infinity,
                                        height: 200,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                            color: const Color(0xFF6B8E72),
                                          ),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint('Detail image error: $error');
                                  return Image.asset(
                                    'static/images/cflogo2.png',
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                'static/images/cflogo2.png',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      // Author and reading time
                      Row(
                        children: [
                          Text(
                            '@${widget.post.author.toLowerCase()}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.post.readingTimeMinutes} min reading',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              _isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _isFavorited ? Colors.pink : Colors.grey,
                            ),
                            onPressed: _toggleFavorite,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        widget.post.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Content
                      Text(
                        widget.post.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // "Others You Might Like" section
                      const Text(
                        'Others You Might Like',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Related posts
                      if (_isLoadingRelated)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF6B8E72),
                            ),
                          ),
                        )
                      else if (_relatedPosts.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No other posts available',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ..._relatedPosts.map((post) => _buildRelatedPost(post)),
                      const SizedBox(height: 16),
                      if (!_isLoadingRelated && _relatedPosts.isNotEmpty)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'See more',
                              style: TextStyle(
                                color: Color(0xFF6B8E72),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 80), // Extra space for bottom nav
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedPost(BlogPost post) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BlogDetailPage(post: post, user: widget.user),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.readingTimeMinutes} min reading',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          '@${post.author.toLowerCase()}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  post.thumbnailUrl.isNotEmpty &&
                      Uri.tryParse(post.thumbnailUrl)?.hasAbsolutePath == true
                  ? Image.network(
                      post.thumbnailUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      headers: const {
                        'User-Agent':
                            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                        'Accept':
                            'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
                        'Referer': 'https://www.npr.org/',
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: const Color(0xFF6B8E72),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'static/images/cflogo2.png',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 30,
                            ),
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      'static/images/cflogo2.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
