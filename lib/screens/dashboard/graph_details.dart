import 'package:energym/app_config.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/helpers/routing/router.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// It contains big size circle graph
class GraphDetailsArgs extends RoutesArgs {
  GraphDetailsArgs(
      {this.workoutType,
      this.healthkitValue,
      this.ourAppValue,
      this.sumValue,
      this.targetedValue})
      : super(isHeroTransition: true);

  final WorkoutType? workoutType;
  final double? healthkitValue;
  final int? ourAppValue;
  final double? sumValue;
  final double? targetedValue;
}

class GraphDetails extends StatefulWidget {
  const GraphDetails(
      {Key? key,
      this.workoutType,
      this.healthkitValue,
      this.ourAppValue,
      this.sumValue,
      this.targetedValue})
      : super(key: key);
  static const String routeName = '/GraphDetails';
  final WorkoutType? workoutType;
  final double? healthkitValue;
  final int? ourAppValue;
  final double? sumValue;
  final double? targetedValue;
  @override
  _GraphDetailsState createState() => _GraphDetailsState();
}

class _GraphDetailsState extends State<GraphDetails> {
  AppConfig? _config;
  WorkoutType? _workoutType;
  double? _healthkitValue;
  int? _ourAppValue;
  double? _sumValue;
  double? _targetedValue;
  @override
  void initState() {
    super.initState();
    _workoutType = widget.workoutType;
    _healthkitValue = widget.healthkitValue;
    _ourAppValue = widget.ourAppValue;
    _sumValue = widget.sumValue;
    _targetedValue = widget.targetedValue;
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: _widgetMainContainer(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _widgetBackToDashboard(),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(
      context, _config!,
      backgoundColor: Colors.transparent,
      textColor: _config!.whiteColor,
      //title: AppConstants.workoutSummary,
      elevation: 0,
      isBackEnable: false,
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

  Widget _widgetMainContainer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_workoutType == WorkoutType.activityMinutes)
            _widgetActiveMinutes(),
          if (_workoutType == WorkoutType.energyGenerated)
            _widgetEnergyGenerate(),
          if (_workoutType == WorkoutType.caloriesBurend) _widgetCaloriesBurn(),
          _widgetValueColorInfo()
        ],
      ),
    );
  }

  Widget _widgetValueColorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _widgetGraphSelectedValue(),
        if (_workoutType != WorkoutType.energyGenerated)
          _widgetGraphPreviousValue(),
        if (_workoutType != WorkoutType.energyGenerated)
          _widgetGraphDefaultValue()
      ],
    );
  }

  Widget _widgetActiveMinutes() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _widgetActivityProgress(),
        const SizedBox(
          height: 32,
        ),
        AutoSizeText(
          AppConstants.activeMinutes,
          maxLines: 2,
          style: _config!.paragraphLargeFontStyle
              .apply(color: _config!.whiteColor, fontSizeDelta: 4),
        )
      ],
    );
  }

  Widget _widgetActivityProgress() {
    return Container(
      padding: EdgeInsets.zero,
      width: 230,
      height: 230,
      child: Hero(
        tag: WorkoutType.activityMinutes,
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              maximum: _targetedValue ?? 0,
              showLabels: false,
              showTicks: false,
              startAngle: 270,
              endAngle: 270,
              axisLineStyle: AxisLineStyle(
                thickness: 0.20,
                //cornerStyle: CornerStyle.bothCurve,
                color: _config!.darkGreyColor,
                thicknessUnit: GaugeSizeUnit.factor,
              ),
              pointers: <GaugePointer>[
                RangePointer(
                  value: _targetedValue ?? 0,
                  width: 0.20,
                  sizeUnit: GaugeSizeUnit.factor,
                  color: Colors.transparent,
                  cornerStyle: CornerStyle.bothCurve,
                  enableAnimation: true,
                ),
                RangePointer(
                  value: _sumValue ?? 0,
                  width: 0.20,
                  sizeUnit: GaugeSizeUnit.factor,
                  color: _config!.skyBlueColor,
                  cornerStyle: CornerStyle.bothCurve,
                  enableAnimation: true,
                )
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                    positionFactor: 0.0,
                    angle: 90,
                    widget: Text(
                      (_sumValue ?? 0).toStringAsFixed(2).toString(),
                      style: _config!.antonio60FontStyle.apply(
                          color: _config!.whiteColor,
                          decoration: TextDecoration.none),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _widgetEnergyGenerate() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _widgetEnergyGenerateProgress(),
        const SizedBox(
          height: 32,
        ),
        AutoSizeText(
          AppConstants.energyGenerated,
          maxLines: 2,
          style: _config!.paragraphLargeFontStyle
              .apply(color: _config!.whiteColor, fontSizeDelta: 4),
        )
      ],
    );
  }

  Widget _widgetEnergyGenerateProgress() {
    return Container(
      padding: EdgeInsets.zero,
      width: 230,
      height: 230,
      child: Hero(
        tag: WorkoutType.energyGenerated,
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              maximum: _targetedValue ?? 0,
              showLabels: false,
              showTicks: false,
              startAngle: 270,
              endAngle: 270,
              axisLineStyle: AxisLineStyle(
                thickness: 1,
                //cornerStyle: CornerStyle.bothCurve,
                color: _config!.btnPrimaryColor,
                thicknessUnit: GaugeSizeUnit.factor,
              ),
              pointers: <GaugePointer>[
                RangePointer(
                  value: (_ourAppValue ?? 0).toDouble(),
                  width: 0.20,
                  sizeUnit: GaugeSizeUnit.factor,
                  color: Colors.transparent,
                  cornerStyle: CornerStyle.bothCurve,
                  enableAnimation: true,
                ),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                    positionFactor: 0.5,
                    angle: 90,
                    widget: Text(
                      (_sumValue ?? 0).toInt().toString(),
                      style: _config!.antonio60FontStyle.apply(
                          color: _config!.blackColor,
                          decoration: TextDecoration.none),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _widgetCaloriesBurn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _widgetCaloriesBurnProgress(),
        const SizedBox(
          height: 32,
        ),
        AutoSizeText(
          AppConstants.caloriesBurned,
          maxLines: 2,
          style: _config!.paragraphLargeFontStyle
              .apply(color: _config!.whiteColor, fontSizeDelta: 4),
        )
      ],
    );
  }

  Widget _widgetCaloriesBurnProgress() {
    return Container(
      padding: EdgeInsets.zero,
      width: 230,
      height: 230,
      child: Hero(
        tag: WorkoutType.caloriesBurend,
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              showLabels: false,
              showTicks: false,
              startAngle: 270,
              endAngle: 270,
              maximum: _targetedValue ?? 0,
              axisLineStyle: AxisLineStyle(
                thickness: 0.20,
                //cornerStyle: CornerStyle.bothCurve,
                color: _config!.darkGreyColor,
                thicknessUnit: GaugeSizeUnit.factor,
              ),
              pointers: <GaugePointer>[
                RangePointer(
                  value: _targetedValue ?? 0,
                  width: 0.20,
                  sizeUnit: GaugeSizeUnit.factor,
                  color: Colors.transparent,
                  cornerStyle: CornerStyle.bothCurve,
                  enableAnimation: true,
                ),
                RangePointer(
                  value: _healthkitValue ?? 0,
                  width: 0.20,
                  sizeUnit: GaugeSizeUnit.factor,
                  color: _config!.orangeColor,
                  cornerStyle: CornerStyle.bothCurve,
                  enableAnimation: true,
                )
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                    positionFactor: 0.0,
                    angle: 90,
                    widget: Text(
                      '${(_sumValue ?? 0).toInt().toString()} / ${(_targetedValue ?? 0).toInt()}',
                      style: _config!.antonio60FontStyle.apply(
                          color: _config!.whiteColor,
                          fontSizeFactor: 0.5,
                          decoration: TextDecoration.none),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _widgetBackToDashboard() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        child: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            overlayColor:
                MaterialStateColor.resolveWith((states) => Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SvgIcon.asset(
                ImgConstants.backArrowSmall,
                size: 20,
                color: _config!.btnPrimaryColor,
              ),
              const SizedBox(
                width: 11,
              ),
              Text(
                AppConstants.backToDashboard,
                style: _config!.linkSmallFontStyle.apply(
                  color: _config!.btnPrimaryColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _widgetGraphSelectedValue() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: _getWorkoutValueColor()),
          ),
          const SizedBox(
            width: 12,
          ),
          Text(
            'Conubia consectetur imperdiet',
            style: _config!.paragraphSmallFontStyle.apply(
              color: _config!.greyColor,
            ),
          )
        ],
      ),
    );
  }

  Widget _widgetGraphPreviousValue() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: _config!.greyColor),
          ),
          const SizedBox(
            width: 12,
          ),
          Text(
            'Nam sem suspendisse',
            style: _config!.paragraphSmallFontStyle.apply(
              color: _config!.greyColor,
            ),
          )
        ],
      ),
    );
  }

  Widget _widgetGraphDefaultValue() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: _config!.borderColor),
          ),
          const SizedBox(
            width: 12,
          ),
          Text(
            'Nostra vestibulum iaculis augue',
            style: _config!.paragraphSmallFontStyle.apply(
              color: _config!.greyColor,
            ),
          )
        ],
      ),
    );
  }

  Color _getWorkoutValueColor() {
    switch (_workoutType) {
      case WorkoutType.activityMinutes:
        return _config!.skyBlueColor;
      case WorkoutType.energyGenerated:
        return _config!.greyColor;
      case WorkoutType.caloriesBurend:
        return _config!.orangeColor;
      default:
        return _config!.skyBlueColor;
    }
  }
}
