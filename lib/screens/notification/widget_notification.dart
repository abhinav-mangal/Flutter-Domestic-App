import 'package:energym/app_config.dart';
import 'package:energym/models/group_model.dart';
import 'package:energym/screens/comment/comment.dart';
import 'package:energym/screens/feed/feed_details.dart';
import 'package:energym/screens/workout/green_zone/green_zone.dart';
import 'package:energym/screens/workout/workout.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:energym/models/notification_model.dart';
import 'package:energym/reusable_component/skeleton.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:energym/models/user_model.dart';

class NotificationWidget extends StatelessWidget {
  NotificationWidget({
    Key? key,
    this.onPressDeleteInvite,
    this.onPressJoinInvite,
    required this.data,
  }) : super(key: key);
  final NotificationModel data;
  final Function(GroupModel, Map<String, dynamic>, NotificationModel)?
      onPressDeleteInvite;
  final Function(GroupModel, Map<String, dynamic>, NotificationModel)?
      onPressJoinInvite;

  UserModel? userData;

  @override
  Widget build(BuildContext context) {
    AppConfig _appConfig = AppConfig.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (data != null && data.entityType != NotificationType.welcome) {
          if (data.entityType == NotificationType.likePost ||
              data.entityType == NotificationType.commentPost) {
            Navigator.pushNamed(
              context,
              FeedDetails.routeName,
              arguments: FeedDetailsArgs(
                feedId: data.entityId,
              ),
            );
          } else if (data.entityType == NotificationType.ftpReminder) {
            Navigator.pushNamed(
              context,
              GreenZone.routeName,
            );
          }
        }
      },
      child: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            _widgetUserInfo(_appConfig, context),
            const SizedBox(
              height: 12,
            ),
            Divider(
              thickness: 1,
              color: _appConfig.borderColor,
            )
          ],
        ),
      ),
    );
  }

  Widget _widgetUserInfo(AppConfig appConfig, BuildContext mainContext) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
      child: FutureBuilder<UserModel>(
          future: getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              userData = snapshot.data!;
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
                      widgetNotificaitonMsg(appConfig),
                      _feedTimeAgo(appConfig),
                      if (data.entityType == NotificationType.inviteGroupMember)
                        _joinDelete(context, appConfig)
                      else if (data.entityType ==
                          NotificationType.inviteGroupMemberDeleted)
                        Text('Invite deleted')
                      else if (data.entityType ==
                          NotificationType.inviteGroupMemberJoined)
                        Text('Joined group')
                      else
                        const SizedBox()
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }

  Widget _userImage(AppConfig appConfig) {
    if (userData == null) {
      return SkeletonContainer(
        width: 40,
        height: 40,
        radius: BorderRadius.circular(20),
      );
    } else {
      return CircularImage(userData!.profilePhoto!);
    }
  }

  Widget widgetNotificaitonMsg(AppConfig appConfig) {
    if (data == null) {
      return SkeletonText(
        height: 20,
      );
    } else {
      return Text(
        data.title!,
        style: appConfig.paragraphNormalFontStyle.apply(
          color: appConfig.whiteColor,
        ),
      );
    }
  }

  Widget _feedTimeAgo(AppConfig appConfig) {
    if (data == null) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
        child: SkeletonText(
          width: 30,
          height: 18,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
        child: Text(
          data.createdAt!.timeAgo(),
          style: appConfig.paragraphSmallFontStyle.apply(
            color: appConfig.greyColor,
          ),
        ),
      );
    }
  }

  Widget _joinDelete(BuildContext context, AppConfig appConfig) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: (MediaQuery.of(context).size.width - 100) / 2,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(appConfig.btnPrimaryColor),
            ),
            onPressed: () async {
              // fetch group
              GroupModel? group =
                  await FireStoreProvider.instance.fetchGroup(data.groupId!);
              // Update group
              final Map<String, dynamic> _neetToStoreData = <String, dynamic>{};

              group?.participantId?.add(data.receiverId!);
              group?.participantName?.add(data.invitedMemberName!);
              _neetToStoreData[GroupCollectionField.participantId] =
                  group?.participantId;
              _neetToStoreData[GroupCollectionField.participantName] =
                  group?.participantName;

              group?.participantInviteId?.remove(data.receiverId);
              group?.participantInviteName?.remove(data.invitedMemberName);
              _neetToStoreData[GroupCollectionField.participantInviteId] =
                  group?.participantInviteId;
              _neetToStoreData[GroupCollectionField.participantInviteName] =
                  group?.participantInviteName;
              if (onPressJoinInvite != null) {
                onPressJoinInvite!(group!, _neetToStoreData, data);
              }
            },
            child: const Text('Join'),
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 100) / 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  AppColors.grayworkout,
                ),
                foregroundColor: MaterialStateProperty.all(
                  AppColors.black,
                ),
              ),
              onPressed: () async {
                // fetch group
                GroupModel? group =
                    await FireStoreProvider.instance.fetchGroup(data.groupId!);
                // Update group
                final Map<String, dynamic> _neetToStoreData =
                    <String, dynamic>{};

                group?.participantInviteId?.remove(data.receiverId);
                group?.participantInviteName?.remove(data.invitedMemberName);
                _neetToStoreData[GroupCollectionField.participantInviteId] =
                    group?.participantInviteId;
                _neetToStoreData[GroupCollectionField.participantInviteName] =
                    group?.participantInviteName;
                if (onPressDeleteInvite != null) {
                  onPressDeleteInvite!(group!, _neetToStoreData, data);
                }
              },
              child: const Text('Delete'),
            ),
          ),
        )
      ],
    );
  }

  Future<UserModel> getUserDetails() {
    return FireStoreProvider.instance.getUserData(userId: data.senderId);
  }
}
