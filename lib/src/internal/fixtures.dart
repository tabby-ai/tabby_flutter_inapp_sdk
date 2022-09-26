import 'package:tabby_flutter_sdk/tabby_flutter_sdk.dart';

final defaultMerchantUrls = MerchantUrls(
  success: 'https://checkout.tabby.dev/success.html',
  failure: 'https://checkout.tabby.dev/failure.html',
  cancel: 'https://checkout.tabby.dev/cancel.html',
);

final snippetWebUrls = <Lang, String>{
  Lang.en: 'https://checkout.tabby.ai/promos/product-page/installments/en/',
  Lang.ar: 'https://checkout.tabby.ai/promos/product-page/installments/ar/',
};
