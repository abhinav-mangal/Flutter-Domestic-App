import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/loader_button.dart';
import 'package:energym/screens/AnimationCounter/animation_counter.dart';
import 'package:energym/screens/bluetoothConnectivity/bluetoothConnectivity.dart';
import 'package:energym/screens/workout/green_zone/livecalibrationworkout.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

// This is green zone screen and this contains current FTP and 5 and 20 mins workout
// User can start calibration workout to get updated FTP value
class GreenZone extends StatefulWidget {
  const GreenZone({Key? key}) : super(key: key);
  static const String routeName = '/GreenZone';

  @override
  _GreenZoneState createState() => _GreenZoneState();
}

class _GreenZoneState extends State<GreenZone> {
  AppConfig? _config;
  UserModel? _currentUser;
  ValueNotifier<bool> _notifier5mins = ValueNotifier<bool>(false);
  ValueNotifier<bool> _notifier20mins = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _currentUser = aGeneralBloc.currentUser;
    globalMins = 0;
  }

  @override
  void dispose() {
    super.dispose();
    _notifier20mins.dispose();
    _notifier5mins.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            _topText(),
            _topTextFTP(),
            _currentFTP(),
            _fTPValue(),
            _testMins(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _btnStartCalibration(),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _config,
        backgoundColor: Colors.transparent,
        elevation: 0,
        // isBackEnable: true,
        isBackEnable: false,
        onBack: () {},
        leadingWidget: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 24,
            color: _config!.btnPrimaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        // textColor: _config!.btnPrimaryColor,
        widget: btnPairing(context, (isConnectedDevice) {
          if (isConnectedDevice) {
            // pop up
            // bottomSheet(context);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlueToothConnectivityVC(),
              ),
            );
          }
        }),
        actions: <Widget>[
          btnSweatCointBalance(context, _config!),
        ]);
  }

  Widget _topText() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5),
      child: Text(
        AppConstants.greenZone.toUpperCase(),
        style:
            _config!.antonio36FontStyle.apply(color: _config!.btnPrimaryColor),
      ),
    );
  }

  Widget _topTextFTP() {
    return Text(
      '[${AppConstants.hintFTP}]',
      style: _config!.antonio36FontStyle
          .apply(color: _config!.btnPrimaryColor, fontSizeFactor: 0.5),
    );
  }

  Widget _currentFTP() {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Text(
        AppConstants.currentFTP,
        style:
            _config!.antonioHeading2FontStyle.apply(color: _config!.whiteColor),
      ),
    );
  }

  Widget _fTPValue() {
    return Text(
      "${_currentUser?.ftpValue}",
      style: _config!.antonioHeading1FontStyle
          .apply(color: _config!.btnPrimaryColor),
    );
  }

  Widget _testMins() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ValueListenableBuilder<bool>(
              valueListenable: _notifier5mins,
              builder: (BuildContext? context, status, child) {
                return minsWidget(5, 0, status, () {
                  // push to timer controller
                  globalMins = 5;
                  _notifier5mins.value = true;
                  _notifier20mins.value = false;
                });
              }),
          SizedBox(
            width: 20,
          ),
          ValueListenableBuilder<bool>(
              valueListenable: _notifier20mins,
              builder: (BuildContext? context, status, child) {
                return minsWidget(20, 1, status, () {
                  // push to timer controller
                  globalMins = 20;
                  _notifier20mins.value = true;
                  _notifier5mins.value = false;
                });
              }),
        ],
      ),
    );
  }

  Widget minsWidget(int mins, int index, bool isSelected, Function? onPress) {
    return GestureDetector(
      onTap: () {
        onPress!();
      },
      child: Container(
        height: 85,
        width: 85,
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: _config!.btnPrimaryColor),
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
            color: isSelected ? _config?.btnPrimaryColor : Colors.transparent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${mins}',
              style: _config!.antonioHeading2FontStyle
                  .apply(color: _config!.whiteColor),
            ),
            Text(
              'Min',
              style: _config!.antonioHeading2FontStyle
                  .apply(color: _config!.whiteColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btnStartCalibration() {
    return Container(
      padding: EdgeInsets.only(bottom: 50, left: 30, right: 30),
      // color: Colors.red,
      width: double.infinity,
      height: 110,
      child: LoaderButton(
        isOutLine: true,
        outLineColor: _config!.btnPrimaryColor,
        radius: 15,
        onPressed: () {
          if (globalMins == 0) {
            CustomAlertDialog().showAlert(
                context: context,
                message: MsgConstants.testmin,
                title: AppConstants.appName);
          } else {
            Navigator.popAndPushNamed(
              context,
              AnimationCounter.routeName,
              arguments: AnimationCounterArgs(
                  isLiveCalibration: true,
                  mins: globalMins,
                  isBuildworkout: false),
            );
          }
        },
        title: AppConstants.startCalibration.toUpperCase(),
        titleStyle: _config!.antonio48FontStyle
            .apply(color: _config!.btnPrimaryColor, fontSizeFactor: 0.5),
      ),
    );
  }
}
