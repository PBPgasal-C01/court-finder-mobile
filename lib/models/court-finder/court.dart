import 'province.dart';

class Court {
  final String id;
  final String name;
  final String courtType;
  final String locationType;
  final double pricePerHour;
  final String address;
  final List<Province> provinces;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String? description;
  final List<String> facilities;
  final bool isBookmarked;
  final double? distance;

  Court({
    required this.id,
    required this.name,
    required this.courtType,
    required this.locationType,
    required this.pricePerHour,
    required this.address,
    required this.provinces,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    this.description,
    this.facilities = const [],
    this.isBookmarked = false,
    this.distance,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'].toString(),
      name: json['name'],
      courtType: json['court_type'],
      locationType: json['location_type'] ?? 'outdoor',
      pricePerHour: double.parse(json['price_per_hour'].toString()),
      address: json['address'],
      provinces: json['provinces'] != null
          ? (json['provinces'] as List)
          .map((p) => Province.fromJson(p))
          .toList()
          : [],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      phoneNumber: json['phone_number'] ?? '',
      description: json['description'],
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'])
          : [],
      isBookmarked: json['is_bookmarked'] ?? false,
      distance: json['distance'] != null
          ? double.tryParse(json['distance'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'court_type': courtType,
      'location_type': locationType,
      'price_per_hour': pricePerHour,
      'address': address,
      'provinces': provinces.map((p) => p.toJson()).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'description': description,
      'facilities': facilities,
      'is_bookmarked': isBookmarked,
      'distance': distance,
    };
  }

  Court copyWith({
    String? id,
    String? name,
    String? courtType,
    String? locationType,
    double? pricePerHour,
    String? address,
    List<Province>? provinces,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? description,
    List<String>? facilities,
    bool? isBookmarked,
    double? distance,
  }) {
    return Court(
      id: id ?? this.id,
      name: name ?? this.name,
      courtType: courtType ?? this.courtType,
      locationType: locationType ?? this.locationType,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      address: address ?? this.address,
      provinces: provinces ?? this.provinces,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      description: description ?? this.description,
      facilities: facilities ?? this.facilities,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      distance: distance ?? this.distance,
    );
  }

  // Helper untuk display
  String get courtTypeDisplay {
    final typeMap = {
      'basketball': 'Basketball',
      'futsal': 'Futsal',
      'badminton': 'Badminton',
      'tennis': 'Tennis',
      'baseball': 'Baseball',
      'volleyball': 'Volleyball',
      'padel': 'Padel',
      'golf': 'Golf',
      'football': 'Football',
      'softball': 'Softball',
      'other': 'Other',
    };
    return typeMap[courtType] ?? courtType;
  }

  String get locationTypeDisplay {
    return locationType == 'indoor' ? 'Indoor' : 'Outdoor';
  }
}