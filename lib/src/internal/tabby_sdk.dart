import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

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
}

class TabbySDK implements TabbyWithRemoteDataSource {
  factory TabbySDK() {
    return _singleton;
  }

  TabbySDK._internal();

  static final TabbySDK _singleton = TabbySDK._internal();

  late final String apiKey;
  late final String host;

  @override
  void setup({
    required String withApiKey,
    Environment environment = Environment.production,
  }) {
    if (withApiKey.isEmpty) {
      throw 'Tabby public key cannot be empty';
    }
    apiKey = withApiKey;
    host = environment.host;
  }

  void checkSetup() {
    try {
      apiKey.isNotEmpty && host.isNotEmpty;
    } catch (e) {
      throw 'TabbySDK did not setup.\nCall TabbySDK().setup in main.dart';
    }
  }

  @override
  Future<TabbySession> createSession(TabbyCheckoutPayload payload) async {
    checkSetup();
    final response = await http.post(
      Uri.parse('${host}api/v2/checkout'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
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
                webUrl: installmentsPlan.webUrl)
            : null,
      );

      final tabbyCheckoutSession = TabbySession(
        sessionId: checkoutSession.id,
        paymentId: checkoutSession.payment.id,
        availableProducts: availableProducts,
      );
      return tabbyCheckoutSession;
    } else {
      debugPrint(response.body);
      throw ServerException();
    }
  }
}
