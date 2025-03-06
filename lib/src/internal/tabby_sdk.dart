import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tabby_flutter_inapp_sdk/src/internal/headers.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

abstract class TabbyWithRemoteDataSource {
  /// Initialise Tabby API.
  void setup({
    required String withApiKey,
    Environment environment = Environment.production,
  });

  /// Calls the https://api.tabby.dev/api/v2/checkout endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<TabbySession> createSession(TabbyCheckoutPayload payload);

  /// Log analytics event
  Future<void> logEvent(AnalyticsEvent event, EventProperties properties);
}

class TabbySDK implements TabbyWithRemoteDataSource {
  factory TabbySDK() {
    return _singleton;
  }

  TabbySDK._();

  static final TabbySDK _singleton = TabbySDK._();

  static const String rejectionTextEn = tabbyRejectionTextEn;
  static const String rejectionTextAr = tabbyRejectionTextAr;

  final _anonymousId = uuid.v4();

  late final String _apiKey;
  late final String _host;
  late final String _analyticsHost;

  @override
  void setup({
    required String withApiKey,
    Environment environment = Environment.production,
  }) {
    if (withApiKey.isEmpty) {
      throw 'Tabby public key cannot be empty';
    }
    _apiKey = withApiKey;
    _host = environment.host;
    _analyticsHost = environment.analyticsHost;
  }

  void checkSetup() {
    try {
      _apiKey.isNotEmpty && _host.isNotEmpty;
    } catch (e) {
      throw 'TabbySDK did not setup.\nCall TabbySDK().setup in main.dart';
    }
  }

  @override
  Future<TabbySession> createSession(TabbyCheckoutPayload payload) async {
    checkSetup();
    final response = await http.post(
      Uri.parse('$_host/api/v2/checkout'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-SDK-Version': getVersionHeader(),
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode(payload.toJson()),
    );

    debugPrint('session create status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final checkoutSession =
          CheckoutSession.fromJson(jsonDecode(response.body));

      final installmentsPlan =
          checkoutSession.configuration.availableProducts.installments?.first;

      final availableProducts = TabbySessionAvailableProducts(
        installments: installmentsPlan != null
            ? TabbyProduct(
                type: TabbyPurchaseType.installments,
                webUrl: installmentsPlan.webUrl,
              )
            : null,
      );

      final tabbyCheckoutSession = TabbySession(
        sessionId: checkoutSession.id,
        status: checkoutSession.status,
        paymentId: checkoutSession.payment.id,
        availableProducts: availableProducts,
      );
      return tabbyCheckoutSession;
    } else {
      debugPrint(response.body);
      throw ServerException();
    }
  }

  @override
  Future<void> logEvent(
    AnalyticsEvent event,
    EventProperties properties,
  ) async {
    final data = {
      'anonymousId': _anonymousId,
      'messageId': uuid.v4(),
      'properties': {
        'publicKey': _apiKey,
        'platformType': 'merchant app',
        'productType': 'installments',
        'merchantIntegrationType': 'snippetAndPopup',
        'planSelected': properties.installmentsCount,
        'popupType': 'standardWithInfo',
        'snippetType': 'fullInformation',
        'merchantCountry': properties.currency.countryName
      },
      'mobileSDK': true,
      'context': {
        'source': 'flutter-sdk',
        'direct': true,
      },
      'type': 'track',
      'event': event.name,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'integrations': {
        'Segment.io': true,
      },
    };
    if (kDebugMode) {
      print('Tabby SDK logEvent :: ${jsonEncode(data)}');
    }
    try {
      await http.post(
        Uri.parse(_analyticsHost),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-SDK-Version': getVersionHeader(),
          'Authorization': 'Basic ${getHeader()}',
        },
        body: jsonEncode(data),
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
