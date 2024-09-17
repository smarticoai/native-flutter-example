import 'dart:convert';

import 'package:flutter_application_1/managers/deep-links/constants.dart';

class DeepLinksManager {
  String? gfUrl;

  final Map<DeepLinksKeys, List<void Function(String deepLink)>> _subscribers;

  DeepLinksManager() : _subscribers = {};

  Future<void> init(String url) async {
    gfUrl = url;
  }

  Future<void> handleDeepLink(String deepLinkJson) async {
    Map<String, dynamic> deepLinkMap = jsonDecode(deepLinkJson);

    DeepLinkKey deepLinkCall = DeepLinkKey.fromJson(deepLinkMap);

    DeepLinksKeys? key = DeepLinksKeys.fromString(deepLinkCall.dp);

    List<void Function(String deepLink)>? subscribers = _subscribers[key];

    String deepLink = "$gfUrl&dp=${deepLinkCall.dp}";

    if (subscribers == null) {
      return;
    }

    int i = 0;

    while (i < subscribers.length) {
      subscribers[i](deepLink);

      i++;
    }
  }

  void registerSubscriber(
      DeepLinksKeys key, void Function(String deepLink) subscriber) {
    List<void Function(String deepLink)> currentSubscribers =
        _subscribers[key] ?? [];

    _subscribers[key] = [...currentSubscribers, subscriber];
  }

  void removeSubscriber(
      DeepLinksKeys key, void Function(String deepLink) subscriber) {
    List<void Function(String deepLink)> updatedList = [];

    List<void Function(String deepLink)> currentSubscribers =
        _subscribers[key] ?? [];

    int i = 0;

    while (i < updatedList.length) {
      if (subscriber != currentSubscribers[i]) {
        updatedList.add(currentSubscribers[i]);
      }

      i++;
    }

    _subscribers[key] = updatedList;
  }
}
