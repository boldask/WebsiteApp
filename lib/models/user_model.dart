import 'package:cloud_firestore/cloud_firestore.dart';

/// User data model representing a Boldask user.
class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? location;
  final List<String> pollIds;
  final List<String> circleIds;
  final List<String> projectIds;
  final List<String> followers;
  final List<String> following;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.location,
    this.pollIds = const [],
    this.circleIds = const [],
    this.projectIds = const [],
    this.followers = const [],
    this.following = const [],
    required this.createdAt,
  });

  /// Create UserModel from Firestore document.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      location: data['location'],
      pollIds: List<String>.from(data['polls'] ?? []),
      circleIds: List<String>.from(data['circles'] ?? []),
      projectIds: List<String>.from(data['projects'] ?? []),
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert UserModel to Firestore document data.
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'location': location,
      'polls': pollIds,
      'circles': circleIds,
      'projects': projectIds,
      'followers': followers,
      'following': following,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with updated fields.
  UserModel copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    String? location,
    List<String>? pollIds,
    List<String>? circleIds,
    List<String>? projectIds,
    List<String>? followers,
    List<String>? following,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      location: location ?? this.location,
      pollIds: pollIds ?? this.pollIds,
      circleIds: circleIds ?? this.circleIds,
      projectIds: projectIds ?? this.projectIds,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      createdAt: createdAt,
    );
  }

  /// Get total number of polls created.
  int get pollCount => pollIds.length;

  /// Get total number of circles created.
  int get circleCount => circleIds.length;

  /// Get total number of followers.
  int get followerCount => followers.length;

  /// Get total number of users being followed.
  int get followingCount => following.length;

  /// Check if user is following another user.
  bool isFollowing(String userId) => following.contains(userId);

  /// Check if user is followed by another user.
  bool isFollowedBy(String userId) => followers.contains(userId);

  /// Empty user for initialization.
  static UserModel empty() {
    return UserModel(
      uid: '',
      displayName: '',
      email: '',
      createdAt: DateTime.now(),
    );
  }
}
