import AppIntents

struct Csv2JsonIntent: AppIntent {
    static let title: LocalizedStringResource = "CSV to JSON"
    static let description = IntentDescription(
        "Convert a CSV data file to data.json via SwiftStanServer.")

    @Parameter(title: "Model", default: "bernoulli")
    var model: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = try await StanService().csv2json(FileParams(model: model))
        try result.throwingResult()
        return .result(dialog: IntentDialog(stringLiteral: result.status))
    }
}
