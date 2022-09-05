import 'package:flutter/material.dart';
import 'package:tabby_flutter_sdk/tabby_flutter_sdk.dart';

class TabbyCheckoutButton extends StatelessWidget {
  const TabbyCheckoutButton({
    required this.price,
    required this.currency,
    required this.lang,
    required this.onPressed,
    this.borderColor = const Color(0xFFD6DED6),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.textColor = const Color(0xFF292929),
    Key? key,
  }) : super(key: key);
  final String price;
  final Currency currency;
  final Lang lang;
  final Function() onPressed;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final localStrings = getLocalStrings(
      price: price,
      currency: currency,
      lang: lang,
    );
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 720),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
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
                    color: textColor,
                    fontFamily: lang == Lang.ar ? 'Arial' : 'Inter',
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
                    TextSpan(text: localStrings[2]),
                    TextSpan(
                      text: localStrings[3],
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
                image: AssetImage('assets/images/tabby-badge.png',
                    package: 'tabby_flutter_sdk'),
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
