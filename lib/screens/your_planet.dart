import 'package:energym/app_config.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:energym/models/user_model.dart';

class YourPlanet extends StatefulWidget {
  static const String routeName = '/YourPlanet';

  @override
  _YourPlanetState createState() => _YourPlanetState();
}

class _YourPlanetState extends State<YourPlanet> {
  AppConfig? _appConfig;
  UserModel? _currentUser;
  APIProvider? _api;

  @override
  void initState() {
    super.initState();
    _currentUser = aGeneralBloc.currentUser;
    _api = APIProvider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    _appConfig = AppConfig.of(context);

    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        child: _widgetMainContainer(),
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _appConfig!,
        backgoundColor: Colors.transparent,
        textColor: _appConfig!.whiteColor,
        title: AppConstants.yourPlanet,
        centerTitle: true,
        elevation: 0, onBack: () {
      // aGeneralBloc.updateAPICalling(false);
      Navigator.pop(context);
    }, actions: <Widget>[
      btnSweatCointBalance(context, _appConfig!),
    ]);
  }

  Widget _widgetMainContainer() {
    return Container(
      padding: EdgeInsets.zero,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text(
                    "LEVEL 2",
                    style: _appConfig!.labelNormalFontStyle
                        .apply(color: _appConfig!.greyColor),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Supercharger",
                    style: _appConfig!.calibriHeading1FontStyle
                        .apply(color: _appConfig!.whiteColor),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Hero(
                    tag: 'gif_tag',
                    child: Image.asset(
                      ImgConstants.planetGif,
                      height: 250,
                    ),
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'You have offset',
                          style: _appConfig!.paragraphNormalFontStyle
                              .apply(color: _appConfig!.skyBlueColor),
                        ),
                        TextSpan(
                          text: ' 23 tonnes ',
                          style: _appConfig!.paragraphNormalFontStyle
                              .apply(color: _appConfig!.btnPrimaryColor),
                        ),
                        TextSpan(
                          text: 'of carbon',
                          style: _appConfig!.paragraphNormalFontStyle
                              .apply(color: _appConfig!.skyBlueColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 38,
                  ),
                  _widgetTile(
                    text: 'You have unlocked Trees,'
                        '\nadd them to your planet',
                    bgColor: _appConfig!.skyBlueColor,
                    img: ImgConstants.tree,
                  ),
                  SizedBox(
                    height: 28,
                  ),
                  _widgetTile(
                    text: 'Congrats on getting your \nsupercharger badge!',
                    bgColor: _appConfig!.btnPrimaryColor,
                    img: ImgConstants.logoR,
                  ),
                  SizedBox(
                    height: 32,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          _widgetShareSocial(),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget _widgetShareSocial() {
    return Align(
      alignment: Alignment.topCenter,
      child: TextButton(
        onPressed: () {

        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgIcon.asset(ImgConstants.share,
                size: 20, color: _appConfig!.btnPrimaryColor),
            const SizedBox(
              width: 9,
            ),
            Text(
              AppConstants.shareViaSocial,
              style: _appConfig!.calibriHeading5FontStyle.apply(
                color: _appConfig!.btnPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _widgetTile({String? text, String? img, Color? bgColor}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 64,
          width: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor!.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Image.asset(img!, width: 40, height: 40,),
        ),
        const SizedBox(width: 16,),
        Text(
          text!,
          style: _appConfig!.paragraphLargeFontStyle.apply(
            color: _appConfig!.whiteColor,
          ),
        ),
      ],
    );
  }
}
