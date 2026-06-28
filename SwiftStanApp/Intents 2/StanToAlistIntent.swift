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
    let client = StanClient.make()
    let response = try await client.stan2alist(.init(body: .json(.init(
      model: model.lowercased(), verbose: false, force: force))))
    let result = try response.ok.body.json
    guard result.error.isEmpty else { throw StanIntentError.failed(result.error) }
    return .result(dialog: IntentDialog(stringLiteral: result.status))
  }
}
