import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tabby_flutter_sdk/tabby_flutter_sdk.dart';

void printError(Object error, StackTrace stackTrace) {
  print('Exception: $error');
  print('StackTrace: $stackTrace');
}

IOSNavigationResponseAction iosNavigationResponseHandler({
  required TabbyCheckoutCompletion onResult,
  required String nextUrl,
}) {
  if (nextUrl.contains(defaultMerchantUrls.cancel)) {
    onResult(WebViewResult.close);
    return IOSNavigationResponseAction.CANCEL;
  }
  if (nextUrl.contains(defaultMerchantUrls.failure)) {
    onResult(WebViewResult.rejected);
    return IOSNavigationResponseAction.CANCEL;
  }
  if (nextUrl.contains(defaultMerchantUrls.success)) {
    onResult(WebViewResult.authorized);
    return IOSNavigationResponseAction.CANCEL;
  }
  return IOSNavigationResponseAction.ALLOW;
}

void javaScriptHandler(
  List<dynamic> message,
  TabbyCheckoutCompletion onResult,
) {
  try {
    final List<dynamic> events = message.first;
    final msg = events.first as String;
    final resultCode = WebViewResult.values.firstWhere(
      (value) => value.name == msg.toLowerCase(),
    );
    onResult(resultCode);
  } catch (e, s) {
    printError(e, s);
  }
}

List<String> getLocalStrings({
  required String price,
  required Currency currency,
  required Lang lang,
}) {
  final fullPrice = double.parse(price).toStringAsFixed(2);
  if (lang == Lang.ar) {
    if (currency == Currency.egp) {
      return [
        'قسّمها على 4 دفعات شهرية بقيمة',
        ' ${currency.name} $fullPrice',
        '. بدون فوائد، بدون أي رسوم. ',
        'لمعرفة المزيد'
      ];
    }
    return [
      ' ﺔﻤﻴﻘﺑ ﺔﻳﺮﻬﺷ تﺎﻌﻓد 4 ﻰﻠﻋ ﺎﻬﻤﺴّﻗ وﺃ',
      ' ${currency.name} $fullPrice',
      '. ',
      'لمعرفة المزيد'
    ];
  } else {
    if (currency == Currency.egp) {
      return [
        '4 payments of ',
        '$fullPrice ${currency.name}',
        '. No interest. No fees. ',
        'Learn more'
      ];
    }
    return [
      'or 4 interest-free payments of ',
      '$fullPrice ${currency.name}',
      '. ',
      'Learn more'
    ];
  }
}
