import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tabby_flutter/internal/fixtures.dart';
import 'package:tabby_flutter/internal/mock.dart';
import 'package:tabby_flutter/internal/tabby_checkout_browser.dart';
import 'package:tabby_flutter/internal/tabby_sdk.dart';
import 'package:tabby_flutter/internal/utils.dart';
import 'package:tabby_flutter/models/enums.dart';
import 'package:tabby_flutter/models/models.dart';

import 'internal/tabby_checkout_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  } else {
    await IOSInAppWebViewController.handlesURLScheme('file://');
  }

  TabbySDK().setup(
    withApiKey: 'pk_test_528adcfa-b906-47b5-9f66-e5cf967e0095',
    environment: Environment.stage,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabby Flutter SDK Demo',
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      locale: const Locale('en', ''),
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
      routes: {
        '/home': (context) => MyHomePage(),
        '/checkout': (context) => const TabbyCheckoutView(),
      },
    );
  }
}

final options = InAppBrowserClassOptions(
  crossPlatform: InAppBrowserOptions(
    hideToolbarTop: false,
    hideUrlBar: true,
    toolbarTopBackgroundColor: Colors.white,
  ),
  ios: IOSInAppBrowserOptions(
    hideToolbarBottom: true,
    presentationStyle: IOSUIModalPresentationStyle.PAGE_SHEET,
    toolbarTopTranslucent: true,
  ),
  inAppWebViewGroupOptions: InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      javaScriptEnabled: true,
      incognito: true,
      useOnLoadResource: true,
    ),
    ios: IOSInAppWebViewOptions(
      applePayAPIEnabled: true,
      useOnNavigationResponse: true,
    ),
  ),
);

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  final browser = TabbyCheckoutBrowser();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _status = 'idle';
  TabbySession? session;

  void _setStatus(String newStatus) {
    setState(() {
      _status = newStatus;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> createSession() async {
    try {
      _setStatus('pending');

      final s = await TabbySDK().createSession(
        TabbyCheckoutPayload(
          merchantCode: 'ae',
          lang: Lang.en,
          payment: mockPayload1,
          merchantUrls: Platform.isIOS ? defaultMerchantUrls : null,
        ),
      );
      setState(() {
        session = s;
      });
      _setStatus('created');
    } catch (e, s) {
      printError(e, s);
      _setStatus('error');
    }
  }

  void openCheckOutPage() {
    Navigator.pushNamed(
      context,
      '/checkout',
      arguments: TabbyCheckoutNavParams(
        selectedProduct: session!.availableProducts.installments!,
      ),
    );
  }

  void openInAppBrowser() {
    // widget.browser.onResult = (resultCode) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(resultCode.name),
    //     ),
    //   );
    // };
    // widget.browser.openUrlRequest(
    //   urlRequest: URLRequest(
    //       url: Uri.parse(session!.availableProducts.installments!.webUrl)),
    //   options: options,
    // );
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag: false,
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.94,
            child: TabbyWebView(
              webUrl: session!.availableProducts.installments!.webUrl,
              onResult: (WebViewResult resultCode) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(resultCode.name),
                  ),
                );
                Navigator.pop(context);
              },
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabby Flutter SDK demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${mockPayload1.amount} ${mockPayload1.currency.name}',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            Text(
              mockPayload1.buyer?.email ?? '',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            Text(
              mockPayload1.buyer?.phone ?? '',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              _status,
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 24),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: session?.availableProducts.installments != null
                        ? openInAppBrowser
                        : null,
                    child: const Text('demo installments')),
                const ElevatedButton(
                    onPressed: null,
                    child: Text('demo credit_card_installments')),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: session == null ? createSession : null,
        tooltip: 'Create',
        child: const Icon(Icons.add),
      ),
    );
  }
}
