import AppIntents
import SwiftStan

struct SampleModelIntent: AppIntent {
  static let title: LocalizedStringResource = "Sample Stan Model"
  static let description = IntentDescription(
    "Run NUTS sampling on a compiled Stan model.")

  @Parameter(title: "Model", default: "bernoulli")
  var model: String

  @Parameter(title: "No Summary", default: false)
  var nosummary: Bool

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let r = sample(
      model: model.lowercased(),
      arguments: [],
      cmdstan: AppSettings.cmdstanPath(),
      verbose: false,
      nosummary: nosummary,
      install: false)
    guard r.1.isEmpty else { throw StanIntentError.failed(r.1) }
    return .result(dialog: IntentDialog("\(r.0)"))
  }
}
