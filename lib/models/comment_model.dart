import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/helpers/firebase/firestore_provider.dart';

class CommentModel {
  String? documentId;
  String? comment;
  String? userFullName;
  String? userId;
  String? userMobileNumber;
  String? userProfilePicture;
  String? userName;
  String? postId;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? status;
  CommentModel({
    this.documentId,
    this.comment,
    this.userFullName,
    this.userId,
    this.userMobileNumber,
    this.userProfilePicture,
    this.userName,
    this.postId,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  CommentModel.fromJson(Map<String, dynamic> json) {
    this.documentId = json[CommentCollectionField.documentId] == null
        ? ''
        : json[CommentCollectionField.documentId];

    this.comment = json[CommentCollectionField.comment] == null
        ? ''
        : json[CommentCollectionField.comment];
    this.userFullName = json[CommentCollectionField.userFullName] == null
        ? ''
        : json[CommentCollectionField.userFullName];
    this.userId = json[CommentCollectionField.userId] == null
        ? ''
        : json[CommentCollectionField.userId];
    this.userMobileNumber =
        json[CommentCollectionField.userMobileNumber] == null
            ? ''
            : json[CommentCollectionField.userMobileNumber];
    this.userProfilePicture =
        json[CommentCollectionField.userProfilePhoto] == null
            ? ''
            : json[CommentCollectionField.userProfilePhoto];
    this.userName = json[CommentCollectionField.username] == null
        ? ''
        : json[CommentCollectionField.username];
    this.postId = json[CommentCollectionField.postId] == null
        ? ''
        : json[CommentCollectionField.postId];
    this.createdAt = json[CommentCollectionField.createdAt] == null
        ? DateTime.now()
        : (json[CommentCollectionField.createdAt] as Timestamp).toDate();
    this.updatedAt = json[CommentCollectionField.updatedAt] == null
        ? DateTime.now()
        : (json[CommentCollectionField.updatedAt] as Timestamp).toDate();
    this.status = json[CommentCollectionField.status] == null
        ? false
        : json[CommentCollectionField.status];
  }
}
