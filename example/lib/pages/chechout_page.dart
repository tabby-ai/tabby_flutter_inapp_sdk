import 'package:flutter/material.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

class TabbyCheckoutNavParams {
  TabbyCheckoutNavParams({
    required this.selectedProduct,
  });

  final TabbyProduct selectedProduct;
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late TabbyProduct selectedProduct;

  void onResult(WebViewResult resultCode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultCode.name),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ModalRoute.of(context)!.settings;
    selectedProduct =
        (settings.arguments as TabbyCheckoutNavParams).selectedProduct;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tabby Checkout'),
      ),
      body: TabbyWebView(
        webUrl: selectedProduct.webUrl,
        onResult: onResult,
      ),
    );
  }
}
