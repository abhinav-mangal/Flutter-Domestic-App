import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/helpers/firebase/firestore_provider.dart';

class GroupModel {
  String? documentId;
  String? groupName;
  String? groupProfile;
  String? adminId;
  bool? isActive;
  List<String>? participantId;
  List<String>? participantName;
  List<String>? participantInviteId;
  List<String>? participantInviteName;

  DateTime? createdAt;
  String? groupType;
  int? totalWatts;

  GroupModel(
      {this.documentId,
      this.groupName,
      this.groupProfile,
      this.adminId,
      this.isActive,
      this.participantId,
      this.participantName,
      this.createdAt,
      this.groupType,
      this.totalWatts});

  GroupModel.fromJson(Map<String, dynamic> json) {
    this.documentId = json[GroupCollectionField.documentId] == null
        ? ''
        : json[GroupCollectionField.documentId];

    this.groupName = json[GroupCollectionField.groupName] == null
        ? ''
        : json[GroupCollectionField.groupName];
    this.groupProfile = json[GroupCollectionField.groupProfile] == null
        ? ''
        : json[GroupCollectionField.groupProfile];
    this.adminId = json[GroupCollectionField.adminId] == null
        ? ''
        : json[GroupCollectionField.adminId];
    this.isActive = json[GroupCollectionField.isActivie] == null
        ? false
        : json[GroupCollectionField.isActivie];
    this.participantId = json[GroupCollectionField.participantId] == null
        ? []
        : List<String>.from(
            json[GroupCollectionField.participantId].map((x) => x));

    this.participantName = json[GroupCollectionField.participantName] == null
        ? []
        : List<String>.from(
            json[GroupCollectionField.participantName].map((x) => x));

    this.createdAt = json[GroupCollectionField.createdAt] == null
        ? DateTime.now()
        : (json[GroupCollectionField.createdAt] as Timestamp).toDate();
    this.groupType = json[GroupCollectionField.groupType] == null
        ? ''
        : json[GroupCollectionField.groupType];
    this.totalWatts = json[GroupCollectionField.totalWatts] == null
        ? 0
        : json[GroupCollectionField.totalWatts];
    this.participantInviteId =
        json[GroupCollectionField.participantInviteId] == null
            ? []
            : List<String>.from(
                json[GroupCollectionField.participantInviteId].map((x) => x));

    this.participantInviteName =
        json[GroupCollectionField.participantInviteName] == null
            ? []
            : List<String>.from(
                json[GroupCollectionField.participantInviteName].map((x) => x));
  }
}
