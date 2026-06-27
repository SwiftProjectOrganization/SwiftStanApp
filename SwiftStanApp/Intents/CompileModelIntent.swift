import AppIntents
import SwiftStan

struct CompileModelIntent: AppIntent {
  static let title: LocalizedStringResource = "Compile Stan Model"
  static let description = IntentDescription(
    "Compile a Stan model under ~/Documents/StanCases.")

  @Parameter(title: "Model", default: "bernoulli")
  var model: String

  @Parameter(title: "Force Recompile", default: false)
  var force: Bool

  @Parameter(title: "Install Example", default: false)
  var install: Bool

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let r = compile(
      model: model.lowercased(),
      arguments: [],
      cmdstan: AppSettings.cmdstanPath(),
      verbose: false,
      install: install,
      force: force)
    guard r.1.isEmpty else { throw StanIntentError.failed(r.1) }
    return .result(dialog: IntentDialog("\(r.0)"))
  }
}
