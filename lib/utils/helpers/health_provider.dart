import 'dart:ffi';

import 'package:energym/screens/dashboard/dashboard.dart';
import 'package:energym/screens/dashboard/dashboard_bloc.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:health/health.dart';
import 'package:energym/utils/extensions/extension.dart';

class HealthProvider {
  static HealthProvider? _instance;
  static HealthFactory? _health;
  static HealthProvider get instance => _instance ?? HealthProvider._internal();
  List<HealthDataPoint> _healthDataList = [];
  List<HealthDataType> types = [
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.ACTIVE_ENERGY_BURNED
  ];

  // final permissions = [
  //   HealthDataAccess.READ,
  //   HealthDataAccess.READ,
  //   HealthDataAccess.READ,
  //   HealthDataAccess.READ_WRITE
  // ];

  HealthProvider._internal() {
    _health = HealthFactory();

    final DateTime dateFrom = DateTime.now().subtract(const Duration(days: 5));
    final DateTime dateTo = DateTime.now();

    /// You MUST request access to the data types before reading them
    _health!.requestAuthorization(types).then((bool accessWasGranted) async {
      // permissions: permissions
      if (accessWasGranted) {
        try {
          /// Fetch new data
          List<HealthDataPoint> healthData =
              await _health!.getHealthDataFromTypes(dateFrom, dateTo, types);

          /// Save all the new data points
          _healthDataList.addAll(healthData);
        } catch (e) {
          print("Caught exception in getHealthDataFromTypes: $e");
        }

        /// Filter out duplicates
        _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

        bool? hasPermissions = await HealthFactory.hasPermissions(types);
        if (hasPermissions!) {
          aGeneralBloc.commonNotifire.notifyEvent();
        }
      } else {
        print("Authorization not granted");
      }
    });

    _instance = this;
  }

  Future<int?> getHeight() async {
    if (_healthDataList.isNotEmpty) {
      final HealthDataPoint data = await _healthDataList.firstWhere(
          (HealthDataPoint element) => element.type == HealthDataType.HEIGHT,
          orElse: () => _healthDataList[0]);
      // final HealthDataPoint data = (await _healthDataList
      //     .where((e) => e.type == HealthDataType.HEIGHT)) as HealthDataPoint;
      print("Data point: $data");
      final double heightInM = double.parse(data.value.toString());
      int? heightInCM;
      if (heightInM != null) {
        heightInCM = (heightInM * 100).toInt();
      }
      return heightInCM!;
    }
  }

  Future<double?> getWeight() async {
    if (_healthDataList.isNotEmpty) {
      final HealthDataPoint data = await _healthDataList.firstWhere(
          (HealthDataPoint element) => element.type == HealthDataType.WEIGHT,
          orElse: () => _healthDataList[0]);
      // final HealthDataPoint data = (await _healthDataList
      //     .where((e) => e.type == HealthDataType.WEIGHT)) as HealthDataPoint;
      final double heightInkg = double.parse(data.value.toString());
      return heightInkg.doubleWithPlaces(1);
    }
  }

  Future<bool> getHealthKitauth() async {
    bool access = false;

    try {
      await _health!
          .requestAuthorization(types)
          .then((bool accessWasGranted) async {
        access = accessWasGranted;
      });
    } catch (error) {
      print(error);
    }

    return access;
  }

  Future<double?> getHealthkitCalories(int value) async {
    var dayNow = DateTime.now();
    var dayStart;
    double calorie = 0;

    if (value == 0) {
      // Today
      dayStart = DateTime(dayNow.year, dayNow.month, dayNow.day);
    } else if (value == 1) {
      // Past 7 Days
      dayStart = DateTime.now().subtract(Duration(days: 6));
    } else if (value == 2) {
      // Past 30 Days
      dayStart = DateTime.now().subtract(Duration(days: 29));
    }

    List<HealthDataPoint> caloriesBurnedData = await _health!
        .getHealthDataFromTypes(dayStart as DateTime, dayNow,
            [HealthDataType.ACTIVE_ENERGY_BURNED]);
    List<HealthDataPoint> caloriesBurned =
        HealthFactory.removeDuplicates(caloriesBurnedData);

    caloriesBurned.forEach((data) {
      calorie = calorie + double.parse(data.value.toString());
    });
    print('calorie = -1 ${DateTime.now()}');

    print('calorie = ${calorie} - value ${value}');
    return calorie;
  }

  Future<List<WorkoutData>> getHealthkitCalWeekWise() async {
    var dayNow = DateTime.now();
    var dayStart;
    List<WorkoutData> tempWorkoutData = <WorkoutData>[
      WorkoutData(AppConstants.mon, 0),
      WorkoutData(AppConstants.tue, 0),
      WorkoutData(AppConstants.wed, 0),
      WorkoutData(AppConstants.thu, 0),
      WorkoutData(AppConstants.fri, 0),
      WorkoutData(AppConstants.sat, 0),
      WorkoutData(AppConstants.sun, 0),
    ];
    // Past 7 Days
    dayStart = DateTime.now().subtract(Duration(days: 6));

    List<HealthDataPoint> caloriesBurnedData = await _health!
        .getHealthDataFromTypes(dayStart as DateTime, dayNow,
            [HealthDataType.ACTIVE_ENERGY_BURNED]);
    List<HealthDataPoint> caloriesBurned =
        HealthFactory.removeDuplicates(caloriesBurnedData);

    for (HealthDataPoint data in caloriesBurned) {
      DateFormat format = DateFormat("E");
      switch (format.format(data.dateFrom).toUpperCase()) {
        case 'MON':
          tempWorkoutData[0].value =
              tempWorkoutData[0].value + double.parse(data.value.toString());
          break;
        case 'TUE':
          tempWorkoutData[1].value =
              tempWorkoutData[1].value + double.parse(data.value.toString());
          break;
        case 'WED':
          tempWorkoutData[2].value =
              tempWorkoutData[2].value + double.parse(data.value.toString());
          break;
        case 'THU':
          tempWorkoutData[3].value =
              tempWorkoutData[3].value + double.parse(data.value.toString());
          break;
        case 'FRI':
          tempWorkoutData[4].value =
              tempWorkoutData[4].value + double.parse(data.value.toString());
          break;
        case 'SAT':
          tempWorkoutData[5].value =
              tempWorkoutData[5].value + double.parse(data.value.toString());
          break;
        case 'SUN':
          tempWorkoutData[6].value =
              tempWorkoutData[6].value + double.parse(data.value.toString());
          break;
        default:
          print(
              "other ${data.dateFrom} - ${format.format(data.dateFrom)} - ${data.dateTo} - ${data.value}");
      }
    }
    return tempWorkoutData;
  }

  writeCalories() async {
    bool? success = await _health?.writeHealthData(10,
        HealthDataType.ACTIVE_ENERGY_BURNED, DateTime.now(), DateTime.now());
    print(success);
  }
}
