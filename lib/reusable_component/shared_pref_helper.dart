import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import '../models/user_model.dart';

class SharedPrefskey {
  //Keys
  static final String isLoogedIn = "isLoogedIn";
  static final String deviceToken = "deviceToken";
  static final String userRole = "userRole";
  static final String userData = "userData";
  static final String currentStep = "currentStep";
  static final String? userId = "userId";
  static final String? loginuserId = "loginuserId";
  static final String isEmailEnabled = "isEmailEnabled";
  static final String isPushEnabled = "isPushEnabled";
  static final String isApprove = "isApprove";
  static final String isIntroDone = "isIntroDone";
  static final String token = "token";
  static final String generiacBloc = "generiacBloc";
  static final String generiacBlocAuthToken = "generiacBlocAuthToken";
  static final String applicantNextScreen = "applicantNextScreen";
  static final String employerNextScreen = "employerNextScreen";
  static final String streamClientId = "streamClientId";
  static final String streamClient = "streamClient";
  static final String supportEmail = "supportEmail";
  static final String isWalkThroughFinished = "isWalkThroughFinished";
  static final String fcmToken = "fcmToken";
  static final String isSecurityEndable = "isSecurityEndable";
  static final String? connectedDevice = "connectedDevice";
  static final String? isconnectedDevice = "isconnectedDevice";
}

class SharedPrefsHelper {
  //Keys
  final String isLoogedIn = 'isLoogedIn';
  final String appUDID = 'appUDID';
  final String deviceToken = 'deviceToken';
  static final String token = 'token';
  final IV iv = IV.fromLength(8);
  final Encrypter encrypter = Encrypter(Salsa20(Key.fromLength(32)));

  // For plain-text data
  Future<void> set(String key, dynamic value) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    if (value is bool) {
      sharedPreferences.setBool(key, value);
    } else if (value is String) {
      sharedPreferences.setString(key, value);
    } else if (value is double) {
      sharedPreferences.setDouble(key, value);
    } else if (value is int) {
      sharedPreferences.setInt(key, value);
    }
  }

  Future<void> setObject(String key, dynamic value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key, jsonEncode(value));
  }

  Future<UserModel?>? getUserInfo(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map<String, dynamic>? userMap = {};
    final String? userStr = sharedPreferences.getString(key)!;
    if (userStr != null) {
      userMap = jsonDecode(userStr) as Map<String, dynamic>;
    }

    if (userMap != null) {
      final UserModel user = UserModel.fromJson(userMap);
      //print(user);
      return user;
    }
    return null;
  }

  //Method for get from any key
  Future<dynamic> get(String key, {dynamic defaultValue}) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return await sharedPreferences.get(key) ?? defaultValue;
  }

  //Example for get string
  Future<String> getString() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return await sharedPreferences.get(deviceToken) as String;
  }

  //Example for get bool
  Future<bool> isLoggedIn() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return await sharedPreferences.get(isLoogedIn) as bool;
  }

  Future<void> setEncrypted(String key, String value) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString(key, encrypter.encrypt(value).base64);
  }

  Future<String?> getEncrypted(String key) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    Encrypted encrypted = sharedPreferences.get(key) as Encrypted;
    if (encrypted == null) return null;
    return encrypter.decrypt(encrypted, iv: iv);
  }

  Future<Encrypted> setQR(String qrCode) async {
    final key = Key.fromUtf8('H@McQfTjWnZr4u7x');
    final encrypter1 = Encrypter(AES(key, mode: AESMode.ecb));
    return encrypter1.encrypt(qrCode, iv: iv);
  }

  Future<String?> getQR(Encrypted encryptedQrCode) async {
    if (encryptedQrCode == null) return null;
    Encrypted encrypted = encryptedQrCode;
    final key = Key.fromUtf8('H@McQfTjWnZr4u7x');
    final encrypter1 = Encrypter(AES(key, mode: AESMode.ecb));
    return encrypter1.decrypt(encrypted, iv: iv);
  }

  Future<void> setUuid(String uuid) {
    return setEncrypted(appUDID, uuid);
  }

  Future<String?>? getUuid() {
    return getEncrypted(appUDID);
  }

  Future<void> setToken(String uuid) async {
    return setEncrypted(appUDID, uuid);
  }

  Future<String?>? getToken() async {
    return getEncrypted(appUDID);
  }

  Future<bool> removeKey(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
    ;
  }

  // For logging out
  Future<void> deleteAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(isLoogedIn);
    await prefs.remove(appUDID);
    await prefs.remove(deviceToken);
  }
}
