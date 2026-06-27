import SwiftUI

struct ContentView: View {
  @AppStorage("cmdstanPath") private var cmdstanPath: String = ""

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("SwiftStan")
        .font(.headline)
      Text("Invoke Stan subcommands from Shortcuts, Siri, or Spotlight.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      Divider()
      LabeledContent("cmdstan path") {
        TextField(
          "/Users/rob/Projects/StanSupport/cmdstan",
          text: $cmdstanPath)
          .textFieldStyle(.roundedBorder)
          .font(.system(.body, design: .monospaced))
      }
      Text("Leave blank to use $CMDSTAN or the default path above.")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .padding(24)
    .frame(minWidth: 440)
  }
}
