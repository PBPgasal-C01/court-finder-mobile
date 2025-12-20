import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../models/blog/blog_post.dart';

class BlogEditPage extends StatefulWidget {
  final BlogPost post;

  const BlogEditPage({super.key, required this.post});

  @override
  State<BlogEditPage> createState() => _BlogEditPageState();
}

class _BlogEditPageState extends State<BlogEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _contentController;
  late final TextEditingController _thumbnailController;

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing data
    _titleController = TextEditingController(text: widget.post.title);
    _authorController = TextEditingController(text: widget.post.author);
    _contentController = TextEditingController(text: widget.post.content);
    _thumbnailController = TextEditingController(
      text: widget.post.thumbnailUrl,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _contentController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B8E72),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Title'),
                        _buildTextField(
                          controller: _titleController,
                          hintText: 'Enter blog title',
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Author'),
                        _buildTextField(
                          controller: _authorController,
                          hintText: 'e.g. Admin',
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Thumbnail URL'),
                        _buildTextField(
                          controller: _thumbnailController,
                          hintText: 'https://example.com/image.jpg',
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Content'),
                        _buildTextField(
                          controller: _contentController,
                          hintText: 'Write your story here...',
                          maxLines: 7,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _buildSaveButton()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildCancelButton()),
                          ],
                        ),
                      ],
                    ),
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(color: Color(0xFF6B8E72)),
      child: Row(
        children: const [
          Icon(Icons.edit, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'EDIT BLOG',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF6B8E72)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B8E72),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            // Show loading
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(color: Color(0xFF6B8E72)),
              ),
            );

            try {
              final request = context.read<CookieRequest>();
              const baseUrl =
                  'https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id';

              final response = await request.postJson(
                '$baseUrl/blog/api/posts/${widget.post.id}/update/',
                jsonEncode({
                  'title': _titleController.text.trim(),
                  'author': _authorController.text.trim(),
                  'content': _contentController.text.trim(),
                  'thumbnail_url': _thumbnailController.text.trim(),
                }),
              );

              if (!mounted) return;
              Navigator.pop(context); // Close loading

              if (response['ok'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Blog post updated successfully!'),
                    backgroundColor: Color(0xFF6B8E72),
                  ),
                );
                Navigator.pop(context, true); // Return true to indicate success
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed: ${response['error'] ?? 'Unknown error'}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              if (!mounted) return;
              Navigator.pop(context); // Close loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: const Text(
          'UPDATE',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFFE5E2),
          foregroundColor: const Color(0xFFE57373),
          side: const BorderSide(color: Color(0xFFE57373)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          'CANCEL',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
    );
  }
}
