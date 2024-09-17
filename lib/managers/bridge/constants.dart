enum JavaScriptChannelCall {
  pageReady(1),
  closeMe(2),
  showEngagement(3),
  toggleDeepLink(4);

  final int bcid;

  const JavaScriptChannelCall(this.bcid);

  static JavaScriptChannelCall? fromBcid(int bcid) {
    for (var call in JavaScriptChannelCall.values) {
      if (call.bcid == bcid) {
        return call;
      }
    }

    return null;
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
