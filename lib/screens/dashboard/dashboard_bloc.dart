import 'package:energym/models/workout_model.dart';
import 'package:energym/screens/dashboard/dashboard.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class DashboardBloc {
  final BehaviorSubject<List<WorkoutModel>> _userWorkout =
      BehaviorSubject<List<WorkoutModel>>();
  ValueStream<List<WorkoutModel>> get getUserWorkout => _userWorkout.stream;

  List<WorkoutModel> workoutList = <WorkoutModel>[];
  DocumentSnapshot<Map<String, dynamic>?>? lastDocument;

  final BehaviorSubject<int> _workoutWatts = BehaviorSubject<int>.seeded(0);
  ValueStream<int> get workoutWatts => _workoutWatts.stream;

  final BehaviorSubject<int> _workoutCalories = BehaviorSubject<int>.seeded(0);
  ValueStream<int> get workoutCalories => _workoutCalories.stream;

  final BehaviorSubject<double> _workoutMinutes =
      BehaviorSubject<double>.seeded(0);
  ValueStream<double> get workoutMinutes => _workoutMinutes.stream;

  final BehaviorSubject<double> _healthkitClories = BehaviorSubject<double>();
  ValueStream<double> get healthkitClories => _healthkitClories.stream;

  final BehaviorSubject<int> _tabbarSelectedIndex =
      BehaviorSubject<int>.seeded(0);
  ValueStream<int> get tabbarSelectedIndex => _tabbarSelectedIndex.stream;

  final BehaviorSubject<double?> _caloriesData =
      BehaviorSubject<double?>.seeded(0);
  ValueStream<double?> get caloriesData => _caloriesData.stream;

  Future<void> getWorkout(BuildContext mainContext,
      {String? userId, required int index}) async {
    // _userWorkout.sink.add(workoutList);

    List<DocumentSnapshot<Map<String, dynamic>>>? _list =
        await FireStoreProvider.instance
            .getWorkoutDataSum(mainContext: mainContext, index: index);

    int sumWatts = 0;
    double sumActiveMinutes = 0;
    int sumCalories = 0;

    if (_list != null && _list.isNotEmpty) {
      lastDocument = _list.last;
      List<WorkoutModel> _listModel = <WorkoutModel>[];
      _list.forEach((document) async {
        Map<String, dynamic>? tempData = document.data();

        sumWatts = sumWatts + int.parse(((tempData?['watts']).toString()));
        sumActiveMinutes = sumActiveMinutes +
            double.parse(((tempData?['activeMinutes']).toString()));
        sumCalories =
            sumCalories + int.parse(((tempData?['calories']).toString()));

        _workoutWatts.sink.add(sumWatts);
        _workoutMinutes.sink.add(sumActiveMinutes);
        _workoutCalories.sink.add(sumCalories);
      });
    } else {
      _workoutWatts.sink.add(0);
      _workoutMinutes.sink.add(0);
      _workoutCalories.sink.add(0);
    }
  }

  // Get workout data from firebase for chart
  Future<List<WorkoutData>> getWorkoutList(BuildContext mainContext,
      {String? userId}) async {
    List<WorkoutData> tempWorkoutData = <WorkoutData>[
      WorkoutData(AppConstants.mon, 0),
      WorkoutData(AppConstants.tue, 0),
      WorkoutData(AppConstants.wed, 0),
      WorkoutData(AppConstants.thu, 0),
      WorkoutData(AppConstants.fri, 0),
      WorkoutData(AppConstants.sat, 0),
      WorkoutData(AppConstants.sun, 0),
    ];
    List<DocumentSnapshot<Map<String, dynamic>?>?>? _list =
        await FireStoreProvider.instance
            .getWorkoutData(mainContext: mainContext);

    if (_list != null && _list.isNotEmpty) {
      _list.forEach((document) async {
        Map<String, dynamic>? tempData = document?.data();
        DateFormat format = DateFormat("E");
        final cal = int.parse(((tempData?['calories']).toString()));
        switch (format
            .format(DateTime.parse(tempData!['created_at'].toDate().toString()))
            .toUpperCase()) {
          case 'MON':
            tempWorkoutData[0].value =
                tempWorkoutData[0].value + double.parse(cal.toString());
            break;
          case 'TUE':
            tempWorkoutData[1].value =
                tempWorkoutData[1].value + double.parse(cal.toString());
            break;
          case 'WED':
            tempWorkoutData[2].value =
                tempWorkoutData[2].value + double.parse(cal.toString());
            break;
          case 'THU':
            tempWorkoutData[3].value =
                tempWorkoutData[3].value + double.parse(cal.toString());
            break;
          case 'FRI':
            tempWorkoutData[4].value =
                tempWorkoutData[4].value + double.parse(cal.toString());
            break;
          case 'SAT':
            tempWorkoutData[5].value =
                tempWorkoutData[5].value + double.parse(cal.toString());
            break;
          case 'SUN':
            tempWorkoutData[6].value =
                tempWorkoutData[6].value + double.parse(cal.toString());
            break;
          default:
        }
      });
    } else {}
    return tempWorkoutData;
  }

  void dispose() {
    _userWorkout.close();
    _healthkitClories.close();
  }

  addHealthkitCalories(double value) {
    _caloriesData.sink.add(value);
  }

  setCurrentTabbarIndex(int index) {
    _tabbarSelectedIndex.sink.add(index);
  }
}
