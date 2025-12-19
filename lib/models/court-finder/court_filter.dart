class CourtFilter {
  final double? latitude;
  final double? longitude;
  final List<String> courtTypes; // Ini List
  final String? province;
  final double? priceMin;
  final double? priceMax;
  final bool bookmarkedOnly;

  CourtFilter({
    this.latitude,
    this.longitude,
    this.courtTypes = const [], // Default kosong
    this.province,
    this.priceMin,
    this.priceMax,
    this.bookmarkedOnly = false,
  });

  // CopyWith untuk memudahkan update state (immutable style)
  CourtFilter copyWith({
    double? latitude,
    double? longitude,
    List<String>? courtTypes,
    String? province,
    double? priceMin,
    double? priceMax,
    bool? bookmarkedOnly,
  }) {
    return CourtFilter(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      courtTypes: courtTypes ?? this.courtTypes,
      province: province ?? this.province,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      bookmarkedOnly: bookmarkedOnly ?? this.bookmarkedOnly,
    );
  }

  // --- BAGIAN PENTING (FIX ERROR) ---
  // Ubah return type jadi Map<String, dynamic>
  // Agar bisa menampung List<String> di key 'court_types'
  Map<String, dynamic> toRequestBody() {
    return {
      // Hapus .toString() -> Biarkan jadi angka (JSON support angka)
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,

      // List ini SEKARANG AMAN dikirim karena kita pakai JSON
      if (courtTypes.isNotEmpty) 'court_types': courtTypes,

      if (province != null && province!.isNotEmpty) 'province': province,
      if (priceMin != null) 'price_min': priceMin,
      if (priceMax != null) 'price_max': priceMax,

      // Boolean biarkan boolean
      'bookmarked_only': bookmarkedOnly,
    };
  }
}