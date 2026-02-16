import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(String userId, String filePath) async {
    final ref = _storage.ref().child('profile_images/$userId.jpg');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  Future<String> uploadEventFlyer(String eventId, String filePath) async {
    final ref = _storage.ref().child('event_flyers/$eventId.jpg');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }
}
