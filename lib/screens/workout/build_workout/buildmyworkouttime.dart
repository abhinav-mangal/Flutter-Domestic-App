import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/loader_button.dart';
import 'package:energym/screens/AnimationCounter/animation_counter.dart';
import 'package:energym/screens/bluetoothConnectivity/bluetoothConnectivity.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/helpers/routing/router.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wheel_slider/wheel_slider.dart';

// This screen choose time to start workout
// There is few optons 30, 45, 60 and custom time ,
//so uer can set time via slider scrolling
class BuildMyWorkoutTimeArgs extends RoutesArgs {
  BuildMyWorkoutTimeArgs({
    required this.index,
  }) : super(isHeroTransition: true);
  final int? index;
}

class BuildMyWorkoutTime extends StatefulWidget {
  const BuildMyWorkoutTime({Key? key, required this.index}) : super(key: key);
  static const String routeName = '/BuildMyWorkoutTime';
  final int? index;
  @override
  _BuildMyWorkoutTimeState createState() => _BuildMyWorkoutTimeState();
}

class _BuildMyWorkoutTimeState extends State<BuildMyWorkoutTime> {
  UserModel? _currentUser;
  AppConfig? _config;
  APIProvider? _api;
  int? _index;
  final int _totalCount = 120;
  final int _initValue = 60;
  int _currentValue = 60;

  ValueNotifier<bool> _notifier30mins = ValueNotifier<bool>(false);
  ValueNotifier<bool> _notifier45mins = ValueNotifier<bool>(false);
  ValueNotifier<bool> _notifier60mins = ValueNotifier<bool>(false);
  ValueNotifier<int> _notifierSlider = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _api = APIProvider.of(context);
    _notifierSlider.value = _currentValue;
    _index = widget.index;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: _getAppBar(),
          body: _mainContainer(),
          floatingActionButton: _btnStart(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  Widget _mainContainer() {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 15),
            child: Text(
              AppConstants.yourWorkout.toUpperCase(),
              style: _config!.antonio36FontStyle
                  .apply(color: AppColors.blueworkout),
            ),
          ),
          Text(AppConstants.chooseanOption,
              style: _config!.antonioHeading2FontStyle),
          _time(),
          _customTime(),
          _slider()
        ],
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _config!,
        backgoundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        isBackEnable: false,
        onBack: () {},
        leadingWidget: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 24,
            color: AppColors.blueworkout,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        widget: btnPairing(context, (isConnectedDevice) {
          if (isConnectedDevice) {
            // pop up
            // bottomSheet(context);
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BlueToothConnectivityVC()));
          }
        }),
        actions: <Widget>[
          btnSweatCointBalance(context, _config!),
        ]);
  }

  Widget _time() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ValueListenableBuilder<bool>(
              valueListenable: _notifier30mins,
              builder: (BuildContext? context, status, child) {
                return minsWidget(30, 0, _notifier30mins.value, 85, () {
                  _notifier30mins.value = true;
                  _notifier45mins.value = false;
                  _notifier60mins.value = false;
                  _notifierSlider.value = 30;
                });
              }),
          ValueListenableBuilder<bool>(
              valueListenable: _notifier45mins,
              builder: (BuildContext? context, status, child) {
                return minsWidget(45, 0, _notifier45mins.value, 85, () {
                  _notifier30mins.value = false;
                  _notifier45mins.value = true;
                  _notifier60mins.value = false;
                  _notifierSlider.value = 45;
                });
              }),
          ValueListenableBuilder<bool>(
              valueListenable: _notifier60mins,
              builder: (BuildContext? context, status, child) {
                return minsWidget(60, 0, _notifier60mins.value, 85, () {
                  _notifier30mins.value = false;
                  _notifier45mins.value = false;
                  _notifier60mins.value = true;
                  _notifierSlider.value = 60;
                });
              }),
        ],
      ),
    );
  }

  Widget _customTime() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        height: 85,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: AppColors.blueworkout),
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: Center(
          child: Text(
            AppConstants.customTime,
            textAlign: TextAlign.center,
            style: _config!.antonioHeading2FontStyle
                .apply(color: _config!.whiteColor),
          ),
        ),
      ),
    );
  }

  Widget minsWidget(
      int mins, int index, bool isSelected, double width, Function? onPress) {
    return GestureDetector(
      onTap: () {
        onPress!();
      },
      child: Container(
        height: 85,
        width: width,
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: AppColors.blueworkout),
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
            color: isSelected ? AppColors.blueworkout : Colors.transparent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${mins}',
              style: _config!.antonioHeading2FontStyle
                  .apply(color: _config!.whiteColor),
            ),
            Text(
              'Min',
              style: _config!.antonioHeading2FontStyle
                  .apply(color: _config!.whiteColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider() {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: ValueListenableBuilder<int>(
            valueListenable: _notifierSlider,
            builder: (BuildContext? context, value, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('${value}', style: _config!.antonioHeading3FontStyle),
                  WheelSlider(
                    lineColor: AppColors.blueworkout,
                    pointerColor: AppColors.blueworkout,
                    totalCount: _totalCount,
                    initValue: _initValue,
                    isVibrate: false,
                    onValueChanged: (val) {
                      if (int.parse(val.toString()) >= 15) {
                        _notifierSlider.value = int.parse(val.toString());
                      }
                    },
                  ),
                  Text('MIN', style: _config!.antonioHeading4FontStyle),
                ],
              );
            }));
  }

  Widget _btnStart() {
    return Container(
      padding: EdgeInsets.only(bottom: 50, left: 30, right: 30),
      // color: Colors.red,
      width: double.infinity,
      height: 110,
      child: LoaderButton(
        isOutLine: true,
        outLineColor: AppColors.blueworkout,
        radius: 12,
        onPressed: () {
          // if (globalMins == 0) {
          //   CustomAlertDialog().showAlert(
          //       context: context,
          //       message: MsgConstants.testmin,
          //       title: AppConstants.appName);
          // } else {
          Navigator.popAndPushNamed(
            context,
            AnimationCounter.routeName,
            arguments: AnimationCounterArgs(
                isLiveCalibration: false,
                mins: _notifierSlider.value,
                isBuildworkout: true,
                index: _index),
          );
          // }
        },
        title: AppConstants.startWorkout.toUpperCase(),
        titleStyle: _config!.antonio48FontStyle
            .apply(color: AppColors.blueworkout, fontSizeFactor: 0.5),
      ),
    );
  }
}
