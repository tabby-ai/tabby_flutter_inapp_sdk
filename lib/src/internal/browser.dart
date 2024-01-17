import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

class TabbyChromeSafariBrowser extends ChromeSafariBrowser {
  TabbyChromeSafariBrowser({
    required this.currency,
    required this.lang,
    this.installmentsCount,
  });

  Currency currency;
  Lang lang;
  int? installmentsCount;

  @override
  void onOpened() {
    TabbySDK().logEvent(
      AnalyticsEvent.learnMorePopUpOpened,
      EventProperties(
        currency: currency,
        lang: lang,
        installmentsCount: installmentsCount,
      ),
    );
  }

  @override
  void onClosed() {
    TabbySDK().logEvent(
      AnalyticsEvent.learnMorePopUpClosed,
      EventProperties(
        currency: currency,
        lang: lang,
        installmentsCount: installmentsCount,
      ),
    );
  }
}
