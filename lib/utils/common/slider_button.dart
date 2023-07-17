import 'dart:async';

import 'package:energym/screens/workout/complete_workout.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

class SliderButton extends StatefulWidget {
  ///To make button more customizable add your child widget
  final Widget? child;

  ///Sets the radius of corners of a button.
  final double? radius;

  ///Use it to define a height and width of widget.
  final double? height;
  final double? width;
  final double? buttonSize;

  ///Use it to define a color of widget.
  final Color backgroundColor;
  final Color baseColor;
  final Color highlightedColor;
  final Color buttonColor;

  ///Change it to gave a label on a widget of your choice.
  final Text? label;

  ///Gives a alignment to a slider icon.
  final Alignment alignLabel;
  final BoxShadow? boxShadow;
  final Widget? icon;
  final Function action;

  ///Make it false if you want to deactivate the shimmer effect.
  final bool? shimmer;

  ///Make it false if you want maintain the widget in the tree.
  final bool dismissible;

  final bool? vibrationFlag;

  ///The offset threshold the item has to be dragged in order to be considered
  ///dismissed e.g. if it is 0.4, then the item has to be dragged
  /// at least 40% towards one direction to be considered dismissed
  final double dismissThresholds;

  final bool disable;
  SliderButton({
    required this.action,
    this.radius,
    this.boxShadow,
    this.child,
    this.vibrationFlag,
    this.shimmer,
    this.height,
    this.buttonSize,
    this.width,
    this.alignLabel = const Alignment(0.3, 0),
    this.backgroundColor = const Color(0xffe0e0e0),
    this.baseColor = Colors.black87,
    this.buttonColor = Colors.white,
    this.highlightedColor = Colors.white,
    this.label,
    this.icon,
    this.dismissible = true,
    this.dismissThresholds = 0,
    this.disable = false,
  }) : assert((buttonSize ?? 60) <= (height ?? 70));

  @override
  _SliderButtonState createState() => _SliderButtonState();
}

class _SliderButtonState extends State<SliderButton>
    with TickerProviderStateMixin {
  bool? flag;

  double opacity = 1.0;
  StreamController<double> controller = StreamController<double>();
  Stream<double>? stream;

  double? startPosition;
  AnimationController? _loadingController;
  Animation? buttomZoomOut;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this);

    buttomZoomOut = Tween(
      begin: 70.0,
      end: 1000.0,
    ).animate(
      CurvedAnimation(
        parent: _loadingController!,
        curve: const Interval(
          0.550,
          0.999,
          curve: Curves.bounceOut,
        ),
      ),
    );
    stream = controller.stream;
    flag = true;
  }

  @override
  void dispose() {
    _loadingController?.dispose();
    controller.close();
    super.dispose();
  }

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return flag == true
        ? _control()
        : widget.dismissible == true
            ? _animationButton()
            : Container(
                child: _control(),
              );
  }

  @override
  Widget build(BuildContext context) {
    _loadingController?.addListener(() {
      if (_loadingController!.isCompleted) {}
    });
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: _loadingController!,
    );
  }

  Widget _animationButton() {
    print('_animationButton >>>>>>');
    return Container(
      height: buttomZoomOut?.value as double,
      width: buttomZoomOut?.value as double,
      decoration: BoxDecoration(
        shape: (buttomZoomOut?.value as double < 500)
            ? BoxShape.circle
            : BoxShape.rectangle,
        color: Colors.green,
      ),
      child: Center(
        child: Lottie.asset(LottieConstants.workoutComplete),
      ),
    );
  }

  Widget _control() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
      child: Container(
        height: widget.height ?? 70,
        width: widget.width ?? 250,
        decoration: BoxDecoration(
            color:
                widget.disable ? Colors.grey.shade700 : widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.radius ?? 100)),
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            StreamBuilder<double>(
                stream: stream,
                initialData: 1.0,
                builder: (context, snapshot) {
                  return Opacity(
                    opacity: snapshot.data!,
                    child: Container(
                      alignment: widget.alignLabel,
                      child: widget.shimmer ?? true && !widget.disable
                          ? Shimmer.fromColors(
                              baseColor: widget.disable
                                  ? Colors.grey
                                  : widget.baseColor,
                              highlightColor: widget.highlightedColor,
                              child: widget.label!,
                            )
                          : widget.label,
                    ),
                  );
                }),
            // ignore: prefer_if_elements_to_conditional_expressions
            widget.disable
                ? Tooltip(
                    verticalOffset: 50,
                    message: 'Button is disabled',
                    child: Container(
                      width: (widget.width ?? 250) - (widget.height ?? 70),
                      height: widget.height ?? 80 - 70,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(
                        left: widget.height == null
                            ? (70 - (widget.buttonSize ?? 60)) / 2
                            : (widget.height ??
                                    0 -
                                        (widget.buttonSize ??
                                            widget.height ??
                                            0 * 0.9)) /
                                2,
                      ),
                      child: widget.child ??
                          Container(
                            height:
                                widget.buttonSize ?? widget.height ?? 70 * 0.9,
                            width:
                                widget.buttonSize ?? widget.height ?? 70 * 0.9,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  widget.boxShadow ?? BoxShadow(),
                                ],
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(
                                    widget.radius ?? 100)),
                            child: Center(child: widget.icon),
                          ),
                    ),
                  )
                : Dismissible(
                    key: Key("cancel"),
                    direction: DismissDirection.startToEnd,
                    dismissThresholds: {
                      DismissDirection.startToEnd: widget.dismissThresholds
                    },

                    ///gives direction of swipping in argument.
                    onDismissed: (dir) async {
                      print('_animationButton >>>>>>');
                      setState(() {
                        if (widget.dismissible) {
                          flag = false;
                        } else {
                          flag = !flag!;
                        }
                        print('_animationButton >>>>>>');
                      });

                      await widget.action();
                      _loadingController!.forward();
                    },
                    child: Listener(
                      onPointerDown: (event) {
                        startPosition = event.position.dx;
                        print('startPosition >>>> $startPosition');
                      },
                      onPointerUp: (event) {
                        opacity = 1.0;
                        controller.add(opacity);
                      },
                      onPointerMove: (details) {
                        if (details.position.dx > startPosition!) {
                          var move = details.position.dx + startPosition!;
                          move =
                              move / (MediaQuery.of(context).size.width - 32);

                          opacity = 1 - move;
                          if (opacity < 0) {
                            opacity = 0;
                          }
                          // print('opacity >>>> $opacity');
                          // print('move >>>> $move');

                          controller.add(opacity);
                        }
                      },
                      child: Container(
                        width: (widget.width ?? 250) - (widget.height ?? 70),
                        height: widget.height ?? 70,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(
                          left: widget.height == null
                              ? (70 - (widget.buttonSize ?? 60)) / 2
                              : (widget.height ??
                                      1 -
                                          (widget.buttonSize ??
                                              widget.height ??
                                              1 * 0.9)) /
                                  2,
                        ),
                        child: widget.child ??
                            Container(
                              height: widget.buttonSize ??
                                  widget.height ??
                                  70 * 0.9,
                              width: widget.buttonSize ??
                                  widget.height ??
                                  70 * 0.9,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    widget.boxShadow ?? BoxShadow(),
                                  ],
                                  color: widget.buttonColor,
                                  borderRadius: BorderRadius.circular(
                                      widget.radius ?? 100)),
                              child: Center(child: widget.icon),
                            ),
                      ),
                    ),
                  ),
            Container(
              child: SizedBox.expand(),
            ),
          ],
        ),
      ),
    );
  }
}
