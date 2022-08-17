import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tabby_flutter/internal/TabbySdk.dart';
import 'package:tabby_flutter/models/models.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TabbyCheckoutView extends StatefulWidget {
  const TabbyCheckoutView({Key? key}) : super(key: key);

  @override
  State<TabbyCheckoutView> createState() => _TabbyCheckoutViewState();
}

class _TabbyCheckoutViewState extends State<TabbyCheckoutView> {
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

  const TabbyWebView({
    Key? key,
    required this.webUrl,
    required this.onResult,
  }) : super(key: key);

  @override
  State<TabbyWebView> createState() => _TabbyWebViewState();
}

const tabbyColor = Color.fromRGBO(62, 237, 191, 1);

class _TabbyWebViewState extends State<TabbyWebView> {
  double _progress = 0;
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
          child: WebView(
            initialUrl: widget.webUrl,
            javascriptMode: JavascriptMode.unrestricted,
            onProgress: (progress) {
              _progress = progress / 100;
              setState(() {});
            },
            onWebViewCreated: (controller) {
              print(controller.currentUrl());
            },
            // javascriptChannels: <JavascriptChannel>{
            //   JavascriptChannel(
            //     name: 'tabbyMobileSDK',
            //     onMessageReceived: (JavascriptMessage message) async {
            //       if (kDebugMode) {
            //         print('From JS: ${message.message}');
            //       }
            //       try {
            //         final resultCode = WebViewResult.values.firstWhere(
            //           (value) => value.name == message.message.toLowerCase(),
            //         );
            //         widget.onResult(resultCode);
            //       } catch (err) {
            //         print(err);
            //       }
            //     },
            //   ),
            // },
          ),
        ),
      ],
    );
  }
}
