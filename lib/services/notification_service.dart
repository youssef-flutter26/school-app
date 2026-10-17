import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Named parameter: settings
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  static Future<void> showPreArrivalNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'school_ride_pre_arrival',
      'Pre-Arrival Alerts',
      channelDescription: 'Notification when bus is 5 minutes away',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    // Named parameters for v17+
    await _notificationsPlugin.show(
      id: 0,
      title: 'Bus Arriving Soon 🚌',
      body: 'The bus is approximately 5 minutes away from your location.',
      notificationDetails: platformDetails,
    );
  }
}
