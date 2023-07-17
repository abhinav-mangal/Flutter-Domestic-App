import 'dart:io';
import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/screens/dashboard/dashboard_bloc.dart';
import 'package:energym/screens/dashboard/graph_details.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/common/svg_picture_customise.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/helpers/health_provider.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  UserModel? _currentUser;
  AppConfig? _config;
  TabController? _tabController;
  APIProvider? _api;
  final DashboardBloc _blocDashboard = DashboardBloc();

  Future<double?>? futureCalories;
  ValueNotifier<int> _notifierWorkoutCalories = ValueNotifier<int>(0);
  ValueNotifier<int> _notifierWorkoutWatts = ValueNotifier<int>(0);
  ValueNotifier<double> _notifierWorkoutActiveMeniutes =
      ValueNotifier<double>(0);
  ValueNotifier<bool> _isChartHealthKitData = ValueNotifier<bool>(false);
  ValueNotifier<bool> _isChartWorkoutData = ValueNotifier<bool>(false);

  double calories = 0;
  double targetedCaloriesGoal = 0;
  List<WorkoutData> chartHealth = [];
  List<WorkoutData> chartWorkout = [];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    _api = APIProvider.of(context);
    aGeneralBloc.getLoginUserId();

    if (Platform.isAndroid) {
      // Actvity Recognition permission
      androidHelthPermission();
    }
    if (Platform.isIOS) {
      authHealthKitiOS();
    }
  }

  Future<void> androidHelthPermission() async {
    await Permission.activityRecognition.request();
    final status = await Permission.activityRecognition.status;
    if (status.isGranted) {
      print('activityRecognition');
      authHealthKit();
    }
  }

  authHealthKitiOS() async {
    bool access = await HealthProvider.instance.getHealthKitauth();
    print(access);
    if (access) {
      dataDisplyAfterHealthKitAuth();
    }
  }

  authHealthKit() async {
    HealthProvider.instance;
    aGeneralBloc.commonNotifire.addListener(() {
      dataDisplyAfterHealthKitAuth();
    });

    dataDisplyAfterHealthKitAuth();
  }

  dataDisplyAfterHealthKitAuth() {
    aGeneralBloc.updateAPICalling(true);

    _getHealthkitCalWeekWise();
    _getCaloriesData(0);
    _getWorkoutList();
    _getCaloriesFromWorkout(0);
    _getWattsFromWorkout(0);
    _getActiveMinutesFromWorkout(0);

    aGeneralBloc.updateAPICalling(false);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
    _notifierWorkoutCalories.dispose();
    _notifierWorkoutWatts.dispose();
    _notifierWorkoutActiveMeniutes.dispose();
    _isChartHealthKitData.dispose();
    _isChartWorkoutData.dispose();
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
          aGeneralBloc.getCurrentSweatCoinUser(_api, context);
        }

        return CustomScaffold(
          resizeToAvoidBottomInset: false,
          appBar: _getAppBar(),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            child: _mainContainerWidget(context),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _config!,
        backgoundColor: Colors.transparent,
        textColor: _config!.whiteColor,
        title: '${AppConstants.welcome}${_currentUser?.getFirstName()}',
        elevation: 0,
        isBackEnable: false,
        //gradient: AppColors.gradintBtnSignUp,
        onBack: () {},
        actions: <Widget>[
          btnSweatCointBalance(context, _config!),
        ]);
  }

  Widget _mainContainerWidget(BuildContext context) {
    return Column(
      children: [
        _widgetTabBar(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _widgetTabBarView(),
                _widgetEngegyGenerate(),
                _widgetYourPerformance(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _widgetTabBar() {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
      width: double.infinity,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _config!.borderColor,
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: _config!.whiteColor,
        labelStyle: _config!.calibriHeading5FontStyle,
        unselectedLabelColor: _config!.greyColor,
        unselectedLabelStyle: _config!.calibriHeading5FontStyle,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _config!.lightBorderColor,
          ),
          color: _config!.darkGreyColor,
        ),
        tabs: <Tab>[
          Tab(
            text: AppConstants.today,
          ),
          Tab(
            text: AppConstants.sevenDays,
          ),
          Tab(
            text: AppConstants.thirtyDays,
          ),
        ],
        onTap: (index) async {
          aGeneralBloc.updateAPICalling(true);
          calories = 0;
          targetedCaloriesGoal = 0;
          _blocDashboard.setCurrentTabbarIndex(index);
          await _getCaloriesData(index);
          await _getCaloriesFromWorkout(index);
          await _getWattsFromWorkout(index);
          await _getActiveMinutesFromWorkout(index);
          aGeneralBloc.updateAPICalling(false);
          // });
        },
      ),
    );
  }

  Widget _widgetTabBarView() {
    return Container(
      height: 180,
      child: StreamBuilder<int>(
        stream: _blocDashboard.tabbarSelectedIndex,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                _widgetProgressTrakingAsPerDays(HealthkitDays.today, 0),
                _widgetProgressTrakingAsPerDays(HealthkitDays.days7, 1),
                _widgetProgressTrakingAsPerDays(HealthkitDays.days30, 2)
              ],
            );
          }
          return SizedBox();
        },
      ),
    );
  }

  Widget _widgetProgressTrakingAsPerDays(HealthkitDays day, int index) {
    return Container(
      // color: Colors.red,
      padding: EdgeInsets.zero,
      width: double.infinity,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 24),
        child: Column(
          children: <Widget>[
            _widgetProgressBar(day),
          ],
        ),
      ),
    );
  }

  Widget _widgetProgressBar(HealthkitDays day) {
    return Container(
      padding: EdgeInsets.zero,
      width: double.infinity,
      //height: 156,
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: _widgetActiveMinutes(day),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Center(
              child: _widgetEnergyGenerate(day),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Center(
              child: _widgetCaloriesBurn(day),
            ),
          ),
        ],
      ),
    );
  }

  Widget _widgetActiveMinutes(HealthkitDays value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _widgetActivityProgress(),
        const SizedBox(
          height: 12,
        ),
        AutoSizeText(
          AppConstants.activeMinutesAnd,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: _config!.paragraphNormalFontStyle.apply(
            color: _config!.whiteColor,
          ),
        )
      ],
    );
  }

  Widget _widgetActivityProgress() {
    return ValueListenableBuilder<double>(
        valueListenable: _notifierWorkoutActiveMeniutes,
        builder: (BuildContext? context, activeMinutes, child) {
          double targetedMinutes = 0;
          final index = _tabController!.index;
          targetedMinutes = 60;
          targetedMinutes = (index == 0)
              ? targetedMinutes
              : (index == 1)
                  ? (targetedMinutes * 7)
                  : (targetedMinutes * 30);

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.pushNamed(
                context!,
                GraphDetails.routeName,
                arguments: GraphDetailsArgs(
                    workoutType: WorkoutType.activityMinutes,
                    healthkitValue: 0,
                    ourAppValue: activeMinutes.toInt(),
                    sumValue: activeMinutes.toDouble(),
                    targetedValue: targetedMinutes),
              );
            },
            child: Container(
              padding: EdgeInsets.zero,
              height: 100,
              child: Hero(
                tag: WorkoutType.activityMinutes,
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      maximum: targetedMinutes,
                      showLabels: false,
                      showTicks: false,
                      startAngle: 270,
                      endAngle: 270,
                      axisLineStyle: AxisLineStyle(
                        thickness: 0.20,
                        //cornerStyle: CornerStyle.bothCurve,
                        color: _config!.darkGreyColor,
                        thicknessUnit: GaugeSizeUnit.factor,
                      ),
                      pointers: <GaugePointer>[
                        RangePointer(
                          value: targetedMinutes,
                          width: 0.20,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: Colors.transparent,
                          cornerStyle: CornerStyle.bothCurve,
                          enableAnimation: true,
                        ),
                        RangePointer(
                          value: activeMinutes,
                          width: 0.20,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: _config!.skyBlueColor,
                          cornerStyle: CornerStyle.bothCurve,
                          enableAnimation: true,
                        )
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          positionFactor: 0.0,
                          angle: 90,
                          widget: Text(
                            activeMinutes.toStringAsFixed(2).toString(),
                            style: _config!.antonioHeading2FontStyle.apply(
                              color: _config!.whiteColor,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _widgetEnergyGenerate(HealthkitDays value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _widgetEnergyGenerateProgress(),
        const SizedBox(
          height: 12,
        ),
        AutoSizeText(
          AppConstants.energyGeneratedAnd,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: _config!.paragraphNormalFontStyle.apply(
            color: _config!.whiteColor,
          ),
        )
      ],
    );
  }

  Widget _widgetEnergyGenerateProgress() {
    return ValueListenableBuilder<int>(
        valueListenable: _notifierWorkoutWatts,
        builder: (BuildContext? context, energyData, child) {
          double targetedEnergyGoal = 0;
          final index = _tabController!.index;
          targetedEnergyGoal =
              (aGeneralBloc.currentUser?.calorieGoal ?? 0).toDouble();
          targetedEnergyGoal = (index == 0)
              ? targetedEnergyGoal
              : (index == 1)
                  ? (targetedEnergyGoal * 7)
                  : (targetedEnergyGoal * 30);
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.pushNamed(context!, GraphDetails.routeName,
                  arguments: GraphDetailsArgs(
                      workoutType: WorkoutType.energyGenerated,
                      healthkitValue: 0,
                      ourAppValue: energyData,
                      sumValue: energyData.toDouble(),
                      targetedValue: targetedEnergyGoal));
            },
            child: Container(
              padding: EdgeInsets.zero,
              height: 100,
              child: Hero(
                tag: WorkoutType.energyGenerated,
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      maximum: (targetedEnergyGoal == 0)
                          ? 0.001
                          : targetedEnergyGoal,
                      showLabels: false,
                      showTicks: false,
                      startAngle: 270,
                      endAngle: 270,
                      axisLineStyle: AxisLineStyle(
                        thickness: 1,
                        //cornerStyle: CornerStyle.bothCurve,
                        color: _config!.btnPrimaryColor,
                        thicknessUnit: GaugeSizeUnit.factor,
                      ),
                      pointers: <GaugePointer>[
                        RangePointer(
                          value: energyData.toDouble(),
                          width: 0.20,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: Colors.transparent,
                          cornerStyle: CornerStyle.bothCurve,
                        ),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          positionFactor: 0.5,
                          angle: 90,
                          widget: Text(
                            '${energyData}',
                            style: _config!.antonioHeading2FontStyle.apply(
                              color: _config!.blackColor,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _widgetCaloriesBurn(HealthkitDays value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _widgetCaloriesBurnProgress(value),
        const SizedBox(
          height: 12,
        ),
        AutoSizeText(
          AppConstants.caloriesBurnedAnd,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: _config!.paragraphNormalFontStyle.apply(
            color: _config!.whiteColor,
          ),
        )
      ],
    );
  }

  Widget _widgetCaloriesBurnProgress(HealthkitDays value) {
    print('sumCalories 1 = ${value}');
    return StreamBuilder<double?>(
        stream: _blocDashboard.caloriesData,
        builder: (BuildContext context, AsyncSnapshot<double?> snapshot) {
          if (snapshot.hasData) {
            final index = _tabController!.index;
            targetedCaloriesGoal =
                (aGeneralBloc.currentUser?.calorieGoal ?? 0).toDouble();
            targetedCaloriesGoal = (index == 0)
                ? targetedCaloriesGoal
                : (index == 1)
                    ? (targetedCaloriesGoal * 7)
                    : (targetedCaloriesGoal * 30);
            double? calories = snapshot.data;
            return ValueListenableBuilder<int>(
              valueListenable: _notifierWorkoutCalories,
              builder: (BuildContext? context, sumData, child) {
                final sumCalories = sumData +
                    double.parse(
                        ((snapshot.data ?? 0).toStringAsExponential(2)));
                return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.pushNamed(
                        context!,
                        GraphDetails.routeName,
                        arguments: GraphDetailsArgs(
                            workoutType: WorkoutType.caloriesBurend,
                            healthkitValue: double.parse(((snapshot.data ?? 0)
                                .toStringAsExponential(2))),
                            ourAppValue: sumData,
                            sumValue: sumCalories,
                            targetedValue: targetedCaloriesGoal),
                      );
                    },
                    child: ValueListenableBuilder<int>(
                        valueListenable: _notifierWorkoutCalories,
                        builder: (BuildContext? context, data, child) {
                          return Container(
                            padding: EdgeInsets.zero,
                            height: 100,
                            child: Hero(
                              tag: WorkoutType.caloriesBurend,
                              child: SfRadialGauge(
                                axes: <RadialAxis>[
                                  RadialAxis(
                                    showLabels: false,
                                    showTicks: false,
                                    startAngle: 270,
                                    endAngle: 270,
                                    minimum: 0,
                                    maximum: targetedCaloriesGoal,
                                    axisLineStyle: AxisLineStyle(
                                      thickness: 0.20,
                                      color: _config!.darkGreyColor,
                                      thicknessUnit: GaugeSizeUnit.factor,
                                    ),
                                    pointers: <GaugePointer>[
                                      RangePointer(
                                        value: targetedCaloriesGoal,
                                        width: 0.20,
                                        sizeUnit: GaugeSizeUnit.factor,
                                        color: Colors.transparent,
                                        cornerStyle: CornerStyle.bothCurve,
                                        enableAnimation: true,
                                      ),
                                      RangePointer(
                                        value: calories ?? 0,
                                        width: 0.20,
                                        sizeUnit: GaugeSizeUnit.factor,
                                        color: _config!.orangeColor,
                                        cornerStyle: CornerStyle.bothCurve,
                                        enableAnimation: true,
                                      ),
                                      RangePointer(
                                        value: data.toDouble(),
                                        width: 0.20,
                                        sizeUnit: GaugeSizeUnit.factor,
                                        color: AppColors.greenColor,
                                        cornerStyle: CornerStyle.bothCurve,
                                        enableAnimation: true,
                                      ),
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                        positionFactor: 0.0,
                                        angle: 90,
                                        widget: Container(
                                          // color: Colors.green,
                                          width: 70,
                                          child: Text(
                                            '${sumCalories.toInt()} / ${targetedCaloriesGoal.toInt()}',
                                            style: _config!
                                                .antonioHeading2FontStyle
                                                .apply(
                                                    color: _config!.whiteColor,
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSizeFactor: 0.7),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }));
              },
            );
          }
          return Container(
            padding: EdgeInsets.zero,
            height: 100,
            child: Hero(
              tag: WorkoutType.caloriesBurend,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    showLabels: false,
                    showTicks: false,
                    startAngle: 270,
                    endAngle: 270,
                    axisLineStyle: AxisLineStyle(
                      thickness: 0.20,
                      //cornerStyle: CornerStyle.bothCurve,
                      color: _config!.darkGreyColor,
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: targetedCaloriesGoal,
                        width: 0.20,
                        sizeUnit: GaugeSizeUnit.factor,
                        color: Colors.transparent,
                        cornerStyle: CornerStyle.bothCurve,
                      ),
                      RangePointer(
                        value: 0,
                        width: 0.20,
                        sizeUnit: GaugeSizeUnit.factor,
                        color: _config!.orangeColor,
                        cornerStyle: CornerStyle.bothCurve,
                        animationType: AnimationType.bounceOut,
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                          positionFactor: 0.0,
                          angle: 90,
                          widget: Text(
                            '0',
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
          );
        });
  }

  Widget _widgetEngegyGenerate() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
      width: double.infinity,
      //height: 145,
      decoration: BoxDecoration(
          color: _config!.borderColor, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AutoSizeText(
            AppConstants.energyGeneratedMsg,
            style: _config!.labelNormalFontStyle.apply(
              color: _config!.greyColor,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 0),
                  child: _widgetLightHours(),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 0),
                  child: _widgetChargePhone(),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 0),
                  child: _widgetChargeEBike(),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _widgetLightHours() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.zero,
          width: 40,
          height: 40,
          child: SvgPictureRecolor.asset(
            ImgConstants.light,
          ),
        ),
        _widgetLightText()
      ],
    );
  }

  Widget _widgetLightText() {
    return ValueListenableBuilder<int>(
        valueListenable: _notifierWorkoutWatts,
        builder: (BuildContext? context, energyData, child) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: AppConstants.lightHome,
                style: _config!.paragraphSmallFontStyle.apply(
                  color: _config!.greyColor,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (energyData / 0.06).toStringAsFixed(0).toString(),
                    style: _config!.paragraphSmallFontStyle.apply(
                      color: _config!.whiteColor,
                    ),
                  ),
                  TextSpan(
                    text: AppConstants.hours,
                    style: _config!.paragraphSmallFontStyle.apply(
                      color: _config!.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _widgetChargePhone() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.zero,
          width: 40,
          height: 40,
          child: SvgIcon.asset(
            ImgConstants.battery,
            color: _config!.orangeColor,
          ),
        ),
        _widgetChargePhoneText()
      ],
    );
  }

  Widget _widgetChargePhoneText() {
    return ValueListenableBuilder<int>(
        valueListenable: _notifierWorkoutWatts,
        builder: (BuildContext? context, energyData, child) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: AppConstants.chargePhone,
                style: _config!.paragraphSmallFontStyle.apply(
                  color: _config!.greyColor,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (energyData / 0.01).toStringAsFixed(0).toString(),
                    style: _config!.paragraphSmallFontStyle.apply(
                      color: _config!.whiteColor,
                    ),
                  ),
                  TextSpan(
                    text: AppConstants.times,
                    style: _config!.paragraphSmallFontStyle.apply(
                      color: _config!.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _widgetChargeEBike() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.zero,
          width: 40,
          height: 40,
          child: SvgPictureRecolor.asset(
            ImgConstants.eBike,
          ),
        ),
        _widgetChargeEBikeText()
      ],
    );
  }

  Widget _widgetChargeEBikeText() {
    return ValueListenableBuilder<int>(
        valueListenable: _notifierWorkoutWatts,
        builder: (BuildContext? context, energyData, child) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: AppConstants.chargeEbike,
                style: _config!.paragraphSmallFontStyle.apply(
                  color: _config!.greyColor,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (energyData / 0.05).toStringAsFixed(0).toString(),
                    style: _config!.paragraphSmallFontStyle.apply(
                      color: _config!.whiteColor,
                    ),
                  ),
                  TextSpan(
                    text: AppConstants.times,
                    style: _config!.paragraphSmallFontStyle.apply(
                      color: _config!.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _widgetYourPerformance() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 3,
      decoration: BoxDecoration(
        color: _config!.borderColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.yourperformance.toUpperCase(),
            style: _config!.labelNormalFontStyle.apply(
              color: _config!.greyColor,
            ),
          ),
          Expanded(
            child: Container(
                child: ValueListenableBuilder<bool>(
                    valueListenable: _isChartWorkoutData,
                    builder: (BuildContext? context, isData, child) {
                      return ValueListenableBuilder<bool>(
                          valueListenable: _isChartHealthKitData,
                          builder: (BuildContext? context, isData, child) {
                            return _chartView();
                          });
                    })),
          ),
        ],
      ),
    );
  }

  final staticTicks = <charts.TickSpec<String>>[
    charts.TickSpec(AppConstants.mon),
    charts.TickSpec(AppConstants.tue),
    charts.TickSpec(AppConstants.wed),
    charts.TickSpec(AppConstants.thu),
    charts.TickSpec(AppConstants.fri),
    charts.TickSpec(AppConstants.sat),
    charts.TickSpec(AppConstants.sun),
  ];

  List<charts.Series<WorkoutData, String>> _createData() {
    final target = (aGeneralBloc.currentUser?.calorieGoal ?? 0).toDouble();
    final List<WorkoutData> targetedData = [
      WorkoutData(AppConstants.mon, target),
      WorkoutData(AppConstants.tue, target),
      WorkoutData(AppConstants.wed, target),
      WorkoutData(AppConstants.thu, target),
      WorkoutData(AppConstants.fri, target),
      WorkoutData(AppConstants.sat, target),
      WorkoutData(AppConstants.sun, target),
    ];

    final List<WorkoutData> appWorkoutData = chartWorkout;

    final List<WorkoutData> healthkitData = chartHealth;

    return [
      charts.Series<WorkoutData, String>(
        id: 'Targeted',
        domainFn: (WorkoutData sales, _) => sales.days,
        measureFn: (WorkoutData sales, _) => sales.value,
        data: targetedData,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(_config!.greyColor),
      ),
      charts.Series<WorkoutData, String>(
        id: 'App Workout Calories',
        domainFn: (WorkoutData sales, _) => sales.days,
        measureFn: (WorkoutData sales, _) => sales.value,
        data: appWorkoutData,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(AppColors.lightGreen),
      ),
      charts.Series<WorkoutData, String>(
        id: 'HealthKit Calories',
        domainFn: (WorkoutData sales, _) => sales.days,
        measureFn: (WorkoutData sales, _) => sales.value,
        data: healthkitData,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(_config!.btnPrimaryColor),
      ),
    ];
  }

  Widget _chartView() {
    return Container(
      child: charts.BarChart(
        _createData(),
        animate: true,
        barGroupingType: charts.BarGroupingType.stacked,
        primaryMeasureAxis: charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(fontSize: 8),
            lineStyle: charts.LineStyleSpec(
                color: charts.ColorUtil.fromDartColor(_config!.greyColor),
                dashPattern: [2, 2]),
          ),
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(desiredTickCount: 5),
          showAxisLine: false,
        ),
        domainAxis: charts.OrdinalAxisSpec(
          tickProviderSpec: charts.StaticOrdinalTickProviderSpec(staticTicks),
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(fontSize: 8),
            lineStyle: charts.LineStyleSpec(
                color: charts.ColorUtil.fromDartColor(_config!.greyColor),
                dashPattern: [2, 2]),
          ),
          showAxisLine: true,
        ),
      ),
    );
  }

  // Get healthkit / google kit calories data
  Future<void> _getCaloriesData(int index) async {
    _blocDashboard.addHealthkitCalories(0);
    double? caloriesData =
        await HealthProvider.instance.getHealthkitCalories(index) ?? 0;
    print('calories = in ${caloriesData}');
    _blocDashboard.addHealthkitCalories(caloriesData);
  }

  // Get our app workout calories data from firebase
  Future<void> _getCaloriesFromWorkout(int index) async {
    _notifierWorkoutCalories.value = 0;
    await _blocDashboard.getWorkout(context, index: index);
    _notifierWorkoutCalories.value =
        _blocDashboard.workoutCalories.valueWrapper?.value ?? 0;
    print(_notifierWorkoutCalories.value);
  }

  // Get our app watts data
  Future<void> _getWattsFromWorkout(int index) async {
    _notifierWorkoutWatts.value = 0;
    await _blocDashboard.getWorkout(context, index: index);
    _notifierWorkoutWatts.value =
        _blocDashboard.workoutWatts.valueWrapper?.value ?? 0;
  }

  // Get workout minutes
  Future<void> _getActiveMinutesFromWorkout(int index) async {
    _notifierWorkoutActiveMeniutes.value = 0;
    await _blocDashboard.getWorkout(context, index: index);
    _notifierWorkoutActiveMeniutes.value =
        _blocDashboard.workoutMinutes.valueWrapper?.value ?? 0;
  }

  // Get healthkit / google kit data to display week wise
  Future<void> _getHealthkitCalWeekWise() async {
    _isChartHealthKitData.value = false;
    chartHealth = await HealthProvider.instance.getHealthkitCalWeekWise();
    _isChartHealthKitData.value = true;
  }

  // Get workout list for chart view
  Future<void> _getWorkoutList() async {
    _isChartWorkoutData.value = false;
    chartWorkout = await _blocDashboard.getWorkoutList(context);

    _isChartWorkoutData.value = true;
  }
}

class WorkoutData {
  final String days;
  double value;

  WorkoutData(this.days, this.value);
}

class CommonNotifire with ChangeNotifier {
  // when notifyListeners is called, it will invoke
  // any callbacks that have been registered with an instance of this object
  // addListener.

  void notifyEvent() {
    notifyListeners();
  }
}
