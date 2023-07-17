import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/reusable_component/skeleton.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class LeaderboardWidget extends StatelessWidget {
  LeaderboardWidget({
    Key? key,
    required this.data,
    required this.index,
    required this.currentUser,
    this.groupAdminId,
    this.onPress,
  }) : super(key: key);
  final UserModel? data;
  final int? index;
  final UserModel? currentUser;
  final Function? onPress;
  final String? groupAdminId;

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
        padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 0),
              child: SizedBox(width: 16, child: Text('${(index ?? 0) + 1}')),
            ),
            _userImage(appConfig),
            const SizedBox(
              width: 16,
            ),
            Container(
              // color: Colors.amber,
              width: MediaQuery.of(mainContext).size.width * 0.35,
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
            Container(
                // color: Colors.red,
                width: 50,
                child: Text(
                  '${data?.ftpLeaderboard ?? 0} %',
                  textAlign: TextAlign.end,
                  style: appConfig.antonio14FontStyle,
                )),
            const SizedBox(
              width: 40,
            ),
            Container(
              width: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(ImgConstants.logoR, width: 12, height: 12),
                  Text(
                    '${data?.watts ?? 0}',
                    style: appConfig.antonio14FontStyle,
                  )
                ],
              ),
            )
          ],
        ));
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
