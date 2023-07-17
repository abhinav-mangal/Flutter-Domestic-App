import 'dart:ui';

import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/screens/bluetoothConnectivity/bluetoothConnectivity.dart';
import 'package:energym/screens/workout/build_workout/buildmyworkouttime.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Build your workout listing
// There is fix 5 types of workouts listed
class BuildMyWorkout extends StatefulWidget {
  static const String routeName = '/BuildMyWorkout';
  @override
  _BuildMyWorkoutState createState() => _BuildMyWorkoutState();
}

class _BuildMyWorkoutState extends State<BuildMyWorkout> {
  UserModel? _currentUser;
  AppConfig? _config;
  APIProvider? _api;
  List<String> listWorkout = [
    AppConstants.climbCondition,
    AppConstants.pharaomones,
    AppConstants.allPain,
    AppConstants.holyHiit,
    AppConstants.shedHappens
  ];
  @override
  void initState() {
    super.initState();
    _api = APIProvider.of(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
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
          //aGeneralBloc.getCurrentSweatCoinUser(_api, context);
        }

        return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: _getAppBar(),
            body: _mainContainer());
      },
    );
  }

  Widget _mainContainer() {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 15),
            child: Text(
              AppConstants.yourWorkout.toUpperCase(),
              style: _config!.antonio36FontStyle
                  .apply(color: AppColors.blueworkout),
            ),
          ),
          Text(AppConstants.chooseanOption,
              style: _config!.antonioHeading2FontStyle),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 20),
              itemCount: listWorkout.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final item = listWorkout[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.popAndPushNamed(
                      context,
                      BuildMyWorkoutTime.routeName,
                      arguments: BuildMyWorkoutTimeArgs(index: index),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 7, left: 30, right: 30),
                    child: Column(
                      children: [
                        Container(
                            height: 78,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: AppColors.blueworkout),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            child: Center(
                              child: Text(
                                item,
                                style: _config!.abel24FontStyle,
                              ),
                            )),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _config!,
        backgoundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        isBackEnable: false,
        onBack: () {},
        leadingWidget: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 24,
            color: AppColors.blueworkout,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        widget: btnPairing(context, (isConnectedDevice) {
          if (isConnectedDevice) {
            // pop up
            // bottomSheet(context);
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BlueToothConnectivityVC()));
          }
        }),
        actions: <Widget>[
          btnSweatCointBalance(context, _config!),
        ]);
  }
}
