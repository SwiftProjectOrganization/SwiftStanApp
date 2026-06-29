import AppIntents

struct StanToAlistIntent: AppIntent {
    static let title: LocalizedStringResource = "Stan to alist"
    static let description = IntentDescription(
        "Reverse a Stan model file back to an R alist via SwiftStanServer.")

    @Parameter(title: "Model", default: "bernoulli")
    var model: String

    @Parameter(title: "Force Overwrite", default: false)
    var force: Bool

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = try await StanService().stan2alist(Stan2AlistParams(model: model, force: force))
        try result.throwingResult()
        return .result(dialog: IntentDialog(stringLiteral: result.status))
    }
}
