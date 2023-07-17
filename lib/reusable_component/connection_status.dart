import 'package:energym/utils/extensions/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../utils/common/constants.dart';
import '../utils/helpers/internet_connection.dart';
import '../utils/theme/colors.dart';

class ConnectionStatusMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final internetConnection = InternetConnection.of(context);
    final visible = internetConnection.status != ConnectionStatus.online;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _icon(context),
          _title(context),
          SizedBox(height: 4),
          _description(context, AppConstants.noInternetMsg),
        ],
      ),
    );
  }

  Widget _icon(BuildContext context) {
    //Widget icon = TenantImages.errorOffline;
    return Container(
      margin: EdgeInsets.fromLTRB(8, 16, 8, 20),
      // constraints: BoxConstraints(
      //   maxWidth: 280,
      //   maxHeight: 220,
      // ),
      //child: Lottie.asset(LottieConstants.offline, fit: BoxFit.cover),
    );
  }

  Widget _title(BuildContext context) {
    return Text(
      AppConstants.noInternetMsg,
      style: context.theme.textTheme.bodyText1!
          .apply(color: AppColors.textColorWhite),
      textAlign: TextAlign.center,
    );
  }

  Widget _description(BuildContext context, String message) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 300,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          message,
          style: context.theme.textTheme.bodyText2!
              .apply(color: AppColors.textColorGrey.withOpacity(0.50)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class ConnectionStatusPage extends StatelessWidget {
  final Widget? child;

  const ConnectionStatusPage({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final config = AppConfig.of(context);
    final internetConnection = InternetConnection.of(context);
    if (internetConnection.isOffline) {
      return ConnectionStatusMessage();
    } else {
      return child!;
    }
  }
}

// SystemUiOverlayStyle getSystemUiOverlayStyle({Brightness brightness, Color statusBarColor}) {
//   bool isDark = brightness == Brightness.dark;

//   SystemUiOverlayStyle style =
//       isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.light;

//   return style.copyWith(
//     statusBarColor: statusBarColor ?? Colors.transparent,
//     systemNavigationBarColor: Colors.transparent,
//     systemNavigationBarIconBrightness:
//         isDark ? Brightness.light : Brightness.dark,
//   );
// }
