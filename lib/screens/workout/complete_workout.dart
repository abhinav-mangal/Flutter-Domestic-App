import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/screens/workout/complete_animation.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/helpers/routing/router.dart';
import 'package:flutter/material.dart';

// This is complete workout screen means workout summary
class CompleteWorkoutArgs extends RoutesArgs {
  CompleteWorkoutArgs({
    required this.workoutData,
  }) : super(isHeroTransition: true);
  final Map<String, dynamic>? workoutData;
}

class CompleteWorkout extends StatefulWidget {
  CompleteWorkout({Key? key, required this.workoutData}) : super(key: key);
  static const String routeName = '/CompleteWorkout';
  final Map<String, dynamic>? workoutData;
  @override
  _CompleteWorkoutState createState() => _CompleteWorkoutState();
}

class _CompleteWorkoutState extends State<CompleteWorkout>
    with TickerProviderStateMixin {
  AppConfig? _config;
  UserModel? _currentUser;

  //Animation<double>? containerGrowAnimation;
  //AnimationController? _screenController;
  AnimationController? _buttonController;
  //Animation<Color?>? fadeScreenAnimation;
  Map<String, dynamic>? _workoutData;
  @override
  void initState() {
    _currentUser = aGeneralBloc.currentUser;
    _workoutData = widget.workoutData;
    // _screenController = AnimationController(
    //     duration: const Duration(milliseconds: 3000), vsync: this);
    _buttonController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);

    // fadeScreenAnimation = ColorTween(
    //   begin: Colors.green,
    //   end: Colors.green.withOpacity(0),
    // ).animate(
    //   CurvedAnimation(
    //     parent: _screenController!,
    //     curve: Curves.ease,
    //   ),
    // );
    // containerGrowAnimation = CurvedAnimation(
    //   parent: _screenController!,
    //   curve: Curves.easeIn,
    // );

    // _screenController!.forward();
    super.initState();
  }

  @override
  void dispose() {
    //  _screenController!.dispose();
    _buttonController!.dispose();
    super.dispose();
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
        title: AppConstants.workoutSummary,
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
              Future.delayed(
                Duration(milliseconds: 100),
                () {
                  Navigator.pop(context);
                },
              );
            }),
        actions: <Widget>[
          btnSweatCointBalance(context, _config!),
        ]);
  }

  Widget _widgetMainContainer() {
    return SingleChildScrollView(
      child: Column(
        children: [
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
        _workoutData![WorkoutDataKey.wattsGenerated] as double;
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
        height: 145,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _widgetCaloriesBurned(),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 0),
              child: Container(
                width: 1,
                height: double.infinity,
                color: _config!.whiteColor.withOpacity(0.10),
              ),
            ),
            _widgetSeatcoinEarned(),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 0),
              child: Container(
                width: 1,
                height: double.infinity,
                color: _config!.whiteColor.withOpacity(0.10),
              ),
            ),
            _widgetMilesCoverd(),
          ],
        ),
      ),
    );
  }

  Widget _widgetCaloriesBurned() {
    final int caloriesBurned =
        _workoutData![WorkoutDataKey.caloriesBurned] as int;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SvgIcon.asset(
          ImgConstants.burn,
          color: _config!.orangeColor,
          size: 40,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(caloriesBurned.toString(),
            style: _config!.antonioHeading1FontStyle
                .apply(color: _config!.whiteColor),
            textAlign: TextAlign.center),
        const SizedBox(
          height: 4,
        ),
        Text(AppConstants.caloriesBurnedAnd,
            style: _config!.paragraphNormalFontStyle
                .apply(color: _config!.greyColor),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _widgetMilesCoverd() {
    final int milesCovered = _workoutData![WorkoutDataKey.milesCovered] as int;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SvgIcon.asset(
          ImgConstants.cycle,
          color: _config!.skyBlueColor,
          size: 40,
        ),
        const SizedBox(
          height: 8,
        ),
        Text('--',
            style: _config!.antonioHeading1FontStyle
                .apply(color: _config!.whiteColor),
            textAlign: TextAlign.center),
        const SizedBox(
          height: 4,
        ),
        Text(AppConstants.milesCovered,
            style: _config!.paragraphNormalFontStyle
                .apply(color: _config!.greyColor),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _widgetSeatcoinEarned() {
    final double sweatCoinsEarned =
        _workoutData![WorkoutDataKey.sweatCoinsEarned] as double;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SvgIcon.asset(
          ImgConstants.sweatCoin,
          color: _config!.btnPrimaryColor,
          size: 40,
        ),
        const SizedBox(
          height: 8,
        ),
        _widgetGeneratedValues(sweatCoinsEarned),
        const SizedBox(
          height: 4,
        ),
        Text(AppConstants.sweatcoinsEarned,
            style: _config!.paragraphNormalFontStyle
                .apply(color: _config!.greyColor),
            textAlign: TextAlign.center),
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
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _config!.borderColor),
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
                  postType: PostType.workout,
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
