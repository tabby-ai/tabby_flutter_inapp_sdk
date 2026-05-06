## Overview

Replace hardcoded base URLs with per-currency endpoints fetched at `setup()` from `POST /api/v1/sdk/config`. Async setup, in-memory cache, hard-fail.

**Spec**: `ai_specs/sdk-config-sharded-base-urls.md` (read this file for full requirements)

## Context

- **Structure**: layer-first under `lib/src/internal/` (singleton, snippet, headers, webview) and `lib/src/models/` (data classes, enums).
- **State management**: none — package is a singleton SDK with `package:http` for I/O.
- **Reference implementations**:
  - `lib/src/internal/tabby_sdk.dart` — singleton + `setup()` + `createSession()` HTTP pattern.
  - `lib/src/internal/tabby_product_page_snippet.dart` — widget consumes `TabbySDK().widgetsBaseUrl` to build URL.
  - `lib/src/models/enums.dart` — `Environment.host`, `Environment.widgetsHost`, `Currency.displayName` (uppercase ISO).
  - `lib/src/models/models.dart` — `TabbyCheckoutPayload.payment.currency` carries the per-call currency.
- **Test infra**: only placeholder `test/tabby_flutter_sdk_test.dart`. Use `package:http/testing.dart` `MockClient`. No additional deps needed.
- **Assumptions/Gaps**:
  - Bootstrap body is `{}` per curl-with-no-body interpretation; if backend rejects, drop body and `Content-Type` (flag during impl).
  - `Environment.host` renamed to `bootstrapApiBaseUrl` for clarity; `Environment.widgetsHost` removed.
  - Singleton's `late final` fields relax to `late` so re-`setup()` is allowed (per spec req #17).

## Plan

### Phase 1: Bootstrap + per-currency checkout routing (vertical slice) — COMPLETE

- **Goal**: `await setup()` fetches sharded config; `createSession` routes by `payload.payment.currency`.
- [x] `lib/src/models/sdk_config.dart` - new `SdkEndpoints` (`checkoutApiBaseUrl`, `widgetsBaseUrl`) + `SdkConfig` (raw-string-keyed map, `endpointsFor(Currency)` with `default` fallback) with `fromJson` factories.
- [x] `lib/tabby_flutter_inapp_sdk.dart` - export new file.
- [x] `lib/src/models/enums.dart` - rename `EnvironmentExt.host` → `bootstrapApiBaseUrl`; remove `widgetsHost`.
- [x] `lib/src/internal/tabby_sdk.dart` - implement bootstrap fetch as a private `_fetchSdkConfig()` on `TabbySDK` (NOT exposed on the public `TabbyWithRemoteDataSource` interface — partners should only see partner-facing entry points); inject `http.Client` (visible-for-testing seam); convert `setup` to `Future<void>`; replace `_host`/`_widgetsHost` with `late SdkConfig _config`; route `createSession` via `_config.endpointsFor(payload.payment.currency).checkoutApiBaseUrl`; update `checkSetup` message.
- [x] `lib/src/internal/tabby_sdk.dart` - add `@visibleForTesting void primeConfigForTest(SdkConfig)` and `set client(http.Client)` seams (named `httpClientForTesting`).
- [x] TDD: `SdkEndpoints.fromJson` extracts only `checkoutApiBaseUrl` + `widgetsBaseUrl`; ignores extras.
- [x] TDD: `SdkEndpoints.fromJson` throws `FormatException` when a required URL is missing/empty.
- [x] TDD: `SdkConfig.fromJson` builds map with `default` plus per-currency keys; preserves unknown keys (e.g. `EGP`).
- [x] TDD: `SdkConfig.fromJson` throws when `default` missing or any per-currency `endpoints` malformed.
- [x] TDD: `SdkConfig.endpointsFor(Currency.sar)` returns SAR endpoints when present.
- [x] TDD: `SdkConfig.endpointsFor(Currency.aed)` falls back to `default` when AED absent.
- [x] TDD: `setup()` issues `POST <bootstrapApiBaseUrl>/api/v1/sdk/config` with `X-SDK-Version: Flutter/<v>`, `Content-Type: application/json`, body `{}`, and **no** `Authorization` header (the bootstrap endpoint is merchant-agnostic). Asserted via `MockClient`.
- [x] TDD (critical journey): primed `setup()` + `createSession` with `payment.currency = sar` → POSTs to `<SAR.checkoutApiBaseUrl>/api/v2/checkout`; with `aed` (absent) → POSTs to `<default.checkoutApiBaseUrl>/api/v2/checkout`.
- [x] Verify: `flutter analyze` && `flutter test` (passed; analyze exit 0 with 3 stylistic line-length infos in tests).

Note: `example/lib/pages/api_key.dart` `host` → `bootstrapApiBaseUrl` reference was also updated here to keep `flutter analyze` green; the example app's broader async-setup migration remains in Phase 3.

### Phase 2: Snippet currency-aware widget URL — COMPLETE

- **Goal**: `TabbyProductPageSnippet` builds URL from `widgetsBaseUrlFor(currency)`; old getter removed.
- [x] `lib/src/internal/tabby_sdk.dart` - add `String widgetsBaseUrlFor(Currency)`; remove `String get widgetsBaseUrl`. (done in Phase 1 commit; verified by Phase 2 tests).
- [x] `lib/src/internal/tabby_product_page_snippet.dart` - extract pure top-level `buildSnippetUrl({widgetsBaseUrl, price, currency, publicKey, merchantCode, lang, installmentsCount})` joining `widgetsBaseUrl` + `/tabby-promo.html?...` with single-slash trim; called from `initState` and `didUpdateWidget` via `TabbySDK().widgetsBaseUrlFor(widget.currency)`. Function exported via the public barrel.
- [x] TDD: `buildSnippetUrl` produces `<base>/tabby-promo.html?...` whether `base` ends with `/` or not (no double slash).
- [x] TDD: composition of `TabbySDK().widgetsBaseUrlFor(currency)` + `buildSnippetUrl` resolves SAR currency to SAR widgets host and falls back to default for non-sharded currencies (covers the snippet's per-currency selection contract).
- [~] TDD: `didUpdateWidget` re-resolves URL when `currency` changes — NOT covered by a widget test. Rationale per spec/plan: `WebViewController.loadRequest` cannot be cleanly intercepted in widget tests without a more invasive seam. Currency-driven re-composition is verified through the pure `buildSnippetUrl` (returns different URLs for different currencies); the `didUpdateWidget` branch in the snippet is correct-by-construction once it calls `_buildAddress()`. Documented as a deliberate gap.
- [x] TDD: `createSession` and `widgetsBaseUrlFor` throw clear "did not setup. Call `await TabbySDK().setup(...)`" if singleton un-primed (added `@visibleForTesting resetForTest()` seam).
- [x] Verify: `flutter analyze` && `flutter test` (passed; analyze exit 0 with 4 stylistic line-length infos in test files).

### Phase 3: Failure modes, release packaging, example migration

- **Goal**: Hard-fail paths covered; v2.0.0 released; example app + docs migrated.
- [ ] `lib/src/internal/tabby_sdk.dart` - ensure non-200 → `ServerException` (with status code logged via `debugPrint`); malformed JSON / missing `default` → propagated `FormatException`; transport throw propagates unchanged.
- [ ] `lib/src/internal/headers.dart` - bump `getVersionHeader` → `'Flutter/2.0.0'`.
- [ ] `pubspec.yaml` - bump `version: 1.12.0` → `2.0.0`.
- [ ] `example/lib/pages/api_key.dart` - make `openNextPage` async; `await TabbySDK().setup(...)`; surface bootstrap failures (snackbar/dialog) before navigating.
- [ ] `README.md` - update setup snippet to `await`; add v2.0.0 breaking-change + migration note; describe sharded routing.
- [ ] `CHANGELOG.md` - add `## 2.0.0` entry: async `setup()`, sharded base URLs via `/api/v1/sdk/config`, removed `widgetsBaseUrl` getter, removed `Environment.widgetsHost`, renamed `Environment.host`.
- [ ] `test/fixtures/sdk_config/*.json` - prod, staging, default-only, with-unknown-currency, malformed-default, empty-widgets-url.
- [ ] TDD: `setup()` with fake client returning 500 → `ServerException`.
- [ ] TDD: `setup()` with non-JSON body → `FormatException`.
- [ ] TDD: `setup()` with body missing `default` → `FormatException`.
- [ ] TDD: `setup()` with `SocketException`-throwing client → exception propagates.
- [ ] TDD: empty `withApiKey` short-circuits before any HTTP call (no bootstrap fired).
- [ ] TDD: repeated `setup()` with different env replaces stored config (asserted via subsequent `createSession` URL).
- [ ] Manual: example app on iOS + Android — checkout with `Currency.sar` hits `api.tabby.sa`; with `Currency.aed` hits `api.tabby.ai`; `X-SDK-Version: Flutter/2.0.0` visible on bootstrap.
- [ ] Verify: `flutter analyze` && `flutter test` && example app runs on iOS + Android.

## Risks / Out of scope

- **Risks**:
  - Breaking `setup()` signature affects every partner integrator; v2.0.0 changelog + README migration must be unmissable.
  - Bootstrap body `{}` is an assumption; backend may require empty body — verify with one live call before shipping.
  - No request timeout introduced; bootstrap can hang indefinitely on bad networks. Acceptable per spec but flag-for-followup.
- **Out of scope**:
  - Disk persistence / TTL / refresh of config (in-memory only).
  - Retry / fallback to embedded URLs (hard-fail).
  - Consuming `webCheckoutBaseUrl` / `analyticsBaseUrl` (parsed only as much as required — i.e. ignored).
  - Adding new entries to the `Currency` enum (handled in a future SDK release when needed).
  - Introducing HTTP timeouts SDK-wide.
