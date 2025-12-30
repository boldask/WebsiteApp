import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';
import '../models/user_model.dart';
import '../models/poll_model.dart';
import '../models/circle_model.dart';

/// Service for handling Firestore database operations.
class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USERS ====================

  /// Get user by ID.
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Stream user data.
  Stream<UserModel?> streamUser(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Update user profile.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  /// Search users by display name.
  Future<List<UserModel>> searchUsers(String query) async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// Follow a user.
  Future<void> followUser(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();

    // Add to current user's following
    batch.update(
      _firestore.collection(AppConstants.usersCollection).doc(currentUserId),
      {'following': FieldValue.arrayUnion([targetUserId])},
    );

    // Add to target user's followers
    batch.update(
      _firestore.collection(AppConstants.usersCollection).doc(targetUserId),
      {'followers': FieldValue.arrayUnion([currentUserId])},
    );

    await batch.commit();
  }

  /// Unfollow a user.
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();

    // Remove from current user's following
    batch.update(
      _firestore.collection(AppConstants.usersCollection).doc(currentUserId),
      {'following': FieldValue.arrayRemove([targetUserId])},
    );

    // Remove from target user's followers
    batch.update(
      _firestore.collection(AppConstants.usersCollection).doc(targetUserId),
      {'followers': FieldValue.arrayRemove([currentUserId])},
    );

    await batch.commit();
  }

  // ==================== POLLS ====================

  /// Create a new poll.
  Future<String> createPoll(PollModel poll) async {
    final docRef = await _firestore
        .collection(AppConstants.pollsCollection)
        .add(poll.toFirestore());

    // Add poll ID to user's polls
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(poll.creatorUid)
        .update({'polls': FieldValue.arrayUnion([docRef.id])});

    return docRef.id;
  }

  /// Get poll by ID.
  Future<PollModel?> getPoll(String pollId) async {
    final doc = await _firestore
        .collection(AppConstants.pollsCollection)
        .doc(pollId)
        .get();
    if (!doc.exists) return null;
    return PollModel.fromFirestore(doc);
  }

  /// Stream poll data.
  Stream<PollModel?> streamPoll(String pollId) {
    return _firestore
        .collection(AppConstants.pollsCollection)
        .doc(pollId)
        .snapshots()
        .map((doc) => doc.exists ? PollModel.fromFirestore(doc) : null);
  }

  /// Get polls with pagination.
  Future<List<PollModel>> getPolls({
    int limit = AppConstants.defaultPageSize,
    DocumentSnapshot? startAfter,
    bool? isPersonal,
    List<String>? tags,
    String? creatorUid,
  }) async {
    Query query = _firestore
        .collection(AppConstants.pollsCollection)
        .orderBy('createdAt', descending: true);

    if (isPersonal != null) {
      query = query.where('isPersonal', isEqualTo: isPersonal);
    }

    if (tags != null && tags.isNotEmpty) {
      query = query.where('tags', arrayContainsAny: tags);
    }

    if (creatorUid != null) {
      query = query.where('creatorUid', isEqualTo: creatorUid);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => PollModel.fromFirestore(doc)).toList();
  }

  /// Vote on a poll.
  Future<void> votePoll(String pollId, String oderId, int answerIndex) async {
    await _firestore.runTransaction((transaction) async {
      final pollDoc = await transaction.get(
        _firestore.collection(AppConstants.pollsCollection).doc(pollId),
      );

      if (!pollDoc.exists) throw Exception('Poll not found');

      final poll = PollModel.fromFirestore(pollDoc);

      if (poll.hasUserVoted(oderId)) {
        throw Exception('You have already voted on this poll');
      }

      // Update vote counts
      final newVoteCounts = List<int>.from(poll.voteCounts);
      if (newVoteCounts.length <= answerIndex) {
        // Extend the list if needed
        while (newVoteCounts.length <= answerIndex) {
          newVoteCounts.add(0);
        }
      }
      newVoteCounts[answerIndex]++;

      transaction.update(pollDoc.reference, {
        'votedUserIds': FieldValue.arrayUnion([oderId]),
        'voteCounts': newVoteCounts,
      });
    });
  }

  /// Delete a poll.
  Future<void> deletePoll(String pollId, String creatorUid) async {
    await _firestore
        .collection(AppConstants.pollsCollection)
        .doc(pollId)
        .delete();

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(creatorUid)
        .update({'polls': FieldValue.arrayRemove([pollId])});
  }

  /// Get polls by creator.
  Future<List<PollModel>> getPollsByCreator(String creatorUid) async {
    final snapshot = await _firestore
        .collection(AppConstants.pollsCollection)
        .where('creatorUid', isEqualTo: creatorUid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs.map((doc) => PollModel.fromFirestore(doc)).toList();
  }

  // ==================== CIRCLES ====================

  /// Create a new circle.
  Future<String> createCircle(CircleModel circle) async {
    final docRef = await _firestore
        .collection(AppConstants.circlesCollection)
        .add(circle.toFirestore());

    // Add circle ID to user's circles
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(circle.creatorUid)
        .update({'circles': FieldValue.arrayUnion([docRef.id])});

    return docRef.id;
  }

  /// Get circle by ID.
  Future<CircleModel?> getCircle(String circleId) async {
    final doc = await _firestore
        .collection(AppConstants.circlesCollection)
        .doc(circleId)
        .get();
    if (!doc.exists) return null;
    return CircleModel.fromFirestore(doc);
  }

  /// Stream circle data.
  Stream<CircleModel?> streamCircle(String circleId) {
    return _firestore
        .collection(AppConstants.circlesCollection)
        .doc(circleId)
        .snapshots()
        .map((doc) => doc.exists ? CircleModel.fromFirestore(doc) : null);
  }

  /// Get circles with pagination.
  Future<List<CircleModel>> getCircles({
    int limit = AppConstants.defaultPageSize,
    DocumentSnapshot? startAfter,
    List<String>? tags,
    String? creatorUid,
    bool upcomingOnly = false,
  }) async {
    Query query = _firestore
        .collection(AppConstants.circlesCollection)
        .orderBy('scheduledDate', descending: false);

    if (upcomingOnly) {
      query = query.where('scheduledDate', isGreaterThan: Timestamp.now());
    }

    if (tags != null && tags.isNotEmpty) {
      query = query.where('tags', arrayContainsAny: tags);
    }

    if (creatorUid != null) {
      query = query.where('creatorUid', isEqualTo: creatorUid);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => CircleModel.fromFirestore(doc)).toList();
  }

  /// Join a circle.
  Future<void> joinCircle(String circleId, String userId) async {
    await _firestore
        .collection(AppConstants.circlesCollection)
        .doc(circleId)
        .update({
      'attendeeIds': FieldValue.arrayUnion([userId]),
    });
  }

  /// Leave a circle.
  Future<void> leaveCircle(String circleId, String userId) async {
    await _firestore
        .collection(AppConstants.circlesCollection)
        .doc(circleId)
        .update({
      'attendeeIds': FieldValue.arrayRemove([userId]),
    });
  }

  /// Delete a circle.
  Future<void> deleteCircle(String circleId, String creatorUid) async {
    await _firestore
        .collection(AppConstants.circlesCollection)
        .doc(circleId)
        .delete();

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(creatorUid)
        .update({'circles': FieldValue.arrayRemove([circleId])});
  }

  /// Get circles by creator.
  Future<List<CircleModel>> getCirclesByCreator(String creatorUid) async {
    final snapshot = await _firestore
        .collection(AppConstants.circlesCollection)
        .where('creatorUid', isEqualTo: creatorUid)
        .orderBy('scheduledDate', descending: false)
        .limit(50)
        .get();
    return snapshot.docs.map((doc) => CircleModel.fromFirestore(doc)).toList();
  }

  // ==================== SITE CONTENT ====================

  /// Get site content by key.
  Future<Map<String, dynamic>?> getSiteContent(String key) async {
    final doc = await _firestore
        .collection(AppConstants.siteContentCollection)
        .doc(key)
        .get();
    return doc.data();
  }

  /// Get news articles.
  Future<List<Map<String, dynamic>>> getNews({int limit = 10}) async {
    final snapshot = await _firestore
        .collection(AppConstants.newsCollection)
        .where('isPublished', isEqualTo: true)
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }
}
