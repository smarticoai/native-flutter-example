import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home.screen.dart';

enum Routes {
  home('home'),
  popup('popup'),
  saw('saw'),
  gf('gf');

  final String route;

  String getRoute() {
    return route;
  }

  const Routes(this.route);
}

List<Page> initialPagesState = [
  MaterialPage(
    key: const ValueKey('HomePage'),
    child: Home(
      key: const Key("home"),
      openPopup: (
        String popupUrl,
        dynamic eventPayload,
        void Function(String deepLinkJson) handleDeepLink,
      ) {},
      openSaw: (int templateId, int pendingMessageId, String url) {},
      resetNavigator: () {},
      openGf: (String url) => {},
    ),
  )
];
