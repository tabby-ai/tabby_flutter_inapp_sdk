import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

const tabbyColor = Color.fromRGBO(62, 237, 191, 1);

typedef TabbyCheckoutCompletion = void Function(WebViewResult resultCode);

final options = InAppWebViewGroupOptions(
  crossPlatform: InAppWebViewOptions(
    incognito: true,
  ),
  ios: IOSInAppWebViewOptions(
    applePayAPIEnabled: true,
    useOnNavigationResponse: true,
  ),
);

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

  static void showWebView({
    required BuildContext context,
    required String webUrl,
    required TabbyCheckoutCompletion onResult,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.94,
          child: TabbyWebView(
            webUrl: webUrl,
            onResult: onResult,
          ),
        );
      },
    );
  }
}

class _TabbyWebViewState extends State<TabbyWebView> {
  final GlobalKey webViewKey = GlobalKey();
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_progress < 1) ...[
          LinearProgressIndicator(
            value: _progress,
            color: tabbyColor,
            backgroundColor: Colors.black,
          )
        ],
        Expanded(
          child: InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url: Uri.parse(widget.webUrl)),
            initialOptions: options,
            onProgressChanged:
                (InAppWebViewController controller, int progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
            iosOnNavigationResponse: (controller, response) async {
              final nextUrl = response.response?.url?.toString() ?? '';
              return iosNavigationResponseHandler(
                onResult: widget.onResult,
                nextUrl: nextUrl,
              );
            },
            onWebViewCreated: (controller) async {
              controller.addJavaScriptHandler(
                handlerName: 'tabbyMobileSDK',
                callback: (message) =>
                    javaScriptHandler(message, widget.onResult),
              );
            },
          ),
        ),
      ],
    );
  }
}
