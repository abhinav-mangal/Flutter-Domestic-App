import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/loader_button.dart';
import 'package:energym/screens/AnimationCounter/animation_counter.dart';
import 'package:energym/screens/bluetoothConnectivity/bluetoothConnectivity.dart';
import 'package:energym/screens/workout/green_zone/livecalibrationworkout.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

// This screen for edit goal , user can edit goal
class EditGoal extends StatefulWidget {
  static const String routeName = '/EditGoal';

  @override
  _EditGoalState createState() => _EditGoalState();
}

class _EditGoalState extends State<EditGoal> {
  AppConfig? _config;
  UserModel? _currentUser;
  ValueNotifier<int> _notifierWNewCalories = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _currentUser = aGeneralBloc.currentUser;
    _notifierWNewCalories.value = _currentUser?.calorieGoal ?? 0;
  }

  @override
  void dispose() {
    super.dispose();

    _notifierWNewCalories.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _topText(),
              _staticCurrentGoal(),
              // _calories(),
              _currentGoalValue(),
              _staticNewGoal(),
              _newGoalValue(),
              // _btnEditGoal(),
              // _btnStartWorkout(),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _btnSaveGoal(),
        ],
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
            Navigator.pop(context, _currentUser);
          },
        ),
        widget: btnPairing(context, (isConnectedDevice) {
          if (isConnectedDevice) {
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
        AppConstants.editGoal.toUpperCase(),
        style:
            _config!.antonio36FontStyle.apply(color: AppColors.orangeworkout),
      ),
    );
  }

  Widget _staticCurrentGoal() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        AppConstants.currentGoal,
        style:
            _config!.antonioHeading2FontStyle.apply(color: _config!.whiteColor),
      ),
    );
  }

  Widget _calories() {
    return Text(
      '[${AppConstants.calories}]',
      style: _config!.antonioHeading4FontStyle
          .apply(color: _config!.whiteColor, fontSizeFactor: 0.5),
    );
  }

  Widget _currentGoalValue() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        '${_currentUser?.calorieGoal}',
        style: _config!.antonio36FontStyle.apply(color: _config!.orangeColor),
      ),
    );
  }

  Widget _newValue() {
    return Center(
      child: ValueListenableBuilder<int>(
          valueListenable: _notifierWNewCalories,
          builder: (BuildContext? context, data, child) {
            return Text(
              '$data',
              // textAlign: TextAlign.center,
              style: _config!.antonio36FontStyle
                  .apply(color: _config!.orangeColor),
            );
          }),
    );
  }

  Widget _newGoalValue() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Container(
        height: 80,
        width: 140,
        decoration: BoxDecoration(
            border: Border.all(color: _config!.orangeColor, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            _newValue(),
            Container(
              width: 30,
              // height: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    child: Container(
                        // color: Colors.red,
                        child: Icon(
                      Icons.arrow_drop_up,
                      color: AppColors.orangeworkout,
                    )),
                    onTap: () {
                      if (_notifierWNewCalories.value >= 0) {
                        _notifierWNewCalories.value++;
                      }
                    },
                  ),
                  GestureDetector(
                    child: Container(
                        // color: Colors.red,
                        child: Icon(Icons.arrow_drop_down,
                            color: AppColors.orangeworkout)),
                    onTap: () {
                      if (_notifierWNewCalories.value > 0) {
                        _notifierWNewCalories.value--;
                      } else {
                        _notifierWNewCalories.value = 0;
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _staticNewGoal() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        AppConstants.newGoal,
        style:
            _config!.antonioHeading2FontStyle.apply(color: _config!.whiteColor),
      ),
    );
  }

  Widget _btnEditGoal() {
    return Container(
      padding: EdgeInsets.only(bottom: 10, left: 30, right: 30, top: 20),
      // color: Colors.red,
      width: double.infinity,
      height: 90,
      child: LoaderButton(
        isOutLine: true,
        outLineColor: AppColors.orangeworkout,
        radius: 15,
        onPressed: () {
          if (globalMins == 0) {
            CustomAlertDialog().showAlert(
                context: context,
                message: MsgConstants.testmin,
                title: AppConstants.appName);
          } else {
            Navigator.popAndPushNamed(
              context,
              AnimationCounter.routeName,
              arguments: AnimationCounterArgs(
                  isLiveCalibration: true,
                  mins: globalMins,
                  isBuildworkout: false),
            );
          }
        },
        title: AppConstants.editgoal,
        titleStyle: _config!.antonio48FontStyle
            .apply(color: AppColors.orangeworkout, fontSizeFactor: 0.5),
      ),
    );
  }

  Widget _btnSaveGoal() {
    return Container(
      padding: EdgeInsets.only(bottom: 50, left: 30, right: 30),
      // color: Colors.red,
      width: double.infinity,
      height: 110,
      child: LoaderButton(
        isOutLine: true,
        outLineColor: AppColors.orangeworkout,
        radius: 15,
        onPressed: () {
          updateUser();
        },
        title: AppConstants.saveGoal.toUpperCase(),
        titleStyle: _config!.antonio48FontStyle
            .apply(color: AppColors.orangeworkout, fontSizeFactor: 0.5),
      ),
    );
  }

  void updateUser() async {
    UserModel? currenrtUser = aGeneralBloc.currentUser;

    final Map<String, dynamic> _neetToStoreData = <String, dynamic>{};

    _neetToStoreData[UserCollectionField.calorieGoal] =
        _notifierWNewCalories.value;

    print('_neetToStoreData ${_neetToStoreData}');
    // Save workout data into user profile
    FireStoreProvider.instance.updateUser(
        userId: _currentUser!.documentId,
        userData: _neetToStoreData,
        onSuccess: (Map<String, dynamic> successResponse) {
          print(successResponse);
          FireStoreProvider.instance.getCurrentUserData(
              userId: _currentUser?.documentId,
              onSuccess: (UserModel data) async {
                aGeneralBloc.updateCurrentUser(data);
                Navigator.pop(context, data);
              });
        },
        onError: (Map<String, dynamic> errorResponse) {
          print(errorResponse);
          aGeneralBloc.updateAPICalling(false);
        });
  }
}
