# 2.0.0
- ❗ Breaking change: `TabbySDK().setup(...)` is now `Future<void>` and must be awaited. Partners must update their integration (this is really an easy todo).
- 🆕 SDK now bootstraps sharded base URLs from `POST /api/v1/sdk/config` during `setup()`. Per-request hosts are resolved by `Currency` (e.g. `Currency.sar` is routed to KSA-resident endpoints) with a `default` fallback.
- New public types: `SdkConfig`, `SdkEndpoints`.
- Removed `TabbySDK().widgetsBaseUrl` getter (was currency-agnostic). Use `widgetsBaseUrlFor(Currency)` if you need direct access to the resolved widgets base URL.
- Removed `Environment.widgetsHost`; renamed `Environment.host` → `Environment.bootstrapApiBaseUrl` (used only for the bootstrap call).
- The bootstrap call is merchant-agnostic and does not include the partner `Authorization` header; subsequent calls (e.g. `createSession`) continue to send `Authorization: Bearer <apiKey>`.
- Hard-fail on bootstrap failure: `setup()` propagates `ServerException` for non-200 responses, `FormatException` for malformed payloads, and transport errors are passed through unchanged. No retry, no fallback to embedded URLs, no on-disk caching.

# 1.11.0
- [Android] Resolved issue of user sometimes unable to attach files during the checkout

# 1.10.1
- Minor fix: removing `setOnConsoleMessage` as not needed

# 1.10.0
- Getting rid of deprecated `TabbyCheckoutSnippet`
- Getting rid of deprecated `TabbyPresentationSnippetNonStantard`
- ❗️ Breaking change: Getting rid of deprecated `TabbyPresentationSnippet`. Please use `TabbyProductPageSnippet` instead - it's an easy migration
- 🆕 Adding new web-view based dynamic `TabbyProductPageSnippet`
- Lowering code dependency on `flutter_inappwebview` package, using `webview_flutter` instead

# 1.9.0
- Updating example app to the latest Flutter version
- Migrating `TabbyWebView` from using `flutter_inappwebview` to more stable `webview_flutter`

# 1.8.1
- Fixed typo in package description

# 1.8.0
- `TabbyWebView` is now in charge of managing permissions requests asked by the web page. The `TabbyWebView` will ask for permissions only when needed
- ❗ Important: please refer to Readme.md and update your integration to handle the new `TabbyWebView` behavior
- Example app reworked to demonstrate the new `TabbyWebView` behavior 

# 1.7.0
- Added `SessionStatus`
- ❗ Important: The `TabbySession.status` can now be either `SessionStatus.rejected` or `SessionStatus.created`. Some customers may be rejected immediately after a session creation. You need to handle this scenario before opening `TabbyWebView`.
For reference, check the example implementation in `example/lib/pages/home_page.dart`, specifically the functions: `void openInAppBrowser() {...}` and `void openCheckOutPage() {...}`
- Added `TabbySDK.rejectionTextEn` and `TabbySDK.rejectionTextAr`

# 1.6.2

- `TabbyCheckoutSnippet` reworked to use png images

# 1.6.1

- `Environment.stage` removed from SDK internals

# 1.6.0

- ❗️Breaking change: update required fields for `TabbySDK().createSession(TabbyCheckoutPayload payload) {...}`
- flutter_inappwebview updated dependency

# 1.5.0

- No-breaking change built in widgets usage staticsics

# 1.4.2

- Fix TabbyPresentationSnippet not displaying updated price

# 1.4.1

- Fix Bahrain currency

# 1.4.0

- Removed credit_card_installments
- Removed monthly_billing

# 1.3.0

- Added TabbyCheckoutSnippet
- Added TabbyPresentationSnippetNonStantard

# 1.2.0

- Qatar supported, Egypt deprecated.

# 1.1.2

- Updated domains for checkout result pages

# 1.1.1

- Integration docs updated

# 1.1.0

- Added internal webview params for proper analytics

# 1.0.2

- Fixed WebView dependency

# 1.0.1

- Fixed optional params of Payment

# 1.0.0

- Webview
- Bottom Sheet page
