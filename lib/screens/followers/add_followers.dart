import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/screens/followers/contacts.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share/share.dart';

import '../../utils/common/constants.dart';
import '../../utils/common/main_app_bar.dart';
import '../../utils/common/svg_icon.dart';

class AddFollowers extends StatefulWidget {
  static const String routeName = '/AddFollowers';
  @override
  _AddFollowersState createState() => _AddFollowersState();
}

class _AddFollowersState extends State<AddFollowers>
    with SingleTickerProviderStateMixin {
  AppConfig? _config;
  AnimationController? _animationController;
  UserModel? _currentUser;
  String refUrl = '';
  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
        reverseDuration: Duration(seconds: 2));
    super.initState();
    _currentUser = aGeneralBloc.currentUser;
    refUrl = 'https://energym.io/${_currentUser!.documentId}';
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
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
      _config!,
      backgoundColor: Colors.transparent,
      textColor: _config!.whiteColor,
      title: AppConstants.addFollower,
      elevation: 0,
      isBackEnable: false,
      onBack: () {},
      leadingWidget: IconButton(
          icon: Icon(
            Icons.close,
            size: 24,
            color: _config!.whiteColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
    );
  }

  Widget _mainContainerWidget(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 35, 0, 0),
      child: Column(
        children: [
          _widgetAddInviteText(),
          _widgetByInvitingFollowerText(),
          _widgetSearch(),
          _widgetPlaceHolder(),
          _widgetShareYourReferralLinkText(),
          _widgetRefrelEranText(),
          _widgetCopyReferal(),
          _widgetShare(),
        ],
      ),
    );
  }

  Widget _widgetAddInviteText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
      child: Text(
        AppConstants.addOrInvite,
        style:
            _config!.calibriHeading2FontStyle.apply(color: _config!.whiteColor),
      ),
    );
  }

  Widget _widgetByInvitingFollowerText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
      child: Text(
        AppConstants.byInvitingFollower,
        style:
            _config!.paragraphNormalFontStyle.apply(color: _config!.greyColor),
      ),
    );
  }

  Widget _widgetSearch() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, ContactList.routeName);
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
          minimumSize: const Size(double.infinity, 38),
          backgroundColor: _config!.borderColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Row(
          children: [
            SvgIcon.asset(
              ImgConstants.search,
              size: 20,
              color: _config!.greyColor,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              AppConstants.searchBy,
              style: _config!.paragraphSmallFontStyle
                  .apply(color: _config!.greyColor),
            )
          ],
        ),
      ),
    );
  }

  Widget _widgetPlaceHolder() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(38, 28, 38, 0),
      child: SvgPicture.asset(
        ImgConstants.addFollower,
        //width: double.infinity,
      ),
    );
  }

  Widget _widgetShareYourReferralLinkText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 40, 16, 0),
      child: Text(
        AppConstants.shareYourReferralLink,
        style:
            _config!.calibriHeading2FontStyle.apply(color: _config!.whiteColor),
      ),
    );
  }

  Widget _widgetRefrelEranText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
      child: Text(
        AppConstants.eran,
        style:
            _config!.paragraphNormalFontStyle.apply(color: _config!.greyColor),
      ),
    );
  }

  Widget widgetCopied() {
    return Positioned(
      right: 40,
      child: FadeTransition(
        opacity: _animationController!,
        child: Container(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
          decoration: BoxDecoration(
              color: _config!.whiteColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5)),
          child: Text(
            'COPIED',
            style: _config!.linkNormalFontStyle.apply(
              color: _config!.whiteColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _widgetCopyReferal() {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
      decoration: BoxDecoration(
          color: _config!.borderColor, borderRadius: BorderRadius.circular(8)),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                  child: AutoSizeText(
                    refUrl,
                    maxLines: 1,
                    minFontSize: 5,
                    overflow: TextOverflow.visible,
                    style: _config!.paragraphNormalFontStyle.apply(
                      color: _config!.whiteColor,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: refUrl))
                      .then((value) async {
                    await _animationController!.forward();
                    await _animationController!.reverse();
                  });
                },
                style: TextButton.styleFrom(
                    backgroundColor: _config!.btnPrimaryColor,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ))),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 9, 20, 9),
                  child: Text(
                    AppConstants.copy,
                    style: _config!.linkNormalFontStyle.apply(
                      color: _config!.whiteColor,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _widgetShare() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 71),
        child: TextButton(
          onPressed: () {
            Share.share(refUrl,
                subject: 'Signup using my referral and get sweatcoin bonus');
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
                ImgConstants.share,
                size: 20,
                color: _config!.btnPrimaryColor,
              ),
              const SizedBox(
                width: 11,
              ),
              Text(
                AppConstants.shareViaSocial,
                style: _config!.linkSmallFontStyle.apply(
                  color: _config!.btnPrimaryColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
