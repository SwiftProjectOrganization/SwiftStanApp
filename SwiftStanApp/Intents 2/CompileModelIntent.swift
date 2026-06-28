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
    let client = StanClient.make()
    let response = try await client.compile(.init(body: .json(.init(
      model: model.lowercased(), arguments: nil, cmdstan: nil,
      verbose: false, install: install, force: force))))
    let result = try response.ok.body.json
    guard result.error.isEmpty else { throw StanIntentError.failed(result.error) }
    return .result(dialog: IntentDialog(stringLiteral: result.status))
  }
}
