import 'package:flutter/material.dart';

class SlideAnimation extends StatelessWidget {
  const SlideAnimation({
    Key? key,
    this.child,
    this.begin = const Offset(250, 0),
    this.end = const Offset(0, 0),
    this.intervalStart = 0,
    this.intervalEnd = 1,
    this.duration = const Duration(milliseconds: 2000),
    this.curve = Curves.fastOutSlowIn,
  }) : super(key: key);
  final Offset? begin;
  final Offset? end;
  final double? intervalStart;
  final double? intervalEnd;
  final Duration? duration;
  final Curve? curve;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: begin, end: end),
      duration: duration!,
      curve: Interval(intervalStart!, intervalEnd!, curve: curve!),
      child: child,
      builder: (BuildContext context, Offset value, Widget? child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
    );
  }
}
