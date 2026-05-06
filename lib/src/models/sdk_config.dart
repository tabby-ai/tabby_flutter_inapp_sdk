import 'package:tabby_flutter_inapp_sdk/src/models/enums.dart';

class SdkConfig {
  SdkConfig({required this.endpointsByKey});

  factory SdkConfig.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('default')) {
      throw FormatException(
          'SdkConfig: required "default" key is missing', json);
    }
    final byKey = <String, SdkEndpoints>{};
    json.forEach((key, value) {
      final entry = value as Map<String, dynamic>;
      final endpointsJson = entry['endpoints'] as Map<String, dynamic>;
      byKey[key] = SdkEndpoints.fromJson(endpointsJson);
    });
    return SdkConfig(endpointsByKey: byKey);
  }

  final Map<String, SdkEndpoints> endpointsByKey;

  SdkEndpoints endpointsFor(Currency currency) {
    final byCurrency = endpointsByKey[currency.displayName];
    if (byCurrency != null) {
      return byCurrency;
    }
    return endpointsByKey['default']!;
  }
}

class SdkEndpoints {
  SdkEndpoints({
    required this.checkoutApiBaseUrl,
    required this.widgetsBaseUrl,
  });

  factory SdkEndpoints.fromJson(Map<String, dynamic> json) {
    return SdkEndpoints(
      checkoutApiBaseUrl: _requireUrl(json, 'checkoutApiBaseUrl'),
      widgetsBaseUrl: _requireUrl(json, 'widgetsBaseUrl'),
    );
  }

  static String _requireUrl(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) {
      throw FormatException(
        'SdkEndpoints: missing or empty "$key" field',
        json,
      );
    }
    return value;
  }

  final String checkoutApiBaseUrl;
  final String widgetsBaseUrl;
}
