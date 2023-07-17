import 'package:energym/app_config.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/reusable_component/custom_textfield.dart';
import 'package:energym/reusable_component/loader_button.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/screens/forgot_password/forgot_password_bloc.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

// Forgot password screen to reset password
class ForGotPassword extends StatefulWidget {
  @override
  State<ForGotPassword> createState() => _ForGotPasswordState();
}

class _ForGotPasswordState extends State<ForGotPassword> {
  AppConfig? _config;

  final TextEditingController? _txtFieldEmail = TextEditingController();
  final FocusNode? _focusNodeEmail = FocusNode();
  ForGotPasswordBloc _forgotBloc = ForGotPasswordBloc();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: getMainAppBar(
          context,
          _config!,
          backgoundColor: AppColors.greyColor,
          textColor: _config!.whiteColor,
          title: AppConstants.forgotPassword,
          elevation: 0,
          onBack: () {
            Navigator.pop(context);
          },
        ),
        body: Container(
          padding: EdgeInsets.only(top: 50, left: 15, right: 15),
          color: AppColors.greyColor,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [textFieldEmail(), _forGotPasswordButton()],
          ),
        ),
      ),
    );
  }

  Widget _topText() {
    return Text(
      AppConstants.forgotPassword,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget textFieldEmail() {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -2,
        intensity: 0.7,
        surfaceIntensity: 1,
        color: AppColors.greyColor1,
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      child: CustomTextField(
        isAGradientShadow: true,
        hindText: AppConstants.hintEmailAddress,
        context: context,
        controller: _txtFieldEmail,
        focussNode: _focusNodeEmail,
        bgColor: Colors.transparent,
        lableText: AppConstants.email,
        inputType: TextInputType.emailAddress,
        capitalization: TextCapitalization.none,
        inputAction: TextInputAction.done,
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
        maxlength: 50,
        hintTextStyle: _config!.interTextField1FontStyle,
      ),
    );
  }

  Widget _forGotPasswordButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: StreamBuilder<bool>(
          stream: aGeneralBloc.getIsApiCalling,
          builder: (context, snapshot) {
            return Container(
              width: double.infinity,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    gradient: LinearGradient(colors: [
                      AppColors.greenColor2,
                      AppColors.greenColor1
                    ])),
                child: LoaderButton(
                  titleStyle: _config!.interButtonFontStyle,
                  backgroundColor: Colors.transparent,
                  isOutLine: false,
                  isEnabled: true,
                  isLoading: snapshot.data ?? false,
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    final validationResult = _forgotBloc.validation(
                        email: _txtFieldEmail?.text ?? "", context: context);

                    if (validationResult) {
                      aGeneralBloc.updateAPICalling(true);
                      // call firebase api to send mail for password
                      await resetPassword(email: _txtFieldEmail?.text ?? "");
                    }
                  },
                  buttonHeight: 50,
                  title: AppConstants.submit,
                  radius: 12,
                ),
              ),
            );
          }),
    );
  }

  // This function to rest passweord and wll send email
  Future<void> resetPassword({required String email}) async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .then((value) {
      print('value');
      aGeneralBloc.updateAPICalling(false);
      const CustomAlertDialog().showExeptionErrorMessage(
        context: context,
        title: AppConstants.appName,
        message: AppConstants.emailsent,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );
    }).catchError((e) {
      aGeneralBloc.updateAPICalling(false);
      print(e);
      const CustomAlertDialog().showExeptionErrorMessage(
        context: context,
        title: AppConstants.appName,
        message: (e as FirebaseAuthException).message,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );
    });
  }
}
