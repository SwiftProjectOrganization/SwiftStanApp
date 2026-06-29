import AppIntents

struct RuninfoIntent: AppIntent {
    static let title: LocalizedStringResource = "Run Info"
    static let description = IntentDescription(
        "Clean and rewrite the cmdstan run-info JSON via SwiftStanServer.")

    @Parameter(title: "Model", default: "bernoulli")
    var model: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = try await StanService().runinfo(FileParams(model: model))
        try result.throwingResult()
        return .result(dialog: IntentDialog(stringLiteral: result.status))
    }
}
