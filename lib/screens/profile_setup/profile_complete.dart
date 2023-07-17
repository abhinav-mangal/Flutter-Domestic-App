import 'package:energym/app_config.dart';
import 'package:energym/screens/home/home.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:flutter_svg/svg.dart';
import 'package:energym/reusable_component/shared_pref_helper.dart';
import 'package:energym/models/user_model.dart';

class ProfileComplete extends StatefulWidget {
  static const String routeName = '/ProfileComplete';
  @override
  _ProfileCompleteState createState() => _ProfileCompleteState();
}

class _ProfileCompleteState extends State<ProfileComplete> {
  AppConfig? _config;
  UserModel? _currentUser;
  final GlobalKey _transitionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    FireStoreProvider.instance.fetchCurrentUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return StreamBuilder<DocumentSnapshot?>(
      stream: FireStoreProvider.instance.getCurrentUserUpdate,
      builder:
          // ignore: always_specify_types
          (BuildContext context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          _currentUser = UserModel.fromJson(
              snapshot.data!.data() as Map<String, dynamic>,
              doumentId: snapshot.data!.id);
          aGeneralBloc.updateCurrentUser(_currentUser!);
        }

        return CustomScaffold(
          body: SafeArea(
            child: Container(
              padding: EdgeInsets.zero,
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _widgetPowerBy(),
                  _widgetSuccessTitle(),
                  _widgetSuccessMsg(),
                  _btnDone(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _widgetPowerBy() {
    return SvgPicture.asset(
      ImgConstants.largeProfileSuccess,
    );
  }

  Widget _widgetSuccessTitle() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(32, 40, 32, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(
          AppConstants.profileCreateSuccessTitle,
          style: _config!.calibriHeading2FontStyle.apply(
            color: _config!.whiteColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _widgetSuccessMsg() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(32, 16, 32, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(
          AppConstants.profileCreateSuccessMsg,
          style: _config!.paragraphNormalFontStyle.apply(
            color: _config!.greyColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _btnDone() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 0),
      child: TextButton(
        key: _transitionKey,
        onPressed: () async {
          await sharedPrefsHelper.set(SharedPrefskey.isLoogedIn, true);
          FireStoreProvider.instance.sendFcmNotification(
              _currentUser!,
              _currentUser!.documentId!,
              NotificationType.welcome,
              _currentUser!.documentId!,
              null, null);
          Navigator.of(context).push<void>(
            Home.route(context, _transitionKey),
          );

          // Navigator.pushNamedAndRemoveUntil(
          //                         context,
          //                         Home.routeName,
          //                         ModalRoute.withName('/'));
        },
        style: TextButton.styleFrom(
          backgroundColor: _config!.btnPrimaryColor,
          padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        child: Container(
          padding: EdgeInsets.zero,
          //width: double.infinity,
          height: 48,
          child: Center(
            child: SvgPicture.asset(
              ImgConstants.icPowerOn,
              height: 20,
            ),
          ),
        ),
      ),
    );
  }
}
