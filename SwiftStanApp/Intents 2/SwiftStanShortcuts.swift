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
      intent: Csv2JsonIntent(),
      phrases: ["Convert \(.applicationName) CSV to JSON"],
      shortTitle: "CSV→JSON",
      systemImageName: "doc.badge.arrow.up")
    AppShortcut(
      intent: OptimizeModelIntent(),
      phrases: ["Optimize \(.applicationName) model"],
      shortTitle: "Optimize",
      systemImageName: "target")
    AppShortcut(
      intent: PathfinderIntent(),
      phrases: ["Run \(.applicationName) Pathfinder"],
      shortTitle: "Pathfinder",
      systemImageName: "location")
    AppShortcut(
      intent: LaplaceIntent(),
      phrases: ["Run \(.applicationName) Laplace"],
      shortTitle: "Laplace",
      systemImageName: "function")
    AppShortcut(
      intent: GeneratedQuantitiesIntent(),
      phrases: ["Generate \(.applicationName) quantities"],
      shortTitle: "GenQuant",
      systemImageName: "sparkles")
    AppShortcut(
      intent: StansummaryIntent(),
      phrases: ["Summarize \(.applicationName) samples"],
      shortTitle: "Summary",
      systemImageName: "list.bullet.rectangle")
  }
}
