import 'package:cloud_firestore/cloud_firestore.dart';

/// Poll data model representing a Boldask poll.
class PollModel {
  final String id;
  final String creatorUid;
  final String creatorName;
  final String? creatorPhotoUrl;
  final String question;
  final List<String> answers;
  final bool isPersonal; // true = Personal Growth, false = Social+Political
  final List<String> tags;
  final GeoPoint? location;
  final DateTime createdAt;
  final List<String> votedUserIds;
  final List<int> voteCounts;

  const PollModel({
    required this.id,
    required this.creatorUid,
    required this.creatorName,
    this.creatorPhotoUrl,
    required this.question,
    required this.answers,
    required this.isPersonal,
    this.tags = const [],
    this.location,
    required this.createdAt,
    this.votedUserIds = const [],
    this.voteCounts = const [],
  });

  /// Create PollModel from Firestore document.
  factory PollModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse answers from pollA1-5 fields or answers array
    List<String> answers = [];
    if (data['answers'] != null) {
      answers = List<String>.from(data['answers']);
    } else {
      // FlutterFlow format with pollA1, pollA2, etc.
      for (int i = 1; i <= 5; i++) {
        final answer = data['pollA$i'];
        if (answer != null && answer.toString().isNotEmpty) {
          answers.add(answer.toString());
        }
      }
    }

    return PollModel(
      id: doc.id,
      creatorUid: data['uid'] ?? data['creatorUid'] ?? '',
      creatorName: data['userDisplayName'] ?? data['creatorName'] ?? '',
      creatorPhotoUrl: data['userPhotoUrl'] ?? data['creatorPhotoUrl'],
      question: data['pollQ'] ?? data['question'] ?? '',
      answers: answers,
      isPersonal: data['pollIsPersonal'] ?? data['isPersonal'] ?? true,
      tags: List<String>.from(data['pollTags'] ?? data['tags'] ?? []),
      location: data['location'] as GeoPoint?,
      createdAt: (data['time'] ?? data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      votedUserIds: List<String>.from(data['voted_users'] ?? data['votedUserIds'] ?? []),
      voteCounts: List<int>.from(data['votes'] ?? data['voteCounts'] ?? []),
    );
  }

  /// Convert PollModel to Firestore document data.
  Map<String, dynamic> toFirestore() {
    return {
      'creatorUid': creatorUid,
      'creatorName': creatorName,
      'creatorPhotoUrl': creatorPhotoUrl,
      'question': question,
      'answers': answers,
      'isPersonal': isPersonal,
      'tags': tags,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'votedUserIds': votedUserIds,
      'voteCounts': voteCounts,
    };
  }

  /// Create a copy with updated fields.
  PollModel copyWith({
    String? question,
    List<String>? answers,
    bool? isPersonal,
    List<String>? tags,
    GeoPoint? location,
    List<String>? votedUserIds,
    List<int>? voteCounts,
  }) {
    return PollModel(
      id: id,
      creatorUid: creatorUid,
      creatorName: creatorName,
      creatorPhotoUrl: creatorPhotoUrl,
      question: question ?? this.question,
      answers: answers ?? this.answers,
      isPersonal: isPersonal ?? this.isPersonal,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      createdAt: createdAt,
      votedUserIds: votedUserIds ?? this.votedUserIds,
      voteCounts: voteCounts ?? this.voteCounts,
    );
  }

  /// Get total number of votes.
  int get totalVotes => voteCounts.fold(0, (sum, count) => sum + count);

  /// Check if a user has voted on this poll.
  bool hasUserVoted(String userId) => votedUserIds.contains(userId);

  /// Get vote percentage for an answer.
  double getVotePercentage(int answerIndex) {
    if (totalVotes == 0 || answerIndex >= voteCounts.length) return 0;
    return (voteCounts[answerIndex] / totalVotes) * 100;
  }

  /// Get category label.
  String get categoryLabel => isPersonal ? 'Personal Growth' : 'Social & Political';

  /// Empty poll for initialization.
  static PollModel empty() {
    return PollModel(
      id: '',
      creatorUid: '',
      creatorName: '',
      question: '',
      answers: [],
      isPersonal: true,
      createdAt: DateTime.now(),
    );
  }
}
