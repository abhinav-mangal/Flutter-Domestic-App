import 'package:energym/models/user_model.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rxdart/rxdart.dart';

// This is leaderboard bloc contains leaderboard business logic
class LeaderboardBloc {
  final BehaviorSubject<List<UserModel>> _userLeaderBoard =
      BehaviorSubject<List<UserModel>>();

  ValueStream<List<UserModel>> get userLeaderBoard => _userLeaderBoard.stream;
  List<UserModel> leaderboardList = <UserModel>[];

  final BehaviorSubject<List<UserModel>> _userLeaderBoardRegional =
      BehaviorSubject<List<UserModel>>();
  ValueStream<List<UserModel>> get userLeaderBoardRegional =>
      _userLeaderBoardRegional.stream;
  List<UserModel> leaderboardRegionalList = <UserModel>[];

  //  Fetch leaderboaerd data from firebase
  Future<void> getLeaderboardData(BuildContext mainContext,
      {String? timeZone, bool? sortedByWatts, bool? sortedByFTP}) async {
    leaderboardList = [];
    final List<DocumentSnapshot<Map<String, dynamic>?>?>? _list =
        await FireStoreProvider.instance.getUserLeaderBoard(mainContext,
            timeZone: timeZone,
            sortedByWatts: sortedByWatts,
            sortedByFTP: sortedByFTP);

    if (_list != null && _list.isNotEmpty) {
      List<UserModel> _listModel = <UserModel>[];
      _list.forEach((document) async {
        _listModel.add(UserModel.fromJson(document!.data()!));
      });

      // Sorting
      if (sortedByWatts!) {
        _listModel.sort((UserModel a, UserModel b) {
          if (a.watts! < b.watts!) {
            return 1;
          }
          return 0;
        });
      } else {
        _listModel.sort((UserModel a, UserModel b) {
          if (a.ftpLeaderboard! < b.ftpLeaderboard!) {
            return 1;
          }
          return 0;
        });
      }

      leaderboardList.addAll(_listModel);

      _userLeaderBoard.sink.add(leaderboardList);
    } else {
      _userLeaderBoard.sink.add(leaderboardList);
    }
  }

  Future<void> searchLeaderboard(BuildContext mainContext,
      {@required String? searchText}) async {
    if (searchText != null && searchText.isNotEmpty) {
      List<UserModel> _listModel = <UserModel>[];

      _listModel = leaderboardList
          .where((UserModel user) => user.fullName!
              .toLowerCase()
              .contains(searchText.toString().toLowerCase()))
          .map((UserModel e) => e)
          .toList();
      _userLeaderBoard.sink.add(_listModel);
    } else {
      _userLeaderBoard.sink.add(leaderboardList);
    }
  }

  Future<void> getLeaderboardRegionalData(BuildContext mainContext,
      {String? timeZone, bool? sortedByWatts, bool? sortedByFTP}) async {
    leaderboardRegionalList = [];
    final List<DocumentSnapshot<Map<String, dynamic>?>?>? _list =
        await FireStoreProvider.instance.getUserLeaderBoard(mainContext,
            timeZone: timeZone,
            sortedByWatts: sortedByWatts,
            sortedByFTP: sortedByFTP);

    if (_list != null && _list.isNotEmpty) {
      List<UserModel> _listModel = <UserModel>[];
      _list.forEach((document) async {
        _listModel.add(UserModel.fromJson(document!.data()!));
      });

      // Sorting
      if (sortedByWatts!) {
        _listModel.sort((UserModel a, UserModel b) {
          if (a.watts! < b.watts!) {
            return 1;
          }
          return 0;
        });
      } else {
        _listModel.sort((UserModel a, UserModel b) {
          if (a.ftpLeaderboard! < b.ftpLeaderboard!) {
            return 1;
          }
          return 0;
        });
      }

      leaderboardRegionalList.addAll(_listModel);

      _userLeaderBoardRegional.sink.add(leaderboardRegionalList);
    } else {
      _userLeaderBoardRegional.sink.add(leaderboardRegionalList);
    }
  }

  Future<void> searchLeaderboardRegional(BuildContext mainContext,
      {@required String? searchText}) async {
    if (searchText != null && searchText.isNotEmpty) {
      List<UserModel> _listModel = <UserModel>[];

      _listModel = leaderboardRegionalList
          .where((UserModel user) => user.fullName!
              .toLowerCase()
              .contains(searchText.toString().toLowerCase()))
          .map((UserModel e) => e)
          .toList();
      _userLeaderBoardRegional.sink.add(_listModel);
    } else {
      _userLeaderBoardRegional.sink.add(leaderboardRegionalList);
    }
  }
}
