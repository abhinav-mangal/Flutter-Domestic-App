import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/shared_pref_helper.dart';
import 'package:energym/screens/MarketPlace/marketplace.dart';
import 'package:energym/screens/community/community.dart';
import 'package:energym/screens/dashboard/dashboard.dart';
import 'package:energym/screens/feed/feed_details.dart';
import 'package:energym/screens/notification/notification.dart';
import 'package:energym/screens/user_profile/user_pofile.dart';
import 'package:energym/screens/workout/green_zone/green_zone.dart';
import 'package:energym/screens/workout/workout.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/config.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/fab_fill.dart';
import 'package:energym/utils/helpers/device_info.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/helpers/push_nofitications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key, this.sourceRect}) : super(key: key);

  static const String routeName = '/Home';
  static Route<dynamic> route(BuildContext context, GlobalKey key) {
    final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    final Rect sourceRect = box.localToGlobal(Offset.zero) & box.size;

    return PageRouteBuilder<void>(
      pageBuilder: (BuildContext context, _, __) =>
          Home(sourceRect: sourceRect),
      transitionDuration: const Duration(milliseconds: 600),
    );
  }

  final Rect? sourceRect;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AppConfig? _config;

  //List<BottomNavigationBarItem> _widgetBottomItem = [];
  int selectedIndex = 0;
  List<Widget> widgetOptions = <Widget>[];
  UserModel? _currentUser;
  @override
  void initState() {
    super.initState();
    _setUpWidgetTabBarAsPerUser();
    FireStoreProvider.instance.fetchCurrentUser();
    PushNotificationsManager().init(context);
    registerDeviceToken();
    fromNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return FabFillTransition(
      source: widget.sourceRect ??
          Rect.fromCenter(center: Offset(0, 0), width: 0, height: 0),
      child: CustomScaffold(
        bottomNavigationBar: _widgetBottomNavigationBar(context),
        body: SafeArea(
          top: false,
          bottom: false,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              child: Center(
                child: _mainContainerScreen(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _widgetBottomNavigationBar(BuildContext mainContext) {
    // ignore: always_specify_types
    return StreamBuilder<DocumentSnapshot?>(
      stream: FireStoreProvider.instance.getCurrentUserUpdate,
      builder:
          // ignore: always_specify_types
          (BuildContext context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.data() != null) {
          _currentUser = UserModel.fromJson(
              snapshot.data!.data() as Map<String, dynamic>,
              doumentId: snapshot.data!.id);
          // aGeneralBloc.updateCurrentUser(_currentUser!);
        }

        return Container(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            child: Theme(
              data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                key: globalKeyBottomBard,
                backgroundColor: _config!.windowBackground,
                showUnselectedLabels: true,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle: _config!.labelSmallFontStyle,
                unselectedLabelStyle: _config!.labelSmallFontStyle,
                currentIndex: selectedIndex,
                selectedItemColor: _config!.btnPrimaryColor,
                unselectedItemColor: _config!.greyColor,
                onTap: onItemTapped,
                items: <BottomNavigationBarItem>[
                  _tabBarItem(
                      imageName: ImgConstants.tabDashboard,
                      title: AppConstants.tabDashboard),
                  _tabBarItem(
                      imageName: ImgConstants.tabCommunity,
                      title: AppConstants.tabCommunity),
                  _tabBarItem(
                      imageName: ImgConstants.tabWorkout,
                      title: AppConstants.tabWorkout),
                  _tabBarItem(
                      imageName: ImgConstants.tabMarketPlace,
                      title: AppConstants.tabMarketplace),
                  _tabBarItem(
                    imageName: ImgConstants.tabWorkout,
                    title: AppConstants.tabProfile,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _tabBarItem({
    String? imageName,
    String? title,
  }) {
    return BottomNavigationBarItem(
      backgroundColor: _config!.windowBackground,
      tooltip: '',
      icon: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
        child: title == AppConstants.tabProfile
            ? _currentUser?.profilePhoto == null
                ? CircularImage(
                    '',
                    height: 24,
                    width: 24,
                  )
                : CircularImage(
                    _currentUser!.profilePhoto!,
                    height: 24,
                    width: 24,
                  )
            : SvgPicture.asset(
                imageName!,
                width: 24,
                height: 24,
                color: _config!.greyColor,
              ),
      ),
      activeIcon: Container(
        padding: EdgeInsets.zero,
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
              child: Container(
                padding: EdgeInsets.zero,
                width: 20,
                height: 20,
                child: title == AppConstants.tabProfile
                    ? _currentUser?.profilePhoto == null
                        ? SpinKitCircle(
                            color: _config!.btnPrimaryColor,
                            size: 15,
                          )
                        : CircularImage(
                            _currentUser!.profilePhoto!,
                            height: 24,
                            width: 24,
                          )
                    : SvgPicture.asset(
                        imageName!,
                        width: 24,
                        height: 24,
                        color: _config!.btnPrimaryColor,
                      ),
              ),
            )
          ],
        ),
      ),
      label: title,

      //backgroundColor: context.theme.accentColor
    );
  }

  void onItemTapped(int index) {
    setState(
      () {
        selectedIndex = index;
      },
    );
  }

  void _setUpWidgetTabBarAsPerUser() {
    widgetOptions = <Widget>[
      Dashboard(),
      Community(),
      Workout(),
      MarketPlace(),
      // StreamBuilder<DocumentSnapshot?>(
      //     stream: FireStoreProvider.instance.getCurrentUserUpdate,
      //     builder: (BuildContext context,
      //         AsyncSnapshot<DocumentSnapshot?> snapshot) {
      //       if (snapshot.hasData &&
      //           snapshot.data != null &&
      //           snapshot.data!.data() != null) {
      //         _currentUser = UserModel.fromJson(
      //             snapshot.data!.data() as Map<String, dynamic>,
      //             doumentId: snapshot.data!.id);
      //         aGeneralBloc.updateCurrentUser(_currentUser!);
      //       }

      UserProfile(
        isLoggedInUser: true,
        userId: _currentUser?.documentId, //_currentUser?.documentId ?? '',
      ),
      // })
    ];
  }

  Widget _mainContainerScreen(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      width: double.infinity,
      height: double.infinity,
      child: widgetOptions.elementAt(selectedIndex),
    );
  }

  void fromNotification(BuildContext mainContext) async {
    bool isOpenformNotification =
        generalNotificationBloc.getIsOpenFromNotification();
    if (isOpenformNotification) {
      await Future.delayed(Duration(seconds: 1));

      final String entity = generalNotificationBloc.getPushEntityId();
      final String type = generalNotificationBloc.getPushType();
      redirectNotification(
        type,
        entity,
      );
    }
  }

  void redirectNotification(String type, String dataId) {
    generalNotificationBloc.updateType(null);
    generalNotificationBloc.updateEntity(null);
    generalNotificationBloc.updateIsOpenFromNotification(null);
    switch (type) {
      case NotificationType.likePost:
        Navigator.pushNamed(
          context,
          FeedDetails.routeName,
          arguments: FeedDetailsArgs(feedId: dataId),
        );
        break;
      case NotificationType.commentPost:
        Navigator.pushNamed(
          context,
          FeedDetails.routeName,
          arguments: FeedDetailsArgs(feedId: dataId),
        );
        break;
      case NotificationType.ftpReminder:
        Navigator.pushNamed(
          context,
          GreenZone.routeName,
        );
        break;
      case NotificationType.follower:
        Navigator.pushNamed(
          context,
          AppNotification.routeName,
        );
        break;
      case NotificationType.inviteGroupMember:
        Navigator.pushNamed(
          context,
          AppNotification.routeName,
        );
        break;
      default:
        break;
    }
  }

  Future<void> registerDeviceToken() async {
    DeviceInfo _deviceInfo = Provider.of<DeviceInfo>(context, listen: false);
    String deviceType = _deviceInfo.os!;
    final String fcmToken =
        await sharedPrefsHelper.get(SharedPrefskey.fcmToken) as String;
    FireStoreProvider.instance.saveDeviceToken(
      context: context,
      deviceType: deviceType,
      deviceToke: fcmToken,
      isLogOut: false,
    );
  }
}
