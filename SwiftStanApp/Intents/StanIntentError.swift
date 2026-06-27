import Foundation

enum StanIntentError: Error, CustomLocalizedStringResourceConvertible {
  case failed(String)

  var localizedStringResource: LocalizedStringResource {
    switch self {
    case .failed(let msg): return "SwiftStan error: \(msg)"
    }
  }
}
