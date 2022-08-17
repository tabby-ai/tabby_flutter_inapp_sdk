import 'dart:convert';

import 'package:tabby_flutter/models/enums.dart';
import 'package:tabby_flutter/models/errors.dart';
import 'package:tabby_flutter/models/models.dart';
import 'package:http/http.dart' as http;

abstract class TabbyWithRemoteDataSource {
  /// Calls the https://api.tabby.dev/api/v2/checkout endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<TabbySession> createSession(TabbyCheckoutPayload payload);
}

enum WebViewResult {
  close,
  authorized,
  rejected,
  expired,
}

extension WebViewResultExt on WebViewResult {
  String get name {
    switch (this) {
      case WebViewResult.close:
        return 'close';
      case WebViewResult.authorized:
        return 'authorized';
      case WebViewResult.rejected:
        return 'rejected';
      case WebViewResult.expired:
        return 'expired';
    }
  }
}

class TabbySdk implements TabbyWithRemoteDataSource {
  late final String apiKey;
  static const _apiHost = 'https://api.tabby.dev/api/v2/checkout';

  setup({required String withApiKey}) {
    apiKey = withApiKey;
  }

  @override
  Future<TabbySession> createSession(TabbyCheckoutPayload payload) async {
    final response = await http.post(
      Uri.parse(_apiHost),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(payload.toJson()),
    );
    if (response.statusCode == 200) {
      final checkoutSession =
          CheckoutSession.fromJson(jsonDecode(response.body));

      final installmentsPlan =
          checkoutSession.configuration.available_products.installments?.first;
      final creditCardInstallmentsPlan = checkoutSession
          .configuration.available_products.credit_card_installments?.first;
      // final monthlyBillingPlan = checkoutSession
      //     .configuration.available_products.monthly_billing?.first;

      final availableProducts = TabbySessionAvailableProducts(
        credit_card_installments: creditCardInstallmentsPlan != null
            ? TabbyProduct(
                type: TabbyPurchaseType.credit_card_installments,
                webUrl: creditCardInstallmentsPlan.web_url)
            : null,
        installments: installmentsPlan != null
            ? TabbyProduct(
                type: TabbyPurchaseType.installments,
                webUrl: installmentsPlan.web_url)
            : null,
        monthly_billing: null,
      );

      final tabbyCheckoutSession = TabbySession(
        sessionId: checkoutSession.id,
        paymentId: checkoutSession.payment.id,
        availableProducts: availableProducts,
      );
      return tabbyCheckoutSession;
    } else {
      throw ServerException();
    }
  }
}

final Tabby = TabbySdk();
