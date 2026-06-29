import AppIntents

struct StansummaryIntent: AppIntent {
    static let title: LocalizedStringResource = "Stan Summary"
    static let description = IntentDescription(
        "Run stansummary on sample chains via SwiftStanServer.")

    @Parameter(title: "Model", default: "bernoulli")
    var model: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = try await StanService().stansummary(CmdstanParams(model: model))
        try result.throwingResult()
        return .result(dialog: IntentDialog(stringLiteral: result.status))
    }
}
