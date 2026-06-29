import AppIntents

struct LaplaceIntent: AppIntent {
    static let title: LocalizedStringResource = "Run Laplace"
    static let description = IntentDescription(
        "Run Laplace approximation via SwiftStanServer.")

    @Parameter(title: "Model", default: "bernoulli")
    var model: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = try await StanService().laplace(CmdstanParams(model: model))
        try result.throwingResult()
        return .result(dialog: IntentDialog(stringLiteral: result.status))
    }
}
