import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/validation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupBloc {
  bool validation(
      {required String name,
      required String email,
      required String phone,
      required String password,
      required String cPassword,
      required BuildContext context}) {
    bool isValid = true;
    if (name.trim().isEmpty) {
      isValid = false;
      displayAlert(context, MsgConstants.enterFullName);
    } else if (email.trim().isEmpty) {
      isValid = false;
      displayAlert(context, MsgConstants.enterEmail);
    } 
    // else if (phone.trim().isEmpty) {
    //   isValid = false;
    //   displayAlert(context, MsgConstants.enterMobileNumber);
    // } 
    else if (Validation.instance.validateEmail(email.trim()) != null) {
      isValid = false;
      displayAlert(context, MsgConstants.enterValidEmail);
    } else if (password.trim().isEmpty) {
      isValid = false;
      displayAlert(context, MsgConstants.password);
    } else if (Validation.instance.validatePassWord(password.trim()) != null) {
      isValid = false;
      displayAlert(
          context, Validation.instance.validatePassWord(password.trim()) ?? '');
    } else if (cPassword.trim().isEmpty) {
      isValid = false;
      displayAlert(context, MsgConstants.cpassword);
    } else if (password.trim() != cPassword.trim()) {
      isValid = false;
      displayAlert(context, MsgConstants.passwordnotmatch);
    }
    return isValid;
  }

  displayAlert(BuildContext context, String message) {
    CustomAlertDialog().showAlert(
        context: context, message: message, title: AppConstants.appName);
  }

  // createNewUser(String email, String password, BuildContext context) async {
  //   try {
  //     final credential =
  //         await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'email-already-in-use') {
  //       _displayAlert(context, MsgConstants.emailExists);
  //     }
  //   } catch (e) {
  //     print(e);
  //     _displayAlert(context, e.toString());
  //   }
  // }
}
