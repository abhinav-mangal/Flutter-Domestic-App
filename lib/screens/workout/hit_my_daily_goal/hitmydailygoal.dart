import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/loader_button.dart';
import 'package:energym/screens/AnimationCounter/animation_counter.dart';
import 'package:energym/screens/bluetoothConnectivity/bluetoothConnectivity.dart';
import 'package:energym/screens/dashboard/dashboard_bloc.dart';
import 'package:energym/screens/workout/green_zone/livecalibrationworkout.dart';
import 'package:energym/screens/workout/hit_my_daily_goal/hitmydailygoaledit.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/helpers/health_provider.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HitMyDailyGoal extends StatefulWidget {
  const HitMyDailyGoal({Key? key}) : super(key: key);
  static const String routeName = '/HitMyDailyGoal';

  @override
  _HitMyDailyGoalState createState() => _HitMyDailyGoalState();
}

class _HitMyDailyGoalState extends State<HitMyDailyGoal> {
  AppConfig? _config;
  UserModel? _currentUser;
  final DashboardBloc _blocDashboard = DashboardBloc();
  ValueNotifier<int> _notifierWorkoutCalories = ValueNotifier<int>(0);
  @override
  void initState() {
    super.initState();
    _currentUser = aGeneralBloc.currentUser;

    _getCaloriesData(0); // for today
    _getCaloriesFromWorkout(0); // for today
  }

  @override
  void dispose() {
    super.dispose();
    _notifierWorkoutCalories.dispose();
    _blocDashboard.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            _topText(),
            _staticCalories(),
            _targetedCalories(),
            Expanded(child: circularGraph()),
            _btnEditGoal(),
            _btnStartWorkout(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _config,
        backgoundColor: Colors.transparent,
        elevation: 0,
        // isBackEnable: true,
        isBackEnable: false,
        onBack: () {},
        leadingWidget: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 24,
            color: AppColors.orangeworkout,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        // textColor: AppColors.orangeworkout,
        widget: btnPairing(context, (isConnectedDevice) {
          if (isConnectedDevice) {
            // pop up
            // bottomSheet(context);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlueToothConnectivityVC(),
              ),
            );
          }
        }),
        actions: <Widget>[
          btnSweatCointBalance(context, _config!),
        ]);
  }

  Widget _topText() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5),
      child: Text(
        AppConstants.hitmydailygoal.toUpperCase(),
        style:
            _config!.antonio36FontStyle.apply(color: AppColors.orangeworkout),
      ),
    );
  }

  Widget _staticCalories() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        AppConstants.calGoal,
        style:
            _config!.antonioHeading2FontStyle.apply(color: _config!.whiteColor),
      ),
    );
  }

  Widget _targetedCalories() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: StreamBuilder<double?>(
        stream: _blocDashboard.caloriesData,
        builder: (BuildContext context, AsyncSnapshot<double?> snapshot) {
          if (snapshot.hasData) {
            double? calories = snapshot.data;
            return ValueListenableBuilder<int>(
                valueListenable: _notifierWorkoutCalories,
                builder: (BuildContext? context, sumData, child) {
                  final sumCalories = sumData +
                      double.parse(((snapshot.data ?? 0).toStringAsFixed(2)));
                  return RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: '${sumCalories.toStringAsFixed(0)}',
                      style: _config!.antonio36FontStyle.apply(
                        color: _config!.orangeColor,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' / ${_currentUser?.calorieGoal}',
                          style: _config!.antonio36FontStyle.apply(
                            color: _config!.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  );
                });
          }
          return SizedBox();
        },
      ),
    );
  }

  Widget circularGraph() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        width: MediaQuery.of(context).size.height * 0.30,
        color: Colors.transparent,
        child: StreamBuilder<double?>(
          stream: _blocDashboard.caloriesData,
          builder: (BuildContext context, AsyncSnapshot<double?> snapshot) {
            if (snapshot.hasData) {
              double? calories = snapshot.data;
              return ValueListenableBuilder<int>(
                  valueListenable: _notifierWorkoutCalories,
                  builder: (BuildContext? context, sumData, child) {
                    final sumCalories = sumData +
                        double.parse(((snapshot.data ?? 0).toStringAsFixed(2)));
                    return SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          showLabels: false,
                          showTicks: false,
                          startAngle: 270,
                          endAngle: 270,
                          maximum:
                              double.parse('${_currentUser!.calorieGoal!}'),
                          axisLineStyle: AxisLineStyle(
                            thickness: 0.12,
                            //cornerStyle: CornerStyle.bothCurve,
                            color: _config!.darkGreyColor,
                            thicknessUnit: GaugeSizeUnit.factor,
                          ),
                          pointers: <GaugePointer>[
                            // RangePointer(
                            //   value: 1234,
                            //   width: 0.20,
                            //   sizeUnit: GaugeSizeUnit.factor,
                            //   color: _config!.greyColor,
                            //   cornerStyle: CornerStyle.bothCurve,
                            //   enableAnimation: true,
                            // ),
                            RangePointer(
                              value: sumCalories,
                              width: 0.12,
                              sizeUnit: GaugeSizeUnit.factor,
                              color: _config!.orangeColor,
                              cornerStyle: CornerStyle.bothCurve,
                              enableAnimation: true,
                            ),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              positionFactor: 0.0,
                              angle: 90,
                              widget: Text(
                                '${sumCalories.toStringAsFixed(0)} / ${_currentUser!.calorieGoal!}',
                                style: _config!.antonioHeading2FontStyle.apply(
                                  color: _config!.whiteColor,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    );
                  });
            }
            return SizedBox();
          },
        ),
      ),
    );
  }

  Widget _btnEditGoal() {
    return Container(
      padding: EdgeInsets.only(bottom: 10, left: 30, right: 30, top: 30),
      // color: Colors.red,
      width: double.infinity,
      height: 110,
      child: LoaderButton(
        isOutLine: true,
        outLineColor: AppColors.orangeworkout,
        radius: 15,
        onPressed: () async {
          UserModel? userModel = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditGoal(),
            ),
          );
          print('temp ${userModel}');
          setState(() {
            _currentUser = userModel;
          });
        },
        title: AppConstants.editgoal,
        titleStyle: _config!.antonio48FontStyle
            .apply(color: AppColors.orangeworkout, fontSizeFactor: 0.5),
      ),
    );
  }

  Widget _btnStartWorkout() {
    return Container(
      padding: EdgeInsets.only(bottom: 50, left: 30, right: 30),
      // color: Colors.red,
      width: double.infinity,
      height: 120,
      child: LoaderButton(
        isOutLine: true,
        outLineColor: AppColors.orangeworkout,
        radius: 15,
        onPressed: () {
          Navigator.popAndPushNamed(
            context,
            AnimationCounter.routeName,
            arguments: AnimationCounterArgs(
                isLiveCalibration: false,
                mins: globalMins,
                isBuildworkout: false,
                isHitMyDailyGoal: true),
          );
        },
        title: AppConstants.startWorkout.toUpperCase(),
        titleStyle: _config!.antonio48FontStyle
            .apply(color: AppColors.orangeworkout, fontSizeFactor: 0.5),
      ),
    );
  }

  Future<void> _getCaloriesData(int index) async {
    _blocDashboard.addHealthkitCalories(0);
    double? caloriesData =
        await HealthProvider.instance.getHealthkitCalories(index) ?? 0;
    print('calories = in ${caloriesData}');
    _blocDashboard.addHealthkitCalories(caloriesData);
  }

  Future<void> _getCaloriesFromWorkout(int index) async {
    _notifierWorkoutCalories.value = 0;
    await _blocDashboard.getWorkout(context, index: index);
    _notifierWorkoutCalories.value =
        _blocDashboard.workoutCalories.valueWrapper?.value ?? 0;
    print(_notifierWorkoutCalories.value);
  }
}
