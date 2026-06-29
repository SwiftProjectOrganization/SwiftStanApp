import Foundation
import Observation

enum StanCommand: String, CaseIterable, Identifiable {
    case sample = "Sample"
    case compile = "Compile"
    case optimize = "Optimize"
    case pathfinder = "Pathfinder"
    case laplace = "Laplace"
    case generatedQuantities = "Generated Quantities"
    case stansummary = "Stan Summary"
    case csv2json = "CSV to JSON"
    case alist2dsl = "alist to DSL"
    case stancode = "Generate Stan Code"
    case runinfo = "Run Info"
    case stan2alist = "Stan to alist"
    case ulam = "Ulam Pipeline"

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
    var cmdstanPath: String = ""

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

    var isRunning: Bool {
        if case .running = phase { return true }
        return false
    }

    func fetchHealth() async {
        guard let health = try? await StanService().health() else { return }
        if cmdstanPath.isEmpty {
            cmdstanPath = health.cmdstan
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
        cmdstanPath.isEmpty ? nil : cmdstanPath
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
