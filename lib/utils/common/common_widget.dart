import 'dart:io';
import 'package:energym/app_config.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/reusable_component/shared_pref_helper.dart';
import 'package:energym/screens/bluetoothConnectivity/bluetoothConnectivity.dart';
import 'package:energym/screens/home/home.dart';
import 'package:energym/screens/transaction/transaction.dart';
import 'package:energym/screens/workout/workout.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_picture_customise.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:energym/models/sweatcoin_user_model.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:health/health.dart';

// Get Sweatcoin balance
Widget btnSweatCointBalance(
  BuildContext context,
  AppConfig appConfig,
) {
  APIProvider _api = APIProvider.of(context);
  return FutureBuilder<SweatCoinUser?>(
    future: aGeneralBloc.getCurrentSweatCoinUser(_api, context),
    builder: (BuildContext? context, AsyncSnapshot<SweatCoinUser?>? snapshot) {
      bool isLoading = !snapshot!.hasData;
      String balance = '0';
      if (snapshot.hasData && snapshot.data != null) {
        SweatCoinUser user = snapshot.data!;
        balance = '${double.parse((user.balance ?? 0).toStringAsFixed(2))}';
      }

      return TextButton(
        style: TextButton.styleFrom(),
        onPressed: () {
          Navigator.pushNamed(context!, Transaction.routeName);
        },
        child: Container(
          height: 30,
          padding: const EdgeInsetsDirectional.fromSTEB(11, 5, 11, 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: appConfig.btnPrimaryColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SvgPictureRecolor.asset(
                ImgConstants.sweatCoin,
                width: 10,
                //height: 13,

                //size: 10,
                //color: _config.whiteColor,
              ),
              const SizedBox(
                width: 5,
              ),
              isLoading
                  ? SpinKitCircle(
                      color: appConfig.whiteColor,
                      size: 15,

                      //lineWidth: 3,
                    )
                  : Text(
                      balance,
                      style: appConfig.antonioHeading4FontStyle
                          .apply(color: appConfig.whiteColor),
                    )
            ],
          ),
        ),
      );
    },
  );
}

// This is pairing weiget
Widget btnPairing(
    BuildContext mainContext, Function? funParing(bool isConnected)) {
  return StreamBuilder<List<BluetoothDevice?>?>(
    stream: Stream.periodic(const Duration(milliseconds: 200))
        .asyncMap((_) => flutterInstance.connectedDevices),
    builder: (c, snapshot) {
      if (snapshot.hasData) {
        BluetoothDevice? bleDevice = null;

        for (final BluetoothDevice? data in snapshot.data!) {
          if (aGeneralBloc.connectedBLE == data?.id.id) {
            bleDevice = data;
            break;
          }
        }

        if (bleDevice == null) {
          return pairedButton(
            false,
            (isConnected) {
              if (funParing != null) {
                funParing(false);
              }
            },
          );
        }

        return StreamBuilder<BluetoothDeviceState?>(
          stream: bleDevice.state,
          builder: (BuildContext context,
              AsyncSnapshot<BluetoothDeviceState?> innersnapshot) {
            final BluetoothDeviceState? state = innersnapshot.data;

            switch (state) {
              case BluetoothDeviceState.connected:
                flutterInstance.stopScan();
                aGeneralBloc.selectedBike(bleDevice);
                aGeneralBloc.saveConnectedDeviceUInPreference(bleDevice);
                break;
              case BluetoothDeviceState.disconnected:
                aGeneralBloc.selectedBike(null);
                aGeneralBloc.saveConnectedDeviceUInPreference(null);
                aGeneralBloc.setConnectedDeviceID('');
                gdevice = null;
                aGeneralBloc.services = [];
                aGeneralBloc.connectedBLE = '';

                break;
              case BluetoothDeviceState.connecting:
                break;
              case BluetoothDeviceState.disconnecting:
                print('Disconnecting');
                break;
              default:
                print('');
            }
            statusConnectedDevice();
            return pairedButton(
              statusConnected ?? false,
              (isConnected) {
                if (funParing != null) {
                  funParing(statusConnected ?? false);
                }
              },
            );
          },
        );
      }
      return pairedButton(
        false,
        (isConnected) {
          if (funParing != null) {
            funParing(false);
          }
        },
      );
    },
  );
}

bool? statusConnected;
statusConnectedDevice() async {
  statusConnected = await aGeneralBloc.connectedDeviceFromApp();
}

Widget pairedButton(bool isData, Function? funParing(bool isConnected)) {
  return TextButton(
    child: Container(
      height: 44,
      width: 44,
      child: Image.asset(
        (isData) ? ImgConstants.paired : ImgConstants.unpaired,
        fit: BoxFit.cover,
      ),
    ),
    onPressed: () {
      if (funParing != null) {
        funParing(isData);
      }
    },
  );
}

Widget popUp(BuildContext context) {
  var connectedDevice = aGeneralBloc.getSelectedBike();
  AppConfig _config = AppConfig.of(context);
  return Padding(
    padding: EdgeInsets.only(top: 50, bottom: 50),
    child: Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      AppConstants.disconnectBike,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: _config.fontFamilyCalibri,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '${connectedDevice?.name}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: _config.fontFamilyAntonio,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      '${connectedDevice?.id}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: _config.fontFamilyAntonio,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    btnDisConnect(context)
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    ),
  );
}

Widget btnDisConnect(BuildContext context) {
  var connectedDevice = aGeneralBloc.getSelectedBike();
  AppConfig _config = AppConfig.of(context);
  return Container(
    height: 44,
    width: 150,
    child: TextButton(
      child: Text(
        AppConstants.disconnect,
        style: TextStyle(
          fontFamily: _config.fontFamilyAntonio,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      onPressed: () {
        aGeneralBloc.selectedBike(null);
        connectedDevice?.disconnect();
        Navigator.pop(context);
      },
    ),
    decoration: BoxDecoration(
      color: AppColors.darkgreen,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  );
}

bottomSheet(BuildContext context) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[popUp(context)],
      );
    },
  );
}
