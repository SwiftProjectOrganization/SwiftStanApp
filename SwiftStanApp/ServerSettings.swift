import Foundation

enum ServerSettings {
  static func serverURL() -> URL {
    let stored = UserDefaults.standard.string(forKey: "serverURL") ?? ""
    let urlString = stored.isEmpty ? "http://127.0.0.1:8080" : stored
    return URL(string: urlString) ?? URL(string: "http://127.0.0.1:8080")!
  }

  static func stanCases() -> String {
    let stored = UserDefaults.standard.string(forKey: "stanCases") ?? ""
    return stored.isEmpty ? "StanCases" : stored
  }

  static func cmdstan() -> String {
    UserDefaults.standard.string(forKey: "cmdstanPath") ?? ""
  }

  static func setCmdstan(_ value: String) {
    UserDefaults.standard.set(value, forKey: "cmdstanPath")
  }
}
