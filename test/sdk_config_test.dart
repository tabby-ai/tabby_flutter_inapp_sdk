// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

void main() {
  group('SdkEndpoints.fromJson', () {
    test('extracts checkoutApiBaseUrl and widgetsBaseUrl, ignores extras', () {
      final endpoints = SdkEndpoints.fromJson(<String, dynamic>{
        'checkoutApiBaseUrl': 'https://api.tabby.ai',
        'webCheckoutBaseUrl': 'https://checkout.tabby.ai',
        'widgetsBaseUrl': 'https://widgets.tabby.ai',
        'analyticsBaseUrl': 'https://dp-event-collector.tabby.ai',
      });

      expect(endpoints.checkoutApiBaseUrl, 'https://api.tabby.ai');
      expect(endpoints.widgetsBaseUrl, 'https://widgets.tabby.ai');
    });

    test('throws FormatException when checkoutApiBaseUrl is missing', () {
      expect(
        () => SdkEndpoints.fromJson(<String, dynamic>{
          'widgetsBaseUrl': 'https://widgets.tabby.ai',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('SdkConfig.fromJson', () {
    test(
        'builds endpointsByKey for default plus per-currency keys, preserving unknown keys',
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
        'EGP': {
          'endpoints': {
            'checkoutApiBaseUrl': 'https://api.tabby.eg',
            'widgetsBaseUrl': 'https://widgets.tabby.eg',
          },
        },
      });

      expect(config.endpointsByKey.keys,
          containsAll(<String>['general', 'SAR', 'EGP']));
      expect(config.endpointsByKey['SAR']!.checkoutApiBaseUrl,
          'https://api.tabby.sa');
      expect(config.endpointsByKey['EGP']!.widgetsBaseUrl,
          'https://widgets.tabby.eg');
      expect(config.endpointsByKey['general']!.checkoutApiBaseUrl,
          'https://api.tabby.ai');
    });

    test(
        'throws FormatException when a per-currency endpoints block is malformed',
        () {
      expect(
        () => SdkConfig.fromJson(<String, dynamic>{
          'general': {
            'endpoints': {
              'checkoutApiBaseUrl': 'https://api.tabby.ai',
              'widgetsBaseUrl': 'https://widgets.tabby.ai',
            },
          },
          'SAR': {
            'endpoints': {
              'checkoutApiBaseUrl': 'https://api.tabby.sa',
            },
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when default key is missing', () {
      expect(
        () => SdkConfig.fromJson(<String, dynamic>{
          'SAR': {
            'endpoints': {
              'checkoutApiBaseUrl': 'https://api.tabby.sa',
              'widgetsBaseUrl': 'https://widgets.tabby.sa',
            },
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('SdkConfig.endpointsFor', () {
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

    test('returns SAR endpoints for Currency.sar when present', () {
      final endpoints = buildConfig().endpointsFor(Currency.sar);
      expect(endpoints.checkoutApiBaseUrl, 'https://api.tabby.sa');
      expect(endpoints.widgetsBaseUrl, 'https://widgets.tabby.sa');
    });

    test('falls back to default endpoints when currency is absent', () {
      final endpoints = buildConfig().endpointsFor(Currency.aed);
      expect(endpoints.checkoutApiBaseUrl, 'https://api.tabby.ai');
      expect(endpoints.widgetsBaseUrl, 'https://widgets.tabby.ai');
    });
  });
}
