import 'dart:io';

import 'package:energym/app_config.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/reusable_component/custom_textfield.dart';
import 'package:energym/reusable_component/img_picker.dart';
import 'package:energym/reusable_component/loader_button.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/reusable_component/shared_pref_helper.dart';
import 'package:energym/screens/signup/signup_bloc.dart';
import 'package:energym/screens/user_profile/edit_user_profile_bloc.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/config.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/helpers/firebase/auth_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/helpers/firebase/storage_provider.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_keychain/flutter_keychain.dart';

// Signup screen to register new user
class Signup extends StatefulWidget {
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  AppConfig? _config;

  final TextEditingController? _txtFieldName = TextEditingController();
  final FocusNode? _focusNodeName = FocusNode();

  final TextEditingController? _txtFieldEmail = TextEditingController();
  final FocusNode? _focusNodeEmail = FocusNode();

  final TextEditingController? _txtFieldPhoneNumber = TextEditingController();
  final FocusNode? _focusNodePhoneNumber = FocusNode();

  final TextEditingController? _txtFielPassword = TextEditingController();
  final FocusNode? _focusNodePassword = FocusNode();

  final TextEditingController? _txtFieldCPassword = TextEditingController();
  final FocusNode? _focusNodeCPassword = FocusNode();

  SignupBloc _signupBloc = SignupBloc();
  APIProvider? _api;
  dynamic? _selecteProfile;
  EditProfileBloc? _blocProfileSetUp;

  @override
  void initState() {
    super.initState();
    _api = APIProvider.of(context);
    _blocProfileSetUp = EditProfileBloc();
  }

  @override
  void dispose() {
    _blocProfileSetUp!.dispose();
    _txtFieldPhoneNumber!.dispose();
    _focusNodePhoneNumber!.dispose();
    super.dispose();
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
          title: AppConstants.registration,
          elevation: 0,
          onBack: () {
            Navigator.pop(context);
          },
        ),
        body: Container(
          color: AppColors.greyColor,
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _thumbnail(mainContext: context),
                textFieldName(),
                textFieldEmail(),
                // textFieldPhoneNumber(),
                textFieldPassword(),
                textFieldCPassword(),
                _SignupButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topText() {
    return Text(
      'Registration',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _thumbnail({BuildContext? mainContext}) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: StreamBuilder<dynamic>(
                stream: _blocProfileSetUp?.getProfilePic,
                builder: (context, snapshot) {
                  print(snapshot.hasData);
                  print(snapshot.data);
                  if (snapshot.hasData) {
                    return ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            color: Colors.black,
                          ),
                          child: Image.file(snapshot.data as File,
                              fit: BoxFit.cover)),
                    );
                  }
                  return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Colors.black,
                      ),
                      child:
                          Image.asset(ImgConstants.avatar, fit: BoxFit.cover));
                }),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              height: 40,
              child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: mainContext!,
                      builder: (BuildContext context) {
                        return ImagePickerHelper(
                          title: AppConstants.hintProfilePicture,
                          isCropped: true,
                          cropStyle: CropStyle.circle,
                          size: SizeConfig.kSquare400Size,
                          onDone: (File? file) {
                            if (file != null) {
                              print(file);

                              _selecteProfile = file;
                              _blocProfileSetUp!.onChangeProfilePic(
                                  value: _selecteProfile, isShowError: true);
                            }
                          },
                        );
                      },
                    );
                  },
                  child: Image.asset(ImgConstants.plusButton)),
            ),
          ),
        ],
      ),
    );
  }

  Widget textFieldName() {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Neumorphic(
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
            hindText: AppConstants.fullName,
            context: context,
            controller: _txtFieldName,
            focussNode: _focusNodeName,
            bgColor: Colors.transparent,
            lableText: AppConstants.fullName,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            inputType: TextInputType.text,
            capitalization: TextCapitalization.words,
            inputAction: TextInputAction.next,
            enableSuggestions: true,
            isAutocorrect: true,
            maxlength: 50,
            hintTextStyle: _config!.interTextField1FontStyle,
          ),
        ));
  }

  Widget textFieldEmail() {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Neumorphic(
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
            hindText: AppConstants.email,
            context: context,
            controller: _txtFieldEmail,
            focussNode: _focusNodeEmail,
            bgColor: Colors.transparent,
            lableText: AppConstants.email,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            inputType: TextInputType.emailAddress,
            capitalization: TextCapitalization.none,
            inputAction: TextInputAction.go,
            enableSuggestions: true,
            isAutocorrect: true,
            maxlength: 50,
            hintTextStyle: _config!.interTextField1FontStyle,
          ),
        ));
  }

  Widget textFieldPhoneNumber() {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Neumorphic(
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
            hindText: AppConstants.phoneNumber,
            context: context,
            controller: _txtFieldPhoneNumber,
            focussNode: _focusNodePhoneNumber,
            bgColor: Colors.transparent,
            lableText: AppConstants.phoneNumber,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            inputType: TextInputType.phone,
            capitalization: TextCapitalization.none,
            inputAction: TextInputAction.go,
            enableSuggestions: true,
            isAutocorrect: true,
            maxlength: 50,
            hintTextStyle: _config!.interTextField1FontStyle,
          ),
        ));
  }

  Widget textFieldPassword() {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Neumorphic(
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
            hindText: AppConstants.password,
            context: context,
            controller: _txtFielPassword,
            focussNode: _focusNodePassword,
            bgColor: Colors.transparent,
            lableText: AppConstants.password,
            isObscureText: true,
            inputType: TextInputType.text,
            capitalization: TextCapitalization.none,
            inputAction: TextInputAction.next,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            maxlength: 50,
            maxline: 1,
            hintTextStyle: _config!.interTextField1FontStyle,
          ),
        ));
  }

  Widget textFieldCPassword() {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Neumorphic(
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
            hindText: AppConstants.cpassword,
            context: context,
            controller: _txtFieldCPassword,
            focussNode: _focusNodeCPassword,
            isObscureText: true,
            bgColor: Colors.transparent,
            lableText: AppConstants.cpassword,
            inputType: TextInputType.text,
            capitalization: TextCapitalization.none,
            inputAction: TextInputAction.done,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            maxlength: 50,
            maxline: 1,
            hintTextStyle: _config!.interTextField1FontStyle,
          ),
        ));
  }

  Widget _SignupButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
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
                    await FlutterKeychain.put(
                      key: 'email',
                      value: _txtFieldEmail?.text ?? '',
                    );
                    await FlutterKeychain.put(
                      key: 'password',
                      value: _txtFielPassword?.text ?? '',
                    );

                    final validationResult = _signupBloc.validation(
                      name: _txtFieldName?.text ?? '',
                      email: _txtFieldEmail?.text ?? '',
                      password: _txtFielPassword?.text ?? '',
                      cPassword: _txtFieldCPassword?.text ?? '',
                      context: context,
                      phone: _txtFieldPhoneNumber?.text ?? '',
                    );

                    if (validationResult) {
                      aGeneralBloc.updateAPICalling(true);
                      // Api call to register
                      AuthProvider.instance.signUpWithEmailPassword(
                          context: context,
                          email: _txtFieldEmail?.text.trim() ?? '',
                          password: _txtFielPassword?.text ?? '',
                          onSuccess: (Map<String, dynamic> successData) async {
                            final String userID =
                                successData['userId'] as String;

                            // Save level data
                            final Map<String, dynamic> data =
                                <String, dynamic>{};

                            createSweatCoinNewUser(
                                userId: userID,
                                email: _txtFieldEmail?.text.trim() ?? "");
                          },
                          onError: (Map<String, dynamic> errorResponse) {
                            print(errorResponse);
                            aGeneralBloc.updateAPICalling(false);
                          });
                    }
                  },
                  buttonHeight: 50,
                  title: AppConstants.signup,
                  radius: 12,
                ),
              ),
            );
          }),
    );
  }

  // This function is to create new sweatcoin user
  Future<void> createSweatCoinNewUser(
      {required String? userId, required String? email}) async {
    String jwtToken = aGeneralBloc.createjWTToken({
      'external_user_id': userId,
      'country_code': 'us',
      'language': 'en',
    });

    final Map<String, dynamic> data = await getAPIData(jwtToken);
    // registerNewUser(
    //   userId: userId!,
    //   jwtToken: jwtToken,
    //   sweatCoinId: '',
    //   email: email,
    // );

    //  TODOO REintegtaion
    // ignore: use_build_context_synchronously
    await _api!.postAPICall(context, APIConstant.createSweatCoin, data,
        jwtToken: jwtToken,
        onSuccess: (Response? response, Map<String, dynamic>? json) {
      String sweatCoinId = json!['data']['authentication_token'] as String;
      registerNewUser(
        userId: userId,
        jwtToken: jwtToken,
        sweatCoinId: sweatCoinId,
        email: email,
      );
      print('createSweatCoinNewUser success >>> $json');
    }, onError: (Response? response, Map<String, dynamic>? jsonData) {
      print('createSweatCoinNewUser error>>> $jsonData');
      registerNewUser(
        userId: userId,
        email: email,
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

  // This function to register new user in system
  Future<void> registerNewUser(
      {required String? userId,
      required String? email,
      String? jwtToken,
      String? sweatCoinId}) async {
    final dynamic? fcmToken =
        await sharedPrefsHelper.get(SharedPrefskey.fcmToken);
    Map<String, dynamic> data = {};
    data[UserCollectionField.documentId] = userId;
    data[UserCollectionField.email] = email;
    data[UserCollectionField.mobileNumber] = _txtFieldPhoneNumber?.text.trim();
    data[UserCollectionField.jwtToken] = jwtToken;
    data[UserCollectionField.sweatcoinId] = sweatCoinId;
    data[UserCollectionField.isActive] = false;
    data[UserCollectionField.fullName] = _txtFieldName?.text.trim();
    data[UserCollectionField.deviceToken] = fcmToken;
    data[UserCollectionField.timeZoneName] = DateTime.now().timeZoneName;
    data[UserCollectionField.level] = 1;
    data[UserCollectionField.videoName] = LevelVideoName.levelVideoName1;
    data[UserCollectionField.levelName] = LevelLevelName.levelLevelName1;
    data[UserCollectionField.generatedenergy] = 0;
    data[UserCollectionField.workoutCountInLevel] = 0;

    FireStoreProvider.instance.registerNewUserWilthEmail(
        documentId: userId!,
        data: data,
        onSuccess: (Map<String, dynamic> successResponse) {
          if (_selecteProfile is File) {
            uplaodFile(userId);
          } else {
            displayAlert(context, AppConstants.accountCreatedSuccessfully);
          }
        },
        onError: (Map<String, dynamic> errorResponse) {
          aGeneralBloc.updateAPICalling(false);
        },
        email: email);
  }

  displayAlert(BuildContext context, String message) {
    CustomAlertDialog().showAlert(
        context: context,
        message: message,
        title: AppConstants.appName,
        onSuccess: () {
          aGeneralBloc.updateAPICalling(false);
          Navigator.pop(context);
        });
  }

  // This function to upload thumbnail
  uplaodFile(String documentId) async {
    if (_selecteProfile is File) {
      final File image = _selecteProfile as File;
      final String fileExtenstion = path.extension(image.path);
      final String fileName = '${documentId}$fileExtenstion';
      await StorageProvider.instance.uploadFile(
          profilePic: image,
          fileName: fileName,
          onSuccess: (String imageUrl) {
            displayAlert(context, AppConstants.accountCreatedSuccessfully);
          },
          onError: (String errorMsg) {
            print(errorMsg);
            aGeneralBloc.updateAPICalling(false);
          });
    } else {
      aGeneralBloc.updateAPICalling(false);
      Navigator.pop(context);
    }
  }
}
