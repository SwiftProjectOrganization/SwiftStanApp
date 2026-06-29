import AppIntents

struct CompileModelIntent: AppIntent {
    static let title: LocalizedStringResource = "Compile Stan Model"
    static let description = IntentDescription(
        "Compile a Stan model under ~/Documents/StanCases via SwiftStanServer.")

    @Parameter(title: "Model", default: "bernoulli")
    var model: String

    @Parameter(title: "Force Recompile", default: false)
    var force: Bool

    @Parameter(title: "Install Example", default: false)
    var install: Bool

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let params = CompileParams(model: model, install: install, force: force)
        let result = try await StanService().compile(params)
        try result.throwingResult()
        return .result(dialog: IntentDialog(stringLiteral: result.status))
    }
}
