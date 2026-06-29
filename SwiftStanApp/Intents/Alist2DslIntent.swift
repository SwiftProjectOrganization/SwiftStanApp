import AppIntents

struct Alist2DslIntent: AppIntent {
    static let title: LocalizedStringResource = "alist to DSL"
    static let description = IntentDescription(
        "Convert an alist.R to a Swift DSL driver via SwiftStanServer.")

    @Parameter(title: "Model", default: "bernoulli")
    var model: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = try await StanService().alist2dsl(FileParams(model: model))
        try result.throwingResult()
        return .result(dialog: IntentDialog(stringLiteral: result.status))
    }
}
