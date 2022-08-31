import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tabby_flutter/internal/utils.dart';
import 'package:tabby_flutter/models/enums.dart';
import 'package:tabby_flutter/models/models.dart';

class TabbyCheckoutView extends StatefulWidget {
  const TabbyCheckoutView({Key? key}) : super(key: key);

  @override
  State<TabbyCheckoutView> createState() => _TabbyCheckoutViewState();
}

const tabbyColor = Color.fromRGBO(62, 237, 191, 1);

class _TabbyCheckoutViewState extends State<TabbyCheckoutView> {
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
    final settings = ModalRoute.of(context)!.settings;
    selectedProduct =
        (settings.arguments as TabbyCheckoutNavParams).selectedProduct;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tabby Checkout'),
      ),
      body: TabbyWebView(
        webUrl: selectedProduct.webUrl,
        onResult: onResult,
      ),
    );
  }
}

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
}

InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
  crossPlatform: InAppWebViewOptions(
    incognito: true,
  ),
  ios: IOSInAppWebViewOptions(
    applePayAPIEnabled: true,
    useOnNavigationResponse: true,
  ),
);

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
