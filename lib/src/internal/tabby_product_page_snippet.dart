import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';
import 'package:webview_flutter/webview_flutter.dart';

String buildSnippetUrl({
  required String widgetsBaseUrl,
  required double price,
  required Currency currency,
  required String publicKey,
  required String merchantCode,
  required Lang lang,
  required int installmentsCount,
}) {
  final trimmed = widgetsBaseUrl.endsWith('/')
      ? widgetsBaseUrl.substring(0, widgetsBaseUrl.length - 1)
      : widgetsBaseUrl;
  return '$trimmed/tabby-promo.html'
      '?price=$price'
      '&currency=${currency.displayName}'
      '&publicKey=$publicKey'
      '&merchantCode=$merchantCode'
      '&lang=${lang.displayName}'
      '&installmentsCount=$installmentsCount';
}

class TabbyProductPageSnippet extends StatefulWidget {
  const TabbyProductPageSnippet({
    required this.price,
    required this.currency,
    required this.lang,
    required this.merchantCode,
    required this.apiKey,
    this.installmentsCount = 4,
    Key? key,
  }) : super(key: key);
  final double price;
  final Currency currency;
  final Lang lang;
  final String merchantCode;
  final String apiKey;
  final int installmentsCount;

  @override
  State<TabbyProductPageSnippet> createState() =>
      _TabbyProductPageSnippetState();
}

class _TabbyProductPageSnippetState extends State<TabbyProductPageSnippet> {
  double height = 98;
  late final WebViewController webViewController;

  void messageHandler(JavaScriptMessage message) {
    final json = jsonDecode(message.message) as Map<String, dynamic>;
    final type = JSEventTypeMapper.fromDto(json['type']);
    if (type == null) {
      return;
    }
    if (type == JSEventType.onChangeDimensions) {
      final event = DimentionsChangeEvent.fromJson(json);
      final dimentions = event.data;
      setState(() {
        height = dimentions.height;
      });
    }
    if (type == JSEventType.onLearnMoreClicked) {
      final event = LearnMoreClickedEvent.fromJson(json);
      final params = event.data;
      final url = event.url;
      final browser = ChromeSafariBrowser();
      final initializationData = InitializationData(data: params);
      final fullUrl =
          '$url&${initializationData.type}=${initializationData.data}';
      final uri = Uri.parse(fullUrl);
      final webUri = WebUri.uri(uri);
      browser.open(url: webUri);
    }
  }

  String _buildAddress() => buildSnippetUrl(
        widgetsBaseUrl: TabbySDK().widgetsBaseUrlFor(widget.currency),
        price: widget.price,
        currency: widget.currency,
        publicKey: widget.apiKey,
        merchantCode: widget.merchantCode,
        lang: widget.lang,
        installmentsCount: widget.installmentsCount,
      );

  @override
  void initState() {
    final uri = Uri.parse(_buildAddress());
    webViewController = createBaseWebViewController(messageHandler);
    webViewController.loadRequest(uri);
    super.initState();
  }

  @override
  void didUpdateWidget(TabbyProductPageSnippet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.price != widget.price ||
        oldWidget.currency != widget.currency ||
        oldWidget.lang != widget.lang ||
        oldWidget.merchantCode != widget.merchantCode ||
        oldWidget.apiKey != widget.apiKey ||
        oldWidget.installmentsCount != widget.installmentsCount) {
      final uri = Uri.parse(_buildAddress());
      webViewController.loadRequest(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
        maxHeight: height,
      ),
      child: WebViewWidget(
        controller: webViewController,
      ),
    );
  }
}
