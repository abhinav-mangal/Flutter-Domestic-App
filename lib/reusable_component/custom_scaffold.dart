import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../app_config.dart';
import '../utils/common/base_bloc.dart';
import 'connection_status.dart';

class CustomScaffold extends StatelessWidget {
  final bool? extendBody;
  final bool? extendBodyBehindAppBar;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? drawerScrimColor;
  final Color? statusBarColor;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool? resizeToAvoidBottomInset;
  final bool? primary;
  final DragStartBehavior? drawerDragStartBehavior;
  final double? drawerEdgeDragWidth;
  final bool? drawerEnableOpenDragGesture;
  final bool? endDrawerEnableOpenDragGesture;

  /// Creates a visual scaffold for material design widgets.
  const CustomScaffold(
      {Key? key,
      this.appBar,
      this.body,
      this.floatingActionButton,
      this.floatingActionButtonLocation,
      this.floatingActionButtonAnimator,
      this.persistentFooterButtons,
      this.drawer,
      this.endDrawer,
      this.bottomNavigationBar,
      this.bottomSheet,
      this.backgroundColor,
      this.resizeToAvoidBottomInset,
      this.primary = true,
      this.drawerDragStartBehavior = DragStartBehavior.start,
      this.extendBody = false,
      this.extendBodyBehindAppBar = false,
      this.drawerScrimColor,
      this.drawerEdgeDragWidth,
      this.drawerEnableOpenDragGesture = true,
      this.endDrawerEnableOpenDragGesture = true,
      this.statusBarColor,
      List<Widget>? slivers})
      : assert(primary != null),
        assert(extendBody != null),
        assert(extendBodyBehindAppBar != null),
        assert(drawerDragStartBehavior != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.of(context);

    return Scaffold(
      backgroundColor: backgroundColor ?? config.windowBackground,
      //body: containerWidget(body),
      body: AnnotatedRegion(
          value: config.systemUiOverlayStyle, child: containerWidget(body!)),
      //proxy other properties
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary!,
      drawerDragStartBehavior: drawerDragStartBehavior!,
      extendBody: extendBody ?? true,
      extendBodyBehindAppBar: extendBodyBehindAppBar!,
      drawerScrimColor: drawerScrimColor,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
//        drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
//        endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
    );
  }

  Widget containerWidget(Widget body) {
    // return ConnectionStatusPage(
    //     child: body,
    //   );
    return StreamBuilder<bool>(
        stream: aGeneralBloc.getIsApiCalling,
        builder: (context, snapshot) {
          bool isApiCalling = false;
          if (snapshot.hasData && snapshot.data != null) {
            isApiCalling = snapshot.data!;
          }
          return AbsorbPointer(
            absorbing: isApiCalling,
            child: ConnectionStatusPage(
              child: body,
            ),
          );
        });
  }
}
