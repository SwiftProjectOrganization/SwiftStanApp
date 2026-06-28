# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

SwiftStanApp is a non-sandboxed **macOS app** that surfaces SwiftStan commands as **App Intents** (invocable from Shortcuts / Siri / Spotlight). macOS 14+; Swift 6. It is built as an **Xcode project** (not an SPM package); a Debug build phase copies the `.app` to `/Applications`.

It is one of three independent projects:
- [`SwiftStan`](../SwiftStan) — the library doing the real work.
- [`SwiftStanServer`](../SwiftStanServer) — a separate app hosting an OpenAPI/Hummingbird HTTP server over the library.
- `SwiftStanApp` (this) — the App Intents front end.

The design rationale and migration plan live in `../SwiftStan/Docs/SwiftStanServer-Plan.md`.

## Architecture (current state)

The app links the `SwiftStan` library **directly** via a local SPM path dependency (`XCLocalSwiftPackageReference "../SwiftStan"`) and calls its top-level functions in-process; the library shells out to cmdstan. This is why the app is non-sandboxed.

- `SwiftStanAppApp.swift` — `@main` App; calls `SwiftStanShortcuts.updateAppShortcutParameters()` in `init()` to register shortcuts on every launch.
- `ContentView.swift` — minimal GUI: a single `TextField` bound to `@AppStorage("cmdstanPath")`. The app does no real work in the UI; everything happens through intents.
- `AppSettings.swift` — `cmdstanPath()`: UserDefaults `"cmdstanPath"` → `$CMDSTAN` → hardcoded default (GUI apps launched by launchd don't inherit the shell's `$CMDSTAN`).
- `Intents/` — five `AppIntent`s, each `import SwiftStan` and call a library function:
  - `CompileModelIntent` → `compile(...)` (params: model, force, install)
  - `SampleModelIntent` → `sample(...)` (params: model, nosummary)
  - `RunUlamPipelineIntent` → `ulamPipeline(...)` (params: model, force)
  - `GenerateStanCodeIntent` → `stancode(model:verbose:)` (param: model)
  - `StanToAlistIntent` → `stan2alist(model:verbose:force:)` (params: model, force)
  - `StanIntentError` — thrown when a command returns a non-empty error string.
  - `SwiftStanShortcuts` — `AppShortcutsProvider` enumerating the five intents with phrases / short titles / SF Symbols.
- Intents that run cmdstan (`compile`, `sample`, `ulam`) pass `AppSettings.cmdstanPath()`; the file-translation intents (`stancode`, `stan2alist`) do not.
- `SwiftStanApp.entitlements` — sandbox disabled (`com.apple.security.app-sandbox = false`); Hardened Runtime on (Developer-ID / direct distribution).

The `(stdout, stderr)`-tuple intents throw `StanIntentError.failed(stderr)` when stderr is non-empty and otherwise return `IntentDialog(stdout)`; the file intents return `IntentDialog("Wrote <file>")`.

## Planned migration → OpenAPI client (see ../SwiftStan/Docs/SwiftStanServer-Plan.md)

The app will be refactored to a thin **HTTP client** of `SwiftStanServer`, so it no longer links `SwiftStan` and no longer shells out:

1. **Drop** the `XCLocalSwiftPackageReference "../SwiftStan"` + `SwiftStan` product dependency; remove `import SwiftStan` from the intents.
2. **Add** the OpenAPI client packages: `swift-openapi-generator` (build plugin), `swift-openapi-runtime`, `swift-openapi-urlsession`. Copy the canonical `../SwiftStanServer/SwiftStanServer/OpenAPI/openapi.yaml` into the app target's source folder with a **client** `openapi-generator-config.yaml` (`generate: [types, client]`). Wire the plugin via Build Phases → Run Build Tool Plug-ins.
3. **Add** `StanClient.swift` (builds the generated `Client` over `URLSessionTransport` with a long ~900 s timeout for multi-minute sampling) + `ServerSettings.swift` (reads `@AppStorage("serverURL")`, default `http://127.0.0.1:8080`).
4. **Rewrite** the five intents to call the generated client, and **add nine** (`Optimize, Pathfinder, Laplace, GeneratedQuantities, Stansummary, Csv2Json, Dsl2Stan, Alist2Dsl, Runinfo`) for full parity — 14 total. `perform()` is `async throws`, so `try await client.<op>(...)` works directly; branch on the response's `error` field and surface failures via `StanIntentError`.
5. **Update** `SwiftStanShortcuts` (add the nine new intents) and `ContentView` (add a `serverURL` field; the cmdstan path now lives on the server).
6. **Entitlements**: the app stops shelling out, so it *could* be sandboxed (then add `com.apple.security.network.client`). Keeping it non-sandboxed initially minimizes churn.

## Decoupling invariant

SwiftStanApp must have **no build/source dependency** on `SwiftStanServer` (and, post-migration, none on `SwiftStan`). The only link to the server is HTTP at runtime via `serverURL`. `openapi.yaml` is a shared *specification*, copied (not referenced) — keep it byte-identical to the server's canonical copy.

## Key constraints

- macOS 14+; Swift 6. Xcode project (not SPM). Debug builds copy to `/Applications`.
- Bundle id `com.goedman.SwiftStanApp`; category developer-tools.
- App Intents `perform()` can make async network calls — complete the network call before any interactive prompt (a foregrounded confirmation can tear down a URLSession started in the background).
