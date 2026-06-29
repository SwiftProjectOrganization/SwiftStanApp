import AppIntents

struct GenerateStanCodeIntent: AppIntent {
    static let title: LocalizedStringResource = "Generate Stan Code"
    static let description = IntentDescription(
        "Convert an alist.R to a Stan model file in-process via SwiftStanServer.")

    @Parameter(title: "Model", default: "bernoulli")
    var model: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = try await StanService().stancode(FileParams(model: model))
        try result.throwingResult()
        return .result(dialog: IntentDialog(stringLiteral: result.status))
    }
}
