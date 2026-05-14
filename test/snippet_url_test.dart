// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

void main() {
  group('buildSnippetUrl', () {
    test(
        'joins base and tabby-promo.html with a single "/" regardless of trailing slash',
        () {
      const expectedQuery = '?price=100.0'
          '&currency=AED'
          '&publicKey=pk'
          '&merchantCode=ae'
          '&lang=en'
          '&installmentsCount=4';

      final withSlash = buildSnippetUrl(
        widgetsBaseUrl: 'https://widgets.tabby.ai/',
        price: 100.0,
        currency: Currency.aed,
        publicKey: 'pk',
        merchantCode: 'ae',
        lang: Lang.en,
        installmentsCount: 4,
      );
      final withoutSlash = buildSnippetUrl(
        widgetsBaseUrl: 'https://widgets.tabby.ai',
        price: 100.0,
        currency: Currency.aed,
        publicKey: 'pk',
        merchantCode: 'ae',
        lang: Lang.en,
        installmentsCount: 4,
      );

      expect(
          withSlash, 'https://widgets.tabby.ai/tabby-promo.html$expectedQuery');
      expect(withoutSlash,
          'https://widgets.tabby.ai/tabby-promo.html$expectedQuery');
    });

    test(
        'combines TabbySDK.widgetsBaseUrlFor with buildSnippetUrl for sharded currency',
        () {
      final config = SdkConfig.fromJson(<String, dynamic>{
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
      TabbySDK().primeConfigForTest(
        apiKey: 'pk',
        environment: Environment.production,
        config: config,
      );

      final sarUrl = buildSnippetUrl(
        widgetsBaseUrl: TabbySDK().widgetsBaseUrlFor(Currency.sar),
        price: 99.99,
        currency: Currency.sar,
        publicKey: 'pk',
        merchantCode: 'sa',
        lang: Lang.ar,
        installmentsCount: 4,
      );
      final aedUrl = buildSnippetUrl(
        widgetsBaseUrl: TabbySDK().widgetsBaseUrlFor(Currency.aed),
        price: 99.99,
        currency: Currency.aed,
        publicKey: 'pk',
        merchantCode: 'ae',
        lang: Lang.en,
        installmentsCount: 4,
      );

      expect(sarUrl, startsWith('https://widgets.tabby.sa/tabby-promo.html?'));
      expect(sarUrl, contains('currency=SAR'));
      expect(aedUrl, startsWith('https://widgets.tabby.ai/tabby-promo.html?'));
      expect(aedUrl, contains('currency=AED'));
    });
  });
}
