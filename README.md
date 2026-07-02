# SwiftStanApp

## Purpose

A macOS app that exposes [cmdstan](https://mc-stan.org/users/interfaces/cmdstan) methods from MacOS or iOS clients. It also supports an experimental port of the ulam() R method in [Statistical Rethinking](https://xcelab.net/rm/) and it's supporting R packade `rethinking`.

It will also declare a subset of the methods as **App Intents**, making them available from Shortcuts, Siri, and Spotlight.

## SwiftStan related repositories (the 'SwiftStan suite')

The [SwiftStanApp](https://github.com/SwiftProjectOrganization/SwiftStanApp) is a thin HTTP client of [SwiftStanServer](https://github.com/SwiftProjectOrganization/SwiftStanServer). The SwiftStanServer uses the [SwiftStanLibrary](https://github.com/SwiftProjectOrganization/SwiftStanLibrary) to use the capabilities of `make` and `cmdstan`. As stated above, the SwiftStanApp is a MacOS or IOS client, the SwiftStanServer + SwiftStanLibrary + cmdstan run on a single MacOS system.

The SwiftStanLibrary is based on the [SwiftStan CLI](https://github.com/SwiftProjectOrganization/SwiftStan). The CLI also includes a second ulam pipeline using an intermediate DSL that requires `swiftc`. As swiftc is not available on iOS platforms that functionality was dropped from the SwiftStanLibrary SPM package.

Ultimately my personal dream setup will have a Mac Mini M6 running the SwiftStanServer and use tools, for example as suggested [here](https://medium.com/macoclock/17-unexpected-uses-of-mac-mini-most-people-dont-know-about-00edd82d3ec8) (`YMMV!`), to run Stan models when on the road.

## Requirements

- macOS 27.0 + Xcode 27.0
- SwiftStanServer
- cmdstan

The workflow envisioned in the SwiftStan suite depends on the availability of a shared (e.g. iCloud based) ~/Documents directory where models, data and results are stored. 

## Building

Clone SwiftStanApp from `https://github.com/SwiftProjectOrganization/SwiftStanApp`. It will open in Xcode. Build it. A Debug build automatically copies the app to `/Applications`.

## Configuration

Launch the app and enter the server URL in the text field (leave blank for the default `http://127.0.0.1:8080`). SwiftStanServer must be running before invoking any command, intent or model selection.

## Available Commands

| Command | Shortcut phrase | Description |
|---|---|---|
| Compile | "Compile a Stan model" | Compile a Stan model in `~/Documents/<StanCases>` |
| Sample | "Sample with cmdstan" | Run HMC/NUTS sampling |
| Optimize | "Optimize a Stan model" | Run cmdstan `optimize` |
| Pathfinder | "Run Pathfinder" | Run cmdstan `pathfinder` |
| Laplace | "Run Laplace" | Run cmdstan `laplace` |
| Generated Quantities | "Generate quantities" | Run cmdstan `generate_quantities` |
| Stansummary | "Summarize Stan samples" | Run `stansummary` on output CSV files |
| Ulam | "Run ulam" | Run the full Ulam → Stan → sample pipeline |
| Stancode | "Generate Stan code with SwiftStan" | Translate .alist.r to .stan source |
| CSV to JSON | "Convert .csv to .json" | Convert .csv + .stan to a .data.json file|
| Stan to Alist | ".stan -> .alist.r" | Convert .stan to .alist.r format |
| Alist to DSL | ".alist.r -> DSL" | Convert Alist to DSL format |
| Runinfo | "Read .config.json" | Extract metadata from a cmdstan run |
| Stancases | "Show <Stan_Cases>" | Use `swiftstan stancases SR2Cases` to set <Stan_Cases> |

All commands operate on  a `model` parameter (default: `bernoulli`) matching a subdirectory under `~/Documents/<StanCases>`. The parameter `<StanCases>` is set in the main UI window of SwiftStanApp.

## Architecture

```
Shortcuts / Siri / Spotlight
         │  AppIntent.perform()
         ▼
  SwiftStanApp          ← this repo
   (OpenAPI client)
         │  HTTP POST /v1/<op>
         ▼
   (Hummingbird)
  SwiftStanServer 
         │
         ▼
  SwiftStanLibrary
   (library → cmdstan)
```

The app has no compile-time dependency on SwiftStanLibrary or SwiftStanServer. The shared contract is `openapi.yaml` (kept byte-identical to the server's canonical copy).

## Related Projects

- [`SwiftStanLibrary`](https://github.com/SwiftProjectOrganization/SwiftStanLibrary) — Swift library wrapping cmdstan
- [`SwiftStanServer`](https://github.com/SwiftProjectOrganization/SwiftStanServer) — HTTP server exposing the library via OpenAPI
- [`SwiftStan`](https://github.com/SwiftProjectOrganization/SwiftStan) — CLI executable with similar functionality
