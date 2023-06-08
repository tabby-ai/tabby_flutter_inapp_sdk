import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

const checkoutSnippetLocalesEn = {
  'useAnyCard': 'Use any card.',
  'today': 'Today',
  'in1Month': 'In 1 month',
  'in2Months': 'In 2 months',
  'in3Months': 'In 3 months',
};

const checkoutSnippetLocalesAr = {
  'useAnyCard': 'استخدم أي بطاقة.',
  'today': 'اليوم',
  'in1Month': 'بعد شهر',
  'in2Months': 'بعد شهرين',
  'in3Months': 'بعد ثلاثة أشهر',
};

class AppLocales {
  AppLocales._();

  /// Provides instance [AppLocales].
  factory AppLocales.instance() => _instance;

  static final AppLocales _instance = AppLocales._();

  Map<String, String> checkoutSnippet(Lang lang) {
    switch (lang) {
      case Lang.en:
        return checkoutSnippetLocalesEn;
      default:
        return checkoutSnippetLocalesAr;
    }
  }
}
