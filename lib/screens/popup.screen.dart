import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/managers/bridge/bridge.manager.dart';
import 'package:flutter_application_1/managers/bridge/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Popup extends StatefulWidget {
  final String? url;
  final dynamic eventPayload;
  final void Function() closePopup;
  final void Function(String deepLinkJson) onDeepLinkHandle;

  const Popup({
    super.key,
    required this.closePopup,
    required this.onDeepLinkHandle,
    this.url,
    this.eventPayload,
  });

  @override
  PopupState createState() => PopupState();
}

class PopupState extends State<Popup> {
  late final WebViewController _webViewController;
  Bridge? javaScriptChannelBridge;

  bool loaded = false;
  bool isClosed = false;

  @override
  void dispose() {
    javaScriptChannelBridge?.removeSubscriber(
        JavaScriptChannelCall.pageReady, handlePageReady);
    javaScriptChannelBridge?.removeSubscriber(
        JavaScriptChannelCall.closeMe, handleCloseCall);
    javaScriptChannelBridge?.removeSubscriber(
        JavaScriptChannelCall.showEngagement, handleShowEngagement);
    javaScriptChannelBridge?.removeSubscriber(
        JavaScriptChannelCall.toggleDeepLink, handleDeepLink);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (loaded == true) {
      return;
    }

    _webViewController = WebViewController()
      ..loadRequest(Uri.parse(widget.url!))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        "SmarticoBridge",
        onMessageReceived: (JavaScriptMessage javaScriptMessage) {
          javaScriptChannelBridge?.listenChannelCalls(javaScriptMessage);

          log("message from the web view -> \"${javaScriptMessage.message}\"");
        },
      );

    javaScriptChannelBridge = Bridge();

    javaScriptChannelBridge?.registerSubscriber(
        JavaScriptChannelCall.pageReady, handlePageReady);
    javaScriptChannelBridge?.registerSubscriber(
        JavaScriptChannelCall.closeMe, handleCloseCall);
    javaScriptChannelBridge?.registerSubscriber(
        JavaScriptChannelCall.showEngagement, handleShowEngagement);
    javaScriptChannelBridge?.registerSubscriber(
        JavaScriptChannelCall.toggleDeepLink, handleDeepLink);

    loaded = true;
  }

  void handlePageReady(JavaScriptMessage javaScriptMessage) {
    log("page ready, sending -> 'window.postMessage({\"bcid\": 3, ...${widget.eventPayload}})'");

    _webViewController.runJavaScript(
        'window.postMessage({"bcid": 3, ...${widget.eventPayload}})');
  }

  void handleCloseCall(JavaScriptMessage javaScriptMessage) {
    if (isClosed == true) {
      return;
    }

    widget.closePopup();

    isClosed = true;
  }

  void handleShowEngagement(JavaScriptMessage javaScriptMessage) {
    webSocketManager.send(javaScriptMessage.message);
  }

  void handleDeepLink(JavaScriptMessage javaScriptMessage) {
    widget.onDeepLinkHandle(javaScriptMessage.message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: WebViewWidget(
              controller: _webViewController,
            ),
          ),
        ],
      ),
    );
  }
}
