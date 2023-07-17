import 'package:energym/app_config.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:flutter/material.dart';
import 'package:energym/models/follower_model.dart';
import 'package:energym/reusable_component/skeleton.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/models/user_model.dart';

class FollowerWidget extends StatelessWidget {
  FollowerWidget({
    Key? key,
    required this.data,
    required this.currentUser,
    this.isSelectable = false,
    this.isSelected = false,
    this.onPress,
  }) : super(key: key);
  final FollowerModel? data;
  final UserModel? currentUser;
  final bool? isSelectable;
  final bool? isSelected;
  final Function? onPress;
  UserModel? follower;

  @override
  Widget build(BuildContext context) {
    AppConfig _appConfig = AppConfig.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (onPress != null) {
          onPress!();
        }
      },
      child: Container(
        width: double.infinity,
        child: _widgetUserInfo(_appConfig, context),
      ),
    );
  }

  Widget _widgetUserInfo(AppConfig appConfig, BuildContext mainContext) {
    return Container(
      width: double.infinity,
      height: 50,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 8, 0),
      child: FutureBuilder<UserModel>(
          future: getFollowerUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              follower = snapshot.data;
              FireStoreProvider.instance.updatefollowUser(
                  context: context,
                  documentId: data!.documentId,
                  userData: currentUser!,
                  followerUserData: follower!);
            }

            return Row(
              children: <Widget>[
                _userImage(appConfig),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _followerFullName(appConfig),
                      const SizedBox(
                        height: 2,
                      ),
                      _followerUserName(appConfig),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                if (isSelectable!)
                  SvgIcon.asset(
                    isSelected!
                        ? ImgConstants.checkMarkCircle
                        : ImgConstants.uncheckMarkCircle,
                    size: 20,
                    color: appConfig.skyBlueColor,
                  )
              ],
            );
          }),
    );
  }

  Widget _userImage(AppConfig appConfig) {
    if (data == null) {
      return SkeletonContainer(
        width: 40,
        height: 40,
        radius: BorderRadius.circular(20),
      );
    } else {
      final String imageUrl =
          follower?.profilePhoto ?? data!.followerProfilePhoto!;
      return CircularImage(imageUrl);
    }
  }

  Widget _followerFullName(AppConfig appConfig) {
    if (data == null) {
      return SkeletonText(
        height: 20,
      );
    } else {
      final String fullName = follower?.fullName ?? data!.followerFullName!;

      return Text(
        fullName,
        style: appConfig.calibriHeading4FontStyle
            .apply(color: appConfig.whiteColor),
      );
    }
  }

  Widget _followerUserName(AppConfig appConfig) {
    if (data == null) {
      return SkeletonText(
        height: 20,
      );
    } else {
      final String userName = follower?.username ?? data!.followerUsername!;
      return Text(
        userName,
        style:
            appConfig.paragraphSmallFontStyle.apply(color: appConfig.greyColor),
      );
    }
  }

  Future<UserModel> getFollowerUser() {
    return FireStoreProvider.instance
        .getUserData(userId: data?.followerId ?? '');
  }
}
