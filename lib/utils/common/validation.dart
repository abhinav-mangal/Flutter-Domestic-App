import 'dart:async';

import 'package:energym/utils/common/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:validators/validators.dart';

class Validation {
  Validation._privateConstructor();

  static final Validation _instance = Validation._privateConstructor();

  static Validation get instance => _instance;

  String? validateEmail(String? value) {
    if (value!.isEmpty) return 'enterEmail'.tr();
    final RegExp? nameExp = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

    if (!nameExp!.hasMatch(value)) return 'enterValidEmail'.tr();
    return null;
  }

  String? validateUrl(String value) {
    if (value.isEmpty) return 'enterWebsiteUrl'.tr();
    if (!isURL(value)) {
      return 'entervalidUrl'.tr();
    }
    return null;
  }

  String? validatePassWord(String value) {
    if (value.isEmpty) return MsgConstants.password;

    if (value.length < 8) return MsgConstants.enterValidPwd;

    if (!isPasswordCompliant(value, 8)) return MsgConstants.enterValidPwd;
    return null;
  }

  String? validateUserName(String value) {
    if (value.isEmpty) return 'Please enter user name';
    final RegExp nameExp =
        RegExp(r'^(?=.{4,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$');

    if (!nameExp.hasMatch(value)) return 'Please enter valid userName';
    return null;
  }

  String? validateMobile(String value) {
    if (value.isEmpty) return 'enterMobile'.tr();

    if (value.length < 9) return 'enterValidMobile'.tr();

    return null;
  }

  bool validateIsNotEmpty(String value) {
    if (value == null || value.isEmpty) return false;
    return true;
  }

  bool isPasswordCompliant(String password, [int minLength = 6]) {
    if (password == null || password.isEmpty) {
      return false;
    }

    final bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final bool hasDigits = password.contains(RegExp(r'[0-9]'));
    final bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    final bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final bool hasMinLength = password.length >= minLength;

    return hasDigits &
        hasUppercase &
        hasLowercase &
        hasSpecialCharacters &
        hasMinLength;
  }
}
