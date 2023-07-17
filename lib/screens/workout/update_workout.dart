import 'dart:async';

import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/screens/bluetoothConnectivity/bluetoothbloc.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/helpers/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class UpdateWorkoutArgs extends RoutesArgs {
  UpdateWorkoutArgs({
    required this.workoutValue,
    required this.value,
  }) : super(isHeroTransition: true);
  final WorkoutType? workoutValue;
  final int value;
}

// This screen used to update workout data and write to ESP
class UpdateWorkout extends StatefulWidget {
  const UpdateWorkout({
    Key? key,
    required this.workoutValue,
    required this.value,
  }) : super(key: key);
  static const String routeName = '/UpdateWorkout';
  final WorkoutType workoutValue;
  final int value;

  @override
  _UpdateWorkoutState createState() => _UpdateWorkoutState();
}

class _UpdateWorkoutState extends State<UpdateWorkout> {
  AppConfig? _config;
  UserModel? _currentUser;
  ValueNotifier<int>? _notifierValueChange = ValueNotifier<int>(190);
  WorkoutType? _workoutValue;
  Timer? _timer;
  final BluetoothBloc _blocBluetooth = BluetoothBloc();
  late BluetoothDevice? connectedDevice;
  List<int> arrExerciseData = [];
  // final StopWatchTimer _stopWatchTimer = StopWatchTimer(
  //   mode: StopWatchMode.countUp,
  //   onChange: (int value) {
  //     final displayTime = StopWatchTimer.getDisplayTime(
  //       value,
  //     );
  //     aGeneralBloc.updateWorkoutTimer(displayTime);
  //   },
  // );

  @override
  void initState() {
    super.initState();
    _workoutValue = widget.workoutValue;
    _currentUser = aGeneralBloc.currentUser;
    _notifierValueChange!.value = widget.value;
    connectedDevice = aGeneralBloc.getSelectedBike();
    _blocBluetooth.discoverCharacteristics(connectedDevice!);
    // Future.delayed(Duration(seconds: 1), () {
    //   _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    // });
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsetsDirectional.fromSTEB(16, 41, 16, 38),
          child: StreamBuilder<BluetoothCharacteristic?>(
              stream: _blocBluetooth.streamCharValue,
              builder: (context, snapshotBluetoothCharacteristic) {
                if (snapshotBluetoothCharacteristic.hasData &&
                    snapshotBluetoothCharacteristic.data != null) {
                  return StreamBuilder<List<int>>(
                      stream: snapshotBluetoothCharacteristic.data?.value,
                      initialData:
                          snapshotBluetoothCharacteristic.data?.lastValue,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          // 0 index for cadence
                          // 1 index for resistence
                          // 2 index for watts
                          // 3 index for calories
                          arrExerciseData = _blocBluetooth
                              .dataParserAndCalculation(snapshot.data!);
                          return Column(
                            children: <Widget>[
                              Expanded(child: _widgetWorkoutValue()),
                              _widgetBottomValues()
                            ],
                          );
                        }
                        return SizedBox();
                      });
                }
                return SizedBox();
              }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _blocBluetooth.bleReadCharacteristic!.setNotifyValue(false);
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(
      context,
      _config!,
      backgoundColor: Colors.transparent,
      textColor: _config!.whiteColor,
      widget: _widgetTimter(),
      elevation: 0,
      isBackEnable: false,
      onBack: () {},
      leadingWidget: IconButton(
          icon: Icon(
            Icons.close,
            size: 24,
            color: _config!.whiteColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
    );
  }

  Widget _widgetTimter() {
    return StreamBuilder<String>(
        stream: aGeneralBloc.getWorkoutTime,
        builder: (context, snapshot) {
          String time = '00:00:00';
          if (snapshot.hasData && snapshot.data != null) {
            time = snapshot.data!;
          }
          return Padding(
            padding: const EdgeInsets.all(0.0),
            child: Text(time,
                style: _config!.antonioHeading1FontStyle
                    .apply(color: _config!.btnPrimaryColor),
                textAlign: TextAlign.center),
          );
        });
  }

  Widget _widgetWorkoutValue() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _btnPlus(),
          const SizedBox(
            height: 40,
          ),
          _widgetSpeedoMeeter(),
          const SizedBox(
            height: 40,
          ),
          _btnMinus(),
        ],
      ),
    );
  }

  Widget _btnPlus() {
    return GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getWorkoutValueColor().withOpacity(0.1),
          ),
          width: 80,
          height: 80,
          child: Center(
            child: SvgIcon.asset(
              ImgConstants.plus,
              size: 48,
              color: _getWorkoutValueColor(),
            ),
          ),
        ),
        onTap: () async {
          if (_notifierValueChange!.value < 300) {
            _notifierValueChange!.value++;

            // Write Resistance in ESP
            _blocBluetooth.writeData(
                context, 0x04, _notifierValueChange!.value);
          }
        },
        onTapDown: (TapDownDetails details) {
          print('down');
          _timer = Timer.periodic(Duration(milliseconds: 100), (t) {
            if (_notifierValueChange!.value < 300) {
              _notifierValueChange!.value++;
            }
          });
        },
        onTapUp: (TapUpDetails details) {
          print('up');
          _timer!.cancel();
        },
        onTapCancel: () {
          print('cancel');
          _timer!.cancel();
        });
  }

  Widget _btnMinus() {
    return GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getWorkoutValueColor().withOpacity(0.1),
          ),
          width: 80,
          height: 80,
          child: Center(
            child: SvgIcon.asset(
              ImgConstants.minus,
              size: 48,
              color: _getWorkoutValueColor(),
            ),
          ),
        ),
        onTap: () {
          if (_notifierValueChange!.value > 0) {
            _notifierValueChange!.value--;
          }
        },
        onTapDown: (TapDownDetails details) {
          print('down');
          _timer = Timer.periodic(Duration(milliseconds: 100), (t) {
            if (_notifierValueChange!.value > 0) {
              _notifierValueChange!.value--;
            }
          });
        },
        onTapUp: (TapUpDetails details) {
          print('up');
          _timer!.cancel();
        },
        onTapCancel: () {
          print('cancel');
          _timer!.cancel();
        });
  }

  Widget _widgetSpeedoMeeter() {
    return ValueListenableBuilder<int>(
      valueListenable: _notifierValueChange!,
      builder: (BuildContext? context, int? value, Widget? child) {
        return Expanded(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                Expanded(
                  child: Hero(
                    tag: _workoutValue!,
                    child: SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          minimum: 0,
                          maximum: 300,
                          canScaleToFit: true,
                          showTicks: false,
                          interval: 50,
                          axisLabelStyle: GaugeTextStyle(
                            fontSize: 14,
                            color: _config!.greyColor,
                            fontFamily: _config!.fontFamilyCalibri,
                          ),
                          axisLineStyle: AxisLineStyle(
                            thickness: 0.20,
                            color: _config!.borderColor,
                            thicknessUnit: GaugeSizeUnit.factor,
                            cornerStyle: CornerStyle.bothCurve,
                          ),
                          pointers: <GaugePointer>[
                            RangePointer(
                              value: value!.toDouble(),
                              width: 0.20,
                              sizeUnit: GaugeSizeUnit.factor,
                              color: _getWorkoutValueColor(),
                              cornerStyle: CornerStyle.bothCurve,
                            )
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                                positionFactor: 0.0,
                                angle: 90,
                                widget: Text(
                                  value.toString(),
                                  style:
                                      _config!.antonioHeading1FontStyle.apply(
                                    color: _config!.whiteColor,
                                    decoration: TextDecoration.none,
                                  ),
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(_getWorkoutValueName(),
                      style: _config!.calibriHeading2FontStyle
                          .apply(color: _config!.whiteColor),
                      textAlign: TextAlign.center),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _widgetBottomValues() {
    return Container(
      width: double.infinity,
      height: 72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_workoutValue == WorkoutType.resistance) _widgetWatts(),
          if (_workoutValue == WorkoutType.watts) _widgetResistance(),
          if (_workoutValue == WorkoutType.calories) _widgetResistance(),
          if (_workoutValue == WorkoutType.cadence) _widgetWatts(),
          const SizedBox(
            width: 40,
            height: double.infinity,
          ),
          Container(
            width: 1,
            height: double.infinity,
            color: _config!.whiteColor.withOpacity(0.1),
          ),
          const SizedBox(
            width: 40,
            height: double.infinity,
          ),
          _widgetCadence()
        ],
      ),
    );
  }

  Widget _widgetResistance() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: Column(
        children: [
          Text('${arrExerciseData[1]}',
              style: _config!.antonioHeading1FontStyle
                  .apply(color: _config!.whiteColor),
              textAlign: TextAlign.center),
          const SizedBox(
            height: 4,
          ),
          Text(AppConstants.resistance,
              style: _config!.paragraphNormalFontStyle
                  .apply(color: _config!.greyColor),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _widgetWatts() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: Column(
        children: [
          Text('${arrExerciseData[2]}',
              style: _config!.antonioHeading1FontStyle
                  .apply(color: _config!.whiteColor),
              textAlign: TextAlign.center),
          const SizedBox(
            height: 4,
          ),
          Text(AppConstants.watts,
              style: _config!.paragraphNormalFontStyle
                  .apply(color: _config!.greyColor),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _widgetCalories() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: Column(
        children: [
          Text('130',
              style: _config!.antonioHeading1FontStyle
                  .apply(color: _config!.whiteColor),
              textAlign: TextAlign.center),
          const SizedBox(
            height: 4,
          ),
          Text(AppConstants.calories,
              style: _config!.paragraphNormalFontStyle
                  .apply(color: _config!.greyColor),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _widgetCadence() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: Column(
        children: [
          Text('${arrExerciseData[0]}',
              style: _config!.antonioHeading1FontStyle
                  .apply(color: _config!.whiteColor),
              textAlign: TextAlign.center),
          const SizedBox(
            height: 4,
          ),
          Text(AppConstants.cadence,
              style: _config!.paragraphNormalFontStyle
                  .apply(color: _config!.greyColor),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // Set workout color based on workout data
  Color _getWorkoutValueColor() {
    switch (_workoutValue) {
      case WorkoutType.resistance:
        return _config!.skyBlueColor;
      case WorkoutType.watts:
        return _config!.btnPrimaryColor;
      case WorkoutType.calories:
        return _config!.orangeColor;
      case WorkoutType.cadence:
        return _config!.purpelColor;
      default:
        return _config!.purpelColor;
    }
  }

  // Set data types name
  String _getWorkoutValueName() {
    switch (_workoutValue) {
      case WorkoutType.resistance:
        return AppConstants.resistance;
      case WorkoutType.watts:
        return AppConstants.watts;
      case WorkoutType.calories:
        return AppConstants.calories;
      case WorkoutType.cadence:
        return AppConstants.cadence;
      default:
        return AppConstants.resistance;
    }
  }
}
