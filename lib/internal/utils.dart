import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tabby_flutter/internal/fixtures.dart';
import 'package:tabby_flutter/internal/tabby_checkout_view.dart';
import 'package:tabby_flutter/models/enums.dart';

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
