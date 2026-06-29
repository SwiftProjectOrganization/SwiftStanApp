import AppIntents

struct RunUlamPipelineIntent: AppIntent {
    static let title: LocalizedStringResource = "Run Ulam Pipeline"
    static let description = IntentDescription(
        "Run the full alist\u{2192}Stan\u{2192}compile\u{2192}sample pipeline via SwiftStanServer.")

    @Parameter(title: "Model", default: "bernoulli")
    var model: String

    @Parameter(title: "Force", default: false)
    var force: Bool

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = try await StanService().ulam(UlamParams(model: model, force: force))
        try result.throwingResult()
        return .result(dialog: IntentDialog(stringLiteral: result.status))
    }
}
