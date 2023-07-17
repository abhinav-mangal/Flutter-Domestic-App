import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energym/screens/bluetoothConnectivity/qrcodescanning.dart';
import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../models/user_model.dart';
import '../../reusable_component/custom_scaffold.dart';
import '../../reusable_component/main_app_bar.dart';
import '../../utils/common/base_bloc.dart';
import '../../utils/common/common_widget.dart';
import '../../utils/common/constants.dart';
import '../../utils/helpers/api_provider.dart';
import '../../utils/helpers/firebase/firestore_provider.dart';
import '../../utils/theme/colors.dart';
import 'bluetoothListVC.dart';

// This screen contains BLE selection
// Like QR code scanning or List
class BlueToothConnectivityVC extends StatefulWidget {
  @override
  _BlueToothConnectivityVCState createState() =>
      _BlueToothConnectivityVCState();
}

class _BlueToothConnectivityVCState extends State<BlueToothConnectivityVC> {
  UserModel? _currentUser;
  AppConfig? _config;
  APIProvider? _api;
  @override
  void initState() {
    super.initState();
    _api = APIProvider.of(context);
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
          //aGeneralBloc.getCurrentSweatCoinUser(_api, context);
        }

        return CustomScaffold(
          resizeToAvoidBottomInset: false,
          appBar: _getAppBar(),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: Container(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BlueToothListVC()));
                          },
                          child: ClipRRect(
                              child: Image.asset(ImgConstants.bluetoothicon,
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                        height: MediaQuery.of(context).size.height / 3.5,
                        width: MediaQuery.of(context).size.height / 3.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          border:
                              Border.all(width: 1, color: AppColors.greenColor),
                        ),
                      )),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        AppConstants.pairBikeBlutooth,
                        style: TextStyle(
                            fontFamily: _config!.fontFamilyAntonio,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                            color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: Container(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => QRCodeScanningVC()));
                          },
                          child: ClipRRect(
                              child: Image.asset(ImgConstants.qrscan,
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                        height: MediaQuery.of(context).size.height / 3.5,
                        width: MediaQuery.of(context).size.height / 3.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          border:
                              Border.all(width: 1, color: AppColors.greenColor),
                        ),
                      )),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        AppConstants.pairBikeQR,
                        style: TextStyle(
                            fontFamily: _config!.fontFamilyAntonio,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        AppConstants.recommendedgym,
                        style: TextStyle(
                            fontFamily: _config!.fontFamilyAntonio,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
