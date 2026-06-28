import AppIntents

struct SampleModelIntent: AppIntent {
  static let title: LocalizedStringResource = "Sample Stan Model"
  static let description = IntentDescription(
    "Run HMC/NUTS sampling on a Stan model via SwiftStanServer.")

  @Parameter(title: "Model", default: "bernoulli")
  var model: String

  @Parameter(title: "No Summary", default: false)
  var nosummary: Bool

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let client = StanClient.make()
    let response = try await client.sample(.init(body: .json(.init(
      model: model.lowercased(), arguments: nil, cmdstan: nil,
      verbose: false, install: false, nosummary: nosummary))))
    let result = try response.ok.body.json
    guard result.error.isEmpty else { throw StanIntentError.failed(result.error) }
    return .result(dialog: IntentDialog(stringLiteral: result.status))
  }
}
