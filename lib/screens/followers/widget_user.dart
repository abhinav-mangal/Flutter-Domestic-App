import 'package:energym/app_config.dart';
import 'package:energym/screens/followers/follower_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/helpers/firebase/auth_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:energym/reusable_component/skeleton.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:lottie/lottie.dart';

class WidgetUser extends StatefulWidget {
  const WidgetUser({Key? key, required this.data, required this.currentUser})
      : super(key: key);
  final UserModel? data;
  final UserModel? currentUser;
  @override
  _WidgetUserState createState() => _WidgetUserState();
}

class _WidgetUserState extends State<WidgetUser> {
  UserModel? _contact;
  UserModel? _userData;
  UserModel? _currentUser;
  FollowersBloc? _blocFollowers;
  AppConfig? _appConfig;

  final ValueNotifier<bool> _isFollowingLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _contact = widget.data;
    _currentUser = widget.currentUser;
    _blocFollowers = FollowersBloc();
    if (_contact != null) {
      _blocFollowers!.checkForUser(contact: _contact);
    }
  }

  @override
  void didUpdateWidget(covariant WidgetUser oldWidget) {
    if (_contact != widget.data) {
      _contact = widget.data;
      if (_contact != null) {
        _blocFollowers!.checkForUser(contact: _contact);
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _appConfig = AppConfig.of(context);
    return StreamBuilder<dynamic>(
        stream: _blocFollowers!.getUser,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data is UserModel) {
              _contact = widget.data;
              _userData = snapshot.data as UserModel;
            }

            _isFollowingLoading.value = false;
          }

          if (_userData != null &&
              _userData!.documentId == AuthProvider.instance.currentUserId()) {
            return const SizedBox();
          }
          return Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
            child: Row(
              children: <Widget>[
                _widgetUserPicture(),
                Expanded(
                  child: _widgetUserInfo(),
                ),
                _widgetButtoInvite(context)
              ],
            ),
          );
        });
  }

  Widget _widgetUserPicture() {
    final String imageUrl = _userData?.profilePhoto ?? '';
    return CircularImage(imageUrl);
  }

  Widget _widgetUserInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _widgetUserFullName(),
          const SizedBox(
            height: 2,
          ),
          _widgetUserName(),
        ],
      ),
    );
  }

  Widget _widgetUserFullName() {
    if (_contact == null) {
      return SkeletonContainer(
        width: double.infinity,
        height: 20,
      );
    } else {
      final String userName = _contact?.fullName ?? '';
      // if (_userData != null) {
      //   userName = _userData?.fullName ?? '';
      // } else {
      //   userName = widget?.data?.displayName ?? '';
      // }

      return Text(
        userName,
        style: _appConfig!.calibriHeading4FontStyle
            .apply(color: _appConfig!.whiteColor),
      );
    }
  }

  Widget _widgetUserName() {
    if (_contact == null) {
      return SkeletonContainer(
        width: double.infinity,
        height: 20,
      );
    } else {
      return Text(
        _userData?.username ?? '',
        style: _appConfig!.paragraphSmallFontStyle
            .apply(color: _appConfig!.greyColor),
      );
    }
  }

  Widget _widgetButtoInvite(BuildContext mainContext) {
    if (_contact == null) {
      return SkeletonContainer(
        width: 63,
        height: 32,
        radius: BorderRadius.circular(4),
      );
    } else {
      String title = AppConstants.invite;
      Color bgColor = _appConfig!.skyBlueColor;

      if (_userData != null) {
        print(
            'is following #${_userData!.isFollowing} - ${_userData?.fullName}');
        title = _userData!.isFollowing!
            ? AppConstants.unfollow
            : AppConstants.follow;
        bgColor =
            _userData!.isFollowing! ? Colors.red : _appConfig!.btnPrimaryColor;
      }

      return ValueListenableBuilder<bool>(
        valueListenable: _isFollowingLoading,
        builder: (BuildContext? context, bool? isLoading, Widget? child) {
          return TextButton(
            onPressed: () {
              if (_userData != null && !isLoading!) {
                _isFollowingLoading.value = true;
                if (_userData!.isFollowing!) {
                  FireStoreProvider.instance.unfollowUser(
                      context: mainContext,
                      followUserData: _userData!,
                      onSuccess: (Map<String, dynamic> successData) {
                        _blocFollowers!.checkForUser(contact: _contact);
                      },
                      onError: (Map<String, dynamic> errorData) {
                        _isFollowingLoading.value = false;
                      });
                } else {
                  FireStoreProvider.instance.followUser(
                    context: mainContext,
                    followerUserData: _currentUser!,
                    userData: _userData!,
                    onSuccess: (Map<String, dynamic> successData) async {
                      await FireStoreProvider.instance.sendFcmNotification(
                        _currentUser!,
                        _userData!.documentId!,
                        NotificationType.follower,
                        _currentUser!.documentId!,
                        null,
                        null,
                      );
                      _blocFollowers!.checkForUser(contact: _contact);
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
                ? Lottie.asset(LottieConstants.loader, height: 24, width: 24)
                : Text(
                    title,
                    style: _appConfig!.linkSmallFontStyle.apply(
                      color: _appConfig!.whiteColor,
                    ),
                  ),
          );
        },
      );
    }
  }
}
