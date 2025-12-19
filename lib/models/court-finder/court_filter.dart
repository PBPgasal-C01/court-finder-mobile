class CourtFilter {
  final double? latitude;
  final double? longitude;
  final List<String> courtTypes;
  final String? province;
  final double? priceMin;
  final double? priceMax;
  final bool bookmarkedOnly;

  CourtFilter({
    this.latitude,
    this.longitude,
    this.courtTypes = const [],
    this.province,
    this.priceMin,
    this.priceMax,
    this.bookmarkedOnly = false,
  });

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

  Map<String, dynamic> toRequestBody() {
    return {
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,

      if (courtTypes.isNotEmpty) 'court_types': courtTypes,

      if (province != null && province!.isNotEmpty) 'province': province,
      if (priceMin != null) 'price_min': priceMin,
      if (priceMax != null) 'price_max': priceMax,

      'bookmarked_only': bookmarkedOnly,
    };
  }
}