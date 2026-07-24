import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';
import 'package:webview_flutter/webview_flutter.dart';

const tabbyColor = Color.fromRGBO(62, 237, 191, 1);

typedef TabbyCheckoutCompletion = void Function(WebViewResult resultCode);

class TabbyWebView extends StatefulWidget {
  const TabbyWebView({
    required this.webUrl,
    required this.onResult,
    Key? key,
  }) : super(key: key);

  final String webUrl;
  final TabbyCheckoutCompletion onResult;

  @override
  State<TabbyWebView> createState() => _TabbyWebViewState();

  /// Opens Tabby checkout in a modal bottom sheet (callback-style).
  ///
  /// Every checkout event is delivered to [onResult]. The SDK does not close
  /// the sheet — you decide when to dismiss it (typically by calling
  /// `Navigator.pop(context)` inside [onResult]). Use this variant when you
  /// want full control over the sheet lifecycle, e.g. to keep it open after
  /// a `WebViewResult.expired` and load a fresh session.
  ///
  /// If you just want to wait for the checkout outcome, use
  /// [showWebViewAsync] instead.
  static void showWebView({
    required BuildContext context,
    required String webUrl,
    required TabbyCheckoutCompletion onResult,
  }) {
    _showCheckoutSheet(
      context: context,
      builder: (context) {
        return TabbyWebView(
          webUrl: webUrl,
          onResult: onResult,
        );
      },
    );
  }

  /// Opens Tabby checkout in a modal bottom sheet and completes with the
  /// checkout outcome (await-style).
  ///
  /// Unlike [showWebView], the SDK owns the sheet lifecycle: the sheet is
  /// closed automatically as soon as the first checkout result arrives, and
  /// the returned future resolves with that result. Resolves with `null`
  /// when the sheet is dismissed before any result is received (e.g. the
  /// user taps the barrier or navigates back).
  ///
  /// [onResult] is optional here and, when provided, is invoked with the
  /// same result right before the sheet is closed.
  static Future<WebViewResult?> showWebViewAsync({
    required BuildContext context,
    required String webUrl,
    TabbyCheckoutCompletion? onResult,
  }) async {
    WebViewResult? result;
    await _showCheckoutSheet(
      context: context,
      builder: (sheetContext) {
        return TabbyWebView(
          webUrl: webUrl,
          onResult: (resultCode) {
            // Only the first result counts: it closes the sheet, and any
            // late-arriving bridge event must not pop the route below it.
            if (result != null) {
              return;
            }
            result = resultCode;
            onResult?.call(resultCode);
            Navigator.of(sheetContext).pop();
          },
        );
      },
    );
    return result;
  }

  static Future<void> _showCheckoutSheet({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.zero,
        ),
      ),
      builder: builder,
    );
  }
}

extension TabbyPermissionResourceType on WebViewPermissionResourceType {
  static Permission? toAndroidPermission(WebViewPermissionResourceType value) {
    if (value == WebViewPermissionResourceType.camera) {
      return Permission.camera;
    } else if (value == WebViewPermissionResourceType.microphone) {
      return Permission.microphone;
    } else {
      return null;
    }
  }
}

class _TabbyWebViewState extends State<TabbyWebView> {
  final GlobalKey webViewKey = GlobalKey();
  double _progress = 0;
  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    webViewController = createBaseWebViewController((message) {
      javaScriptHandler(message.message, widget.onResult);
    });
    webViewController.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          if (mounted) {
            setState(() {
              _progress = progress / 100;
            });
          }
        },
      ),
    );
    webViewController.loadRequest(Uri.parse(widget.webUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_progress < 1) ...[
          LinearProgressIndicator(
            value: _progress,
            color: tabbyColor,
            backgroundColor: Colors.black,
          ),
        ],
        const SizedBox(width: double.infinity),
        Expanded(
          key: webViewKey,
          child: WebViewWidget(
            controller: webViewController,
          ),
        ),
      ],
    );
  }
}
