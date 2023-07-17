import 'dart:io';

import 'package:device_info/device_info.dart';

class DeviceInfo {
  final String? id;
  final String? os;
  final String? osVersion;
  final String? manufacturer;
  final String? make;
  final String? model;

  const DeviceInfo({
    this.id,
    this.os,
    this.osVersion,
    this.manufacturer,
    this.make,
    this.model,
  });

  static Future<DeviceInfo?> create() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return DeviceInfo(
        id: androidDeviceInfo.androidId,
        os: 'android',
        osVersion: androidDeviceInfo.version.release,
        manufacturer: androidDeviceInfo.manufacturer,
        make: androidDeviceInfo.brand,
        model: androidDeviceInfo.model,
      );
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;

      return DeviceInfo(
        id: iosDeviceInfo.identifierForVendor,
        os: 'ios',
        osVersion: iosDeviceInfo.systemVersion,
        manufacturer: null,
        make: null,
        model: iosDeviceInfo.model,
      );
    }

    return null;
  }

//        app_name: Alloy.Globals.appLongCodeName,
//        version: Ti.App.deployType === 'development' || Ti.App.deployType === 'test' ? '10000.0.0.0' : Ti.App.version,
//        device_id: Ti.Platform.id,
//        os: Ti.Platform.osname,
//        os_version: Ti.Platform.version,
//        name: Ti.Platform.name,
//        model: Ti.Platform.model,
}
