import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;

class StorageProvider {
  static StorageProvider? _instance;
  static firebase_storage.FirebaseStorage? _storage;

  static StorageProvider get instance =>
      _instance ?? StorageProvider._internal();

  //factory StorageProvider() => _instance ?? StorageProvider._internal();

  StorageProvider._internal() {
    _storage = firebase_storage.FirebaseStorage.instance;

    _instance = this;
  }

  Future<void> uploadFile(
      {required File? profilePic,
      String? fileName,
      Function(String)? onSuccess,
      Function(String)? onError}) async {
    firebase_storage.Reference refProfilePic = _storage!
        .ref()
        .child('user_profile_photo')
        .child(fileName ?? Path.basename(profilePic!.path));

    try {
      await refProfilePic.putFile(profilePic!);
      refProfilePic.getDownloadURL().then((String imageUrl) {
        return onSuccess!(imageUrl);
      });
    } on firebase_core.FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      return onError!(e.message!);
    }
  }

  Future<String?> uploadPostAttachment({
    required File? profilePic,
    String? fileName,
  }) async {
    firebase_storage.Reference refProfilePic = _storage!
        .ref()
        .child('post_attachment')
        .child(fileName ?? Path.basename(profilePic!.path));

    try {
      await refProfilePic.putFile(profilePic!);
      return refProfilePic.getDownloadURL().then((String imageUrl) {
        return imageUrl;
      });
    } on firebase_core.FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      return null;
    }
  }

  Future<bool> deleteFile({required String? fileUrl}) async {
    return _storage!.refFromURL(fileUrl!).delete().then((_) {
      return true;
    }).catchError((onError) {
      return false;
    });
  }
}
