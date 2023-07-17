import 'dart:io';

import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/validation.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:energym/models/error_message_model.dart';

class ProfileSetUpBloc {
  final BehaviorSubject<bool> _profileSetUpFormValid = BehaviorSubject<bool>();
  ValueStream<bool> get getFormValid => _profileSetUpFormValid.stream;

  final BehaviorSubject<int> _profileSetUpStep = BehaviorSubject<int>.seeded(0);
  ValueStream<int> get getProfileSetUpStep => _profileSetUpStep.stream;

  final BehaviorSubject<String> _fullNameController = BehaviorSubject<String>();

  final BehaviorSubject<ErrorMessage> _fullNameErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getFullNameErrorMessage =>
      _fullNameErrorMessage.stream;

  final BehaviorSubject<String> _emailController =
      BehaviorSubject<String>.seeded('');
  final BehaviorSubject<ErrorMessage> _emailErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getEmailErrorMessage =>
      _emailErrorMessage.stream;

  final BehaviorSubject<String> _userNameController =
      BehaviorSubject<String>.seeded('');
  final BehaviorSubject<ErrorMessage> _userNameErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getUserNameErrorMessage =>
      _userNameErrorMessage.stream;

  final BehaviorSubject<dynamic> _profilePicController =
      BehaviorSubject<dynamic>.seeded('');
  ValueStream<dynamic> get getProfilePic => _profilePicController.stream;
  final BehaviorSubject<ErrorMessage> _profilePicErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getProfilePicErrorMessage =>
      _profilePicErrorMessage.stream;

  final BehaviorSubject<String> _locationController = BehaviorSubject<String>();
  ValueStream<String> get getLocation => _locationController.stream;
  final BehaviorSubject<ErrorMessage> _locationErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getLocationErrorMessage =>
      _locationErrorMessage.stream;

  final BehaviorSubject<String> _heightController = BehaviorSubject<String>();
  ValueStream<String> get getHeight => _heightController.stream;
  final BehaviorSubject<ErrorMessage> _heightErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getHeightErrorMessage =>
      _heightErrorMessage.stream;

  final BehaviorSubject<String> _heightTypeController =
      BehaviorSubject<String>();
  ValueStream<String> get getHeightType => _heightTypeController.stream;
  final BehaviorSubject<ErrorMessage> _heightTypeErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getHeightTypeErrorMessage =>
      _heightTypeErrorMessage.stream;

  final BehaviorSubject<double> _weightController = BehaviorSubject<double>();
  ValueStream<double> get getWeight => _weightController.stream;
  final BehaviorSubject<ErrorMessage> _weightErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getWeightErrorMessage =>
      _weightErrorMessage.stream;

  final BehaviorSubject<String> _weightTypeController =
      BehaviorSubject<String>();
  ValueStream<String> get getWeightType => _weightTypeController.stream;
  final BehaviorSubject<ErrorMessage> _weightTypeErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getWeightTypeErrorMessage =>
      _weightTypeErrorMessage.stream;

  final BehaviorSubject<String> _birthdayController = BehaviorSubject<String>();
  ValueStream<String> get getBirthday => _birthdayController.stream;
  final BehaviorSubject<ErrorMessage> _birthdayErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getBirthdayErrorMessage =>
      _birthdayErrorMessage.stream;

  final BehaviorSubject<String> _genderController = BehaviorSubject<String>();
  ValueStream<String> get getGender => _genderController.stream;
  final BehaviorSubject<ErrorMessage> _genderErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getGenderErrorMessage =>
      _genderErrorMessage.stream;

  final BehaviorSubject<int> _activityLevel = BehaviorSubject<int>();
  ValueStream<int> get getActivityLevel => _activityLevel.stream;

  final BehaviorSubject<int> _activityGoal = BehaviorSubject<int>();
  ValueStream<int> get getActivityGoal => _activityGoal.stream;

  final BehaviorSubject<String> _caloriesGoalController =
      BehaviorSubject<String>();
  ValueStream<String> get getCaloriesGoal => _caloriesGoalController.stream;
  final BehaviorSubject<ErrorMessage> _caloriesGoalErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getCaloriesGoalErrorMessage =>
      _caloriesGoalErrorMessage.stream;

  final BehaviorSubject<String> _minutesGoalController =
      BehaviorSubject<String>();
  ValueStream<String> get getMinutesGoal => _minutesGoalController.stream;
  final BehaviorSubject<ErrorMessage> _minutesGoalErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getMinutesGoalErrorMessage =>
      _minutesGoalErrorMessage.stream;

  final BehaviorSubject<String> _energyEngGoalController =
      BehaviorSubject<String>();
  ValueStream<String> get getEnergyEngGoal => _energyEngGoalController.stream;
  final BehaviorSubject<ErrorMessage> _energyEngGoalErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getEnergyEngGoalErrorMessage =>
      _energyEngGoalErrorMessage.stream;

  final BehaviorSubject<String> _ftpController =
      BehaviorSubject<String>.seeded('100');
  ValueStream<String> get getFtp => _ftpController.stream;
  final BehaviorSubject<ErrorMessage> _ftpErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getFtpErrorMessage => _ftpErrorMessage.stream;

  int _setUpStep = 1;
  PermissionStatus? permissionStatus;
  ServiceStatus? serviceStatus;

  void updateSetp({int? stepValue}) {
    _setUpStep = stepValue!;
    _profileSetUpStep.sink.add(stepValue);
    validateProfileSetUpForm();
  }

  void onChangeFullName({String? value, bool isShowError = false}) {
    _fullNameController.sink.add(value!);
    validateFullName(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateFullName({bool isShowError = false}) {
    bool isValid = true;
    final String validFullName = _fullNameController.valueWrapper?.value ?? '';
    if (Validation.instance.validateIsNotEmpty(validFullName) == false) {
      if (isShowError) {
        _fullNameErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.enterFullName));
      } else {
        _fullNameErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = false;
    } else {
      if (isShowError) {
        _fullNameErrorMessage.sink.add(ErrorMessage(false, ''));
      }
      isValid = true;
    }

    return isValid;
  }

  void onChangeEmailAddress({String? value, bool isShowError = false}) {
    _emailController.sink.add(value!);
    validateEmail(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateEmail({bool isShowError = false}) {
    bool isValid = true;
    final String? validEmail = _emailController.valueWrapper?.value;
    if (Validation.instance.validateIsNotEmpty(validEmail!) == false) {
      if (isShowError) {
        _emailErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.enterEmail));
      }

      isValid = false;
    } else if (Validation.instance.validateEmail(validEmail) != null) {
      isValid = false;
      if (isShowError) {
        _emailErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.enterValidEmail));
      }
    } else {
      if (isShowError) {
        _emailErrorMessage.sink.add(ErrorMessage(false, ''));
      }
      isValid = true;
    }

    return isValid;
  }

  void showErrorEmailExists(
      {required bool? isEmailExists, String? value, bool isShowError = false}) {
    if (isEmailExists!) {
      _emailErrorMessage.sink.add(ErrorMessage(true, MsgConstants.emailExists));
      _profileSetUpFormValid.sink.add(false);
    } else {
      onChangeEmailAddress(value: value, isShowError: isShowError);
    }
  }

  void showErrorUserNotExists(
      {required bool? isUserExists, String? value, bool isShowError = false}) {
    if (isUserExists!) {
      _userNameErrorMessage.sink
          .add(ErrorMessage(true, MsgConstants.userNameExists));
      _profileSetUpFormValid.sink.add(false);
    } else {
      onChangeUserName(value: value!, isShowError: isShowError);
    }
  }

  void onChangeUserName({String? value, bool isShowError = false}) {
    _userNameController.sink.add(value!);
    validateUserName(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateUserName({bool isShowError = false}) {
    bool isValid = true;
    final String validUserName = _userNameController.valueWrapper?.value ?? '';
    if (Validation.instance.validateIsNotEmpty(validUserName) == false) {
      if (isShowError) {
        _userNameErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.enterUserName));
      }
      isValid = false;
    } else if (Validation.instance.validateUserName(validUserName) != null) {
      isValid = false;
      if (isShowError) {
        _userNameErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.enterValidUserName));
      }
    } else {
      if (isShowError) {
        _userNameErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = true;
    }

    return isValid;
  }

  void onChangeProfilePic({dynamic value, bool isShowError = false}) {
    _profilePicController.sink.add(value);
    validateProfilePic(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateProfilePic({bool isShowError = false}) {
    bool isValid = true;
    final dynamic validPofilePic = _profilePicController.value;
    if (validPofilePic == null) {
      if (isShowError) {
        _profilePicErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.selectProfilePicture));
      }
      isValid = false;
    } else {
      if (isShowError) {
        _profilePicErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = true;
    }

    return isValid;
  }

  void onChangeLocation({String? value, bool isShowError = false}) {
    _locationController.sink.add(value!);
    validateLocation(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateLocation({bool isShowError = false}) {
    bool isValid = true;
    final String validUserName = _locationController.valueWrapper?.value ?? '';
    if (Validation.instance.validateIsNotEmpty(validUserName) == false) {
      if (isShowError) {
        _userNameErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.selectLocation));
      }
      isValid = false;
    } else {
      if (isShowError) {
        _userNameErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = true;
    }

    return isValid;
  }

  void onChangeHeight({String? value, bool isShowError = false}) {
    _heightController.sink.add(value!);
    validateHeight(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateHeight({bool isShowError = false}) {
    bool isValid = true;
    final String validHeight = _heightController.value.toString();
    if (Validation.instance.validateIsNotEmpty(validHeight) == false) {
      if (isShowError) {
        _heightErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.selectHeight));
      }
      isValid = false;
    } else {
      if (isShowError) {
        _heightErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = true;
    }

    return isValid;
  }

  void onChangeHeightType({String? value, bool isShowError = false}) {
    _heightTypeController.sink.add(value!);
    validateHeightType(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateHeightType({bool isShowError = false}) {
    bool isValid = true;
    final String validHeightType =
        _heightTypeController.valueWrapper?.value ?? '';
    if (Validation.instance.validateIsNotEmpty(validHeightType) == false) {
      if (isShowError) {
        _heightTypeErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.selectHeight));
      }
      isValid = false;
    } else {
      if (isShowError) {
        _heightTypeErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = true;
    }

    return isValid;
  }

  void onChangeWeight({double? value, bool isShowError = false}) {
    _weightController.sink.add(value!);
    validateWeight(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateWeight({bool isShowError = false}) {
    bool isValid = true;
    final String validWeight = _weightController.value.toString();
    if (Validation.instance.validateIsNotEmpty(validWeight) == false) {
      if (isShowError) {
        _weightErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.selectWeight));
      }
      isValid = false;
    } else {
      if (isShowError) {
        _weightErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = true;
    }

    return isValid;
  }

  void onChangeWeightType({String? value, bool isShowError = false}) {
    _weightTypeController.sink.add(value!);
    validateWeightType(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateWeightType({bool isShowError = false}) {
    bool isValid = true;
    final String validWeightType =
        _weightTypeController.valueWrapper?.value ?? '';
    if (Validation.instance.validateIsNotEmpty(validWeightType) == false) {
      if (isShowError) {
        _weightTypeErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.selectWeight));
      }
      isValid = false;
    } else {
      if (isShowError) {
        _weightTypeErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = true;
    }

    return isValid;
  }

  void onChangeBirthday({String? value, bool isShowError = false}) {
    _birthdayController.sink.add(value!);
    validateBirthday(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateBirthday({bool isShowError = false}) {
    bool isValid = true;
    final String validBirthday = _birthdayController.valueWrapper?.value ?? '';
    if (Validation.instance.validateIsNotEmpty(validBirthday) == false) {
      if (isShowError) {
        _birthdayErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.selectBirthday));
      }
      isValid = false;
    } else {
      if (isShowError) {
        _birthdayErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = true;
    }

    return isValid;
  }

  void onChangeGender({String? value, bool isShowError = false}) {
    _genderController.sink.add(value!);
    validateGender(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateGender({bool isShowError = false}) {
    bool isValid = true;
    final String validGender = _genderController.valueWrapper?.value ?? '';
    if (Validation.instance.validateIsNotEmpty(validGender) == false) {
      if (isShowError) {
        _genderErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.selectGender));
      }
      isValid = false;
    } else {
      if (isShowError) {
        _genderErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = true;
    }

    return isValid;
  }

  void onChangeActivityLevel({int? value, bool isShowError = false}) {
    _activityLevel.sink.add(value!);
    validateActivityLevel(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateActivityLevel({bool isShowError = false}) {
    bool isValid = true;
    final int validActivityLevel = _activityLevel.valueWrapper?.value ?? 0;
    if (validActivityLevel == null) {
      isValid = false;
    } else {
      isValid = true;
    }

    return isValid;
  }

  void onChangeActivityGoal({int? value, bool isShowError = false}) {
    _activityGoal.sink.add(value!);
    validateActivityGoal(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateActivityGoal({bool isShowError = false}) {
    bool isValid = true;
    final int validActivityGoal = _activityGoal.valueWrapper?.value ?? 0;
    if (validActivityGoal == null) {
      isValid = false;
    } else {
      isValid = true;
    }

    return isValid;
  }

  void onChangeCaloriesGoal({String? value, bool isShowError = false}) {
    _caloriesGoalController.sink.add(value!);
    validateCaloriesGoal(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateCaloriesGoal({bool isShowError = false}) {
    bool isValid = true;
    final String validCaloriesGoal =
        _caloriesGoalController.valueWrapper?.value ?? '';
    if (Validation.instance.validateIsNotEmpty(validCaloriesGoal) == false) {
      if (isShowError) {
        _caloriesGoalErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.selectBirthday));
      }
      isValid = false;
    } else {
      if (isShowError) {
        _caloriesGoalErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = true;
    }

    return isValid;
  }

  void onChangeMinutesGoal({String? value, bool isShowError = false}) {
    _minutesGoalController.sink.add(value!);
    validateMinutesGoal(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateMinutesGoal({bool isShowError = false}) {
    bool isValid = true;
    final String validMinutesGoal =
        _minutesGoalController.valueWrapper?.value ?? '';
    if (Validation.instance.validateIsNotEmpty(validMinutesGoal) == false) {
      if (isShowError) {
        _minutesGoalErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.selectBirthday));
      }
      isValid = false;
    } else {
      if (isShowError) {
        _minutesGoalErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = true;
    }

    return isValid;
  }

  void onChangeEnergyEngGoal({String? value, bool isShowError = false}) {
    _energyEngGoalController.sink.add(value!);
    validateEnergyEngGoal(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateEnergyEngGoal({bool isShowError = false}) {
    bool isValid = true;
    final String valideEnergyEngGoal =
        _energyEngGoalController.valueWrapper?.value ?? '';
    if (Validation.instance.validateIsNotEmpty(valideEnergyEngGoal) == false) {
      if (isShowError) {
        _energyEngGoalErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.selectBirthday));
      }
      isValid = false;
    } else {
      if (isShowError) {
        _energyEngGoalErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = true;
    }

    return isValid;
  }

  void onChangeFTP({String? value, bool isShowError = false}) {
    _ftpController.sink.add(value!);
    validateFTP(isShowError: isShowError);
    validateProfileSetUpForm();
  }

  bool validateFTP({bool isShowError = false}) {
    bool isValid = true;
    final String? validFtp = _ftpController.valueWrapper?.value.toString();
    if (Validation.instance.validateIsNotEmpty(validFtp!) == false) {
      if (isShowError) {
        _ftpErrorMessage.sink.add(ErrorMessage(true, MsgConstants.selectFTP));
      }
      isValid = false;
    } else {
      if (isShowError) {
        _ftpErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = true;
    }

    return isValid;
  }

  void validateProfileSetUpForm({bool isShowError = false}) {
    bool isValid = true;
    if (_setUpStep == -1) {
      if (!validateFullName(isShowError: isShowError)) {
        isValid = false;
      }
    } else if (_setUpStep == -1) {
      if (!validateEmail(isShowError: isShowError)) {
        isValid = false;
      }
    } else if (_setUpStep == 0) {
      if (!validateUserName(isShowError: isShowError)) {
        isValid = false;
      }
    } else if (_setUpStep == 1) {
      if (!validateProfilePic(isShowError: isShowError)) {
        isValid = false;
      }
    } else if (_setUpStep == 2) {
      if (!validateLocation(isShowError: isShowError)) {
        isValid = false;
      }
    } else if (_setUpStep == 3) {
      if (!validateHeight(isShowError: isShowError)) {
        isValid = false;
      }
      if (!validateHeightType(isShowError: isShowError)) {
        isValid = false;
      }
    } else if (_setUpStep == 4) {
      if (!validateWeight(isShowError: isShowError)) {
        isValid = false;
      }
      if (!validateWeightType(isShowError: isShowError)) {
        isValid = false;
      }
    } else if (_setUpStep == 5) {
      if (!validateBirthday(isShowError: isShowError)) {
        isValid = false;
      }
    } else if (_setUpStep == 6) {
      if (!validateGender(isShowError: isShowError)) {
        isValid = false;
      }
    } else if (_setUpStep == 7) {
      if (!validateActivityLevel(isShowError: isShowError)) {
        isValid = false;
      }
    } else if (_setUpStep == 8) {
      if (!validateActivityGoal(isShowError: isShowError)) {
        isValid = false;
      }
    } else if (_setUpStep == 9) {
      if (!validateCaloriesGoal(isShowError: isShowError)) {
        isValid = false;
      }
    } else if (_setUpStep == 10) {
      if (!validateMinutesGoal(isShowError: isShowError)) {
        isValid = false;
      }
    } else if (_setUpStep == 11) {
      if (!validateEnergyEngGoal(isShowError: isShowError)) {
        isValid = false;
      }
    } else if (_setUpStep == 12) {
      if (!validateFTP(isShowError: isShowError)) {
        isValid = false;
      }
    }

    _profileSetUpFormValid.sink.add(isValid);
  }

  void dispose() {
    _profileSetUpFormValid.close();
    _profileSetUpStep.close();
    _fullNameController.close();
    _fullNameErrorMessage.close();
    _emailController.close();
    _emailErrorMessage.close();
    _userNameController.close();
    _userNameErrorMessage.close();
    _profilePicController.close();
    _profilePicErrorMessage.close();
    _locationController.close();
    _locationErrorMessage.close();
    _heightController.close();
    _heightErrorMessage.close();
    _heightTypeController.close();
    _heightTypeErrorMessage.close();
    _weightController.close();
    _weightErrorMessage.close();
    _weightTypeController.close();
    _weightTypeErrorMessage.close();

    _birthdayController.close();
    _birthdayErrorMessage.close();
    _activityLevel.close();
    _activityGoal.close();

    _caloriesGoalController.close();
    _caloriesGoalErrorMessage.close();

    _minutesGoalController.close();
    _minutesGoalErrorMessage.close();

    _energyEngGoalController.close();
    _energyEngGoalErrorMessage.close();

    _ftpController.close();
    _ftpErrorMessage.close();
  }
}
