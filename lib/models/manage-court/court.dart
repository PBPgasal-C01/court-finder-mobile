// To parse this JSON data, do
//
//     final courtEntry = courtEntryFromJson(jsonString);

import 'dart:convert';

CourtEntry courtEntryFromJson(String str) => CourtEntry.fromJson(json.decode(str));

String courtEntryToJson(CourtEntry data) => json.encode(data.toJson());

class CourtEntry {
    String status;
    List<Court> courts;

    CourtEntry({
        required this.status,
        required this.courts,
    });

    factory CourtEntry.fromJson(Map<String, dynamic> json) => CourtEntry(
        status: json["status"] as String,
        courts: List<Court>.from(json["courts"].map((x) => Court.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "courts": List<dynamic>.from(courts.map((x) => x.toJson())),
    };
}

class Court {
    int pk;
    String name;
    String address;
    String? description;
    String courtType;
    String operationalHours;
    double pricePerHour;
    String phoneNumber;
    int? province;
    double? latitude;
    double? longitude;
    String? photoUrl;
    List<int> facilities;

    Court({
        required this.pk,
        required this.name,
        required this.address,
        required this.description,
        required this.courtType,
        required this.operationalHours,
        required this.pricePerHour,
        required this.phoneNumber,
        required this.province,
        required this.latitude,
        required this.longitude,
        required this.photoUrl,
        required this.facilities,
    });

    factory Court.fromJson(Map<String, dynamic> json) => Court(
        pk: json["pk"] as int,
        name: json["name"] as String,
        address: json["address"] as String,
        description: json["description"] as String?,
        province: json["province"] as int?,
        photoUrl: json["photo_url"] as String?,
        courtType: json["court_type"] as String,
        operationalHours: json["operational_hours"] as String,
        phoneNumber: json["phone_number"] as String,
        pricePerHour: (json["price_per_hour"] as num).toDouble(), 
        latitude: (json["latitude"] as num?)?.toDouble(),
        longitude: (json["longitude"] as num?)?.toDouble(),
        facilities: List<int>.from(json["facilities"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "pk": pk,
        "name": name,
        "address": address,
        "description": description,
        "court_type": courtType,
        "operational_hours": operationalHours,
        "price_per_hour": pricePerHour,
        "phone_number": phoneNumber,
        "province": province,
        "latitude": latitude,
        "longitude": longitude,
        "photo_url": photoUrl,
        "facilities": List<dynamic>.from(facilities.map((x) => x)),
    };
}

// Tambahkan di bagian paling bawah lib/models/manage-court/court.dart

class MockCourts {
  static List<Court> dummyData = [
    Court(
      pk: 1,
      name: "Lapangan Futsal Garuda (Mock)",
      address: "Jl. Margonda Raya No. 123, Depok",
      description: "Lapangan rumput sintetis standar internasional.",
      courtType: "Futsal",
      operationalHours: "08:00 - 22:00",
      pricePerHour: 150000.0,
      phoneNumber: "08123456789",
      province: 11, 
      latitude: -6.3725,
      longitude: 106.8294,
      photoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Futsal_H%C3%A5kan_Sandberg.jpg/800px-Futsal_H%C3%A5kan_Sandberg.jpg", // Contoh URL gambar asli
      facilities: [1, 3, 5],
    ),
    Court(
      pk: 2,
      name: "Arena Badminton Juara (Mock)",
      address: "Jl. Kaliurang Km 5, Yogyakarta",
      description: "Lapangan karpet vinyl, pencahayaan terang.",
      courtType: "Badminton",
      operationalHours: "09:00 - 23:00",
      pricePerHour: 75000.0,
      phoneNumber: "08987654321",
      province: 14, 
      latitude: -7.7605,
      longitude: 110.3840,
      photoUrl: null, // Foto kosong untuk ngetes icon default
      facilities: [2, 4], 
    ),
  ];
}
