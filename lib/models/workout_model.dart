class WorkoutModel {
  String? documentId;
  String? userId;
  int? reward;
  int? watts;
  int? resistance;
  int? calories;
  int? cadence;
  String? updatedAt;
  String? createdAt;
  String? userFullName;
  String? userMobileNumber;
  String? userProfilePhoto;
  String? username;

  WorkoutModel(
      {this.documentId,
      this.userId,
      this.reward,
      this.watts,
      this.resistance,
      this.calories,
      this.cadence,
      this.updatedAt,
      this.createdAt,
      this.userFullName,
      this.userMobileNumber,
      this.userProfilePhoto,
      this.username});

  WorkoutModel.fromJson(Map<String, dynamic> json) {
    documentId = json['document_id'];
    userId = json['user_id'];
    reward = json['reward'];
    watts = json['watts'];
    resistance = json['resistance'];
    calories = json['calories'];
    cadence = json['cadence'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    userFullName = json['user_full_name'];
    userMobileNumber = json['user_mobile_number'];
    userProfilePhoto = json['user_profile_photo'];
    username = json['username'];
  }


}
