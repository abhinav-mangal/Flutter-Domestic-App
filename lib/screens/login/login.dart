import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/countryPicker/country_model.dart';
import 'package:energym/reusable_component/countryPicker/functions.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/custom_textfield.dart';
import 'package:energym/reusable_component/loader_button.dart';
import 'package:energym/reusable_component/shared_pref_helper.dart';
import 'package:energym/screens/forgot_password/forgot_password.dart';
import 'package:energym/screens/home/home.dart';
import 'package:energym/screens/login/login_bloc.dart';
import 'package:energym/screens/profile_setup/profile_setup.dart';
import 'package:energym/screens/signup/signup.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/helpers/firebase/auth_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

// Login screen , to signin user using email and password
class Login extends StatefulWidget {
  static const String routeName = '/Login';
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  AppConfig? _config;
  // final TextEditingController? _txtFieldPhoneNumber = TextEditingController();
  final TextEditingController? _txtFieldEmail = TextEditingController();
  final FocusNode? _focusNodeEmail = FocusNode();

  final TextEditingController? _txtFieldPassword = TextEditingController();
  final FocusNode? _focusNodePassword = FocusNode();

  LoginBloc? _blocLogin;
  CountryModel? _selectedCountry;
  @override
  void initState() {
    super.initState();
    _blocLogin = LoginBloc();

    setLoginData();
  }

  @override
  void dispose() {
    _txtFieldEmail!.dispose();
    _focusNodeEmail!.dispose();
    _txtFieldPassword!.dispose();
    _focusNodePassword!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            padding: EdgeInsets.zero,
            width: double.infinity,
            height: double.infinity,
            color: AppColors.greyColor,
            child: _widgetMainContainer(context),
          ),
        ),
      ),
    );
  }

  // Setup login credential from
  setLoginData() async {
    var email = await FlutterKeychain.get(key: 'email');
    _txtFieldEmail?.text = email ?? '';

    var password = await FlutterKeychain.get(key: 'password');
    _txtFieldPassword?.text = password ?? '';
  }

  Widget _widgetMainContainer(BuildContext mainContext) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 2.1,
                width: double.infinity,
                child: Container(
                  child: Image.asset(
                    ImgConstants.loginRegenImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 70, left: 30),
            child: Container(
              height: 150,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.welcomeOnly,
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontFamily: _config!.fontFamilyAbel),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'OHM',
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontFamily: _config!.fontFamilyAbel),
                  ),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            padding: new EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 2.3,
            ),
            child: Container(
              padding: EdgeInsets.only(left: 22, right: 22),
              width: double.infinity,
              // height: MediaQuery.of(context).size.height / 1.7,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  color: AppColors.greyColor),
              child: Column(
                children: [
                  Container(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          loginButton(),
                          registrationButton(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  textFieldEmail(),
                  SizedBox(
                    height: 20,
                  ),
                  textFieldPassword(),
                  forgotPassButton(),
                  _btnLogin(context)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget loginButton() {
    return Container(
      child: Center(
        child: NeumorphicButton(
          style: NeumorphicStyle(
            depth: -2,
            intensity: 0.7,
            surfaceIntensity: 1,
            color: AppColors.greyColor1,
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
          ),
          child: SizedBox(
            height: 30,
            width: 100,
            child: Container(
              // color: Colors.bl,
              child: Center(
                child: Text(
                  AppConstants.login,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: _config!.fontFamilyInter),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget registrationButton() {
    return Container(
      child: Center(
        child: NeumorphicButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Signup();
            }));
          },
          style: NeumorphicStyle(
            depth: -2,
            intensity: 0.7,
            surfaceIntensity: 1,
            color: AppColors.greyColor1,
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
          ),
          child: SizedBox(
            height: 30,
            width: 100,
            child: Container(
              // color: Colors.bl,
              child: Center(
                  child: Text(AppConstants.register,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: _config!.fontFamilyInter))),
            ),
          ),
        ),
      ),
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
        inputAction: TextInputAction.next,
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
        maxlength: 50,
        hintTextStyle: _config!.interTextField1FontStyle,
      ),
    );
  }

  Widget textFieldPassword() {
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
        hindText: AppConstants.password,
        context: context,
        controller: _txtFieldPassword,
        focussNode: _focusNodePassword,
        bgColor: Colors.transparent,
        lableText: AppConstants.password,
        inputType: TextInputType.text,
        isObscureText: true,
        maxline: 1,
        capitalization: TextCapitalization.none,
        inputAction: TextInputAction.done,
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
        maxlength: 50,
        hintTextStyle: _config!.interTextField1FontStyle,
      ),
    );
  }

  Widget forgotPassButton() {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            child: Text(AppConstants.forgotpassword,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.right),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ForGotPassword()));
            },
          ),
        ],
      ),
    );
  }

  Widget _btnLogin(BuildContext mainContext) {
    double height = MediaQuery.of(context).size.height - 70;
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 20),
      child: StreamBuilder<bool>(
          stream: _blocLogin!.validateLoginForm,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            return StreamBuilder<bool>(
                stream: aGeneralBloc.getIsApiCalling,
                initialData: false,
                builder: (BuildContext context,
                    AsyncSnapshot<bool> apiCallingSnapshot) {
                  bool isLoading = false;
                  if (apiCallingSnapshot.hasData &&
                      apiCallingSnapshot.data != null) {
                    isLoading = apiCallingSnapshot.data!;
                  }
                  return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        gradient: LinearGradient(colors: [
                          AppColors.greenColor2,
                          AppColors.greenColor1
                        ])),
                    child: LoaderButton(
                        titleStyle: _config!.interButtonFontStyle,
                        radius: 12,
                        backgroundColor: Colors.transparent,
                        isLoading: isLoading,
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if (_blocLogin!.validation(
                              email: _txtFieldEmail!.text,
                              password: _txtFieldPassword!.text,
                              context: context)) {
                            aGeneralBloc.updateAPICalling(true);

                            await FlutterKeychain.put(
                              key: 'email',
                              value: _txtFieldEmail?.text ?? '',
                            );
                            await FlutterKeychain.put(
                              key: 'password',
                              value: _txtFieldPassword?.text ?? '',
                            );

                            AuthProvider.instance.signInWithEmailPassword(
                                context: context,
                                email: _txtFieldEmail!.text,
                                password: _txtFieldPassword!.text,
                                onSuccess:
                                    (Map<String, dynamic> successData) async {
                                  print(successData);

                                  final String userID =
                                      successData['userId'] as String;
                                  await sharedPrefsHelper.set(
                                      SharedPrefskey.isLoogedIn, true);
                                  await sharedPrefsHelper.set(
                                      SharedPrefskey.userId!, userID);
                                  await sharedPrefsHelper.set(
                                      SharedPrefskey.loginuserId!, userID);

                                  FireStoreProvider.instance.getCurrentUserData(
                                      userId: userID,
                                      onSuccess: (UserModel data) async {
                                        await sharedPrefsHelper.set(
                                            SharedPrefskey.currentStep,
                                            data.currStep);

                                        aGeneralBloc.updateCurrentUser(data);
                                        if (data.currStep == 12) {
                                          aGeneralBloc.updateAPICalling(false);
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            Home.routeName,
                                            ModalRoute.withName('/'),
                                          );
                                        } else {
                                          aGeneralBloc.updateAPICalling(false);
                                          Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              ProfileSetUp.routeName!,
                                              ModalRoute.withName('/'),
                                              arguments: ProfileSetUpArgs(
                                                  userId: userID,
                                                  currentStep:
                                                      data.currStep ?? 0,
                                                  isNewUser: true));
                                        }
                                      },
                                      onError:
                                          (Map<String, dynamic> errorResponse) {
                                        aGeneralBloc.updateAPICalling(false);
                                      });
                                },
                                onError: (Map<String, dynamic> errorResponse) {
                                  print(errorResponse);
                                  aGeneralBloc.updateAPICalling(false);
                                });
                          } else {
                            aGeneralBloc.updateAPICalling(false);
                          }
                        },
                        title: AppConstants.login),
                  );
                });
          }),
    );
  }
}
