import 'dart:convert';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/managers/persistant-storage/constants.dart';
import 'package:flutter_application_1/managers/web-socket/dto.dart';

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

void handleIdentifyUserRes(dynamic identifyUserPayload) {
  Map<String, dynamic> smarticoResponseMap = jsonDecode(identifyUserPayload);

  IdentifyUserResponse identifyUserResponse =
      IdentifyUserResponse.fromJson(smarticoResponseMap);

  deepLinkManager.init(identifyUserResponse.nativeAppGfUrl!);

  persistantStorage.setBool(PersistantStorageKeys.isLoggedIn.value, true);

  popupUrl = identifyUserResponse.nativeAppPopupUrl;
  gfUrl = identifyUserResponse.nativeAppGfUrl;
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
