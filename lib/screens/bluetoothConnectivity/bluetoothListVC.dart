import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

import '../../app_config.dart';
import '../../models/user_model.dart';
import '../../reusable_component/custom_dialog.dart';
import '../../reusable_component/custom_scaffold.dart';
import '../../reusable_component/loader_button.dart';
import '../../reusable_component/main_app_bar.dart';
import '../../utils/common/base_bloc.dart';
import '../../utils/common/common_widget.dart';
import '../../utils/common/constants.dart';
import '../../utils/helpers/api_provider.dart';
import '../../utils/helpers/firebase/firestore_provider.dart';
import '../../utils/theme/colors.dart';
import 'bluetoothbloc.dart';

// This screen having Bluetooth device list which will display
// after scanning near by devices
class BlueToothListVC extends StatefulWidget {
  @override
  _BlueToothListVCState createState() => _BlueToothListVCState();
}

class _BlueToothListVCState extends State<BlueToothListVC> {
  UserModel? _currentUser;
  AppConfig? _config;
  APIProvider? _api;

  final BluetoothBloc _blocBluetooth = BluetoothBloc();
  List<ScanResult>? resultDevice = [];
  ValueNotifier<int> _notifierBLECount = ValueNotifier<int>(0);
  ValueNotifier<String> _testing = ValueNotifier<String>('');

  bool isCalledServices = false;

  @override
  void initState() {
    super.initState();
    _api = APIProvider.of(context);

    // Set default data
    aGeneralBloc.selectedBike(null);
    aGeneralBloc.saveConnectedDeviceUInPreference(null);

    // Permission for Bluetooth
    permission();
  }

  // Check bluetooth permission
  permission() async {
    final status = await Permission.bluetoothScan.request();
    final status1 = await Permission.bluetooth.request();
    final status2 = await Permission.bluetoothConnect.request();
    final status3 = await Permission.bluetoothAdvertise.request();

    if (Platform.isIOS) {
      if (status1.isGranted) {
        // Scanning BLEs
        flutterInstance.startScan();
      } else {
        openAppSettings();
      }
    } else if (Platform.isAndroid) {
      if (status.isGranted &&
          status1.isGranted &&
          status2.isGranted &&
          status3.isGranted) {
        // Scanning BLEs
        flutterInstance.startScan();
      } else {
        openAppSettings();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    flutterInstance.stopScan();
    _notifierBLECount.dispose();
    _blocBluetooth.dispose();
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
          //aGeneralBloc.getCurrentSweatCoinUser(_api, context);
        }

        return CustomScaffold(
          resizeToAvoidBottomInset: false,
          appBar: _getAppBar(),
          body: Stack(
            children: [
              StreamBuilder<List<BluetoothDevice?>?>(
                stream: Stream.periodic(const Duration(seconds: 1))
                    .asyncMap((_) => flutterInstance.connectedDevices),
                builder: (c, snapshot) {
                  if (snapshot.hasData && snapshot.data!.length > 0) {
                    String state = '';
                    BluetoothDevice? bleDevice =
                        snapshot.data!.length > 0 ? snapshot.data?.last! : null;
                    // print('btn pariing List ${bleDevice}');
                    return StreamBuilder<BluetoothDeviceState>(
                      stream: bleDevice?.state,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          switch (snapshot.data) {
                            case BluetoothDeviceState.connected:
                              if (!isCalledServices) {
                                isCalledServices = true;

                                _blocBluetooth.discoversErvices(
                                    bleDevice!, context);
                              }

                              break;
                            default:
                              state = '';
                          }
                        }

                        return SizedBox();
                      },
                    );
                  }
                  return SizedBox();
                },
              ),

              _listBLE(),

              // Scanning
              _scanningUI()
            ],
          ),
        );
      },
    );
  }

  Widget _listBLE() {
    return StreamBuilder<List<ScanResult>>(
        stream: FlutterBlue.instance.scanResults,
        builder: (context, snapshot) {
          resultDevice = snapshot.hasData ? snapshot.data : [];
          print(resultDevice);
          bleCount(resultDevice!);
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 15),
              ValueListenableBuilder(
                  valueListenable: _notifierBLECount,
                  builder: (context, value, child) {
                    return Text(
                      "${value} ${AppConstants.regenfound}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: _config!.fontFamilyAntonio,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                          color: Colors.white),
                    );
                  }),
              SizedBox(height: 15),
              Text(
                AppConstants.selectRide,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: _config!.fontFamilyAntonio,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.grey),
              ),
              SizedBox(height: 5),
              Expanded(
                  child: ListView.builder(
                      itemCount: resultDevice?.length ?? 0,
                      itemBuilder: (context, index) {
                        ScanResult? device = resultDevice?[index];

                        if (_blocBluetooth.isCellDisplay(device!)) {
                          return StreamBuilder<int>(
                              stream: _blocBluetooth.intSelection,
                              builder: (context, snapshot) {
                                return GestureDetector(
                                  onTap: () {
                                    _blocBluetooth.cellSelection(index);
                                  },
                                  child: Container(
                                    height: 130,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent),
                                    child: Stack(children: [
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: AppColors.greenColor,
                                                    width: 3),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(14))),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    width: 80,
                                                    child: Container(
                                                        color: Colors
                                                            .transparent)),
                                                Expanded(
                                                    child: Center(
                                                        child: Container(
                                                  color: Colors.transparent,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          '${(device.device.name.isNotEmpty) ? device.device.name : 'NA'}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontFamily: _config!
                                                                  .fontFamilyAntonio,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 20,
                                                              color:
                                                                  Colors.white),
                                                          textAlign:
                                                              TextAlign.start),
                                                      SizedBox(height: 5),
                                                      Text(
                                                          '${device.device.id}',
                                                          style: TextStyle(
                                                              fontFamily: _config!
                                                                  .fontFamilyAntonio,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.grey),
                                                          textAlign:
                                                              TextAlign.start)
                                                    ],
                                                  ),
                                                ))),
                                                // snapshot.data == index
                                                //     ? Center(
                                                //         child: IconButton(
                                                //           icon: Image.asset(
                                                //               ImgConstants
                                                //                   .tickmarkbike,
                                                //               fit:
                                                //                   BoxFit.cover),
                                                //           iconSize: 40,
                                                //           onPressed: () {},
                                                //         ),
                                                //       )
                                                //     :
                                                Container(width: 40),
                                                SizedBox(width: 20),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data != index
                                          ? Container(
                                              color: Colors.black54,
                                            )
                                          : Container(),
                                      Container(
                                        padding: EdgeInsets.only(left: 20),
                                        child: snapshot.data == index
                                            ? Image.asset(
                                                ImgConstants.indoorbike)
                                            : null,
                                      ),
                                    ]),
                                  ),
                                );
                              });
                        }
                        return SizedBox(
                          height: 0,
                        );
                      })),
              _btnBLEConnect()
            ],
          );
        });
  }

  Widget _scanningUI() {
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBlue.instance.scanResults,
      builder: (context, snapshot) {
        List<ScanResult>? resultDevice = snapshot.hasData ? snapshot.data : [];

        return ValueListenableBuilder(
            valueListenable: _notifierBLECount,
            builder: (context, value, child) {
              if (value == 0) {
                return scanningWidget();
              }
              return Container();
            });
      },
    );
  }

  Widget scanningWidget() {
    return Container(
      color: Colors.black,
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(height: 15),
          Text(
            AppConstants.searching,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: _config!.fontFamilyAntonio,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
                fontSize: 20,
                color: Colors.white),
          ),
          Expanded(child: Image.asset(ImgConstants.searchingBLE)),
          Text(
            AppConstants.thisisfaster,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: _config!.fontFamilyAntonio,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: Colors.grey),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _btnBLEConnect() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 15.0), child: _btnConnect());
  }

  Widget _btnConnect() {
    int intSelectedValue = (_blocBluetooth.intSelection.value ?? 0);

    return StreamBuilder<bool>(
        stream: _blocBluetooth.btnTapped,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              height: 50,
              width: MediaQuery.of(context).size.width / 2,
              child: LoaderButton(
                title: AppConstants.connect,
                isLoading: snapshot.data,
                onPressed: () async {
                  if ((_blocBluetooth.intSelection.value ?? 0) > -1) {
                    _blocBluetooth.bleConnectButtonTapped(true);
                    final scanResult =
                        resultDevice?[_blocBluetooth.intSelection.value ?? 0];
                    if (scanResult != null) {
                      if (scanResult.advertisementData.connectable) {
                        await scanResult.device.connect(autoConnect: false);
                      }
                    } else {
                      CustomAlertDialog().showAlert(
                          context: context,
                          message: AppConstants.bleDataNotAccessible,
                          title: AppConstants.appName);
                    }
                  }
                },
              ),
            );
          }
          return Container();
        });
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

  // Bluetooth REGEN device count which is scanned
  bleCount(List<ScanResult> resultDevice) async {
    int count = await _blocBluetooth.checkCountForREGRN(resultDevice);
    print(count);
    _notifierBLECount.value = count;
  }
}
