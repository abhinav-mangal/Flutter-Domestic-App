import 'package:energym/reusable_component/shared_pref_helper.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:energym/reusable_component/custom_dialog.dart';

typedef SuccessResponseCallback<T> = T Function(Map<String, dynamic> jsonData);
typedef ErrorResponseCallback<T> = T Function(Map<String, dynamic> jsonData);

class AuthProvider {
  AuthProvider._internal() {}
  AuthProvider._privateConstructor();

  static final AuthProvider _instance = AuthProvider._privateConstructor();

  static AuthProvider get instance => _instance;

  String currentUserId() {
    print('Current User ID === ${FirebaseAuth.instance.currentUser!.uid}');
    return FirebaseAuth.instance.currentUser!.uid;
  }

  Future<String?> getJWTToken() async {
    return FirebaseAuth.instance.currentUser?.getIdToken();
  }

  Future<void> sendCode<T>({
    required BuildContext? context,
    required String? countryCode,
    required String? mobile,
    SuccessResponseCallback? onSuccess,
    ErrorResponseCallback? onError,
  }) async {
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '$countryCode $mobile',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        return null;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        return null;
      },
      codeSent: (String? verificationId, int? forceResendingToken) {
        Map<String, dynamic> response = {};
        response['verificationId'] = verificationId;
        response['forceResendingToken'] = forceResendingToken;
        return onSuccess!(response);
      },
      verificationFailed: (FirebaseAuthException error) {
        Map<String, dynamic> errorResponse = {};

        errorResponse[AppKeyConstant.code] = error.code;
        errorResponse[AppKeyConstant.message] = error.message;

        if (error.code == 'invalid-phone-number') {
          errorResponse[AppKeyConstant.code] = AppConstants.errorInvalidMoblile;
          errorResponse[AppKeyConstant.message] =
              AppConstants.errorInvalidMoblileMsg;
        }

        //print('errorResponse >>>> $errorResponse');

        const CustomAlertDialog().showExeptionErrorMessage(
          context: context,
          title: errorResponse[AppKeyConstant.code] as String,
          message: errorResponse[AppKeyConstant.message] as String,
          buttonTitle: AppConstants.ok,
          onPress: () {},
        );

        return onError!(errorResponse);
      },
    );
  }

  Future<void> signInWithPhoneNumber<T>({
    required BuildContext? context,
    required String? smsCode,
    required String? verificationId,
    required String? mobile,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    PhoneAuthCredential credential = await PhoneAuthProvider.credential(
        verificationId: verificationId!, smsCode: smsCode!);

    //print('credential >>>>> $credential');

    FirebaseAuth.instance.signInWithCredential(credential).then((user) async {
      final String currentUserId = user.user!.uid;
      Map<String, dynamic> response = {};
      response['user'] = user;
      response['userId'] = currentUserId;
      return onSuccess!(response);
    }).catchError((error) {
      Map<String, dynamic> errorResponse = <String, dynamic>{};

      errorResponse[AppKeyConstant.code] = error.code;
      errorResponse[AppKeyConstant.message] = error.message;

      if (error.code == 'invalid-verification-code') {
        errorResponse[AppKeyConstant.code] = AppConstants.errorInvalidCode;
        errorResponse[AppKeyConstant.message] =
            AppConstants.errorInvalidCodeMsg;
      }
      const CustomAlertDialog().showExeptionErrorMessage(
        context: context,
        title: errorResponse[AppKeyConstant.code] as String,
        message: errorResponse[AppKeyConstant.message] as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return onError!(errorResponse);
    });
  }

  Future<void> signOut<T>({
    required BuildContext? context,
    bool? isForceLogout = false,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    if (isForceLogout!) {
      FirebaseAuth.instance.signOut().then((value) async {
        aGeneralBloc.userSignOut();
        Map<String, dynamic> response = <String, dynamic>{};
        return onSuccess!(response);
      }).catchError((error) {
        Map<String, dynamic> errorResponse = <String, dynamic>{};
        errorResponse[AppKeyConstant.message] = error.message;
        errorResponse[AppKeyConstant.code] = error.code;
        return onError!(errorResponse);
      });
    } else {
      FireStoreProvider.instance
          .saveDeviceToken(
        context: context!,
        deviceType: '',
        deviceToke: '',
        isLogOut: true,
      )
          .then((value) {
        FirebaseAuth.instance.signOut().then((value) async {
          aGeneralBloc.userSignOut();
          Map<String, dynamic> response = <String, dynamic>{};
          return onSuccess!(response);
        }).catchError((error) {
          Map<String, dynamic> errorResponse = <String, dynamic>{};
          errorResponse[AppKeyConstant.message] = error.message;
          errorResponse[AppKeyConstant.code] = error.code;
          return onError!(errorResponse);
        });
      });
    }
  }

  Future<bool?> deleteUser<T>({
    String? userId,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    try {
      User user = await FirebaseAuth.instance.currentUser!;
      if (user != null) {
        await user.delete().then((value) {
          FirebaseFirestore.instance
              .collection(FSCollection.user)
              .doc(userId)
              .delete()
              .whenComplete(() {
            Map<String, dynamic> successResponse = <String, dynamic>{};
            successResponse[AppKeyConstant.title] = AppConstants.delete;
            successResponse[AppKeyConstant.message] =
                AppConstants.deleteAccountSuccessMsg;

            return onSuccess!(successResponse);
          }).catchError((onError) {});
        }).catchError((error) {
          Map<String, dynamic> errorResponse = <String, dynamic>{};
          errorResponse[AppKeyConstant.message] = error.message;
          errorResponse[AppKeyConstant.code] = error.code;
          return onError!(errorResponse);
        });
      }

      return true;
    } catch (e) {
      //print(e.toString());
      return null;
    }
  }

  Future<void> signUpWithEmailPassword<T>({
    required BuildContext? context,
    required String email,
    required String password,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((user) async {
      final String currentUserId = user.user!.uid;
      Map<String, dynamic> response = {};
      response['user'] = user;
      response['userId'] = currentUserId;
      return onSuccess!(response);
    }).catchError((error) {
      Map<String, dynamic> errorResponse = <String, dynamic>{};

      errorResponse[AppKeyConstant.code] = error.code;
      errorResponse[AppKeyConstant.message] = error.message;

      if (error.code == 'email-already-in-use') {
        errorResponse[AppKeyConstant.code] = AppConstants.email;
        errorResponse[AppKeyConstant.message] = MsgConstants.emailExists;
      }
      const CustomAlertDialog().showExeptionErrorMessage(
        context: context,
        title: errorResponse[AppKeyConstant.code] as String,
        message: errorResponse[AppKeyConstant.message] as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return onError!(errorResponse);
    });
  }

  Future<void> signInWithEmailPassword<T>({
    required BuildContext? context,
    required String email,
    required String password,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)
          .then((user) async {
        final String currentUserId = user.user!.uid;
        Map<String, dynamic> response = {};
        response['user'] = user;
        response['userId'] = currentUserId;
        return onSuccess!(response);
      }).catchError((error) {
        Map<String, dynamic> errorResponse = <String, dynamic>{};

        errorResponse[AppKeyConstant.code] = error.code;
        errorResponse[AppKeyConstant.message] = error.message;

        if (error.code == 'invalid-verification-code') {
          errorResponse[AppKeyConstant.code] = AppConstants.errorInvalidCode;
          errorResponse[AppKeyConstant.message] =
              AppConstants.errorInvalidCodeMsg;
        }
        const CustomAlertDialog().showExeptionErrorMessage(
          context: context,
          title: errorResponse[AppKeyConstant.code] as String,
          message: errorResponse[AppKeyConstant.message] as String,
          buttonTitle: AppConstants.ok,
          onPress: () {},
        );

        return onError!(errorResponse);
      });
  }
}
