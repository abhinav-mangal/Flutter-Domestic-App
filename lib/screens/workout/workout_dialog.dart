import 'package:energym/app_config.dart';
import 'package:energym/reusable_component/loader_button.dart';
import 'package:energym/screens/AnimationCounter/animation_counter.dart';
import 'package:energym/utils/common/circle_button.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';

class WorkoutDialog extends StatefulWidget {
  const WorkoutDialog({
    Key? key,
    required this.min,
    required this.calories,
    required this.watts,
    required this.sweatCoints,
  }) : super(key: key);
  final int? min;
  final int? calories;
  final int? watts;
  final int? sweatCoints;

  @override
  _WorkoutDialogState createState() => _WorkoutDialogState();
}

class _WorkoutDialogState extends State<WorkoutDialog> {
  int? _min;
  int? _calories;
  int? _watts;
  int? _sweatCoints;

  @override
  void initState() {
    super.initState();
    _min = widget.min ?? 30;
    _calories = widget.calories ?? 250;
    _watts = widget.watts ?? 120;
    _sweatCoints = widget.sweatCoints ?? 120;
  }

  AppConfig? _config;
  @override
  Widget build1(BuildContext context) {
    _config = AppConfig.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.only(bottom: 24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: CircleButton(
              iconName: ImgConstants.close,
              borderColor: _config!.lightGreyColor,
              isBorderd: false,
              iconSize: 15,
              iconColor: _config!.whiteColor,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsetsDirectional.fromSTEB(24, 32, 24, 24),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _config!.whiteColor),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _widgetHeader(),
                    _widgetWorkoutValue(),
                    _btnStartWorkOut(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: CircleButton(
          iconName: ImgConstants.close,
          borderColor: _config!.lightGreyColor,
          isBorderd: false,
          iconSize: 15,
          iconColor: _config!.whiteColor,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
        child: Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.fromSTEB(24, 32, 24, 24),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _config!.whiteColor),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _widgetHeader(),
                _widgetWorkoutValue(),
                _btnStartWorkOut(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _widgetHeader() {
    return Text(
      AppConstants.youGotThis,
      style: _config!.antonioHeading1FontStyle
          .apply(color: _config!.btnPrimaryColor),
    );
  }

  Widget _widgetWorkoutValue() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 32, 0, 32),
      child: AspectRatio(
        aspectRatio: 295 / 225,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: _config!.blackColor.withAlpha(10),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: _widgetMinCalories(),
                ),
              ),
              const SizedBox(
                height: 1,
              ),
              Expanded(
                child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: _widgetwattsSweatCoin()),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _widgetMinCalories() {
    return Row(
      children: [
        Expanded(
          child: Container(
              width: double.infinity,
              height: double.infinity,
              color: _config!.whiteColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_min m',
                    style: _config!.antonioHeading1FontStyle
                        .apply(color: _config!.blackColor),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    AppConstants.duration,
                    style: _config!.paragraphNormalFontStyle
                        .apply(color: _config!.blackColor),
                  )
                ],
              )),
        ),
        const SizedBox(
          width: 1,
        ),
        Expanded(
          child: Container(
              width: double.infinity,
              height: double.infinity,
              color: _config!.whiteColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_calories',
                    style: _config!.antonioHeading1FontStyle
                        .apply(color: _config!.blackColor),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    AppConstants.calories,
                    style: _config!.paragraphNormalFontStyle
                        .apply(color: _config!.blackColor),
                  )
                ],
              )),
        ),
      ],
    );
  }

  Widget _widgetwattsSweatCoin() {
    return Row(
      children: [
        Expanded(
          child: Container(
              width: double.infinity,
              height: double.infinity,
              color: _config!.whiteColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_watts\W',
                    style: _config!.antonioHeading1FontStyle
                        .apply(color: _config!.blackColor),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    AppConstants.watts,
                    style: _config!.paragraphNormalFontStyle
                        .apply(color: _config!.blackColor),
                  )
                ],
              )),
        ),
        const SizedBox(
          width: 1,
        ),
        Expanded(
          child: Container(
              width: double.infinity,
              height: double.infinity,
              color: _config!.whiteColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_sweatCoints',
                    style: _config!.antonioHeading1FontStyle
                        .apply(color: _config!.blackColor),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    AppConstants.sweatCoins,
                    style: _config!.paragraphNormalFontStyle
                        .apply(color: _config!.blackColor),
                  )
                ],
              )),
        ),
      ],
    );
  }

  Widget _btnStartWorkOut() {
    return LoaderButton(
        backgroundColor: _config!.btnPrimaryColor,
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        onPressed: () async {
          Navigator.popAndPushNamed(context, AnimationCounter.routeName, arguments: AnimationCounterArgs(
              isLiveCalibration: false, isBuildworkout: false,
            ),
          );
        },
        title: AppConstants.starMyWorkOut);
  }
}
