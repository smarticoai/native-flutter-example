import 'dart:convert';
import 'dart:developer';

import 'package:flutter_application_1/managers/bridge/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Bridge {
  final Map<JavaScriptChannelCall, List<void Function(JavaScriptMessage)>>
      _subscribers;

  Bridge() : _subscribers = {};

  Future<void> listenChannelCalls(JavaScriptMessage javaScriptMessage) async {
    Map<String, dynamic> webViewToNativeCallMap =
        jsonDecode(javaScriptMessage.message);

    WebViewToNativeCall webViewToNativeCall =
        WebViewToNativeCall.fromJson(webViewToNativeCallMap);

    JavaScriptChannelCall? key =
        JavaScriptChannelCall.fromBcid(webViewToNativeCall.bcid);

    log("recieve native call with bcid -> ${webViewToNativeCall.bcid}, message -> ${javaScriptMessage.message}");

    List<void Function(JavaScriptMessage)>? subscribers = _subscribers[key];

    if (subscribers == null) {
      return;
    }

    int i = 0;

    while (i < subscribers.length) {
      subscribers[i](javaScriptMessage);

      i++;
    }
  }

  void registerSubscriber(
      JavaScriptChannelCall key, void Function(JavaScriptMessage) subscriber) {
    List<void Function(JavaScriptMessage)> currentSubscribers =
        _subscribers[key] ?? [];

    _subscribers[key] = [...currentSubscribers, subscriber];
  }

  void removeSubscriber(
      JavaScriptChannelCall key, void Function(JavaScriptMessage) subscriber) {
    List<void Function(JavaScriptMessage)> updatedList = [];

    List<void Function(JavaScriptMessage)> currentSubscribers =
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
