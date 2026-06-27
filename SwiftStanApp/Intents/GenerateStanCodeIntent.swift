import AppIntents
import SwiftStan

struct GenerateStanCodeIntent: AppIntent {
  static let title: LocalizedStringResource = "Generate Stan Code"
  static let description = IntentDescription(
    "Translate <model>.alist.R to <model>.stan (in-process, no swiftc).")

  @Parameter(title: "Model", default: "bernoulli")
  var model: String

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let url = try stancode(model: model.lowercased(), verbose: false)
    return .result(dialog: IntentDialog("Wrote \(url.lastPathComponent)"))
  }
}
