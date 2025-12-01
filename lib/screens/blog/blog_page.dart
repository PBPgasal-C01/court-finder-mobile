import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../models/blog/blog_post.dart';
import '../../models/user_entry.dart';
import 'blog_detail.dart';
import 'blog_form.dart';

class BlogPage extends StatefulWidget {
  final UserEntry? user;
  const BlogPage({super.key, this.user});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final TextEditingController _searchController = TextEditingController();
  List<BlogPost> _blogPosts = [];
  List<BlogPost> _filteredPosts = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final Set<int> _favoriteIds = <int>{};

  // Ganti dengan URL production Anda
  static const String _baseUrl =
      'https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id';

  @override
  void initState() {
    super.initState();
    _fetchBlogPosts();
    if (widget.user != null) {
      _fetchFavorites();
    }
  }

  Future<void> _fetchBlogPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/blog/api/posts/'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _blogPosts = data.map((json) => BlogPost.fromJson(json)).toList();
          _filteredPosts = _blogPosts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load blog posts: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFavorites() async {
    if (!mounted) return;
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('$_baseUrl/blog/api/favorites/');
      if (response != null && response['favorite_ids'] != null) {
        setState(() {
          _favoriteIds.clear();
          _favoriteIds.addAll(List<int>.from(response['favorite_ids']));
        });
      }
    } catch (e) {
      // Silent fail for favorites, tidak critical
      debugPrint('Failed to fetch favorites: $e');
    }
  }

  void _filterPosts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPosts = _blogPosts;
      } else {
        _filteredPosts = _blogPosts
            .where(
              (post) =>
                  post.title.toLowerCase().contains(query.toLowerCase()) ||
                  post.content.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Future<void> _toggleFavorite(BlogPost post) async {
    if (widget.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add favorites')),
      );
      return;
    }

    // Optimistic update UI
    final wasFavorited = _favoriteIds.contains(post.id);
    setState(() {
      if (wasFavorited) {
        _favoriteIds.remove(post.id);
      } else {
        _favoriteIds.add(post.id);
      }
    });

    // Sync dengan backend
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        '$_baseUrl/blog/api/posts/${post.id}/favorite/',
        {},
      );

      if (response['ok'] == true) {
        // Backend confirm success
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['favorited'] == true
                  ? 'Added to favorites'
                  : 'Removed from favorites',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        // Revert jika gagal
        setState(() {
          if (wasFavorited) {
            _favoriteIds.add(post.id);
          } else {
            _favoriteIds.remove(post.id);
          }
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update favorite')),
        );
      }
    } catch (e) {
      // Revert on error
      setState(() {
        if (wasFavorited) {
          _favoriteIds.add(post.id);
        } else {
          _favoriteIds.remove(post.id);
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _openFavorites() {
    final favorites = _blogPosts
        .where((p) => _favoriteIds.contains(p.id))
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('My Favorites'),
            backgroundColor: const Color(0xFF6B8E72),
            foregroundColor: Colors.white,
          ),
          body: favorites.isEmpty
              ? const Center(child: Text('No favorites yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) =>
                      _buildBlogListItem(favorites[index]),
                ),
        ),
      ),
    );
  }

  Future<void> _deletePost(BlogPost post) async {
    try {
      final resp = await http.delete(
        Uri.parse('$_baseUrl/blog/api/posts/${post.id}/'),
        headers: {'Accept': 'application/json'},
      );
      if (resp.statusCode == 204 || resp.statusCode == 200) {
        setState(() {
          _blogPosts.removeWhere((p) => p.id == post.id);
          _filteredPosts.removeWhere((p) => p.id == post.id);
          _favoriteIds.remove(post.id);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Post deleted')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B8E72),
      floatingActionButton: (widget.user?.isSuperuser ?? false)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BlogFormPage()),
                );
              },
              backgroundColor: const Color(0xFF6B8E72),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
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
                  const Text(
                    'Blog',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Placeholder untuk profile picture
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.person, color: Color(0xFF6B8E72)),
                  ),
                ],
              ),
            ),
            // Content area dengan background putih
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _filterPosts,
                                decoration: InputDecoration(
                                  hintText: 'Search blog...',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey[400],
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFE91E63),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.white,
                              ),
                              onPressed: _openFavorites,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Featured posts carousel
                    if (_filteredPosts.isNotEmpty) ...[
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredPosts.length > 3
                              ? 3
                              : _filteredPosts.length,
                          itemBuilder: (context, index) {
                            final post = _filteredPosts[index];
                            return _buildFeaturedCard(post);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    // "For You" section
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _errorMessage.isNotEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _errorMessage,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _fetchBlogPosts,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : _filteredPosts.isEmpty
                          ? const Center(
                              child: Text(
                                'No blog posts found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'For You',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text(
                                          'See more',
                                          style: TextStyle(
                                            color: Color(0xFF6B8E72),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    itemCount: _filteredPosts.length,
                                    itemBuilder: (context, index) {
                                      final post = _filteredPosts[index];
                                      return _buildBlogListItem(post);
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BlogPost post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BlogDetailPage(post: post)),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: NetworkImage(post.thumbnailUrl),
            fit: BoxFit.cover,
            onError: (_, __) {},
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _favoriteIds.contains(post.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.pinkAccent,
                    ),
                    onPressed: () => _toggleFavorite(post),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlogListItem(BlogPost post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BlogDetailPage(post: post)),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.user?.isSuperuser ?? false)
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Post'),
                                content: const Text(
                                  'Are you sure you want to delete this post?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await _deletePost(post);
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.readingTimeMinutes} min reading',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '@${post.author.toLowerCase()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.thumbnailUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _favoriteIds.contains(post.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.pinkAccent,
                  ),
                  onPressed: () => _toggleFavorite(post),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
