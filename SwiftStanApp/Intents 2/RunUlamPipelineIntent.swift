import AppIntents

struct RunUlamPipelineIntent: AppIntent {
  static let title: LocalizedStringResource = "Run Ulam Pipeline"
  static let description = IntentDescription(
    "Run the full alist→Stan→compile→sample pipeline via SwiftStanServer.")

  @Parameter(title: "Model", default: "bernoulli")
  var model: String

  @Parameter(title: "Force", default: false)
  var force: Bool

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let client = StanClient.make()
    let response = try await client.ulam(.init(body: .json(.init(
      model: model.lowercased(), arguments: nil, cmdstan: nil,
      verbose: false, force: force))))
    let result = try response.ok.body.json
    guard result.error.isEmpty else { throw StanIntentError.failed(result.error) }
    return .result(dialog: IntentDialog(stringLiteral: result.status))
  }
}
