import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../models/blog/blog_post.dart';
import '../../models/user_entry.dart';
import '../../widgets/left_drawer.dart';
import 'blog_form.dart';
import '../../widgets/blog/blog_widgets.dart';
import '../../services/blog_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _fetchBlogPosts();
    if (widget.user != null) {
      await _fetchFavorites();
    }
  }

  Future<void> _fetchBlogPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final posts = await BlogService.fetchBlogPosts();
      setState(() {
        _blogPosts = posts;
        _filteredPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFavorites() async {
    if (!mounted) return;
    final request = context.read<CookieRequest>();
    final favorites = await BlogService.fetchFavorites(request);
    if (mounted) {
      setState(() {
        _favoriteIds.clear();
        _favoriteIds.addAll(favorites);
      });
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
      _showMessage('Please login to add favorites');
      return;
    }

    // Optimistic update
    final wasFavorited = _favoriteIds.contains(post.id);
    setState(() {
      if (wasFavorited) {
        _favoriteIds.remove(post.id);
      } else {
        _favoriteIds.add(post.id);
      }
    });

    // Sync with backend
    try {
      final request = context.read<CookieRequest>();
      final response = await BlogService.toggleFavorite(request, post.id);

      if (response['ok'] == true) {
        _showMessage(
          response['favorited'] == true
              ? 'Added to favorites'
              : 'Removed from favorites',
          isSuccess: true,
        );
      } else {
        // Revert on failure
        setState(() {
          if (wasFavorited) {
            _favoriteIds.add(post.id);
          } else {
            _favoriteIds.remove(post.id);
          }
        });
        _showMessage('Failed: ${response['error']}');
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
      _showMessage('Error: ${e.toString().split('\n').first}');
    }
  }

  Future<void> _deletePost(BlogPost post) async {
    final confirm = await _showDeleteDialog();
    if (confirm != true) return;

    try {
      final request = context.read<CookieRequest>();
      final response = await BlogService.deletePost(request, post.id);

      if (response['ok'] == true) {
        setState(() {
          _blogPosts.removeWhere((p) => p.id == post.id);
          _filteredPosts.removeWhere((p) => p.id == post.id);
          _favoriteIds.remove(post.id);
        });
        _showMessage('Post deleted successfully', isSuccess: true);
      } else {
        _showMessage('Failed to delete: ${response['error']}');
      }
    } catch (e) {
      _showMessage('Error deleting: ${e.toString()}');
    }
  }

  void _openFavorites() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FavoritesPage(
          blogPosts: _blogPosts,
          favoriteIds: _favoriteIds,
          user: widget.user,
        ),
      ),
    );

    // Refresh data when returning from favorites page
    if (result == true) {
      _loadData();
    }
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? const Color(0xFF6B8E72) : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool?> _showDeleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B8E72),
      drawer: widget.user != null ? LeftDrawer(user: widget.user!) : null,
      floatingActionButton: (widget.user?.isSuperuser ?? false)
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BlogFormPage()),
                );
                if (result == true) {
                  _fetchBlogPosts();
                }
              },
              backgroundColor: const Color(0xFF6B8E72),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
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
                    _buildSearchBar(),
                    if (_filteredPosts.isNotEmpty) _buildFeaturedSection(),
                    Expanded(child: _buildContentArea()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF6B8E72),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.user != null)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          else
            const SizedBox(width: 48),
          const Text(
            'Blog',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                onPressed: _loadData,
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child:
                    (widget.user?.photo != null &&
                        widget.user!.photo!.isNotEmpty)
                    ? ClipOval(
                        child: Image.network(
                          widget.user!.photo!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            color: Color(0xFF6B8E72),
                          ),
                        ),
                      )
                    : const Icon(Icons.person, color: Color(0xFF6B8E72)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
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
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
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
              icon: const Icon(Icons.favorite, color: Colors.white),
              onPressed: _openFavorites,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredPosts.length > 3 ? 3 : _filteredPosts.length,
            itemBuilder: (context, index) {
              final post = _filteredPosts[index];
              return BlogFeaturedCard(
                post: post,
                isFavorited: _favoriteIds.contains(post.id),
                onFavoriteToggle: () => _toggleFavorite(post),
                user: widget.user,
                onNavigateBack: _loadData,
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildContentArea() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchBlogPosts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredPosts.isEmpty) {
      return const Center(
        child: Text(
          'No blog posts found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'For You',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See more',
                  style: TextStyle(color: Color(0xFF6B8E72)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredPosts.length,
            itemBuilder: (context, index) {
              final post = _filteredPosts[index];
              return BlogListItem(
                post: post,
                isFavorited: _favoriteIds.contains(post.id),
                onFavoriteToggle: () => _toggleFavorite(post),
                showDeleteButton: widget.user?.isSuperuser ?? false,
                onDelete: () => _deletePost(post),
                user: widget.user,
                onNavigateBack: _loadData,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _FavoritesPage extends StatefulWidget {
  final List<BlogPost> blogPosts;
  final Set<int> favoriteIds;
  final UserEntry? user;

  const _FavoritesPage({
    required this.blogPosts,
    required this.favoriteIds,
    this.user,
  });

  @override
  State<_FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<_FavoritesPage> {
  late Set<int> _favoriteIds;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _favoriteIds = Set.from(widget.favoriteIds);
  }

  Future<void> _refreshFavorites() async {
    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();
      final favoriteIds = await BlogService.fetchFavorites(request);

      if (mounted) {
        setState(() {
          _favoriteIds = favoriteIds;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing favorites: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite(BlogPost post) async {
    final previousState = _favoriteIds.contains(post.id);

    setState(() {
      if (previousState) {
        _favoriteIds.remove(post.id);
      } else {
        _favoriteIds.add(post.id);
      }
    });

    try {
      final request = context.read<CookieRequest>();
      final response = await BlogService.toggleFavorite(request, post.id);

      if (response['ok'] != true) {
        if (mounted) {
          setState(() {
            if (previousState) {
              _favoriteIds.add(post.id);
            } else {
              _favoriteIds.remove(post.id);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to toggle favorite'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (previousState) {
            _favoriteIds.add(post.id);
          } else {
            _favoriteIds.remove(post.id);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = widget.blogPosts
        .where((p) => _favoriteIds.contains(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: const Color(0xFF6B8E72),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshFavorites,
          ),
        ],
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) => BlogListItem(
                post: favorites[index],
                isFavorited: _favoriteIds.contains(favorites[index].id),
                onFavoriteToggle: () => _toggleFavorite(favorites[index]),
                user: widget.user,
                onNavigateBack: _refreshFavorites,
              ),
            ),
    );
  }
}
