import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/helpers/firebase/firestore_provider.dart';

class NotificationModel {
  String? documentId;
  String? senderId;
  String? receiverId;
  String? entityType;
  String? entityId;
  String? title;
  int? seenStatus;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? groupId;
  String? invitedMemberName;

  NotificationModel(
      {this.documentId,
      this.senderId,
      this.receiverId,
      this.entityType,
      this.entityId,
      this.title,
      this.seenStatus,
      this.isActive,
      this.createdAt,
      this.updatedAt,
      this.groupId,
      this.invitedMemberName});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    this.documentId = json[NotificaitonCollectionField.documentId] == null
        ? ''
        : json[NotificaitonCollectionField.documentId];

    this.senderId = json[NotificaitonCollectionField.senderId] == null
        ? ''
        : json[NotificaitonCollectionField.senderId];

    this.receiverId = json[NotificaitonCollectionField.receiverId] == null
        ? ''
        : json[NotificaitonCollectionField.receiverId];

    this.entityType = json[NotificaitonCollectionField.entityType] == null
        ? ''
        : json[NotificaitonCollectionField.entityType];

    this.entityId = json[NotificaitonCollectionField.entityId] == null
        ? ''
        : json[NotificaitonCollectionField.entityId];

    this.title = json[NotificaitonCollectionField.title] == null
        ? ''
        : json[NotificaitonCollectionField.title];

    this.seenStatus = json[NotificaitonCollectionField.seenStatus] == null
        ? 0
        : json[NotificaitonCollectionField.seenStatus];

    this.isActive = json[NotificaitonCollectionField.isActive] == null
        ? false
        : json[NotificaitonCollectionField.isActive];

    this.createdAt = json[NotificaitonCollectionField.createdAt] == null
        ? DateTime.now()
        : (json[NotificaitonCollectionField.createdAt] as Timestamp).toDate();
    this.updatedAt = json[NotificaitonCollectionField.updatedAt] == null
        ? DateTime.now()
        : (json[NotificaitonCollectionField.updatedAt] as Timestamp).toDate();
    this.groupId = json[NotificaitonCollectionField.groupId] == null
        ? ''
        : json[NotificaitonCollectionField.groupId];
    this.invitedMemberName =
        json[NotificaitonCollectionField.invitedMemberName] == null
            ? ''
            : json[NotificaitonCollectionField.invitedMemberName];
  }
}
