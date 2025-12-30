import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';

/// Circle data model representing a Boldask circle/event.
class CircleModel {
  final String id;
  final String creatorUid;
  final String creatorName;
  final String? creatorPhotoUrl;
  final String title;
  final String description;
  final CircleFormat format;
  final String? meetingLink;
  final String? address;
  final int? inPersonCapacity;
  final int? onlineCapacity;
  final DateTime scheduledDate;
  final List<String> tags;
  final List<String> attendeeIds;
  final DateTime createdAt;

  const CircleModel({
    required this.id,
    required this.creatorUid,
    required this.creatorName,
    this.creatorPhotoUrl,
    required this.title,
    required this.description,
    required this.format,
    this.meetingLink,
    this.address,
    this.inPersonCapacity,
    this.onlineCapacity,
    required this.scheduledDate,
    this.tags = const [],
    this.attendeeIds = const [],
    required this.createdAt,
  });

  /// Create CircleModel from Firestore document.
  factory CircleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse format
    CircleFormat format = CircleFormat.online;
    final formatValue = data['circleFormatValue'] ?? data['format'];
    if (formatValue != null) {
      if (formatValue.toString().toLowerCase().contains('person')) {
        format = CircleFormat.inPerson;
      } else if (formatValue.toString().toLowerCase().contains('both')) {
        format = CircleFormat.both;
      }
    }

    return CircleModel(
      id: doc.id,
      creatorUid: data['uid'] ?? data['creatorUid'] ?? '',
      creatorName: data['userDisplayName'] ?? data['creatorName'] ?? '',
      creatorPhotoUrl: data['userPhotoUrl'] ?? data['creatorPhotoUrl'],
      title: data['circleTitle'] ?? data['title'] ?? '',
      description: data['circleDescription'] ?? data['description'] ?? '',
      format: format,
      meetingLink: data['circleLink'] ?? data['meetingLink'],
      address: data['circleAddress'] ?? data['address'],
      inPersonCapacity: data['addressLimitValue'] ?? data['inPersonCapacity'],
      onlineCapacity: data['onlineLimitValue'] ?? data['onlineCapacity'],
      scheduledDate: _parseDateTime(data['circleDate'], data['circleTime']) ??
          (data['scheduledDate'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      tags: List<String>.from(data['circleTags'] ?? data['tags'] ?? []),
      attendeeIds: List<String>.from(data['attended_users'] ?? data['attendeeIds'] ?? []),
      createdAt: (data['time'] ?? data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Parse date and time from FlutterFlow format.
  static DateTime? _parseDateTime(dynamic date, dynamic time) {
    if (date == null) return null;

    DateTime dateValue;
    if (date is Timestamp) {
      dateValue = date.toDate();
    } else if (date is String) {
      dateValue = DateTime.tryParse(date) ?? DateTime.now();
    } else {
      return null;
    }

    if (time is Timestamp) {
      final timeValue = time.toDate();
      return DateTime(
        dateValue.year,
        dateValue.month,
        dateValue.day,
        timeValue.hour,
        timeValue.minute,
      );
    }

    return dateValue;
  }

  /// Convert CircleModel to Firestore document data.
  Map<String, dynamic> toFirestore() {
    return {
      'creatorUid': creatorUid,
      'creatorName': creatorName,
      'creatorPhotoUrl': creatorPhotoUrl,
      'title': title,
      'description': description,
      'format': format.name,
      'meetingLink': meetingLink,
      'address': address,
      'inPersonCapacity': inPersonCapacity,
      'onlineCapacity': onlineCapacity,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'tags': tags,
      'attendeeIds': attendeeIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with updated fields.
  CircleModel copyWith({
    String? title,
    String? description,
    CircleFormat? format,
    String? meetingLink,
    String? address,
    int? inPersonCapacity,
    int? onlineCapacity,
    DateTime? scheduledDate,
    List<String>? tags,
    List<String>? attendeeIds,
  }) {
    return CircleModel(
      id: id,
      creatorUid: creatorUid,
      creatorName: creatorName,
      creatorPhotoUrl: creatorPhotoUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      format: format ?? this.format,
      meetingLink: meetingLink ?? this.meetingLink,
      address: address ?? this.address,
      inPersonCapacity: inPersonCapacity ?? this.inPersonCapacity,
      onlineCapacity: onlineCapacity ?? this.onlineCapacity,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      tags: tags ?? this.tags,
      attendeeIds: attendeeIds ?? this.attendeeIds,
      createdAt: createdAt,
    );
  }

  /// Get total number of attendees.
  int get attendeeCount => attendeeIds.length;

  /// Check if a user is attending.
  bool isUserAttending(String userId) => attendeeIds.contains(userId);

  /// Check if circle has available spots.
  bool get hasAvailableSpots {
    final totalCapacity = (inPersonCapacity ?? 0) + (onlineCapacity ?? 0);
    return totalCapacity == 0 || attendeeCount < totalCapacity;
  }

  /// Get remaining spots.
  int? get remainingSpots {
    final totalCapacity = (inPersonCapacity ?? 0) + (onlineCapacity ?? 0);
    if (totalCapacity == 0) return null;
    return totalCapacity - attendeeCount;
  }

  /// Check if circle is in the past.
  bool get isPast => scheduledDate.isBefore(DateTime.now());

  /// Empty circle for initialization.
  static CircleModel empty() {
    return CircleModel(
      id: '',
      creatorUid: '',
      creatorName: '',
      title: '',
      description: '',
      format: CircleFormat.online,
      scheduledDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }
}
