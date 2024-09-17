enum ServerCall {
  ping(1),
  identifyUserResponse(6),
  clientEngagementEvent(110),
  sawEvent(707);

  final int cid;

  const ServerCall(this.cid);

  static ServerCall? fromCid(int cid) {
    for (var call in ServerCall.values) {
      if (call.cid == cid) {
        return call;
      }
    }

    return null;
  }
}

enum WebSocketUrl {
  api6(6,
      'wss://api6.smartico.ai/websocket/services?master=&domain=demo.smartico.ai&version=1.3.209'),
  api5(5,
      'wss://api5.smartico.ai/websocket/services?master=&domain=demo.smartico.ai&version=1.3.209'),
  api4(4,
      'wss://api4.smartico.ai/websocket/services?master=&domain=demo.smartico.ai&version=1.3.209'),
  api3(3,
      'wss://api3.smartico.ai/websocket/services?master=&domain=demo.smartico.ai&version=1.3.209'),
  api2(2,
      'wss://api.smartico.ai/websocket/service?master=&domain=demo.smartico.ai&version=1.3.209');

  final int apiNumber;
  final String url;

  const WebSocketUrl(this.apiNumber, this.url);

  static String getWebSocketUrl(int number) {
    for (var service in WebSocketUrl.values) {
      if (service.apiNumber == number) {
        return service.url;
      }
    }

    throw Exception('Invalid API number');
  }
}
