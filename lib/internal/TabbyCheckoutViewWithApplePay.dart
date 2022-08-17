import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tabby_flutter/internal/TabbySdk.dart';
import 'package:tabby_flutter/models/models.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TabbyCheckoutViewWithApplePay extends StatefulWidget {
  const TabbyCheckoutViewWithApplePay({Key? key}) : super(key: key);

  @override
  State<TabbyCheckoutViewWithApplePay> createState() =>
      _TabbyCheckoutViewWithApplePayState();
}

const tabbyColor = Color.fromRGBO(62, 237, 191, 1);

class _TabbyCheckoutViewWithApplePayState
    extends State<TabbyCheckoutViewWithApplePay> {
  late TabbySession session;
  late TabbyProduct selectedProduct;
  void onResult(WebViewResult resultCode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultCode.name),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    RouteSettings settings = ModalRoute.of(context)!.settings;
    session = (settings.arguments as TabbyCheckoutNavParams).session;
    selectedProduct =
        (settings.arguments as TabbyCheckoutNavParams).selectedProduct;
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedProduct.type.name),
        centerTitle: true,
      ),
      body: Container(
        child: TabbyWebView(
          webUrl: selectedProduct.webUrl,
          onResult: onResult,
        ),
      ),
    );
  }
}

typedef void TabbyCheckoutCompletion(WebViewResult resultCode);

class TabbyWebView extends StatefulWidget {
  final String webUrl;
  final TabbyCheckoutCompletion onResult;

  TabbyWebView({
    Key? key,
    required this.webUrl,
    required this.onResult,
  }) : super(key: key);

  @override
  State<TabbyWebView> createState() => _TabbyWebViewState();
}

InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
  ios: IOSInAppWebViewOptions(
    applePayAPIEnabled: true,
  ),
);

class _TabbyWebViewState extends State<TabbyWebView> {
  final GlobalKey webViewKey = GlobalKey();
  double _progress = 0;
  // InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress,
          color: tabbyColor,
          backgroundColor: Colors.black,
        ),
        Expanded(
          child: InAppWebView(
            key: webViewKey,
            initialUrlRequest:
                URLRequest(url: Uri.parse('http://localhost:3000')),
            initialOptions: options,
            onLoadStart: (InAppWebViewController controller, Uri? url) {
              print('onLoadStart $url');
            },
            onLoadStop: (InAppWebViewController controller, Uri? url) async {
              print('onLoadStop $url');
            },
            onProgressChanged:
                (InAppWebViewController controller, int progress) {
              _progress = progress / 100;
              setState(() {});
            },
            onWebViewCreated: (controller) {
              // _webViewController = controller;
              controller.addJavaScriptHandler(
                handlerName: 'tabbyMobileSDK',
                callback: (message) {
                  try {
                    final List<dynamic> events = message.first;
                    final msg = events.first as String;
                    print("msg :: $msg");
                    final resultCode = WebViewResult.values.firstWhere(
                      (value) => value.name == msg.toLowerCase(),
                    );
                    // widget.onResult(resultCode);
                  } catch (err) {
                    print(err);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
