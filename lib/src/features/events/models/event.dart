import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String organizerId;
  final String organizerName;
  final String location;
  final List<String> categories;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final int maxAttendees;
  final List<String> attendees;  final String? imageUrl;
  final double? ticketPrice;
  final bool? isSaved;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.organizerId,
    required this.organizerName,
    required this.location,
    required this.categories,
    required this.startDateTime,
    required this.endDateTime,
    required this.maxAttendees,    this.attendees = const [],
    this.imageUrl,
    this.ticketPrice,
    this.isSaved,
    required this.createdAt,
    required this.updatedAt,
  });

  Event copyWith({
    String? title,
    String? description,
    String? location,    List<String>? categories,
    DateTime? startDateTime,
    DateTime? endDateTime,
    int? maxAttendees,
    List<String>? attendees,
    String? imageUrl,
    double? ticketPrice,
    bool? isSaved,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      organizerId: organizerId,
      organizerName: organizerName,
      location: location ?? this.location,
      categories: categories ?? this.categories,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      maxAttendees: maxAttendees ?? this.maxAttendees,      attendees: attendees ?? this.attendees,
      imageUrl: imageUrl ?? this.imageUrl,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

// UI compatibility getters
  DateTime get startDate => startDateTime;
  DateTime get endDate => endDateTime;

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'location': location,
      'categories': categories,
      'startDateTime': Timestamp.fromDate(startDateTime),
      'endDateTime': Timestamp.fromDate(endDateTime),
      'maxAttendees': maxAttendees,
      'attendees': attendees,
      'imageUrl': imageUrl,      'ticketPrice': ticketPrice,
      'isSaved': isSaved,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      organizerId: data['organizerId'] as String,
      organizerName: data['organizerName'] as String,
      location: data['location'] as String,
      categories: List<String>.from(data['categories'] ?? []),
      startDateTime: (data['startDateTime'] as Timestamp).toDate(),
      endDateTime: (data['endDateTime'] as Timestamp).toDate(),
      maxAttendees: data['maxAttendees'] as int,
      attendees: List<String>.from(data['attendees'] ?? []),
      imageUrl: data['imageUrl'] as String?,
      ticketPrice: (data['ticketPrice'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
