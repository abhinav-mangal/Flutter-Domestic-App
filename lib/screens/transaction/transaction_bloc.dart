import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:energym/models/transaction_model.dart';

class TransactionBloc {
  final BehaviorSubject<List<TransactionModel>> _userTransaction =
      BehaviorSubject<List<TransactionModel>>();

  ValueStream<List<TransactionModel>> get getUserTransaction =>
      _userTransaction.stream;

  List<TransactionModel> transactionList = <TransactionModel>[];
  DocumentSnapshot<Map<String, dynamic>?>? lastDocument;
  bool isLoadingFeed = false;
  Future<void> getTransaction(BuildContext mainContext,
      {bool isReset = false, String? userId}) async {
    if (!isLoadingFeed) {
      isLoadingFeed = true;
      if (isReset) {
        lastDocument = null;
        transactionList.clear();
        _userTransaction.sink.add(transactionList);
      }
      final List<DocumentSnapshot<Map<String, dynamic>?>?>? _list =
          await FireStoreProvider.instance.getTransaction(
        mainContext,
        docmentLimit: 20,
        lastDocument: lastDocument,
      );

      if (_list != null && _list.isNotEmpty) {
        lastDocument = _list.last;
        List<TransactionModel> _listModel = <TransactionModel>[];
        _list.forEach((document) async {
          _listModel.add(TransactionModel.fromJson(document!.data()!));
        });
        transactionList.addAll(_listModel);
        isLoadingFeed = false;
        _userTransaction.sink.add(transactionList);
      } else {
        isLoadingFeed = false;
        _userTransaction.sink.add(transactionList);
      }
    }
  }

  void updateFeed(List<TransactionModel> list) {
    transactionList = list;
    _userTransaction.sink.add(transactionList);
  }

  void dispose() {
    _userTransaction.close();
  }
}
