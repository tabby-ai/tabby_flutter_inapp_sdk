<goal>
Add sharding support to the Tabby Flutter SDK by replacing hardcoded base URLs with a per-currency endpoint map fetched at SDK initialisation from a new bootstrap configuration endpoint.

The SDK will:
- Call `POST {bootstrapHost}/api/v1/sdk/config` during `setup()` to retrieve a currency-keyed map of endpoints.
- Resolve `checkoutApiBaseUrl` and `widgetsBaseUrl` for each request using the request's `Currency`, falling back to a `default` entry when the currency is not present in the response.
- Handle currencies the SDK has not seen before (any new key returned by the API) without an SDK release.

This unblocks server-side sharding (KSA-residency endpoints today; more shards in the future) for all partner apps consuming the SDK without forcing future SDK releases when shards are added or moved.

Beneficiaries: Tabby backend operations (free to re-shard merchants), partner apps (continue using the SDK transparently after a one-time async-setup migration), and Tabby compliance posture (data-residency routing per currency).
</goal>

<background>
Tech stack: Flutter package, Dart `>=2.15.0 <4.0.0`, single HTTP client (`http: ^1.2.2`), web views via `flutter_inappwebview` and `webview_flutter`. The SDK is a singleton (`TabbySDK()`) initialised once via `setup()`.

Today the SDK has two hardcoded base URLs per environment in `Environment` enum extensions:
- `Environment.host` → `https://api.tabby.ai` (prod) / `https://api.tabby.dev` (staging) — used as the API base URL for `createSession`.
- `Environment.widgetsHost` → `https://widgets.tabby.ai/tabby-promo.html` (prod) / `https://widgets.tabby.dev/tabby-promo.html` (staging) — used as the full widgets URL for `TabbyProductPageSnippet`.

`TabbySDK.setup()` is currently synchronous and stores `_host` and `_widgetsHost` from the chosen `Environment`. `TabbySDK.widgetsBaseUrl` is exposed as a currency-agnostic getter and consumed inside `TabbyProductPageSnippet` to build the widget URL.

The bootstrap endpoint, regardless of currency, is reachable at:
- Production: `https://api.tabby.ai/api/v1/sdk/config`
- Staging: `https://api.tabby.dev/api/v1/sdk/config`

Sample response (production):
```json
{
  "default": {
    "endpoints": {
      "checkoutApiBaseUrl": "https://api.tabby.ai",
      "webCheckoutBaseUrl": "https://checkout.tabby.ai",
      "widgetsBaseUrl": "https://widgets.tabby.ai",
      "analyticsBaseUrl": "https://dp-event-collector.tabby.ai"
    }
  },
  "SAR": {
    "endpoints": {
      "checkoutApiBaseUrl": "https://api.tabby.sa",
      "webCheckoutBaseUrl": "https://checkout.tabby.sa",
      "widgetsBaseUrl": "https://widgets.tabby.sa",
      "analyticsBaseUrl": "https://dp-event-collector.tabby.sa"
    }
  }
}
```

Sample response (staging):
```json
{
  "default": {
    "endpoints": {
      "checkoutApiBaseUrl": "https://api.tabby.dev",
      "webCheckoutBaseUrl": "https://checkout.tabby.dev",
      "widgetsBaseUrl": "https://widgets.tabby.dev",
      "analyticsBaseUrl": "https://dp-event-collector.tabby.dev"
    }
  },
  "SAR": {
    "endpoints": {
      "checkoutApiBaseUrl": "https://api.tabbysa.dev",
      "webCheckoutBaseUrl": "https://checkout.tabbysa.dev",
      "widgetsBaseUrl": "https://widgets.tabbysa.dev",
      "analyticsBaseUrl": "https://dp-event-collector.tabbysa.dev"
    }
  }
}
```

Top-level keys are `default` plus zero or more uppercase currency codes. Today `Currency` enum exposes `aed, sar, kwd, bhd, qar` with `displayName` returning the matching uppercase string (e.g. `SAR`).

Files to examine:
- `@lib/src/internal/tabby_sdk.dart` — the singleton, `setup()`, `createSession()`, `widgetsBaseUrl` getter.
- `@lib/src/internal/tabby_product_page_snippet.dart` — consumes `TabbySDK().widgetsBaseUrl` to build the widget URL with currency in the query string.
- `@lib/src/models/enums.dart` — `Environment` and `Currency` enums.
- `@lib/src/models/models.dart` — `TabbyCheckoutPayload` (line 560) and nested `Payment.currency` (line 355).
- `@lib/src/internal/headers.dart` — `getVersionHeader()` returns `'Flutter/<version>'` and is sent as `X-SDK-Version`.
- `@pubspec.yaml` — current version `1.12.0` will be bumped to a new major.
- `@lib/tabby_flutter_inapp_sdk.dart` — public exports.
</background>

<user_flows>
Primary flow (happy path):
1. App calls `await TabbySDK().setup(withApiKey: ..., environment: Environment.production)`.
2. SDK derives the bootstrap host from `environment` (`https://api.tabby.ai` for prod, `https://api.tabby.dev` for staging).
3. SDK sends `POST {bootstrapHost}/api/v1/sdk/config` with headers `Content-Type: application/json`, `X-SDK-Version: Flutter/<version>`, `Authorization: Bearer <apiKey>`, body `{}`.
4. SDK parses the response into an `SdkConfig` object containing a map of `currencyKey → SdkEndpoints { checkoutApiBaseUrl, widgetsBaseUrl }` plus a required `default` entry.
5. SDK stores the parsed `SdkConfig` and the API key in the singleton; `setup()` resolves.
6. Partner code calls `TabbySDK().createSession(payload)` where `payload.payment.currency == Currency.sar`. SDK resolves endpoints by `'SAR' → SAR.endpoints`, then `POST {SAR.checkoutApiBaseUrl}/api/v2/checkout`.
7. Partner mounts `TabbyProductPageSnippet(currency: Currency.sar, ...)`. SDK resolves `SAR.widgetsBaseUrl`, appends `/tabby-promo.html?...query`, loads the URL.

Alternative flow — currency missing from config:
- Partner calls `createSession` with `Currency.aed`. Config response only contains `default` and `SAR`. SDK falls back to `default.endpoints` and routes to `https://api.tabby.ai/api/v2/checkout`.
- Same fallback applies to `TabbyProductPageSnippet` for non-sharded currencies.

Alternative flow — new currency added server-side:
- Backend deploys new top-level key (e.g. `EGP`) with corresponding endpoints. SDK already running on partner devices receives this on next cold start; lookup by `currency.displayName` succeeds without code changes. (Note: until the `Currency` enum is extended in a future release, the SDK's own request models can't carry that currency — but the resolution logic is forward-compatible.)

Error flows:
- Bootstrap fetch fails (network error, non-200 status, malformed JSON, missing `default` entry): `setup()` throws a typed exception (`SdkConfigException` or reuse of `ServerException` — see `<implementation>`). No fallback to embedded URLs. No retry. SDK remains uninitialised.
- `createSession` or `TabbyProductPageSnippet` invoked before a successful `setup()`: same "TabbySDK did not setup" error path as today, with a clear message instructing the caller to `await TabbySDK().setup(...)`.
- Successful `setup()` followed by `createSession` with a `Currency` value not in config and no `default` present: treated as a malformed config — should have been caught at `setup()` time. If it slips through, throw a clear runtime error (defence-in-depth).

Entry/exit:
- Entry: partner app's `main()` (or initialisation code) calls `await TabbySDK().setup(...)` once.
- Exit: partner app uses `createSession`, `TabbyProductPageSnippet`, and existing SDK widgets normally.
</user_flows>

<requirements>

**Functional:**

1. Add a new bootstrap call, exposed on the existing `TabbyWithRemoteDataSource` interface as `Future<SdkConfig> getSdkConfig()`. It performs `POST {bootstrapHost}/api/v1/sdk/config`. The bootstrap host is derived from the `Environment` passed to `setup()`. Headers: `Accept: application/json`, `Content-Type: application/json`, `X-SDK-Version: <getVersionHeader()>`, `Authorization: Bearer <apiKey>`. Body: `{}`.

2. Convert `TabbySDK.setup()` to `Future<void>`. Inside, after validating `withApiKey`, store the api key, call `getSdkConfig()`, and store the resulting `SdkConfig` in the singleton. The API surface change is intentional and breaking — partners must `await` setup.

3. Introduce two model classes in `lib/src/models/models.dart` (or a new `lib/src/models/sdk_config.dart` exported from `lib/tabby_flutter_inapp_sdk.dart`):
   - `SdkEndpoints { String checkoutApiBaseUrl; String widgetsBaseUrl; factory SdkEndpoints.fromJson(Map<String, dynamic>); }`. Only these two fields are parsed; other JSON fields (`webCheckoutBaseUrl`, `analyticsBaseUrl`, future additions) are ignored.
   - `SdkConfig { Map<String, SdkEndpoints> endpointsByKey; factory SdkConfig.fromJson(Map<String, dynamic>); SdkEndpoints endpointsFor(Currency currency); }`. The map's keys are exactly the JSON keys (`'default'`, `'SAR'`, etc.). `endpointsFor` looks up `currency.displayName`; if absent, returns the `'default'` entry.

4. `SdkConfig.fromJson` MUST throw `FormatException` (or a wrapping `SdkConfigException`) if the `'default'` key is missing or its `endpoints` cannot be parsed, since the SDK relies on `default` for fallback. Per-currency entries that fail to parse a required field MUST also fail the whole parse — partial success is not allowed.

5. `TabbySDK.createSession(payload)` MUST resolve the API base URL via `_config.endpointsFor(payload.payment.currency).checkoutApiBaseUrl` and use it to build the `POST {base}/api/v2/checkout` URL. The previously stored `_host` field is removed.

6. `TabbyProductPageSnippet` MUST resolve `widgetsBaseUrl` per-instance from `widget.currency` via the SDK singleton (e.g. a new `TabbySDK().widgetsBaseUrlFor(Currency)` method). The current currency-agnostic `TabbySDK().widgetsBaseUrl` getter MUST be removed (breaking change inside the SDK; the snippet is the only consumer and is updated together). The widget URL composition in `initState` and `didUpdateWidget` MUST be updated to append `/tabby-promo.html` to the resolved base before the existing query string.

7. The `Environment.widgetsHost` extension getter MUST be removed (it is no longer the source of truth and would mislead future contributors). The `Environment.host` getter MAY be kept and renamed to `bootstrapApiBaseUrl` (or kept with a doc comment noting it is bootstrap-only) — the resolved spec choice is renaming for clarity. Update the rename across the codebase.

8. `pubspec.yaml` `version` MUST be bumped to `2.0.0`. `getVersionHeader()` in `lib/src/internal/headers.dart` MUST be updated to return `'Flutter/2.0.0'` so the new version is reported in `X-SDK-Version` (including the bootstrap call).

9. Public exports in `lib/tabby_flutter_inapp_sdk.dart` MUST include the new `SdkConfig` and `SdkEndpoints` types so partners can introspect the loaded config if needed.

10. The example app under `example/` MUST be updated to `await TabbySDK().setup(...)` in its initialisation path and continue to compile and run.

11. The README MUST be updated with: (a) the breaking-change note for `setup()`, (b) the bootstrap behaviour, (c) the migration snippet from `setup()` to `await setup()`, (d) the version bump.

12. The CHANGELOG MUST gain a `2.0.0` entry summarising the breaking API change and the new sharding behaviour.

**Error Handling:**

13. If the bootstrap HTTP call returns any non-200 status, `setup()` MUST throw `ServerException` (existing type) wrapped or extended with the status code so callers can distinguish auth failures from outages if needed. Bodies should be `debugPrint`ed (matching existing logging style in `createSession`) to aid integration debugging.

14. If the bootstrap HTTP call throws (e.g. `SocketException`, `TimeoutException`), the exception MUST propagate from `setup()` unchanged so callers can detect it. No internal retry.

15. If the response body is not valid JSON or the parsed `SdkConfig` is malformed (missing `default`, missing required URL fields), `setup()` MUST throw `FormatException` (or a typed `SdkConfigException` wrapping it). Same propagation contract as above.

16. `createSession` and `TabbyProductPageSnippet` MUST throw a clear "TabbySDK did not setup. Call `await TabbySDK().setup(...)` in main.dart" error if invoked before a successful `setup()`. Update the existing `checkSetup()` message to reflect the async migration.

**Edge Cases:**

17. Repeated `setup()` calls: a second call with the same arguments MUST re-fetch and replace the stored `SdkConfig` (no-op suppression NOT required). A second call with different arguments MUST also re-fetch and replace. This matches the existing `late final` semantics being relaxed to `late` (mutable) — document the change.

18. Bootstrap response containing only `default` (no per-currency keys) MUST work: `endpointsFor` always returns `default` for any currency.

19. Bootstrap response containing keys for currencies the SDK does not yet know (e.g. `EGP`): the keys MUST be retained in the `SdkConfig.endpointsByKey` map and accessible if a future SDK release adds the corresponding `Currency` enum value. They MUST NOT cause parse failure.

20. Bootstrap response with extra fields inside `endpoints` (e.g. `webCheckoutBaseUrl`, `analyticsBaseUrl`, future additions): MUST be ignored without warning.

21. `widgetsBaseUrl` returned by the API may or may not include a trailing slash. URL composition in the snippet MUST handle both shapes by ensuring exactly one `/` between the base and `tabby-promo.html`.

**Validation:**

22. `withApiKey` empty-string check stays as-is and continues to throw before any network call. (No bootstrap attempt for an empty API key.)

23. `Currency` resolution is case-sensitive against `Currency.displayName` (uppercase). The SDK MUST NOT lowercase, trim, or transform keys before lookup; the API contract is uppercase ISO-style codes.
</requirements>

<boundaries>
Edge cases:
- Empty top-level config object (no `default`, no currencies): treat as malformed → throw `FormatException` from `SdkConfig.fromJson`.
- `default.endpoints` missing one of `checkoutApiBaseUrl` / `widgetsBaseUrl`: malformed → throw.
- `default.endpoints` with one of the two URLs being an empty string or invalid URI: throw `FormatException` with the offending field name. This catches obvious operator mistakes early.
- A per-currency entry exists but its `endpoints` is missing a required field: throw (defence-in-depth — operator error must not silently degrade to `default`).
- `Currency` enum extended in a future release before backend adds its key: `endpointsFor(newCurrency)` returns `default` — current contract holds.

Error scenarios:
- Bootstrap timeout / DNS failure: `setup()` throws; partner UI must surface or retry.
- Bootstrap 401/403 (bad api key on the new endpoint): same treatment as any non-200 — throw `ServerException` with the status code.
- Bootstrap returns 200 with non-JSON body: `FormatException`.

Limits:
- No client-side rate limiting on `setup()`. Repeated calls re-fetch every time.
- No request timeout is set today on `http.post`; this spec does NOT introduce one (out of scope). Document the gap in the SDK's ticketing system if not already tracked.
</boundaries>

<implementation>

**Files to create:**

1. `lib/src/models/sdk_config.dart` — new file containing `SdkEndpoints` and `SdkConfig` classes with `fromJson` factories and `endpointsFor(Currency)` resolver. Optional but recommended to keep `models.dart` from growing further.
2. `test/sdk_config_test.dart` — unit tests for parse + resolution (see `<validation>`).
3. `test/tabby_sdk_test.dart` — async-setup + `createSession` URL routing tests using a fake `http.Client` (see `<validation>`).
4. `test/tabby_product_page_snippet_test.dart` — widget test verifying URL composition under different currencies and on currency change.

**Files to modify:**

5. `lib/src/internal/tabby_sdk.dart`:
   - Replace `_host` and `_widgetsHost` with `late SdkConfig _config`.
   - Add `Future<SdkConfig> getSdkConfig()` to `TabbyWithRemoteDataSource` and implement on `TabbySDK`. The implementation MUST inject the http client via an optional constructor / setter parameter (`http.Client client = const _DefaultClient()` or expose a setter `@visibleForTesting set client(http.Client c)`) so tests can substitute a fake client without monkey-patching globals.
   - Convert `setup()` to `Future<void>` and await `getSdkConfig()`.
   - Add `String widgetsBaseUrlFor(Currency currency)` returning `_config.endpointsFor(currency).widgetsBaseUrl`.
   - Remove the existing `String get widgetsBaseUrl`.
   - Update `createSession` to resolve `_config.endpointsFor(payload.payment.currency).checkoutApiBaseUrl` and build the URL from it.
   - Update `checkSetup()` and its error message to reference `await setup`.

6. `lib/src/models/enums.dart`:
   - Remove `EnvironmentExt.widgetsHost`.
   - Rename `EnvironmentExt.host` → `bootstrapApiBaseUrl` (or add a doc comment on the existing name making clear it is bootstrap-only). Recommend the rename for clarity; update all references.
   - Keep all other enums untouched.

7. `lib/src/internal/tabby_product_page_snippet.dart`:
   - Compute `final base = TabbySDK().widgetsBaseUrlFor(widget.currency);` then build `final address = '${_joinPath(base, 'tabby-promo.html')}?...';` where `_joinPath` ensures exactly one `/` between segments. Apply in both `initState` and `didUpdateWidget`.

8. `lib/src/internal/headers.dart` — bump version string to `'Flutter/2.0.0'`.

9. `pubspec.yaml` — bump `version: 1.12.0` → `version: 2.0.0`. Do not change the SDK constraint in this change.

10. `lib/tabby_flutter_inapp_sdk.dart` — export `./src/models/sdk_config.dart` (after creating the file).

11. `README.md` — update setup snippet to `await TabbySDK().setup(...)`, add breaking-change note and migration guidance.

12. `CHANGELOG.md` — add `## 2.0.0` entry.

13. `example/lib/main.dart` (and any other example entry points) — update to `await TabbySDK().setup(...)`.

**Patterns and libraries to use:**

- Continue using `package:http/http.dart` directly. Do not introduce a new HTTP client abstraction in this change.
- Match the existing `debugPrint(...)` logging style for both success (status code) and failure (response body) of the bootstrap call.
- Keep `Uuid` import unchanged; bootstrap does not need a request id (current `createSession` does not send one either).
- Reuse `getVersionHeader()` for the `X-SDK-Version` header on the bootstrap call.
- The bootstrap request body is empty JSON `{}` (mirrors the curl in the task input which has no `-d` body but does set `Content-Type: application/json`). If integration testing reveals the backend rejects an empty body, switch to no body and remove the `Content-Type` header — flag this during implementation, do not pre-emptively over-engineer.
- For `_joinPath`, use `Uri.resolve` semantics or a small helper:
  ```dart
  String _joinPath(String base, String segment) {
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    return '$b/$segment';
  }
  ```

**Testability seams (must be designed in, not retrofitted):**

- `TabbySDK` MUST accept an injectable `http.Client`. Two acceptable shapes:
  - Add a private constructor that takes a `Client` parameter, plus a `@visibleForTesting` factory or setter for tests; OR
  - Add a `@visibleForTesting` setter `set httpClient(http.Client c)` and a default field initialised to `http.Client()`.
  Either way, tests must be able to substitute a fake client without reflection or global mutation.
- `TabbyProductPageSnippet` already takes `currency` as a parameter. No new injection needed for its widget tests; `TabbySDK()` singleton should be primed in `setUp()` via a test-only helper that bypasses the real network call (e.g. `@visibleForTesting void primeConfigForTest(SdkConfig c)`).
- `SdkConfig` parsing must be a pure function (input: `Map<String, dynamic>`; output: `SdkConfig` or thrown `FormatException`). No I/O, no logging, no globals.

**What to avoid and the reason why:**

- Do NOT add fallback to the old hardcoded URLs on bootstrap failure. The user explicitly chose hard-fail to avoid silently routing to a non-sharded host.
- Do NOT persist the config to disk. The user chose in-memory caching; persistence adds invalidation complexity that is not needed today.
- Do NOT keep the legacy `widgetsBaseUrl` getter as a "compatibility shim". It would route currency-agnostically and silently produce wrong URLs for sharded currencies.
- Do NOT introduce a request-timeout for the bootstrap call in this change. The current SDK uses no timeouts anywhere; introducing one only at bootstrap creates inconsistent behaviour. Track separately.
- Do NOT add retry logic. The user explicitly chose hard-fail.
- Do NOT add new dependencies. `http` and `package:uuid` already cover the need.
- Do NOT lowercase or transform currency keys in `endpointsFor`. The API contract is uppercase; transforming hides backend bugs.
- Do NOT couple `SdkConfig` parsing to the `Currency` enum. The map should keep raw string keys so that newly-deployed currencies survive an SDK that has not yet added the enum case.
</implementation>

<validation>

**Baseline automated coverage:**

- Logic: `SdkConfig` and `SdkEndpoints` parse + resolution covered by unit tests (no Flutter binding required — pure Dart tests).
- UI behavior: `TabbyProductPageSnippet` URL composition covered by widget tests under the resolved currency variants.
- Critical journey: `TabbySDK.setup()` → `createSession()` end-to-end covered by an integration-style test using a fake `http.Client` that asserts (a) the bootstrap request shape and (b) the per-currency routing of the subsequent checkout call.

**TDD discipline (vertical-slice RED → GREEN → REFACTOR):**

Apply test-first, one slice at a time. Suggested ordering — write each test, watch it fail, implement minimum to pass, refactor:

1. RED: `SdkEndpoints.fromJson` extracts `checkoutApiBaseUrl` and `widgetsBaseUrl`; ignores extra fields.
2. RED: `SdkEndpoints.fromJson` throws `FormatException` when a required URL is missing/empty.
3. RED: `SdkConfig.fromJson` builds a map with `default` plus per-currency keys.
4. RED: `SdkConfig.fromJson` throws when `default` is missing.
5. RED: `SdkConfig.fromJson` throws when a per-currency `endpoints` is malformed.
6. RED: `SdkConfig.endpointsFor(Currency.sar)` returns SAR endpoints when present.
7. RED: `SdkConfig.endpointsFor(Currency.aed)` falls back to `default` when AED is absent.
8. RED: `SdkConfig.fromJson` retains unknown keys (e.g. `EGP`) in `endpointsByKey` without throwing.
9. RED: `TabbySDK.setup()` issues `POST <bootstrapHost>/api/v1/sdk/config` with the expected headers and body when given the fake client.
10. RED: `TabbySDK.setup()` throws `ServerException` when the fake client returns 500.
11. RED: `TabbySDK.setup()` throws `FormatException` when the fake client returns malformed JSON.
12. RED: `TabbySDK.setup()` throws `FormatException` when the fake client returns a body missing `default`.
13. RED: `TabbySDK.createSession()` after a successful `setup()` POSTs to `<SAR.checkoutApiBaseUrl>/api/v2/checkout` when the payload's `payment.currency == Currency.sar`.
14. RED: `TabbySDK.createSession()` POSTs to `<default.checkoutApiBaseUrl>/api/v2/checkout` when the payload's `payment.currency` is not in the config.
15. RED: `TabbyProductPageSnippet` with `Currency.sar` loads a URL beginning with `<SAR.widgetsBaseUrl>/tabby-promo.html?` and the existing query string.
16. RED: `TabbyProductPageSnippet` with a non-sharded currency loads a URL beginning with `<default.widgetsBaseUrl>/tabby-promo.html?`.
17. RED: `TabbyProductPageSnippet` re-resolves the URL when `currency` changes via `didUpdateWidget`.
18. RED: `TabbyProductPageSnippet` and `TabbySDK.createSession` throw the "did not setup" error if the singleton has not been primed.

For each slice: write the test, confirm it fails for the expected reason, write the minimum code, confirm green, refactor only when the slice is green. Do not batch slices.

**Mocking policy:**

- Prefer fakes over mocks. Use a hand-rolled `class _FakeHttpClient extends http.BaseClient` (or `MockClient` from `package:http/testing.dart`) that returns canned responses keyed by URL. The `http` package already ships `MockClient`; prefer it.
- Do NOT mock `SdkConfig` or `SdkEndpoints`; they are pure data and should be exercised directly.
- Do NOT mock `TabbySDK`; tests that need a primed singleton should use the `@visibleForTesting` seam (`primeConfigForTest`) to skip the network call.
- For widget tests: use the same primed-singleton seam plus `tester.pumpWidget` with a real `WebViewWidget` substitute is not necessary — assert the URL passed into `webViewController.loadRequest` is correct. If today's snippet does not expose the URL for assertion, tests MUST inject a fake `WebViewController` via a test-only constructor parameter; if that is too invasive, validate URL construction by extracting a pure function `_buildSnippetUrl(SdkEndpoints endpoints, Currency, ...) → String` and unit-testing it directly.

**Robot/journey coverage:**

The SDK is a library, not an app. There are no cross-screen user journeys to robot-test inside this package. The "critical journey" coverage requirement is satisfied by the integration-style test in step 13 (setup → createSession with sharded routing). Justified deviation from the robot-driven default: the package has no example journey worth robot-testing in this change, and the example app already exercises the live flow during manual verification. Do not add a robot test in this change; flag in the spec audit if reviewers disagree.

**Manual verification (run before declaring done):**

- `flutter pub get` succeeds.
- `flutter analyze` passes with no new warnings.
- `flutter test` passes all new and existing tests.
- The example app under `example/` builds for both iOS and Android and successfully creates a checkout session with `Currency.sar` and `Currency.aed`. Verify in the network log that `createSession` for SAR hits the SAR-specific host (e.g. `api.tabby.sa`) and AED hits the default host.
- Bootstrap call is observable in the network log on app start with `X-SDK-Version: Flutter/2.0.0`.

**Test data:**

- Fixture for prod-style response, staging-style response, response with only `default`, response with extra unknown currency key, response with malformed `default`, response with empty `widgetsBaseUrl` — committed under `test/fixtures/sdk_config/*.json`.
</validation>

<done_when>

1. `pubspec.yaml` reports `version: 2.0.0`; `getVersionHeader()` returns `'Flutter/2.0.0'`.
2. `TabbySDK.setup` returns `Future<void>` and performs the bootstrap call before resolving.
3. `SdkConfig` and `SdkEndpoints` exist, are exported from the package barrel, and are covered by passing unit tests for all parse + resolve cases enumerated in `<validation>` slices 1–8.
4. `TabbySDK.createSession` routes to the correct `checkoutApiBaseUrl` based on `payload.payment.currency`, with passing tests for the sharded and fallback cases (slices 13–14).
5. `TabbyProductPageSnippet` builds widget URLs from the per-currency `widgetsBaseUrl`, with passing tests for sharded, fallback, and currency-change cases (slices 15–17).
6. `Environment.widgetsHost` is removed; `TabbySDK.widgetsBaseUrl` getter is removed; `Environment.host` is renamed (or doc-commented) to reflect bootstrap-only purpose; all in-tree call sites compile.
7. Bootstrap failure paths (HTTP non-200, network throw, malformed JSON, missing `default`) all surface as exceptions out of `setup()`, with passing tests for each (slices 10–12).
8. README and CHANGELOG are updated; example app awaits setup and runs.
9. `flutter analyze` is clean; `flutter test` is green.
10. Manual verification of SAR-sharded and AED-default routing in the example app on iOS and Android is recorded in the PR description.
</done_when>
