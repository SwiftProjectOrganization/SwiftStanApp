import Foundation

struct StanResult {
    let status: String
    let error: String
    let outputPath: String?

    var isSuccess: Bool { error.isEmpty }

    @discardableResult
    func throwingResult() throws -> StanResult {
        guard error.isEmpty else { throw StanIntentError.failed(error) }
        return self
    }
}

struct ServerHealth {
    let cmdstan: String
    let stanCases: String
}

struct SampleParams {
    var model: String = "bernoulli"
    var arguments: [String]? = nil
    var cmdstan: String? = nil
    var verbose: Bool = false
    var install: Bool = false
    var nosummary: Bool = false
    var numSamples: Int? = nil
    var numWarmup: Int? = nil
    var numChains: Int? = nil
    var thin: Int? = nil
    var seed: Int? = nil
    var adaptDelta: Double? = nil
    var maxTreedepth: Int? = nil
}

struct CompileParams {
    var model: String = "bernoulli"
    var arguments: [String]? = nil
    var cmdstan: String? = nil
    var verbose: Bool = false
    var install: Bool = false
    var force: Bool = false
}

struct CmdstanParams {
    var model: String = "bernoulli"
    var arguments: [String]? = nil
    var cmdstan: String? = nil
    var verbose: Bool = false
}

struct FileParams {
    var model: String = "bernoulli"
    var verbose: Bool = false
}

struct UlamParams {
    var model: String = "bernoulli"
    var arguments: [String]? = nil
    var cmdstan: String? = nil
    var verbose: Bool = false
    var force: Bool = false
}

struct Stan2AlistParams {
    var model: String = "bernoulli"
    var verbose: Bool = false
    var force: Bool = false
}

struct StanService {
    private let client: Client

    init(client: Client = StanClient.make()) {
        self.client = client
    }

    func health() async throws -> ServerHealth {
        let r = try await client.health()
        let j = try r.ok.body.json
        return ServerHealth(cmdstan: j.cmdstan, stanCases: j.stanCases)
    }

    func models() async throws -> (root: String, models: [String]) {
        let r = try await client.models(.init(body: .json(.init(
            stanCases: ServerSettings.stanCases()))))
        let j = try r.ok.body.json
        return (j.root, j.models)
    }

    func sample(_ p: SampleParams) async throws -> StanResult {
        let r = try await client.sample(.init(body: .json(.init(
            model: p.model.lowercased(), arguments: p.arguments, cmdstan: p.cmdstan,
            stanCases: ServerSettings.stanCases(),
            verbose: p.verbose, install: p.install, nosummary: p.nosummary,
            numSamples: p.numSamples, numWarmup: p.numWarmup, numChains: p.numChains,
            thin: p.thin, seed: p.seed, adaptDelta: p.adaptDelta, maxTreedepth: p.maxTreedepth))))
        let j = try r.ok.body.json
        return StanResult(status: j.status, error: j.error, outputPath: j.outputPath)
    }

    func compile(_ p: CompileParams) async throws -> StanResult {
        let r = try await client.compile(.init(body: .json(.init(
            model: p.model.lowercased(), arguments: p.arguments, cmdstan: p.cmdstan,
            stanCases: ServerSettings.stanCases(),
            verbose: p.verbose, install: p.install, force: p.force))))
        let j = try r.ok.body.json
        return StanResult(status: j.status, error: j.error, outputPath: j.outputPath)
    }

    func optimize(_ p: CmdstanParams) async throws -> StanResult {
        let r = try await client.optimize(.init(body: .json(.init(
            model: p.model.lowercased(), arguments: p.arguments,
            cmdstan: p.cmdstan, stanCases: ServerSettings.stanCases(),
            verbose: p.verbose))))
        let j = try r.ok.body.json
        return StanResult(status: j.status, error: j.error, outputPath: j.outputPath)
    }

    func pathfinder(_ p: CmdstanParams) async throws -> StanResult {
        let r = try await client.pathfinder(.init(body: .json(.init(
            model: p.model.lowercased(), arguments: p.arguments,
            cmdstan: p.cmdstan, stanCases: ServerSettings.stanCases(),
            verbose: p.verbose))))
        let j = try r.ok.body.json
        return StanResult(status: j.status, error: j.error, outputPath: j.outputPath)
    }

    func laplace(_ p: CmdstanParams) async throws -> StanResult {
        let r = try await client.laplace(.init(body: .json(.init(
            model: p.model.lowercased(), arguments: p.arguments,
            cmdstan: p.cmdstan, stanCases: ServerSettings.stanCases(),
            verbose: p.verbose))))
        let j = try r.ok.body.json
        return StanResult(status: j.status, error: j.error, outputPath: j.outputPath)
    }

    func generatedQuantities(_ p: CmdstanParams) async throws -> StanResult {
        let r = try await client.generatedQuantities(.init(body: .json(.init(
            model: p.model.lowercased(), arguments: p.arguments,
            cmdstan: p.cmdstan, stanCases: ServerSettings.stanCases(),
            verbose: p.verbose))))
        let j = try r.ok.body.json
        return StanResult(status: j.status, error: j.error, outputPath: j.outputPath)
    }

    func stansummary(_ p: CmdstanParams) async throws -> StanResult {
        let r = try await client.stansummary(.init(body: .json(.init(
            model: p.model.lowercased(), arguments: p.arguments,
            cmdstan: p.cmdstan, stanCases: ServerSettings.stanCases(),
            verbose: p.verbose))))
        let j = try r.ok.body.json
        return StanResult(status: j.status, error: j.error, outputPath: j.outputPath)
    }

    func csv2json(_ p: FileParams) async throws -> StanResult {
        let r = try await client.csv2json(.init(body: .json(.init(
            model: p.model.lowercased(), stanCases: ServerSettings.stanCases(),
            verbose: p.verbose))))
        let j = try r.ok.body.json
        return StanResult(status: j.status, error: j.error, outputPath: j.outputPath)
    }

    func alist2dsl(_ p: FileParams) async throws -> StanResult {
        let r = try await client.alist2dsl(.init(body: .json(.init(
            model: p.model.lowercased(), stanCases: ServerSettings.stanCases(),
            verbose: p.verbose))))
        let j = try r.ok.body.json
        return StanResult(status: j.status, error: j.error, outputPath: j.outputPath)
    }

    func stancode(_ p: FileParams) async throws -> StanResult {
        let r = try await client.stancode(.init(body: .json(.init(
            model: p.model.lowercased(), stanCases: ServerSettings.stanCases(),
            verbose: p.verbose))))
        let j = try r.ok.body.json
        return StanResult(status: j.status, error: j.error, outputPath: j.outputPath)
    }

    func runinfo(_ p: FileParams) async throws -> StanResult {
        let r = try await client.runinfo(.init(body: .json(.init(
            model: p.model.lowercased(), stanCases: ServerSettings.stanCases(),
            verbose: p.verbose))))
        let j = try r.ok.body.json
        return StanResult(status: j.status, error: j.error, outputPath: j.outputPath)
    }

    func ulam(_ p: UlamParams) async throws -> StanResult {
        let r = try await client.ulam(.init(body: .json(.init(
            model: p.model.lowercased(), arguments: p.arguments, cmdstan: p.cmdstan,
            stanCases: ServerSettings.stanCases(),
            verbose: p.verbose, force: p.force))))
        let j = try r.ok.body.json
        return StanResult(status: j.status, error: j.error, outputPath: j.outputPath)
    }

    func stan2alist(_ p: Stan2AlistParams) async throws -> StanResult {
        let r = try await client.stan2alist(.init(body: .json(.init(
            model: p.model.lowercased(), stanCases: ServerSettings.stanCases(),
            verbose: p.verbose, force: p.force))))
        let j = try r.ok.body.json
        return StanResult(status: j.status, error: j.error, outputPath: j.outputPath)
    }
}
