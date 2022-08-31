import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tabby_flutter/internal/tabby_checkout_view.dart';
import 'package:tabby_flutter/internal/utils.dart';
import 'package:tabby_flutter/models/enums.dart';

class TabbyCheckoutBrowser extends InAppBrowser {
  TabbyCheckoutCompletion? onResult;
  String? baseUrl;

  void onResultBrowser(WebViewResult code) {
    close();
    onResult?.call(code);
  }

  @override
  Future onBrowserCreated() async {
    webViewController.addJavaScriptHandler(
        handlerName: 'tabbyMobileSDK',
        callback: (message) => javaScriptHandler(message, onResultBrowser));
  }

  @override
  Future<IOSNavigationResponseAction?>? iosOnNavigationResponse(
      IOSWKNavigationResponse navigationResponse) async {
    final nextUrl = navigationResponse.response?.url.toString() ?? '';
    print(nextUrl);

    return iosNavigationResponseHandler(
      onResult: onResultBrowser,
      nextUrl: nextUrl,
    );
  }

  @override
  Future onLoadStart(url) async {
    baseUrl = url.toString();
  }

  @override
  Future<NavigationActionPolicy?>? shouldOverrideUrlLoading(
      NavigationAction navigationAction) async {
    print("\n\nOverride ${navigationAction.request.url}\n\n");
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadError(url, code, message) {
    print("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(progress) {
    print('Progress: $progress');
  }

  @override
  void onExit() {
    print('Browser closed!');
    onResult?.call(WebViewResult.close);
  }
}
