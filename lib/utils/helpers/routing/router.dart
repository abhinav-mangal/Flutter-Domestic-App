import 'package:energym/reusable_component/countryPicker/country_picker.dart';
import 'package:energym/screens/AnimationCounter/animation_counter.dart';
import 'package:energym/screens/cms/cms.dart';
import 'package:energym/screens/comment/comment.dart';
import 'package:energym/screens/dashboard/graph_details.dart';
import 'package:energym/screens/device_connection/device_connection.dart';
import 'package:energym/screens/feed/add_feed.dart';
import 'package:energym/screens/feed/feed_details.dart';
import 'package:energym/screens/followers/add_followers.dart';
import 'package:energym/screens/followers/add_group.dart';
import 'package:energym/screens/followers/contacts.dart';
import 'package:energym/screens/group/groupmemberlist.dart';
import 'package:energym/screens/group/invite_member.dart';
import 'package:energym/screens/home/home.dart';
import 'package:energym/screens/introduction/intro_slider.dart';
import 'package:energym/screens/login/login.dart';
import 'package:energym/screens/notification/notification.dart';
import 'package:energym/screens/otp/otp.dart';
import 'package:energym/screens/profile_setup/profile_complete.dart';
import 'package:energym/screens/profile_setup/profile_setup.dart';
import 'package:energym/screens/settings/settings.dart';
import 'package:energym/screens/splash.dart/splash.dart';
import 'package:energym/screens/transaction/transaction.dart';
import 'package:energym/screens/user_profile/edit_user_profile.dart';
import 'package:energym/screens/user_profile/user_pofile.dart';
import 'package:energym/screens/workout/build_workout/build_workout.dart';
import 'package:energym/screens/workout/build_workout/buildmyworkoutlist.dart';
import 'package:energym/screens/workout/build_workout/buildmyworkouttime.dart';
import 'package:energym/screens/workout/build_workout/livebuildmyworkout.dart';
import 'package:energym/screens/workout/complete_workout.dart';
import 'package:energym/screens/workout/green_zone/calibrationcompleteworkout.dart';
import 'package:energym/screens/workout/green_zone/green_zone.dart';
import 'package:energym/screens/workout/green_zone/livecalibrationworkout.dart';
import 'package:energym/screens/workout/hit_my_daily_goal/hitmydailygoal.dart';
import 'package:energym/screens/workout/hit_my_daily_goal/hitmydailygoaledit.dart';
import 'package:energym/screens/workout/hit_my_daily_goal/live_workout_hitmydailygoal.dart';
import 'package:energym/screens/workout/instant_workout/live_workout.dart';
import 'package:energym/screens/workout/update_workout.dart';
import 'package:energym/screens/your_planet.dart';
import 'package:flutter/material.dart';

typedef RouteWidgetBuilder = Widget Function(
  BuildContext context,
  RouteSettings settings,
);

final Map<String, Function> routes = {
  Splash.routeName: (BuildContext context) => Splash(),
  IntroSlider.routeName: (BuildContext context) => IntroSlider(),
  Login.routeName: (BuildContext context) => Login(),
  CountryPicker.routeName: (BuildContext context) => CountryPicker(),
  OtpVerification.routeName: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final OtpVerificationArgs args =
          settings.arguments as OtpVerificationArgs;
      return OtpVerification(
        code: args.code ?? '',
        mobile: args.mobile ?? '',
        isNewUser: args.isNewUser ?? true,
        verificationId: args.verificationId ?? '',
        isReauthentication: args.isReauthentication ?? false,
      );
    };
    return builder;
  },
  CMS.routeName: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final CmsArgs args = settings.arguments as CmsArgs;
      return CMS(
        //isShowAgreeButton: args.isShowAgreeButton ?? false,
        cmsType: args.cmsType,
      );
    };
    return builder;
  },
  ProfileSetUp.routeName!: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final ProfileSetUpArgs args = settings.arguments as ProfileSetUpArgs;
      return ProfileSetUp(
        isNewUser: args.isNewUser ?? true,
        userId: args.userId,
        currentStep: args.currentStep ?? 0,
      );
    };
    return builder;
  },
  ProfileComplete.routeName: (BuildContext context) => ProfileComplete(),
  Home.routeName: (BuildContext context) => const Home(),
  EditProfile.routeName: (BuildContext context) => EditProfile(),
  YourPlanet.routeName: (BuildContext context) => YourPlanet(),
  AddFollowers.routeName: (BuildContext context) => AddFollowers(),
  ContactList.routeName: (BuildContext context) => ContactList(),
  AddFeed.routeName: (BuildContext context) => AddFeed(),
  Comment.routeName: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final CommentArgs args = settings.arguments as CommentArgs;
      return Comment(
        feedId: args.feedId,
      );
    };
    return builder;
  },
  AddGroup.routeName: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final AddGroupArgs args = settings.arguments as AddGroupArgs;
      return AddGroup(
        groupModel: args.groupModel,
      );
    };
    return builder;
  },
  UserProfile.routeName!: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final UserProfileArgs args = settings.arguments as UserProfileArgs;
      return UserProfile(
        isLoggedInUser: args.isLoggedInUser ?? false,
        userId: args.userId,
        isShowBack: args.isShowBack,
      );
    };
    return builder;
  },
  AppSettings.routeName: (BuildContext context) => AppSettings(),
  AppNotification.routeName: (BuildContext context) => AppNotification(),
  FeedDetails.routeName: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final FeedDetailsArgs args = settings.arguments as FeedDetailsArgs;
      return FeedDetails(
        feedId: args.feedId,
      );
    };
    return builder;
  },
  DeviceConnection.routeName: (BuildContext context) =>
      const DeviceConnection(),
  BuildWorkout.routeName: (BuildContext context) => const BuildWorkout(),
  AnimationCounter.routeName: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final AnimationCounterArgs args =
          settings.arguments as AnimationCounterArgs;
      return AnimationCounter(
        isLiveCalibration: args.isLiveCalibration,
        isBuildworkout: args.isBuildworkout,
        mins: args.mins,
        index: args.index,
        isHitMyDailyGoal: args.isHitMyDailyGoal,
      );
    };
    return builder;
  },
  LiveWorkout.routeName: (BuildContext context) => const LiveWorkout(),
  UpdateWorkout.routeName: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final UpdateWorkoutArgs args = settings.arguments as UpdateWorkoutArgs;
      return UpdateWorkout(
        workoutValue: args.workoutValue!,
        value: args.value,
      );
    };
    return builder;
  },
  CompleteWorkout.routeName: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final CompleteWorkoutArgs args =
          settings.arguments as CompleteWorkoutArgs;
      return CompleteWorkout(
        workoutData: args.workoutData,
      );
    };
    return builder;
  },
  GraphDetails.routeName: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final GraphDetailsArgs args = settings.arguments as GraphDetailsArgs;
      return GraphDetails(
        workoutType: args.workoutType,
        healthkitValue: args.healthkitValue,
        ourAppValue: args.ourAppValue,
        sumValue: args.sumValue,
        targetedValue: args.targetedValue,
      );
    };
    return builder;
  },
  Transaction.routeName: (BuildContext context) => const Transaction(),
  GreenZone.routeName: (BuildContext context) => const GreenZone(),
  LiveCalibrationWorkout.routeName: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final LiveCalibrationWorkoutArgs args =
          settings.arguments as LiveCalibrationWorkoutArgs;
      return LiveCalibrationWorkout(
        mins: args.mins,
      );
    };
    return builder;
  },
  CalibrationCompleteWorkout.routeName: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final CalibrationCompleteWorkoutArgs args =
          settings.arguments as CalibrationCompleteWorkoutArgs;
      return CalibrationCompleteWorkout(
        workoutData: args.workoutData,
      );
    };
    return builder;
  },
  BuildMyWorkout.routeName: (BuildContext context) => BuildMyWorkout(),
  BuildMyWorkoutTime.routeName: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final BuildMyWorkoutTimeArgs args =
          settings.arguments as BuildMyWorkoutTimeArgs;
      return BuildMyWorkoutTime(
        index: args.index,
      );
    };
    return builder;
  },
  LiveBuildWorkout.routeName: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final LiveBuildWorkoutArgs args =
          settings.arguments as LiveBuildWorkoutArgs;
      return LiveBuildWorkout(
        mins: args.mins,
        index: args.index,
      );
    };
    return builder;
  },
  HitMyDailyGoal.routeName: (BuildContext context) => HitMyDailyGoal(),
  EditGoal.routeName: (BuildContext context) => EditGoal(),
  LiveHitMyDailyGoalWorkout.routeName: (BuildContext context) =>
      LiveHitMyDailyGoalWorkout(),
  GroupMembers.routeName: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final GroupMembersArgs args = settings.arguments as GroupMembersArgs;
      return GroupMembers(
        groupModel: args.groupModel,
      );
    };
    return builder;
  },
  GroupSettings.routeName: (RouteSettings settings) {
    WidgetBuilder builder = (BuildContext context) {
      final GroupSettingsArgs args = settings.arguments as GroupSettingsArgs;
      return GroupSettings(
        groupModel: args.groupModel,
      );
    };
    return builder;
  },
};

class RoutesArgs {
  RoutesArgs({this.isHeroTransition = false});

  final bool isHeroTransition;
}

class Routers {
  static String initialRoute = Splash.routeName;
  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    if (routes.containsKey(routeSettings.name)) {
      return _getPageRoute(routeSettings);
      // } else if (dialogRoutes.containsKey(routeSettings.name)) {
      //   return _getDialogRoute(routeSettings);
    } else {
      return null;
    }
  }

  static Route<dynamic> _getPageRoute(RouteSettings routeSettings) {
    final Function builder = routes[routeSettings.name]!;
    // ignore: lines_longer_than_80_chars
    final WidgetBuilder widgetBuilder =
        _getWidgetBuilder(builder, routeSettings) as WidgetBuilder;

    final bool isHeroTransition = routeSettings.arguments is RoutesArgs &&
        (routeSettings.arguments as RoutesArgs).isHeroTransition;
    if (routeSettings.name == '/CompleteWorkout') {
      return MyCustomRoute(
        builder: (context) => widgetBuilder(context),
        settings: routeSettings,
      );
    } else {
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          return widgetBuilder(context);
        },
      );
    }
  }

  static dynamic _getWidgetBuilder(
      Function builder, RouteSettings routeSettings) {
    return builder is WidgetBuilder ? builder : builder(routeSettings);
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder? builder, RouteSettings? settings})
      : super(builder: builder!, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // if (settings.arguments) return child;
    return FadeTransition(opacity: animation, child: child);
  }
}
