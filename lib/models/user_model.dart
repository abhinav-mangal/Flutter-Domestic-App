import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/helpers/firebase/firestore_provider.dart';

class UserModel {
  String? documentId;
  int? activeMinuteGoal;
  int? activityGoal;
  int? activityLevel;
  String? address;
  DateTime? birthDate;
  String? gender;
  int? calorieGoal;
  String? countryCode;
  int? currStep;
  String? email;
  int? energyGenerateGoal;
  String? fullName;
  String? height;
  String? heightType;
  bool? isActive;
  bool? isVerified;
  String? latLong;
  String? mobileNumber;
  String? profilePhoto;
  String? socialId;
  String? socialLoginType;
  double? sweatcoinBalance;
  String? sweatcoinId;
  String? sweatcoinTransactions;
  String? username;
  double? wight;
  String? wightType;
  int? followers;
  bool? isFollowing;
  String? deviceToken;
  String? deviceType;
  String? jwtToken;
  int? resistence;
  int? watts;
  int? calories;
  int? cadence;
  String? timeZoneName;
  int? ftpValue;
  int? workoutCount;
  int? ftpLeaderboard;
  int? level;
  String? levelName;
  String? badge;
  int? workoutCountInLevel;
  int? generatedenergy;

  UserModel(
      {this.documentId,
      this.activeMinuteGoal,
      this.activityGoal,
      this.activityLevel,
      this.address,
      this.birthDate,
      this.gender,
      this.calorieGoal,
      this.countryCode,
      this.currStep,
      this.email,
      this.energyGenerateGoal,
      this.fullName,
      this.height,
      this.heightType,
      this.isActive,
      this.isVerified,
      this.latLong,
      this.mobileNumber,
      this.profilePhoto,
      this.socialId,
      this.socialLoginType,
      this.sweatcoinBalance,
      this.sweatcoinId,
      this.sweatcoinTransactions,
      this.username,
      this.wight,
      this.wightType,
      this.followers,
      this.isFollowing,
      this.deviceToken,
      this.deviceType,
      this.jwtToken,
      this.resistence,
      this.watts,
      this.calories,
      this.cadence,
      this.timeZoneName,
      this.ftpValue,
      this.workoutCount,
      this.ftpLeaderboard,
      this.level,
      this.levelName,
      this.badge,
      this.workoutCountInLevel,
      this.generatedenergy});

  UserModel.fromsnapshot(DocumentSnapshot? snapshpt) {
    documentId = snapshpt!.id;
    activeMinuteGoal = snapshpt[UserCollectionField.activeMinuteGoal] ?? 0;
    activityGoal = snapshpt[UserCollectionField.activityGoal] ?? 0;
    activityLevel = snapshpt[UserCollectionField.activityLevel] ?? 0;
    address = snapshpt[UserCollectionField.address] ?? '';
    birthDate = snapshpt[UserCollectionField.birthDate] == null
        ? DateTime.now()
        : DateTime.parse(snapshpt[UserCollectionField.birthDate]);
    calorieGoal = snapshpt[UserCollectionField.calorieGoal] ?? 0;
    countryCode = snapshpt[UserCollectionField.countryCode] ?? '';
    currStep = snapshpt[UserCollectionField.currStep] ?? 0;
    email = snapshpt[UserCollectionField.email] ?? '';
    energyGenerateGoal = snapshpt[UserCollectionField.energyGenerateGoal] ?? 0;
    fullName = snapshpt[UserCollectionField.fullName] ?? '';
    height = snapshpt[UserCollectionField.height] ?? '';
    heightType = snapshpt[UserCollectionField.heightType] ?? '';
    isActive = snapshpt[UserCollectionField.isActive] ?? false;
    isVerified = snapshpt[UserCollectionField.isVerified] ?? false;
    latLong = snapshpt[UserCollectionField.latLong] ?? '';
    mobileNumber = snapshpt[UserCollectionField.mobileNumber] ?? '';
    profilePhoto = snapshpt[UserCollectionField.profilePhoto] ?? '';
    socialId = snapshpt[UserCollectionField.socialId] ?? '';
    socialLoginType = snapshpt[UserCollectionField.socialLoginType] ?? '';
    sweatcoinBalance = snapshpt[UserCollectionField.sweatcoinBalance] ?? 0.0;
    sweatcoinId = snapshpt[UserCollectionField.sweatcoinId] ?? '';
    sweatcoinTransactions =
        snapshpt[UserCollectionField.sweatcoinTransactions] ?? '';
    username = snapshpt[UserCollectionField.username] ?? '';
    wight = snapshpt[UserCollectionField.wight] ?? 0.0;
    wightType = snapshpt[UserCollectionField.wightType] ?? '';
    followers = snapshpt[UserCollectionField.followers] ?? 0;
    isFollowing = snapshpt['is_following'] ?? false;
    deviceToken = snapshpt[UserCollectionField.deviceToken] ?? '';
    deviceType = snapshpt[UserCollectionField.deviceType] ?? '';
    jwtToken = snapshpt[UserCollectionField.jwtToken] ?? '';
    resistence = snapshpt[UserCollectionField.resistence] ?? 0;
    watts = snapshpt[UserCollectionField.watts] ?? 0;
    calories = snapshpt[UserCollectionField.calories] ?? 0;
    cadence = snapshpt[UserCollectionField.cadence] ?? 0;
    timeZoneName = snapshpt[UserCollectionField.timeZoneName] ?? '';
    ftpValue = snapshpt[UserCollectionField.ftpValue] ?? 0;
    workoutCount = snapshpt[UserCollectionField.workoutCount] ?? 0;
    gender = snapshpt[UserCollectionField.gender] ?? '';
    ftpLeaderboard = snapshpt[UserCollectionField.ftpLeaderboard] ?? 0;

    level = snapshpt[UserCollectionField.level] ?? 0;
    levelName = snapshpt[UserCollectionField.levelName] ?? '';
    badge = snapshpt[UserCollectionField.badge] ?? '';
    workoutCountInLevel =
        snapshpt[UserCollectionField.workoutCountInLevel] ?? 0;
    generatedenergy = snapshpt[UserCollectionField.generatedenergy] ?? 0;
  }

  UserModel.fromJson(Map<String, dynamic> json, {String? doumentId}) {
    documentId = doumentId ??
        (json[UserCollectionField.documentId] == null
            ? ''
            : json[UserCollectionField.documentId]);
    this.activeMinuteGoal = json[UserCollectionField.activeMinuteGoal] == null
        ? 0
        : json[UserCollectionField.activeMinuteGoal];
    this.activityGoal = json[UserCollectionField.activityGoal] == null
        ? 0
        : json[UserCollectionField.activityGoal];
    this.activityLevel = json[UserCollectionField.activityLevel] == null
        ? 0
        : json[UserCollectionField.activityLevel];
    this.address = json[UserCollectionField.address] == null
        ? ''
        : json[UserCollectionField.address];
    this.birthDate = json[UserCollectionField.birthDate] == null
        ? DateTime.now()
        : DateTime.parse(json[UserCollectionField.birthDate]);
    this.calorieGoal = json[UserCollectionField.calorieGoal] == null
        ? 0
        : json[UserCollectionField.calorieGoal];
    this.countryCode = json[UserCollectionField.countryCode] == null
        ? ''
        : json[UserCollectionField.countryCode];
    this.currStep = json[UserCollectionField.currStep] == null
        ? 0
        : json[UserCollectionField.currStep];
    this.email = json[UserCollectionField.email] == null
        ? ''
        : json[UserCollectionField.email];
    this.energyGenerateGoal =
        json[UserCollectionField.energyGenerateGoal] == null
            ? 0
            : json[UserCollectionField.energyGenerateGoal];
    this.fullName = json[UserCollectionField.fullName] == null
        ? ''
        : json[UserCollectionField.fullName];
    this.height = json[UserCollectionField.height] == null
        ? ''
        : json[UserCollectionField.height];
    this.heightType = json[UserCollectionField.heightType] == null
        ? ''
        : json[UserCollectionField.heightType];
    this.isActive = json[UserCollectionField.isActive] == null
        ? false
        : json[UserCollectionField.isActive];
    this.isVerified = json[UserCollectionField.isVerified] == null
        ? false
        : json[UserCollectionField.isVerified];
    this.latLong = json[UserCollectionField.latLong] == null
        ? ''
        : json[UserCollectionField.latLong];
    this.mobileNumber = json[UserCollectionField.mobileNumber] == null
        ? ''
        : json[UserCollectionField.mobileNumber];
    this.profilePhoto = json[UserCollectionField.profilePhoto] == null
        ? ''
        : json[UserCollectionField.profilePhoto];
    this.socialId = json[UserCollectionField.socialId] == null
        ? ''
        : json[UserCollectionField.socialId];
    this.socialLoginType = json[UserCollectionField.socialLoginType] == null
        ? ''
        : json[UserCollectionField.socialLoginType];
    this.sweatcoinBalance = json[UserCollectionField.sweatcoinBalance] == null
        ? 0.0
        : json[UserCollectionField.sweatcoinBalance];
    this.sweatcoinId = json[UserCollectionField.sweatcoinId] == null
        ? ''
        : json[UserCollectionField.sweatcoinId];
    this.sweatcoinTransactions =
        json[UserCollectionField.sweatcoinTransactions] == null
            ? ''
            : json[UserCollectionField.sweatcoinTransactions];
    this.username = json[UserCollectionField.username] == null
        ? ''
        : json[UserCollectionField.username];
    this.wight = json[UserCollectionField.wight] == null
        ? 0.0
        : json[UserCollectionField.wight];
    this.wightType = json[UserCollectionField.wightType] == null
        ? ''
        : json[UserCollectionField.wightType];
    this.followers = json[UserCollectionField.followers] == null
        ? 0
        : json[UserCollectionField.followers];
    this.isFollowing =
        json['is_following'] == null ? false : json['is_following'];

    this.deviceToken = json[UserCollectionField.deviceToken] == null
        ? ''
        : json[UserCollectionField.deviceToken];
    this.deviceType = json[UserCollectionField.deviceType] == null
        ? ''
        : json[UserCollectionField.deviceType];
    this.jwtToken = json[UserCollectionField.jwtToken] == null
        ? ''
        : json[UserCollectionField.jwtToken];
    this.resistence = json[UserCollectionField.resistence] == null
        ? 0
        : json[UserCollectionField.resistence];
    this.calories = json[UserCollectionField.calories] == null
        ? 0
        : json[UserCollectionField.calories];
    this.watts = json[UserCollectionField.watts] == null
        ? 0
        : json[UserCollectionField.watts];
    this.cadence = json[UserCollectionField.cadence] == null
        ? 0
        : json[UserCollectionField.cadence];
    this.timeZoneName = json[UserCollectionField.timeZoneName] == null
        ? ''
        : json[UserCollectionField.timeZoneName];
    this.ftpValue = json[UserCollectionField.ftpValue] == null
        ? 0
        : json[UserCollectionField.ftpValue];
    this.workoutCount = json[UserCollectionField.workoutCount] == null
        ? 0
        : json[UserCollectionField.workoutCount];
    this.gender = json[UserCollectionField.gender] == null
        ? ''
        : json[UserCollectionField.gender];
    this.ftpLeaderboard = json[UserCollectionField.ftpLeaderboard] == null
        ? 0
        : json[UserCollectionField.ftpLeaderboard];

    level = json[UserCollectionField.level] == null
        ? 0
        : json[UserCollectionField.level];
    levelName = json[UserCollectionField.levelName] == null
        ? ''
        : json[UserCollectionField.levelName];
    badge = json[UserCollectionField.badge] == null
        ? ''
        : json[UserCollectionField.badge];
    workoutCountInLevel = json[UserCollectionField.workoutCountInLevel] == null
        ? 0
        : json[UserCollectionField.workoutCountInLevel];
    generatedenergy = json[UserCollectionField.generatedenergy] == null
        ? 0
        : json[UserCollectionField.generatedenergy];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['document_id'] = this.documentId;
    data[UserCollectionField.activeMinuteGoal] =
        this.activeMinuteGoal == null ? 0 : this.activeMinuteGoal;
    data[UserCollectionField.activityGoal] =
        this.activityGoal == null ? 0 : this.activityGoal;
    data[UserCollectionField.activityLevel] =
        this.activityLevel == null ? 0 : this.activityLevel;
    data[UserCollectionField.address] =
        this.address == null ? '' : this.address;
    data[UserCollectionField.birthDate] = this.birthDate == null
        ? DateTime.now()
        : this.birthDate!.toIso8601String();
    data[UserCollectionField.calorieGoal] =
        this.calorieGoal == null ? 0 : this.calorieGoal;
    data[UserCollectionField.countryCode] =
        this.countryCode == null ? '' : this.countryCode;
    data[UserCollectionField.currStep] =
        this.currStep == null ? 0 : this.currStep;
    data[UserCollectionField.email] = this.email == null ? '' : this.email;
    data[UserCollectionField.energyGenerateGoal] =
        this.energyGenerateGoal == null ? 0 : this.energyGenerateGoal;
    data[UserCollectionField.fullName] =
        this.fullName == null ? '' : this.fullName;
    data[UserCollectionField.height] = this.height == null ? '' : this.height;
    data[UserCollectionField.heightType] =
        this.heightType == null ? '' : this.heightType;
    data[UserCollectionField.isActive] =
        this.isActive == null ? false : this.isActive;
    data[UserCollectionField.isVerified] =
        this.isVerified == null ? false : this.isVerified;
    data[UserCollectionField.latLong] =
        this.latLong == null ? '' : this.latLong;
    data[UserCollectionField.mobileNumber] =
        this.mobileNumber == null ? '' : this.mobileNumber;
    data[UserCollectionField.profilePhoto] =
        this.profilePhoto == null ? '' : this.profilePhoto;
    data[UserCollectionField.socialId] =
        this.socialId == null ? '' : this.socialId;
    data[UserCollectionField.socialLoginType] =
        this.socialLoginType == null ? '' : this.socialLoginType;
    data[UserCollectionField.sweatcoinBalance] =
        this.sweatcoinBalance == null ? false : this.sweatcoinBalance;
    data[UserCollectionField.sweatcoinId] =
        this.sweatcoinId == null ? '' : this.sweatcoinId;
    data[UserCollectionField.sweatcoinTransactions] =
        this.sweatcoinTransactions == null ? '' : this.sweatcoinTransactions;
    data[UserCollectionField.username] =
        this.username == null ? '' : this.username;
    data[UserCollectionField.wight] = this.wight == null ? 0.0 : this.wight;
    data[UserCollectionField.wightType] =
        this.wightType == null ? '' : this.wightType;
    data[UserCollectionField.followers] =
        this.followers == null ? 0 : this.followers;
    data['is_following'] = this.isFollowing == null ? false : this.isFollowing;
    data[UserCollectionField.deviceToken] =
        this.deviceToken == null ? '' : this.deviceToken;
    data[UserCollectionField.deviceType] =
        this.deviceType == null ? '' : this.deviceType;
    data[UserCollectionField.jwtToken] =
        this.jwtToken == null ? '' : this.jwtToken;
    data[UserCollectionField.resistence] =
        this.resistence == null ? '' : this.resistence;
    data[UserCollectionField.cadence] =
        this.cadence == null ? '' : this.cadence;
    data[UserCollectionField.watts] = this.watts == null ? '' : this.watts;
    data[UserCollectionField.calories] =
        this.calories == null ? '' : this.calories;
    data[UserCollectionField.timeZoneName] =
        this.timeZoneName == null ? '' : this.timeZoneName;
    data[UserCollectionField.ftpValue] =
        this.ftpValue == null ? 0.0 : this.ftpValue;
    data[UserCollectionField.workoutCount] =
        this.workoutCount == null ? 0.0 : this.workoutCount;
    data[UserCollectionField.gender] = this.gender == null ? '' : this.gender;
    data[UserCollectionField.ftpLeaderboard] =
        this.ftpLeaderboard == null ? 0.0 : this.ftpLeaderboard;

    data[UserCollectionField.level] = this.level == null ? 0.0 : this.level;

    data[UserCollectionField.levelName] =
        this.levelName == null ? '' : this.levelName;

    data[UserCollectionField.badge] = this.badge == null ? '' : this.badge;

    data[UserCollectionField.workoutCountInLevel] =
        this.workoutCountInLevel == null ? 0.0 : this.workoutCountInLevel;

    data[UserCollectionField.generatedenergy] =
        this.generatedenergy == null ? 0.0 : this.generatedenergy;

    return data;
  }

  String getFirstName() {
    String firstName = '';
    if (fullName != null && fullName!.isNotEmpty) {
      firstName = fullName!.split(' ').first;
    }
    return firstName;
  }
}
