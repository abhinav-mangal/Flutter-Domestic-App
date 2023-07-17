import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:energym/models/feed_model.dart';

class FeedBloc {
  final BehaviorSubject<List<FeedModel>> _userFeed =
      BehaviorSubject<List<FeedModel>>();

  ValueStream<List<FeedModel>> get getUserFeed => _userFeed.stream;

  List<FeedModel> feedList = <FeedModel>[];
  DocumentSnapshot<Map<String, dynamic>?>? lastDocument;
  bool isLoadingFeed = false;
  Future<void> getFeed(BuildContext mainContext,
      {bool isReset = false, String? userId}) async {
    if (!isLoadingFeed) {
      isLoadingFeed = true;
      if (isReset) {
        lastDocument = null;
        feedList.clear();
        _userFeed.sink.add(feedList);
      }
      final List<DocumentSnapshot<Map<String, dynamic>?>?>? _list =
          await FireStoreProvider.instance.getPost(
        mainContext,
        docmentLimit: 20,
        lastDocument: lastDocument,
        userId: userId,
      );

      if (_list != null && _list.isNotEmpty) {
        lastDocument = _list.last;
        List<FeedModel> _listModel = <FeedModel>[];
        _list.forEach((document) async {
          _listModel.add(FeedModel.fromJson(document!.data()!));
        });
        feedList.addAll(_listModel);
        isLoadingFeed = false;
        _userFeed.sink.add(feedList);
      } else {
        isLoadingFeed = false;
        _userFeed.sink.add(feedList);
      }
    }
  }

  void updateFeed(List<FeedModel> list) {
    feedList = list;
    _userFeed.sink.add(feedList);
  }

  void dispose() {
    _userFeed.close();
  }
}
