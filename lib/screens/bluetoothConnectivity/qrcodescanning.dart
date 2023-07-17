import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../app_config.dart';
import '../../models/user_model.dart';
import '../../reusable_component/custom_dialog.dart';
import '../../reusable_component/custom_scaffold.dart';
import '../../reusable_component/main_app_bar.dart';
import '../../reusable_component/shared_pref_helper.dart';
import '../../utils/common/base_bloc.dart';
import '../../utils/common/common_widget.dart';
import '../../utils/common/constants.dart';
import '../../utils/helpers/api_provider.dart';
import '../../utils/helpers/firebase/firestore_provider.dart';
import '../../utils/theme/colors.dart';
import 'bluetoothbloc.dart';

// This screen to scan REGEN Qr code
class QRCodeScanningVC extends StatefulWidget {
  @override
  _QRCodeScanningVCState createState() => _QRCodeScanningVCState();
}

class _QRCodeScanningVCState extends State<QRCodeScanningVC> {
  UserModel? _currentUser;
  AppConfig? _config;
  APIProvider? _api;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final BluetoothBloc _blocBluetooth = BluetoothBloc();

  @override
  void initState() {
    super.initState();
    _api = APIProvider.of(context);

    aGeneralBloc.selectedBike(null);
    aGeneralBloc.saveConnectedDeviceUInPreference(null);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return StreamBuilder<DocumentSnapshot?>(
      stream: FireStoreProvider.instance.getCurrentUserUpdate,
      builder:
          // ignore: always_specify_types
          (BuildContext context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          _currentUser = UserModel.fromJson(
              snapshot.data!.data() as Map<String, dynamic>,
              doumentId: snapshot.data!.id);
          aGeneralBloc.updateCurrentUser(_currentUser!);
        }

        return CustomScaffold(
          resizeToAvoidBottomInset: false,
          appBar: _getAppBar(),
          body: Container(
            color: Colors.transparent,
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 15),
                  height: 50,
                  child: Text(
                    "Find your bike",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: _config!.fontFamilyAntonio,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 15),
                  height: 50,
                  child: Text(
                    "Scan QR code",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: _config!.fontFamilyAntonio,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
                StreamBuilder<List<BluetoothDevice?>?>(
                    stream: Stream.periodic(const Duration(seconds: 2))
                        .asyncMap((_) => flutterInstance.connectedDevices),
                    builder: (c, snapshot) {
                      if (snapshot.data?.length == 0) {
                        return Expanded(
                            child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20)),
                            height: MediaQuery.of(context).size.width / 1.5,
                            width: MediaQuery.of(context).size.width / 1.5,
                            child: _buildQrView(context),
                          ),
                        ));
                      }
                      BluetoothDevice? bleDevice =
                          snapshot.hasData ? snapshot.data?.last! : null;

                      return StreamBuilder<Object>(
                          stream: bleDevice?.state,
                          builder: (context, snapshot) {
                            switch (snapshot.data) {
                              case BluetoothDeviceState.connected:
                                _blocBluetooth.discoversErvices(
                                  bleDevice!,
                                  context,
                                );
                                Navigator.pop(context);

                                break;
                            }
                            return Expanded(
                                child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20)),
                                height: MediaQuery.of(context).size.width / 1.5,
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: _buildQrView(context),
                              ),
                            ));
                          });
                    }),
                Container(
                  padding: EdgeInsets.only(top: 15, bottom: 30),
                  // height: 50,
                  child: Text(
                    "Choose the bike model \nyou are connecting to",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: _config!.fontFamilyAntonio,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = MediaQuery.of(context).size.width / 2;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: AppColors.greenColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) async {
      pauseCamera(controller);
      print("result = ${scanData.code}");
      //  Encrypted encrypted = await SharedPrefsHelper().setQR(scanData.code!);
      final String? qrDeCode =
          await SharedPrefsHelper().getQR(Encrypted.from64(scanData.code!));

      permission(qrDeCode ?? '', controller);
    });
  }

  // Pause camera after scanning QR
  pauseCamera(QRViewController controller) async {
    await controller.pauseCamera();
  }

  // Resuming QR scanning
  resumeCamera(QRViewController controller) async {
    await controller.resumeCamera();
  }

  // Check Bluetooth permission
  permission(String code, QRViewController controller) async {
    bool isAvailableDevice = false;
    var status = await Permission.bluetooth.request();
    if (status.isGranted) {
      // Scanning BLEs
      try {
        await flutterInstance
            .startScan(timeout: Duration(seconds: 1))
            .then((value) async {
          final List<ScanResult> devices = value as List<ScanResult>;
          if (devices.isNotEmpty) {
            List<ScanResult> deviceResult = devices
                .where((device) =>
                    device.device.id.toString().toLowerCase() ==
                    code.toLowerCase())
                .toList();
            if (deviceResult.isNotEmpty) {
              flutterInstance.stopScan();

              final device = deviceResult[0];

              if (_blocBluetooth.isCellDisplay(device)) {
                if (device.advertisementData.connectable) {
                  try {
                    await device.device.connect(autoConnect: false);
                  } catch (error) {
                    print(error);
                  }
                }
              }
            } else {
              CustomAlertDialog().showAlert(
                  context: context,
                  message: AppConstants.bleDevice,
                  title: AppConstants.appName,
                  onSuccess: () {
                    resumeCamera(controller);
                  });
            }
          } else {
            flutterInstance.stopScan();
          }
        });
      } catch (error) {
        print(error);
      }
    } else {
      openAppSettings();
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      openAppSettings();
    }
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _config!,
        backgoundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        isBackEnable: true,
        widget: btnPairing(context, (isConnectedDevice) {
          if (isConnectedDevice) {
            // pop up
            bottomSheet(context);
          }
        }),
        //gradient: AppColors.gradintBtnSignUp,
        onBack: () {
      Navigator.pop(context);
    }, actions: <Widget>[
      btnSweatCointBalance(context, _config!),
    ]);
  }
}
