import 'package:flutter/material.dart';
import 'package:tabby_flutter_inapp_sdk/src/resources/colors.dart';
import 'package:tabby_flutter_inapp_sdk/src/resources/locales.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

class TabbyCheckoutSnippet extends StatefulWidget {
  const TabbyCheckoutSnippet({
    required this.currency,
    required this.price,
    required this.lang,
    Key? key,
  }) : super(key: key);

  final String price;
  final Currency currency;
  final Lang lang;

  @override
  State<TabbyCheckoutSnippet> createState() => _TabbyCheckoutSnippetState();
}

const gap = SizedBox(height: 6);

class _TabbyCheckoutSnippetState extends State<TabbyCheckoutSnippet> {
  late List<String> localeStrings;

  @override
  void initState() {
    localeStrings =
        AppLocales.instance().checkoutSnippet(widget.lang).values.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final installmentPrice =
        getPrice(price: widget.price, currency: widget.currency);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            localeStrings[0],
            style: TextStyle(
              fontSize: 14,
              color: dividerColor,
            ),
          ),
        ),
        gap,
        gap,
        Stack(
          children: [
            Positioned(
              top: 20,
              left: 16 + 20,
              right: 16 + 20,
              child: Container(
                height: 1,
                color: dividerColor,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: const Image(
                          image: AssetImage(
                            'assets/images/r1.jpg',
                            package: 'tabby_flutter_inapp_sdk',
                          ),
                          width: 40,
                          height: 40,
                        ),
                      ),
                      gap,
                      Text(
                        localeStrings[1],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      gap,
                      Text(
                        '${widget.currency.name} $installmentPrice',
                        style: TextStyle(
                          fontSize: 11,
                          color: dividerColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: const Image(
                          image: AssetImage(
                            'assets/images/r2.jpg',
                            package: 'tabby_flutter_inapp_sdk',
                          ),
                          width: 40,
                          height: 40,
                        ),
                      ),
                      gap,
                      Text(
                        localeStrings[2],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      gap,
                      Text(
                        '${widget.currency.name} $installmentPrice',
                        style: TextStyle(
                          fontSize: 11,
                          color: dividerColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: const Image(
                          image: AssetImage(
                            'assets/images/r3.jpg',
                            package: 'tabby_flutter_inapp_sdk',
                          ),
                          width: 40,
                          height: 40,
                        ),
                      ),
                      gap,
                      Text(
                        localeStrings[3],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      gap,
                      Text(
                        '${widget.currency.name} $installmentPrice',
                        style: TextStyle(
                          fontSize: 11,
                          color: dividerColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: const Image(
                          image: AssetImage(
                            'assets/images/r4.jpg',
                            package: 'tabby_flutter_inapp_sdk',
                          ),
                          width: 40,
                          height: 40,
                        ),
                      ),
                      gap,
                      Text(
                        localeStrings[4],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      gap,
                      Text(
                        '${widget.currency.name} $installmentPrice',
                        style: TextStyle(
                          fontSize: 11,
                          color: dividerColor,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }
}
