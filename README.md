# Tabby Flutter SDK

Use the Tabby checkout in your Flutter app.

## Requirements

- Dart sdk: `">=2.14.0 <3.0.0"`
- Flutter: `">=2.5.0"`
- Android: `minSdkVersion 17` and add support for `androidx` (see [AndroidX Migration](https://flutter.dev/docs/development/androidx-migration) to migrate an existing app)
- iOS: `--ios-language swift`, Xcode version `>= 12`

## Getting started

Add `flutter_inappwebview` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

## On iOS please make sure you've added in your `Info.plist`

Feel free to edit descriptions according to your App

```xml
<key>NSCameraUsageDescription</key>
<string>This allows Tabby to take a photo</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This allows Tabby to select a photo</string>
```

## On Android please make sure you've added in your `AndroidManifest.xml`

```xml
    .....
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />


    <application ....>
        <!-- Add a provider to be able to upload a user id photo -->
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.flutter_inappwebview.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/provider_paths" />
        </provider>
     .....
```

## Usage

1. You should initialise Tabby SDK. We recommend to do it in `main.dart` file:

```dart
  TabbySDK().setup(
    withApiKey: '', // Put here your Api key, given by the Tabby integrations team
  );
```

2. Create checkout session:

```dart
  final mockPayload = Payment(
    amount: '340',
    currency: Currency.aed,
    buyer: Buyer(
      email: 'id.card.success@tabby.ai',
      phone: '500000001',
      name: 'Yazan Khalid',
      dob: '2019-08-24',
    ),
    buyerHistory: BuyerHistory(
      loyaltyLevel: 0,
      registeredSince: '2019-08-24T14:15:22Z',
      wishlistCount: 0,
    ),
    shippingAddress: const ShippingAddress(
      city: 'string',
      address: 'string',
      zip: 'string',
    ),
    order: Order(referenceId: 'id123', items: [
      OrderItem(
        title: 'Jersey',
        description: 'Jersey',
        quantity: 1,
        unitPrice: '10.00',
        referenceId: 'uuid',
        productUrl: 'http://example.com',
        category: 'clothes',
      )
    ]),
    orderHistory: [
      OrderHistoryItem(
        purchasedAt: '2019-08-24T14:15:22Z',
        amount: '10.00',
        paymentMethod: OrderHistoryItemPaymentMethod.card,
        status: OrderHistoryItemStatus.newOne,
      )
    ],
  );

  final session = await TabbySDK().createSession(TabbyCheckoutPayload(
    merchantCode: 'ae', // pay attention, this might be different for different merchants
    lang: Lang.en,
    payment: mockPayload,
  ));
```

3. Open on app browser to show checkout:

```dart
  void openInAppBrowser() {
    TabbyWebView.showWebView(
      context: context,
      webUrl: session.availableProducts.installments.webUrl,
      onResult: (WebViewResult resultCode) {
        print(resultCode.name);
        // TODO: Process resultCode
      },
    );
  }
```

Also you can use TabbyWebView as inline widget on your page:

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabby Checkout'),
      ),
      body: TabbyWebView(
        webUrl: session.availableProducts.installments.webUrl,
        onResult: (WebViewResult resultCode) {
          print(resultCode.name);
          // TODO: Process resultCode
        },
      ),
    );
  }
```

### TabbyPresentationSnippet

<p>
  <img src="./doc/snippet_en.png" width="375" title="english button">
  <img src="./doc/snippet_ar.png" width="375" title="arabic button">
</p>

For show `TabbyPresentationSnippet` you can add as inline widget on your page:

```dart
  TabbyPresentationSnippet(
    price: mockPayload.amount,
    currency: mockPayload.currency,
    lang: lang,
  )
```

## Example

You can also check the [example project](https://github.com/tabby-ai/tabby-flutter-sdk/tree/master/example).
