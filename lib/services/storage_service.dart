import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/constants.dart';

/// Service for handling Firebase Storage operations.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile photo from bytes and return download URL.
  Future<String> uploadProfilePhoto({
    required String userId,
    required Uint8List imageData,
    String? fileName,
  }) async {
    final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage
        .ref()
        .child(AppConstants.profilePhotosPath)
        .child(userId)
        .child(name);

    final uploadTask = ref.putData(
      imageData,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Upload profile photo from file and return download URL.
  Future<String> uploadProfilePhotoFile(
    String userId,
    File file, {
    String? fileName,
  }) async {
    final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage
        .ref()
        .child(AppConstants.profilePhotosPath)
        .child(userId)
        .child(name);

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Upload content image and return download URL.
  Future<String> uploadContentImage({
    required Uint8List imageData,
    required String folder,
    String? fileName,
  }) async {
    final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage
        .ref()
        .child(AppConstants.contentImagesPath)
        .child(folder)
        .child(name);

    final uploadTask = ref.putData(
      imageData,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Delete file by URL.
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // File may not exist, ignore error
    }
  }

  /// Get download URL for a storage path.
  Future<String> getDownloadUrl(String path) async {
    final ref = _storage.ref().child(path);
    return await ref.getDownloadURL();
  }
}
