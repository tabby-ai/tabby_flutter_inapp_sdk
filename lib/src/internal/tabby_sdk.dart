import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tabby_flutter_inapp_sdk/src/internal/headers.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

abstract class TabbyWithRemoteDataSource {
  /// Initialise Tabby API.
  ///
  /// Fetches the sharded SDK configuration from `/api/v1/sdk/config` before
  /// returning. Throws on network or parse failure; no fallback to embedded
  /// URLs.
  Future<void> setup({
    required String withApiKey,
    Environment environment = Environment.production,
  });

  /// Calls the `<checkoutApiBaseUrl>/api/v2/checkout` endpoint, where the base
  /// URL is resolved per `payload.payment.currency` from the loaded config.
  ///
  /// Throws a [ServerException] for all non-200 responses.
  Future<TabbySession> createSession(TabbyCheckoutPayload payload);
}

class TabbySDK implements TabbyWithRemoteDataSource {
  factory TabbySDK() {
    return _singleton;
  }

  TabbySDK._();

  static final TabbySDK _singleton = TabbySDK._();

  static const String rejectionTextEn = tabbyRejectionTextEn;
  static const String rejectionTextAr = tabbyRejectionTextAr;
  static const String jsBridgeName = 'tabbyMobileSDK';

  late String _apiKey;
  late Environment _environment;
  late SdkConfig _config;
  bool _ready = false;

  http.Client _httpClient = http.Client();

  @visibleForTesting
  set httpClientForTesting(http.Client client) => _httpClient = client;

  String get publicKey => _apiKey;

  String widgetsBaseUrlFor(Currency currency) {
    checkSetup();
    return _config.endpointsFor(currency).widgetsBaseUrl;
  }

  @override
  Future<void> setup({
    required String withApiKey,
    Environment environment = Environment.production,
  }) async {
    if (withApiKey.isEmpty) {
      throw 'Tabby public key cannot be empty';
    }
    _apiKey = withApiKey;
    _environment = environment;
    _config = await _fetchSdkConfig();
    _ready = true;
  }

  Future<SdkConfig> _fetchSdkConfig() async {
    final url = '${_environment.bootstrapApiBaseUrl}/api/v1/sdk/config';
    final response = await _httpClient.post(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-SDK-Version': getVersionHeader(),
      },
      body: jsonEncode(<String, dynamic>{}),
    );

    debugPrint('sdk config status: ${response.statusCode}');
    if (response.statusCode != 200) {
      debugPrint(response.body);
      throw ServerException();
    }
    return SdkConfig.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  void checkSetup() {
    if (!_ready) {
      throw 'TabbySDK did not setup.\n'
          'Call `await TabbySDK().setup(...)` in main.dart';
    }
  }

  @override
  Future<TabbySession> createSession(TabbyCheckoutPayload payload) async {
    checkSetup();
    final endpoints = _config.endpointsFor(payload.payment.currency);
    final response = await _httpClient.post(
      Uri.parse('${endpoints.checkoutApiBaseUrl}/api/v2/checkout'),
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
        rejectionReason: checkoutSession
            .configuration.products.installments?.rejectionReason,
      );
      return tabbyCheckoutSession;
    } else {
      debugPrint(response.body);
      throw ServerException();
    }
  }

  @visibleForTesting
  void primeConfigForTest({
    required String apiKey,
    required Environment environment,
    required SdkConfig config,
  }) {
    _apiKey = apiKey;
    _environment = environment;
    _config = config;
    _ready = true;
  }
}
