import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/validation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForGotPasswordBloc {
  // Validation check for email
  bool validation({required String email, required BuildContext context}) {
    bool isValid = true;
    if (email.trim().isEmpty) {
      isValid = false;
      _displayAlert(context, MsgConstants.enterEmail);
    } else if (Validation.instance.validateEmail(email) != null) {
      isValid = false;
      _displayAlert(context, MsgConstants.enterValidEmail);
    }
    return isValid;
  }

  _displayAlert(BuildContext context, String message) {
    CustomAlertDialog().showAlert(
        context: context, message: message, title: AppConstants.appName);
  }
}
