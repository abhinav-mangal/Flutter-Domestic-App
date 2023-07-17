import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class StaggerAnimation extends StatelessWidget {
  StaggerAnimation({Key? key, this.buttonController})
      : buttonZoomOutAnimation = Tween(
          begin: 60.0,
          end: 1000.0,
        ).animate(
          CurvedAnimation(parent: buttonController!, curve: Curves.easeOut),
        ),
        buttonBottomtoCenterAnimation = AlignmentTween(
          begin: Alignment.bottomRight,
          end: Alignment.center,
        ).animate(
          CurvedAnimation(
            parent: buttonController,
            curve: Interval(
              0.0,
              0.200,
              curve: Curves.easeOut,
            ),
          ),
        ),
        super(key: key);

  final Animation<double>? buttonController;
  final Animation? buttonZoomOutAnimation;
  final Animation<Alignment>? buttonBottomtoCenterAnimation;

  Widget _buildAnimation(BuildContext? context, Widget? child) {
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: buttonController!,
    );
  }
}
