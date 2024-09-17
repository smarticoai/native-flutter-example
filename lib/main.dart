import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/managers/deep-links/constants.dart';
import 'package:flutter_application_1/managers/deep-links/deep_links.manager.dart';
import 'package:flutter_application_1/managers/persistant-storage/constants.dart';
import 'package:flutter_application_1/managers/persistant-storage/persistant-storage.manager.dart';
import 'package:flutter_application_1/managers/web-socket/constants.dart';
import 'package:flutter_application_1/managers/web-socket/dto.dart';
import 'package:flutter_application_1/managers/web-socket/handlers.dart';
import 'package:flutter_application_1/managers/web-socket/web-socket.manager.dart';
import 'package:flutter_application_1/router/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final PersistantStorage persistantStorage = PersistantStorage();
final DeepLinksManager deepLinkManager = DeepLinksManager();
final WebSocketManager webSocketManager = WebSocketManager();

final customRouterDelegate = CustomRouterDelegate();

late String? popupUrl;
late String? gfUrl;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await persistantStorage.initInstance();

  webSocketManager.registerSubscriber(
      ServerCall.identifyUserResponse, handleIdentifyUserRes);
  webSocketManager.registerSubscriber(ServerCall.ping, handlePing);
  webSocketManager.registerSubscriber(
      ServerCall.clientEngagementEvent, handleClientEngagementEvent);
  webSocketManager.registerSubscriber(ServerCall.sawEvent, handleSAWEvent);

  deepLinkManager.registerSubscriber(DeepLinksKeys.saw, handleGfDeepLink);
  deepLinkManager.registerSubscriber(DeepLinksKeys.gf, handleGfDeepLink);

  runApp(const MyApp());

  bool? isLoggedIn =
      persistantStorage.getBool(PersistantStorageKeys.isLoggedIn.value);

  if (isLoggedIn == true) {
    initConnection();
  }
}

void handleGfDeepLink(String deepLink) {
  customRouterDelegate.openGf(deepLink);
}

void handleDeepLink(String deepLinkJson) {
  deepLinkManager.handleDeepLink(deepLinkJson);
}

Future<void> initConnection() async {
  String? resUsername =
      persistantStorage.getString(PersistantStorageKeys.username.value);

  String webSocketUrl =
      WebSocketUrl.getWebSocketUrl(int.parse(dotenv.env['ENV'] ?? "6"));

  await webSocketManager.initConnection(webSocketUrl);

  try {
    final String payload =
        await HandshakePayload(sessionId: webSocketManager.sessionId).toJson();

    webSocketManager.send(payload);
  } catch (e) {
    log("Failed to send handshake: $e");
  }

  final String payload =
      IdentifyUserPayload(userExtId: resUsername ?? "testuser").toJson();

  webSocketManager.send(payload);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: customRouterDelegate,
    );
  }
}
