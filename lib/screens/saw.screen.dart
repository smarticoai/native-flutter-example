import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/managers/bridge/bridge.manager.dart';
import 'package:flutter_application_1/managers/bridge/constants.dart';
import 'package:flutter_application_1/managers/web-socket/dto.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Saw extends StatefulWidget {
  final String url;
  final int templateId;
  final int pendingMessageId;
  final void Function() closeSaw;

  const Saw({
    super.key,
    required this.closeSaw,
    required this.url,
    required this.templateId,
    required this.pendingMessageId,
  });

  @override
  SawWebViewScreenState createState() => SawWebViewScreenState();
}

class SawWebViewScreenState extends State<Saw> {
  late final WebViewController _webViewController;
  Bridge javaScriptChannelBridge = Bridge();

  bool loaded = false;
  bool isClosed = false;

  @override
  void dispose() {
    javaScriptChannelBridge.removeSubscriber(
        JavaScriptChannelCall.closeMe, handleCloseCall);
    javaScriptChannelBridge.removeSubscriber(
        JavaScriptChannelCall.pageReady, sendAcknowledge);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (loaded == true) {
      return;
    }

    String sawUrl =
        "${widget.url}&saw_template_id=${widget.templateId}&pending_message_id=${widget.pendingMessageId}&dp=dp:gf_saw&standalone=true&id=${widget.templateId}";

    log("popup url -> $sawUrl");

    _webViewController = WebViewController()
      ..loadRequest(Uri.parse(sawUrl))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        "SmarticoBridge",
        onMessageReceived: (JavaScriptMessage javaScriptMessage) {
          javaScriptChannelBridge.listenChannelCalls(javaScriptMessage);

          log("message from the web view=\"${javaScriptMessage.message}\"");
        },
      );

    javaScriptChannelBridge = Bridge();

    javaScriptChannelBridge.registerSubscriber(
        JavaScriptChannelCall.closeMe, handleCloseCall);
    javaScriptChannelBridge.registerSubscriber(
        JavaScriptChannelCall.pageReady, sendAcknowledge);

    loaded = true;
  }

  Future<void> handleCloseCall(JavaScriptMessage javaScriptMessage) async {
    if (isClosed == true) {
      return;
    }

    widget.closeSaw();

    isClosed = true;
  }

  Future<void> sendAcknowledge(JavaScriptMessage javaScriptMessage) async {
    var payload = await AcknowledgeSpinPushPayload(
      templateId: widget.templateId,
      pendingMessageId: widget.pendingMessageId,
    ).toJson();

    webSocketManager.send(payload);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
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
    ));
  }
}
