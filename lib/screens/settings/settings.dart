import 'dart:io';

import 'package:energym/app_config.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/reusable_component/shared_pref_helper.dart';
import 'package:energym/screens/cms/cms.dart';
import 'package:energym/screens/device_connection/device_connection.dart';
import 'package:energym/screens/login/login.dart';
import 'package:energym/screens/settings/setting_bloc.dart';
import 'package:energym/screens/your_planet.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/common/svg_picture_customise.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/helpers/firebase/auth_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info/package_info.dart';
import 'package:energym/models/user_model.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);
  static const String routeName = '/AppSettings';

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  AppConfig? _appConfig;
  final ValueNotifier<bool>? _notifierNotification = ValueNotifier<bool>(false);
  SettinngBloc? _settinngBloc = SettinngBloc();
  UserModel? _currentUser;
  APIProvider? _api;
  var connectedDevice = aGeneralBloc.getSelectedBike();
  final LocalAuthentication localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _currentUser = aGeneralBloc.currentUser;
    _api = APIProvider.of(context);
    checkForSecurity();
    getJWT();
  }

  Future<void> checkForSecurity() async {
    final bool isSecurityEnable =
        await sharedPrefsHelper.get(SharedPrefskey.isSecurityEndable) as bool;
    _notifierNotification!.value = isSecurityEnable;
  }

  @override
  Widget build(BuildContext context) {
    _appConfig = AppConfig.of(context);

    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        child: _widgetMainContainer(),
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _appConfig!,
        backgoundColor: Colors.transparent,
        textColor: _appConfig!.whiteColor,
        title: AppConstants.settings,
        centerTitle: true,
        elevation: 0,
        //gradient: AppColors.gradintBtnSignUp,
        onBack: () {
      aGeneralBloc.updateAPICalling(false);
      Navigator.pop(context);
    }, actions: <Widget>[
      btnSweatCointBalance(context, _appConfig!),
    ]);
  }

  Widget _widgetMainContainer() {
    return Container(
      padding: EdgeInsets.zero,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _widgetTile(
                  leadingIcon: ImgConstants.privacy,
                  sufixIcon: ImgConstants.forwardArrow,
                  child: Text(
                    AppConstants.privacy,
                    style: _appConfig!.linkNormalFontStyle
                        .apply(color: _appConfig!.whiteColor),
                  ),
                  onPress: () {
                    Navigator.pushNamed(context, CMS.routeName,
                        arguments: CmsArgs(cmsType: CMSType.privacy));
                  },
                ),
                _widgetTile(
                  leadingIcon: ImgConstants.lock,
                  // sufixIcon: ImgConstants.forwardArrow,
                  sufixWidget: _widgetSecuritySwitch(),
                  child: Text(
                    AppConstants.security,
                    style: _appConfig!.linkNormalFontStyle
                        .apply(color: _appConfig!.whiteColor),
                  ),
                  onPress: () {},
                ),
                _widgetTile(
                  leadingIcon: ImgConstants.icSettings,
                  sufixIcon: ImgConstants.forwardArrow,
                  child: Row(
                    children: <Widget>[
                      Text(
                        AppConstants.regen,
                        style: _appConfig!.linkNormalFontStyle
                            .apply(color: _appConfig!.whiteColor),
                      ),
                      const Spacer(),
                      Text(
                        connectedDevice == null
                            ? AppConstants.notconnected
                            : AppConstants.connected,
                        style: connectedDevice == null
                            ? _appConfig!.calibriHeading4FontStyle
                                .apply(color: Colors.red)
                            : _appConfig!.calibriHeading4FontStyle
                                .apply(color: _appConfig!.btnPrimaryColor),
                      ),
                    ],
                  ),
                  onPress: () {
                    Navigator.pushNamed(context, DeviceConnection.routeName);
                  },
                ),
                _widgetTile(
                  leadingIcon: ImgConstants.support,
                  sufixIcon: ImgConstants.forwardArrow,
                  child: Text(
                    AppConstants.support,
                    style: _appConfig!.linkNormalFontStyle
                        .apply(color: _appConfig!.whiteColor),
                  ),
                  onPress: () async {
                    final Email email = Email(
                      body: '',
                      subject: '',
                      recipients: ['support@energym.io'],
                      // cc: ['cc@example.com'],
                      // bcc: ['bcc@example.com'],
                      // attachmentPaths: ['/path/to/attachment.zip'],
                      isHTML: false,
                    );

                    await FlutterEmailSender.send(email);
                  },
                ),
                _widgetTile(
                  leadingIcon: ImgConstants.delete,
                  sufixIcon: ImgConstants.forwardArrow,
                  child: Text(
                    AppConstants.deleteMyAccount,
                    style: _appConfig!.linkNormalFontStyle
                        .apply(color: _appConfig!.whiteColor),
                  ),
                  onPress: () {
                    const CustomAlertDialog().confirmationDialog(
                      title: AppConstants.deleletAccountQuestion,
                      message: AppConstants.deleteAccountMsg,
                      cancelButtonTitle: AppConstants.cancel,
                      okButtonTitle: AppConstants.deleteMyAccount,
                      context: context,
                      onSuccess: () async {
                        _settinngBloc!
                            .deleteUserAccount(context, _currentUser!);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          _widgetLogout(),
          _widgetNameLogo(),
          _widgetVersion(),
          _widgetCopyRight(),
        ],
      ),
    );
  }

  Widget _widgetSecuritySwitch() {
    return ValueListenableBuilder<bool>(
      valueListenable: _notifierNotification!,
      builder: (BuildContext? context, bool? isNotify, Widget? child) {
        return Container(
          padding: EdgeInsets.zero,
          height: 20,
          child: Platform.isAndroid
              ? Switch(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: isNotify!,
                  activeColor: _appConfig!.btnPrimaryColor,
                  onChanged: (bool value) async {
                    _notifierNotification!.value = value;
                    await sharedPrefsHelper.set(
                        SharedPrefskey.isSecurityEndable, value);
                  })
              : CupertinoSwitch(
                  activeColor: _appConfig!.btnPrimaryColor,
                  value: isNotify!,
                  onChanged: (bool value) async {
                    _notifierNotification!.value = value;
                    await sharedPrefsHelper.set(
                        SharedPrefskey.isSecurityEndable, value);

                    if (value) {
                      localAuth
                          .isDeviceSupported()
                          .then((bool isDeviceSupported) async {
                        if (isDeviceSupported) {
                          bool canCheckBiometrics =
                              await localAuth.canCheckBiometrics;
                          if (canCheckBiometrics) {
                            bool didAuthenticate = await localAuth.authenticate(
                                localizedReason:
                                    'Please authenticate to show access app',
                                useErrorDialogs: true,
                                stickyAuth: true);
                            if (didAuthenticate) {
                              // Success
                            } else {
                              _notifierNotification!.value = false;
                              await sharedPrefsHelper.set(
                                SharedPrefskey.isSecurityEndable,
                                value,
                              );
                            }
                          } else {
                            _notifierNotification!.value = false;
                            await sharedPrefsHelper.set(
                              SharedPrefskey.isSecurityEndable,
                              value,
                            );
                          }
                        } else {
                          // Device is not supported
                          _notifierNotification!.value = false;
                          await sharedPrefsHelper.set(
                            SharedPrefskey.isSecurityEndable,
                            value,
                          );
                        }
                      });
                    }
                  }),
        );
      },
    );
  }

  Widget _widgetTile(
      {String? leadingIcon,
      String? sufixIcon,
      Widget? sufixWidget,
      Widget? child,
      Function? onPress}) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(),
      visualDensity: const VisualDensity(vertical: -4),
      onTap: () {
        if (onPress != null) {
          onPress();
        }
      },
      title: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                  0, 16, sufixWidget != null ? 16 : 24, 16),
              child: Row(
                children: <Widget>[
                  if (leadingIcon != null) ...<Widget>[
                    SvgIcon.asset(
                      leadingIcon,
                      size: 18,
                      color: _appConfig!.whiteColor,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                  ],
                  if (child != null) Expanded(child: child),
                  if (sufixIcon != null) ...<Widget>[
                    const SizedBox(
                      width: 16,
                    ),
                    SvgIcon.asset(
                      sufixIcon,
                      size: 10,
                      color: _appConfig!.greyColor,
                    ),
                  ],
                  if (sufixWidget != null) ...<Widget>[
                    const SizedBox(
                      width: 16,
                    ),
                    sufixWidget,
                  ],
                ],
              ),
            ),
            Divider(
              color: _appConfig!.borderColor,
              thickness: 1,
              height: 1,
            )
          ],
        ),
      ),
    );
  }

  Widget _widgetLogout() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 71),
        child: TextButton(
          onPressed: () {
            const CustomAlertDialog().confirmationDialog(
              title: AppConstants.logout,
              message: AppConstants.loguoutMsg,
              cancelButtonTitle: AppConstants.cancel,
              okButtonTitle: AppConstants.logout,
              context: context,
              onSuccess: () async {
                aGeneralBloc.updateAPICalling(true);
                AuthProvider.instance.signOut(
                    context: context,
                    onSuccess: (Map<String, dynamic> succesResponse) {
                      aGeneralBloc.updateAPICalling(false);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Login.routeName,
                        ModalRoute.withName('/'),
                      );
                    },
                    onError: (Map<String, dynamic> errorResponse) {
                      aGeneralBloc.updateAPICalling(false);
                    });
              },
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SvgIcon.asset(ImgConstants.logout,
                  size: 24, color: _appConfig!.orangeColor),
              const SizedBox(
                width: 12,
              ),
              Text(
                AppConstants.logout,
                style: _appConfig!.calibriHeading4FontStyle.apply(
                  color: _appConfig!.orangeColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _widgetNameLogo() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 32, 16, 0),
      child: Image.asset(
        ImgConstants.nameLogo,
        width: double.infinity,
        height: 20,
      ),
    );
  }

  Future<String> getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = packageInfo.version;
    final String appBuild = packageInfo.buildNumber;
    final String fullVersion = '$appVersion($appBuild)';
    return fullVersion;
  }

  Widget _widgetVersion() {
    return FutureBuilder<String>(
      future: getAppVersion(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        String version = AppConstants.version;
        if (snapshot.hasData && snapshot.data != null) {
          version = '$version ${snapshot.data}';
        }
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
          child: Text(
            version,
            style: _appConfig!.labelSmallFontStyle.apply(
              color: _appConfig!.greyColor,
            ),
          ),
        );
      },
    );
  }

  Widget _widgetCopyRight() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
      child: Text(
        AppConstants.copyRight,
        textAlign: TextAlign.center,
        style:
            _appConfig!.labelSmallFontStyle.apply(color: _appConfig!.greyColor),
      ),
    );
  }

  Future<void> getJWT() async {
    String? jwt = await AuthProvider.instance.getJWTToken();
    print('jwt >>> $jwt');
  }

  Future<Map<String, dynamic>> getAPIData(String jwtToken) async {
    Map<String, dynamic> data = {};
    data[APIConstant.requestKeys.clientId] =
        AppKeyConstant.sweatCoinClientIdProduction;
    data[APIConstant.requestKeys.payload] = jwtToken;

    debugPrint("login data >>> $data");
    return data;
  }
}
