import 'package:energym/app_config.dart';
import 'package:energym/reusable_component/skeleton.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/common/svg_picture_customise.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:flutter/material.dart';
import 'package:energym/models/transaction_model.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:flutter_svg/svg.dart';

class TransactionWidget extends StatelessWidget {
  const TransactionWidget(
      {Key? key, required this.data, this.isShowHeader = false})
      : super(key: key);
  final TransactionModel? data;
  final bool? isShowHeader;
  @override
  Widget build(BuildContext context) {
    AppConfig _config = AppConfig.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isShowHeader!) _widgetHeaderData(_config),
          _widgetTransactionInfo(_config),
        ],
      ),
    );
  }

  Widget _widgetHeaderData(AppConfig _config) {
    if (data == null) {
      return SkeletonText(
        width: 100,
        height: 20,
      );
    } else {
      return Container(
        padding: const EdgeInsets.only(bottom: 12.0),
        width: double.infinity,
        child: Text(
          data!.createdAt!.showDayMonth(),
          style: _config.labelNormalFontStyle.apply(color: _config.greyColor),
        ),
      );
    }
  }

  Widget _widgetTransactionInfo(AppConfig _config) {
    return Row(
      children: [
        _widgetIcon(_config),
        Expanded(child: _widgetTransactionDescription(_config),),
        _widgetCreditOrDebitSymbol(_config),
         SvgPicture.asset(
          ImgConstants.sweatCoin,
          width: 20,
          height: 20,
          color: _config.btnPrimaryColor,

        ),
        const SizedBox(width: 8,),
        _widgetAmmount(_config)
      ],
    );
  }

  Widget _widgetIcon(AppConfig _config){
      if (data == null) {
      return SkeletonContainer(
        width: 40,
        height: 40,
      );
    } else {
      return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _getBackGroundColor(_config)),
            child: Center(
              child: Image.asset(
                ImgConstants.logoR,
                color: _getLogoColor(_config),
                width: 20,
                height: 20,
              ),
            ),
          );
      
    }
  }

  Widget _widgetTransactionDescription(AppConfig _config) {
    if (data == null) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
        child: SkeletonText(
          width: double.infinity,
          height: 20,
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
        child: Text(
          data?.transactionDescription ?? '',
          style: _config.paragraphNormalFontStyle.apply(color: _config.whiteColor),
        ),
      );
    }
  }

  Widget _widgetAmmount(AppConfig _config) {
    if (data == null) {
      return SkeletonText(
        width: 30,
        height: 36,
      );
    } else {
      return Container(
        child: Text(
          data!.amount.toString(),
          style: _config.antonioHeading3FontStyle.apply(color: _config.whiteColor),
        ),
      );
    }
  }

  Widget _widgetCreditOrDebitSymbol(AppConfig _config) {
    if (data == null) {
      return Padding(
       padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
        child: SkeletonText(
          width: 20,
          height: 20,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
        child: SvgIcon.asset(
          data?.transactionEntryMode == TransactionMode.credit ? ImgConstants.plus : ImgConstants.minus,
          size: 20,
          color: _config.whiteColor,
        ),
      );
    }
  }


  Color _getBackGroundColor(AppConfig _config){
    if(data!.transactionEntryType == TransactionType.referral ){
      return _config.btnPrimaryColor;
    }

    return _config.btnPrimaryColor.withOpacity(0.20);
  }

  Color _getLogoColor(AppConfig _config) {
    if (data!.transactionEntryType == TransactionType.referral) {
      return _config.whiteColor;
    }

    return _config.btnPrimaryColor;
  }
}
