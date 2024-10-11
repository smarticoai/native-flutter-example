import 'dart:convert';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

@pragma('vm:entry-point')
onDidReceiveBackgroundNotificationResponse(
    NotificationResponse notificationResponse) async {
  if (notificationResponse.notificationResponseType ==
          NotificationResponseType.selectedNotification &&
      notificationResponse.payload != null) {
    if (notificationResponse.payload != null) {
      deepLinkManager.handleDeepLink(notificationResponse.payload!);
    }
  }

  Map<String, dynamic> jsonObject = jsonDecode(notificationResponse.payload!);

  jsonObject['event_type'] = 'engagement_action';

  String updatedJsonString = jsonEncode(jsonObject);

  final url = Uri.parse(
      'https://papi${dotenv.env['ENV']}.smartico.ai/services/public?api_key=${dotenv.env['PUBLIC_LABEL_API_KEY']}&brand_key=${dotenv.env['BRAND_KEY']}&version=${dotenv.env['TRACKER_VERSION']}&event=$updatedJsonString');

  await http.get(url);
}

class NotificationManager {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('app_icon');

  static getNotificationAppLaunchDetails() async {
    return flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  }

  static initNotification() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
      onDidReceiveNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );
  }

  static showLocalNotification(
      String title, String body, String payload) async {
    final url = Uri.parse(
        'https://papi${dotenv.env['ENV']}.smartico.ai/services/public?api_key=${dotenv.env['PUBLIC_LABEL_API_KEY']}&brand_key=${dotenv.env['BRAND_KEY']}&version=${dotenv.env['TRACKER_VERSION']}&event=$payload');

    await http.get(url);

    const androidNotificationDetail = AndroidNotificationDetails(
      '0',
      'general',
      priority: Priority.high,
      autoCancel: false,
      fullScreenIntent: true,
      enableVibration: true,
      importance: Importance.high,
      playSound: true,
    );

    const iosNotificatonDetail = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      iOS: iosNotificatonDetail,
      android: androidNotificationDetail,
    );

    flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
