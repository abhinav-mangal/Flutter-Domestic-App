import 'package:energym/app_config.dart';
import 'package:energym/models/error_message_model.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/loader_button.dart';
import 'package:energym/reusable_component/shared_pref_helper.dart';
import 'package:energym/screens/home/home.dart';
import 'package:energym/screens/otp/otl_bloc.dart';
import 'package:energym/screens/profile_setup/profile_setup.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/helpers/firebase/auth_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/helpers/routing/router.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpVerificationArgs extends RoutesArgs {
  OtpVerificationArgs({
    required this.code,
    required this.mobile,
    required this.verificationId,
    required this.isNewUser,
    this.isReauthentication,
  }) : super(isHeroTransition: true);
  final String? mobile;
  final String? code;
  final String? verificationId;
  final bool? isNewUser;
  final bool? isReauthentication;
}

class OtpVerification extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  OtpVerification({
    Key? key,
    required this.code,
    required this.mobile,
    required this.verificationId,
    required this.isNewUser,
    this.isReauthentication,
  }) : super(key: key);

  static const String routeName = '/OtpVerification';

  final String? mobile;
  final String? code;
  final String? verificationId;
  final bool? isNewUser;
  final bool? isReauthentication;

  @override
  _OtpVerificationState createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  OtpVerificationBloc? _blocOtpVerification;
  AppConfig? _config;
  String? _code;
  String? _mobile;
  String? _verificationId;
  bool? _isNewUser;
  bool? _isReauthentication;
  int? codeLength = 6;
  APIProvider? _api;
  final TextEditingController _otpController = TextEditingController();

  ValueNotifier<bool> _notifierIsResendingOtp = ValueNotifier<bool>(false);
  @override
  void initState() {
    super.initState();
    _api = APIProvider.of(context);
    _code = widget.code;
    _mobile = widget.mobile;
    _verificationId = widget.verificationId;
    _isNewUser = widget.isNewUser;
    _isReauthentication = widget.isReauthentication ?? false;
    _blocOtpVerification = OtpVerificationBloc();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            padding: EdgeInsets.zero,
            width: double.infinity,
            height: double.infinity,
            child: _mainContainer(context),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(
      context,
      _config!,
      title: '',
      backgoundColor: Colors.transparent,
      //textColor: AppColors.textColorWhite,
      elevation: 0,
      //isBackEnable: true,
      //gradient: AppColors.gradintBtnSignUp,
      onBack: () {
        aGeneralBloc.updateAPICalling(false);
        Navigator.pop(context);
      },
    );
  }

  Widget _mainContainer(BuildContext mainContext) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _widgetVerifyText(),
          _widgetVerifyTextMsg(),
          _otpField(),
          _btnContinue(mainContext),
          _widgetDontHaveText(),
          _widgetResend(mainContext),
        ],
      ),
    );
    // return FutureBuilder<void>(
    //     future: SmsAutoFill().listenForCode,
    //     builder: (BuildContext context, AsyncSnapshot<void> snapshot) {

    //     });
  }

  Widget _widgetVerifyText() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: Text(
        AppConstants.veryfyPhone,
        style: _config!.calibriHeading2FontStyle.apply(
          color: _config!.whiteColor,
        ),
      ),
    );
  }

  Widget _widgetVerifyTextMsg() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(32, 22, 32, 0),
      child: Text(
        '${AppConstants.veryfyPhoneMsg} ${_mobile!.hidePhoneNumber(lastdigit: 2)}',
        style: _config!.paragraphNormalFontStyle.apply(
          color: _config!.greyColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _otpField() {
    return StreamBuilder<ErrorMessage>(
        stream: _blocOtpVerification!.otpErrorStream,
        initialData: ErrorMessage(false, ''),
        builder: (BuildContext context, AsyncSnapshot<ErrorMessage> snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 36, 24, 0),
                  child: PinCodeTextField(
                    //textInputType: TextInputType.number,
                    keyboardType: TextInputType.number,
                    keyboardAppearance: _config!.brightness,
                    appContext: context,
                    pastedTextStyle: TextStyle(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                    length: codeLength!,
                    textStyle: _config!.calibriHeading3FontStyle
                        .apply(color: _config!.whiteColor),
                    animationType: AnimationType.fade,
                    validator: (String? v) {
                      if (v!.length < 6) {
                        return '';
                      } else {
                        return null;
                      }
                    },
                    cursorColor: _config!.btnPrimaryColor,
                    enableActiveFill: true,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(4),
                      fieldHeight: 48,
                      fieldWidth: getEachCellsWidth(context),
                      activeColor: snapshot.data!.isError
                          ? Colors.red
                          : Colors.transparent,
                      selectedColor: snapshot.data!.isError
                          ? Colors.red
                          : Colors.transparent,
                      inactiveColor: snapshot.data!.isError
                          ? Colors.red
                          : Colors.transparent,
                      activeFillColor: _config!.borderColor,
                      selectedFillColor: _config!.borderColor,
                      inactiveFillColor: _config!.borderColor,
                      borderWidth: 1,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    controller: _otpController,
                    onCompleted: (String v) {
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (String value) {
                      _blocOtpVerification!.onChangeOtp(value);
                    },
                    beforeTextPaste: (String? text) {
                      return true;
                    },
                  )),
              Visibility(
                visible: snapshot.data!.isError,
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: AutoSizeText(
                    snapshot.data!.errorMessage,
                    style: context.theme.textTheme.bodyText2!
                        .apply(color: Colors.red),
                  ),
                ),
              )
            ],
          );
        });
  }

  Widget _btnContinue(BuildContext mainContext) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
      child: StreamBuilder<bool>(
          stream: _blocOtpVerification!.otpSubmitStream,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            bool isValid = false;
            if (snapshot.hasData && snapshot.data != null) {
              isValid = snapshot.data!;
            }
            return StreamBuilder<bool>(
                stream: aGeneralBloc.getIsApiCalling,
                builder: (BuildContext context,
                    AsyncSnapshot<bool> apiCallingSnapshot) {
                  bool isLoading = false;
                  if (apiCallingSnapshot.hasData && apiCallingSnapshot.data != null) {
                    isLoading = apiCallingSnapshot.data!;
                  }
                  return LoaderButton(
                      backgroundColor: _config!.btnPrimaryColor,
                      isEnabled: isValid,
                      isLoading: isLoading,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        aGeneralBloc.updateAPICalling(true);
                        AuthProvider.instance.signInWithPhoneNumber(
                            context: mainContext,
                            smsCode: _otpController.text,
                            verificationId: _verificationId!,
                            mobile: _mobile!,
                            onSuccess:
                                (Map<String, dynamic> successData) async {
                              final String userID = successData['userId'] as String;
                              await sharedPrefsHelper.set(SharedPrefskey.isLoogedIn, true);
                              await sharedPrefsHelper.set(SharedPrefskey.userId!, userID);
                              print('_isNewUser >>> $_isNewUser');
                              if (_isNewUser!) {
                                createSweatCoinNewUser(
                                    userId: userID,
                                    countryCode: _code!,
                                    mobile: _mobile!);
                              } else {
                                FireStoreProvider.instance.getCurrentUserData(
                                    userId: userID,
                                    onSuccess: (UserModel data) async {
                                      await sharedPrefsHelper.set(SharedPrefskey.currentStep,data.currStep);

                                      aGeneralBloc.updateCurrentUser(data);

                                      if (data.currStep == 10) {
                                        aGeneralBloc.updateAPICalling(false);
                                        if (_isReauthentication!) {
                                          Navigator.pop(context, true);
                                        } else {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            Home.routeName,
                                            ModalRoute.withName('/'),
                                          );
                                        }
                                      } else {
                                        aGeneralBloc.updateAPICalling(false);
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            ProfileSetUp.routeName!,
                                            ModalRoute.withName('/'),
                                            arguments: ProfileSetUpArgs(
                                                userId: userID,
                                                currentStep: data.currStep! + 1,
                                                isNewUser: _isNewUser!));
                                      }
                                    },
                                    onError:
                                        (Map<String, dynamic> errorResponse) {
                                      aGeneralBloc.updateAPICalling(false);
                                    });
                              }
                            },
                            onError: (Map<String, dynamic> errorData) {
                              aGeneralBloc.updateAPICalling(false);
                            });
                      },
                      title: AppConstants.continueStr);
                });
          }),
    );
  }

  Widget _widgetDontHaveText() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 94, 0, 0),
      child: Text(
        AppConstants.dontHaveCode,
        style: _config!.paragraphNormalFontStyle.apply(
          color: _config!.greyColor,
        ),
      ),
    );
  }

  Widget _widgetResend(BuildContext mainContext) {
    return StreamBuilder<bool>(
      stream: _blocOtpVerification!.resendVisibleStream,
      initialData: true,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.data!) {
          return _widgetBtnResend(mainContext);
        }
        return _resendTimer(context);
      },
    );
  }

  Widget _resendTimer(BuildContext context) {
    return StreamBuilder<int>(
        stream: _blocOtpVerification!.resendTimeStream,
        initialData: 59,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(5),
            child: AutoSizeText(
              'Resend code in 00:${snapshot.data! < 10 ? ("0" + snapshot.data.toString()) : snapshot.data}',
              style:
                  _config!.linkNormalFontStyle.apply(color: _config!.greyColor),
            ),
          );
        });
  }

  Widget _widgetBtnResend(BuildContext mainContext) {
    return ValueListenableBuilder<bool>(
      valueListenable: _notifierIsResendingOtp,
      builder: (BuildContext? context, bool? isResending, Widget? child) {
        if (isResending!) {
          return SpinKitCircle(
            color: _config!.btnPrimaryColor,
            size: 20,
          );
        }
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
          child: TextButton(
            onPressed: () {
              _notifierIsResendingOtp.value = true;
              AuthProvider.instance.sendCode(
                  context: mainContext,
                  countryCode: _code!,
                  mobile: _mobile!,
                  onSuccess: (Map<String, dynamic> successData) {
                    aGeneralBloc.updateAPICalling(false);
                    _notifierIsResendingOtp.value = false;
                    _verificationId = successData['verificationId'] as String;
                    _otpController.clear();
                    _blocOtpVerification!.otpValidateStream!
                        .add(_otpController.text);
                    _blocOtpVerification!.showTimer();
                    _blocOtpVerification!.resendTimerSink!.add(59);
                    _blocOtpVerification!.resendVisibleSink!.add(false);
                  },
                  onError: (Map<String, dynamic> errorData) {
                    aGeneralBloc.updateAPICalling(false);
                    _notifierIsResendingOtp.value = false;
                  });
            },
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(
              AppConstants.redend,
              style: _config!.linkNormalFontStyle
                  .apply(color: _config!.btnPrimaryColor),
            ),
          ),
        );
      },
    );
  }

  double getEachCellsWidth(BuildContext context) {
    final double totalWidth = context.width - 48;
    final double totalWidthAfterPadding = totalWidth -
        ((codeLength! - 1) *
            8); // If we have 4 cells with 8 padding between them then there will be 3 gaps where the //padding will be applied, hence it will be totalWidth - ((totalcells - 1) * 8);
    return totalWidthAfterPadding / codeLength!;
  }

  Future<void> createSweatCoinNewUser(
      {required String? userId,
      required String? countryCode,
      required String? mobile}) async {
    String jwtToken = aGeneralBloc.createjWTToken({
      'external_user_id': userId,
      'country_code': 'us',
      'language': 'en',
    });

    final Map<String, dynamic> data = await getAPIData(jwtToken);
    registerNewUser(
        countryCode: countryCode!,
        mobile: mobile!,
        userId: userId!,
        jwtToken: jwtToken,
        sweatCoinId: "");

    //  TODOO REintegtaion
    // ignore: use_build_context_synchronously
    await _api!.postAPICall(context, APIConstant.createSweatCoin, data,
        jwtToken: jwtToken,
        onSuccess: (Response? response, Map<String, dynamic>? json) {
      String sweatCoinId = json!['data']['authentication_token'] as String;
      registerNewUser(
          countryCode: countryCode,
          mobile: mobile,
          userId: userId,
          jwtToken: jwtToken,
          sweatCoinId: sweatCoinId);
      print('createSweatCoinNewUser success >>> $json');
    }, onError: (Response? response, Map<String, dynamic>? jsonData) {
      print('createSweatCoinNewUser error>>> $jsonData');
      registerNewUser(
        countryCode: countryCode,
        mobile: mobile,
        userId: userId,
      );
    });
  }

  Future<Map<String, dynamic>> getAPIData(String jwtToken) async {
    Map<String, dynamic> data = {};
    data[APIConstant.requestKeys.clientId] =
        AppKeyConstant.sweatCoinClientIdProduction;
    data[APIConstant.requestKeys.payload] = jwtToken;

    debugPrint("login data >>> $data");
    return data;
  }

  Future<void> registerNewUser(
      {required String? userId,
      required String? countryCode,
      required String? mobile,
      String? jwtToken,
      String? sweatCoinId}) async {
    // final String? fcmToken =
    //     await sharedPrefsHelper.get(SharedPrefskey.fcmToken) as String;
    final dynamic? fcmToken =
        await sharedPrefsHelper.get(SharedPrefskey.fcmToken);
    Map<String, dynamic> data = {};
    data[UserCollectionField.documentId] = userId;
    data[UserCollectionField.countryCode] = countryCode;
    data[UserCollectionField.mobileNumber] = mobile;
    data[UserCollectionField.jwtToken] = jwtToken;
    data[UserCollectionField.sweatcoinId] = sweatCoinId;
    data[UserCollectionField.isActive] = true;

    data[UserCollectionField.deviceToken] = fcmToken;
    FireStoreProvider.instance.registerNewUser(
        mobile: _mobile!,
        documentId: userId!,
        data: data,
        onSuccess: (Map<String, dynamic> successResponse) {
          aGeneralBloc.updateAPICalling(false);
          Navigator.pushNamedAndRemoveUntil(
              context, ProfileSetUp.routeName!, ModalRoute.withName('/'),
              arguments:
                  ProfileSetUpArgs(userId: userId, isNewUser: _isNewUser!));
        },
        onError: (Map<String, dynamic> errorResponse) {
          aGeneralBloc.updateAPICalling(false);
        });
  }
}
