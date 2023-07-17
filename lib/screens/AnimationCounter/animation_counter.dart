import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../reusable_component/custom_scaffold.dart';
import '../../utils/common/constants.dart';
import '../../utils/helpers/routing/router.dart';
import '../../utils/theme/colors.dart';
import '../workout/build_workout/livebuildmyworkout.dart';
import '../workout/green_zone/livecalibrationworkout.dart';
import '../workout/hit_my_daily_goal/live_workout_hitmydailygoal.dart';
import '../workout/instant_workout/live_workout.dart';
import 'circular_countdown_timer.dart';

// Animator counter screen having counter and it will show before start workout
class AnimationCounterArgs extends RoutesArgs {
  AnimationCounterArgs(
      {required this.isLiveCalibration,
      required this.isBuildworkout,
      this.mins,
      this.index,
      this.isHitMyDailyGoal})
      : super(isHeroTransition: true);
  final bool? isLiveCalibration;
  final bool? isBuildworkout;
  final int? mins;
  final int? index;
  final bool? isHitMyDailyGoal;
}

class AnimationCounter extends StatefulWidget {
  const AnimationCounter(
      {Key? key,
      required this.isLiveCalibration,
      required this.isBuildworkout,
      this.mins,
      this.index,
      this.isHitMyDailyGoal})
      : super(key: key);

  static const String routeName = '/AnimationCounter';
  final bool? isLiveCalibration;
  final bool? isBuildworkout;
  final int? mins;
  final int? index;
  final bool? isHitMyDailyGoal;
  @override
  _AnimationCounterState createState() => _AnimationCounterState();
}

class _AnimationCounterState extends State<AnimationCounter>
    with TickerProviderStateMixin {
  AppConfig? _config;
  bool? _isLiveCalibration;
  bool? _isBuildworkout;
  int? _mins;
  int? _index;
  bool? _isHitMyDailyGoal;
  CountDownController _controller = CountDownController();
  int _duration = 5;

  @override
  void initState() {
    _isLiveCalibration = widget.isLiveCalibration;
    _isBuildworkout = widget.isBuildworkout;
    _mins = widget.mins;
    _index = widget.index;
    _isHitMyDailyGoal = widget.isHitMyDailyGoal;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsetsDirectional.fromSTEB(48, 0, 48, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(AppConstants.relax,
                style: _config!.antonioHeading1FontStyle
                    .apply(color: _config!.whiteColor),
                textAlign: TextAlign.center),
            const AspectRatio(
              aspectRatio: 375 / 100,
              child: SizedBox(
                height: double.infinity,
              ),
            ),
            AspectRatio(
              aspectRatio: 280 / 280,
              child: CircularCountDownTimer(
                // Countdown duration in Seconds.
                duration: _duration,

                // Countdown initial elapsed Duration in Seconds.
                initialDuration: 0,

                // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
                controller: _controller,

                // Width of the Countdown Widget.
                width: double.infinity,

                // Height of the Countdown Widget.
                height: double.infinity,

                // Ring Color for Countdown Widget.
                ringColor: _config!.borderColor,

                // Filling Color for Countdown Widget.
                fillColor: (_isBuildworkout ?? false)
                    ? AppColors.blueworkout
                    : (_isHitMyDailyGoal ?? false)
                        ? AppColors.orangeworkout
                        : _config!.btnPrimaryColor,

                // Border Thickness of the Countdown Ring.
                strokeWidth: 1.0,

                // Begin and end contours with a flat edge and no extension.
                strokeCap: StrokeCap.round,

                // Text Style for Countdown Text.
                textStyle: (_isBuildworkout ?? false)
                    ? _config!.antonioTimerFontStyle
                        .copyWith(color: AppColors.blueworkout)
                    : (_isHitMyDailyGoal ?? false)
                        ? _config!.antonioTimerFontStyle
                            .copyWith(color: AppColors.orangeworkout)
                        : _config!.antonioTimerFontStyle,

                // Format for the Countdown Text.
                textFormat: CountdownTextFormat.S,

                // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
                isReverse: true,

                // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
                isReverseAnimation: true,

                // Handles the timer start.
                autoStart: true,

                // This Callback will execute when the Countdown Starts.
                onStart: () {
                  // Here, do whatever you want
                  print('Countdown Started');
                },

                // This Callback will execute when the Countdown Ends.
                onComplete: () {
                  // Here, do whatever you want
                  if (_isLiveCalibration ?? false) {
                    Navigator.popAndPushNamed(
                        context, LiveCalibrationWorkout.routeName,
                        arguments: LiveCalibrationWorkoutArgs(mins: _mins));
                  } else if (_isBuildworkout ?? false) {
                    Navigator.popAndPushNamed(
                        context, LiveBuildWorkout.routeName,
                        arguments:
                            LiveBuildWorkoutArgs(mins: _mins, index: _index));
                  } else if (_isHitMyDailyGoal ?? false) {
                    Navigator.popAndPushNamed(
                        context, LiveHitMyDailyGoalWorkout.routeName);
                  } else {
                    Navigator.popAndPushNamed(context, LiveWorkout.routeName);
                  }
                },
              ),
            ),
            const AspectRatio(
              aspectRatio: 375 / 100,
              child: SizedBox(
                height: double.infinity,
              ),
            ),
            _btnSkip()
          ],
        ),
      ),
      floatingActionButton: null,
    );
  }

  Widget _btnSkip() {
    return TextButton(
      onPressed: () {
        if (_isLiveCalibration ?? false) {
          Navigator.popAndPushNamed(context, LiveCalibrationWorkout.routeName,
              arguments: LiveCalibrationWorkoutArgs(mins: _mins));
        } else if (_isBuildworkout ?? false) {
          Navigator.popAndPushNamed(context, LiveBuildWorkout.routeName,
              arguments: LiveBuildWorkoutArgs(mins: _mins, index: _index));
        } else if (_isHitMyDailyGoal ?? false) {
          Navigator.popAndPushNamed(
              context, LiveHitMyDailyGoalWorkout.routeName);
        } else {
          Navigator.popAndPushNamed(context, LiveWorkout.routeName);
        }
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      child: Text(AppConstants.skip,
          style:
              _config!.paragraphLargeFontStyle.apply(color: _config!.greyColor),
          textAlign: TextAlign.center),
    );
  }
}
