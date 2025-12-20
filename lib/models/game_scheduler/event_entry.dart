// To parse this JSON data, do
//
//     final eventEntry = eventEntryFromJson(jsonString);

import 'dart:convert';

List<EventEntry> eventEntryFromJson(String str) => List<EventEntry>.from(json.decode(str).map((x) => EventEntry.fromJson(x)));

String eventEntryToJson(List<EventEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EventEntry {
    String model;
    int pk;
    Fields fields;

    EventEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory EventEntry.fromJson(Map<String, dynamic> json) => EventEntry(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String title;
    String description;
    int creator;
    String creatorUsername;
    String creatorPhoto;
    DateTime scheduledDate;
    String startTime;
    String endTime;
    String location;
    String eventType;
    String sportType;
    List<int> participants;

    Fields({
        required this.title,
        required this.description,
        required this.creator,
        required this.creatorUsername,
        required this.creatorPhoto,
        required this.scheduledDate,
        required this.startTime,
        required this.endTime,
        required this.location,
        required this.eventType,
        required this.sportType,
        required this.participants,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        title: json["title"],
        description: json["description"],
        creator: json["creator"],
        creatorUsername: json["creator_username"] ?? "Unknown",
        creatorPhoto: json["creator_photo"] ?? "",
        scheduledDate: DateTime.parse(json["scheduled_date"]),
        startTime: json["start_time"],
        endTime: json["end_time"],
        location: json["location"],
        eventType: json["event_type"],
        sportType: json["sport_type"],
        participants: List<int>.from(json["participants"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "creator": creator,
        "creator_username": creatorUsername,
        "creator_photo": creatorPhoto,
        "scheduled_date": "${scheduledDate.year.toString().padLeft(4, '0')}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')}",
        "start_time": startTime,
        "end_time": endTime,
        "location": location,
        "event_type": eventType,
        "sport_type": sportType,
        "participants": List<dynamic>.from(participants.map((x) => x)),
    };
}
