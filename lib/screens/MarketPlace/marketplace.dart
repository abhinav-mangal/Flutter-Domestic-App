import 'dart:io';

import 'package:energym/app_config.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:energym/models/user_model.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

class MarketPlace extends StatefulWidget {
  const MarketPlace({Key? key}) : super(key: key);

  @override
  _MarketPlaceState createState() => _MarketPlaceState();
}

class _MarketPlaceState extends State<MarketPlace> {
  AppConfig? _config;
  UserModel? _currentUser;
  ValueNotifier<bool> _loadingNotifyer = ValueNotifier<bool>(true);
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldInterceptFetchRequest: true,
      //userAgent: 'energym/1',
      applicationNameForUserAgent: 'energym/100',
      transparentBackground: true,
      disableHorizontalScroll: true,
      userAgent: 'energym/100',
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
  );

  @override
  void initState() {
    super.initState();
    _currentUser = aGeneralBloc.currentUser;

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      body: Stack(
        children: [
          Container(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: Uri.parse("https://platform.sweatco.in/webview/"),
                headers: {
                  'Authentication-Token': _currentUser!.sweatcoinId!,
                },
              ),
              initialOptions: options,
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                _loadingNotifyer.value = true;
              },
              onLoadStop: (controller, url) {
                _loadingNotifyer.value = false;
              },
              onConsoleMessage: (controller, consoleMessage) {
                print('onConsoleMessage >> $consoleMessage');
              },
              onLoadError: (controller, url, code, message) {
                print('onLoadError >> $message');
              },
              onLoadHttpError: (controller, url, code, message) {
                print('onLoadHttpError >> $message');
              },
              
            ),
          ),
          _loader(),
        ],
      ),
    );
  }

  Widget _loader() {
    return ValueListenableBuilder(
      valueListenable: _loadingNotifyer,
      builder: (BuildContext? context, bool? isLoading, Widget? child) {
        if (isLoading!) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: _config!.borderColor.withOpacity(0.10),
            child: Center(
              //child: Lottie.asset(LottieConstants.loader,),
              child: SpinKitCircle(
                color: _config!.btnPrimaryColor,
                size: 30,
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
