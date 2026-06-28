import AppIntents

struct RuninfoIntent: AppIntent {
  static let title: LocalizedStringResource = "Run Info"
  static let description = IntentDescription("Clean and rewrite the cmdstan run-info JSON via SwiftStanServer.")

  @Parameter(title: "Model", default: "bernoulli")
  var model: String

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let client = StanClient.make()
    let response = try await client.runinfo(.init(body: .json(.init(
      model: model.lowercased(), verbose: false))))
    let result = try response.ok.body.json
    guard result.error.isEmpty else { throw StanIntentError.failed(result.error) }
    return .result(dialog: IntentDialog(stringLiteral: result.status))
  }
}
