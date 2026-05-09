import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static ProfileService? _instance;
  static ProfileService get instance {
    _instance ??= ProfileService._();
    return _instance!;
  }

  ProfileService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _cachedProfileUrl;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<String?> getProfileUrl() async {
    if (_cachedProfileUrl != null) {
      return _cachedProfileUrl;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _cachedProfileUrl = data['profileImageUrl'] as String?;
        return _cachedProfileUrl;
      }
    } catch (e) {
      debugPrint('ProfileService: Error getting profile URL: $e');
    }

    return null;
  }

  Future<String?> uploadProfilePicture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    _isLoading = true;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image == null) {
        _isLoading = false;
        return null;
      }

      final file = File(image.path);
      final fileName = 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final storageRef = _storage.ref().child('profile_pictures/$fileName');
      
      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': user.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': downloadUrl,
        'profileImageUpdatedAt': FieldValue.serverTimestamp(),
      });

      _cachedProfileUrl = downloadUrl;
      _isLoading = false;
      
      debugPrint('ProfileService: Profile picture uploaded successfully');
      return downloadUrl;
    } catch (e) {
      _isLoading = false;
      debugPrint('ProfileService: Error uploading profile picture: $e');
      rethrow;
    }
  }

  Future<void> removeProfilePicture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': FieldValue.delete(),
        'profileImageUpdatedAt': FieldValue.serverTimestamp(),
      });

      _cachedProfileUrl = null;
      debugPrint('ProfileService: Profile picture removed');
    } catch (e) {
      debugPrint('ProfileService: Error removing profile picture: $e');
      rethrow;
    }
  }

  void clearCache() {
    _cachedProfileUrl = null;
  }
}