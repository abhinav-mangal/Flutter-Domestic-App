import 'package:energym/app_config.dart';
import 'package:energym/models/group_model.dart';
import 'package:energym/models/notification_model.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/reusable_component/nodata.dart';
import 'package:energym/screens/followers/follower_bloc.dart';
import 'package:energym/screens/notification/notificationBloc.dart';
import 'package:energym/screens/notification/widget_notification.dart';
import 'package:energym/screens/settings/settings.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:flutter/material.dart';

class AppNotification extends StatefulWidget {
  const AppNotification({Key? key}) : super(key: key);
  static const String routeName = '/Notification';
  @override
  _AppNotificationState createState() => _AppNotificationState();
}

class _AppNotificationState extends State<AppNotification> {
  UserModel? _currentUser;
  AppConfig? _appConfig;
  FollowersBloc? _blocFollower;
  NotificationBloc? _blocNotification;

  @override
  void initState() {
    super.initState();
    _currentUser = aGeneralBloc.currentUser;
    _blocFollower = FollowersBloc();
    _blocNotification = NotificationBloc();

    _blocNotification?.getNotificationData(_currentUser!.documentId!);
  }

  @override
  void dispose() {
    super.dispose();
    _blocFollower?.dispose();
    _blocNotification?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appConfig = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        bottom: false,
        child: Container(
          padding: EdgeInsets.zero,
          width: double.infinity,
          height: double.infinity,
          child: _mainContainerWidget(context),
        ),
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(
      context,
      _appConfig!,
      backgoundColor: Colors.transparent,
      textColor: _appConfig!.whiteColor,
      title: NavigationBarConstants.notifications,
      elevation: 0,
      isBackEnable: true,
      onBack: () {
        if (mounted) {
          print(context);
          Navigator.pop(context);
        }
      },
      actions: [
        IconButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          //iconSize: 16,
          icon: SvgIcon.asset(
            ImgConstants.icSettings,
            color: _appConfig!.whiteColor,
          ),
          //color: color,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            Navigator.pushNamed(context, AppSettings.routeName);
            //Navigator.pop(context);
          },
        )
      ],
    );
  }

  Widget _mainContainerWidget(BuildContext mainContext) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: StreamBuilder<List<NotificationModel>>(
          stream: _blocNotification?.notificationData,
          builder: (BuildContext context,
              AsyncSnapshot<List<NotificationModel>> snapshot) {
            List<NotificationModel> _list = [];
            bool isLoading = !snapshot.hasData;
            if (snapshot.hasData && snapshot.data != null) {
              _list = snapshot.data!;
            }
            if (!isLoading && _list.isEmpty) {
              return NODataWidget();
            }
            return ListView.builder(
              itemCount: isLoading ? 5 : _list.length,
              itemBuilder: (_, int index) {
                if (!isLoading) {
                  NotificationModel? notification = _list[index];
                  return NotificationWidget(
                    data: notification,
                    onPressDeleteInvite: (GroupModel group,
                        Map<String, dynamic> needToStore,
                        notificationData) async {
                      // print(needToStore);
                      aGeneralBloc.updateAPICalling(true);

                      await FireStoreProvider.instance.updateGroupParticipant(
                        context: context,
                        groupModel: group,
                        onSuccess:
                            (Map<String, dynamic> successResponse) async {
                          // type update to nofitifcation
                          notificationData.entityType =
                              NotificationType.inviteGroupMemberDeleted;

                          final Map<String, dynamic> _notificationData =
                              <String, dynamic>{};
                          _notificationData[NotificaitonCollectionField
                              .entityType] = notificationData.entityType;

                          await _blocNotification?.updateNotificationData(
                            notificationData.documentId!,
                            _notificationData,
                          );

                          // Get notification data
                          await _blocNotification
                              ?.getNotificationData(_currentUser!.documentId!);

                          aGeneralBloc.updateAPICalling(false);
                        },
                        onError: (Map<String, dynamic> errorResponse) {
                          aGeneralBloc.updateAPICalling(false);
                        },
                        data: needToStore,
                      );
                    },
                    onPressJoinInvite: (GroupModel group,
                        Map<String, dynamic> needToStore,
                        notificationData) async {
                      // print(needToStore);

                      await FireStoreProvider.instance.updateGroupParticipant(
                        context: context,
                        groupModel: group,
                        onSuccess:
                            (Map<String, dynamic> successResponse) async {
                          // type update to nofitifcation
                          notificationData.entityType =
                              NotificationType.inviteGroupMemberJoined;

                          final Map<String, dynamic> _notificationData =
                              <String, dynamic>{};
                          _notificationData[NotificaitonCollectionField
                              .entityType] = notificationData.entityType;

                          await _blocNotification?.updateNotificationData(
                            notificationData.documentId!,
                            _notificationData,
                          );

                          // Get notification data
                          await _blocNotification
                              ?.getNotificationData(_currentUser!.documentId!);

                          aGeneralBloc.updateAPICalling(false);
                        },
                        onError: (Map<String, dynamic> errorResponse) {
                          aGeneralBloc.updateAPICalling(false);
                        },
                        data: needToStore,
                      );
                    },
                  );
                } else {
                  return const SizedBox();
                }
              },
            );
          }),
    );
  }
}
