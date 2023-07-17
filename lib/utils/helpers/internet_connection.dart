import 'dart:async';
import 'dart:developer';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ConnectionStatus {
  online,
  recentlyBackOnline,
  offline,
}

class InternetConnection with ChangeNotifier {
  ConnectionStatus? status = ConnectionStatus.online;
  Timer? backOnlineTimer;
  StreamSubscription<ConnectivityResult>? connectivitySub;

  static InternetConnection of(BuildContext context) {
    return Provider.of<InternetConnection>(context);
  }

  InternetConnection() {
    Connectivity().checkConnectivity().then((result) {
      status = result == ConnectivityResult.none
        ? ConnectionStatus.offline
        : ConnectionStatus.online;
        notifyListeners();
    });

    
    connectivitySub =
        Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    print("Connectivity change to: " + result.toString());

    if (result == ConnectivityResult.none) {
      if (backOnlineTimer != null) {
        backOnlineTimer!.cancel();
      }
      status = ConnectionStatus.offline;
      notifyListeners();
    } else if (status != ConnectionStatus.online) {
      // not already online
      status = ConnectionStatus.recentlyBackOnline;
      backOnlineTimer = Timer(
        Duration(seconds: 2),
        () {
          if (status == ConnectionStatus.recentlyBackOnline) {
            status = ConnectionStatus.online;
            notifyListeners();
          }
        },
      );
      notifyListeners();
    }
  }

  bool get isOnline => !isOffline;

  bool get isOffline => status == ConnectionStatus.offline;

  @override
  void dispose() {
    log("dispose InternetConnection");
    if (backOnlineTimer != null) {
      backOnlineTimer!.cancel();
    }
    connectivitySub!.cancel();
    super.dispose();
  }
}
