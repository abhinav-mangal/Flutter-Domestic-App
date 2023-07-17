import 'dart:ui';

import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/screens/AnimationCounter/animation_counter.dart';
import 'package:energym/screens/bluetoothConnectivity/bluetoothConnectivity.dart';
import 'package:energym/screens/bluetoothConnectivity/bluetoothbloc.dart';
import 'package:energym/screens/workout/build_workout/buildmyworkoutlist.dart';
import 'package:energym/screens/workout/green_zone/green_zone.dart';
import 'package:energym/screens/workout/hit_my_daily_goal/hitmydailygoal.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/common/svg_picture_customise.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// This is main workout listing screen
class Workout extends StatefulWidget {
  @override
  _WorkoutState createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> with SingleTickerProviderStateMixin {
  UserModel? _currentUser;
  AppConfig? _config;
  APIProvider? _api;

  final BluetoothBloc _blocBluetooth = BluetoothBloc();
  double height = 0;
  @override
  void initState() {
    height = WidgetsBinding.instance!.window.physicalSize.height / 2;
    super.initState();
    _api = APIProvider.of(context);
    // HealthProvider.instance.writeCalories();
  }

  @override
  void dispose() {
    super.dispose();
    _blocBluetooth.streamCharValue.drain();
    _blocBluetooth.bleCharacteristic?.value.drain();
    _blocBluetooth.bleCharacteristic!.setNotifyValue(false);
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
        }

        return CustomScaffold(
          resizeToAvoidBottomInset: false,
          appBar: _getAppBar(),
          body: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 15),
                    height: 50,
                    child: Text(
                      AppConstants.PickYourWorkout,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: _config!.fontFamilyAntonio,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      // height: height / 6,
                      child: _mainContainerWidget(context),
                    ),
                  ),
                  _btnStartWorkOut()
                ],
              ),
              // popUp(context),
            ],
          ),
          // floatingActionButtonLocation:
          //     FloatingActionButtonLocation.centerDocked,
          // floatingActionButton: _btnStartWorkOut(),
        );
      },
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _config!,
        backgoundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        isBackEnable: false,
        widget: btnPairing(
          context,
          (isConnectedDevice) {
            if (isConnectedDevice) {
              // pop up
              bottomSheet(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => BlueToothConnectivityVC(),
                ),
              );
            }
          },
        ),
        //gradient: AppColors.gradintBtnSignUp,
        onBack: () {},
        actions: <Widget>[
          btnSweatCointBalance(context, _config!),
        ]);
  }

  Widget _mainContainerWidget(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Column(
        children: [
          _widgetBuildMyWorkOut(
            title: AppConstants.buildYourWorkout,
            subTitle: AppConstants.tCR,
            isInfoVisible: true,
            onPress: () {
              var connectedDevice = aGeneralBloc.getSelectedBike();
              if (connectedDevice == null) {
                CustomAlertDialog().showAlert(
                  context: context,
                  message: AppConstants.bleMNotConnectedessage,
                  title: AppConstants.appName,
                );
              } else {
                Navigator.pushNamed(context, BuildMyWorkout.routeName);
              }
            },
            titleColor: AppColors.blueworkout,
            subTitleColor: AppColors.blueworkout,
          ),
          _widgetBuildMyWorkOut(
            title: AppConstants.HitMyDailyGoal,
            subTitle: AppConstants.calorieGoal,
            isInfoVisible: true,
            onPress: () {
              var connectedDevice = aGeneralBloc.getSelectedBike();
              if (connectedDevice == null) {
                CustomAlertDialog().showAlert(
                  context: context,
                  message: AppConstants.bleMNotConnectedessage,
                  title: AppConstants.appName,
                );
              } else {
                Navigator.pushNamed(context, HitMyDailyGoal.routeName);
              }
            },
            titleColor: AppColors.orangeworkout,
            subTitleColor: AppColors.orangeworkout,
          ),
          _widgetBuildMyWorkOut(
            title: AppConstants.challengeTheLeaderBoard,
            subTitle: AppConstants.rightForYourSpot,
            isInfoVisible: true,
            onPress: () {},
            titleColor: AppColors.brownworkout,
            subTitleColor: AppColors.brownworkout,
          ),
          _widgetBuildMyWorkOut(
            title: AppConstants.greenZone,
            subTitle: AppConstants.rightForYourSpot,
            isInfoVisible: true,
            onPress: () {
              var connectedDevice = aGeneralBloc.getSelectedBike();

              if (connectedDevice == null) {
                CustomAlertDialog().showAlert(
                    context: context,
                    message: AppConstants.bleMNotConnectedessage,
                    title: AppConstants.appName);
              } else {
                Navigator.pushNamed(context, GreenZone.routeName);
              }
            },
            titleColor: AppColors.greenworkout,
            subTitleColor: AppColors.lightgreenworkout,
          ),
          _widgetBuildMyWorkOut(
            title: AppConstants.challengeFriends,
            subTitle: AppConstants.comingSoon,
            isInfoVisible: false,
            onPress: () {},
            titleColor: AppColors.lightgreenworkout,
            subTitleColor: AppColors.greenworkout,
          ),
          _widgetBuildMyWorkOut(
            title: AppConstants.onDemand,
            subTitle: AppConstants.comingSoon,
            isInfoVisible: false,
            onPress: () {},
            titleColor: AppColors.lightgreenworkout,
            subTitleColor: AppColors.greenworkout,
          ),
        ],
      ), //.animatedVertically(),
    );
  }

  Widget _widgetBuildMyWorkOut(
      {required String? title,
      required String? subTitle,
      required bool? isInfoVisible,
      required Color titleColor,
      required Color subTitleColor,
      Color? colorBackground,
      Function? onPress}) {
    return Container(
      width: double.infinity,
      height: 90,
      padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 8),
      child: _widgetBtn(
          title: title,
          subTitle: subTitle,
          workOutValue: _widgetWrokOutValue(10),
          onPress: () {
            if (onPress != null) {
              onPress();
            }
          },
          isInfoVisible: isInfoVisible,
          colorTitlenBorder: titleColor,
          colorSubTitle: subTitleColor,
          colorBackground: colorBackground),
    );
  }

  Widget _widgetBtn(
      {required String? title,
      required String? subTitle,
      required bool? isInfoVisible,
      required Widget? workOutValue,
      required Color colorTitlenBorder,
      required Color colorSubTitle,
      Color? colorBackground,
      Function? onPress}) {
    return TextButton(
      onPressed: () {
        if (onPress != null) {
          onPress();
        }
      },
      style: TextButton.styleFrom(
        backgroundColor: colorBackground != null ? colorBackground : null,
        padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: colorTitlenBorder)),
      ),
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: Container(
                height: 10,
                width: 10,
                child: isInfoVisible!
                    ? Icon(
                        Icons.info,
                        size: 15,
                        color: colorTitlenBorder,
                      )
                    : SizedBox(),
              ),
            ),
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title!.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: _config!.fontFamilyAntonio,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                          color: colorTitlenBorder),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      subTitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: _config!.fontFamilyCalibri,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          color: colorSubTitle),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 20,
            )
          ],
        ),
      ),
    );
  }

  Widget _widgetWrokOutValue(int value) {
    return Container(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SvgPictureRecolor.asset(
            ImgConstants.sweatCoin,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            value.toString(),
            style: _config!.antonioHeading4FontStyle
                .apply(color: _config!.btnPrimaryColor),
          )
        ],
      ),
    );
  }

  Widget _btnStartWorkOut() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
        height: 80,
        child: _widgetBuildMyWorkOut(
            title: AppConstants.instantWorkout,
            subTitle: AppConstants.startNow,
            isInfoVisible: true,
            onPress: () {
              var connectedDevice = aGeneralBloc.getSelectedBike();

              if (connectedDevice == null) {
                CustomAlertDialog().showAlert(
                    context: context,
                    message: AppConstants.bleMNotConnectedessage,
                    title: AppConstants.appName);
              } else {
                Navigator.pushNamed(
                  context,
                  AnimationCounter.routeName,
                  arguments: AnimationCounterArgs(
                    isLiveCalibration: false,
                    isBuildworkout: false,
                  ),
                );
              }
            },
            titleColor: AppColors.graytextworkout,
            subTitleColor: AppColors.grayinfoworkout,
            colorBackground: AppColors.grayworkout),
      ),
    );
  }
}
