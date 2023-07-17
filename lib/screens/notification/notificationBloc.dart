import 'package:energym/models/notification_model.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:rxdart/rxdart.dart';

class NotificationBloc {
  final BehaviorSubject<List<NotificationModel>> _notificationData = BehaviorSubject();
  ValueStream<List<NotificationModel>> get notificationData => _notificationData.stream;
  
  getNotificationData(String id) async {
    List<NotificationModel> data = await FireStoreProvider.instance.fetchUserNotification(id);
    _notificationData.sink.add(data);
  }
  
  updateNotificationData(
      String notificaiionId, Map<String, dynamic>? notificationData, ) {
    FireStoreProvider.instance.updateNotification(
        notificaiionId: notificaiionId,
        notificationData: notificationData,
        onSuccess: (success) {
          print(success);
        },
        onError: (error) {
          print(error);
        });
  }

  void dispose() {}
}
