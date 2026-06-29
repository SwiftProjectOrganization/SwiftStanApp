import AppIntents

struct PathfinderIntent: AppIntent {
    static let title: LocalizedStringResource = "Run Pathfinder"
    static let description = IntentDescription(
        "Run Pathfinder variational inference via SwiftStanServer.")

    @Parameter(title: "Model", default: "bernoulli")
    var model: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = try await StanService().pathfinder(CmdstanParams(model: model))
        try result.throwingResult()
        return .result(dialog: IntentDialog(stringLiteral: result.status))
    }
}
