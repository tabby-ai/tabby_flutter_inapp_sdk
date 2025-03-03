import 'package:flutter/material.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void openNewSessionPage() {
    Navigator.pushNamed(context, '/new_session');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabby Flutter SDK demo'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TabbyPresentationSnippet(
                price: '100.00',
                currency: Currency.sar,
                lang: Lang.en,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: TabbyCheckoutSnippet(
                price: '1100',
                currency: Currency.aed,
                lang: Lang.en,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                ),
                onPressed: openNewSessionPage,
                child: const Text('Test Checkout Session'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
