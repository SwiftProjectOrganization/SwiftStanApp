import Foundation

enum ServerSettings {
  static func serverURL() -> URL {
    let stored = UserDefaults.standard.string(forKey: "serverURL") ?? ""
    let urlString = stored.isEmpty ? "http://127.0.0.1:8080" : stored
    return URL(string: urlString) ?? URL(string: "http://127.0.0.1:8080")!
  }
}
