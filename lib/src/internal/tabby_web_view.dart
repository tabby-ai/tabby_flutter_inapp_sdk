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

  static Future<void> showWebView({
    required BuildContext context,
    required String webUrl,
    required TabbyCheckoutCompletion onResult,
  }) async {
    await showModalBottomSheet(
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
      builder: (context) {
        return TabbyWebView(
          webUrl: webUrl,
          onResult: onResult,
        );
      },
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
