import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS/macOS features.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void printError(Object error, StackTrace stackTrace) {
  debugPrint('Exception: $error');
  debugPrint('StackTrace: $stackTrace');
}

void javaScriptHandler(
  String message,
  TabbyCheckoutCompletion onResult,
) {
  final results = WebViewResult.values
      .where(
        (value) => value.name == message.toLowerCase(),
      )
      .toList();
  if (results.isEmpty) {
    return;
  }

  final resultCode = results.first;
  onResult(resultCode);
}

List<String> getLocalStrings({
  required String price,
  required Currency currency,
  required Lang lang,
}) {
  final fullPrice =
      (double.parse(price) / 4).toStringAsFixed(currency.decimals);
  if (lang == Lang.ar) {
    return [
      'أو قسّمها على 4 دفعات شهرية بقيمة ',
      fullPrice,
      ' ${currency.displayName} ',
      'بدون رسوم أو فوائد. ',
      'لمعرفة المزيد'
    ];
  } else {
    return [
      'or 4 interest-free payments of ',
      fullPrice,
      ' ${currency.displayName}',
      '. ',
      'Learn more'
    ];
  }
}

const space = ' ';

List<String> getLocalStringsNonStandard({
  required Currency currency,
  required Lang lang,
}) {
  if (lang == Lang.ar) {
    return [
      'قسّم مشترياتك وادفعها على كيفك. بدون أي فوائد، أو رسوم.',
      space,
      'لمعرفة المزيد'
    ];
  } else {
    return [
      'Split your purchase and pay over time. No interest. No fees.',
      space,
      'Learn more'
    ];
  }
}

const tabbyRejectionTextEn =
    // ignore: lines_longer_than_80_chars
    'Sorry, Tabby is unable to approve this purchase. Please use an alternative payment method for your order.';
const tabbyRejectionTextAr =
    // ignore: lines_longer_than_80_chars
    'نأسف، تابي غير قادرة على الموافقة على هذه العملية. الرجاء استخدام طريقة دفع أخرى';

String getPrice({
  required String price,
  required Currency currency,
}) {
  final installmentPrice =
      (double.parse(price) / 4).toStringAsFixed(currency.decimals);
  return installmentPrice;
}

Future<void> showTabbyLearnMore({
  required BuildContext context,
  required String url,
  required Lang lang,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.zero),
    ),
    builder: (ctx) => Directionality(
      textDirection: lang == Lang.ar ? TextDirection.rtl : TextDirection.ltr,
      child: _TabbyLearnMoreView(url: url),
    ),
  );
}

class _TabbyLearnMoreView extends StatefulWidget {
  const _TabbyLearnMoreView({required this.url});

  final String url;

  @override
  State<_TabbyLearnMoreView> createState() => _TabbyLearnMoreViewState();
}

class _TabbyLearnMoreViewState extends State<_TabbyLearnMoreView> {
  late final WebViewController controller;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    controller = createBaseWebViewController((_) {})
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() => _progress = progress / 100);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: Row(
            children: [
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        if (_progress < 1)
          LinearProgressIndicator(
            value: _progress,
            color: tabbyColor,
            backgroundColor: Colors.transparent,
          ),
        Expanded(
          child: WebViewWidget(controller: controller),
        ),
      ],
    );
  }
}

Future<List<String>> _androidFilePicker(FileSelectorParams params) async {
  if (params.acceptTypes.any((type) => type.contains('image'))) {
    final picker = image_picker.ImagePicker();
    final photo =
        await picker.pickImage(source: image_picker.ImageSource.gallery);

    if (photo == null) {
      return [];
    }

    final imageData = await photo.readAsBytes();
    final decodedImage = image.decodeImage(imageData)!;
    final scaledImage = image.copyResize(decodedImage, width: 500);
    final jpg = image.encodeJpg(scaledImage, quality: 90);

    final filePath = (await getTemporaryDirectory()).uri.resolve(
          './image_${DateTime.now().microsecondsSinceEpoch}.jpg',
        );
    final file = await File.fromUri(filePath).create(recursive: true);
    await file.writeAsBytes(jpg, flush: true);

    return [file.uri.toString()];
  }

  return [];
}

WebViewController createBaseWebViewController(
  void Function(JavaScriptMessage) bridgeMessagesHandler,
) {
  late final PlatformWebViewControllerCreationParams params;
  if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    params = WebKitWebViewControllerCreationParams(
      allowsInlineMediaPlayback: true,
      mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    );
  } else {
    params = const PlatformWebViewControllerCreationParams();
  }
  final controller = WebViewController.fromPlatformCreationParams(
    params,
    onPermissionRequest: (request) async {
      final resources = request.platform.types.toList();
      if (resources.isEmpty) {
        return;
      }

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
      final statuses = await permissions.request();
      final isGranted = statuses.values.every((s) => s.isGranted);
      final future = isGranted ? request.grant : request.deny;
      await future();
    },
  )
    ..setBackgroundColor(Colors.transparent)
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..addJavaScriptChannel(
      TabbySDK.jsBridgeName,
      onMessageReceived: (message) {
        if (kDebugMode) {
          log(
            'Got message from JS '
            '[${TabbySDK.jsBridgeName}]: '
            '${message.message}',
          );
        }
        bridgeMessagesHandler(message);
      },
    );
  if (controller.platform is AndroidWebViewController) {
    (controller.platform as AndroidWebViewController)
      ..setMediaPlaybackRequiresUserGesture(false)
      ..setOnShowFileSelector(
        (params) async {
          return _androidFilePicker(params);
        },
      );
  }
  return controller;
}
