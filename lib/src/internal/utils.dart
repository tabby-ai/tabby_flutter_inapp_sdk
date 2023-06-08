import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tabby_flutter_inapp_sdk/src/internal/fixtures.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

void printError(Object error, StackTrace stackTrace) {
  debugPrint('Exception: $error');
  debugPrint('StackTrace: $stackTrace');
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
  final fullPrice =
      (double.parse(price) / 4).toStringAsFixed(currency.decimals);
  if (lang == Lang.ar) {
    return [
      'أو قسّمها على 4 دفعات شهرية بقيمة ',
      fullPrice,
      ' ${currency.displayName} ',
      'بدون رسوم أو فوائد. ',
      'لمعرفة المزيد'
    ];
  } else {
    return [
      'or 4 interest-free payments of ',
      fullPrice,
      ' ${currency.displayName}',
      '. ',
      'Learn more'
    ];
  }
}

const space = ' ';

List<String> getLocalStringsNonStandard({
  required Currency currency,
  required Lang lang,
}) {
  if (lang == Lang.ar) {
    return [
      'قسّم مشترياتك وادفعها على كيفك. بدون أي فوائد، أو رسوم.',
      space,
      'لمعرفة المزيد'
    ];
  } else {
    return [
      'Split your purchase and pay over time. No interest. No fees.',
      space,
      'Learn more'
    ];
  }
}

String getPrice({
  required String price,
  required Currency currency,
}) {
  final installmentPrice =
      (double.parse(price) / 4).toStringAsFixed(currency.decimals);
  return installmentPrice;
}
