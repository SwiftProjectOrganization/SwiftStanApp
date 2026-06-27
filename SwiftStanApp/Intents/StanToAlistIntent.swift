import AppIntents
import SwiftStan

struct StanToAlistIntent: AppIntent {
  static let title: LocalizedStringResource = "Stan to alist"
  static let description = IntentDescription(
    "Reverse-translate <model>.stan into <model>.alist.R.")

  @Parameter(title: "Model", default: "bernoulli")
  var model: String

  @Parameter(title: "Force Overwrite", default: false)
  var force: Bool

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let url = try stan2alist(model: model.lowercased(), verbose: false, force: force)
    return .result(dialog: IntentDialog("Wrote \(url.lastPathComponent)"))
  }
}
