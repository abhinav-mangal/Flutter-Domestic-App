import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/helpers/firebase/auth_provider.dart';
import '../utils/helpers/firebase/firestore_provider.dart';

class FeedModel {
  String? documentId;
  List<String>? attachment;
  DateTime? createdAt;
  String? title;
  Map<String, dynamic>? data;
  String? type;
  String? userFullName;
  String? userId;
  String? userMobileNumber;
  String? userProfilePicture;
  String? userName;
  bool? isUserPost;
  FeedModel({
    this.documentId,
    this.attachment,
    this.createdAt,
    this.title,
    this.data,
    this.type,
    this.userFullName,
    this.userId,
    this.userMobileNumber,
    this.userProfilePicture,
    this.userName,
    this.isUserPost,
  });

  FeedModel.fromJson(Map<String, dynamic> json) {
    String _loggedInUserId = AuthProvider.instance.currentUserId();

    this.documentId = json[PostCollectionField.documentId] == null
        ? ''
        : json[PostCollectionField.documentId];
    this.attachment = json[PostCollectionField.attachment] == null
        ? []
        : List<String>.from(json[PostCollectionField.attachment].map((x) => x));
    this.createdAt = json[PostCollectionField.createdAt] == null
        ? DateTime.now()
        : (json[PostCollectionField.createdAt] as Timestamp).toDate();
    this.title = json[PostCollectionField.title] == null
        ? ''
        : json[PostCollectionField.title];
    this.data = json[PostCollectionField.data] == null
        ? {}
        : json[PostCollectionField.data];
    this.type = json[PostCollectionField.type] == null
        ? ''
        : json[PostCollectionField.type];
    this.userFullName = json[PostCollectionField.userFullName] == null
        ? ''
        : json[PostCollectionField.userFullName];
    this.userId = json[PostCollectionField.userId] == null
        ? ''
        : json[PostCollectionField.userId];
    this.userMobileNumber = json[PostCollectionField.userMobileNumber] == null
        ? ''
        : json[PostCollectionField.userMobileNumber];
    this.userProfilePicture = json[PostCollectionField.userProfilePhoto] == null
        ? ''
        : json[PostCollectionField.userProfilePhoto];
    this.userName = json[PostCollectionField.username] == null
        ? ''
        : json[PostCollectionField.username];
    this.isUserPost = _loggedInUserId == this.userId;
  }

  Future<bool> isLiked(String userId) async {
    bool isLiked = false;
    isLiked = await FireStoreProvider.instance
        .isLiked(uesrId: userId, postId: this.documentId);
    return isLiked;
  }
}
