import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/screens/workout/workout_dialog.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BuildWorkout extends StatefulWidget {
  static const String routeName = '/BuildWorkout';
  const BuildWorkout({Key? key}) : super(key: key);

  @override
  _BuildWorkoutState createState() => _BuildWorkoutState();
}

class _BuildWorkoutState extends State<BuildWorkout> {
  AppConfig? _config;
  UserModel? _currentUser;
  String? refUrl = '';
  @override
  void initState() {
    super.initState();
    _currentUser = aGeneralBloc.currentUser;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.zero,
          width: double.infinity,
          height: double.infinity,
          child: _mainContainerWidget(),
        ),
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(
      context,
      _config!,
      backgoundColor: Colors.transparent,
      textColor: _config!.whiteColor,
      title: AppConstants.buildMyWorkOut,
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
            Navigator.pop(context);
          }),
    );
  }

  Widget _mainContainerWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 16),
      child: Column(
        children: <Widget>[
          Expanded(child: _widgetCalorieGoal()),
          Expanded(child: _widgetBeatMy()),
          Expanded(child: _widgetWorkOut()),
          Expanded(child: _widgetCalorie()),
        ],
      ),
    );
  }

  Widget _widgetCalorieGoal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
      child: AspectRatio(
        aspectRatio: 343 / 146,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _config!.purpelColor),
          child: Stack(
            children: [
              Positioned(
                bottom: 12,
                right: 22,
                child: SvgPicture.asset(
                  ImgConstants.burn,
                  color: _config!.whiteColor.withAlpha(15),
                ),
              ),
              TextButton(
                onPressed: () {
                  _showDialog(
                    min: 45,
                    calories: 250,
                    watts: 120,
                    sweatCoints: 120,
                  );
                },
                style: TextButton.styleFrom(
                    //padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                    ),
                child: Container(
                  padding: EdgeInsets.zero,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppConstants.hitMyDaily,
                        style: _config!.antonioHeading1FontStyle
                            .apply(color: _config!.blackColor),
                      ),
                      const SizedBox(
                        height: 21,
                      ),
                      Text(
                        AppConstants.calorieGoal,
                        style: _config!.linkLargeFontStyle
                            .apply(color: _config!.blackColor),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _widgetBeatMy() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
      child: AspectRatio(
        aspectRatio: 343 / 146,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _config!.skyBlueColor),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                right: 0,
                child: SvgIcon.asset(
                  ImgConstants.tabWorkout,
                  color: _config!.whiteColor.withAlpha(30),
                  size: 100,
                ),
              ),
              TextButton(
                onPressed: () {
                  _showDialog(
                    min: 45,
                    calories: 250,
                    watts: 120,
                    sweatCoints: 120,
                  );
                },
                style: TextButton.styleFrom(
                    //padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 16, 16),
                    ),
                child: Container(
                  padding: EdgeInsets.zero,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppConstants.bestMy,
                        style: _config!.antonioHeading1FontStyle
                            .apply(color: _config!.blackColor),
                      ),
                      const SizedBox(
                        height: 21,
                      ),
                      Text(
                        AppConstants.personalBest,
                        style: _config!.linkLargeFontStyle
                            .apply(color: _config!.blackColor),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _widgetWorkOut() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
      child: AspectRatio(
        aspectRatio: 343 / 146,
        child: Row(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                //margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _config!.btnPrimaryColor),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 16,
                      right: 12,
                      child: SvgPicture.asset(
                        ImgConstants.timer,
                        color: _config!.whiteColor.withAlpha(20),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _showDialog(
                          min: 30,
                          calories: 150,
                          watts: 100,
                          sweatCoints: 100,
                        );
                      },
                      style: TextButton.styleFrom(
                          // padding: const EdgeInsetsDirectional.fromSTEB(
                          //     20, 16, 16, 16),
                          ),
                      child: Container(
                        padding: EdgeInsets.zero,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '30 ${AppConstants.min}',
                              style: _config!.antonioHeading1FontStyle
                                  .apply(color: _config!.whiteColor),
                            ),
                            const SizedBox(
                              height: 21,
                            ),
                            Text(
                              AppConstants.workout,
                              style: _config!.linkLargeFontStyle
                                  .apply(color: _config!.whiteColor),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Container(
                //margin: const EdgeInsetsDirectional.fromSTEB(8, 8, 16, 8),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _config!.btnPrimaryColor),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 16,
                      right: 12,
                      child: SvgPicture.asset(
                        ImgConstants.timer,
                        color: _config!.whiteColor.withAlpha(20),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _showDialog(
                          min: 45,
                          calories: 250,
                          watts: 120,
                          sweatCoints: 120,
                        );
                      },
                      style: TextButton.styleFrom(
                          // padding: const EdgeInsetsDirectional.fromSTEB(
                          //     20, 16, 16, 16),
                          ),
                      child: Container(
                        padding: EdgeInsets.zero,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '45 ${AppConstants.min}',
                              style: _config!.antonioHeading1FontStyle
                                  .apply(color: _config!.whiteColor),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Text(
                              AppConstants.workout,
                              style: _config!.linkLargeFontStyle
                                  .apply(color: _config!.whiteColor),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _widgetCalorie() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
      child: AspectRatio(
        aspectRatio: 343 / 146,
        child: Row(
          children: [
            Expanded(
              child: Container(
                //margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _config!.orangeColor),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 16,
                      right: 12,
                      child: SvgPicture.asset(
                        ImgConstants.burn,
                        color: _config!.whiteColor.withAlpha(20),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _showDialog(
                          min: 30,
                          calories: 150,
                          watts: 100,
                          sweatCoints: 100,
                        );
                      },
                      style: TextButton.styleFrom(
                          // padding: const EdgeInsetsDirectional.fromSTEB(
                          //     20, 16, 16, 16),
                          ),
                      child: Container(
                        padding: EdgeInsets.zero,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '150 ${AppConstants.cal}',
                              style: _config!.antonioHeading1FontStyle
                                  .apply(color: _config!.whiteColor),
                            ),
                            const SizedBox(
                              height: 21,
                            ),
                            Text(
                              AppConstants.workout,
                              style: _config!.linkLargeFontStyle
                                  .apply(color: _config!.whiteColor),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Container(
                //margin: const EdgeInsetsDirectional.fromSTEB(8, 8, 16, 8),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _config!.orangeColor),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 16,
                      right: 12,
                      child: SvgPicture.asset(
                        ImgConstants.burn,
                        color: _config!.whiteColor.withAlpha(20),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _showDialog(
                          min: 45,
                          calories: 250,
                          watts: 120,
                          sweatCoints: 120,
                        );
                      },
                      style: TextButton.styleFrom(
                          // padding: const EdgeInsetsDirectional.fromSTEB(
                          //     20, 16, 16, 16),
                          ),
                      child: Container(
                        padding: EdgeInsets.zero,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '250 ${AppConstants.cal}',
                              style: _config!.antonioHeading1FontStyle
                                  .apply(color: _config!.whiteColor),
                            ),
                            const SizedBox(
                              height: 21,
                            ),
                            Text(
                              AppConstants.workout,
                              style: _config!.linkLargeFontStyle
                                  .apply(color: _config!.whiteColor),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog({
    required int? min,
    required int? calories,
    required int? watts,
    required int? sweatCoints,
  }) {
    showGeneralDialog(
      barrierLabel: '',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      context: context,
      pageBuilder: (BuildContext context, Animation<double> anim1,
          Animation<double> anim2) {
        return WorkoutDialog(
          min: min!,
          calories: calories!,
          watts: watts!,
          sweatCoints: sweatCoints!,
        );
      },
      transitionBuilder: (BuildContext context, Animation<double> anim1,
          Animation<double> anim2, Widget child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
    );
  }
}
