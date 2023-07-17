import 'package:energym/app_config.dart';
import 'package:energym/main.dart';
import 'package:energym/screens/home/home.dart';
import 'package:energym/screens/introduction/intro_slider.dart';
import 'package:energym/screens/login/login.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/helpers/push_nofitications.dart';
import 'package:flutter/material.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:energym/reusable_component/shared_pref_helper.dart';
import 'package:local_auth/local_auth.dart';

import '../profile_setup/profile_setup.dart';

// This is splash screen and it will open very first when app launch
// after that will navigate to other sceeen based on condition
class Splash extends StatefulWidget {
  static const String routeName = '/Splash';
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final LocalAuthentication? localAuth = LocalAuthentication();
  AppConfig? config;
  bool? iswalkThroughFinished = false;
  bool? isLoggedIn = false;
  String? userId = '';
  int? currentStep = 0;
  @override
  void initState() {
    super.initState();

    print("Enviroment = ${appEnv.name}");
    aGeneralBloc.services = [];

    getStoreData();
    Future.delayed(
      const Duration(seconds: 3),
      () {
        checkForSecurity();
      },
    );
  }

  Future<void> getStoreData() async {
    userId = await serviceLocator!
        .get<SharedPrefsHelper>()
        .get(SharedPrefskey.userId!, defaultValue: '') as String;

    currentStep = await serviceLocator!
        .get<SharedPrefsHelper>()
        .get(SharedPrefskey.currentStep, defaultValue: 0) as int;

    iswalkThroughFinished = await serviceLocator!
        .get<SharedPrefsHelper>()
        .get(SharedPrefskey.isWalkThroughFinished, defaultValue: false) as bool;

    isLoggedIn = await serviceLocator!
        .get<SharedPrefsHelper>()
        .get(SharedPrefskey.isLoogedIn, defaultValue: false) as bool;
  }

  @override
  Widget build(BuildContext context) {
    config = AppConfig.of(context);
    return CustomScaffold(
      //backgroundColor: config.windowBackground,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: config!.windowBackground,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                _widgetLogo(),
                _widgetPowerBy(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Check local authntication is enabled or not
  Future<void> checkForSecurity() async {
    final bool isSecurityEnable = await sharedPrefsHelper
        .get(SharedPrefskey.isSecurityEndable, defaultValue: false) as bool;
    if (isSecurityEnable) {
      localAuth!.isDeviceSupported().then((bool isDeviceSupported) async {
        if (isDeviceSupported) {
          bool canCheckBiometrics = await localAuth!.canCheckBiometrics;
          if (canCheckBiometrics) {
            bool didAuthenticate = await localAuth!.authenticate(
                localizedReason: 'Please authenticate to show access app',
                useErrorDialogs: true,
                stickyAuth: true);
            if (didAuthenticate) {
              moveToScreen();
            }
          } else {}
        } else {
          moveToScreen();
        }
      });
    } else {
      moveToScreen();
    }
  }

  Widget _widgetLogo() {
    return Center(
      child: Image.asset(
        ImgConstants.splashLogo,
        height: 323,
        width: 320,
        //boxfix: BoxFit.contain,
      ),
    );
  }

  Widget _widgetPowerBy() {
    return Positioned(
      bottom: 64,
      child: SvgPicture.asset(
        ImgConstants.humanPower,
      ),
    );
  }

  // Naviagte to another screen whrn condition satisfy
  void moveToScreen() {
    if (userId == '') {
      if (iswalkThroughFinished!) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Login.routeName,
          ModalRoute.withName('/'),
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          IntroSlider.routeName,
          ModalRoute.withName('/'),
        );
      }
    } else {
      if (currentStep == null) {
        Navigator.pushNamedAndRemoveUntil(
            context, ProfileSetUp.routeName!, ModalRoute.withName('/'),
            arguments: ProfileSetUpArgs(userId: userId, isNewUser: false));
      } else if (currentStep != 12) {
        Navigator.pushNamedAndRemoveUntil(
            context, ProfileSetUp.routeName!, ModalRoute.withName('/'),
            arguments: ProfileSetUpArgs(
                userId: userId,
                currentStep: (currentStep == null) ? 0 : currentStep! + 1,
                isNewUser: false));
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, Home.routeName, ModalRoute.withName('/'));
      }
    }
  }
}
