import AppIntents

struct OptimizeModelIntent: AppIntent {
    static let title: LocalizedStringResource = "Optimize Stan Model"
    static let description = IntentDescription(
        "Run MAP optimization on a Stan model via SwiftStanServer.")

    @Parameter(title: "Model", default: "bernoulli")
    var model: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = try await StanService().optimize(CmdstanParams(model: model))
        try result.throwingResult()
        return .result(dialog: IntentDialog(stringLiteral: result.status))
    }
}
