import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart' as crypto;

class CryptoUtils {
  final _uuid = const Uuid();
  String characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  String generateUuidV4() {
    return _uuid.v4();
  }

  String generateRandomString(int length) {
    final Random random = Random();

    return List.generate(length, (index) {
      final int randomIndex = random.nextInt(characters.length);

      return characters[randomIndex];
    }).join();
  }

  String hashUserId(String userExtId, int validityTimestampMs) {
    return '${crypto.md5.convert(utf8.encode('${userExtId.toLowerCase()}:null:$validityTimestampMs'))}:$validityTimestampMs';
  }
}

var cryptoUtils = CryptoUtils();
