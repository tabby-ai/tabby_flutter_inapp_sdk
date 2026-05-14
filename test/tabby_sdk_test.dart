// ignore_for_file: lines_longer_than_80_chars

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
          'general': {
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

  group('TabbySDK.setup failure modes', () {
    test('throws ServerException when bootstrap returns non-200', () async {
      TabbySDK().resetForTest();
      TabbySDK().httpClientForTesting =
          MockClient((_) async => http.Response('boom', 500));

      expect(
        TabbySDK().setup(
          withApiKey: 'pk_test',
          environment: Environment.production,
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws FormatException when bootstrap body is not valid JSON',
        () async {
      TabbySDK().resetForTest();
      TabbySDK().httpClientForTesting =
          MockClient((_) async => http.Response('not-json', 200));

      expect(
        TabbySDK().setup(
          withApiKey: 'pk_test',
          environment: Environment.production,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when bootstrap body is missing default key',
        () async {
      TabbySDK().resetForTest();
      TabbySDK().httpClientForTesting = MockClient(
        (_) async => http.Response('{"SAR":{"endpoints":{}}}', 200),
      );

      expect(
        TabbySDK().setup(
          withApiKey: 'pk_test',
          environment: Environment.production,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('propagates transport error (e.g. SocketException) unchanged',
        () async {
      TabbySDK().resetForTest();
      TabbySDK().httpClientForTesting = MockClient((_) async {
        throw const _FakeSocketException('boom');
      });

      expect(
        TabbySDK().setup(
          withApiKey: 'pk_test',
          environment: Environment.production,
        ),
        throwsA(isA<_FakeSocketException>()),
      );
    });

    test('throws before any HTTP call when withApiKey is empty', () async {
      TabbySDK().resetForTest();
      var hits = 0;
      TabbySDK().httpClientForTesting = MockClient((_) async {
        hits++;
        return http.Response(_validConfigJson, 200);
      });

      expect(
        TabbySDK().setup(
          withApiKey: '',
          environment: Environment.production,
        ),
        throwsA(predicate(
            (Object e) => e.toString().contains('public key cannot be empty'))),
      );
      // Allow async micro-task to settle without HTTP being called.
      await Future<void>.delayed(Duration.zero);
      expect(hits, 0);
    });
  });

  group('TabbySDK.setup re-invocation', () {
    test(
        'replaces stored config on a second setup with a different environment',
        () async {
      TabbySDK().resetForTest();

      const firstJson = '''
{
  "default": {
    "endpoints": {
      "checkoutApiBaseUrl": "https://api.tabby.ai",
      "widgetsBaseUrl": "https://widgets.tabby.ai"
    }
  }
}
''';
      const secondJson = '''
{
  "default": {
    "endpoints": {
      "checkoutApiBaseUrl": "https://api.tabby.dev",
      "widgetsBaseUrl": "https://widgets.tabby.dev"
    }
  }
}
''';

      String? bootstrapHost;
      var bootstrapHits = 0;
      final responses = <String>[firstJson, secondJson];
      final captured = <http.Request>[];
      TabbySDK().httpClientForTesting = MockClient((request) async {
        if (request.url.path == '/api/v1/sdk/config') {
          bootstrapHost = request.url.host;
          bootstrapHits++;
          return http.Response(responses.removeAt(0), 200);
        }
        captured.add(request);
        return http.Response('', 500);
      });

      await TabbySDK().setup(
        withApiKey: 'pk_test',
        environment: Environment.production,
      );
      expect(bootstrapHost, 'api.tabby.ai');

      await TabbySDK().setup(
        withApiKey: 'pk_test',
        environment: Environment.staging,
      );
      expect(bootstrapHost, 'api.tabby.dev');
      expect(bootstrapHits, 2);

      try {
        await TabbySDK().createSession(_payloadWithCurrency(Currency.aed));
      } catch (_) {}

      expect(captured, hasLength(1));
      expect(captured.single.url.toString(),
          'https://api.tabby.dev/api/v2/checkout');
    });
  });
}

class _FakeSocketException implements Exception {
  const _FakeSocketException(this.message);
  final String message;

  @override
  String toString() => 'SocketException: $message';
}
