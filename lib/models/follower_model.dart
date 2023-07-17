import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/helpers/firebase/firestore_provider.dart';

class FollowerModel {
  String? documentId;
  String? userId;
  String? userMobileNumber;
  String? userProfilePhoto;
  String? userFullName;
  String? username;
  String? followerId;
  String? followerMobileNumber;
  String? followerProfilePhoto;
  String? followerFullName;
  String? followerUsername;
  bool? status;
  DateTime? createdAt;
  DateTime? deletedAt;
  DateTime? updatedAt;

  FollowerModel({
    this.documentId,
    this.userId,
    this.userMobileNumber,
    this.userProfilePhoto,
    this.userFullName,
    this.username,
    this.followerId,
    this.followerMobileNumber,
    this.followerProfilePhoto,
    this.followerFullName,
    this.followerUsername,
    this.status,
    this.createdAt,
    this.deletedAt,
    this.updatedAt,
  });

  FollowerModel.fromJson(Map<String, dynamic> json) {
    this.documentId = json[FollowerCollectionField.documentId] == null
        ? ''
        : json[FollowerCollectionField.documentId];
    this.userId = json[FollowerCollectionField.userId] == null
        ? ''
        : json[FollowerCollectionField.userId];
    this.userMobileNumber =
        json[FollowerCollectionField.userMobileNumber] == null
            ? ''
            : json[FollowerCollectionField.userMobileNumber];
    this.userProfilePhoto =
        json[FollowerCollectionField.userProfilePhoto] == null
            ? ''
            : json[FollowerCollectionField.userProfilePhoto];
    this.userFullName = json[FollowerCollectionField.userFullName] == null
        ? ''
        : json[FollowerCollectionField.userFullName];
    this.username = json[FollowerCollectionField.username] == null
        ? ''
        : json[FollowerCollectionField.username];
    this.followerId = json[FollowerCollectionField.followerId] == null
        ? ''
        : json[FollowerCollectionField.followerId];
    this.followerMobileNumber =
        json[FollowerCollectionField.followerMobileNumber] == null
            ? ''
            : json[FollowerCollectionField.followerMobileNumber];
    this.followerProfilePhoto =
        json[FollowerCollectionField.followerProfilePhoto] == null
            ? ''
            : json[FollowerCollectionField.followerProfilePhoto];
    this.followerFullName =
        json[FollowerCollectionField.followerFullName] == null
            ? ''
            : json[FollowerCollectionField.followerFullName];
    this.followerUsername =
        json[FollowerCollectionField.followerUsername] == null
            ? ''
            : json[FollowerCollectionField.followerUsername];

    this.status = json[FollowerCollectionField.status] == null
        ? false
        : json[FollowerCollectionField.status];
    this.createdAt = json[FollowerCollectionField.createdAt] == null
        ? DateTime.now()
        : (json[FollowerCollectionField.createdAt] as Timestamp).toDate();
    this.updatedAt = json[FollowerCollectionField.updatedAt] == null
        ? DateTime.now()
        : (json[FollowerCollectionField.updatedAt] as Timestamp).toDate();
    this.deletedAt = json[FollowerCollectionField.deletedAt] == null
        ? DateTime.now()
        : (json[FollowerCollectionField.deletedAt] as Timestamp).toDate();
  }
}
