import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/user_model.dart';
import '../../utils/common/base_bloc.dart';
import '../../utils/common/constants.dart';
import '../../utils/helpers/firebase/firestore_provider.dart';

//
String kStrFitness = '1826';
String kStrHeartRate = '180D';

// Bluetooth bloc added all ble related business logic
class BluetoothBloc {
  final BehaviorSubject<bool> _btnTapped = BehaviorSubject<bool>.seeded(false);
  ValueStream<bool> get btnTapped => _btnTapped.stream;

  final BehaviorSubject<int> _intSelection = BehaviorSubject<int>.seeded(-1);
  ValueStream<int> get intSelection => _intSelection.stream;

  final BehaviorSubject<int> _intChartSelection =
      BehaviorSubject<int>.seeded(0);
  ValueStream<int> get intChartSelection => _intChartSelection.stream;

  final BehaviorSubject<BluetoothCharacteristic?> _streamCharValue =
      BehaviorSubject<BluetoothCharacteristic?>();
  ValueStream<BluetoothCharacteristic?> get streamCharValue =>
      _streamCharValue.stream;

  BluetoothCharacteristic? bleCharacteristic;
  BluetoothCharacteristic? bleReadCharacteristic;

  late List<int> lastValue;

  // fitness service UUID
  final String strFitnessService_UUID = "00001826-0000-1000-8000-00805f9b34fb";

  // Fitness service characteristics UUID
  final String strCharacteritcs_UUID = "00002ad2-0000-1000-8000-00805f9b34fb";

  // Write value characteristics UUID
  final String strReadCharacteritcs_UUID =
      "00002ad9-0000-1000-8000-00805f9b34fb";

  @override
  void dispose() {
    // _arrList.close();
    _intSelection.close();
    _streamCharValue.sink.add(null);
    bleCharacteristic = null;
    _streamCharValue.close();
    _streamCharValue.drain();
    bleCharacteristic?.setNotifyValue(false);
    _intChartSelection.close();
  }

  // Check count for REGEN BLE
  Future<int> checkCountForREGRN(List<ScanResult> devices) async {
    int count = 0;
    for (ScanResult device in devices) {
      if (isCellDisplay(device)) {
        count++;
      }
    }
    return count;
  }

  // Check condition to byfurget BLE
  bool isCellDisplay(ScanResult device) {
    if (Platform.isAndroid) {
      bool isFitness = device.advertisementData.serviceUuids
          .contains(strFitnessService_UUID);
      if (isFitness) {
        // 0x1826 Fitness Machine
        return true;
      }
    } else {
      bool isFitness =
          device.advertisementData.serviceUuids.contains(kStrFitness);
      if (isFitness) {
        // 0x1826 Fitness Machine
        return true;
      }
    }
    return false;
  }

  cellSelection(int index) {
    _intSelection.sink.add(index);
  }

  connectedDevice(ScanResult device) {
    // print(device.device.state.last.toString());
  }

  // When connect BLE device with app
  bleConnectButtonTapped(bool status) {
    _btnTapped.sink.add(status);
  }

  // Descover services after connected device
  discoverServices(
      BluetoothDevice connectedDevice, BuildContext context) async {
    aGeneralBloc.services = await connectedDevice.discoverServices();
    print(aGeneralBloc.services);
    aGeneralBloc.connectedBLE = connectedDevice.id.id;
    Navigator.pop(context);
  }

  // Get characterisctics
  discoverCharacteristics(BluetoothDevice connectedDevice) async {
    print(aGeneralBloc.services.length);
    print(aGeneralBloc.services);
    aGeneralBloc.services.forEach((service) {
      if (service.uuid.toString() == strFitnessService_UUID) {
        // fitness service characteristics
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == strCharacteritcs_UUID) {
            bleCharacteristic = characteristic;
            _streamCharValue.sink.add(bleCharacteristic);
            // print('bleCharacteristic ${bleCharacteristic}');
            bleCharacteristic?.setNotifyValue(true);
            bleCharacteristic?.read();

            lastValue = bleCharacteristic!.lastValue;
          } else if (characteristic.uuid.toString() ==
              strReadCharacteritcs_UUID) {
            // Writing characteristics
            bleReadCharacteristic = characteristic;
            bleReadCharacteristic?.setNotifyValue(true);
            bleReadCharacteristic?.value.listen((value) {
              print('listen after write value2 ${value}');
            });
          }
        });
      }
    });
  }

  // Parcing data to display on UI from list of datas
  List<int> dataParserAndCalculation(List<int> data) {
    if (data.length == 15) {
      return [0, 0, 0, 0, 0];
    }
    // 0 index for cadence
    // 1 index for resistence
    // 2 index for watts
    // 3 index for Av. watts
    // 4 index for calories

    List<String>? arrTempHexa = [];
    List<int>? arrActualValues = [];
    data.asMap().forEach((index, value) {
      var hexaValue = "${(value.toRadixString(16)).padLeft(2, '0')}";
      arrTempHexa.add(hexaValue);

      switch (index) {
        case 1:
          // Flag
          final flag =
              int.parse('${arrTempHexa[1]}${arrTempHexa[0]}', radix: 16)
                  .toRadixString(2);
          break;
        case 7:
          // Cadence
          final instCadence =
              (int.parse('${arrTempHexa[7]}${arrTempHexa[6]}', radix: 16) / 2)
                  .toInt();
          arrActualValues.add(instCadence);
          break;
        case 14:
          // Resistance
          final instResis =
              int.parse('${arrTempHexa[14]}${arrTempHexa[13]}', radix: 16);
          arrActualValues.add(instResis);
          break;
        case 16:
          // Inst. Power / Watts
          final instPower =
              int.parse('${arrTempHexa[16]}${arrTempHexa[15]}', radix: 16);
          arrActualValues.add(instPower);
          break;
        case 18:
          // Avg. power / Avg. Watts
          final avWatts =
              int.parse('${arrTempHexa[18]}${arrTempHexa[17]}', radix: 16);
          arrActualValues.add(avWatts);
          break;
        case 20:
          // Calories / Energy
          final instEnergy =
              int.parse('${arrTempHexa[20]}${arrTempHexa[19]}', radix: 16);
          arrActualValues.add(instEnergy);
          break;
        default:
      }
    });

    var joinedstr = arrTempHexa.join("-");
    print(joinedstr);
    return arrActualValues.length > 0 ? arrActualValues : [0, 0, 0, 0, 0];
  }

  chartSelection(int index) {
    _intChartSelection.sink.add(index);
  }

  // Sweatcoin generate logic
  double generateSweatCoin(int avWatts, double mins, int ftp) {
    var x = 1.1;
    var y = 1.2;
    var K = 100;
    var S = 1000;

    // Formula provided by Wills team
    // 𝒕𝒊𝒎𝒆_𝒂𝒅𝒋𝒖𝒔𝒕= 𝟏+(𝑪−𝒙 𝒍𝒏(𝑭𝑻𝑷𝟐𝟎))
    final logValue = log(ftp);
    final timeAdjust = 1 + (0.8733 - 0.285 * logValue);

    // Formula provided by Wills team
    // 𝑲∗(𝑨𝑽𝑮_𝒘𝒂𝒕𝒕𝒔𝑭𝑻𝑷𝟐𝟎∗𝒕𝒊𝒎𝒆_𝒂𝒅𝒋𝒖𝒔𝒕)𝒚∗𝒅𝒖𝒓𝒂𝒕𝒊𝒐𝒏_𝒎𝒊𝒏𝒔 𝒙𝑺=𝒄𝒐𝒊𝒏𝒔 𝒂𝒘𝒂𝒓𝒅𝒆𝒅
    final coinRewarded =
        (K * (pow(avWatts / (100 / timeAdjust), 1.2)) * pow(mins, x)) / S;

    return double.parse(coinRewarded.toStringAsFixed(2));
  }

  // Write Resistance data in to ESP chip
  writeData(BuildContext context, int oPCode, int value) async {
    try {
      await bleReadCharacteristic!.write(
        [oPCode, value],
        withoutResponse: false,
      );
    } catch (error) {
      print(error);
    }
  }

  discoversErvices(BluetoothDevice bleDevice, BuildContext context) async {
    await discoverServices(bleDevice, context);
    if (Platform.isAndroid) {
      bleDevice.requestMtu(30);
    }
  }

  Map<String, dynamic> checkLevel(int totelCalories, UserModel currentUser) {
    print(currentUser);
    Map<String, dynamic> _neetToStoreData = {};

    // On Level 1 , need to generate energy 0.5kWh and completed 1 workout
    // then user will be jump to Level 2
    if (currentUser.level == 1 &&
        currentUser.workoutCountInLevel == 0 &&
        currentUser.generatedenergy == 0) {
      _neetToStoreData[UserCollectionField.level] = 2;
      _neetToStoreData[UserCollectionField.videoName] =
          LevelVideoName.levelVideoName2;
      _neetToStoreData[UserCollectionField.levelName] =
          LevelLevelName.levelLevelName2;
      _neetToStoreData[UserCollectionField.generatedenergy] = 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] = 0;
    }

    // On Level 2 , need to generate energy 1kWh and completed 3 workout
    //then user will be jump to Level 3
    if (currentUser.level == 2 &&
        (currentUser.workoutCountInLevel! >= 0 &&
            currentUser.workoutCountInLevel! <= 2) &&
        currentUser.generatedenergy! >= 0) {
      _neetToStoreData[UserCollectionField.generatedenergy] =
          currentUser.generatedenergy! + 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] =
          currentUser.workoutCountInLevel! + 1;
    } else {
      _neetToStoreData[UserCollectionField.level] = 3;
      _neetToStoreData[UserCollectionField.videoName] =
          LevelVideoName.levelVideoName3;
      _neetToStoreData[UserCollectionField.levelName] =
          LevelLevelName.levelLevelName3;
      _neetToStoreData[UserCollectionField.generatedenergy] = 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] = 0;
    }

    // On Level 3, need to generate energy 1.5kWh and completed 3 workout
    //then user will be jump to Level 4
    if (currentUser.level == 3 &&
        (currentUser.workoutCountInLevel! >= 0 &&
            currentUser.workoutCountInLevel! <= 2) &&
        currentUser.generatedenergy! >= 0) {
      _neetToStoreData[UserCollectionField.generatedenergy] =
          currentUser.generatedenergy! + 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] =
          currentUser.workoutCountInLevel! + 1;
    } else {
      _neetToStoreData[UserCollectionField.level] = 4;
      _neetToStoreData[UserCollectionField.videoName] =
          LevelVideoName.levelVideoName4;
      _neetToStoreData[UserCollectionField.levelName] =
          LevelLevelName.levelLevelName4;
      _neetToStoreData[UserCollectionField.generatedenergy] = 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] = 0;
    }

    // On Level 4, need to generate energy 2kWh and completed 4 workout
    //then user will be jump to Level 5
    if (currentUser.level == 4 &&
        (currentUser.workoutCountInLevel! >= 0 &&
            currentUser.workoutCountInLevel! <= 3) &&
        currentUser.generatedenergy! >= 0) {
      _neetToStoreData[UserCollectionField.generatedenergy] =
          currentUser.generatedenergy! + 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] =
          currentUser.workoutCountInLevel! + 1;
    } else {
      _neetToStoreData[UserCollectionField.level] = 5;
      _neetToStoreData[UserCollectionField.videoName] =
          LevelVideoName.levelVideoName5;
      _neetToStoreData[UserCollectionField.levelName] =
          LevelLevelName.levelLevelName5;
      _neetToStoreData[UserCollectionField.generatedenergy] = 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] = 0;
    }

    // On Level 5, need to generate energy 2.5kWh and completed 4 workout
    //then user will be jump to Level 6
    if (currentUser.level == 5 &&
        (currentUser.workoutCountInLevel! >= 0 &&
            currentUser.workoutCountInLevel! <= 3) &&
        currentUser.generatedenergy! >= 0) {
      _neetToStoreData[UserCollectionField.generatedenergy] =
          currentUser.generatedenergy! + 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] =
          currentUser.workoutCountInLevel! + 1;
    } else {
      _neetToStoreData[UserCollectionField.level] = 6;
      _neetToStoreData[UserCollectionField.videoName] =
          LevelVideoName.levelVideoName6;
      _neetToStoreData[UserCollectionField.levelName] =
          LevelLevelName.levelLevelName6;
      _neetToStoreData[UserCollectionField.generatedenergy] = 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] = 0;
    }

    // On Level 6, need to generate energy 3kWh and completed 4 workout
    //then user will be jump to Level 7
    if (currentUser.level == 6 &&
        (currentUser.workoutCountInLevel! >= 0 &&
            currentUser.workoutCountInLevel! <= 3) &&
        currentUser.generatedenergy! >= 0) {
      _neetToStoreData[UserCollectionField.generatedenergy] =
          currentUser.generatedenergy! + 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] =
          currentUser.workoutCountInLevel! + 1;
    } else {
      _neetToStoreData[UserCollectionField.level] = 7;
      _neetToStoreData[UserCollectionField.videoName] =
          LevelVideoName.levelVideoName7;
      _neetToStoreData[UserCollectionField.levelName] =
          LevelLevelName.levelLevelName7;
      _neetToStoreData[UserCollectionField.generatedenergy] = 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] = 0;
    }

    // On Level 7, need to generate energy 3.5kWh and completed 4 workout
    //then user will be jump to Level 8
    if (currentUser.level == 7 &&
        (currentUser.workoutCountInLevel! >= 0 &&
            currentUser.workoutCountInLevel! <= 3) &&
        currentUser.generatedenergy! >= 0) {
      _neetToStoreData[UserCollectionField.generatedenergy] =
          currentUser.generatedenergy! + 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] =
          currentUser.workoutCountInLevel! + 1;
    } else {
      _neetToStoreData[UserCollectionField.level] = 8;
      _neetToStoreData[UserCollectionField.videoName] =
          LevelVideoName.levelVideoName8;
      _neetToStoreData[UserCollectionField.levelName] =
          LevelLevelName.levelLevelName8;
      _neetToStoreData[UserCollectionField.generatedenergy] = 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] = 0;
    }

    // On Level 8, need to generate energy 4kWh and completed 4 workout
    //then user will be jump to Level 9
    if (currentUser.level == 8 &&
        (currentUser.workoutCountInLevel! >= 0 &&
            currentUser.workoutCountInLevel! <= 3) &&
        currentUser.generatedenergy! >= 0) {
      _neetToStoreData[UserCollectionField.generatedenergy] =
          currentUser.generatedenergy! + 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] =
          currentUser.workoutCountInLevel! + 1;
    } else {
      _neetToStoreData[UserCollectionField.level] = 9;
      _neetToStoreData[UserCollectionField.videoName] =
          LevelVideoName.levelVideoName9;
      _neetToStoreData[UserCollectionField.levelName] =
          LevelLevelName.levelLevelName9;
      _neetToStoreData[UserCollectionField.generatedenergy] = 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] = 0;
    }

    // On Level 79, need to generate energy 4kWh and completed 4 workout
    // then user will be jump to Level 10
    if (currentUser.level == 8 &&
        (currentUser.workoutCountInLevel! >= 0 &&
            currentUser.workoutCountInLevel! <= 3) &&
        currentUser.generatedenergy! >= 0) {
      _neetToStoreData[UserCollectionField.generatedenergy] =
          currentUser.generatedenergy! + 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] =
          currentUser.workoutCountInLevel! + 1;
    } else {
      _neetToStoreData[UserCollectionField.level] = 10;
      _neetToStoreData[UserCollectionField.videoName] =
          LevelVideoName.levelVideoName10;
      _neetToStoreData[UserCollectionField.levelName] =
          LevelLevelName.levelLevelName10;
      _neetToStoreData[UserCollectionField.generatedenergy] = 0;
      _neetToStoreData[UserCollectionField.workoutCountInLevel] = 0;
    }

    return _neetToStoreData;
  }
}
