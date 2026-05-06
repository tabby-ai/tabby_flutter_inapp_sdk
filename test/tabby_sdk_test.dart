import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

const _validConfigJson = '''
{
  "default": {
    "endpoints": {
      "checkoutApiBaseUrl": "https://api.tabby.ai",
      "widgetsBaseUrl": "https://widgets.tabby.ai"
    }
  },
  "SAR": {
    "endpoints": {
      "checkoutApiBaseUrl": "https://api.tabby.sa",
      "widgetsBaseUrl": "https://widgets.tabby.sa"
    }
  }
}
''';

TabbyCheckoutPayload _payloadWithCurrency(Currency currency) {
  return TabbyCheckoutPayload(
    merchantCode: 'sa',
    lang: Lang.en,
    payment: Payment(
      amount: '100.00',
      currency: currency,
      buyer: Buyer(email: 'a@b.c', phone: '+1', name: 'Test'),
      buyerHistory: BuyerHistory(
        registeredSince: '2024-01-01T00:00:00Z',
        loyaltyLevel: 0,
      ),
      shippingAddress: null,
      order: Order(referenceId: 'ref-1', items: const []),
      orderHistory: const [],
    ),
  );
}

void main() {
  group('TabbySDK.setup', () {
    test(
        'issues POST to bootstrap host with expected headers and empty JSON body',
        () async {
      final captured = <http.Request>[];
      final client = MockClient((request) async {
        captured.add(request);
        return http.Response(_validConfigJson, 200);
      });
      TabbySDK().httpClientForTesting = client;

      await TabbySDK().setup(
        withApiKey: 'pk_test_123',
        environment: Environment.production,
      );

      expect(captured, hasLength(1));
      final req = captured.single;
      expect(req.method, 'POST');
      expect(req.url.toString(), 'https://api.tabby.ai/api/v1/sdk/config');
      expect(req.headers['Content-Type'], contains('application/json'));
      expect(req.headers.containsKey('Authorization'), isFalse,
          reason: 'bootstrap config endpoint is merchant-agnostic; no auth');
      expect(req.headers['X-SDK-Version'], startsWith('Flutter/'));
      expect(jsonDecode(req.body), <String, dynamic>{});
    });
  });

  group('TabbySDK.createSession routing', () {
    SdkConfig buildConfig() => SdkConfig.fromJson(<String, dynamic>{
          'default': {
            'endpoints': {
              'checkoutApiBaseUrl': 'https://api.tabby.ai',
              'widgetsBaseUrl': 'https://widgets.tabby.ai',
            },
          },
          'SAR': {
            'endpoints': {
              'checkoutApiBaseUrl': 'https://api.tabby.sa',
              'widgetsBaseUrl': 'https://widgets.tabby.sa',
            },
          },
        });

    test('routes to SAR checkoutApiBaseUrl when payment.currency = sar',
        () async {
      final captured = <http.Request>[];
      final client = MockClient((request) async {
        captured.add(request);
        return http.Response('', 500);
      });
      TabbySDK().httpClientForTesting = client;
      TabbySDK().primeConfigForTest(
        apiKey: 'pk_test_123',
        environment: Environment.production,
        config: buildConfig(),
      );

      try {
        await TabbySDK().createSession(_payloadWithCurrency(Currency.sar));
      } catch (_) {}

      expect(captured, hasLength(1));
      expect(captured.single.url.toString(),
          'https://api.tabby.sa/api/v2/checkout');
    });

    test('falls back to default checkoutApiBaseUrl when currency is absent',
        () async {
      final captured = <http.Request>[];
      final client = MockClient((request) async {
        captured.add(request);
        return http.Response('', 500);
      });
      TabbySDK().httpClientForTesting = client;
      TabbySDK().primeConfigForTest(
        apiKey: 'pk_test_123',
        environment: Environment.production,
        config: buildConfig(),
      );

      try {
        await TabbySDK().createSession(_payloadWithCurrency(Currency.aed));
      } catch (_) {}

      expect(captured, hasLength(1));
      expect(captured.single.url.toString(),
          'https://api.tabby.ai/api/v2/checkout');
    });
  });

  group('TabbySDK setup-required guards', () {
    test('createSession throws "did not setup" when singleton is un-primed',
        () async {
      TabbySDK().resetForTest();

      expect(
        () => TabbySDK().createSession(_payloadWithCurrency(Currency.aed)),
        throwsA(predicate(
          (Object e) => e.toString().contains('did not setup'),
        )),
      );
    });

    test('widgetsBaseUrlFor throws "did not setup" when singleton is un-primed',
        () {
      TabbySDK().resetForTest();

      expect(
        () => TabbySDK().widgetsBaseUrlFor(Currency.aed),
        throwsA(predicate(
          (Object e) => e.toString().contains('did not setup'),
        )),
      );
    });
  });
}
