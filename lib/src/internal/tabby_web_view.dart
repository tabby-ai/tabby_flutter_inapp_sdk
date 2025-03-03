import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

const tabbyColor = Color.fromRGBO(62, 237, 191, 1);

typedef TabbyCheckoutCompletion = void Function(WebViewResult resultCode);

final settings = InAppWebViewSettings(
  applePayAPIEnabled: true,
  useOnNavigationResponse: true,
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

extension TabbyPermissionResourceType on PermissionResourceType {
  static Permission? toAndroidPermission(PermissionResourceType value) {
    if (value == PermissionResourceType.CAMERA) {
      return Permission.camera;
    } else if (value == PermissionResourceType.MICROPHONE) {
      return Permission.microphone;
    } else {
      return null;
    }
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
            initialUrlRequest:
                URLRequest(url: WebUri.uri(Uri.parse(widget.webUrl))),
            initialSettings: settings,
            onPermissionRequest: (controller, permissionRequest) async {
              final resources = permissionRequest.resources;
              final permissions = Platform.isAndroid
                  ? resources
                      .map((r) {
                        final permission =
                            TabbyPermissionResourceType.toAndroidPermission(r);
                        return permission;
                      })
                      .whereType<Permission>()
                      .toList()
                  : [Permission.camera, Permission.microphone];
              if (permissions.isEmpty) {
                return PermissionResponse(
                  action: PermissionResponseAction.GRANT,
                  resources: resources,
                );
              }
              final statuses = await permissions.request();
              final isGranted = statuses.values.every((s) => s.isGranted);
              return PermissionResponse(
                action: isGranted
                    ? PermissionResponseAction.GRANT
                    : PermissionResponseAction.DENY,
                resources: resources,
              );
            },
            onProgressChanged: (
              InAppWebViewController controller,
              int progress,
            ) {
              setState(() {
                _progress = progress / 100;
              });
            },
            onNavigationResponse: (controller, response) async {
              final nextUrl = response.response?.url?.toString() ?? '';
              return navigationResponseHandler(
                onResult: widget.onResult,
                nextUrl: nextUrl,
              );
            },
            onWebViewCreated: (controller) async {
              controller.addJavaScriptHandler(
                handlerName: 'tabbyMobileSDK',
                callback: (message) => javaScriptHandler(
                  message,
                  widget.onResult,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
