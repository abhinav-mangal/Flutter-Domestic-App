//import 'package:Monsify/utils/common/constants.dart';
import 'dart:async';

import 'package:energym/app_config.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_picture_customise.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/shared_pref_helper.dart';
import 'package:energym/models/sweatcoin_user_model.dart';

import '../../screens/dashboard/dashboard.dart';

BluetoothDevice? gdevice;

class GeneralBloc extends BaseBloc {
  final BehaviorSubject<bool> isLoggedIn = BehaviorSubject<bool>();
  final BehaviorSubject<String> authToken = BehaviorSubject<String>.seeded('');
  final BehaviorSubject<String> userId = BehaviorSubject<String>.seeded('');
  final BehaviorSubject<String> currLocal = BehaviorSubject<String>();
  final BehaviorSubject<bool> isApiCalling = BehaviorSubject<bool>();
  final BehaviorSubject<int> notificationCount = BehaviorSubject<int>();
  final BehaviorSubject<String> _workoutTime = BehaviorSubject<String>();
  ValueStream<bool> get getIsApiCalling => isApiCalling.stream;
  ValueStream<int> get getNotificationCount => notificationCount.stream;
  ValueStream<String> get getWorkoutTime => _workoutTime.stream;
  CommonNotifire commonNotifire = CommonNotifire();
  // final BehaviorSubject<List<BluetoothDevice?>?> _connectedBike =
  //     BehaviorSubject<List<BluetoothDevice?>?>();
  // ValueStream<List<BluetoothDevice?>?> get connectedBike => _connectedBike.stream;

  // final BehaviorSubject<SweatCoinUser> _sweatCoinUser =
  //     BehaviorSubject<SweatCoinUser>();
  // ValueStream<SweatCoinUser> get getSweatCoinUser => _sweatCoinUser.stream;

  int notificationBadgeCount = 0;
  UserModel? currentUser;
  Timer? _workOutTimer;
  List<BluetoothService> services = [];

  String? connectedBLE = '';

  String getAuthToken() {
    return authToken.valueWrapper?.value ?? '';
  }

  String getCurrLocal() {
    return currLocal.valueWrapper?.value ?? '';
  }

  void updateCurrentUser(UserModel user) {
    currentUser = user;
    sharedPrefsHelper.setObject(SharedPrefskey.userData, user.toJson());
  }

  Future<UserModel> getCurrentUser() async {
    UserModel? user =
        await sharedPrefsHelper.getUserInfo(SharedPrefskey.userData);
    return user!;
  }

  void updateLocalLanguage(String lang) {
    currLocal.sink.add(lang);
  }

  void updateAPICalling(bool value) {
    isApiCalling.sink.add(value);
  }

  String createjWTToken(Map<String, dynamic> data) {
    // Create a json web token
    final JWT jwt = JWT(
      data,
    );

// Sign it (default with HS256 algorithm)
    final String token = jwt.sign(
        SecretKey(AppKeyConstant.sweatCoinClientSecretStaging),
        noIssueAt: true);

    try {
      // Verify a token
      final jwt = JWT.verify(
          token, SecretKey(AppKeyConstant.sweatCoinClientSecretStaging));

      print('Payload: ${jwt.payload}');
    } on JWTExpiredError {
      print('jwt expired');
    } on JWTError catch (ex) {
      print(ex.message); // ex: invalid signature
    }

    print('Signed token: $token\n');
    return token;
  }

  Future<SweatCoinUser?>? getCurrentSweatCoinUser(
      APIProvider? api, BuildContext context) async {
    assert(api != null);

    return api!.getSweatCoinUser(context,
        onSuccess: (Response? response, Map<String, dynamic>? json) {
      final SweatCoinUserModel userModel = SweatCoinUserModel.fromJson(json!);
      SweatCoinUser? sweatCoinUser = userModel.data!.user;

      if (sweatCoinUser != null) {
        FireStoreProvider.instance
            .updateSweatCoinBalance(balance: sweatCoinUser.balance);
      }
      return sweatCoinUser!;
      //_sweatCoinUser.sink.add(userModel?.data?.user);
    }, onError: (Response? response, Map<String, dynamic>? jsonData) {
      //_sweatCoinUser.sink.add(null);
      // return null;
      return SweatCoinUser();
    });
  }

  Future<void> userSignOut() async {
    await sharedPrefsHelper.set(SharedPrefskey.isLoogedIn, false);
    await sharedPrefsHelper.removeKey(SharedPrefskey.userId!);
    await sharedPrefsHelper.removeKey(SharedPrefskey.currentStep);
    await sharedPrefsHelper.removeKey(SharedPrefskey.userData);
    bleDisconnected();

    FireStoreProvider.instance.sigOut();
  }

  Future<void> bleDisconnected() async {
    await sharedPrefsHelper.removeKey(SharedPrefskey.isconnectedDevice!);
    await sharedPrefsHelper.removeKey(SharedPrefskey.connectedDevice!);
    if (gdevice != null) {
      gdevice?.disconnect();
    }
    gdevice = null;
  }

  void updateWorkoutTimer(String timer) {
    _workoutTime.sink.add(timer);
  }

  @override
  void dispose() {
    isLoggedIn.close();
    authToken.close();
    userId.close();
    currLocal.close();
    isApiCalling.close();
    notificationCount.close();
    _workoutTime.close();
    // _connectedBike.close();
  }

  selectedBike(BluetoothDevice? connectedDevice) {
    if (connectedDevice == null) {
      gdevice = null;
      setConnectedDeviceID('');
    } else {
      gdevice = connectedDevice;
      setConnectedDeviceID(connectedDevice.id.id);
    }
  }

  BluetoothDevice? getSelectedBike() {
    return gdevice;
  }

  setConnectedDeviceID(String id) async {
    await sharedPrefsHelper.set(SharedPrefskey.connectedDevice!, id);
  }

  Future<String> getLoginUserId() async {
    String dt =
        await sharedPrefsHelper.get(SharedPrefskey.loginuserId!) as String;
    currentUserID = dt;
    return dt;
  }

  Future<void> getConnectedDevice() async {
    (await sharedPrefsHelper.get(SharedPrefskey.connectedDevice!) as String);
  }

  Future<bool> connectedDeviceFromApp() async {
    final bool connected =
        await sharedPrefsHelper.get(SharedPrefskey.isconnectedDevice!) as bool;
    // print('connected ${connected}');

    return connected;
  }

  saveConnectedDeviceUInPreference(BluetoothDevice? device) async {
    bool status = false;
    if (device != null) {
      status = true;
    }
    await sharedPrefsHelper.set(SharedPrefskey.isconnectedDevice!, status);
  }

  // connectedDeviceStream(BluetoothDevice? device) {
  //   _connectedBike.sink.add([device]);
  // }

  // Future<BluetoothDevice?> getConnectedBLEDevice(
  //     List<BluetoothDevice?>? device) async {
  //   BluetoothDevice? connectedDevice2 = null;
  //   print(device?.length);
  //   await Future.forEach(device!, (BluetoothDevice? connectedDeviceData) async {
  //     print('btnParing ${device.length}');
  //       print('Device ${connectedDeviceData?.state} - ${connectedDeviceData?.name} - ${connectedDeviceData?.id}');

  //     final String deviceFromAppConnect = await sharedPrefsHelper
  //         .get(SharedPrefskey.connectedDevice!) as String;

  //     if (deviceFromAppConnect == connectedDeviceData?.id.id) {
  //       connectedDevice2 = connectedDeviceData;
  //     }
  //   });
  //   return connectedDevice2;
  // }

}

class GeneralNotificationBloc extends BaseBloc {
  final BehaviorSubject<String> type = BehaviorSubject<String>.seeded('');
  final BehaviorSubject<String> name = BehaviorSubject<String>.seeded('');
  final BehaviorSubject<String> entityId = BehaviorSubject<String>();
  final BehaviorSubject<bool> isOpenFromNotification =
      BehaviorSubject<bool>.seeded(false);

  bool getIsOpenFromNotification() {
    return isOpenFromNotification.valueWrapper?.value ?? false;
  }

  String getPushType() {
    return type.valueWrapper?.value ?? '';
  }

  String getPushName() {
    return name.valueWrapper?.value ?? '';
  }

  String getPushEntityId() {
    return entityId.valueWrapper?.value ?? '';
  }

  void updateType(String? tagValue) {
    type.sink.add(tagValue!);
  }

  void updateEntity(String? nameValue) {
    entityId.sink.add(nameValue!);
  }

  void updateIsOpenFromNotification(bool? value) {
    isOpenFromNotification.sink.add(value!);
  }

  @override
  void dispose() {
    type.close();
    name.close();
    entityId.close();
    isOpenFromNotification.close();
  }
}

final GeneralBloc aGeneralBloc = GeneralBloc();

final GeneralNotificationBloc generalNotificationBloc =
    GeneralNotificationBloc();

abstract class BaseBloc {
  void dispose();
}
