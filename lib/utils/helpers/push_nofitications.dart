import 'dart:convert';
import 'dart:io';

import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/shared_pref_helper.dart';
import 'package:energym/screens/dashboard/dashboard.dart';
import 'package:energym/screens/feed/feed_details.dart';
import 'package:energym/screens/home/home.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/config.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/helpers/device_info.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  BuildContext? _context;

  Future<void> init(@required BuildContext context) async {
    if (!_initialized) {
      setLocalNotification();
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      fireBaseConfiq();

      _initialized = true;
      _context = context;
    }
  }

  void fireBaseConfiq() {
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _navigateToItemDetail(message.data, false);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
      final RemoteNotification? notification = message!.notification;
      final AndroidNotification? android = message.notification?.android;
      if (notification != null) {
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails('energym', 'energym Notification',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker');
        const IOSNotificationDetails iOSPlatformChannelSpecifics =
            IOSNotificationDetails();
        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(
                android: androidPlatformChannelSpecifics,
                iOS: iOSPlatformChannelSpecifics);

        String data = json.encode(message.data) as String;

        flutterLocalNotificationsPlugin.show(notification.hashCode,
            notification.title, notification.body, platformChannelSpecifics,
            payload: data);
        //audioCache.play(SoundConstants.peacock);
      }
      //_navigateToItemDetail(message.data);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _navigateToItemDetail(message.data, false);
    });

    _firebaseMessaging.getToken().then((String? token) async {
      assert(token != null);

      await sharedPrefsHelper.set(SharedPrefskey.fcmToken, token);
      _firebaseMessaging.subscribeToTopic('com.energym');

      DeviceInfo _deviceInfo =
          Provider.of<DeviceInfo>(_context!, listen: false);
      String deviceType = _deviceInfo.os!;

      FireStoreProvider.instance.saveDeviceToken(
        context: _context!,
        deviceType: deviceType,
        deviceToke: token!,
        isLogOut: false,
      );
    });
  }

  Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    //debugPrint('myBackgroundMessageHandler >>> $message');
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
      //debugPrint('==================Firebase Token${data}');
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
      //print('==================Firebase Token${notification}');
    }
    return Future<void>.value();
    // Or do other work.
  }

  Future<void> setLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: (int? id, String? title,
                String? body, String? payload) async {});

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.cancelAll();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        //debugPrint('notification payload: $payload');
        _navigateToItemDetail(
            json.decode(payload) as Map<String, dynamic>, true);
      }
    });
  }

  void _navigateToItemDetail(Map<String, dynamic> message, bool isAppOpen) {
    Map<String, dynamic> tag = {};
    String name = "";
    Map<String, dynamic> data = {};
    // print('tag androiddata>>> $message');
    if (Platform.isAndroid) {
      if (message != null &&
          message[NotificationConstants.notificationMoredata] != null) {
        String moreData =
            message[NotificationConstants.notificationMoredata] as String;

        Map<String, dynamic> valueMap =
            jsonDecode(moreData) as Map<String, dynamic>;
        redirectNotification(valueMap, isAppOpen);
      }
    } else {
      //debugPrint('ios tag >>> $message');
      if (message[NotificationConstants.notificationMoredata] is Map) {
        //debugPrint('ios Map >>>');
      } else if (message[NotificationConstants.notificationMoredata]
          is String) {
        //debugPrint('ios String >>>');
      } else {
        //debugPrint('ios other >>>');
      }
      if (message != null &&
          message[NotificationConstants.notificationMoredata] != null) {
        String moreData =
            message[NotificationConstants.notificationMoredata] as String;

        Map<String, dynamic> valueMap =
            jsonDecode(moreData) as Map<String, dynamic>;
        redirectNotification(valueMap, isAppOpen);
      }
    }
  }

  void redirectNotification(Map<String, dynamic> dataId, bool isAppOpen) {
    //print('redirectNotification >>> $dataId');
    String type = dataId[NotificaitonCollectionField.entityType] as String;
    String entityId = dataId[NotificaitonCollectionField.entityId] as String;

    if (type != null &&
        type.isNotEmpty &&
        entityId != null &&
        entityId.isNotEmpty) {
      UserModel _currentUser = aGeneralBloc.currentUser!;
      AppKeyConstant.fromWhere = AppKeyConstant.notificationRedirect;
      generalNotificationBloc.updateType(type);
      generalNotificationBloc.updateEntity(entityId);
      generalNotificationBloc.updateIsOpenFromNotification(true);

      if (_currentUser != null) {
        Navigator.pushNamedAndRemoveUntil(kNavigatorKey.currentContext!,
            Home.routeName, ModalRoute.withName('/'));
      }
      /*if (isAppOpen) {
        switch (type) {
          case NotificationType.likePost:
            Navigator.pushNamed(
              kNavigatorKey.currentContext,
              FeedDetails.routeName,
              arguments: FeedDetailsArgs(feedId: entityId),
            );
            break;
          case NotificationType.commentPost:
            Navigator.pushNamed(
              kNavigatorKey.currentContext,
              FeedDetails.routeName,
              arguments: FeedDetailsArgs(feedId: entityId),
            );
            break;

          default:
            break;
        }
      } else {
        
      }*/
    }
  }
}

// DEFINE THIS BELOW METHOD OUTSIDE THE CLASS BCZ OF
// https://stackoverflow.com/questions/67519370/flutter-fcm-onbackgroundmessage-handler-gives-null-check-error
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('energym', 'energym Notification',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails();
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_notification');

  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          onDidReceiveLocalNotification:
              (int? id, String? title, String? body, String? payload) async {});

  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      //debugPrint('notification payload: $payload');
    }
  });

  // flutterLocalNotificationsPlugin.show(
  //     message.hashCode,
  //     'New message received',
  //     message.data['message'] as String,
  //     platformChannelSpecifics);
}
