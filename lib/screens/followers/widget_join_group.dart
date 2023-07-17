import 'package:energym/app_config.dart';
import 'package:energym/models/group_model.dart';
import 'package:energym/screens/group/groupmemberlist.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:energym/models/follower_model.dart';
import 'package:energym/reusable_component/skeleton.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/models/user_model.dart';

class GroupJoinWidget extends StatelessWidget {
  GroupJoinWidget(
      {Key? key,
      required this.data,
      required this.currentUser,
      required this.index,
      required this.onJoin})
      : super(key: key);
  final GroupModel? data;
  final UserModel? currentUser;
  final int? index;
  Function(GroupModel)? onJoin;
  @override
  Widget build(BuildContext context) {
    AppConfig _appConfig = AppConfig.of(context);

    return Container(
      width: double.infinity,
      child: _widgetUserInfo(_appConfig, context),
    );
  }

  Widget _widgetUserInfo(AppConfig appConfig, BuildContext mainContext) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Text('${(index ?? 0) + 1}'),
          ),
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
          Row(
            children: [
              Image.asset(ImgConstants.logoR, width: 12, height: 12),
              Text('${data?.totalWatts}', style: appConfig.antonio14FontStyle)
            ],
          ),
          SizedBox(
            width: 5,
          ),
          ElevatedButton(
            onPressed: () {
              if (onJoin != null) {
                onJoin!(data!);
              }
            },
            child: Text(AppConstants.join),
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(appConfig.btnPrimaryColor),
            ),
          ),
        ],
      ),
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
      final String imageUrl = data?.groupProfile ?? '';
      return CircularImage(imageUrl);
    }
  }

  Widget _followerFullName(AppConfig appConfig) {
    if (data == null) {
      return SkeletonText(
        height: 20,
      );
    } else {
      final String fullName = data!.groupName!;

      return Text(
        fullName,
        style: appConfig.abelNormalFontStyle.apply(color: appConfig.whiteColor),
      );
    }
  }

  Widget _followerUserName(AppConfig appConfig) {
    if (data == null) {
      return SkeletonText(
        height: 20,
      );
    } else {
      final String userName = data!.participantName!.join(', ');
      return Text(
        userName,
        style: appConfig.abel14FontStyle.apply(color: appConfig.greyColor),
      );
    }
  }
}
