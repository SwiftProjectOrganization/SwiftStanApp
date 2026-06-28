import SwiftUI

struct ContentView: View {
  @AppStorage("serverURL") private var serverURL: String = ""

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("SwiftStan")
        .font(.headline)
      Text("Invoke Stan subcommands from Shortcuts, Siri, or Spotlight.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      Divider()
      LabeledContent("Server URL") {
        TextField(
          "http://127.0.0.1:8080",
          text: $serverURL)
          .textFieldStyle(.roundedBorder)
          .font(.system(.body, design: .monospaced))
      }
      Text("Leave blank to use the default http://127.0.0.1:8080. SwiftStanServer must be running.")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .padding(24)
    .frame(minWidth: 440)
  }
}
