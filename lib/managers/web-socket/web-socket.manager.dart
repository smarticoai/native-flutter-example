import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_application_1/managers/web-socket/constants.dart';
import 'package:flutter_application_1/managers/web-socket/dto.dart';
import 'package:flutter_application_1/utils/crypto.utils.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketManager {
  late WebSocketChannel? _channel;
  final String sessionId;
  final Map<ServerCall, List<void Function(dynamic)>> _subscribers;

  String? lastMessageId;

  WebSocketManager()
      : _subscribers = {},
        sessionId = cryptoUtils.generateUuidV4();

  Future<void> initConnection(String connectionUrl) async {
    log("connecting to -> $connectionUrl");

    _channel = WebSocketChannel.connect(Uri.parse(connectionUrl));

    await _channel?.ready;

    log("successfully connected to the $connectionUrl");

    _channel?.stream.listen((message) {
      Map<String, dynamic> smarticoResponseMap = jsonDecode(message);

      WebSocketResponse smarticoResponse =
          WebSocketResponse.fromJson(smarticoResponseMap);

      if (smarticoResponse.uuid == lastMessageId && smarticoResponse.cid != 1) {
        return;
      }

      lastMessageId = smarticoResponse.uuid;

      log("get web socket call with cid -> ${smarticoResponse.cid}, message -> $message");

      ServerCall? key = ServerCall.fromCid(smarticoResponse.cid);
      List<void Function(dynamic)>? subscribers = _subscribers[key];

      int length = subscribers?.length ?? 0;

      int i = 0;

      while (i < length) {
        subscribers![i](message);

        i++;
      }
    });
  }

  void send(String message) {
    log("sending message: $message");

    _channel?.sink.add(message);
  }

  Future<void> disconnect() async {
    await _channel?.sink.close(status.normalClosure);

    _channel = null;
  }

  void registerSubscriber(ServerCall key, void Function(dynamic) subscriber) {
    List<void Function(dynamic)> currentSubscribers = _subscribers[key] ?? [];

    _subscribers[key] = [...currentSubscribers, subscriber];
  }

  void removeSubscriber(ServerCall key, void Function(dynamic) subscriber) {
    List<void Function(dynamic)> currentSubscribers = _subscribers[key] ?? [];
    List<void Function(dynamic)> updatedList = [];

    for (var currentSubscriber in currentSubscribers) {
      if (subscriber != currentSubscriber) {
        updatedList.add(currentSubscriber);
      }
    }

    _subscribers[key] = updatedList;
  }
}
