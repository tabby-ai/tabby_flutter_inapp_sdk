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
    final amountText = '${widget.currency.displayName} $installmentPrice';

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
                CheckoutSnippetCell(
                  index: 1,
                  localeStrings: localeStrings,
                  amountText: amountText,
                ),
                CheckoutSnippetCell(
                  index: 2,
                  localeStrings: localeStrings,
                  amountText: amountText,
                ),
                CheckoutSnippetCell(
                  index: 3,
                  localeStrings: localeStrings,
                  amountText: amountText,
                ),
                CheckoutSnippetCell(
                  index: 4,
                  localeStrings: localeStrings,
                  amountText: amountText,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class CheckoutSnippetCell extends StatelessWidget {
  const CheckoutSnippetCell({
    required this.index,
    required this.localeStrings,
    required this.amountText,
    Key? key,
  }) : super(key: key);

  final List<String> localeStrings;
  final String amountText;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CheckoutSnippetImage(index: index),
          gap,
          CheckoutWhenText(index: index, localeStrings: localeStrings),
          gap,
          CheckoutSnippetAmountText(amount: amountText),
        ],
      ),
    );
  }
}

class CheckoutWhenText extends StatelessWidget {
  const CheckoutWhenText({
    required this.index,
    required this.localeStrings,
    Key? key,
  }) : super(key: key);

  final List<String> localeStrings;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Text(
      localeStrings[index],
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class CheckoutSnippetImage extends StatelessWidget {
  const CheckoutSnippetImage({
    required this.index,
    Key? key,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Image(
        image: AssetImage(
          'assets/images/r$index.jpg',
          package: 'tabby_flutter_inapp_sdk',
        ),
        width: 40,
        height: 40,
      ),
    );
  }
}

class CheckoutSnippetAmountText extends StatelessWidget {
  const CheckoutSnippetAmountText({
    required this.amount,
    Key? key,
  }) : super(key: key);
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Text(
      amount,
      style: TextStyle(
        fontSize: 11,
        color: dividerColor,
      ),
    );
  }
}
