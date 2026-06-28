import AppIntents

struct Alist2DslIntent: AppIntent {
  static let title: LocalizedStringResource = "alist to DSL"
  static let description = IntentDescription("Convert an alist.R to a Swift DSL driver via SwiftStanServer.")

  @Parameter(title: "Model", default: "bernoulli")
  var model: String

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let client = StanClient.make()
    let response = try await client.alist2dsl(.init(body: .json(.init(
      model: model.lowercased(), verbose: false))))
    let result = try response.ok.body.json
    guard result.error.isEmpty else { throw StanIntentError.failed(result.error) }
    return .result(dialog: IntentDialog(stringLiteral: result.status))
  }
}
