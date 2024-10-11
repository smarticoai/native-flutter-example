import 'dart:convert';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/managers/notification/notification.manager.dart';
import 'package:flutter_application_1/managers/persistant-storage/constants.dart';
import 'package:flutter_application_1/managers/web-socket/dto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void handlePing(dynamic pingPayload) {
  final payload = PingPayload().toJson();

  webSocketManager.send(payload);
}

void handleClientEngagementEvent(dynamic handleClientEngagementEventPayload) {
  Map<String, dynamic> smarticoResponseMap =
      jsonDecode(handleClientEngagementEventPayload);

  ClientEngagementResponse res =
      ClientEngagementResponse.fromJson(smarticoResponseMap);

  if (res.activityType != 30) {
    return;
  }

  customRouterDelegate.openPopup(
      popupUrl!, handleClientEngagementEventPayload, handleDeepLink);
}

void _handleNotificationPayload(RemoteMessage message) async {
  String userExtId = message.data['user_ext_id'] ?? '';
  String engagementUid = message.data['engagement_uid'] ?? '';
  String messageId = message.data['message_id'] ?? '0';
  String activityType = message.data['activityType'] ?? '0';
  String action = message.data['action'] ?? '';

  String engagementImpressionPayload = PushImpressionPayload(
    userExtId: userExtId,
    engagementUid: engagementUid,
    messageId: int.parse(messageId),
    activityType: int.parse(activityType),
    action: action,
    dp: action,
  ).toJson();

  NotificationManager.showLocalNotification(
    message.notification?.title ?? 'Title',
    message.notification?.body ?? 'Body',
    engagementImpressionPayload,
  );
}

void handleIdentifyUserRes(dynamic identifyUserPayload) async {
  Map<String, dynamic> smarticoResponseMap = jsonDecode(identifyUserPayload);

  IdentifyUserResponse identifyUserResponse =
      IdentifyUserResponse.fromJson(smarticoResponseMap);

  deepLinkManager.init(identifyUserResponse.nativeAppGfUrl!);

  persistantStorage.setBool(PersistantStorageKeys.isLoggedIn.value, true);

  popupUrl = identifyUserResponse.nativeAppPopupUrl;
  gfUrl = identifyUserResponse.nativeAppGfUrl;

  FirebaseMessaging.instance.getToken().then((value) async {
    if (value == null) {
      return;
    }

    String payload =
        await RegisterPushNotificationTokenPayload(token: value).toJson();

    webSocketManager.send(payload);
  });

  var details = await NotificationManager.getNotificationAppLaunchDetails();

  if (details?.didNotificationLaunchApp ?? false) {
    deepLinkManager.handleDeepLink(details!.notificationResponse!.payload!);
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    _handleNotificationPayload(message);
  });

  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    String userExtId = initialMessage.data['user_ext_id'] ?? '';
    String engagementUid = initialMessage.data['engagement_uid'] ?? '';
    String messageId = initialMessage.data['message_id'] ?? '0';
    String activityType = initialMessage.data['activityType'] ?? '0';
    String action = initialMessage.data['action'] ?? '';

    String engagementImpressionPayload = PushImpressionPayload(
      userExtId: userExtId,
      engagementUid: engagementUid,
      messageId: int.parse(messageId),
      activityType: int.parse(activityType),
      action: action,
      dp: action,
    ).toJson();

    handleDeepLink(engagementImpressionPayload);
  }
}

void handleSAWEvent(dynamic sawEventPayload) {
  Map<String, dynamic> smarticoResponseMap = jsonDecode(sawEventPayload);

  SawTemplateResponse sawEvent =
      SawTemplateResponse.fromJson(smarticoResponseMap);

  if (gfUrl != null) {
    customRouterDelegate.openSaw(
      sawEvent.sawTemplateId,
      sawEvent.pendingMessageId,
      gfUrl!,
    );
  }
}
