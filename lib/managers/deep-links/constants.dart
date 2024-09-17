enum DeepLinksKeys {
  gf('dp:gf'),
  saw('dp:gf_saw');

  final String value;

  const DeepLinksKeys(this.value);

  static DeepLinksKeys? fromString(String input) {
    for (DeepLinksKeys key in DeepLinksKeys.values) {
      if (key.value == input) {
        return key;
      }
    }

    return null;
  }
}

class DeepLinkKey {
  String dp;

  DeepLinkKey({required this.dp});

  factory DeepLinkKey.fromJson(Map<String, dynamic> json) {
    return DeepLinkKey(dp: json['dp']);
  }

  Map<String, dynamic> toJson() {
    return {
      'dp': dp,
    };
  }
}
