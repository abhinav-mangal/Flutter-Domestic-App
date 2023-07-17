import 'package:energym/app_config.dart';
import 'package:energym/models/feed_model.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/reusable_component/skeleton.dart';
import 'package:energym/screens/comment/comment.dart';
import 'package:energym/screens/report/report.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:flutter/material.dart';

class FeedWidget extends StatelessWidget {
  FeedWidget(
      {Key? key,
      @required this.data,
      @required this.currentUser,
      this.onDelete})
      : super(key: key);
  final FeedModel? data;
  final UserModel? currentUser;
  final void Function(bool)? onDelete;

  ValueNotifier<bool> _notifierLiked = ValueNotifier<bool>(false);
  ValueNotifier<int> _notifierLikedCount = ValueNotifier<int>(0);
  ValueNotifier<int> _notifierCommentCount = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    print('DATA === $data');

    AppConfig _appConfig = AppConfig.of(context);
    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          _widgetUserInfo(_appConfig, context),
          _widgetPostInfo(_appConfig, context),
          _widgetDivider(_appConfig),
        ],
      ),
    );
  }

  Widget _widgetUserInfo(AppConfig appConfig, BuildContext mainContext) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
      child: Row(
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
                _userFullName(appConfig),
                const SizedBox(
                  height: 2,
                ),
                _userName(appConfig),
              ],
            ),
          ),
          _feedTimeAgo(appConfig),
          _optionButton(appConfig, mainContext),
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
      return CircularImage(data!.userProfilePicture!);
    }
  }

  Widget _userFullName(AppConfig appConfig) {
    if (data == null) {
      return SkeletonText(
        height: 20,
      );
    } else {
      return Text(
        data?.userFullName ?? '',
        style: appConfig.calibriHeading4FontStyle
            .apply(color: appConfig.whiteColor),
      );
    }
  }

  Widget _userName(AppConfig appConfig) {
    if (data == null) {
      return SkeletonText(
        height: 20,
      );
    } else {
      return Text(
        data?.userName ?? '',
        style:
            appConfig.paragraphSmallFontStyle.apply(color: appConfig.greyColor),
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
          data!.createdAt!.timeAgo(),
          style: appConfig.paragraphSmallFontStyle.apply(
            color: appConfig.greyColor,
          ),
        ),
      );
    }
  }

  Widget _optionButton(AppConfig appConfig, BuildContext mainContext) {
    if (data == null) {
      return SkeletonContainer(
        width: 24,
        height: 24,
        radius: BorderRadius.circular(20),
      );
    } else {
      return IconButton(
        icon: SvgIcon.asset(
          ImgConstants.optionMenu,
          size: 24,
          color: appConfig.whiteColor,
        ),
        onPressed: () {
          showModalBottomSheet(
              context: mainContext,
              builder: (context) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (data!.userId != currentUser!.documentId)
                        ListTile(
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          leading: const Icon(Icons.report),
                          // contentPadding: const EdgeInsets.symmetric(),
                          // visualDensity: const VisualDensity(vertical: -4),
                          title: Transform(
                            transform: Matrix4.translationValues(-16, 0.0, 0.0),
                            child: Text(
                              AppConstants.reportPost,
                              style: appConfig.calibriHeading3FontStyle
                                  .apply(color: Colors.red),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            showReportView(
                              context: mainContext,
                              isPostRePost: true,
                            );
                          },
                        ),
                      if (data!.userId != currentUser!.documentId)
                        ListTile(
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          leading: const Icon(Icons.verified_user),
                          title: Transform(
                            transform: Matrix4.translationValues(-16, 0.0, 0.0),
                            child: Text(
                              AppConstants.reportUser,
                              style: appConfig.calibriHeading3FontStyle
                                  .apply(color: Colors.red),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            showReportView(
                              context: mainContext,
                              isPostRePost: false,
                            );
                          },
                        ),
                      if (data!.userId == currentUser!.documentId)
                        if (data!.isUserPost!)
                          ListTile(
                            hoverColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            leading: const Icon(Icons.delete),
                            title: Transform(
                              transform:
                                  Matrix4.translationValues(-16, 0.0, 0.0),
                              child: Text(
                                AppConstants.delete,
                                style: appConfig.calibriHeading3FontStyle
                                    .apply(color: Colors.red),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              deletePost(mainContext);
                            },
                          )
                    ],
                  ),
                );
              });
        },
      );
    }
  }

  void showReportView({
    @required BuildContext? context,
    @required bool? isPostRePost,
  }) {
    showModalBottomSheet(
      context: context!,
      isScrollControlled: true,
      isDismissible: false,
      //expand: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,

      builder: (context) => Report(
        isRepostPost: isPostRePost!,
        feed: data!,
      ),
    ).then(
      (value) {
        if (value != null) {
          //_blocPostDetails.loadPostDeatils(_postId);
        }
      },
    );
  }

  Widget _widgetPostInfo(AppConfig appConfig, BuildContext mainContext) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(72, 8, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _widgetPostText(appConfig),
          if (data!.type == PostType.ftpWorkout) ...[
            const SizedBox(height: 6),
            _widgetFTPWorkoutContainer(appConfig),
          ],
          if (data!.type == PostType.workout) ...[
            const SizedBox(height: 6),
            _widgetWorkoutContainer(appConfig),
          ],
          if (data!.type != PostType.workout) _widgetPostImage(appConfig),
          _widgetPostActionButton(appConfig, mainContext)
        ],
      ),
    );
  }

  Widget _widgetPostText(AppConfig appConfig) {
    if (data == null) {
      return SkeletonText(
        height: 20,
      );
    } else {
      return Align(
        alignment: Alignment.topLeft,
        child: Text(
          data?.title ?? '',
          style: appConfig.paragraphNormalFontStyle.apply(
            color: appConfig.whiteColor,
          ),
        ),
      );
    }
  }

  Widget _widgetPostImage(AppConfig appConfig) {
    if (data == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: SkeletonContainer(
          width: double.infinity,
          height: 150,
          radius: BorderRadius.circular(8),
        ),
      );
    } else {
      if ((data?.attachment?.length ?? 0) > 0 &&
          data!.attachment![0].isNotEmpty) {
        return Container(
          padding: const EdgeInsets.only(top: 6),
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SkeletonImage(
              imageUrl: data?.attachment!.first ?? '',
              borderRadius: BorderRadius.circular(8),
              width: double.infinity,
              height: 150,
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    }
  }

  Widget _widgetFTPWorkoutContainer(AppConfig appConfig) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(33, 15, 33, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage(ImgConstants.workoutbg),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: <Widget>[
          _widgetSweatCoinIcon(appConfig),
          _widgetWattsGenerated(appConfig),
          _widgetWorkoutFTP(appConfig),
        ],
      ),
    );
  }

  Widget _widgetWorkoutFTP(AppConfig appConfig) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      // height: 145,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _widgetOldFTP(appConfig),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Image.asset(
              ImgConstants.arrowftp,
              width: 30,
            ),
          ),
          _widgetNewFTP(appConfig),
        ],
      ),
    );
  }

  Widget _widgetOldFTP(AppConfig appConfig) {
    return Column(
      children: [
        Text(
          AppConstants.oldFTP,
          style: appConfig.antonioHeading2FontStyle
              .apply(color: appConfig.whiteColor),
        ),
        Text(
          "${data?.data![WorkoutDataKey.oldFtpValue] as int}",
          style: appConfig.antonioHeading1FontStyle
              .apply(color: appConfig.btnPrimaryColor),
        )
      ],
    );
  }

  Widget _widgetNewFTP(AppConfig appConfig) {
    final int newftp =
        int.parse("${data?.data![WorkoutDataKey.ftpValue] as int}");
    return Column(
      children: [
        Text(
          AppConstants.newFTP,
          style: appConfig.antonioHeading2FontStyle
              .apply(color: appConfig.whiteColor),
        ),
        Text(
          '${newftp}',
          style: appConfig.antonioHeading1FontStyle
              .apply(color: appConfig.btnPrimaryColor),
        )
      ],
    );
  }

  Widget _widgetWorkoutContainer(AppConfig appConfig) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(33, 15, 33, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage(ImgConstants.workoutbg),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: <Widget>[
          _widgetSweatCoinIcon(appConfig),
          _widgetWattsGenerated(appConfig),
          _widgetWorkoutInfo(appConfig),
        ],
      ),
    );
  }

  Widget _widgetSweatCoinIcon(AppConfig appConfig) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: appConfig.btnPrimaryColor.withOpacity(0.20)),
      child: Center(
        child: Image.asset(
          ImgConstants.logoR,
          color: appConfig.btnPrimaryColor,
          width: 30,
          height: 30,
        ),
      ),
    );
  }

  Widget _widgetWattsGenerated(AppConfig appConfig) {
    final double wattGenerated =
        data?.data![WorkoutDataKey.wattsGenerated] as double;
    return Padding(
      padding: const EdgeInsets.only(top: 9.0),
      child: Column(
        children: [
          _widgetGeneratedValues(appConfig, wattGenerated),
          const SizedBox(
            height: 4,
          ),
          Text(AppConstants.wattsGenerated,
              style: appConfig.paragraphExtraSmallFontStyle
                  .apply(color: appConfig.greyColor),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _widgetGeneratedValues(AppConfig appConfig, double value) {
    return Text(value.toString(),
        style: appConfig.antonioHeading2FontStyle
            .apply(color: appConfig.whiteColor),
        textAlign: TextAlign.center);
  }

  Widget _widgetWorkoutInfo(AppConfig appConfig) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
      child: Container(
        width: double.infinity,
        height: 120,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _widgetCaloriesBurned(appConfig),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
              child: Container(
                width: 1,
                height: double.infinity,
                color: appConfig.whiteColor.withOpacity(0.10),
              ),
            ),
            _widgetSeatcoinEarned(appConfig),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
              child: Container(
                width: 1,
                height: double.infinity,
                color: appConfig.whiteColor.withOpacity(0.10),
              ),
            ),
            _widgetMilesCoverd(appConfig),
          ],
        ),
      ),
    );
  }

  Widget _widgetCaloriesBurned(AppConfig appConfig) {
    final int caloriesBurned =
        data?.data![WorkoutDataKey.caloriesBurned] as int;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SvgIcon.asset(
          ImgConstants.burn,
          color: appConfig.orangeColor,
          size: 30,
        ),
        const SizedBox(
          height: 6,
        ),
        Text(caloriesBurned.toString(),
            style: appConfig.antonioHeading2FontStyle
                .apply(color: appConfig.whiteColor),
            textAlign: TextAlign.center),
        const SizedBox(
          height: 4,
        ),
        Text(AppConstants.caloriesBurnedAnd,
            style: appConfig.paragraphExtraSmallFontStyle
                .apply(color: appConfig.greyColor),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _widgetMilesCoverd(AppConfig appConfig) {
    final int milesCovered = data?.data![WorkoutDataKey.milesCovered] as int;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SvgIcon.asset(
          ImgConstants.cycle,
          color: appConfig.skyBlueColor,
          size: 30,
        ),
        const SizedBox(
          height: 6,
        ),
        Text('--',
            style: appConfig.antonioHeading2FontStyle
                .apply(color: appConfig.whiteColor),
            textAlign: TextAlign.center),
        const SizedBox(
          height: 4,
        ),
        Text(AppConstants.milesCovered,
            style: appConfig.paragraphExtraSmallFontStyle
                .apply(color: appConfig.greyColor),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _widgetSeatcoinEarned(AppConfig appConfig) {
    final double sweatCoinsEarned =
        data?.data![WorkoutDataKey.sweatCoinsEarned] as double;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SvgIcon.asset(
          ImgConstants.sweatCoin,
          color: appConfig.btnPrimaryColor,
          size: 30,
        ),
        const SizedBox(
          height: 6,
        ),
        Text(sweatCoinsEarned.toString(),
            style: appConfig.antonioHeading2FontStyle
                .apply(color: appConfig.whiteColor),
            textAlign: TextAlign.center),
        const SizedBox(
          height: 4,
        ),
        Text(AppConstants.sweatcoinsEarned,
            style: appConfig.paragraphExtraSmallFontStyle
                .apply(color: appConfig.greyColor),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _widgetPostActionButton(
      AppConfig appConfig, BuildContext mainContext) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 17),
      child: Row(
        children: <Widget>[
          Expanded(child: _widgetLike(appConfig, mainContext)),
          Container(
            width: 1,
            height: 18,
            color: appConfig.whiteColor.withOpacity(0.15),
          ),
          Expanded(child: _widgetComment(appConfig, mainContext)),
          Container(
            width: 1,
            height: 18,
            color: appConfig.whiteColor.withOpacity(0.15),
          ),
          Expanded(child: _widgetShare(appConfig)),
        ],
      ),
    );
  }

  Widget _widgetLike(AppConfig appConfig, BuildContext mainContext) {
    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _widgetLikeIcon(appConfig, mainContext),
          _widgetLikeCount(appConfig, mainContext),
        ],
      ),
    );
  }

  Widget _widgetLikeIcon(AppConfig appConfig, BuildContext mainContext) {
    if (data == null) {
      return SkeletonContainer(
        width: 20,
        height: 20,
        radius: BorderRadius.circular(4),
      );
    } else {
      checkedIsLiked();
      return ValueListenableBuilder<bool>(
        valueListenable: _notifierLiked,
        builder: (BuildContext? context, bool? isLiked, Widget? child) {
          return IconButton(
            icon: SvgIcon.asset(
              isLiked! ? ImgConstants.like : ImgConstants.unlike,
              size: 20,
              color: isLiked ? appConfig.orangeColor : appConfig.whiteColor,
            ),
            onPressed: () {
              if (isLiked) {
                _notifierLiked.value = false;
                FireStoreProvider.instance.unLikePost(
                    context: mainContext,
                    postId: data!.documentId,
                    userId: currentUser!.documentId,
                    onSuccess: (Map<String, dynamic> successResponse) {
                      checkedIsLiked();
                    },
                    onError: (Map<String, dynamic> errorResponse) {});
              } else {
                _notifierLiked.value = true;
                FireStoreProvider.instance.likePost(
                    context: mainContext,
                    postId: data!.documentId,
                    userData: currentUser!,
                    onSuccess: (Map<String, dynamic> successResponse) {
                      checkedIsLiked();

                      FireStoreProvider.instance.sendFcmNotification(
                          currentUser!,
                          data!.userId!,
                          NotificationType.likePost,
                          data!.documentId!,
                          null,
                          null);
                    },
                    onError: (Map<String, dynamic> errorResponse) {});
              }
            },
          );
        },
      );
    }
  }

  Widget _widgetLikeCount(AppConfig appConfig, BuildContext mainContext) {
    if (data == null) {
      return SkeletonContainer(
        width: 20,
        height: 20,
        radius: BorderRadius.circular(4),
      );
    } else {
      getLikeCount();
      return ValueListenableBuilder<int>(
        valueListenable: _notifierLikedCount,
        builder: (BuildContext? context, int? count, Widget? child) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {},
            child: Text(
              '$count',
              style: appConfig.linkSmallFontStyle.apply(
                color: appConfig.whiteColor,
              ),
            ),
          );
        },
      );
    }
  }

  void checkedIsLiked() {
    data!.isLiked(currentUser!.documentId!).then((bool value) {
      _notifierLiked.value = value;
      getLikeCount();
    });
  }

  void getLikeCount() {
    FireStoreProvider.instance
        .getLikedCount(
            postId: data!.documentId, uesrId: currentUser!.documentId)
        .then((int count) {
      _notifierLikedCount.value = count;
    });
  }

  void getCommentCount() {
    FireStoreProvider.instance
        .getCommentCount(postId: data?.documentId ?? '')
        .then((int count) {
      _notifierCommentCount.value = count;
    });
  }

  Widget _widgetComment(AppConfig appConfig, BuildContext mainContext) {
    getCommentCount();
    return Align(
        alignment: Alignment.topCenter,
        child: ValueListenableBuilder<int>(
          valueListenable: _notifierCommentCount,
          builder: (BuildContext? context, int? count, Widget? child) {
            int commentCount = count ?? 0;
            return TextButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  mainContext,
                  Comment.routeName,
                  arguments: CommentArgs(feedId: data?.documentId),
                );
                if (result != null) {
                  getCommentCount();
                }
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SvgIcon.asset(
                    ImgConstants.comment,
                    size: 20,
                    color: appConfig.whiteColor,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    '$commentCount',
                    style: appConfig.linkSmallFontStyle.apply(
                      color: appConfig.whiteColor,
                    ),
                  )
                ],
              ),
            );
          },
        ));
  }

  Widget _widgetShare(AppConfig appConfig) {
    return Align(
      alignment: Alignment.topCenter,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgIcon.asset(
              ImgConstants.share,
              size: 20,
              color: appConfig.whiteColor,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              '0',
              style: appConfig.linkSmallFontStyle.apply(
                color: appConfig.whiteColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _widgetDivider(AppConfig appConfig) {
    return Divider(
      thickness: 1,
      color: appConfig.whiteColor.withOpacity(0.15),
    );
  }

  void deletePost(BuildContext mainContext) {
    String postId = data?.documentId ?? '';
    if (postId != null && postId.isNotEmpty) {
      CustomAlertDialog().confirmationDialog(
        title: AppConstants.delete,
        message: AppConstants.deletePostMsg,
        cancelButtonTitle: AppConstants.dismiss,
        okButtonTitle: AppConstants.delete,
        context: mainContext,
        onSuccess: () {
          aGeneralBloc.updateAPICalling(true);
          FireStoreProvider.instance.deletePost(
            context: mainContext,
            feed: data!,
            onSuccess: (Map<String, dynamic> successResponse) {
              aGeneralBloc.updateAPICalling(false);
              onDelete!(true);
              Navigator.pop(mainContext);
            },
            onError: (Map<String, dynamic> errorResponse) {
              aGeneralBloc.updateAPICalling(false);
              Navigator.pop(mainContext);
            },
          );
        },
      );
    }
  }
}
