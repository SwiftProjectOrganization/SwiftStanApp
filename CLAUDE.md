# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

SwiftStanApp is a non-sandboxed **macOS and iOS app** that surfaces cmdstan commands in both a GUI app and as **App Intents** (invocable from Shortcuts / Siri / Spotlight) on MacOS 27+; Swift 6. It is built as an **Xcode project**.

It is one of three independent projects:
- [`SwiftStanLibrary`](https://github.com/SwiftProjectsOrganization/SwiftStanLibrary) — the library doing the real work.
- [`SwiftStanServer`](../SwiftStanServer) — a separate app hosting an OpenAPI/Hummingbird HTTP server over the library.
- `SwiftStanApp` (this) — the front end app.

The complete SwiftStan suite also contains a CLI version, [SwiftStan](https://github.com/SwiftProjectsOrganization/SwiftStan).

## Architecture

The app is a thin **HTTP client** of `SwiftStanServer`, structured as **MVVM over a service layer**: `StanCommandView` → `RunViewModel` → `StanService` → `StanClient` → generated OpenAPI `Client`. It has no compile-time dependency on `SwiftStanLibrary` or `SwiftStanServer`; the shared contract is `openapi.yaml` (kept byte-identical to the server's canonical copy).

- `SwiftStanAppApp.swift` — `@main` App; `WindowGroup { StanCommandView() }` (default size 640×720); macOS `Settings { SettingsView() }` scene; `init()` calls `SwiftStanShortcuts.updateAppShortcutParameters()` to register shortcuts on every launch.
- `StanCommandView.swift` — **main/root view**. `NavigationStack` + `Form` with three sections: command & model selection (picker, prefix filter, model picker), case-directory field, and per-command Stan parameters. Run bar uses Liquid Glass (`.glassProminent`, `GlassEffectContainer`). Results view shows scrollable monospaced status output and macOS "Reveal in Finder" (`NSWorkspace`). `.task { await viewModel.fetchHealth() }` on appear. Toolbar gear opens `SettingsView`; "Advanced" button opens `AdvancedSettingsView`.
- `RunViewModel.swift` — `@Observable @MainActor final class RunViewModel`. Defines `StanCommand` (13 cases, CaseIterable), `RunPhase` (`idle/running/finished(StanResult)/failed(String)`), and `ModelsLoadState`. Orchestrates `fetchHealth()` (seeds `cmdstanPath` from server health if empty) → `loadModels()` → `run()` (switches on command to the matching `StanService` method).
- `AdvancedSettingsView.swift` — sheet with `@Bindable RunViewModel`; extra sampling controls (warmup, thin, seed, adapt delta, max tree depth). Only renders content when `command == .sample`.
- `ContentView.swift` — **defines `SettingsView`** (not a `ContentView` type); a `Form` with server URL and cmdstan path fields. Used by the macOS `Settings` scene and the gear-button sheet.
- `StanService.swift` — service layer wrapping the generated `Client`. DTOs: `StanResult` (`isSuccess`, `throwingResult()` throws `StanIntentError.failed`), `ServerHealth`, and typed param structs (`SampleParams`, `CompileParams`, `CmdstanParams`, `FileParams`, `UlamParams`, `Stan2AlistParams`; all default `model = "bernoulli"`). One async method per endpoint; lowercases model and injects `ServerSettings.stanCases()`.
- `ServerSettings.swift` — `enum ServerSettings` of static UserDefaults helpers. Keys: `serverURL` (default `http://127.0.0.1:8080`), `stanCases` (default `"StanCases"`), `cmdstanPath` (default empty). Methods: `serverURL()`, `stanCases()`, `cmdstan()`, `setCmdstan(_:)`.
- `StanClient.swift` — `enum StanClient` with `static func make() -> Client`. Builds the generated OpenAPI `Client` over `URLSessionTransport`; request and resource timeouts both 900 s (sampling can take many minutes).
- `openapi.yaml` — canonical OpenAPI spec (copied from SwiftStanServer). 15 paths: `GET /v1/health`, `POST /v1/models`, and the 13 command endpoints below.
- `openapi-generator-config.yaml` — `generate: [types, client]`, `accessModifier: internal`, `namingStrategy: idiomatic`.
- `Info.plist` — `NSAppTransportSecurity → NSAllowsLocalNetworking = true`; `NSLocalNetworkUsageDescription` for the local server connection.
- `SwiftStanApp.entitlements` — sandbox disabled (`com.apple.security.app-sandbox = false`); Hardened Runtime on.
- `Intents/` — 13 `AppIntent`s plus supporting types, all calling `StanService`:
  - `CompileModelIntent` — `POST /v1/compile` (model, force, install)
  - `SampleModelIntent` — `POST /v1/sample` (model, nosummary, numSamples, numWarmup, numChains, thin, seed, adaptDelta, maxTreedepth)
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
  - `StanIntentError` — `enum StanIntentError: Error, CustomLocalizedStringResourceConvertible` with case `failed(String)`.
  - `SwiftStanShortcuts` — `AppShortcutsProvider` registering 10 of the 13 intents (excludes `Alist2DslIntent`, `RuninfoIntent`, `StanToAlistIntent`) with phrases / short titles / SF Symbols.

Every `perform()` calls the matching `StanService` method, then `try result.throwingResult()` (throws `StanIntentError.failed` when `error` is non-empty), and returns `IntentDialog(stringLiteral: result.status)`.

## Decoupling invariant

SwiftStanApp has **no build/source dependencies** on `SwiftStanServer` or `SwiftStanLibrary`. The only link to the server is HTTP at runtime via `serverURL`. `openapi.yaml` is a shared *specification*, copied (not referenced) — keep it byte-identical to the server's canonical copy.

## Key constraints

- macOS 27+; Swift 6. Xcode project (not SPM).
- Bundle id `com.goedman.SwiftStanApp`; category developer-tools.
- Use LiquidGlass for UIs.
- App Intents `perform()` can make async network calls — complete the network call before any interactive prompt (a foregrounded confirmation can tear down a URLSession started in the background).
- The OpenAPI generator build plugin requires `openapi.yaml` and `openapi-generator-config.yaml` to be in the target's source folder and listed in the Run Build Tool Plug-ins build phase.
- Sandbox is disabled; `NSAllowsLocalNetworking = true` (in `Info.plist`) is required for the app to reach the local SwiftStanServer over HTTP.
