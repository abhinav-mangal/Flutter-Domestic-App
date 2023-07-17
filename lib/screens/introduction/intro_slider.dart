import 'package:energym/app_config.dart';
import 'package:energym/screens/introduction/sliderview.dart';
import 'package:energym/screens/login/login.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/loader_button.dart';
import 'package:energym/reusable_component/shared_pref_helper.dart';

//  This is introduction screen open when app laucnhes first time
class IntroSlider extends StatefulWidget {
  static const String routeName = '/IntroSlider';
  @override
  _IntroSliderState createState() => _IntroSliderState();
}

class _IntroSliderState extends State<IntroSlider>
    with SingleTickerProviderStateMixin {
  List<Widget> tabs = <Widget>[];

  PublishSubject<int> dotSubject = PublishSubject<int>();

  AppConfig? _config;

  @override
  void initState() {
    tabs.add(
      SliderView(
          image: ImgConstants.intro1,
          title: AppConstants.intro1Title,
          showDone: false,
          showSkip: false),
    );
    tabs.add(
      SliderView(
          image: ImgConstants.intro2,
          title: AppConstants.intro2Title,
          showSkip: false,
          showDone: false),
    );
    tabs.add(
      SliderView(
          image: ImgConstants.intro3,
          title: AppConstants.intro3Title,
          showDone: true,
          showSkip: false),
    );
    super.initState();
  }

  @override
  void dispose() {
    dotSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    _config = AppConfig.of(context);
    return CustomScaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.zero,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 24,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.zero,
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: PageView(
                      onPageChanged: (int page) {
                        dotSubject.sink.add(page);
                      },
                      children: tabs,
                    ),
                  ),
                ),
              ),
              dotIndicator(),
              const SizedBox(
                height: 32,
              ),
              _btnDone(_config!),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btnDone(AppConfig config) {
    return LoaderButton(
        backgroundColor: config.btnPrimaryColor,
        padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
        onPressed: () async {
          FocusScope.of(context).unfocus();
          await sharedPrefsHelper.set(
              SharedPrefskey.isWalkThroughFinished, true);

          Navigator.pushNamedAndRemoveUntil(
            context,
            Login.routeName,
            ModalRoute.withName('/'),
          );
        },
        title: AppConstants.getStarted);
  }

  Widget dotIndicator() {
    return Align(
      child: StreamBuilder<int>(
        initialData: 0,
        stream: dotSubject.stream,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          final int currentIndex = snapshot.data ?? 0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              dotWidget(0, currentIndex),
              const SizedBox(width: 10),
              dotWidget(1, currentIndex),
              const SizedBox(width: 10),
              dotWidget(2, currentIndex),
            ],
          );
        },
      ),
    );
  }

  Widget dotWidget(int index, int currentIndex) {
    final bool isSelected = index == currentIndex;

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: isSelected
            ? _config!.whiteColor
            : _config!.whiteColor.withOpacity(0.40),
        borderRadius: const BorderRadius.all(
          Radius.circular(3),
        ),
      ),
    );
  }
}
