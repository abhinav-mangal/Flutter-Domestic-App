import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/screens/workout/complete_animation.dart';
import 'package:energym/screens/workout/green_zone/livecalibrationworkout.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/helpers/routing/router.dart';
import 'package:flutter/material.dart';

// This is greemn zone workout summary contians workout summary data
class CalibrationCompleteWorkoutArgs extends RoutesArgs {
  CalibrationCompleteWorkoutArgs({
    required this.workoutData,
  }) : super(isHeroTransition: true);
  final Map<String, dynamic>? workoutData;
}

class CalibrationCompleteWorkout extends StatefulWidget {
  CalibrationCompleteWorkout({Key? key, required this.workoutData})
      : super(key: key);
  static const String routeName = '/CalibrationCompleteWorkout';
  final Map<String, dynamic>? workoutData;
  @override
  _CalibrationCompleteWorkoutState createState() =>
      _CalibrationCompleteWorkoutState();
}

class _CalibrationCompleteWorkoutState extends State<CalibrationCompleteWorkout>
    with TickerProviderStateMixin {
  AppConfig? _config;
  UserModel? _currentUser;
  AnimationController? _buttonController;

  Map<String, dynamic>? _workoutData;
  @override
  void initState() {
    _currentUser = aGeneralBloc.currentUser;
    _workoutData = widget.workoutData;

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _buttonController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: _widgetMainContainer(),
            ),
            StaggerAnimation(buttonController: _buttonController!.view)
          ],
        ),
      ),
    );
    ;
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _config!,
        backgoundColor: Colors.transparent,
        textColor: _config!.whiteColor,
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
        actions: <Widget>[
          btnSweatCointBalance(context, _config!),
        ]);
  }

  Widget _widgetMainContainer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            AppConstants.greenZoneSummary,
            style: _config!.able36FontStyle
                .apply(color: _config!.whiteColor, fontSizeFactor: 0.5),
          ),
          _widgetHeaderTitle(),
          _widgetSweatCoinIcon(),
          _widgetWattsGenerated(),
          _widgetWorkoutInfo(),
          _widgetGraph(),
          _widgetShare()
        ],
      ),
    );
  }

  Widget _widgetHeaderTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 23.0),
      child: Text(AppConstants.youSmashedIt,
          style: _config!.antonioHeading1FontStyle
              .apply(color: _config!.whiteColor),
          textAlign: TextAlign.center),
    );
  }

  Widget _widgetSweatCoinIcon() {
    return Padding(
      padding: const EdgeInsets.only(top: 37.0),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: _config!.btnPrimaryColor.withOpacity(0.20)),
        child: Center(
          child: Image.asset(
            ImgConstants.logoR,
            color: _config!.btnPrimaryColor,
            width: 40,
            height: 40,
          ),
        ),
      ),
    );
  }

  Widget _widgetWattsGenerated() {
    final double wattGenerated =
        double.parse('${_workoutData![WorkoutDataKey.wattsGenerated]}');
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        children: [
          _widgetGeneratedValues(wattGenerated),
          const SizedBox(
            height: 4,
          ),
          Text(AppConstants.wattsGenerated,
              style: _config!.paragraphNormalFontStyle
                  .apply(color: _config!.greyColor),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _widgetGeneratedValues(double value) {
    return Text(value.toString(),
        style:
            _config!.antonioHeading1FontStyle.apply(color: _config!.whiteColor),
        textAlign: TextAlign.center);
  }

  Widget _widgetWorkoutInfo() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
      child: Container(
        width: double.infinity,
        // height: 145,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _widgetOldFTP(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Image.asset(
                ImgConstants.arrowftp,
                width: 30,
              ),
            ),
            _widgetNewFTP(),
          ],
        ),
      ),
    );
  }

  Widget _widgetOldFTP() {
    return Column(
      children: [
        Text(
          AppConstants.oldFTP,
          style: _config!.antonioHeading2FontStyle
              .apply(color: _config!.whiteColor),
        ),
        Text(
          "${_currentUser?.ftpValue}",
          style: _config!.antonioHeading1FontStyle
              .apply(color: _config!.btnPrimaryColor),
        )
      ],
    );
  }

  Widget _widgetNewFTP() {
    final double wattGenerated =
        double.parse('${_workoutData![WorkoutDataKey.wattsGenerated]}');
    return Column(
      children: [
        Text(
          AppConstants.newFTP,
          style: _config!.antonioHeading2FontStyle
              .apply(color: _config!.whiteColor),
        ),
        Text(
          globalMins == 5
              ? '${(wattGenerated * 0.85).round()}'
              : '${(wattGenerated * 0.95).round()}',
          style: _config!.antonioHeading1FontStyle
              .apply(color: _config!.btnPrimaryColor),
        )
      ],
    );
  }

  Widget _widgetGraph() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 30, 16, 0),
      child: Container(
        width: double.infinity,
        child: AspectRatio(
          aspectRatio: 343 / 170,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            // decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(8),
            //     color: _config!.borderColor),
          ),
        ),
      ),
    );
  }

  Widget _widgetShare() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 71, bottom: 15),
        child: TextButton(
          onPressed: () {
            CustomAlertDialog().confirmationDialog(
              title: AppConstants.workoutShare,
              message: AppConstants.workoutShareMsg,
              cancelButtonTitle: AppConstants.dismiss,
              okButtonTitle: AppConstants.share,
              okButtonBgColor: _config!.btnPrimaryColor,
              context: context,
              onSuccess: () {
                aGeneralBloc.updateAPICalling(true);

                FireStoreProvider.instance.createPost(
                  context: context,
                  userData: _currentUser!,
                  postType: PostType.ftpWorkout,
                  postTitle: AppConstants.smashedTodaysWorkout,
                  postData: _workoutData!,
                  onSuccess: (Map<String, dynamic> successResponse) {
                    aGeneralBloc.updateAPICalling(false);
                    Future.delayed(
                      Duration(milliseconds: 100),
                      () {
                        Navigator.pop(context);
                      },
                    );
                  },
                  onError: (Map<String, dynamic> errorResponse) {
                    aGeneralBloc.updateAPICalling(false);
                    Future.delayed(
                      Duration(milliseconds: 100),
                      () {
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SvgIcon.asset(
                ImgConstants.share,
                size: 20,
                color: _config!.btnPrimaryColor,
              ),
              const SizedBox(
                width: 11,
              ),
              Text(
                AppConstants.shareWithFollower,
                style: _config!.linkSmallFontStyle.apply(
                  color: _config!.btnPrimaryColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
