import 'package:energym/models/group_model.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/helpers/firebase/auth_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:energym/models/follower_model.dart';

class FollowersBloc {
  final BehaviorSubject<dynamic> _userStream = BehaviorSubject<dynamic>();
  ValueStream<dynamic> get getUser => _userStream.stream;

  final BehaviorSubject<List<FollowerModel>> _userFollower =
      BehaviorSubject<List<FollowerModel>>();

  ValueStream<List<FollowerModel>> get getUserFollower => _userFollower.stream;

  List<FollowerModel> followerList = <FollowerModel>[];

  final BehaviorSubject<List<GroupModel>> _userGroups =
      BehaviorSubject<List<GroupModel>>();

  ValueStream<List<GroupModel>> get getUserGroups => _userGroups.stream;

  List<GroupModel> groupsList = <GroupModel>[];
  // List<UserModel> usersList = <UserModel>[];

  final BehaviorSubject<List<UserModel>> _userGroupsMembers =
      BehaviorSubject<List<UserModel>>();

  ValueStream<List<UserModel>> get getUserGroupsMenbers =>
      _userGroupsMembers.stream;

  final BehaviorSubject<List<UserModel>> _alluser =
      BehaviorSubject<List<UserModel>>();

  ValueStream<List<UserModel>> get alluser => _alluser.stream;
  List<UserModel> allUserList = <UserModel>[];

  void onUpdateUser(dynamic value) {
    _userStream.sink.add(value);
  }

  Future<void> checkForUser({@required UserModel? contact}) async {
    if (contact != null) {
      DocumentSnapshot<Map<String, dynamic>>? doc = await FireStoreProvider
          .instance
          .getUserWithUsername(username: contact.username);
      if (doc != null) {
        final Map<String, dynamic> userData =
            doc.data() as Map<String, dynamic>;

        final String loggedInUser = AuthProvider.instance.currentUserId();

        final bool isFollowing = await FireStoreProvider.instance
            .isFollowing(uesrId: doc.id, followerId: loggedInUser);
        userData['is_following'] = isFollowing;
        UserModel user = UserModel.fromJson(
          userData,
          doumentId: doc.id,
        );

        onUpdateUser(user);
        return;
      }

      onUpdateUser(contact);
    }
  }

  Future<void> getFollower(BuildContext mainContext,
      {@required String? userId}) async {
    final List<DocumentSnapshot<Map<String, dynamic>?>?>? _list =
        await FireStoreProvider.instance.getUserFollower(
      mainContext,
      userId: userId!,
    );

    if (_list != null && _list.isNotEmpty) {
      List<FollowerModel> _listModel = <FollowerModel>[];
      _list.forEach((document) async {
        _listModel.add(FollowerModel.fromJson(document!.data()!));
      });
      followerList.addAll(_listModel);
      debugPrint('followerList 1 >>> $followerList');
      _userFollower.sink.add(followerList);

      print('Done data received');
    } else {
      _userFollower.sink.add(followerList);
    }
  }

  Future<void> searchFollower(BuildContext mainContext,
      {@required String? searchText}) async {
    debugPrint('searchText >>> $searchText');
    debugPrint('followerList >>> $followerList');
    if (searchText != null && searchText.isNotEmpty) {
      List<FollowerModel> _listModel = <FollowerModel>[];

      _listModel = followerList
          .where((FollowerModel follower) =>
              follower.followerFullName!
                  .toLowerCase()
                  .contains(searchText.toString().toLowerCase()) ||
              follower.followerUsername!
                  .toLowerCase()
                  .contains(searchText.toString().toLowerCase()) ||
              follower.followerMobileNumber!
                  .toLowerCase()
                  .startsWith(searchText.toString().toLowerCase()))
          .map((FollowerModel e) => e)
          .toList();
      debugPrint('followerList >>> $followerList');
      debugPrint('_listModel >>> $_listModel');
      _userFollower.sink.add(_listModel);
    } else {
      _userFollower.sink.add(followerList);
    }
  }

  void updateFollower(List<FollowerModel> list) {
    debugPrint('updateFollower >>> $list');
    followerList = list;
    _userFollower.sink.add(followerList);
  }

  // Fetch group which is joined by loggedin user
  Future<void> getUserJoinedGroups(BuildContext mainContext,
      {@required String? userId, @required String? loggedInUserId}) async {
    final List<DocumentSnapshot<Map<String, dynamic>?>?>? _list =
        await FireStoreProvider.instance.getUserGroups(
      mainContext,
      userId: userId,
    );
    if (_list != null && _list.isNotEmpty) {
      List<GroupModel> _listModel = <GroupModel>[];

      _list.forEach((document) async {
        _listModel.add(GroupModel.fromJson(document!.data()!));
      });

      List<GroupModel> _listModell = <GroupModel>[];
      _listModel.forEach((groupModel) {
        if (groupModel.participantId!.contains(loggedInUserId)) {
          _listModell.add(groupModel);
        }
      });

      _listModell.forEach((groupModel) {
        groupModel.participantId?.forEach((id) {
          FireStoreProvider.instance.getUserData(userId: id).then((value) {
            groupModel.totalWatts = groupModel.totalWatts! + value.watts!;
            _userGroups.sink.add(groupsList);
          });
        });
      });
      groupsList.clear();
      groupsList.addAll(_listModell);
      _userGroups.sink.add(groupsList);
    } else {
      _userGroups.sink.add(groupsList);
    }
  }

  // Fetch group members
  Future<void> getGroupMembers(List<String?> ids) async {
    List<UserModel> _listUserModel = <UserModel>[];
    _listUserModel.clear();
    ids.forEach((id) async {
      await FireStoreProvider.instance
          .getUserData(userId: id)
          .then((groupUser) {
        _listUserModel.add(groupUser);

        _userGroupsMembers.sink.add(_listUserModel);
      });

      _userGroupsMembers.sink.add(_listUserModel);
    });
  }

  // Sorting leaderbord data based on FTP and watts
  Future<void> sorting(List<UserModel> usersList, bool byFTP) async {
    List<UserModel> _listUserModel = <UserModel>[];
    _listUserModel.addAll(usersList);
    if (byFTP) {
      _listUserModel.sort((UserModel a, UserModel b) {
        final aResult = a.ftpLeaderboard;
        final bResult = b.ftpLeaderboard;
        if (aResult! < bResult!) {
          return 1;
        }
        return 0;
      });
    } else {
      _listUserModel.sort((UserModel a, UserModel b) {
        final aResult = a.watts;
        final bResult = b.watts;
        if (aResult! < bResult!) {
          return 1;
        }
        return 0;
      });
    }

    _userGroupsMembers.sink.add(_listUserModel);
  }

  // This function to delete group
  Future<void> deleteGroup(
    BuildContext context,
    GroupModel groupModel,
  ) async {
    await FireStoreProvider.instance.deleteGroup(
      context: context,
      groupModel: groupModel,
      onSuccess: (Map<String, dynamic> successResponse) {
        aGeneralBloc.updateAPICalling(false);
        Navigator.pop(context);
      },
      onError: (Map<String, dynamic> errorResponse) {
        aGeneralBloc.updateAPICalling(false);
        Navigator.pop(context);
      },
    );
  }

  // This function to update group participant
  Future<void> groupParticipantUpdate(
    BuildContext context,
    GroupModel groupModel,
    Map<String, dynamic>? userData,
  ) async {
    await FireStoreProvider.instance.updateGroupParticipant(
      context: context,
      groupModel: groupModel,
      onSuccess: (Map<String, dynamic> successResponse) {
        aGeneralBloc.updateAPICalling(false);
        Navigator.pop(context);
        Navigator.pop(context, true);
      },
      onError: (Map<String, dynamic> errorResponse) {
        aGeneralBloc.updateAPICalling(false);
        Navigator.pop(context);
      },
      data: userData,
    );
  }

  // This function to update group participant in group table
  Future<void> groupJoin(BuildContext context, GroupModel groupModel,
      Map<String, dynamic>? userData, Function(bool)? onJoin) async {
    await FireStoreProvider.instance.updateGroupParticipant(
      context: context,
      groupModel: groupModel,
      onSuccess: (Map<String, dynamic> successResponse) {
        aGeneralBloc.updateAPICalling(false);
        const CustomAlertDialog().showAlert(
            context: context,
            title: AppConstants.appName,
            message: MsgConstants.groupjoin,
            onSuccess: () async {
              if (onJoin != null) {
                onJoin(true);
              }
            });
      },
      onError: (Map<String, dynamic> errorResponse) {
        aGeneralBloc.updateAPICalling(false);
        const CustomAlertDialog().showExeptionErrorMessage(
          context: context,
          title: errorResponse[AppKeyConstant.code] as String,
          message: errorResponse[AppKeyConstant.message] as String,
          buttonTitle: AppConstants.ok,
          onPress: () {
            Navigator.pop(context);
          },
        );
      },
      data: userData,
    );
  }

  // Get public group which is not joined by loggedin user
  Future<void> getUserNotJoinedGroups(BuildContext mainContext,
      {@required String? userId}) async {
    final List<DocumentSnapshot<Map<String, dynamic>?>?>? _list =
        await FireStoreProvider.instance.getPublicGroupsWhichNotJoined(
      mainContext,
      userId: userId!,
    );
    if (_list != null && _list.isNotEmpty) {
      List<GroupModel> _listModel = <GroupModel>[];
      _list.forEach((document) async {
        print(document);
        _listModel.add(GroupModel.fromJson(document!.data()!));
      });

      List<GroupModel> _listModelNotJoined = <GroupModel>[];

      _listModel.forEach((groupModel) {
        if (!groupModel.participantId!.contains(userId)) {
          _listModelNotJoined.add(groupModel);
        }
      });
      _listModelNotJoined.forEach((groupModel) {
        groupModel.participantId?.forEach((id) {
          FireStoreProvider.instance.getUserData(userId: id).then((value) {
            groupModel.totalWatts = groupModel.totalWatts! + value.watts!;
            _userGroups.sink.add(groupsList);
          });
        });
      });
      groupsList.clear();
      groupsList.addAll(_listModelNotJoined);
      _userGroups.sink.add(_listModelNotJoined);
    } else {
      _userGroups.sink.add(groupsList);
    }
  }

  // This function to search group
  Future<void> searchGroup(BuildContext mainContext,
      {@required String? searchText}) async {
    if (searchText != null && searchText.isNotEmpty) {
      List<GroupModel> _listModel = <GroupModel>[];

      _listModel = groupsList
          .where((GroupModel group) =>
              group.groupName!
                  .toLowerCase()
                  .contains(searchText.toString().toLowerCase()) ||
              group.participantName!
                  .join(',')
                  .toLowerCase()
                  .startsWith(searchText.toString().toLowerCase()))
          .map((GroupModel e) => e)
          .toList();

      _userGroups.sink.add(_listModel);
    } else {
      _userGroups.sink.add(groupsList);
    }
  }

  // Fetch all users from user table
  Future<void> getAllUsers(BuildContext mainContext) async {
    final List<DocumentSnapshot<Map<String, dynamic>?>?>? _list =
        await FireStoreProvider.instance.getAllUsers(mainContext);

    if (_list != null && _list.isNotEmpty) {
      List<UserModel> _listModel = <UserModel>[];
      allUserList.clear();
      _list.forEach((document) async {
        final userData = UserModel.fromJson(document!.data()!);

        _listModel.add(userData);
        allUserList.add(userData);
        _alluser.sink.add(allUserList);
      });
    } else {
      _alluser.sink.add(allUserList);
    }
  }

  // This function to search user
  Future<void> searchUser(BuildContext mainContext,
      {@required String? searchText}) async {
    debugPrint('searchText >>> $searchText');
    debugPrint('followerList >>> $followerList');
    if (searchText != null && searchText.isNotEmpty) {
      List<UserModel> _listModel = <UserModel>[];

      _listModel = allUserList
          .where((UserModel user) =>
              user.fullName!
                  .toLowerCase()
                  .contains(searchText.toString().toLowerCase()) ||
              user.username!
                  .toLowerCase()
                  .startsWith(searchText.toString().toLowerCase()))
          .map((UserModel e) => e)
          .toList();
      debugPrint('followerList >>> $followerList');
      debugPrint('_listModel >>> $_listModel');
      _alluser.sink.add(_listModel);
    } else {
      _alluser.sink.add(allUserList);
    }
  }

  void updateGroups(List<GroupModel> list) {
    groupsList = list;
    _userGroups.sink.add(groupsList);
  }

  void dispose() {
    _userStream.close();
    _userFollower.close();
    _userGroups.close();
  }
}
