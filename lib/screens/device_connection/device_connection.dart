import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/loader_button.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/screens/device_connection/device_connection_info.dart';
import 'package:energym/utils/common/config.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../app_config.dart';

class DeviceConnection extends StatefulWidget {
  static const String routeName = '/DeviceConnection';
  const DeviceConnection({Key? key}) : super(key: key);

  @override
  _DeviceConnectionState createState() => _DeviceConnectionState();
}

class _DeviceConnectionState extends State<DeviceConnection>
    with SingleTickerProviderStateMixin {
  List<Widget> tabs = <Widget>[];
  ValueNotifier<int> dotSubject = ValueNotifier<int>(0);
  final PageController _pageController = PageController();
  AppConfig? _config;

  @override
  void initState() {
    tabs.add(
      DeviceConnectionInfo(
          image: ImgConstants.deviceConnectionIntro1,
          title: AppConstants.deviceConnectionIntro1Title,
          message: AppConstants.deviceConnectionIntro1Msg,
          showDone: false,
          showSkip: false),
    );
    tabs.add(
      DeviceConnectionInfo(
          image: ImgConstants.deviceConnectionIntro2,
          title: AppConstants.deviceConnectionIntro3Title,
          message: AppConstants.deviceConnectionIntro2Msg,
          showSkip: false,
          showDone: false),
    );
    tabs.add(
      DeviceConnectionInfo(
          image: ImgConstants.deviceConnectionIntro3,
          title: AppConstants.deviceConnectionIntro3Title,
          message: AppConstants.deviceConnectionIntro3Msg,
          showDone: true,
          showSkip: false),
    );
    super.initState();
  }

  @override
  void dispose() {
    dotSubject.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    _config = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.zero,
          width: double.infinity,
          height: double.infinity,
          child: mainContainerView(),
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
      title: AppConstants.setupMyREGEN,
      titleStyle:
          _config!.paragraphNormalFontStyle.apply(color: _config!.greyColor),
      elevation: 0,
      isBackEnable: false,
      centerTitle: true,
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

  Widget mainContainerView() {
    return ValueListenableBuilder<int>(
      valueListenable: dotSubject,
      builder: (BuildContext? context, int? index, Widget? child) {
        return Column(
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
                    controller: _pageController,
                    onPageChanged: (int page) {
                      dotSubject.value = page;
                    },
                    children: tabs,
                  ),
                ),
              ),
            ),
            dotIndicator(index!),
            const SizedBox(
              height: 32,
            ),
            _btnDone(_config!, index),
            _widgetNeedHelp(),
          ],
        );
      },
    );
  }

  Widget _btnDone(AppConfig config, int index) {
    return LoaderButton(
        backgroundColor: config.btnPrimaryColor,
        padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
        onPressed: () async {
          if (index != (tabs.length - 1)) {
            final int nextIndex = index + 1;
            _pageController.animateToPage(
              nextIndex,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          } else {
            final BottomNavigationBar navigationBar =
                globalKeyBottomBard.currentWidget as BottomNavigationBar;
            navigationBar.onTap!(2);
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
        title: getBtnTitle(index));
  }

  String getBtnTitle(int index) {
    String title = AppConstants.getStarted;
    switch (index) {
      case 0:
        title = AppConstants.getStarted;
        break;
      case 1:
        title = AppConstants.next;
        break;
      case 2:
        title = AppConstants.goToMyWorkout;
        break;
      default:
        title = AppConstants.getStarted;
        break;
    }

    return title;
  }

  Widget dotIndicator(int currentIndex) {
    return Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          dotWidget(0, currentIndex),
          const SizedBox(width: 10),
          dotWidget(1, currentIndex),
          const SizedBox(width: 10),
          dotWidget(2, currentIndex),
        ],
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

  Widget _widgetNeedHelp() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 8),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: AppConstants.needHelp,
          style: _config!.linkNormalFontStyle.apply(
            color: _config!.whiteColor,
          ),
          children: <TextSpan>[
            TextSpan(
              text: AppConstants.clickHere,
              style: _config!.linkNormalFontStyle.apply(
                color: _config!.btnPrimaryColor,
              ),
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
          ],
        ),
      ),
    );
  }
}
