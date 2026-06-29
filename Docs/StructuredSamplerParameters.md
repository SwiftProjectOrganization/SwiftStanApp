# Structured sampler parameters for the Sample intent

## Context

**Question that started this:** "Can I use SwiftStanApp to run the available commands on cases in `~/Documents/StanCases` and pass in the model, the switches and other arguments?"

**Current answer:** Partially. All 13 intents run per-case by passing a `model` name (the lowercased case-directory name under `~/Documents/StanCases/<model>/`), plus a few booleans (`force`, `install`, `nosummary`). But **no sampler arguments** (seed, num_samples, num_chains, num_warmup, thin, adapt_delta, max_treedepth) can be passed. The OpenAPI request bodies expose only a free-form `arguments: [String]` passthrough — and every intent hardcodes it to `nil`. There are **no structured fields** for sampler controls anywhere in the spec.

**Goal:** Add first-class, structured sampler parameters to the **`/v1/sample`** path so the user can set seed / sample counts / chains / etc. from Shortcuts/Siri. This spans **three layers**: the shared `openapi.yaml` spec, the **SwiftStanServer** handler, and the **SwiftStanApp** intent. The SwiftStan *library* is left untouched.

**Chosen approach:** Structured fields in the spec → **server translates them into correctly-ordered cmdstan `key=value` tokens** and folds them into the existing `arguments: [String]` array it already passes to `SwiftStan.sample(...)`. The library already splices `arguments` verbatim after the `sample` subcommand (`StanSample.swift`) and only injects its own defaults (`num_chains=4`, `num_samples=1000`, `num_threads=6`) when a key is absent — so explicit values cleanly override. This avoids editing the separately-versioned, dual-mirrored SwiftStan library package.

## Decoupling invariant (must hold)

SwiftStanApp keeps **no** build/source dependency on the server or library. `openapi.yaml` is a *specification* copied byte-identical across all locations. This plan only adds schema fields + intent `@Parameter`s on the app side and handler logic on the server side — the link stays pure HTTP.

## Fields to add (on `SampleRequest` only)

Idiomatic naming maps snake_case → camelCase in generated Swift (`num_samples` → `numSamples`). All optional; omitted when nil.

| Spec field (snake) | Swift (camel) | Type | cmdstan token emitted by server |
|---|---|---|---|
| `num_samples` | `numSamples` | integer | `num_samples=<n>` |
| `num_warmup` | `numWarmup` | integer | `num_warmup=<n>` |
| `num_chains` | `numChains` | integer | `num_chains=<n>` |
| `thin` | `thin` | integer | `thin=<n>` |
| `seed` | `seed` | integer | `random seed=<n>` |
| `adapt_delta` | `adaptDelta` | number | `adapt delta=<d>` |
| `max_treedepth` | `maxTreedepth` | integer | `algorithm=hmc engine=nuts max_depth=<n>` |

The existing `arguments: [String]` stays as a raw escape hatch.

## Changes

### 1. OpenAPI spec — keep ALL copies byte-identical

Add the seven properties under `SampleRequest.properties` (currently `openapi.yaml:217-227`). Edit all three copies identically:
- `/Users/rob/Projects/Swift/SwiftStanApp/SwiftStanApp/openapi.yaml` (app client copy)
- `/Users/rob/Projects/Swift/SwiftStanServer/SwiftStanServer/OpenAPI/openapi.yaml` (server canonical)
- `/Users/rob/Projects/Swift/SwiftStanServer/SwiftStanServer/openapi.yaml` (server duplicate — verified byte-identical today)

New `SampleRequest`:
```yaml
    SampleRequest:
      type: object
      properties:
        model: { type: string, default: bernoulli }
        arguments:
          type: array
          items: { type: string }
        cmdstan: { type: string }
        verbose: { type: boolean, default: false }
        install: { type: boolean, default: false }
        nosummary: { type: boolean, default: false }
        num_samples: { type: integer }
        num_warmup: { type: integer }
        num_chains: { type: integer }
        thin: { type: integer }
        seed: { type: integer }
        adapt_delta: { type: number }
        max_treedepth: { type: integer }
```

(`generate: [types, client]` on the app, `[types, server]` on the server — both regenerate `SampleRequest` with the new optional fields automatically on next build. No generated code is hand-edited.)

### 2. SwiftStanServer handler — translate structured fields → tokens

File: `/Users/rob/Projects/Swift/SwiftStanServer/SwiftStanServer/StanAPIHandler.swift`, `func sample` (lines 69-82).

Add a small private helper that builds tokens in cmdstan's expected order, then prepend them to the caller's `arguments` (raw passthrough kept after, so it can still override):

```swift
/// Translate structured SampleRequest fields into cmdstan key=value tokens,
/// emitted in the order cmdstan's hierarchical parser expects under `sample`.
private func sampleTokens(_ req: Components.Schemas.SampleRequest) -> [String] {
  var t: [String] = []
  if let v = req.numSamples { t.append("num_samples=\(v)") }
  if let v = req.numWarmup  { t.append("num_warmup=\(v)") }
  if let v = req.thin       { t.append("thin=\(v)") }
  if let v = req.adaptDelta { t.append(contentsOf: ["adapt", "delta=\(v)"]) }
  if let v = req.maxTreedepth { t.append(contentsOf: ["algorithm=hmc", "engine=nuts", "max_depth=\(v)"]) }
  if let v = req.numChains  { t.append("num_chains=\(v)") }
  if let v = req.seed       { t.append(contentsOf: ["random", "seed=\(v)"]) }
  return t
}
```

Then in `func sample`, change the `arguments:` argument to:
```swift
arguments: sampleTokens(req) + (req.arguments ?? []),
```
Everything else in the handler is unchanged. The library's default-merge sees the explicit `num_samples=`/`num_chains=` prefixes and skips its defaults.

### 3. SwiftStanApp — expose the fields on the intent

File: `/Users/rob/Projects/Swift/SwiftStanApp/SwiftStanApp/Intents/SampleModelIntent.swift`.

Add seven optional `@Parameter`s and pass them into the generated `SampleRequest` init. Optional `@Parameter`s are unset by default in Shortcuts, so the existing one-tap "Sample bernoulli" flow is unchanged.

```swift
@Parameter(title: "Model", default: "bernoulli")
var model: String

@Parameter(title: "No Summary", default: false)
var nosummary: Bool

@Parameter(title: "Samples")        var numSamples: Int?
@Parameter(title: "Warmup")         var numWarmup: Int?
@Parameter(title: "Chains")         var numChains: Int?
@Parameter(title: "Thin")           var thin: Int?
@Parameter(title: "Seed")           var seed: Int?
@Parameter(title: "Adapt Delta")    var adaptDelta: Double?
@Parameter(title: "Max Tree Depth") var maxTreedepth: Int?

func perform() async throws -> some IntentResult & ProvidesDialog {
  let client = StanClient.make()
  let response = try await client.sample(.init(body: .json(.init(
    model: model.lowercased(), arguments: nil, cmdstan: nil,
    verbose: false, install: false, nosummary: nosummary,
    numSamples: numSamples, numWarmup: numWarmup, numChains: numChains,
    thin: thin, seed: seed, adaptDelta: adaptDelta, maxTreedepth: maxTreedepth))))
  let result = try response.ok.body.json
  guard result.error.isEmpty else { throw StanIntentError.failed(result.error) }
  return .result(dialog: IntentDialog(stringLiteral: result.status))
}
```

(Confirm the exact generated initializer parameter order/labels after the first build — the OpenAPI generator orders init params by property declaration order in the YAML, which the table above follows. Use the generated client to check labels if Xcode flags a mismatch.)

## Scope notes / deliberate exclusions

- **Only `/v1/sample`.** `optimize`, `pathfinder`, `laplace`, `generated_quantities`, `stansummary` all share `CmdstanRequest`; adding sampler fields there would leak `num_samples` into ops that reject it. If those need structured options later, give each its own request schema. `seed` is the one field plausibly shared — out of scope here to keep the change tight.
- **Library untouched.** No edits to `SwiftStan`/`SwiftStanLibrary` (`Commands/Sample.swift`, `Methods/StanSample.swift`). If grammar correctness for grouped args (`adapt delta=`, `algorithm=hmc engine=nuts max_depth=`) proves fragile via the string passthrough, the fallback is a typed `SampleOptions` struct in the library — a larger, dual-repo change noted but not taken now.
- **No data/init upload.** Data and init still resolve server-side from the case's `Results/` dir; this plan does not add file upload.

## Verification

1. **Spec parity:** after editing, confirm the three `openapi.yaml` copies are byte-identical (`diff` the app copy against both server copies — must be empty).
2. **Server build:** build SwiftStanServer (its own Xcode project) so the generator emits the new `SampleRequest` fields; confirm `StanAPIHandler.swift` compiles with `req.numSamples` etc.
3. **Server smoke test (no app needed):** start the server, then
   ```
   curl -s localhost:8080/v1/sample -H 'content-type: application/json' \
     -d '{"model":"bernoulli","num_samples":200,"num_chains":2,"seed":42}'
   ```
   Expect a `CommandResult` with empty `error`. Inspect `~/Documents/StanCases/bernoulli/Results/*.sample.log` (or the cmdstan config) to confirm `num_samples=200 num_chains=2 random seed=42` reached the binary and that the library defaults did NOT override them.
4. **App build:** `BuildProject` (xcode-tools) on SwiftStanApp — confirms the generated client gained the new fields and `SampleModelIntent.swift` compiles. Use `XcodeRefreshCodeIssuesInFile` on `SampleModelIntent.swift` for a fast check of the init labels first.
5. **End-to-end:** run the "Sample Stan Model" intent from Shortcuts/Spotlight with a non-default Seed and Samples set; confirm the run honors them (same log/config check as step 3) and that leaving them blank still works (one-tap default run).
6. **Determinism check:** run twice with the same `seed` → identical draws; different/blank seed → different draws.
