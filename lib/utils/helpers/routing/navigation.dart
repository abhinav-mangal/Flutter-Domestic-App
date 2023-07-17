import 'package:flutter/material.dart';

Object? getRouteArgs(BuildContext context) {
  return ModalRoute.of(context)!.settings.arguments;
}

NavigatorState rootNavigator(BuildContext context) {
  return Navigator.of(context, rootNavigator: true);
}

/// Same as [showDialog], but allows you to change the transitions
///
/// See also:
///
///  * [showDialog], for the method this is based on
Future<T?> pushOnRootNavigator<T>({
  @required BuildContext? context,
  @required Route<T>? route,
}) {
  assert(context != null);
  assert(route != null);

  return rootNavigator(context!).push<T>(route!);
}

void showAppDialog({BuildContext? context, WidgetBuilder? builder}) {
  assert(debugCheckHasMaterialLocalizations(context!));

  pushOnRootNavigator(
    context: context,
    route: AppDialogRoute(
      builder: builder!,
      barrierLabel: MaterialLocalizations.of(context!).modalBarrierDismissLabel,
    ),
  );
}

// DialogRoute
class AppDialogRoute<T> extends PopupRoute<T> {
  AppDialogRoute({
    RouteSettings? settings,
    required WidgetBuilder? builder,
    bool barrierDismissible = true,
    String barrierLabel = 'Dismiss',
  })  : assert(barrierDismissible != null),
        // assert(debugCheckHasMaterialLocalizations(context)),
        _builder = builder!,
        _barrierDismissible = barrierDismissible,
        _barrierLabel = barrierLabel,
        // _barrierLabel =
        //    MaterialLocalizations.of(context).modalBarrierDismissLabel,
        super(settings: settings);

  final WidgetBuilder _builder;

  @override
  bool get barrierDismissible => _barrierDismissible;
  final bool _barrierDismissible;

  @override
  String get barrierLabel => _barrierLabel;
  String _barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    //old
    //final ThemeData theme = Theme.of(context, shadowThemeOnly: true);
    //new 2.0
    final ThemeData theme = Theme.of(context,);
    final Widget pageChild = Builder(builder: _builder);

    return Semantics(
      child: SafeArea(
        child: Builder(
          builder: (context) {
            return theme != null
                ? Theme(data: theme, child: pageChild)
                : pageChild;
          },
        ),
      ),
      scopesRoute: true,
      explicitChildNodes: true,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
