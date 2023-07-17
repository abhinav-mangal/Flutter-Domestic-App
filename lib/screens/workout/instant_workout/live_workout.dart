import 'dart:io';
import 'dart:typed_data';

import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/screens/bluetoothConnectivity/bluetoothbloc.dart';
import 'package:energym/screens/workout/complete_workout.dart';
import 'package:energym/screens/workout/update_workout.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/controlbuttons.dart';
import 'package:energym/utils/common/slider_button.dart';
import 'package:energym/utils/common/stop_watch_timer.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:audio_session/audio_session.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// This is live workout screen, display live workout data
// Display graph and music
class LiveWorkout extends StatefulWidget {
  const LiveWorkout({Key? key}) : super(key: key);
  static const String routeName = '/LiveWorkout';

  @override
  _LiveWorkoutState createState() => _LiveWorkoutState();
}

class _LiveWorkoutState extends State<LiveWorkout> {
  AppConfig? _config;
  UserModel? _currentUser;
  APIProvider? _api;
  late BluetoothDevice? connectedDevice;
  final BluetoothBloc _blocBluetooth = BluetoothBloc();
  List<int> arrResistence = [];
  List<int> arrWatts = [];
  List<int> arrCalories = [];
  List<int> arrCadence = [];
  int avgWatts = 0;
  List<LinearWorkout> arrResistenceChart = [];
  List<LinearWorkout> arrWattsChart = [];
  List<LinearWorkout> arrCaloriesChart = [];
  List<LinearWorkout> arrCadenceChart = [];
  List<LinearWorkout> workoutdata = [];
  double sweatCoinRewarded = 0;
  double spentMin = 0;
  static int _nextMediaId = 0;
  AudioPlayer _player = AudioPlayer();
  final OnAudioQuery audioQuery = OnAudioQuery();
  var retriever = MetadataRetriever();
  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  StopWatchTimer _stopWatchTimer = StopWatchTimer();

  @override
  void initState() {
    super.initState();
    perrmission();

    connectedDevice = aGeneralBloc.getSelectedBike();

    _currentUser = aGeneralBloc.currentUser;

    _stopWatchTimer = StopWatchTimer(
      onChange: (int value) {
        final displayTime = StopWatchTimer.getDisplayTime(
          value,
        );

        aGeneralBloc.updateWorkoutTimer(displayTime);

        final hrs = StopWatchTimer.getDisplayTimeHours(value) * 60;
        final minute = StopWatchTimer.getDisplayTimeMinute(value);
        final second =
            double.parse(StopWatchTimer.getDisplayTimeSecond(value)) / 60;

        spentMin = double.parse(hrs) + double.parse(minute) + second;
      },
    );

    _api = APIProvider.of(context);

    Future.delayed(Duration(seconds: 0), () {
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    });

    _init();
    _blocBluetooth.discoverCharacteristics(connectedDevice!);
  }

  Future<void> _init() async {
    await audioQuery.permissionsRequest();
    await requestStoragePermission();
    await getAudioSourceList();

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream
        .listen((event) {}, onError: (Object e, StackTrace stackTrace) {});
    try {
      await _player.setAudioSource(_playlist);
    } catch (e, stackTrace) {}
  }

  // Bluetooth permission
  perrmission() async {
    await requestStoragePermission();
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
                  if (snapshot.hasData && snapshot.data != null) {
                    List<int> arrExerciseData =
                        _blocBluetooth.dataParserAndCalculation(snapshot.data!);
                    // 0 index for cadence
                    // 1 index for resistence
                    // 2 index for watts
                    // 3 index for calories

                    arrCadence.add(arrExerciseData[0]);
                    arrResistence.add(arrExerciseData[1]);
                    arrWatts.add(arrExerciseData[2]);
                    avgWatts = arrExerciseData[3];
                    arrCalories.add(arrExerciseData[4]);

                    _createData();

                    return Container(
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
                                Text(AppConstants.liveWorkout,
                                    style: TextStyle(
                                        fontFamily: _config!.fontFamilyAntonio,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 20,
                                        color: Colors.white),
                                    textAlign: TextAlign.center),
                                _widgetTimter(),
                                Expanded(child: _widgetWorkout()),
                                Expanded(child: _widgetGraph()),
                                const SizedBox(
                                  height: 0,
                                )
                              ],
                            ),
                          ),
                          _slideButton()
                        ],
                      ),
                    );
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    if (mounted) {
      _stopWatchTimer.dispose();

      _blocBluetooth.streamCharValue.drain();
      _blocBluetooth.bleCharacteristic?.value.drain();
      _blocBluetooth.bleCharacteristic!.setNotifyValue(false);
      _blocBluetooth.dispose();
      _player.dispose();
    }
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(
      context,
      _config!,
      backgoundColor: Colors.transparent,
      textColor: _config!.whiteColor,
      // title: AppConstants.liveWorkout,
      elevation: 0,
      isBackEnable: false,
      widget: btnPairing(
        context,
        (isConnectedDevice) {
          if (isConnectedDevice) {
          } else {}
        },
      ),
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
            return Column(
              children: [
                Container(
                  // chart
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: _config!.borderColor),
                  child: AspectRatio(
                    aspectRatio: 343 / 170,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, top: 10),
                          child: Text(
                              index == 1
                                  ? AppConstants.resistance.toUpperCase()
                                  : index == 2
                                      ? AppConstants.watts.toUpperCase()
                                      : index == 3
                                          ? AppConstants.calories.toUpperCase()
                                          : index == 4
                                              ? AppConstants.cadence
                                                  .toUpperCase()
                                              : '',
                              style: _config!.abelNormalFontStyle
                                  .copyWith(color: Colors.grey)),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 5),
                            width: double.infinity,
                            height: double.infinity,
                            child: PageView(
                                controller: pageController,
                                onPageChanged: (currentIndex) {
                                  print(currentIndex);
                                  _blocBluetooth.chartSelection(currentIndex);
                                },
                                children: [
                                  _musicView(),
                                  chartView(
                                      arrResistence, _config!.skyBlueColor),
                                  chartView(arrWatts, AppColors.greenColor),
                                  chartView(arrCalories, AppColors.darkRed),
                                  chartView(arrCadence, Colors.purple)
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  // Bottom dot view
                  height: 15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      bottomDots(index ?? 0, 0, AppColors.orangeworkout),
                      bottomDots(index ?? 0, 1, _config!.skyBlueColor),
                      bottomDots(index ?? 0, 2, AppColors.greenColor),
                      bottomDots(index ?? 0, 3, AppColors.darkRed),
                      bottomDots(index ?? 0, 4, Colors.purple),
                    ],
                  ),
                )
              ],
            );
          } else {
            return Container();
          }
        });
  }

  // List<charts.Series<LinearWorkout, int>> series = ;
  PageController pageController = PageController();

  // Live workout data set in array
  _createData() {
    int index = _blocBluetooth.intChartSelection.valueWrapper?.value ?? 0;

    arrResistenceChart
        .add(LinearWorkout(arrResistenceChart.length, arrResistence.last));
    arrWattsChart.add(LinearWorkout(arrWattsChart.length, arrWatts.last));
    arrCaloriesChart
        .add(LinearWorkout(arrCaloriesChart.length, arrCalories.last));
    arrCadenceChart.add(LinearWorkout(arrCadenceChart.length, arrCadence.last));
    // print('workoutdata ${arrResistence}');
    if (index == 1) {
      workoutdata = arrResistenceChart;
    } else if (index == 2) {
      workoutdata = arrWattsChart;
    } else if (index == 3) {
      workoutdata = arrCaloriesChart;
    } else if (index == 4) {
      workoutdata = arrCadenceChart;
    }
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
        onTap: () {
          pageController.jumpToPage(id);
        },
      ),
    );
  }

  Widget _widgetWorkout() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 30),
      child: Column(
        children: <Widget>[
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
                      child: _widgetResistance(),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: _widgetWatts(),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                      child: _widgetCalories(),
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
      onTap: () {
        Navigator.pushNamed(
          context,
          UpdateWorkout.routeName,
          arguments: UpdateWorkoutArgs(
            workoutValue: WorkoutType.resistance,
            value: arrResistence.last,
          ),
        );
      },
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
                          value: arrResistence.last.toDouble(),
                          width: 0.20,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: _config!.skyBlueColor,
                          cornerStyle: CornerStyle.bothCurve,
                        )
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            positionFactor: 0.0,
                            angle: 90,
                            widget: Text(
                              '${arrResistence.last}',
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
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(AppConstants.resistance,
                  style: _config!.paragraphNormalFontStyle
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
                          value: arrWatts.last.toDouble(),
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
                              '${arrWatts.last}',
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
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(AppConstants.watts,
                  style: _config!.paragraphNormalFontStyle
                      .apply(color: _config!.whiteColor),
                  textAlign: TextAlign.center),
            )
          ],
        ),
      ),
    );
  }

  Widget _widgetCalories() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // Navigator.pushNamed(
        //   context,
        //   UpdateWorkout.routeName,
        //   arguments: UpdateWorkoutArgs(
        //     workoutValue: WorkoutType.calories,
        //     value: arrCalories.last,
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
                tag: WorkoutType.calories,
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
                          value: arrCalories.last.toDouble(),
                          width: 0.20,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: _config!.orangeColor,
                          cornerStyle: CornerStyle.bothCurve,
                        )
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            positionFactor: 0.0,
                            angle: 90,
                            widget: Text(
                              '${arrCalories.last}',
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
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(AppConstants.calories,
                  style: _config!.paragraphNormalFontStyle
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
                          color: _config!.purpelColor,
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
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(AppConstants.cadence,
                  style: _config!.paragraphNormalFontStyle
                      .apply(color: _config!.whiteColor),
                  textAlign: TextAlign.center),
            )
          ],
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
          ///Do something here OnSlide
          // _blocBluetooth.dispose();
          _blocBluetooth.streamCharValue.drain();
          _blocBluetooth.bleCharacteristic?.value.drain();
          _blocBluetooth.bleCharacteristic!.setNotifyValue(false);
          aGeneralBloc.updateAPICalling(true);

          // Generate Sweatcoin
          sweatCoinRewarded = _blocBluetooth.generateSweatCoin(
              avgWatts, spentMin, _currentUser?.ftpValue ?? 0);

          // Sweatcoin transaction
          _api!.addRewardToUaser(context,
              amount: sweatCoinRewarded,
              token: _currentUser!.sweatcoinId,
              description: '${arrWatts.last} ${AppConstants.watts}',
              onSuccess: (Response? response, Map<String, dynamic>? json) {
            // Sweatcoin transaction success
            // Then create transaction into Firebase 'transaction' table

            json![TransactionCollectionField.userId] = _currentUser!.documentId;
            json[TransactionCollectionField.transactionEntryMode] =
                TransactionMode.credit;
            json[TransactionCollectionField.transactionEntryType] =
                TransactionType.earned;
            json[TransactionCollectionField.wattsGenerated] = arrWatts.last;
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

                // Jump to workout completed screen
                _goToWorkOutCompleteScreen();
              },
            );
          }, onError: (Response? response, Map<String, dynamic>? jsonData) {
            aGeneralBloc.updateAPICalling(false);

            // Jump to workout completed screen
            _goToWorkOutCompleteScreen();
          });
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

        buttonSize: 60,
        width: context.width - 32,
        buttonColor: _config!.btnPrimaryColor,
        backgroundColor: _config!.btnPrimaryColor.withOpacity(0.2),
        highlightedColor: _config!.btnPrimaryColor.withOpacity(0.5),
        baseColor: _config!.btnPrimaryColor,
      ),
    );
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
  void updateUserWorkoutData() async {
    UserModel? currenrtUser = aGeneralBloc.currentUser;

    final Map<String, dynamic> _neetToStoreData = <String, dynamic>{};

    _neetToStoreData[UserCollectionField.resistence] =
        (currenrtUser?.resistence ?? 0) + arrResistence.last;

    _neetToStoreData[UserCollectionField.watts] =
        (currenrtUser?.watts ?? 0) + arrWatts.last;

    var totelCalories = (currenrtUser?.calories ?? 0) + arrCalories.last;
    _neetToStoreData[UserCollectionField.calories] = totelCalories;

    _neetToStoreData[UserCollectionField.cadence] =
        (currenrtUser?.cadence ?? 0) + arrCadence.last;

    final workoutCount = (currenrtUser?.workoutCount ?? 0) + 1;

    _neetToStoreData[UserCollectionField.workoutCount] =
        (currenrtUser?.workoutCount ?? 0) + 1;

    double ftpCalculation = avgWatts / (_currentUser!.ftpValue!);

    double ftpCalculationmultiply = ftpCalculation * 100;

    _neetToStoreData[UserCollectionField.ftpLeaderboard] =
        int.parse('${ftpCalculationmultiply.toStringAsFixed(0)}');

    // _neetToStoreData
    //     .addAll(_blocBluetooth.checkLevel(totelCalories, _currentUser!));

    // Sednd push notification after 5 workout
    if ((workoutCount % 5) == 0) {
      await FireStoreProvider.instance.sendFcmNotification(
          _currentUser!,
          _currentUser!.documentId!,
          NotificationType.ftpReminder,
          _currentUser!.documentId!,
          null,
          null);
    }

    // Save workout data into user profile
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

  // Save workout dat into 'workout' table
  saveFirebaseWorkoutData() {
    FireStoreProvider.instance.saveFirebaseWorkoutData(
        context: context,
        userData: aGeneralBloc.currentUser,
        watts: arrWatts.last,
        resistance: arrResistence.last,
        calories: arrCalories.last,
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

  Widget chartView(List<int> data, Color color) {
    return Container(
      child: charts.LineChart([
        new charts.Series<LinearWorkout, int>(
          id: '',
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(color),
          domainFn: (LinearWorkout data, _) => data.second,
          measureFn: (LinearWorkout data, _) => data.workoutData,
          data: workoutdata,
        ),
        new charts.Series<LinearWorkout, int>(
          id: '',
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.white),
          fillColorFn: (_, __) => charts.ColorUtil.fromDartColor(color),
          domainFn: (LinearWorkout data, _) => data.second,
          measureFn: (LinearWorkout data, _) => data.workoutData,
          data: workoutdata,
        )..setAttribute(charts.rendererIdKey, 'customPoint'),
      ],
          customSeriesRenderers: [
            charts.PointRendererConfig(
                customRendererId: 'customPoint', strokeWidthPx: 2)
          ],
          defaultRenderer: charts.LineRendererConfig(
            includePoints: true,
            includeArea: true,
            radiusPx: 2,
            areaOpacity: 0.05,
            roundEndCaps: true,
          ),
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

  // This is request storage permission
  Future<void> requestStoragePermission() async {
    if (!kIsWeb) {
      var status = await Permission.storage.status;
      if (status.isDenied) {
        if (await Permission.storage.request().isGranted) {
          // Either the permission was already granted before or the user just granted it.
          print('Persmison added');
        }
        setState(() {});
        // We didn't ask for permission yet or the permission has been denied before but not permanently.
      } else if (status.isRestricted) {
        if (await Permission.storage.request().isGranted) {
          // Either the permission was already granted before or the user just granted it.
          print('Persmison added');
        }
        setState(() {});
      } else {
        setState(() {});
      }
    }
  }

  Widget _musicView() {
    return Padding(
      padding: const EdgeInsets.only(right: 5, top: 0, bottom: 5),
      child: Container(
        // color: Colors.red,
        child: StreamBuilder<SequenceState?>(
          stream: _player.sequenceStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state?.sequence.isEmpty ?? true) {
              return Center(
                child: Text(
                  AppConstants.noSongs,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            final metadata = state!.currentSource!.tag as MediaItem;

            return Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 10, top: 30, bottom: 30),
                    child: Center(
                      child: ClipRRect(
                        // borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          File((metadata.displaySubtitle ?? ImgConstants.logoR)
                              .toString()),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, top: 20, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Expanded(
                            child: Text(
                              metadata.album!,
                              maxLines: 1,
                              // softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: _config!.antonioHeading3FontStyle
                                  .apply(color: _config!.whiteColor),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            metadata.title,
                            maxLines: 1,
                            // softWrap: false,
                            overflow: TextOverflow.fade,
                            style: _config!.antonioHeading3FontStyle.apply(
                                color: _config!.whiteColor,
                                fontSizeFactor: 0.7),
                          ),
                        ),
                        ControlButtons(_player),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Get music from system in android and for ios fetch music from music library
  Future<void> getAudioSourceList() async {
    List<AudioSource> audioSourceList = [];

    List<SongModel> listSong = await audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.DESC_OR_GREATER,
        uriType: (Platform.isIOS) ? UriType.INTERNAL : UriType.EXTERNAL,
        ignoreCase: true);
    if (listSong.isNotEmpty) {
      _nextMediaId = 0;
      _playlist.clear();

      print("listSong ${listSong}");
      listSong.forEach((song) async {
        Uint8List? uint =
            await audioQuery.queryArtwork(song.id, ArtworkType.AUDIO);
        Metadata metadata = await MetadataRetriever.fromFile(File(song.data));

        File? imgFile;
        final tempDir = await getTemporaryDirectory();

        if (uint != null) {
          imgFile = await File('${tempDir.path}/image.png').create();
          imgFile.writeAsBytesSync(uint);
        }

        _playlist.add(AudioSource.uri(
          Uri.parse(song.uri!),
          tag: MediaItem(
            id: '${_nextMediaId++}',
            album: song.album ?? "--",
            title: song.title,
            displaySubtitle: imgFile?.path,
            artUri: imgFile?.uri ?? Uri.parse(ImgConstants.logoR),
          ),
        ));
      });
    }
  }
}

class LinearWorkout {
  final int second;
  final int workoutData;

  LinearWorkout(this.second, this.workoutData);
}
