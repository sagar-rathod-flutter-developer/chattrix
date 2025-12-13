import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileRepository {
  Future<void> uploadProfileImage(File file) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseStorage.instance
        .ref('profile_images/$uid.jpg');

    // upload
    await ref.putFile(file);

    // get url AFTER upload
    final imageUrl = await ref.getDownloadURL();

    // save in firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'imageUrl': imageUrl});
  }
}
