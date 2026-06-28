# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

SwiftStanApp is a non-sandboxed **macOS app** that surfaces SwiftStan commands as **App Intents** (invocable from Shortcuts / Siri / Spotlight). macOS 14+; Swift 6. It is built as an **Xcode project** (not an SPM package); a Debug build phase copies the `.app` to `/Applications`.

It is one of three independent projects:
- [`SwiftStan`](../SwiftStan) — the library doing the real work.
- [`SwiftStanServer`](../SwiftStanServer) — a separate app hosting an OpenAPI/Hummingbird HTTP server over the library.
- `SwiftStanApp` (this) — the App Intents front end.

## Architecture

The app is a thin **HTTP client** of `SwiftStanServer`. It has no compile-time dependency on `SwiftStan` or `SwiftStanServer`; the shared contract is `openapi.yaml` (kept byte-identical to the server's canonical copy).

- `SwiftStanAppApp.swift` — `@main` App; calls `SwiftStanShortcuts.updateAppShortcutParameters()` in `init()` to register shortcuts on every launch.
- `ContentView.swift` — minimal GUI: a single `TextField` bound to `@AppStorage("serverURL")`.
- `ServerSettings.swift` — `serverURL()`: UserDefaults `"serverURL"` → default `http://127.0.0.1:8080`.
- `StanClient.swift` — builds the OpenAPI-generated `Client` over `URLSessionTransport` with a 900 s timeout (sampling can take many minutes).
- `openapi.yaml` — canonical OpenAPI spec, copied from SwiftStanServer. The build plugin generates `Client` types from this at compile time.
- `openapi-generator-config.yaml` — `generate: [types, client]`.
- `Intents/` — 13 `AppIntent`s plus supporting types, all calling the generated client:
  - `CompileModelIntent` — `POST /v1/compile` (model, force, install)
  - `SampleModelIntent` — `POST /v1/sample` (model, nosummary)
  - `RunUlamPipelineIntent` — `POST /v1/ulam` (model, force)
  - `GenerateStanCodeIntent` — `POST /v1/stancode` (model)
  - `OptimizeModelIntent` — `POST /v1/optimize` (model)
  - `PathfinderIntent` — `POST /v1/pathfinder` (model)
  - `LaplaceIntent` — `POST /v1/laplace` (model)
  - `GeneratedQuantitiesIntent` — `POST /v1/generated_quantities` (model)
  - `StansummaryIntent` — `POST /v1/stansummary` (model)
  - `Csv2JsonIntent` — `POST /v1/csv2json` (model)
  - `StanToAlistIntent` — `POST /v1/stan2alist` (model, force)
  - `Alist2DslIntent` — `POST /v1/alist2dsl` (model)
  - `RuninfoIntent` — `POST /v1/runinfo` (model)
  - `StanIntentError` — thrown when the server returns a non-empty `error` field.
  - `SwiftStanShortcuts` — `AppShortcutsProvider` registering 10 of the intents with phrases / short titles / SF Symbols.

Every `perform()` calls `StanClient.make()`, awaits the response, checks `result.error`, and either throws `StanIntentError.failed(result.error)` or returns `IntentDialog(result.status)`.

- `SwiftStanApp.entitlements` — sandbox disabled (`com.apple.security.app-sandbox = false`); Hardened Runtime on.

## Decoupling invariant

SwiftStanApp must have **no build/source dependency** on `SwiftStanServer` or `SwiftStan`. The only link to the server is HTTP at runtime via `serverURL`. `openapi.yaml` is a shared *specification*, copied (not referenced) — keep it byte-identical to the server's canonical copy.

## Key constraints

- macOS 14+; Swift 6. Xcode project (not SPM). Debug builds copy to `/Applications`.
- Bundle id `com.goedman.SwiftStanApp`; category developer-tools.
- App Intents `perform()` can make async network calls — complete the network call before any interactive prompt (a foregrounded confirmation can tear down a URLSession started in the background).
- The OpenAPI generator build plugin requires `openapi.yaml` and `openapi-generator-config.yaml` to be in the target's source folder and listed in the Run Build Tool Plug-ins build phase.
