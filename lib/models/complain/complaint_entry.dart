import 'dart:convert';

List<ComplaintEntry> complaintEntryFromJson(String str) => List<ComplaintEntry>.from(json.decode(str).map((x) => ComplaintEntry.fromJson(x)));

String complaintEntryToJson(List<ComplaintEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ComplaintEntry {
    String id;
    String courtName;
    String masalah;
    String deskripsi;
    String fotoUrl;
    String status;
    dynamic komentar;
    DateTime createdAt;

    ComplaintEntry({
        required this.id,
        required this.courtName,
        required this.masalah,
        required this.deskripsi,
        required this.fotoUrl,
        required this.status,
        required this.komentar,
        required this.createdAt,
    });

    factory ComplaintEntry.fromJson(Map<String, dynamic> json) => ComplaintEntry(
        id: json["id"],
        courtName: json["court_name"],
        masalah: json["masalah"],
        deskripsi: json["deskripsi"],
        fotoUrl: json["foto_url"] ?? "",
        status: json["status"],
        komentar: json["komentar"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "court_name": courtName,
        "masalah": masalah,
        "deskripsi": deskripsi,
        "foto_url": fotoUrl,
        "status": status,
        "komentar": komentar,
        "created_at": createdAt.toIso8601String(),
    };
}
