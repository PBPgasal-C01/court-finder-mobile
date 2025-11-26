import 'package:flutter/material.dart';
import '../../models/blog/blog_post.dart';
import 'blog_detail.dart';
import 'blog_form.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final TextEditingController _searchController = TextEditingController();
  List<BlogPost> _blogPosts = [];
  List<BlogPost> _filteredPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    // Dummy data untuk sementara
    _blogPosts = [
      BlogPost(
        id: 1,
        author: 'Admin',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400',
        title:
            'Finally. Lionel Messi leads Argentina over France to win a World Cup championship.',
        content:
            '''The 2022 World Cup started terribly for Argentina. The shocking opening loss to Saudi Arabia — and the whispers began immediately.

Will Lionel Messi end his glorious career without winning a World Cup?

No one is talking about that now. Lionel Messi was the first name to pop up. The 35-year-old carried Argentina and drove them to their third World Cup title in eight games. Messi is now the second player ever to score goals in the group stage, round of 16, quarterfinals, semifinals and final of a single World Cup. The first time he can call himself a World Cup champion, it was the last chance. Now his returns in full.

It came down to Argentina's Gonzalo Montiel who scored the winning penalty kick. Tears and hugs and smiles for Messi and all of Argentina, really.

It had not been since 1986 when Argentina last won a World Cup carried by Diego Maradona - the man whose legend Messi has now joined after leading his nation to their third title.

The 2022 World Cup belongs to Argentina. It's Argentina's third title and the first for Lionel Messi. The first time he can call himself a World Cup champion, it was his last chance. Now his returns in full.

Messi, with a 3-3 (4-2 penalty kick shootout) victory over defending champion France, Lionel Messi can call himself a World Cup champion in what was probably his last chance. Now his returns in full.''',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      BlogPost(
        id: 2,
        author: 'Admin',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400',
        title:
            'Finally. Lionel Messi leads Argentina over France to win a World Cup championship.',
        content:
            '''The 2022 World Cup started terribly for Argentina. The shocking opening loss to Saudi Arabia — and the whispers began immediately.

Will Lionel Messi end his glorious career without winning a World Cup?

No one is talking about that now. Lionel Messi was the first name to pop up.''',
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
      BlogPost(
        id: 3,
        author: 'Admin',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400',
        title:
            'Finally. Lionel Messi leads Argentina over France to win a World Cup championship.',
        content:
            '''The 2022 World Cup started terribly for Argentina. The shocking opening loss to Saudi Arabia — and the whispers began immediately.''',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    _filteredPosts = _blogPosts;
    setState(() {
      _isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B8E72),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BlogFormPage()),
          );
        },
        backgroundColor: const Color(0xFF6B8E72),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
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
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {},
                  ),
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
                              onPressed: () {
                                // TODO: Navigate to favorites
                              },
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
              Text(
                post.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
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
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
