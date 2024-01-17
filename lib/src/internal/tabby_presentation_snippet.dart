// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tabby_flutter_inapp_sdk/src/internal/browser.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

import 'fixtures.dart';

class TabbyPresentationSnippet extends StatefulWidget {
  const TabbyPresentationSnippet({
    required this.price,
    required this.currency,
    required this.lang,
    this.borderColor = const Color(0xFFD6DED6),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.textColor = const Color(0xFF292929),
    Key? key,
  }) : super(key: key);
  final String price;
  final Currency currency;
  final Lang lang;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;

  @override
  State<TabbyPresentationSnippet> createState() =>
      _TabbyPresentationSnippetState();
}

class _TabbyPresentationSnippetState extends State<TabbyPresentationSnippet> {
  late final TabbyChromeSafariBrowser _browser;

  @override
  void initState() {
    TabbySDK().logEvent(
      AnalyticsEvent.snipperCardRendered,
      EventProperties(
        currency: widget.currency,
        lang: widget.lang,
        installmentsCount: 4,
      ),
    );
    _browser = TabbyChromeSafariBrowser(
      currency: widget.currency,
      lang: widget.lang,
      installmentsCount: 4,
    );
    super.initState();
  }

  void openWebBrowser() {
    TabbySDK().logEvent(
      AnalyticsEvent.learnMoreClicked,
      EventProperties(
        currency: widget.currency,
        lang: widget.lang,
        installmentsCount: 4,
      ),
    );
    _browser.open(
      url: Uri.parse(
        '${snippetWebUrls[widget.lang]}'
        '?price=${widget.price}&currency=${widget.currency.displayName}$sdkQuery',
      ),
      options: ChromeSafariBrowserClassOptions(
        android: AndroidChromeCustomTabsOptions(
            shareState: CustomTabsShareState.SHARE_STATE_OFF),
        ios: IOSSafariOptions(
          presentationStyle: IOSUIModalPresentationStyle.POPOVER,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localStrings = getLocalStrings(
      price: widget.price,
      currency: widget.currency,
      lang: widget.lang,
    );
    return GestureDetector(
      onTap: openWebBrowser,
      child: Container(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 720),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: Border.all(
            color: widget.borderColor,
            width: 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: localStrings[0],
                  style: TextStyle(
                    color: widget.textColor,
                    fontFamily: widget.lang == Lang.ar ? 'Arial' : 'Inter',
                    fontSize: 15,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: localStrings[1],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: localStrings[2],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: localStrings[3]),
                    TextSpan(
                      text: localStrings[4],
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsetsDirectional.only(start: 16),
              child: Image(
                image: AssetImage(
                  'assets/images/tabby-badge.png',
                  package: 'tabby_flutter_inapp_sdk',
                ),
                width: 70,
                height: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
