import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/screens/login/login.dart';
import 'package:energym/screens/otp/otp.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/helpers/firebase/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:energym/models/user_model.dart';

class SettinngBloc {
  void deleteUserAccount(BuildContext mainContext, UserModel userData) {
    AuthProvider.instance.sendCode(
        context: mainContext,
        countryCode: userData.countryCode,
        mobile: userData.mobileNumber,
        onSuccess: (Map<String, dynamic> successData) {
          aGeneralBloc.updateAPICalling(false);
          final String verificationId =
              successData['verificationId'] as String;
          Navigator.pushNamed(
            mainContext,
            OtpVerification.routeName,
            arguments: OtpVerificationArgs(
                code: userData.countryCode,
                mobile: userData.mobileNumber,
                isNewUser: false,
                verificationId: verificationId,
                isReauthentication: true),
          ).then((value) {
            aGeneralBloc.updateAPICalling(true);
            AuthProvider.instance.deleteUser(
                userId: userData.documentId,
                onSuccess: (Map<String, dynamic> successData) {
                  aGeneralBloc.userSignOut();
                  aGeneralBloc.updateAPICalling(false);
                  Navigator.pushNamedAndRemoveUntil(
                    mainContext,
                    Login.routeName,
                    ModalRoute.withName('/'),
                  );
                },
                onError: (Map<String, dynamic> errorResponse) {
                  print('errorResponse >> $errorResponse');
                  Navigator.pop(mainContext);
                  aGeneralBloc.updateAPICalling(false);
                  const CustomAlertDialog().showAlert(
                      context: mainContext,
                      title: AppConstants.deleteMyAccount,
                      message: errorResponse[AppKeyConstant.message] as String);
                });
          });
        },
        onError: (Map<String, dynamic> errorData) {});
  }
}
