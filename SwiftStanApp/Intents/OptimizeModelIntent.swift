import AppIntents

struct OptimizeModelIntent: AppIntent {
  static let title: LocalizedStringResource = "Optimize Stan Model"
  static let description = IntentDescription("Run MAP optimization on a Stan model via SwiftStanServer.")

  @Parameter(title: "Model", default: "bernoulli")
  var model: String

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let client = StanClient.make()
    let response = try await client.optimize(.init(body: .json(.init(
      model: model.lowercased(), arguments: nil, cmdstan: nil, verbose: false))))
    let result = try response.ok.body.json
    guard result.error.isEmpty else { throw StanIntentError.failed(result.error) }
    return .result(dialog: IntentDialog(stringLiteral: result.status))
  }
}
