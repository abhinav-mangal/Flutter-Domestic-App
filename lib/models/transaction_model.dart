import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/helpers/firebase/firestore_provider.dart';

class TransactionModel {
  String? documentId;
  String? userId;
  String? transactionId;
  String? transactionEntryMode;
  String? transactionEntryType;
  String? transactionDescription;
  String? referralUserId;
  double? amount;
  double? wattsGenerated;
  bool? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  TransactionModel({
    this.documentId,
    this.userId,
    this.transactionId,
    this.transactionEntryMode,
    this.transactionEntryType,
    this.transactionDescription,
    this.referralUserId,
    this.amount,
    this.wattsGenerated,
    this.status,
    this.updatedAt,
    this.createdAt,
  });

  TransactionModel.fromJson(Map<String, dynamic> json) {
    this.documentId = json[TransactionCollectionField.documentId] == null
        ? ''
        : json[TransactionCollectionField.documentId];
    this.userId = json[TransactionCollectionField.userId] == null
        ? ''
        : json[TransactionCollectionField.userId];
    this.transactionId = json[TransactionCollectionField.transactionId] == null
        ? ''
        : json[TransactionCollectionField.transactionId];

    this.transactionEntryMode =
        json[TransactionCollectionField.transactionEntryMode] == null
            ? ''
            : json[TransactionCollectionField.transactionEntryMode];

    this.transactionEntryType =
        json[TransactionCollectionField.transactionEntryType] == null
            ? ''
            : json[TransactionCollectionField.transactionEntryType];
    this.transactionDescription =
        json[TransactionCollectionField.transactionDescription] == null
            ? ''
            : json[TransactionCollectionField.transactionDescription];

    this.referralUserId =
        json[TransactionCollectionField.referralUserId] == null
            ? ''
            : json[TransactionCollectionField.referralUserId];

    this.amount = json[TransactionCollectionField.amount] == null
        ? 0.0
        : json[TransactionCollectionField.amount];

    this.wattsGenerated =
        json[TransactionCollectionField.wattsGenerated] == null
            ? 0.0
            : json[TransactionCollectionField.wattsGenerated];

    this.status = json[TransactionCollectionField.status] == null
        ? false
        : json[TransactionCollectionField.status];

    this.createdAt = json[TransactionCollectionField.createdAt] == null
        ? DateTime.now()
        : (json[TransactionCollectionField.createdAt] as Timestamp).toDate();
    this.updatedAt = json[TransactionCollectionField.updatedAt] == null
        ? DateTime.now()
        : (json[TransactionCollectionField.updatedAt] as Timestamp).toDate();
  }
}
