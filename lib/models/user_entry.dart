// To parse this JSON data, do
//
//     final userEntry = userEntryFromJson(jsonString);

import 'dart:convert';

UserEntry userEntryFromJson(String str) => UserEntry.fromJson(json.decode(str));

String userEntryToJson(UserEntry data) => json.encode(data.toJson());

class UserEntry {
  String email;
  String username;
  String? photo;
  String preference;
  bool isSuperuser;
  bool isStaff;
  String role;
  bool isActive;
  String dateJoined;

  UserEntry({
    required this.email,
    required this.username,
    required this.photo,
    required this.preference,
    required this.isSuperuser,
    required this.isStaff,
    required this.role,
    this.isActive = false,
    this.dateJoined = ""
  });

  factory UserEntry.fromJson(Map<String, dynamic> json) => UserEntry(
        email: json["email"],
        username: json["username"],
        photo: json["photo"], // may be null
        preference: json["preference"],
        isSuperuser: json["is_superuser"],
        isStaff: json["is_staff"],
        role: json["role"],
        isActive: json["is_active"],
        dateJoined: json["joined"]
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "username": username,
        "photo": photo,
        "preference": preference,
        "is_superuser": isSuperuser,
        "is_staff": isStaff,
        "role": role,
        "is_active": isActive,
        "joined": dateJoined
      };
}
