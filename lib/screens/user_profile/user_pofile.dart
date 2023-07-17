import 'package:energym/app_config.dart';
import 'package:energym/main.dart';
import 'package:energym/models/feed_model.dart';
import 'package:energym/models/group_model.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/loader/load.dart';
import 'package:energym/reusable_component/loader/src/loading.dart';
import 'package:energym/reusable_component/skeleton.dart';
import 'package:energym/screens/feed/feed_bloc.dart';
import 'package:energym/screens/feed/widget_feed.dart';
import 'package:energym/screens/followers/follower_bloc.dart';
import 'package:energym/screens/followers/widget_group.dart';
import 'package:energym/screens/group/groupmemberlist.dart';
import 'package:energym/screens/notification/notification.dart';
import 'package:energym/screens/settings/settings.dart';
import 'package:energym/screens/user_profile/edit_user_profile.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/helpers/firebase/auth_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/helpers/routing/router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rxdart/rxdart.dart';

import '../your_planet.dart';

class UserProfileArgs extends RoutesArgs {
  UserProfileArgs(
      {required this.userId, required this.isLoggedInUser, this.isShowBack})
      : super(isHeroTransition: true);
  final String? userId;
  final bool? isLoggedInUser;
  final bool? isShowBack;
}

// This is user profile screen
class UserProfile extends StatefulWidget {
  const UserProfile(
      {Key? key,
      required this.userId,
      required this.isLoggedInUser,
      this.isShowBack})
      : super(key: key);

  static const String? routeName = '/UserProfile';
  final String? userId;
  final bool? isLoggedInUser;
  final bool? isShowBack;
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with RouteAware {
  AppConfig? _config;
  String? _userId;
  bool? _isLoggedInUser;
  UserModel? _userData;
  UserModel? _currentUser;

  bool? _isShowBack;

  final FeedBloc _blocFeed = FeedBloc();
  List<FeedModel> _list = <FeedModel>[];

  List<GroupModel> _listGroups = <GroupModel>[];
  final FollowersBloc _blocFollower = FollowersBloc();

  final ValueNotifier<bool> _isFollowingLoading = ValueNotifier<bool>(false);
  final BehaviorSubject<bool> _isUserFollowing = BehaviorSubject<bool>();
  ValueStream<bool> get getIsUserFollowing => _isUserFollowing.stream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Helper.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    if (mounted) {
      _blocFollower.getUserJoinedGroups(context,
          userId: _userId, loggedInUserId: _currentUser!.documentId!);
    }
  }

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    _isLoggedInUser = widget.isLoggedInUser ?? false;
    if (_isLoggedInUser!) {
      FireStoreProvider.instance.fetchCurrentUser(userId: _userId);
    } else {
      FireStoreProvider.instance.fetchUser(userId: _userId);
    }

    _currentUser = aGeneralBloc.currentUser;

    _isShowBack = widget.isShowBack ?? false;
    _init();
  }

  _init() async {
    await _blocFeed.getFeed(context,
        userId: _userId ?? _currentUser!.documentId);
    await _blocFollower.getUserJoinedGroups(context,
        userId: _userId ?? _currentUser!.documentId,
        loggedInUserId: _currentUser!.documentId);
  }

  @override
  void dispose() {
    super.dispose();
    _blocFollower.dispose();
    _blocFeed.dispose();

    Helper.routeObserver.unsubscribe(this);
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);

    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        child: _widgetMainContainer(),
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _config!,
        backgoundColor: Colors.transparent,
        textColor: _config!.whiteColor,
        title: _isLoggedInUser! ? AppConstants.myProfile : AppConstants.profile,
        elevation: 0,
        isBackEnable: _isShowBack!, onBack: () {
      Navigator.pop(context);
    }, actions: <Widget>[
      if (_isLoggedInUser!)
        IconButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          //iconSize: 16,
          icon: SvgIcon.asset(
            ImgConstants.notification,
            color: _config!.whiteColor,
          ),
          //color: color,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppNotification(),
                ));
          },
        )
    ]);
  }

  Widget _widgetMainContainer() {
    // ignore: always_specify_types
    return StreamBuilder<DocumentSnapshot?>(
      stream: _isLoggedInUser!
          ? FireStoreProvider.instance.getCurrentUserUpdate
          : FireStoreProvider.instance.getUserUpdate,
      builder:
          // ignore: always_specify_types
          (BuildContext? context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          _userData = UserModel.fromJson(
            snapshot.data?.data() as Map<String, dynamic>,
            doumentId: snapshot.data?.id ?? '',
          );

          if (!_isLoggedInUser!) {
            checkIsFollowing();
          } else {
            aGeneralBloc.updateCurrentUser(_userData!);
          }
        }
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _widgetUserInfo(),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 0),
                  child: Divider(
                    color: _config!.whiteColor.withOpacity(0.15),
                    thickness: 1,
                  ),
                ),
                _widgetPlanetInfo(),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                  child: Divider(
                    color: _config!.whiteColor.withOpacity(0.15),
                    thickness: 1,
                  ),
                ),
                _widgetGroupList(),
                _widgetFeed()
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _widgetUserInfo() {
    return Container(
      //padding: EdgeInsets.zero,
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _widgetProfilePic(),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _widgetUserFullName(),
                  _widgetUserName(),
                  _widgetUserFollowers(),
                  if (_isLoggedInUser!)
                    Row(
                      children: <Widget>[
                        _widgetButtonEditProfile(),
                        _widgetButtonSetting(),
                      ],
                    )
                ],
              ),
            ),
          ),
          Container(
              width: 60,
              height: 80,
              child: _isLoggedInUser!
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_userData?.ftpValue ?? 0}',
                          style: _config!.antonioHeading2FontStyle.apply(
                            color: _config!.btnPrimaryColor,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          AppConstants.hintFTP,
                          style: _config!.able36FontStyle.apply(
                              color: _config!.greyColor, fontSizeFactor: 1 / 3),
                          textAlign: TextAlign.right,
                        )
                      ],
                    )
                  : SizedBox()),
          if (!_isLoggedInUser!) _widgetButtoFollow(context)
        ],
      ),
    );
  }

  Widget _widgetPlanetInfo() {
    return Row(
      children: [
        // Hero(
        //   tag: 'gif_tag',
        Container(
            padding: EdgeInsets.only(left: 10),
            width: 140,
            height: 140,
            child: Image.asset(
              ImgConstants.level1,
              fit: BoxFit.cover,
            )),
        // ),
        SizedBox(
          width: 20,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LEVEL ${_userData?.level}',
                style: _config!.labelNormalFontStyle
                    .apply(color: _config!.greyColor),
              ),
              SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  '${_userData?.levelName!.toUpperCase()}',
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  style: _config!.calibriHeading3FontStyle
                      .apply(color: _config!.whiteColor),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'You have offset\n',
                      style: _config!.paragraphNormalFontStyle
                          .apply(color: _config!.greyColor),
                    ),
                    TextSpan(
                      text: '23 tonnes ',
                      style: _config!.paragraphNormalFontStyle
                          .apply(color: _config!.whiteColor),
                    ),
                    TextSpan(
                      text: 'of carbon',
                      style: _config!.paragraphNormalFontStyle
                          .apply(color: _config!.greyColor),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              _widgetReadMore(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _widgetReadMore() {
    return Align(
      alignment: Alignment.topCenter,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, YourPlanet.routeName)
              .then((Object? value) {});
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppConstants.readMore,
              style: _config!.calibriHeading5FontStyle.apply(
                color: _config!.btnPrimaryColor,
              ),
            ),
            Container(
              height: 1.5,
              width: 65,
              color: _config!.btnPrimaryColor,
            )
          ],
        ),
      ),
    );
  }

  Widget _widgetProfilePic() {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.zero,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(82 / 2),
              child: CircularImage(
                _userData?.profilePhoto ?? '',
                width: 82,
                height: 82,
              )),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(width: 2, color: _config!.windowBackground),
                color: _config!.borderColor),
            child: Center(
              child: Image.asset(
                ImgConstants.logoR,
                color: _config!.btnPrimaryColor,
                width: 16,
                height: 16,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _widgetUserFullName() {
    if (_userData == null) {
      return SkeletonText(
        width: 100,
      );
    } else {
      return Text(
        _userData?.fullName ?? '',
        style: _config!.calibriHeading3FontStyle.apply(
          color: _config!.whiteColor,
        ),
      );
    }
  }

  Widget _widgetUserName() {
    if (_userData == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: SkeletonText(
          width: 100,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          _userData?.username ?? '',
          style:
              _config!.paragraphSmallFontStyle.apply(color: _config!.greyColor),
        ),
      );
    }
  }

  Widget _widgetUserFollowers() {
    return FutureBuilder<int>(
        future: FireStoreProvider.instance
            .getFollowerCount(uesrId: _userData?.documentId ?? ''),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          String count = '';
          if (snapshot.hasData && snapshot.data != null) {
            count = snapshot.data.toString();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '$count ${AppConstants.followers}',
              style: _config!.calibriHeading4FontStyle.apply(
                color: _config!.whiteColor,
              ),
            ),
          );
        });
  }

  Widget _widgetButtonEditProfile() {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, EditProfile.routeName)
            .then((Object? value) {
          FireStoreProvider.instance.fetchCurrentUser();
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: _config!.greyColor,
        //minimumSize: const Size(96, 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
        child: Text(
          AppConstants.editProfile,
          style: _config!.linkSmallFontStyle.apply(
            color: _config!.whiteColor,
          ),
        ),
      ),
    );
  }

  Widget _widgetButtonSetting() {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, AppSettings.routeName);
      },
      style: TextButton.styleFrom(
        backgroundColor: _config!.greyColor,
        minimumSize: const Size(32, 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      child: SvgIcon.asset(
        ImgConstants.icSettings,
        color: _config!.whiteColor,
        size: 20,
      ),
    );
  }

  Widget _widgetButtoFollow(BuildContext mainContext) {
    if (_userData == null) {
      return SkeletonContainer(
        width: 63,
        height: 32,
        radius: BorderRadius.circular(4),
      );
    } else {
      return StreamBuilder<bool>(
          stream: getIsUserFollowing,
          builder: (context, snapshot) {
            String title = AppConstants.follow;
            Color bgColor = _config!.btnPrimaryColor;
            bool isfollowing = false;
            if (snapshot.hasData && snapshot.data != null) {
              _isFollowingLoading.value = false;
              isfollowing = snapshot.data!;
              title = isfollowing ? AppConstants.unfollow : AppConstants.follow;
              bgColor = isfollowing ? Colors.red : _config!.btnPrimaryColor;

              return ValueListenableBuilder<bool>(
                valueListenable: _isFollowingLoading,
                builder:
                    (BuildContext? context, bool? isLoading, Widget? child) {
                  return TextButton(
                    onPressed: () {
                      if (_userData != null && !isLoading!) {
                        _isFollowingLoading.value = true;
                        if (isfollowing) {
                          FireStoreProvider.instance.unfollowUser(
                              context: mainContext,
                              followUserData: _userData!,
                              onSuccess: (Map<String, dynamic> successData) {
                                checkIsFollowing();
                              },
                              onError: (Map<String, dynamic> errorData) {
                                _isFollowingLoading.value = false;
                              });
                        } else {
                          FireStoreProvider.instance.followUser(
                            context: mainContext,
                            followerUserData: _currentUser!,
                            userData: _userData!,
                            onSuccess: (Map<String, dynamic> successData) {
                              checkIsFollowing();
                            },
                            onError: (Map<String, dynamic> errorData) {
                              _isFollowingLoading.value = false;
                            },
                          );
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: bgColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4))),
                    child: isLoading!
                        ? Lottie.asset(LottieConstants.loader,
                            height: 24, width: 24)
                        : Text(
                            title,
                            style: _config!.linkSmallFontStyle.apply(
                              color: _config!.whiteColor,
                            ),
                          ),
                  );
                },
              );
            } else {
              return SkeletonContainer(
                width: 63,
                height: 32,
                radius: BorderRadius.circular(4),
              );
            }
          });
    }
  }

  Widget _widgetGroupHeader() {
    if (_userData == null) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 0),
        child: SkeletonText(
          width: 100,
        ),
      );
    } else {
      String name =
          _userData?.fullName!.split(' ').first ?? _userData?.fullName ?? '';

      if (name != null && name.isNotEmpty) {
        name = '$name${AppConstants.isPoststs}';
      }
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 0),
        child: Text(
          AppConstants.group.toUpperCase(),
          textAlign: TextAlign.left,
          style: _config!.labelNormalFontStyle.apply(color: _config!.greyColor),
        ),
      );
    }
  }

  Future<void> checkIsFollowing() async {
    final bool isFollowing = await FireStoreProvider.instance.isFollowing(
        uesrId: _userData!.documentId,
        followerId: AuthProvider.instance.currentUserId());

    _isUserFollowing.sink.add(isFollowing);
  }

  Widget _widgetGroupList() {
    return StreamBuilder<List<GroupModel>>(
      stream: _blocFollower.getUserGroups,
      builder: (_, AsyncSnapshot<List<GroupModel>> snapshot) {
        final bool isLoading = !snapshot.hasData;

        if (snapshot.hasData && snapshot.data != null) {
          _listGroups = snapshot.data!;
        }

        if (_listGroups.isEmpty) {
          return const SizedBox();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _widgetGroupHeader(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: isLoading ? 5 : _listGroups.length,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
              itemBuilder: (_, int index) {
                GroupModel? data = isLoading ? null : _listGroups[index];
                return GestureDetector(
                  onTapDown: (_) {
                    Navigator.pushNamed(
                      context,
                      GroupMembers.routeName,
                      arguments: GroupMembersArgs(groupModel: data!),
                    );
                  },
                  child: GroupWidget(
                    data: data,
                    currentUser: _currentUser,
                    index: index,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 0),
              child: Divider(
                color: _config!.whiteColor.withOpacity(0.15),
                thickness: 1,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _widgetFeedHeader() {
    if (_userData == null) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 0),
        child: SkeletonText(
          width: 100,
        ),
      );
    } else {
      String name =
          _userData?.fullName!.split(' ').first ?? _userData?.fullName ?? '';

      if (name != null && name.isNotEmpty) {
        name = '$name${AppConstants.isPoststs}';
      }
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 0),
        child: Text(
          name.toUpperCase(),
          textAlign: TextAlign.left,
          style: _config!.labelNormalFontStyle.apply(color: _config!.greyColor),
        ),
      );
    }
  }

  Widget _widgetFeed() {
    return StreamBuilder<List<FeedModel>>(
        stream: _blocFeed.getUserFeed,
        builder: (_, AsyncSnapshot<List<FeedModel>> snapshot) {
          final bool isLoading = !snapshot.hasData;

          if (snapshot.hasData && snapshot.data != null) {
            _list = snapshot.data!;
          }

          if (_list.isEmpty) {
            return const SizedBox();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _widgetFeedHeader(),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: isLoading ? 5 : _list.length,
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                  itemBuilder: (_, int index) {
                    final FeedModel? data = isLoading ? null : _list[index];
                    return FeedWidget(
                      data: data,
                      currentUser: _currentUser,
                      onDelete: (bool isDelete) {
                        _list.removeAt(index);
                        _blocFeed.updateFeed(_list);
                      },
                    );
                  }),
            ],
          );
        });
  }
}
