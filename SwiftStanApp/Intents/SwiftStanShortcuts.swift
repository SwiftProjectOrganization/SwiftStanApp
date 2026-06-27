import AppIntents

struct SwiftStanShortcuts: AppShortcutsProvider {
  @AppShortcutsBuilder
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: CompileModelIntent(),
      phrases: ["Compile \(.applicationName) model"],
      shortTitle: "Compile",
      systemImageName: "hammer")
    AppShortcut(
      intent: SampleModelIntent(),
      phrases: ["Sample with \(.applicationName)"],
      shortTitle: "Sample",
      systemImageName: "chart.bar")
    AppShortcut(
      intent: RunUlamPipelineIntent(),
      phrases: ["Run \(.applicationName) pipeline"],
      shortTitle: "Ulam",
      systemImageName: "arrow.triangle.branch")
    AppShortcut(
      intent: GenerateStanCodeIntent(),
      phrases: ["Generate Stan code with \(.applicationName)"],
      shortTitle: "Stancode",
      systemImageName: "doc.text")
    AppShortcut(
      intent: StanToAlistIntent(),
      phrases: ["Convert Stan to alist with \(.applicationName)"],
      shortTitle: "Stan2alist",
      systemImageName: "arrow.uturn.backward")
  }
}
