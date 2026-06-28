import AppIntents

struct PathfinderIntent: AppIntent {
  static let title: LocalizedStringResource = "Run Pathfinder"
  static let description = IntentDescription("Run Pathfinder variational inference via SwiftStanServer.")

  @Parameter(title: "Model", default: "bernoulli")
  var model: String

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let client = StanClient.make()
    let response = try await client.pathfinder(.init(body: .json(.init(
      model: model.lowercased(), arguments: nil, cmdstan: nil, verbose: false))))
    let result = try response.ok.body.json
    guard result.error.isEmpty else { throw StanIntentError.failed(result.error) }
    return .result(dialog: IntentDialog(stringLiteral: result.status))
  }
}
