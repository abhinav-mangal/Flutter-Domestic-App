import 'package:energym/app_config.dart';
import 'package:energym/screens/splash.dart/splash.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:energym/utils/helpers/device_info.dart';
import 'package:energym/utils/helpers/internet_connection.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'utils/common/constants.dart';
import 'utils/common/env.dart';

class Bootstrap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppConfig>(
          create: (_) => _getConfig(appEnv),
        ),
        ChangeNotifierProvider<InternetConnection>(
          create: (_) => InternetConnection(),
        ),
      ],
      //child: MyApp(),
      child: FutureBuilder<dynamic>(
        future: Future.wait([
          _getPackageInfo(),
          _getDeviceInfo(),
          _getSharedPreferences(),
        ]),
        builder: (context, snapshot) {
          final AppConfig config = AppConfig.of(context);
          if (snapshot.hasData) {
            final PackageInfo packageInfo = snapshot.data![0] as PackageInfo;
            final DeviceInfo deviceInfo = snapshot.data![1] as DeviceInfo;
            final SharedPreferences sharedPreferences =
                snapshot.data![2] as SharedPreferences;

            return MultiProvider(
              providers: [
                Provider.value(value: packageInfo),
                Provider.value(value: deviceInfo),
                Provider.value(value: sharedPreferences),
                _apiProvider(),
              ],
              child: MyApp(),
              
            );
          } else {
            //return _splashScreen(config);
            return SizedBox();
          }
        },
      ),
    );
  }

 

  Future<PackageInfo> _getPackageInfo() async {
    Stopwatch stopwatch = Stopwatch()..start();
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }

  Future<DeviceInfo?> _getDeviceInfo() async {
    Stopwatch stopwatch = Stopwatch()..start();
    final deviceInfo = await DeviceInfo.create();
    return deviceInfo;
  }

  Future<SharedPreferences> _getSharedPreferences() async {
    Stopwatch stopwatch = Stopwatch()..start();
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences;
  }

  InheritedProvider _apiProvider({Widget? child}) {
    return ProxyProvider<InternetConnection,
        APIProvider>(
      update: (
        context,
        internetConnection,
        api,
      ) {
        print('api >>>> $api');
        if (api == null) {
          return APIProvider(
            internetConnection: internetConnection,
          );
        }
        return api;
      },
      dispose: (context, api) {
        api.dispose();
      },
      //child: const SizedBox(),
    );
  }

  Widget _splashScreen(AppConfig config) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: config.windowBackground,
    );
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

  AppConfig _getConfig(Environment environment) {
    EnvironmentService environmentService = EnvironmentService(environment);

    return AppConfig(
        fireStoreDB: environmentService.getValue(
          dev: 'energym_dev',
          staging: 'energym_staging',
          prod: 'energym_poduction',
        ),
        brightness: Brightness.dark,
        defaultThemeData: AppThemeData(
          accentColor: Color(0xff314b39),
          textAccentColor: Color(0xff314b39),
          accentBrightness: Brightness.dark,
          primaryButtonColor: Color(0xff314b39),
        ),
        lightThemeData: AppThemeData(
          accentColor: Color(0xff314b39),
          textAccentColor: Color(0xff314b39),
          accentBrightness: Brightness.light,
          primaryButtonColor: Color(0xff314b39),
        ),
        darkThemeData: AppThemeData(
          accentColor: Color(0xff314b39),
          textAccentColor: Color(0xff314b39),
          accentBrightness: Brightness.dark,
          primaryButtonColor: Color(0xff314b39),
        ));
  }
}
