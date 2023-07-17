import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FabFillTransition extends StatelessWidget {
  const FabFillTransition({
    Key? key,
    required this.source,
    required this.child,
  })  : assert(source != null),
        assert(child != null),
        super(key: key);

  final Rect source;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = ModalRoute.of(context)!.animation!;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Animation<double> positionAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        );

        final Animation<RelativeRect> itemPosition = RelativeRectTween(
          begin: RelativeRect.fromLTRB(
              source.left,
              source.top,
              constraints.biggest.width - source.right,
              constraints.biggest.height - source.bottom),
          end: RelativeRect.fill,
        ).animate(positionAnimation);

        final BorderRadiusTween borderTween = BorderRadiusTween(
          begin: BorderRadius.circular(source.width / 2),
          end: BorderRadius.circular(0.0),
        );

        final Animation<double> fadeMaterialBackground = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.2, 1, curve: Curves.ease),
        );

        final Animation<double> scaleAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.9, curve: Curves.fastOutSlowIn),
        );

        final Tween<double> fabIconTween = Tween<double>(begin: 1.0, end: 3.0);

        return Stack(
          children: <Widget>[
            PositionedTransition(
              rect: itemPosition,
              child: AnimatedBuilder(
                animation: positionAnimation,
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  minWidth: constraints.maxWidth,
                  maxWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight,
                  maxHeight: constraints.maxHeight,
                  child: child,
                ),
                builder: (BuildContext? context, Widget? child) {
                  return ClipRRect(
                    borderRadius: borderTween.evaluate(positionAnimation),
                    child: Stack(
                      children: <Widget>[
                        FadeTransition(
                          opacity: fadeMaterialBackground,
                          child: ScaleTransition(
                              alignment: Alignment.topCenter,
                              scale: scaleAnimation,
                              child: child),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
