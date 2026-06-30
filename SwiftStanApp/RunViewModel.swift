import Foundation
import Observation

enum StanCommand: String, CaseIterable, Identifiable {
    case sample = "Sample"
    case compile = "Compile"
    case optimize = "Optimize"
    case pathfinder = "Pathfinder"
    case laplace = "Laplace"
    case generatedQuantities = "Generated Quantities"
    case stansummary = "Stansummary"
    case csv2json = "CSV to JSON"
    case ulam = "Ulam"
    case stancode = "Stancode"
    case runinfo = "Run Info"
    case alist2dsl = "Alist to DSL"
    case stan2alist = "Stan to alist"

    var id: String { rawValue }
}

enum RunPhase {
    case idle
    case running
    case finished(StanResult)
    case failed(String)
}

@Observable
@MainActor
final class RunViewModel {
    var command: StanCommand = .sample

    // Common
    var model: String = "bernoulli"
    var verbose: Bool = false

    // Sample-specific
    var nosummary: Bool = false
    var numSamplesText: String = ""
    var numWarmupText: String = ""
    var numChainsText: String = ""
    var thinText: String = ""
    var seedText: String = ""
    var adaptDeltaText: String = ""
    var maxTreedepthText: String = ""

    // Compile / stan2alist / ulam
    var install: Bool = false
    var force: Bool = false

    var phase: RunPhase = .idle

    // Model list
    enum ModelsLoadState { case notLoaded, loaded, failed }
    var modelsState: ModelsLoadState = .notLoaded
    var availableModels: [String] = []
    var stanCasesRoot: String = ""
    var modelPrefix: String = ""

    var casename: String { ServerSettings.stanCases() }

    var isRunning: Bool {
        if case .running = phase { return true }
        return false
    }

    var filteredModels: [String] {
        let p = modelPrefix.trimmingCharacters(in: .whitespaces).lowercased()
        guard !p.isEmpty else { return availableModels }
        return availableModels.filter { $0.lowercased().hasPrefix(p) }
    }

    var modelOptions: [String] {
        var opts = filteredModels
        if !opts.contains(model) { opts.insert(model, at: 0) }
        return opts
    }

    func fetchHealth() async {
        guard let health = try? await StanService().health() else { return }
        if ServerSettings.cmdstan().isEmpty {
            ServerSettings.setCmdstan(health.cmdstan)
        }
        await loadModels()
    }

    func loadModels() async {
        do {
            let result = try await StanService().models()
            let rootChanged = !stanCasesRoot.isEmpty && stanCasesRoot != result.root
            stanCasesRoot = result.root
            availableModels = result.models
            modelsState = .loaded
            if rootChanged || !availableModels.contains(model) {
                model = availableModels.first ?? ""
                modelPrefix = ""
            }
        } catch {
            availableModels = []
            modelsState = .failed
        }
    }

    func run() async {
        phase = .running
        do {
            let result: StanResult
            switch command {
            case .sample:
                result = try await StanService().sample(sampleParams)
            case .compile:
                result = try await StanService().compile(compileParams)
            case .optimize:
                result = try await StanService().optimize(cmdstanParams)
            case .pathfinder:
                result = try await StanService().pathfinder(cmdstanParams)
            case .laplace:
                result = try await StanService().laplace(cmdstanParams)
            case .generatedQuantities:
                result = try await StanService().generatedQuantities(cmdstanParams)
            case .stansummary:
                result = try await StanService().stansummary(cmdstanParams)
            case .csv2json:
                result = try await StanService().csv2json(fileParams)
            case .alist2dsl:
                result = try await StanService().alist2dsl(fileParams)
            case .stancode:
                result = try await StanService().stancode(fileParams)
            case .runinfo:
                result = try await StanService().runinfo(fileParams)
            case .stan2alist:
                result = try await StanService().stan2alist(stan2AlistParams)
            case .ulam:
                result = try await StanService().ulam(ulamParams)
            }
            phase = .finished(result)
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    private var parsedCmdstan: String? {
        let value = ServerSettings.cmdstan()
        return value.isEmpty ? nil : value
    }

    private var sampleParams: SampleParams {
        SampleParams(
            model: model, cmdstan: parsedCmdstan,
            verbose: verbose, nosummary: nosummary,
            numSamples: Int(numSamplesText), numWarmup: Int(numWarmupText),
            numChains: Int(numChainsText), thin: Int(thinText), seed: Int(seedText),
            adaptDelta: Double(adaptDeltaText), maxTreedepth: Int(maxTreedepthText))
    }

    private var compileParams: CompileParams {
        CompileParams(model: model, cmdstan: parsedCmdstan,
                      verbose: verbose, install: install, force: force)
    }

    private var cmdstanParams: CmdstanParams {
        CmdstanParams(model: model, cmdstan: parsedCmdstan, verbose: verbose)
    }

    private var fileParams: FileParams {
        FileParams(model: model, verbose: verbose)
    }

    private var stan2AlistParams: Stan2AlistParams {
        Stan2AlistParams(model: model, verbose: verbose, force: force)
    }

    private var ulamParams: UlamParams {
        UlamParams(model: model, cmdstan: parsedCmdstan, verbose: verbose, force: force)
    }
}
