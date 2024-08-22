import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';

var uuid = const Uuid();
var labelName = "";
var labelKey = "";
var brandKey = "";
var trackerVersion = "1.3.197";
var extUserId = "";
var page = "";

class SmarticoResponse {
  int cid;

  SmarticoResponse({required this.cid});

  factory SmarticoResponse.fromJson(Map<String, dynamic> json) {
    return SmarticoResponse(
      cid: json['cid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
    };
  }
}

class Ping {
  int cid;
  int ts;
  String uuid;

  Ping({required this.cid, required this.ts, required this.uuid});

  factory Ping.fromJson(Map<String, dynamic> json) {
    return Ping(cid: json['cid'], ts: json['ts'], uuid: json['uuid']);
  }

  Map<String, dynamic> toJson() {
    return {'cid': cid, 'ts': ts, 'uuid': uuid};
  }
}

class WebViewToNativeCall {
  int bcid;

  WebViewToNativeCall({required this.bcid});

  factory WebViewToNativeCall.fromJson(Map<String, dynamic> json) {
    return WebViewToNativeCall(bcid: json['bcid']);
  }

  Map<String, dynamic> toJson() {
    return {
      'bcid': bcid,
    };
  }
}

class IdentifyUserResponse {
  final int cid;
  final String publicUsername;
  final String avatarId;
  final String? nativeAppGfUrl;
  final String? nativeAppPopupUrl;

  IdentifyUserResponse({
    required this.cid,
    required this.publicUsername,
    required this.avatarId,
    this.nativeAppGfUrl,
    this.nativeAppPopupUrl,
  });

  factory IdentifyUserResponse.fromJson(Map<String, dynamic> json) {
    return IdentifyUserResponse(
      cid: json['cid'],
      publicUsername: json['public_username'],
      avatarId: json['avatar_id'],
      nativeAppGfUrl: json['native_app_gf_url'],
      nativeAppPopupUrl: json['native_app_popup_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
      'public_username': publicUsername,
      'avatar_id': avatarId,
      'native_app_gf_url': nativeAppGfUrl,
      'native_app_popup_url': nativeAppPopupUrl,
    };
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Smartico Popup Demo',
      home: WebSocketDemo(),
    );
  }
}

class WebSocketWebViewBridge extends StatefulWidget {
  const WebSocketWebViewBridge({super.key});

  @override
  WebSocketDemoState createState() => WebSocketDemoState();
}

class WebSocketDemo extends StatefulWidget {
  const WebSocketDemo({super.key});

  @override
  WebSocketDemoState createState() => WebSocketDemoState();
}

class WebViewScreen extends StatefulWidget {
  final String appPopupUrl;
  final dynamic eventPayload;
  final WebSocketChannel wsChannel;

  const WebViewScreen(
      {super.key,
      required this.appPopupUrl,
      required this.eventPayload,
      required this.wsChannel});

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..loadRequest(Uri.parse(widget.appPopupUrl))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        "SmarticoBridge",
        onMessageReceived: (JavaScriptMessage javaScriptMessage) {
          Map<String, dynamic> webViewToNativeCallMap =
              jsonDecode(javaScriptMessage.message);

          WebViewToNativeCall webViewToNativeCall =
              WebViewToNativeCall.fromJson(webViewToNativeCallMap);

          if (webViewToNativeCall.bcid == 1) {
            log("bcid 1 => inject event: ${widget.eventPayload}");

            _webViewController.runJavaScript(
                'window.postMessage({"bcid": 3, ...${widget.eventPayload}})');
          }

          if (webViewToNativeCall.bcid == 2) {
            log("bcid 2 => close");

            Navigator.of(context).popUntil((route) => route.isFirst);
          }

          if (webViewToNativeCall.bcid == 6) {
            log("bcid 6 => sending message to the server: ${javaScriptMessage.message}");

            widget.wsChannel.sink.add(javaScriptMessage.message);
          }

          log("message from the web view=\"${javaScriptMessage.message}\"");
        },
      );
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

enum ConnectionStatuses {
  connected,
  disconnected,
}

class WebSocketDemoState extends State<WebSocketDemo> {
  WebSocketChannel? channel;
  String? appPopupUrl;
  ConnectionStatuses connectionStatus = ConnectionStatuses.disconnected;

  @override
  void dispose() {
    closeWsConnection();

    super.dispose();
  }

  void closeWsConnection() {
    channel?.sink.close(status.goingAway);

    handleLostConnection();
  }

  Future<void> initWebSocket() async {
    try {
      channel = WebSocketChannel.connect(
        Uri.parse('wss://api5.smartico.ai/websocket/services'),
      );

      await channel?.ready;

      handleWsConnect();
    } catch (err) {
      log("error in ws connect $err");
    }

    sendInitialPayload();

    channel?.stream.listen((message) {
      log("get message from the server: $message");

      Map<String, dynamic> smarticoResponseMap = jsonDecode(message);

      SmarticoResponse smarticoResponse =
          SmarticoResponse.fromJson(smarticoResponseMap);

      if (smarticoResponse.cid == 1) {
        pong();
      }

      if (smarticoResponse.cid == 6) {
        try {
          IdentifyUserResponse identifyUserResponse =
              IdentifyUserResponse.fromJson(smarticoResponseMap);

          setState(() {
            appPopupUrl = identifyUserResponse.nativeAppPopupUrl;
          });
        } catch (err) {
          log("Error during parse of IdentifyUserResponse");
        }
      }

      if (smarticoResponse.cid == 110) {
        if (appPopupUrl != null && channel != null) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              barrierColor: Colors.black54,
              pageBuilder: (BuildContext context, _, __) => WebViewScreen(
                appPopupUrl: appPopupUrl!,
                eventPayload: message!,
                wsChannel: channel!,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        }
      }

      log("message cid is ${smarticoResponse.cid}");
    }, onError: (error) {
      log("error $error");

      closeWsConnection();
    }, onDone: () {
      log("done");
    });
  }

  void handleLostConnection() {
    setState(() {
      connectionStatus = ConnectionStatuses.disconnected;
    });
  }

  void handleWsConnect() {
    setState(() {
      connectionStatus = ConnectionStatuses.connected;
    });
  }

  void sendResponceMessage(dynamic message) {
    channel?.sink.add(message);
  }

  void pong() {
    final payload = {
      "cid": 2,
      "ts": DateTime.now().millisecondsSinceEpoch,
      "uuid": uuid.v4()
    };

    try {
      log("sending pong");

      channel?.sink.add(jsonEncode(payload));
    } catch (err) {
      log("error during sending the pong");
    }
  }

  void sendInitialPayload() async {
    String? deviceId = await _getId();

    final payload = {
      "cid": 3,
      "label_name": labelName,
      "label_key": labelKey,
      "brand_key": brandKey,
      "simulation_mode": false,
      "device_id": deviceId,
      "page": page,
      "tracker_version": trackerVersion,
      "session_id": uuid.v4(),
      "ts": DateTime.now().millisecondsSinceEpoch,
      "uuid": uuid.v4()
    };

    try {
      log("sending inilial payload with body $payload");

      channel?.sink.add(jsonEncode(payload));
    } catch (err) {
      log("error in send initial payload $err");
    }
  }

  void identifyUser() {
    final identifyPayload = {
      "cid": 5,
      "ext_user_id": extUserId,
      "visitor_id": null,
      "ua": {
        "host": "libs.smartico.ai",
        "device_type": "NATIVE_PHONE",
        "tzoffset": -180,
        "browser": "Chrome",
        "os": "Android"
      },
      "page": page,
      "skip_cjm_processing": false,
      "token": null,
      "pushNotificationUserStatus": 4,
      "platform": 0,
      "app_package_id": null,
      "payload": {},
      "ts": DateTime.now().millisecondsSinceEpoch,
      "uuid": uuid.v4()
    };

    try {
      log('trying to identify the user...');

      channel?.sink.add(jsonEncode(identifyPayload));
    } catch (err) {
      log("error in identifyUser $err");
    }
  }

  void login() {
    final identifyPayload = {
      "cid": 7,
      "payload": {
        "ua_device_type": "NATIVE_PHONE",
        "ua_tzoffset": -180,
        "ua_os": "Android"
      },
      "ts": DateTime.now().millisecondsSinceEpoch,
      "uuid": uuid.v4()
    };

    try {
      log("trying to login user...");

      channel?.sink.add(jsonEncode(identifyPayload));
    } catch (err) {
      log("error in login $err");
    }
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;

      return iosDeviceInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;

      return androidDeviceInfo.id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smartico Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text("Web Socket Connection status: $connectionStatus"),
            ElevatedButton(
              onPressed: initWebSocket,
              child: const Text('Init WebSocket'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: identifyUser,
              child: const Text('Identify User'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: closeWsConnection,
              child: const Text('Close WS connection'),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 32),
            const Text(
              'Response from server:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(appPopupUrl ?? 'No popup url yet'),
          ],
        ),
      ),
    );
  }
}
