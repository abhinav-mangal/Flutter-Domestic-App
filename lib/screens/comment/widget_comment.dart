import 'package:energym/app_config.dart';
import 'package:flutter/material.dart';
import 'package:energym/models/comment_model.dart';
import 'package:energym/reusable_component/skeleton.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/utils/extensions/extension.dart';

class CommentWidget extends StatelessWidget {
  CommentWidget({
    Key? key,
    required this.data,
  }) : super(key: key);
  final CommentModel data;

  @override
  Widget build(BuildContext context) {
    AppConfig _appConfig = AppConfig.of(context);
    return Container(
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
    );
  }

  Widget _widgetUserInfo(AppConfig appConfig, BuildContext mainContext) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  children: [
                    Expanded(child: _userFullName(appConfig)),
                    const SizedBox(
                      width: 8,
                    ),
                    _feedTimeAgo(appConfig),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                _userComment(appConfig),
              ],
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
      return CircularImage(data.userProfilePicture!);
    }
  }

  Widget _userFullName(AppConfig appConfig) {
    if (data == null) {
      return SkeletonText(
        height: 20,
      );
    } else {
      return Text(
        data.userFullName!,
        style: appConfig.calibriHeading4FontStyle
            .apply(color: appConfig.whiteColor),
      );
    }
  }

  Widget _userComment(AppConfig appConfig) {
    if (data == null) {
      return SkeletonText(
        height: 20,
      );
    } else {
      return Text(
        data.comment!,
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
}
