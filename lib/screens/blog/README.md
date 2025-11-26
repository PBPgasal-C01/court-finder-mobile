# Blog Module - Court Finder Mobile

Modul blog untuk aplikasi Court Finder Mobile dengan UI sesuai desain mockup.

## Fitur yang Sudah Diimplementasi

### 1. Blog Page (`blog_page.dart`)

- ✅ Header dengan menu dan profile picture placeholder
- ✅ Search bar untuk mencari blog posts
- ✅ Tombol favorite (heart icon) - belum terintegrasi dengan backend
- ✅ Featured posts carousel (horizontal scroll)
- ✅ Section "For You" dengan list blog posts
- ✅ Dummy data untuk testing (3 blog posts sample)
- ✅ Filter search berdasarkan title dan content

### 2. Blog Detail Page (`blog_detail.dart`)

- ✅ Header dengan tombol "Back to Blog"
- ✅ Featured image dari blog post
- ✅ Author info dan reading time
- ✅ Tombol favorite (dapat di-toggle)
- ✅ Full content blog post
- ✅ Section "Others You Might Like" dengan related posts
- ✅ Tombol "See more" untuk load more posts

### 3. Model (`blog_post.dart`)

- ✅ Class `BlogPost` dengan properties sesuai backend Django model
- ✅ Method `fromJson` untuk parsing dari API
- ✅ Method `toJson` untuk serialization
- ✅ Property `readingTimeMinutes` (calculated field)
- ✅ Method `summary()` untuk generate ringkasan text

## Struktur File

```
lib/
├── models/
│   └── blog_post.dart          # Model untuk BlogPost
└── screens/
    └── blog/
        ├── blog_page.dart      # Halaman utama blog (list)
        ├── blog_detail.dart    # Halaman detail blog
        └── blog_form.dart      # Placeholder untuk form (future use)
```

## Data Dummy

Saat ini menggunakan data dummy dengan:

- 3 blog posts sample
- Title: "Finally. Lionel Messi leads Argentina over France to win a World Cup championship."
- Thumbnail dari Unsplash
- Content lengkap untuk testing reading time

## TODO - Integrasi Backend

Untuk mengintegrasikan dengan Django backend:

1. **API Service**

   ```dart
   // Buat file: lib/services/blog_service.dart
   class BlogService {
     static const String baseUrl = 'YOUR_BACKEND_URL';

     Future<List<BlogPost>> fetchBlogPosts() async {
       final response = await http.get(Uri.parse('$baseUrl/api/blog/'));
       // Parse response...
     }

     Future<BlogPost> fetchBlogDetail(int id) async {
       final response = await http.get(Uri.parse('$baseUrl/api/blog/$id/'));
       // Parse response...
     }
   }
   ```

2. **Update blog_page.dart**

   - Replace `_loadDummyData()` dengan `_loadBlogPosts()` yang call API
   - Add loading state
   - Add error handling

3. **Favorite Feature**

   - Implement POST request ke `/api/blog/favorites/`
   - Update UI based on user's favorites
   - Add authentication handling

4. **Dependencies yang Perlu Ditambahkan**
   ```yaml
   # pubspec.yaml
   dependencies:
     http: ^1.1.0 # untuk API calls
     provider: ^6.0.0 # untuk state management (optional)
   ```

## Navigasi

Modul blog sudah terintegrasi dengan bottom navigation bar:

- Tap icon "Blog" untuk membuka `BlogPage`
- Tap pada blog post card untuk membuka `BlogDetailPage`
- Tombol back untuk kembali ke list

## Warna & Design System

- Primary Color: `#6B8E72` (hijau)
- Accent Color: `#E91E63` (pink untuk favorite button)
- Background: White dengan border radius 30 di top
- Font sizes:
  - Title: 24px (bold)
  - Subtitle: 16px
  - Body: 16px (line height 1.6)
  - Caption: 12-14px (grey)

## Screenshot Reference

Desain mengikuti mockup yang diberikan dengan:

- Clean white background
- Card-based layout
- Smooth rounded corners
- Consistent spacing
- Material Design icons

---

**Note:** Header dengan profile picture sengaja di-placeholder karena berkaitan dengan modul authentication yang belum diimplementasi.
