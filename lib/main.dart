import 'dart:async';
import 'dart:io';
import 'package:energym/bootstrap.dart';
import 'package:energym/reusable_component/shared_pref_helper.dart';
import 'package:energym/utils/common/config.dart';
import 'package:energym/utils/common/env.dart';
import 'package:energym/utils/helpers/routing/router.dart';
import 'package:energym/utils/theme/style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_audio_background/just_audio_background.dart';

class Helper {
  static final RouteObserver<ModalRoute> routeObserver =
      RouteObserver<ModalRoute>();
}

GetIt? serviceLocator = GetIt.instance; //Singletone helper //Register
Environment appEnv = Environment.dev;
void setupServiceLocator() {
  serviceLocator!
      .registerLazySingleton<SharedPrefsHelper>(() => SharedPrefsHelper());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  setupServiceLocator();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  if (Platform.isIOS) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );
  }

  Firebase.initializeApp().whenComplete(() {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    runApp(
      EasyLocalization(
        // ignore: prefer_const_literals_to_create_immutables
        supportedLocales: <Locale>[
          const Locale('en'),
        ],
        useOnlyLangCode: true,
        path: SizeConfig.localizationPath,
        child: Bootstrap(),
      ),
    );
    //   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    //     .then((_) {

    // });
  });
}

// final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    //setLocalNotification();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: EasyLocalization.of(context)!.supportedLocales,
      locale: EasyLocalization.of(context)!.locale,
      theme: darkTheme,
      initialRoute: Routers.initialRoute,
      onGenerateRoute: Routers.onGenerateRoute,
      navigatorObservers: [Helper.routeObserver],
      localizationsDelegates: [
        EasyLocalization.of(context)!.delegate,
      ],
      navigatorKey: kNavigatorKey,
      builder: (BuildContext? context, Widget? child) {
        print('MediaQuery = ${MediaQuery.of(context!).size}');
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
