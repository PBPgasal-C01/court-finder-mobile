// To parse this JSON data, do
//
//     final courtEntry = courtEntryFromJson(jsonString);

import 'dart:convert';

CourtEntry courtEntryFromJson(String str) => CourtEntry.fromJson(json.decode(str));

String courtEntryToJson(CourtEntry data) => json.encode(data.toJson());

class CourtEntry {
    String status;
    List<Court> courts; // Tetap non-nullable

    CourtEntry({
        required this.status,
        required this.courts,
    });

    factory CourtEntry.fromJson(Map<String, dynamic> json) => CourtEntry(
        status: json["status"] as String? ?? "error",
        // FIX: Handle null courts dengan default empty list
        courts: json["courts"] != null 
            ? List<Court>.from(json["courts"].map((x) => Court.fromJson(x)))
            : [], // ← Jika null, return empty list
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
    String? province;
    double? latitude;
    double? longitude;
    String? photoUrl;
    List<int> facilities;

    Court({
        required this.pk,
        required this.name,
        required this.address,
        this.description,
        required this.courtType,
        required this.operationalHours,
        required this.pricePerHour,
        required this.phoneNumber,
        this.province,
        this.latitude,
        this.longitude,
        this.photoUrl,
        required this.facilities,
    });

    factory Court.fromJson(Map<String, dynamic> json) => Court(
        pk: json["pk"] as int,
        name: json["name"] as String,
        address: json["address"] as String,
        description: json["description"] as String?,
        province: json["province"]?.toString(),
        photoUrl: json["photo_url"] as String?,
        courtType: json["court_type"] as String,
        operationalHours: json["operational_hours"] as String,
        phoneNumber: json["phone_number"] as String,
        pricePerHour: (json["price_per_hour"] as num).toDouble(), 
        latitude: (json["latitude"] as num?)?.toDouble(),
        longitude: (json["longitude"] as num?)?.toDouble(),
        facilities: json["facilities"] != null 
            ? List<int>.from(json["facilities"].map((x) => x))
            : [],
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