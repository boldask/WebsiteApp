import 'package:cloud_firestore/cloud_firestore.dart';

/// Project data model (Coming Soon feature).
class ProjectModel {
  final String id;
  final String creatorUid;
  final String creatorName;
  final String? creatorPhotoUrl;
  final String title;
  final String description;
  final List<String> tags;
  final List<String> memberIds;
  final DateTime createdAt;

  const ProjectModel({
    required this.id,
    required this.creatorUid,
    required this.creatorName,
    this.creatorPhotoUrl,
    required this.title,
    required this.description,
    this.tags = const [],
    this.memberIds = const [],
    required this.createdAt,
  });

  /// Create ProjectModel from Firestore document.
  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      creatorUid: data['creatorUid'] ?? '',
      creatorName: data['creatorName'] ?? '',
      creatorPhotoUrl: data['creatorPhotoUrl'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      memberIds: List<String>.from(data['memberIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert ProjectModel to Firestore document data.
  Map<String, dynamic> toFirestore() {
    return {
      'creatorUid': creatorUid,
      'creatorName': creatorName,
      'creatorPhotoUrl': creatorPhotoUrl,
      'title': title,
      'description': description,
      'tags': tags,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Get member count.
  int get memberCount => memberIds.length;

  /// Empty project for initialization.
  static ProjectModel empty() {
    return ProjectModel(
      id: '',
      creatorUid: '',
      creatorName: '',
      title: '',
      description: '',
      createdAt: DateTime.now(),
    );
  }
}
