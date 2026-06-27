import Foundation

enum AppSettings {
  // GUI apps don't inherit the shell's $CMDSTAN via launchd; prefer a stored
  // setting, then the process env (works when launched from a shell), then the
  // historical hardcoded fallback.
  static func cmdstanPath() -> String {
    if let stored = UserDefaults.standard.string(forKey: "cmdstanPath"),
       !stored.isEmpty {
      return stored
    }
    if let env = ProcessInfo.processInfo.environment["CMDSTAN"], !env.isEmpty {
      return env
    }
    return "/Users/rob/Projects/StanSupport/cmdstan"
  }
}
