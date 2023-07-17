import 'package:energym/app_config.dart';
import 'package:energym/models/group_model.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/reusable_component/skeleton.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

// Group member cell / widget class
// this contains group related data
class MemberWidget extends StatelessWidget {
  MemberWidget(
      {Key? key,
      required this.data,
      required this.index,
      required this.currentUser,
      this.groupAdminId,
      this.group,
      this.onPress,
      this.onPressRemoveMember,
      this.onPressSendInvite,
      this.onPressSentInvite})
      : super(key: key);
  final UserModel? data;
  final int? index;
  final UserModel? currentUser;
  final Function? onPress;
  final Function(GroupModel, Map<String, dynamic>)? onPressRemoveMember;
  final Function(GroupModel, Map<String, dynamic>, UserModel)?
      onPressSendInvite;
  final Function(GroupModel, Map<String, dynamic>)? onPressSentInvite;
  final String? groupAdminId;
  final GroupModel? group;

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
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
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
            if (group!.participantId!.contains(data!.documentId))
              _removeMember(appConfig)
            else if (group!.participantInviteId!.contains(data!.documentId))
              SizedBox(width: 80, child: _invitedMember(appConfig))
            else
              SizedBox(width: 80, child: _inviteMember(appConfig))
          ],
        ));
  }

  Widget _removeMember(AppConfig appConfig) {
    return TextButton(
      onPressed: () {
        if (onPressRemoveMember != null) {
          final Map<String, dynamic> _neetToStoreData = <String, dynamic>{};

          group?.participantId?.remove(data!.documentId);
          group?.participantName?.remove(data!.fullName);
          _neetToStoreData[GroupCollectionField.participantId] =
              group?.participantId;
          _neetToStoreData[GroupCollectionField.participantName] =
              group?.participantName;
          onPressRemoveMember!(group!, _neetToStoreData);
        }
      },
      child: Text(
        AppConstants.removeMembr,
        textAlign: TextAlign.end,
        style: appConfig.abelNormalFontStyle
            .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _inviteMember(AppConfig appConfig) {
    return ElevatedButton(
      onPressed: () {
        if (onPressSendInvite != null) {
          final Map<String, dynamic> _neetToStoreData = <String, dynamic>{};

          group?.participantInviteId?.add(data!.documentId!);
          group?.participantInviteName?.add(data!.fullName!);
          _neetToStoreData[GroupCollectionField.participantInviteId] =
              group?.participantInviteId;
          _neetToStoreData[GroupCollectionField.participantInviteName] =
              group?.participantInviteName;

          onPressSendInvite!(group!, _neetToStoreData, data!);
        }
      },
      child: Text(AppConstants.invite.toUpperCase(),
          style: appConfig.abelNormalFontStyle
              .copyWith(fontWeight: FontWeight.bold)),
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(appConfig.btnPrimaryColor)),
    );
  }

  Widget _invitedMember(AppConfig appConfig) {
    return ElevatedButton(
      onPressed: () {
        if (onPressSentInvite != null) {
          final Map<String, dynamic> _neetToStoreData = <String, dynamic>{};

          group?.participantInviteId?.remove(data!.documentId);
          group?.participantInviteName?.remove(data!.fullName);
          _neetToStoreData[GroupCollectionField.participantInviteId] =
              group?.participantInviteId;
          _neetToStoreData[GroupCollectionField.participantInviteName] =
              group?.participantInviteName;
          onPressSentInvite!(group!, _neetToStoreData);
        }
      },
      child: Text(
        AppConstants.invited.toUpperCase(),
        style:
            appConfig.abelNormalFontStyle.copyWith(fontWeight: FontWeight.bold),
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
        AppColors.blueworkout,
      )),
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
      final String imageUrl = data?.profilePhoto ?? '';
      return CircularImage(imageUrl);
    }
  }

  Widget _followerFullName(AppConfig appConfig) {
    if (data == null) {
      return SkeletonText(
        height: 20,
      );
    } else {
      final String fullName = data?.fullName ?? '';

      String tempFullName = '';
      if (groupAdminId == data?.documentId) {
        // Admin
        tempFullName = (currentUser?.documentId == data?.documentId)
            ? 'You (admin)'
            : '${fullName} (admin)';
      } else {
        tempFullName =
            (currentUser?.documentId == data?.documentId) ? 'You' : fullName;
      }
      return Text(
        tempFullName,
        style: appConfig.calibriHeading4FontStyle.apply(
            color: appConfig.whiteColor, overflow: TextOverflow.ellipsis),
      );
    }
  }

  Widget _followerUserName(AppConfig appConfig) {
    if (data == null) {
      return SkeletonText(
        height: 20,
      );
    } else {
      final String userName = data?.username ?? '';
      return Text(
        userName,
        style:
            appConfig.paragraphSmallFontStyle.apply(color: appConfig.greyColor),
      );
    }
  }
}
