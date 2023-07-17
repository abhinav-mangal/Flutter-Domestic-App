import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/screens/bluetoothConnectivity/bluetoothbloc.dart';
import 'package:energym/screens/workout/complete_workout.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/slider_button.dart';
import 'package:energym/utils/common/stop_watch_timer.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// This is Hit my daily goal live workout screen contains calories goal
class LiveHitMyDailyGoalWorkout extends StatefulWidget {
  static const String routeName = '/LiveHitMyDailyGoalWorkout';

  @override
  _LiveHitMyDailyGoalWorkoutState createState() =>
      _LiveHitMyDailyGoalWorkoutState();
}

class _LiveHitMyDailyGoalWorkoutState extends State<LiveHitMyDailyGoalWorkout> {
  AppConfig? _config;
  UserModel? _currentUser;
  APIProvider? _api;

  late BluetoothDevice? connectedDevice;
  final BluetoothBloc _blocBluetooth = BluetoothBloc();

  List<int> arrWatts = [];
  List<int> arrCalories = [];
  List<int> arrCadence = [];
  List<int> arrAvgWatts = [];
  List<int> arrResistence = [];
  List<LinearWorkout> arrCaloriesChart = [];
  int caloriesValue = 0;

  double sweatCoinRewarded = 0;

  double spentMin = 0;
  bool isTimerDone = false;

  StopWatchTimer _stopWatchTimer = StopWatchTimer();
  ValueNotifier<double> _notifySliderValue = ValueNotifier<double>(0);
  var list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  @override
  void initState() {
    super.initState();

    _stopWatchTimer = StopWatchTimer(
      // mode: StopWatchMode.countUp,
      onChange: (int value) {
        final displayTime = StopWatchTimer.getDisplayTime(
          value,
        );
        final hrs = StopWatchTimer.getDisplayTimeHours(value) * 60;
        final minute = StopWatchTimer.getDisplayTimeMinute(value);
        final second =
            double.parse(StopWatchTimer.getDisplayTimeSecond(value)) / 60;

        spentMin = double.parse(hrs) + double.parse(minute) + second;
        aGeneralBloc.updateWorkoutTimer(displayTime);
      },
    );

    _currentUser = aGeneralBloc.currentUser;
    _api = APIProvider.of(context);
    connectedDevice = aGeneralBloc.getSelectedBike();
    _blocBluetooth.discoverCharacteristics(connectedDevice!);

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
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
          child: Column(
            children: <Widget>[
              _getAppBar(),
              _widgetTimter(),
              _widgetFTMSValues(),
              // Expanded(
              //   child:
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: _circleGraph(),
              ),
              // ),

              _resistanceLevel(context),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: _widgetGraph(),
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 10),
              //   child: _slideButton(),
              // ),
            ],
          ),
        ),
      )),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: _slideButton(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
    _notifySliderValue.dispose();
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(
      context,
      _config!,
      backgoundColor: Colors.transparent,
      textColor: _config!.whiteColor,
      title: AppConstants.liveWorkout,
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
          }
          return Text(time,
              style: _config!.antonioHeading1FontStyle
                  .apply(color: AppColors.orangeworkout),
              textAlign: TextAlign.center);
        });
  }

  Widget _widgetFTMSValues() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
      child: Column(
        children: [
          StreamBuilder<BluetoothCharacteristic?>(
            stream: _blocBluetooth.streamCharValue,
            builder: (context, snapshotBluetoothCharacteristic) {
              if (snapshotBluetoothCharacteristic.hasData &&
                  snapshotBluetoothCharacteristic.data != null) {
                return StreamBuilder<List<int>>(
                  stream: snapshotBluetoothCharacteristic.data?.value,
                  initialData: snapshotBluetoothCharacteristic.data?.lastValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      List<int> arrExerciseData = _blocBluetooth
                          .dataParserAndCalculation(snapshot.data!);

                      // 0 index for cadence
                      // 1 index for resistence
                      // 2 index for watts
                      // 3 index for Av. watts
                      // 4 index for calories

                      arrCadence.add(arrExerciseData[0]);
                      arrWatts.add(arrExerciseData[2]);
                      arrAvgWatts.add(arrExerciseData[3]);
                      arrCalories.add(arrExerciseData[4]);
                      arrResistence.add(arrExerciseData[1]);

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Column(
                              children: [
                                Text(
                                    arrWatts.length > 0
                                        ? arrWatts.last.toString()
                                        : '0',
                                    style: _config!.antonio36FontStyle
                                        .copyWith(fontSize: 30)),
                                Text(AppConstants.watts.toUpperCase(),
                                    style: _config!.abelNormalFontStyle),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Column(
                              children: [
                                Text(arrAvgWatts.last.toString(),
                                    style: _config!.antonio36FontStyle
                                        .copyWith(fontSize: 30)),
                                Text(AppConstants.avwatts.toUpperCase(),
                                    style: _config!.abelNormalFontStyle),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Column(
                              children: [
                                Text(arrCadence.last.toString(),
                                    style: _config!.antonio36FontStyle
                                        .copyWith(fontSize: 30)),
                                Text(AppConstants.rpm.toUpperCase(),
                                    style: _config!.abelNormalFontStyle),
                              ],
                            ),
                          ),
                        ],
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
        ],
      ),
    );
  }

  Widget _circleGraph() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            showLabels: false,
            showTicks: false,
            startAngle: 270,
            endAngle: 270,
            maximum: (_currentUser!.calorieGoal ?? 0).toDouble(),
            axisLineStyle: const AxisLineStyle(
              thickness: 0.10,
              color: Colors.transparent,
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            pointers: <GaugePointer>[
              RangePointer(
                value: (_currentUser!.calorieGoal ?? 0).toDouble(),
                width: 0.10,
                sizeUnit: GaugeSizeUnit.factor,
                cornerStyle: CornerStyle.bothCurve,
                enableAnimation: true,
                gradient: SweepGradient(
                  colors: [
                    Colors.black,
                    AppColors.orangeworkout,
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
                      Text(
                        '${arrCalories.last} / ${(_currentUser!.calorieGoal ?? 0).toDouble().toStringAsFixed(0)}',
                        style: _config!.antonio36FontStyle
                            .copyWith(fontSize: 24)
                            .apply(fontSizeFactor: 0.8),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          AppConstants.calGoal.toUpperCase(),
                          style: _config!.abelNormalFontStyle
                              .copyWith(fontSize: 12),
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
    ;
  }

  Widget _resistanceLevel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        // color: Colors.red,
        child: Column(
          children: [
            Text(
              AppConstants.resistanceLevel.toUpperCase(),
              style: _config!.abelNormalFontStyle,
            ),
            ValueListenableBuilder<double>(
                valueListenable: _notifySliderValue,
                builder: (BuildContext? context, value, child) {
                  return NeumorphicSlider(
                    sliderHeight: 20,
                    min: 1,
                    max: 10,
                    value: value,
                    thumb: Image.asset(
                      ImgConstants.sliderThumb,
                      width: 40,
                      height: 40,
                    ),
                    style: SliderStyle(
                      depth: 1.5,
                      variant: AppColors.orangeworkout,
                      accent: Colors.black,
                      thumbBorder: NeumorphicBorder(
                        width: 10,
                      ),
                    ),
                    onChangeEnd: (value) {
                      _blocBluetooth.writeData(context!, 0x04, 5);
                    },
                    onChanged: (value) {
                      _notifySliderValue.value =
                          double.parse(value.toStringAsFixed(0));
                    },
                  );
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var item in list)
                  Text(
                    '$item',
                    style: _config!.abelNormalFontStyle,
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _widgetGraph() {
    return StreamBuilder<BluetoothCharacteristic?>(
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
                caloriesValue = arrExerciseData[4];
                print(caloriesValue);
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _config!.borderColor),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          // chart
                          width: double.infinity,
                          child: AspectRatio(
                            aspectRatio: 343 / 170,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    AppConstants.calories.toUpperCase(),
                                    style: _config!.abelNormalFontStyle
                                        .copyWith(color: Colors.grey),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(left: 5),
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: chartView([caloriesValue]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SizedBox();
            },
          );
        }
        return SizedBox();
      },
    );
  }

  List<charts.Series<LinearWorkout, int>> _createData() {
    List<LinearWorkout> data = [];

    arrCaloriesChart
        .add(LinearWorkout((arrCaloriesChart.length), caloriesValue));
    data = arrCaloriesChart;
    return [
      new charts.Series<LinearWorkout, int>(
        id: '',
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(AppColors.orangeworkout),
        domainFn: (LinearWorkout data, _) => data.second,
        measureFn: (LinearWorkout data, _) => data.workoutData,
        data: data,
      ),
      new charts.Series<LinearWorkout, int>(
        id: '',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.white),
        fillColorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(AppColors.orangeworkout),
        domainFn: (LinearWorkout data, _) => data.second,
        measureFn: (LinearWorkout data, _) => data.workoutData,
        data: data,
      )..setAttribute(charts.rendererIdKey, 'customPoint'),
    ];
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

  Widget _slideButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: SliderButton(
        action: () {
          ///Do something here OnSlide
          // saveData();
        },

        ///Put label over here
        label: Text(
          AppConstants.completeMyWorkout,
          style:
              _config!.linkLargeFontStyle.apply(color: AppColors.orangeworkout),
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
        buttonColor: AppColors.orangeworkout,
        backgroundColor: AppColors.orangeworkout.withOpacity(0.2),
        highlightedColor: AppColors.orangeworkout.withOpacity(0.5),
        baseColor: AppColors.orangeworkout,
      ),
    );
  }

  // Save workout data in firebase and
  void saveData() {
    _blocBluetooth.streamCharValue.drain();
    _blocBluetooth.bleCharacteristic?.value.drain();
    _blocBluetooth.bleCharacteristic!.setNotifyValue(false);
    aGeneralBloc.updateAPICalling(true);

    // Generate Sweatcoin
    sweatCoinRewarded = _blocBluetooth.generateSweatCoin(
        arrAvgWatts.last, spentMin, _currentUser?.ftpValue ?? 0);

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

      // Create Sweatcoin transaction in firebase
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

  // Update workout data into user table in firebase
  void updateUserWorkoutData() {
    UserModel? currenrtUser = aGeneralBloc.currentUser;

    final Map<String, dynamic> _neetToStoreData = <String, dynamic>{};

    _neetToStoreData[UserCollectionField.resistence] =
        (currenrtUser?.resistence ?? 0) + arrResistence.last;

    _neetToStoreData[UserCollectionField.watts] =
        (currenrtUser?.watts ?? 0) + arrWatts.last;

    _neetToStoreData[UserCollectionField.calories] =
        (currenrtUser?.calories ?? 0) + arrCalories.last;

    _neetToStoreData[UserCollectionField.cadence] =
        (currenrtUser?.cadence ?? 0) + arrCadence.last;

    final workoutCount = (currenrtUser?.workoutCount ?? 0) + 1;

    _neetToStoreData[UserCollectionField.workoutCount] =
        (currenrtUser?.workoutCount ?? 0) + 1;

    double ftpCalculation = arrAvgWatts.last / (_currentUser!.ftpValue!);

    double ftpCalculationmultiply = ftpCalculation * 100;

    _neetToStoreData[UserCollectionField.ftpLeaderboard] =
        int.parse('${ftpCalculationmultiply.toStringAsFixed(0)}');

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

  // Save workout data into firebase
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
}

class LinearWorkout {
  final int second;
  final int workoutData;

  LinearWorkout(this.second, this.workoutData);
}
