import 'dart:convert';

import 'package:flutter_application_1/utils/crypto.utils.dart';
import 'package:flutter_application_1/utils/device.utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebSocketResponse {
  int cid;
  String uuid;

  WebSocketResponse({required this.cid, required this.uuid});

  factory WebSocketResponse.fromJson(Map<String, dynamic> json) {
    return WebSocketResponse(
      cid: json['cid'],
      uuid: json['uuid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
    };
  }
}

class PingPayload {
  final int cid = 2;

  PingPayload();

  String toJson() {
    return jsonEncode({
      "cid": cid,
      "ts": DateTime.now().millisecondsSinceEpoch,
      "uuid": cryptoUtils.generateUuidV4()
    });
  }
}

class IdentifyUserPayload {
  final int cid = 5;
  final String userExtId;

  IdentifyUserPayload({required this.userExtId});

  String toJson() {
    final hashValidityTimestampMs =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) * 1000 +
            24 * 3600 * 1000;

    return jsonEncode({
      "cid": cid,
      "ext_user_id": userExtId.toLowerCase(),
      "visitor_id": null,
      "ua": {
        "host": "libs.smartico.ai",
        "device_type": "NATIVE_PHONE",
        "tzoffset": -180,
        "browser": "Chrome",
        "os": "Android"
      },
      "page": dotenv.env['PAGE'],
      "skip_cjm_processing": false,
      "token": null,
      "pushNotificationUserStatus": 4,
      "platform": 0,
      "app_package_id": null,
      "payload": {},
      "hash": cryptoUtils.hashUserId(userExtId, hashValidityTimestampMs),
      "ts": DateTime.now().millisecondsSinceEpoch,
      "uuid": cryptoUtils.generateUuidV4()
    });
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

class HandshakePayload {
  final int cid = 3;
  final String sessionId;

  HandshakePayload({
    required this.sessionId,
  });

  Future<String> toJson() async {
    return jsonEncode({
      "cid": cid,
      "label_key": dotenv.env['LABEL_KEY'],
      "label_name": dotenv.env['LABEL_KEY'],
      "brand_key": dotenv.env['BRAND_KEY'],
      "simulation_mode": false,
      "device_id": await DeviceUtils.getDeviceId(),
      "page": dotenv.env['PAGE'],
      "tracker_version": dotenv.env['TRACKER_VERSION'],
      "session_id": sessionId,
      "ts": DateTime.now().millisecondsSinceEpoch,
      "uuid": cryptoUtils.generateUuidV4(),
    });
  }
}

class SawTemplateResponse {
  int cid;
  int sawTemplateId;
  int pendingMessageId;
  int ts;
  String uuid;

  SawTemplateResponse({
    required this.cid,
    required this.ts,
    required this.uuid,
    required this.sawTemplateId,
    required this.pendingMessageId,
  });

  factory SawTemplateResponse.fromJson(Map<String, dynamic> json) {
    return SawTemplateResponse(
        cid: json['cid'],
        ts: json['ts'],
        uuid: json['uuid'],
        sawTemplateId: json['saw_template_id'],
        pendingMessageId: json['pending_message_id']);
  }

  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
      'ts': ts,
      'uuid': uuid,
      'sawTemplateId': sawTemplateId,
      'pendingMessageId': pendingMessageId
    };
  }
}

class AcknowledgeSpinPushPayload {
  final int cid = 711;
  final int templateId;
  final int pendingMessageId;

  AcknowledgeSpinPushPayload({
    required this.templateId,
    required this.pendingMessageId,
  });

  Future<String> toJson() async {
    return jsonEncode({
      "saw_template_id": templateId,
      "pending_message_id": pendingMessageId,
      "cid": cid,
    });
  }
}

class ClientEngagementResponse {
  int cid;
  int activityType;

  ClientEngagementResponse({
    required this.cid,
    required this.activityType,
  });

  factory ClientEngagementResponse.fromJson(Map<String, dynamic> json) {
    return ClientEngagementResponse(
      cid: json['cid'],
      activityType: json['activityType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
      'activityType': activityType,
    };
  }
}
