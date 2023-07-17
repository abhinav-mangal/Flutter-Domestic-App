import 'package:flutter/material.dart';
import 'package:energym/utils/common/constants.dart';

class Validations {
  String? validateEmail(String value) {
    if (value.isEmpty) return 'Please Enter Email Address';
    final RegExp nameExp = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

    if (!nameExp.hasMatch(value)) return 'Please Enter Valid Email Address';
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return 'Please choose a password.';
    final RegExp nameExp =
        RegExp(r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$");
    if (!nameExp.hasMatch(value)) return 'Invalid password';
    return null;
  }

  String? validateUserName(String value) {
    if (value.isEmpty) return 'Please enter user name';
    final RegExp nameExp = RegExp(r'^(?=[a-zA-Z0-9._]{8,20}$)(?!.*[_.]{2})[^_.].*[^_.]$');

    if (!nameExp.hasMatch(value)) return 'Please enter valid userName';
    return null;
  }

  String? validateEmpty(String value) {
    if (value.isEmpty || value == null) return 'Please enter a value.';
    return null;
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s) != null;
  }

  // String validateFName(String value) {
  //   if (value.isEmpty) {
  //     return MsgConstants.enterFirstName;
  //   } else {
  //     final RegExp nameExp = RegExp(r'^[a-z A-Z,.\-]+$');
  //     if (!nameExp.hasMatch(value)) {
  //       return 'Please enter only alphabetical characters.';
  //     } else {
  //       return null;
  //     }
  //   }
  // }

  // String validateLName(String value) {
  //   if (value.isEmpty) {
  //     return MsgConstants.enterLasttName;
  //   } else {
  //     final RegExp nameExp = RegExp(r'^[a-z A-Z,.\-]+$');
  //     if (!nameExp.hasMatch(value)) {
  //       return 'Please enter only alphabetical characters.';
  //     } else {
  //       return null;
  //     }
  //   }
  // }
}

extension listExtension on List {
  String arraytostring() {
    return this.toString().replaceAll("[", "").replaceAll("]", "");
  }
}
