# SwiftStanApp

A macOS app that exposes [SwiftStan](../SwiftStan) / [cmdstan](https://mc-stan.org/users/interfaces/cmdstan) operations as **App Intents**, making them available from Shortcuts, Siri, and Spotlight.

The app is a thin HTTP client of [SwiftStanServer](../SwiftStanServer). It contains no Stan logic itself — all computation happens on the server.

## Requirements

- macOS 14+
- [SwiftStanServer](../SwiftStanServer) running (default: `http://127.0.0.1:8080`)
- Xcode 15.4+ (to build)

## Building

Open `SwiftStanApp.xcodeproj` in Xcode and build. A Debug build automatically copies the app to `/Applications`.

## Configuration

Launch the app and enter the server URL in the text field (leave blank for the default `http://127.0.0.1:8080`). SwiftStanServer must be running before invoking any intent.

## Available Intents

| Intent | Shortcut phrase | Description |
|---|---|---|
| Compile Stan Model | "Compile SwiftStan model" | Compile a Stan model in `~/Documents/StanCases` |
| Sample Stan Model | "Sample with SwiftStan" | Run HMC/NUTS sampling |
| Run Ulam Pipeline | "Run SwiftStan pipeline" | Run the full Ulam → Stan → sample pipeline |
| Generate Stan Code | "Generate Stan code with SwiftStan" | Translate a Ulam model to Stan source |
| CSV to JSON | "Convert SwiftStan CSV to JSON" | Convert cmdstan CSV output to JSON |
| Optimize Model | "Optimize SwiftStan model" | Run cmdstan `optimize` |
| Pathfinder | "Run SwiftStan Pathfinder" | Run cmdstan `pathfinder` |
| Laplace | "Run SwiftStan Laplace" | Run cmdstan `laplace` |
| Generated Quantities | "Generate SwiftStan quantities" | Run cmdstan `generate_quantities` |
| Stan Summary | "Summarize SwiftStan samples" | Run `stansummary` on output CSV files |
| Stan to Alist | _(direct only)_ | Convert Stan output to Alist format |
| Alist to DSL | _(direct only)_ | Convert Alist to DSL format |
| Run Info | _(direct only)_ | Extract metadata from a cmdstan run |

All intents accept a `model` parameter (default: `bernoulli`) matching a directory under `~/Documents/StanCases`.

## Architecture

```
Shortcuts / Siri / Spotlight
         │  AppIntent.perform()
         ▼
   SwiftStanApp          ← this repo
   (OpenAPI client)
         │  HTTP POST /v1/<op>
         ▼
  SwiftStanServer        ← ../SwiftStanServer
   (Hummingbird)
         │
         ▼
     SwiftStan            ← ../SwiftStan
     (library → cmdstan)
```

The app has no compile-time dependency on SwiftStan or SwiftStanServer. The shared contract is `openapi.yaml` (kept byte-identical to the server's canonical copy).

## Related Projects

- [`SwiftStan`](../SwiftStan) — Swift library wrapping cmdstan
- [`SwiftStanServer`](../SwiftStanServer) — HTTP server exposing the library via OpenAPI
