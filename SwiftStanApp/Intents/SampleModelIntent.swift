import AppIntents

struct SampleModelIntent: AppIntent {
    static let title: LocalizedStringResource = "Sample Stan Model"
    static let description = IntentDescription(
        "Run HMC/NUTS sampling on a Stan model via SwiftStanServer.")

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
        let params = SampleParams(
            model: model, nosummary: nosummary,
            numSamples: numSamples, numWarmup: numWarmup, numChains: numChains,
            thin: thin, seed: seed, adaptDelta: adaptDelta, maxTreedepth: maxTreedepth)
        let result = try await StanService().sample(params)
        try result.throwingResult()
        return .result(dialog: IntentDialog(stringLiteral: result.status))
    }
}
