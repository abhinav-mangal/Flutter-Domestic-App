import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/loader_button.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/screens/bluetoothConnectivity/bluetoothbloc.dart';
import 'package:energym/screens/workout/green_zone/calibrationcompleteworkout.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/slider_button.dart';
import 'package:energym/utils/common/stop_watch_timer.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/helpers/routing/router.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

int? globalMins;

// This screen for green zone live workout
// It contains Rersistance, Watts, Cadence
// And also Watts graph
// After complete workout this will calculate FTP value for user
class LiveCalibrationWorkoutArgs extends RoutesArgs {
  LiveCalibrationWorkoutArgs({
    required this.mins,
  }) : super(isHeroTransition: true);
  final int? mins;
}

class LiveCalibrationWorkout extends StatefulWidget {
  const LiveCalibrationWorkout({Key? key, required this.mins})
      : super(key: key);
  static const String routeName = '/LiveCalibrationWorkout';
  final int? mins;
  @override
  _LiveCalibrationWorkoutState createState() => _LiveCalibrationWorkoutState();
}

class _LiveCalibrationWorkoutState extends State<LiveCalibrationWorkout> {
  AppConfig? _config;
  UserModel? _currentUser;
  APIProvider? _api;
  late BluetoothDevice? connectedDevice;
  final BluetoothBloc _blocBluetooth = BluetoothBloc();
  int resistenceValue = 0;
  int wattsValue = 0;

  List<int> arrCadence = [];
  int caloriesValue = 0;
  int avgWatts = 0;

  List<LinearWorkout> arrResistenceChart = [];
  List<LinearWorkout> arrWattsChart = [];
  List<LinearWorkout> arrCadenceChart = [];
  ValueNotifier<int> _notifierResistance = ValueNotifier<int>(0);
  double sweatCoinRewarded = 0;

  int? _mins;
  bool isTimerDone = false;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countDown,
    presetMillisecond: StopWatchTimer.getMilliSecFromMinute(globalMins ?? 0),
    onChange: (int value) {
      final displayTime = StopWatchTimer.getDisplayTime(value);
      aGeneralBloc.updateWorkoutTimer(displayTime);
    },
  );

  @override
  void initState() {
    super.initState();

    _mins = widget.mins;
    connectedDevice = aGeneralBloc.getSelectedBike();

    _blocBluetooth.discoverCharacteristics(connectedDevice!);

    _currentUser = aGeneralBloc.currentUser;
    _api = APIProvider.of(context);
    Future.delayed(Duration(seconds: 0), () {
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    });
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      // appBar: ,
      body: SafeArea(
        child: StreamBuilder<BluetoothCharacteristic?>(
          stream: _blocBluetooth.streamCharValue,
          builder: (context, snapshotBluetoothCharacteristic) {
            if (snapshotBluetoothCharacteristic.hasData &&
                snapshotBluetoothCharacteristic.data != null) {
              return StreamBuilder<List<int>>(
                stream: snapshotBluetoothCharacteristic.data?.value,
                initialData: snapshotBluetoothCharacteristic.data?.lastValue,
                builder: (context, snapshot) {
                  print("snapshot.data ${snapshot.data}");
                  if (snapshot.hasData && snapshot.data != null) {
                    List<int> arrExerciseData =
                        _blocBluetooth.dataParserAndCalculation(snapshot.data!);
                    // 0 index for cadence
                    // 1 index for resistence
                    // 2 index for watts
                    // 3 index for Av. watts
                    // 4 index for calories
                    arrCadence.add(arrExerciseData[0]);
                    resistenceValue = arrExerciseData[1];
                    wattsValue = arrExerciseData[2];
                    avgWatts = arrExerciseData[3];
                    caloriesValue = arrExerciseData[4];

                    return Container(
                      // color: Colors.red,
                      width: double.infinity,
                      height: double.infinity,
                      child: Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 0, 16, 0),
                            child: Column(
                              children: <Widget>[
                                _getAppBar(),
                                const SizedBox(
                                  height: 0,
                                ),
                                Text(AppConstants.liveCalibration,
                                    style: TextStyle(
                                        fontFamily: _config!.fontFamilyAntonio,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 20,
                                        color: Colors.white),
                                    textAlign: TextAlign.center),
                                _widgetTimter(),
                                _btnResistanceLevelUp(),
                                Expanded(child: _widgetWorkout()),
                                _widgetGraph(),
                                const SizedBox(
                                  height: 0,
                                )
                              ],
                            ),
                          ),
                          // _slideButton()
                        ],
                      ),
                    );
                  } else {
                    return SizedBox();
                  }
                },
              );
            } else {
              return SizedBox();
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _stopWatchTimer.dispose();
    _blocBluetooth.streamCharValue.drain();
    _blocBluetooth.bleCharacteristic?.value.drain();
    _blocBluetooth.bleCharacteristic!.setNotifyValue(false);
    _blocBluetooth.dispose();
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(
      context,
      _config!,
      backgoundColor: Colors.transparent,
      textColor: _config!.whiteColor,
      // title: AppConstants.liveCalibration,
      widget: btnPairing(
        context,
        (_) {},
      ),
      titleStyle: _config!.abel20FontStyle,
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
            _blocBluetooth.streamCharValue.drain();
            _blocBluetooth.bleCharacteristic?.value.drain();
            _blocBluetooth.bleCharacteristic!.setNotifyValue(false);
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

            if (snapshot.data == "00:00:00") {
              if (!isTimerDone) {
                isTimerDone = true;
                aGeneralBloc.updateWorkoutTimer('-1');

                saveData();
              }
            }
          }
          return Text(time,
              style: _config!.antonioHeading1FontStyle
                  .apply(color: _config!.btnPrimaryColor),
              textAlign: TextAlign.center);
        });
  }

  Widget _widgetGraph() {
    return StreamBuilder<int>(
        stream: _blocBluetooth.intChartSelection,
        builder: (context, snapshot) {
          var index = snapshot.data;
          if (snapshot.hasData) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _config!.borderColor),
              child: Column(
                children: [
                  Container(
                    // chart
                    width: double.infinity,
                    child: AspectRatio(
                      aspectRatio: 343 / 170,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, top: 10),
                            child: Text(
                              AppConstants.watts.toUpperCase(),
                              style: _config!.abelNormalFontStyle
                                  .copyWith(color: Colors.grey),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 5),
                              width: double.infinity,
                              height: double.infinity,
                              // decoration: BoxDecoration(
                              //     borderRadius: BorderRadius.circular(8),
                              //     color: _config!.borderColor),
                              child: chartView([wattsValue]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        });
  }

  List<charts.Series<LinearWorkout, int>> _createData() {
    int index = _blocBluetooth.intChartSelection.valueWrapper?.value ?? 0;
    List<LinearWorkout> data = [];

    arrWattsChart.add(LinearWorkout((arrWattsChart.length), wattsValue));
    data = arrWattsChart;
    return [
      new charts.Series<LinearWorkout, int>(
        id: '',
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(_config!.btnPrimaryColor),
        domainFn: (LinearWorkout data, _) => data.second,
        measureFn: (LinearWorkout data, _) => data.workoutData,
        data: data,
      ),
      new charts.Series<LinearWorkout, int>(
        id: '',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.white),
        fillColorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(_config!.btnPrimaryColor),
        domainFn: (LinearWorkout data, _) => data.second,
        measureFn: (LinearWorkout data, _) => data.workoutData,
        data: data,
      )..setAttribute(charts.rendererIdKey, 'customPoint'),
    ];
  }

  Widget bottomDots(int index, int id, Color color) {
    return Expanded(
      child: GestureDetector(
        child: Container(
          height: index == id ? 12 : 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _widgetWorkout() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 30),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: _widgetResistance(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _btnResistanceLevelDown(),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
              // color: Colors.blueGrey,
              width: double.infinity,
              height: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: _widgetWatts(),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: _widgetCadence(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    ;
  }

  Widget _widgetResistance() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      // onTap: () {
      //   Navigator.pushNamed(
      //     context,
      //     UpdateWorkout.routeName,
      //     arguments: UpdateWorkoutArgs(
      //       workoutValue: WorkoutType.resistance,
      //       value: resistenceValue,
      //     ),
      //   );
      // },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: WorkoutType.resistance,
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 300,
                      canScaleToFit: true,
                      showTicks: false,
                      interval: 50,
                      axisLabelStyle: GaugeTextStyle(
                        fontSize: 8,
                        color: _config!.greyColor,
                        fontFamily: _config!.fontFamilyCalibri,
                      ),
                      axisLineStyle: AxisLineStyle(
                        thickness: 0.20,
                        //cornerStyle: CornerStyle.bothCurve,
                        color: _config!.borderColor,
                        thicknessUnit: GaugeSizeUnit.factor,
                        cornerStyle: CornerStyle.bothCurve,
                      ),
                      pointers: <GaugePointer>[
                        RangePointer(
                          value: resistenceValue.toDouble(),
                          width: 0.20,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: _config!.btnPrimaryColor,
                          cornerStyle: CornerStyle.bothCurve,
                        )
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            positionFactor: 0.0,
                            angle: 90,
                            widget: Text(
                              '${resistenceValue}',
                              style: _config!.antonioHeading2FontStyle.apply(
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
              padding: const EdgeInsets.only(top: 0.0),
              child: Text(AppConstants.resistance.toUpperCase(),
                  style: _config!.abelNormalFontStyle
                      .apply(color: _config!.whiteColor),
                  textAlign: TextAlign.center),
            )
          ],
        ),
      ),
    );
  }

  Widget _widgetWatts() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // Navigator.pushNamed(
        //   context,
        //   UpdateWorkout.routeName,
        //   arguments: UpdateWorkoutArgs(
        //     workoutValue: WorkoutType.watts,
        //     value: arrWatts.last,
        //   ),
        // );
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: WorkoutType.watts,
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 300,
                      canScaleToFit: true,
                      showTicks: false,
                      interval: 50,
                      axisLabelStyle: GaugeTextStyle(
                        fontSize: 8,
                        color: _config!.greyColor,
                        fontFamily: _config!.fontFamilyCalibri,
                      ),
                      axisLineStyle: AxisLineStyle(
                        thickness: 0.20,
                        //cornerStyle: CornerStyle.bothCurve,
                        color: _config!.borderColor,
                        thicknessUnit: GaugeSizeUnit.factor,
                        cornerStyle: CornerStyle.bothCurve,
                      ),
                      pointers: <GaugePointer>[
                        RangePointer(
                          value: wattsValue.toDouble(),
                          width: 0.20,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: _config!.btnPrimaryColor,
                          cornerStyle: CornerStyle.bothCurve,
                        )
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            positionFactor: 0.0,
                            angle: 90,
                            widget: Text(
                              '${wattsValue}',
                              style: _config!.antonioHeading2FontStyle.apply(
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
              padding: const EdgeInsets.only(top: 0.0),
              child: Text(AppConstants.watts.toUpperCase(),
                  style: _config!.abelNormalFontStyle
                      .apply(color: _config!.whiteColor),
                  textAlign: TextAlign.center),
            )
          ],
        ),
      ),
    );
  }

  Widget _widgetCadence() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // Navigator.pushNamed(
        //   context,
        //   UpdateWorkout.routeName,
        //   arguments: UpdateWorkoutArgs(
        //       workoutValue: WorkoutType.cadence, value: arrCadence.last),
        // );
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: WorkoutType.cadence,
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 300,
                      canScaleToFit: true,
                      showTicks: false,
                      interval: 50,
                      axisLabelStyle: GaugeTextStyle(
                        fontSize: 8,
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
                          value: arrCadence.last.toDouble(),
                          width: 0.20,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: _config!.btnPrimaryColor,
                          cornerStyle: CornerStyle.bothCurve,
                        )
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            positionFactor: 0.0,
                            angle: 90,
                            widget: Text(
                              '${arrCadence.last}',
                              style: _config!.antonioHeading2FontStyle.apply(
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
              padding: const EdgeInsets.only(top: 0.0),
              child: Text(AppConstants.cadence.toUpperCase(),
                  style: _config!.abelNormalFontStyle
                      .apply(color: _config!.whiteColor),
                  textAlign: TextAlign.center),
            )
          ],
        ),
      ),
    );
  }

  Widget _btnResistanceLevelUp() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Container(
        width: 150,
        child: LoaderButton(
          isOutLine: true,
          outLineColor: _config!.btnPrimaryColor,
          radius: 8,
          onPressed: () {
            // Write Resistance in ESP
            _notifierResistance.value++;

            _blocBluetooth.writeData(context, 0x04, _notifierResistance.value);
          },
          title: '+',
          titleStyle: _config!.antonio48FontStyle
              .apply(color: _config!.btnPrimaryColor, fontSizeFactor: 0.5),
        ),
      ),
    );
  }

  Widget _btnResistanceLevelDown() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        width: 150,
        child: LoaderButton(
          isOutLine: true,
          outLineColor: _config!.btnPrimaryColor,
          radius: 8,
          onPressed: () {
            // Write Resistance in ESP
            _notifierResistance.value--;
            print(_notifierResistance.value);
            _blocBluetooth.writeData(context, 0x04, _notifierResistance.value);
          },
          title: '-',
          titleStyle: _config!.antonio48FontStyle
              .apply(color: _config!.btnPrimaryColor, fontSizeFactor: 0.5),
        ),
      ),
    );
  }

  Widget _slideButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: SliderButton(
        action: () {
          saveData();
        },
        label: Text(
          AppConstants.completeMyWorkout,
          style: _config!.linkLargeFontStyle
              .apply(color: _config!.btnPrimaryColor),
        ),
        icon: const Center(
          child: SvgIcon.asset(
            ImgConstants.tabWorkout,
            color: Colors.white,
            size: 24.0,
          ),
        ),
        boxShadow: const BoxShadow(
          color: Colors.black,
          blurRadius: 4,
        ),
        buttonSize: 60,
        width: context.width - 32,
        buttonColor: _config!.btnPrimaryColor,
        backgroundColor: _config!.btnPrimaryColor.withOpacity(0.2),
        highlightedColor: _config!.btnPrimaryColor.withOpacity(0.5),
        baseColor: _config!.btnPrimaryColor,
      ),
    );
  }

  // This function save workout data
  void saveData() {
    _blocBluetooth.streamCharValue.drain();
    _blocBluetooth.bleCharacteristic?.value.drain();
    _blocBluetooth.bleCharacteristic!.setNotifyValue(false);
    aGeneralBloc.updateAPICalling(true);

    // Generate Sweatcoin
    sweatCoinRewarded = _blocBluetooth.generateSweatCoin(avgWatts,
        double.parse(_mins!.toStringAsFixed(0)), _currentUser?.ftpValue ?? 0);

    _api!.addRewardToUaser(context,
        amount: sweatCoinRewarded,
        token: _currentUser!.sweatcoinId,
        description: '${wattsValue} ${AppConstants.watts}',
        onSuccess: (Response? response, Map<String, dynamic>? json) {
      json![TransactionCollectionField.userId] = _currentUser!.documentId;
      json[TransactionCollectionField.transactionEntryMode] =
          TransactionMode.credit;
      json[TransactionCollectionField.transactionEntryType] =
          TransactionType.earned;
      json[TransactionCollectionField.wattsGenerated] = wattsValue;
      json[TransactionCollectionField.status] = true;
      json[TransactionCollectionField.createdAt] = Timestamp.now();

      FireStoreProvider.instance.createTransaction(
        context: context,
        data: json,
        onSuccess: (Map<String, dynamic> success) {
          // Get and Update wortkout data for loggedin user
          updateUserWorkoutData();
          aGeneralBloc.updateAPICalling(false);
        },
        onError: (Map<String, dynamic> success) {
          aGeneralBloc.updateAPICalling(false);
          _goToWorkOutCompleteScreen();
        },
      );
    }, onError: (Response? response, Map<String, dynamic>? jsonData) {
      aGeneralBloc.updateAPICalling(false);
      _goToWorkOutCompleteScreen();
    });
  }

  // Naviagte to workout screen
  void _goToWorkOutCompleteScreen() {
    Map<String, dynamic> data = {};
    data[WorkoutDataKey.wattsGenerated] = wattsValue.toDouble();
    data[WorkoutDataKey.sweatCoinsEarned] = sweatCoinRewarded;
    data[WorkoutDataKey.ftpValue] = calculateFTP();

    data[WorkoutDataKey.oldFtpValue] = _currentUser?.ftpValue;
    Navigator.popAndPushNamed(context, CalibrationCompleteWorkout.routeName,
        arguments: CalibrationCompleteWorkoutArgs(workoutData: data));
  }

  // This function to update workout dat ain user table
  void updateUserWorkoutData() {
    var latestftp = calculateFTP();
    UserModel? currenrtUser = aGeneralBloc.currentUser;

    final Map<String, dynamic> _neetToStoreData = <String, dynamic>{};
    _neetToStoreData[UserCollectionField.resistence] =
        (currenrtUser?.resistence ?? 0) + resistenceValue;
    _neetToStoreData[UserCollectionField.watts] =
        (currenrtUser?.watts ?? 0) + wattsValue;
    _neetToStoreData[UserCollectionField.cadence] =
        (currenrtUser?.cadence ?? 0) + arrCadence.last;
    _neetToStoreData[UserCollectionField.ftpValue] = latestftp;
    _neetToStoreData[UserCollectionField.ftpLeaderboard] =
        ((avgWatts / latestftp) * 100).toInt();
    print("_neetToStoreData = ${_neetToStoreData}");

    FireStoreProvider.instance.updateUser(
        userId: _currentUser!.documentId,
        userData: _neetToStoreData,
        onSuccess: (Map<String, dynamic> successResponse) {
          print(successResponse);
          saveFirebaseWorkoutData();
        },
        onError: (Map<String, dynamic> errorResponse) {
          print(errorResponse);
          aGeneralBloc.updateAPICalling(false);
        });
  }

  int calculateFTP() {
    return globalMins == 5
        ? int.parse('${(avgWatts * 0.85).round()}')
        : int.parse('${(avgWatts * 0.95).round()}');
  }

  saveFirebaseWorkoutData() {
    FireStoreProvider.instance.saveFirebaseWorkoutData(
        context: context,
        userData: aGeneralBloc.currentUser,
        watts: wattsValue,
        resistance: resistenceValue,
        calories: caloriesValue,
        cadence: arrCadence.last,
        activeMinutes: arrCadence.length /
            60, // any of lenght array , becasue that is added in sec.
        onSuccess: (Map<String, dynamic> successResponse) {
          print(successResponse);
          aGeneralBloc.updateAPICalling(false);
          _goToWorkOutCompleteScreen();
        },
        onError: (Map<String, dynamic> errorResponse) {
          print(errorResponse);
        });
  }

  Widget chartView(List<int> data) {
    return Container(
      child: charts.LineChart(_createData(),
          defaultRenderer: charts.LineRendererConfig(
            includePoints: true,
            includeArea: true,
            radiusPx: 2,
            areaOpacity: 0.05,
            roundEndCaps: true,
          ),
          customSeriesRenderers: [
            charts.PointRendererConfig(
                customRendererId: 'customPoint', strokeWidthPx: 2)
          ],
          primaryMeasureAxis: charts.NumericAxisSpec(
              renderSpec: charts.NoneRenderSpec(),
              tickProviderSpec:
                  charts.BasicNumericTickProviderSpec(desiredTickCount: 0),
              showAxisLine: false),
          domainAxis: charts.NumericAxisSpec(
            showAxisLine: false,
            renderSpec: charts.NoneRenderSpec(),
            tickProviderSpec:
                new charts.BasicNumericTickProviderSpec(desiredTickCount: 0),
          ),
          animate: false),
    );
  }
}

class LinearWorkout {
  final int second;
  final int workoutData;

  LinearWorkout(this.second, this.workoutData);
}
