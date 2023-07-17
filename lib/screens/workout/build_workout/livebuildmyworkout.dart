import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/loader_button.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/screens/bluetoothConnectivity/bluetoothbloc.dart';
import 'package:energym/screens/workout/complete_workout.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/dotted_line.dart';
import 'package:energym/utils/common/slider_button.dart';
import 'package:energym/utils/common/stop_watch_timer.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/helpers/routing/router.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:charts_common/common.dart' as commonCharts;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

int? globalMins;

// This is live workout screen for Build your workout
// Contains Watts, Av. watts, rpm, cals
// Zones
// per calaulated graph based on FTP
class LiveBuildWorkoutArgs extends RoutesArgs {
  LiveBuildWorkoutArgs({required this.mins, this.index})
      : super(isHeroTransition: true);
  final int? mins;
  final int? index;
}

class LiveBuildWorkout extends StatefulWidget {
  const LiveBuildWorkout({Key? key, required this.mins, this.index})
      : super(key: key);
  static const String routeName = '/LiveBuildWorkout';
  final int? mins;
  final int? index;
  @override
  _LiveBuildWorkoutState createState() => _LiveBuildWorkoutState();
}

class _LiveBuildWorkoutState extends State<LiveBuildWorkout> {
  AppConfig? _config;
  UserModel? _currentUser;
  APIProvider? _api;
  int? _index;
  late BluetoothDevice? connectedDevice;
  final BluetoothBloc _blocBluetooth = BluetoothBloc();

  List<int> arrWatts = [];
  List<int> arrCalories = [];
  List<int> arrCadence = [];
  List<int> arrAvgWatts = [];

  double sweatCoinRewarded = 0;

  int? _mins;
  bool isTimerDone = false;

  StopWatchTimer _stopWatchTimer = StopWatchTimer();

  double differenceMaxValue = 10;

  final BehaviorSubject<double> _streamCharValue = BehaviorSubject<double>();
  ValueStream<double> get streamCharValue => _streamCharValue.stream;
  double initValue = 0;

  double percentageToBeFilled = 0;
  int _currentZone = 0;

  ScrollController _scrollController = ScrollController();
  int value = 40;
  int barWidth = 40;

  List<FTPValues> arrGraphToDisplay = [];
  ValueNotifier<int> _notifierResistance = ValueNotifier<int>(0);

  // Just values , nothing esle
  double intZone1 = 100;
  double intZone2 = 150;
  double intZone3 = 200;
  double intZone4 = 250;
  double intZone5 = 300;

  @override
  void initState() {
    super.initState();

    _mins = widget.mins;
    _index = widget.index;

    _stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: StopWatchTimer.getMilliSecFromMinute(_mins ?? 0),
      onChange: (int value) {
        final displayTime = StopWatchTimer.getDisplayTime(value);

        aGeneralBloc.updateWorkoutTimer(displayTime);
      },
    );
    connectedDevice = aGeneralBloc.getSelectedBike();
    _blocBluetooth.discoverCharacteristics(connectedDevice!);

    _currentUser = aGeneralBloc.currentUser;
    _api = APIProvider.of(context);

    _setupGraphData();

    Future.delayed(
      Duration(microseconds: 200),
      () {
        _scrollController.animateTo(
          value.toDouble(),
          curve: Curves.linear,
          duration: Duration(minutes: _mins!),
        );
      },
    );
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
          child: Container(
        // color: Colors.red,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _getAppBar(),
                    const SizedBox(
                      height: 0,
                    ),
                    Text(AppConstants.liveWorkout,
                        style: TextStyle(
                            fontFamily: _config!.fontFamilyAntonio,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
                            color: Colors.white),
                        textAlign: TextAlign.center),
                    _widgetTimter(),
                    _widgetFTMSValues(),
                    _btnResistanceLevelUp(),
                    Text(
                      AppConstants.resistanceLevel.toUpperCase(),
                      style: _config!.abelNormalFontStyle,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: _zoneCircle(),
                    ),
                    _btnResistanceLevelDown(),
                    // Stack(
                    //   alignment: Alignment.centerLeft,
                    //   children: [
                    Container(
                      // color: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        child: _barChartView(),
                      ),
                    ),
                    // Container(
                    //   color: Colors.purple,
                    //   width: 40,
                    //   height: 100,
                    //   child: Column(
                    //     children: [
                    //       Container()
                    //     ],
                    //   ),
                    // )
                    //   ],

                    // ),
                  ],
                ),
              ),
            ),
            // _slideButton()
          ],
        ),
      )),
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
      // title: AppConstants.liveWorkout,
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

  Widget _btnResistanceLevelUp() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 5),
      child: Container(
        width: 150,
        child: LoaderButton(
          isOutLine: true,
          outLineColor: _config!.btnPrimaryColor,
          radius: 8,
          onPressed: () {
            // Write Resistance in ESP
            _notifierResistance.value++;
            print(_notifierResistance.value);
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
      padding: const EdgeInsets.only(top: 0, bottom: 20),
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

  Widget _widgetFTMSValues() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                  children: [
                    Container(
                      child: StreamBuilder<BluetoothCharacteristic?>(
                        stream: _blocBluetooth.streamCharValue,
                        builder: (context, snapshotBluetoothCharacteristic) {
                          if (snapshotBluetoothCharacteristic.hasData &&
                              snapshotBluetoothCharacteristic.data != null) {
                            return StreamBuilder<List<int>>(
                              stream:
                                  snapshotBluetoothCharacteristic.data?.value,
                              initialData: snapshotBluetoothCharacteristic
                                  .data?.lastValue,
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  List<int> arrExerciseData = _blocBluetooth
                                      .dataParserAndCalculation(snapshot.data!);
                                  // 0 index for cadence
                                  // 1 index for resistence
                                  // 2 index for watts

                                  arrWatts.add(arrExerciseData[2]);
                                  setupZones();
                                  return Text(
                                      arrWatts.length > 0
                                          ? arrWatts.last.toString()
                                          : '0',
                                      style: _config!.antonio36FontStyle);
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
                    Text(AppConstants.watts.toUpperCase(),
                        style: _config!.abelNormalFontStyle),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                  children: [
                    StreamBuilder<BluetoothCharacteristic?>(
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
                                List<int> arrExerciseData = _blocBluetooth
                                    .dataParserAndCalculation(snapshot.data!);
                                // 0 index for cadence
                                // 1 index for resistence
                                // 2 index for watts

                                arrAvgWatts.add(arrExerciseData[3]);

                                return Text(arrAvgWatts.last.toString(),
                                    style: _config!.antonio36FontStyle);
                              } else {
                                return Container();
                              }
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    Text(AppConstants.avwatts.toUpperCase(),
                        style: _config!.abelNormalFontStyle),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                  children: [
                    StreamBuilder<BluetoothCharacteristic?>(
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
                                List<int> arrExerciseData = _blocBluetooth
                                    .dataParserAndCalculation(snapshot.data!);
                                // 0 index for cadence
                                // 1 index for resistence
                                // 2 index for watts

                                arrCadence.add(arrExerciseData[0]);

                                return Text(arrCadence.last.toString(),
                                    style: _config!.antonio36FontStyle);
                              } else {
                                return Container();
                              }
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    Text(AppConstants.rpm.toUpperCase(),
                        style: _config!.abelNormalFontStyle),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                  children: [
                    StreamBuilder<BluetoothCharacteristic?>(
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
                                List<int> arrExerciseData = _blocBluetooth
                                    .dataParserAndCalculation(snapshot.data!);
                                // 0 index for cadence
                                // 1 index for resistence
                                // 2 index for watts

                                arrCalories.add(arrExerciseData[4]);

                                return Text(arrCalories.last.toString(),
                                    style: _config!.antonio36FontStyle);
                              } else {
                                return Container();
                              }
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    Text(AppConstants.cals.toUpperCase(),
                        style: _config!.abelNormalFontStyle),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _zoneCircle() {
    return StreamBuilder<double>(
        stream: streamCharValue,
        builder: (context, snapshot) {
          if (snapshot.data != null && snapshot.hasData) {
            return Container(
              padding: EdgeInsets.zero,
              height: MediaQuery.of(context).size.height * 0.3,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    showLabels: false,
                    showTicks: false,
                    startAngle: 270,
                    endAngle: 270,
                    maximum: differenceMaxValue,
                    axisLineStyle: const AxisLineStyle(
                      thickness: 0.10,
                      color: Colors.transparent,
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: snapshot.data ?? 0.0,
                        width: 0.10,
                        sizeUnit: GaugeSizeUnit.factor,
                        cornerStyle: CornerStyle.bothCurve,
                        enableAnimation: true,
                        // color: _currentZone == 1
                        //     ? Colors.white
                        //     : _currentZone == 2
                        //         ? AppColors.blueworkout
                        //         : _currentZone == 3
                        //             ? Colors.yellow
                        //             : _currentZone == 4
                        //                 ? Colors.red
                        //                 : _config!.btnPrimaryColor,
                        gradient: SweepGradient(
                          colors: [
                            Colors.black,
                            if (_currentZone == 1)
                              Colors.white
                            else if (_currentZone == 2)
                              AppColors.blueworkout
                            else if (_currentZone == 3)
                              Colors.yellow
                            else if (_currentZone == 4)
                              Colors.red
                            else
                              _config!.btnPrimaryColor,
                          ],
                        ),
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        angle: 90,
                        widget: SizedBox(
                          height: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Text(
                                  '${percentageToBeFilled.toStringAsFixed(1)}%',
                                  style: _config!.abelNormalFontStyle,
                                ),
                              ),
                              Text(
                                'ZONE $_currentZone',
                                style: _config!.antonio36FontStyle,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: (_currentZone == 5)
                                    ? const SizedBox()
                                    : Text(
                                        'TARGET ZONE: ${_currentZone + 1}',
                                        style: _config!.abelNormalFontStyle,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            );
          }
          return SizedBox();
        });
  }

  Widget _barChartView() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Center(
            child: AnimatedAlign(
              alignment: Alignment.centerLeft,
              duration: const Duration(seconds: 10),
              child: Container(
                height: 200,
                width: value + MediaQuery.of(context).size.width - 80,
                // color: Colors.green,
                child: Center(
                  child: Container(
                    // color: Colors.red,
                    height: 200,
                    width: value.toDouble(),
                    child: _barChart(),
                  ),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            height: 200,
            child: const DottedLine(
              direction: Axis.vertical,
              lineLength: 200,
              lineThickness: 4.0,
              dashLength: 2.0,
              dashColor: Colors.white,
              dashRadius: 0.0,
              dashGapLength: 5.0,
              dashGapColor: Colors.transparent,
              dashGapRadius: 0.0,
            ),
          ),
        ),
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.center,
              colors: [Colors.black, Colors.black12],
            ),
          ),
        ),
      ],
    );
  }

  Widget _barChart() {
    return Container(
      height: 200,

      // color: Colors.purple,
      child: charts.BarChart(
        _data(),
        primaryMeasureAxis:
            const charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
        defaultRenderer: new charts.BarRendererConfig(
            maxBarWidthPx: barWidth,
            cornerStrategy: const charts.ConstCornerStrategy(0)),
        domainAxis: charts.OrdinalAxisSpec(
          scaleSpec: commonCharts.FixedPixelSpaceOrdinalScaleSpec(0),
          tickProviderSpec: charts.BasicOrdinalTickProviderSpec(),
        ),
        layoutConfig: charts.LayoutConfig(
          leftMarginSpec: charts.MarginSpec.fixedPixel(0),
          topMarginSpec: charts.MarginSpec.fixedPixel(0),
          rightMarginSpec: charts.MarginSpec.fixedPixel(0),
          bottomMarginSpec: charts.MarginSpec.fixedPixel(0),
        ),
      ),
    );
  }

  /// Create one series with sample hard coded data.
  List<charts.Series<FTPValues, String>> _data() {
    return [
      new charts.Series<FTPValues, String>(
        id: 'FTP Data',
        colorFn: (obj, _) => obj.zone == 1
            ? charts.ColorUtil.fromDartColor(Colors.white)
            : obj.zone == 2
                ? charts.ColorUtil.fromDartColor(AppColors.blueworkout)
                : obj.zone == 3
                    ? charts.ColorUtil.fromDartColor(Colors.yellow)
                    : obj.zone == 4
                        ? charts.ColorUtil.fromDartColor(Colors.red)
                        : charts.ColorUtil.fromDartColor(
                            _config!.btnPrimaryColor),
        domainFn: (obj, _) => obj.time,
        measureFn: (obj, _) => obj.ftp,
        data: arrGraphToDisplay,
      )
    ];
  }

  setUpGraphModel() {}

  Widget _slideButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: SliderButton(
        action: () {
          ///Do something here OnSlide
          saveData();
        },

        ///Put label over here
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

        //Put BoxShadow here
        boxShadow: const BoxShadow(
          color: Colors.black,
          blurRadius: 4,
        ),

        //Adjust effects such as shimmer and flag vibration here
        // shimmer: true,
        // vibrationFlag: true,
        buttonSize: 60,
        width: context.width - 32,

        ///Change All the color and size from here.
        // height: 60,
        // radius: 60/2,
        buttonColor: _config!.btnPrimaryColor,
        backgroundColor: _config!.btnPrimaryColor.withOpacity(0.2),
        highlightedColor: _config!.btnPrimaryColor.withOpacity(0.5),
        baseColor: _config!.btnPrimaryColor,
      ),
    );
  }

  // Save workout data and generate Sweatcoin
  void saveData() {
    _blocBluetooth.streamCharValue.drain();
    _blocBluetooth.bleCharacteristic?.value.drain();
    _blocBluetooth.bleCharacteristic!.setNotifyValue(false);
    aGeneralBloc.updateAPICalling(true);

    // Generate Sweatcoin
    sweatCoinRewarded = _blocBluetooth.generateSweatCoin(arrAvgWatts.last,
        double.parse(_mins!.toStringAsFixed(0)), _currentUser?.ftpValue ?? 0);

    _api!.addRewardToUaser(context,
        amount: sweatCoinRewarded,
        token: _currentUser!.sweatcoinId,
        description: '${arrWatts.last} ${AppConstants.watts}',
        onSuccess: (Response? response, Map<String, dynamic>? json) {
      json![TransactionCollectionField.userId] = _currentUser!.documentId;
      json[TransactionCollectionField.transactionEntryMode] =
          TransactionMode.credit;
      json[TransactionCollectionField.transactionEntryType] =
          TransactionType.earned;
      json[TransactionCollectionField.wattsGenerated] = arrWatts.last;
      json[TransactionCollectionField.status] = true;
      json[TransactionCollectionField.createdAt] = Timestamp.now();

      // Add Sweatcoin transaction in to Firebase
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

  void _goToWorkOutCompleteScreen() {
    Map<String, dynamic> data = {};
    data[WorkoutDataKey.wattsGenerated] = arrWatts.last.toDouble();
    data[WorkoutDataKey.caloriesBurned] = arrCalories.last;
    data[WorkoutDataKey.sweatCoinsEarned] = sweatCoinRewarded;
    data[WorkoutDataKey.milesCovered] = 0;

    Navigator.popAndPushNamed(context, CompleteWorkout.routeName,
        arguments: CompleteWorkoutArgs(workoutData: data));
  }

  // Update workout data in user table
  void updateUserWorkoutData() {
    UserModel? currenrtUser = aGeneralBloc.currentUser;

    final Map<String, dynamic> _neetToStoreData = <String, dynamic>{};
    _neetToStoreData[UserCollectionField.watts] =
        (currenrtUser?.watts ?? 0) + arrWatts.last;

    _neetToStoreData[UserCollectionField.ftpLeaderboard] =
        int.parse('${(arrAvgWatts.last / _currentUser!.ftpValue!) * 100}');

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

  // Save workout data on firebase
  saveFirebaseWorkoutData() {
    FireStoreProvider.instance.saveFirebaseWorkoutData(
        context: context,
        userData: aGeneralBloc.currentUser,
        watts: arrWatts.last,
        resistance: 0,
        calories: arrCalories.last,
        cadence: arrCadence.last,
        activeMinutes: 0, // any of lenght array , becasue that is added in sec.
        onSuccess: (Map<String, dynamic> successResponse) {
          print(successResponse);
          aGeneralBloc.updateAPICalling(false);
          _goToWorkOutCompleteScreen();
        },
        onError: (Map<String, dynamic> errorResponse) {
          print(errorResponse);
        });
  }

  // Set up zones values
  setupZones() {
    // FTP
    int ftp = _currentUser?.ftpValue ?? 0;
    int min = _mins ?? 0;
    int watts = arrWatts.last;

    // < or equal to 55%
    //≤  56-75%
    //≤ 76-90%
    //≤ 91-105%
    //106-150% +
    double range1 = ftp * 0.55;

    double range2of1 = ftp * 0.56;
    double range2of2 = ftp * 0.75;

    double range3of1 = ftp * 0.76;
    double range3of2 = ftp * 0.90;

    double range4of1 = ftp * 0.91;
    double range4of2 = ftp * 1.05;

    double range5of1 = ftp * 1.06;
    double range5of2 = ftp * 1.50;

    if (watts <= range1) {
      // Zone 1 (WHITE)
      differenceMaxValue = range1;
      initValue = range1;
      _currentZone = 1;
    } else if (watts <= range2of2 && watts >= range2of1) {
      // Zone 2 (BLUE)
      differenceMaxValue = range2of2 - range2of1;
      initValue = range2of1;
      _currentZone = 2;
    } else if (watts <= range3of2 && watts >= range3of1) {
      // Zone 3 (YELLOW)
      differenceMaxValue = range3of2 - range3of1;
      initValue = range3of1;
      _currentZone = 3;
    } else if (watts <= range4of2 && watts >= range4of1) {
      // Zone 4 (RED)
      differenceMaxValue = range4of2 - range4of1;
      initValue = range4of1;
      _currentZone = 4;
    } else if (watts >= range5of1) {
      // Zone 5 (GREEN)
      differenceMaxValue = range5of2 - range5of1;
      initValue = range5of1;
      _currentZone = 5;
    }

    double diff = (watts - initValue);
    // print('Difference ${diff}');
    percentageToBeFilled = diff / differenceMaxValue * 100;
    // print('differenceMaxValue ${differenceMaxValue}');
    // print('percentageToBeFilled ${diff / differenceMaxValue * 100}');
    _streamCharValue.sink.add(diff);
  }

  _setupGraphData() {
    switch (_index) {
      case 0:
        _climbConditionData();
        break;
      case 1:
        _pharaomonesData();
        break;
      case 2:
        _allPainsData();
        break;
      case 3:
        _holyHitData();
        break;
      case 4:
        _shedData();
        break;

      default:
    }
  }

  // Climb Condition workout graph logic
  _climbConditionData() {
    var min = _mins ?? 0;
    var ftp = _currentUser?.ftpValue ?? 0;
    var second = 4;
    List<GraphFTP> arrValues = [
      GraphFTP(((min * 0.25) * second).round(), intZone1, 1),
      GraphFTP(((min * 0.10) * second).round(), intZone2, 2),
      GraphFTP(((min * 0.10) * second).round(), intZone3, 3),
      GraphFTP(((min * 0.05) * second).round(), intZone1, 1),
      GraphFTP(((min * 0.10) * second).round(), intZone2, 2),
      GraphFTP(((min * 0.05) * second).round(), intZone5, 5),
      GraphFTP(((min * 0.05) * second).round(), intZone3, 3),
      GraphFTP(((min * 0.30) * second).round(), intZone1, 1),
    ];

    for (int i = 0; i < arrValues.length; i++) {
      for (int j = 0; j < arrValues[i].timePer; j++) {
        arrGraphToDisplay.add(
          FTPValues('${arrGraphToDisplay.length + 1}',
              arrValues[i].ftpValue.toInt(), arrValues[i].zone),
        );
      }
    }
    value = (arrGraphToDisplay.length * barWidth);

// "First 25% of workout time, rounded up to nearest minute: Zone 1
// Next 10%: Zone 2
// Next 10%: Zone 3
// Next 5%: Zone 1
// Next 10%: Zone 2
// Next 5%: Zone 5
// Next 5%: Zone 3
// Final 30%: Zone 1
  }

  // Pharaomones workout graph logic
  _pharaomonesData() {
    var min = _mins ?? 0;
    var ftp = _currentUser?.ftpValue ?? 0;
    var second = 4;
    List<GraphFTP> arrValues = [
      GraphFTP(((min * 0.20) * second).round(), intZone1, 1),
      GraphFTP(((min * 0.15) * second).round(), intZone2, 2),
      GraphFTP(((min * 0.07) * second).round(), intZone3, 3),
      GraphFTP(((min * 0.05) * second).round(), intZone4, 4),
      GraphFTP(((min * 0.02) * second).round(), intZone5, 5),
      GraphFTP(((min * 0.08) * second).round(), intZone4, 4),
      GraphFTP(((min * 0.01) * second).round(), intZone4, 3),
      GraphFTP(((min * 0.03) * second).round(), intZone5, 5),
      GraphFTP(((min * 0.01) * second).round(), intZone4, 4),
      GraphFTP(((min * 0.10) * second).round(), intZone2, 2),
      GraphFTP(((min * 0.20) * second).round(), intZone1, 1),
    ];

    for (int i = 0; i < arrValues.length; i++) {
      for (int j = 0; j < arrValues[i].timePer; j++) {
        arrGraphToDisplay.add(
          FTPValues('${arrGraphToDisplay.length + 1}',
              arrValues[i].ftpValue.toInt(), arrValues[i].zone),
        );
      }
    }
    value = arrGraphToDisplay.length * barWidth;

// First 20%: Zone 1
// Next 15%: Zone 2
//  Next 7%: Zone 3
// Next 5%: Zone 4
// Next 2%: Zone 5
// Next 8%: Zone 4
// Next 8%: Zone 3
// Next 1%: Zone 5
// Next 3%: Zone 4
// Next 1%: Zone 5
// Next 10 %: Zone 2
// Final 20%: Zone 1
  }

  // allPains workout graph logic
  _allPainsData() {
    _mins;
    _currentUser?.ftpValue;

    // From zone 3 to zone 5, switching every min
    var min = _mins ?? 0;
    var ftp = _currentUser?.ftpValue ?? 0;
    var second = 4;

    int zone = 3;
    int tempFTPZone = intZone3.toInt();
    for (int i = 0; i < min; i++) {
      for (int j = 0; j < 4; j++) {
        arrGraphToDisplay.add(
          FTPValues('${arrGraphToDisplay.length + 1}', tempFTPZone, zone),
        );
      }

      if (zone == 3) {
        zone = zone + 1;
        tempFTPZone = intZone4.toInt();
      } else if (zone == 4) {
        zone = zone + 1;
        tempFTPZone = intZone5.toInt();
      } else if (zone == 5) {
        zone = 3;
        tempFTPZone = intZone3.toInt();
      }
    }
    value = arrGraphToDisplay.length * barWidth;
  }

  // Holy Hit workout graph logic
  _holyHitData() {
// "First 25%: Zone 2
// Next 50%: From Zone 5 to Zone 1, switching every minute
// Final 25%: Zone 1
    var min = _mins ?? 0;
    var ftp = _currentUser?.ftpValue ?? 0;
    var second = 4;
    List<GraphFTP> arrValues = [
      GraphFTP(((min * 0.25) * second).round(), intZone2, 2),
    ];

    for (int i = 0; i < arrValues.length; i++) {
      for (int j = 0; j < arrValues[i].timePer; j++) {
        arrGraphToDisplay.add(
          FTPValues('${arrGraphToDisplay.length + 1}',
              arrValues[i].ftpValue.toInt(), arrValues[i].zone),
        );
      }
    }

// Next 50%: From Zone 5 to Zone 1, switching every minute
    int tempFTPZone = intZone5.toInt();
    int zone = 5;
    for (int i = 0; i < (min * 0.5); i++) {
      for (int j = 0; j < 4; j++) {
        arrGraphToDisplay.add(
          FTPValues('${arrGraphToDisplay.length + 1}', tempFTPZone, zone),
        );
      }

      if (zone == 5) {
        zone = zone - 1;
        tempFTPZone = intZone4.toInt();
      } else if (zone == 4) {
        zone = zone - 1;
        tempFTPZone = intZone3.toInt();
      } else if (zone == 3) {
        zone = zone - 1;
        tempFTPZone = intZone2.toInt();
      } else if (zone == 2) {
        zone = zone - 1;
        tempFTPZone = intZone1.toInt();
      } else if (zone == 1) {
        zone = 5;
        tempFTPZone = intZone5.toInt();
      }
    }

    // Final 25%: Zone 1
    List<GraphFTP> arrValues1 = [
      GraphFTP(((min * 0.25) * second).round(), intZone1, 1),
    ];

    for (int i = 0; i < arrValues1.length; i++) {
      for (int j = 0; j < arrValues1[i].timePer; j++) {
        arrGraphToDisplay.add(
          FTPValues('${arrGraphToDisplay.length + 1}',
              arrValues1[i].ftpValue.toInt(), arrValues1[i].zone),
        );
      }
    }
    value = arrGraphToDisplay.length * barWidth;
  }

  // Shed workout graph logic
  _shedData() {
    // First 25%:  Zone 2
    // Second 25%: Zone 3
    // Third 25% 20 seconds in zone 5, then 20 seconds zone 1 repeat
    // Final 25%: Zone 2

    var min = _mins ?? 0;
    var ftp = _currentUser?.ftpValue ?? 0;
    var second = 4;

    // First 25%:  Zone 2
    // Second 25%: Zone 3
    List<GraphFTP> arrValues = [
      GraphFTP(((min * 0.25) * second).round(), intZone2, 2),
      GraphFTP(((min * 0.25) * second).round(), intZone3, 3),
    ];

    for (int i = 0; i < arrValues.length; i++) {
      for (int j = 0; j < arrValues[i].timePer; j++) {
        arrGraphToDisplay.add(
          FTPValues('${arrGraphToDisplay.length + 1}',
              arrValues[i].ftpValue.toInt(), arrValues[i].zone),
        );
      }
    }

    // Third 25% 20 seconds in zone 5, then 20 seconds zone 1 repeat

    for (int i = 0; i < (min * 0.25); i++) {
      for (int j = 0; j < 3; j++) {
        if (j % 3 == 0 || j % 3 == 2) {
          arrGraphToDisplay.add(
            FTPValues('${arrGraphToDisplay.length + 1}', intZone5.toInt(), 5),
          );
        } else if (j % 3 == 1) {
          arrGraphToDisplay.add(
            FTPValues('${arrGraphToDisplay.length + 1}', intZone1.toInt(), 1),
          );
        }
      }
    }

    // Final 25%: Zone 2

    List<GraphFTP> arrValues1 = [
      GraphFTP(((min * 0.25) * second).round(), intZone2, 2),
    ];

    for (int i = 0; i < arrValues1.length; i++) {
      for (int j = 0; j < arrValues1[i].timePer; j++) {
        arrGraphToDisplay.add(
          FTPValues('${arrGraphToDisplay.length + 1}',
              arrValues1[i].ftpValue.toInt(), arrValues1[i].zone),
        );
      }
    }

    value = arrGraphToDisplay.length * barWidth;
  }
}

class LinearWorkout {
  final int second;
  final int workoutData;

  LinearWorkout(this.second, this.workoutData);
}

class FTPValues {
  final String time;
  final int ftp;
  final int zone;

  FTPValues(this.time, this.ftp, this.zone);
}

class GraphFTP {
  final int timePer;
  final double ftpValue;
  final int zone;

  GraphFTP(this.timePer, this.ftpValue, this.zone);
}
