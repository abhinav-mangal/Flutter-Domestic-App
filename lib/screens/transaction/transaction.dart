import 'package:energym/app_config.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/nodata.dart';
import 'package:energym/screens/transaction/transaction_bloc.dart';
import 'package:energym/screens/transaction/transaction_widget.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/models/sweatcoin_user_model.dart';
import 'package:energym/models/transaction_model.dart';
import 'package:energym/utils/extensions/extension.dart';

class Transaction extends StatefulWidget {
  const Transaction({Key? key}) : super(key: key);
  static const String routeName = '/Transaction';

  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  AppConfig? _config;
  APIProvider? _api;
  UserModel? _currentUser;
  final TransactionBloc _blocTransaction = TransactionBloc();
  @override
  void initState() {
    super.initState();
    _currentUser = aGeneralBloc.currentUser;
    _api = APIProvider.of(context);
    _blocTransaction.getTransaction(context);
  }

  @override
  void dispose() {
    _blocTransaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _widgetBalanceView(),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 0),
              child: Divider(
                height: 1,
                thickness: 1,
                color: _config!.whiteColor.withOpacity(0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 16),
              child: Text(AppConstants.allTransactions,
                  style: _config!.calibriHeading3FontStyle
                      .apply(color: _config!.whiteColor),
                  textAlign: TextAlign.center),
            ),
            Expanded(
              child: _widgetTransactionList(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(
      context, _config!,
      backgoundColor: Colors.transparent,
      textColor: _config!.whiteColor,
      title: AppConstants.sweatCoins,
      elevation: 0,
      //gradient: AppColors.gradintBtnSignUp,
      onBack: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _widgetBalanceView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.only(left: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _widgetCurrentBalance(),
            Text(AppConstants.currentBalance.toUpperCase(),
                style: _config!.labelNormalFontStyle
                    .apply(color: _config!.greyColor),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _widgetCurrentBalance() {
    return FutureBuilder<SweatCoinUser?>(
        future: aGeneralBloc.getCurrentSweatCoinUser(_api!, context),
        builder: (BuildContext? context, AsyncSnapshot<SweatCoinUser?>? snapshot) {
          bool isLoading = !snapshot!.hasData;
          String balance = '0';
          if (snapshot.hasData && snapshot.data != null) {
            SweatCoinUser user = snapshot.data!;
            balance = user.balance.toString();
          }

          return Text(balance,
              style: _config!.antonioHeading1FontStyle.apply(
                  color: _config!.btnPrimaryColor,
                  fontSizeDelta: 16,
                  fontWeightDelta: 3),
              textAlign: TextAlign.center);
        });
  }

  Widget _widgetTransactionList1() {
    return Container(
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _widgetTransaction() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.axis == Axis.vertical) {
          if (scrollNotification.metrics.pixels ==
              scrollNotification.metrics.maxScrollExtent) {
            //_blocFeed.getFeed(context);
          }

          return true;
        }
        return false;
      },
      child: _widgetTransactionList(),
    );
  }

  Widget _widgetTransactionList() {
    return StreamBuilder<List<TransactionModel>>(
        stream: _blocTransaction.getUserTransaction,
        builder: (_, AsyncSnapshot<List<TransactionModel>> snapshot) {
          final bool isLoading = !snapshot.hasData;
          List<TransactionModel> _list = <TransactionModel>[];
          if (snapshot.hasData && snapshot.data != null) {
            _list.addAll(snapshot.data!);
          }

          if (_list.isEmpty) {
            return NODataWidget();
          }
          return ListView.builder(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 20),
              physics: const ClampingScrollPhysics(),
              itemCount: isLoading ? 5 : _list.length,
              itemBuilder: (_, int index) {
                final TransactionModel? data = isLoading ? null : _list[index];
                bool isShowHeaderdata = false;
                if (data != null && _list.length > 1) {
                  if(index == 0){
                    isShowHeaderdata = true;
                  } else {
                    final TransactionModel previousData = _list[index - 1];

                  isShowHeaderdata =
                      !data.createdAt!.isEqualDate(previousData.createdAt!);
                  }
                  
                }
                print('isShowHeaderdata >>> $isShowHeaderdata');
                return TransactionWidget(
                  data: data,
                  isShowHeader: isShowHeaderdata,
                );
              });
        });
  }
}
