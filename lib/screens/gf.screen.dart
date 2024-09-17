import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/managers/bridge/bridge.manager.dart';
import 'package:flutter_application_1/managers/bridge/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Gf extends StatefulWidget {
  final String url;
  final void Function() closeGf;

  const Gf({
    super.key,
    required this.url,
    required this.closeGf,
  });

  @override
  GfState createState() => GfState();
}

class GfState extends State<Gf> {
  late final WebViewController _webViewController;
  final Bridge javaScriptChannelBridge = Bridge();

  @override
  void dispose() {
    javaScriptChannelBridge.removeSubscriber(
        JavaScriptChannelCall.closeMe, handleCloseCall);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    log('gf url -> ${widget.url}');

    _webViewController = WebViewController()
      ..loadRequest(Uri.parse(widget.url))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        "SmarticoBridge",
        onMessageReceived: (JavaScriptMessage javaScriptMessage) {
          javaScriptChannelBridge.listenChannelCalls(javaScriptMessage);

          log("message from the web view=\"${javaScriptMessage.message}\"");
        },
      );

    javaScriptChannelBridge.registerSubscriber(
        JavaScriptChannelCall.closeMe, handleCloseCall);
  }

  void handleCloseCall(JavaScriptMessage javaScriptMessage) {
    widget.closeGf();
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
