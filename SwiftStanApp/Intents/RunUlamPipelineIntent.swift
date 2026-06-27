import AppIntents
import SwiftStan

struct RunUlamPipelineIntent: AppIntent {
  static let title: LocalizedStringResource = "Run Ulam Pipeline"
  static let description = IntentDescription(
    "Generate Stan code, compile, and sample from an alist or DSL input.")

  @Parameter(title: "Model", default: "bernoulli")
  var model: String

  @Parameter(title: "Force", default: false)
  var force: Bool

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let r = ulamPipeline(
      model: model.lowercased(),
      cmdstan: AppSettings.cmdstanPath(),
      verbose: false,
      force: force,
      arguments: [])
    guard r.1.isEmpty else { throw StanIntentError.failed(r.1) }
    return .result(dialog: IntentDialog("\(r.0)"))
  }
}
