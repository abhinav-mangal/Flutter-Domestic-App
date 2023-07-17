import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';

import '../../app_config.dart';
import '../../reusable_component/custom_scaffold.dart';
import '../../reusable_component/loader_button.dart';
import '../../reusable_component/main_app_bar.dart';
import '../../utils/common/constants.dart';
import '../../utils/helpers/firebase/firestore_provider.dart';
import '../../utils/helpers/routing/router.dart';
import '../profile_setup/profile_complete.dart';

class CmsArgs extends RoutesArgs {
  CmsArgs({
    required this.cmsType,
    this.isShowAgreeButton,
  }) : super(isHeroTransition: true);
  final bool? isShowAgreeButton;
  final String cmsType;
}

class CMS extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  CMS({
    Key? key,
    required this.cmsType,
    this.isShowAgreeButton,
  }) : super(key: key);

  static const String routeName = '/CMS';
  final bool? isShowAgreeButton;
  final String cmsType;

  @override
  _CMSState createState() => _CMSState();
}

class _CMSState extends State<CMS> {
  bool? _isShowAgreeButton;
  String? _cmsType;
  @override
  void initState() {
    super.initState();
    _cmsType = widget.cmsType;
    _isShowAgreeButton = widget.isShowAgreeButton ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final AppConfig _config = AppConfig.of(context);
    return CustomScaffold(
      appBar: getMainAppBar(
        context,
        _config,
        title: getNavigationTittel(),
        backgoundColor: _config.blackColor,
        textColor: _config.whiteColor,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
          child: FutureBuilder<String>(
            future: FireStoreProvider.instance.getCMS(_cmsType!),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              String body = '';
              if (snapshot.hasData && snapshot.data != null) {
                body = snapshot.data!;
              }
              return SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                child: Html(
                  data: body,
                  // textAlign: TextAlign.center,
                  // style: context.theme.textTheme.bodyText2
                  //     .apply(color: AppColors.textColorGrey),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _btnAgree(_config),
    );
  }

  String getNavigationTittel() {
    String title = '';
    switch (_cmsType) {
      case CMSType.terms:
        title = NavigationBarConstants.termsOfUse;
        break;
      case CMSType.privacy:
        title = NavigationBarConstants.privacyPolicy;
        break;
      case CMSType.info:
        title = NavigationBarConstants.info;
        break;
      default:
        break;
    }

    return title;
  }

  Widget _btnAgree(AppConfig config) {
    return _isShowAgreeButton!
        ? LoaderButton(
            backgroundColor: config.btnPrimaryColor,
            padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
            onPressed: () async {
              FocusScope.of(context).unfocus();
              Navigator.pushNamed(context, ProfileComplete.routeName);
            },
            title: AppConstants.agree)
        : const SizedBox();
  }
}
