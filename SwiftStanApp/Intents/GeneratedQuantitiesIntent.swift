import AppIntents

struct GeneratedQuantitiesIntent: AppIntent {
    static let title: LocalizedStringResource = "Generated Quantities"
    static let description = IntentDescription(
        "Run generated quantities on prior sample chains via SwiftStanServer.")

    @Parameter(title: "Model", default: "bernoulli")
    var model: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = try await StanService().generatedQuantities(CmdstanParams(model: model))
        try result.throwingResult()
        return .result(dialog: IntentDialog(stringLiteral: result.status))
    }
}
