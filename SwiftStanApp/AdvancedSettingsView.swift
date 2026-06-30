import SwiftUI

struct AdvancedSettingsView: View {
    @Bindable var viewModel: RunViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                if viewModel.command == .sample {
                    Section("Sampling") {
                        Toggle("No Summary", isOn: $viewModel.nosummary)
                        Toggle("Install Example", isOn: $viewModel.install)
                        Toggle("Verbose", isOn: $viewModel.verbose)
                        numField("Warmup",         $viewModel.numWarmupText,    hint: "1000")
                        numField("Thin",           $viewModel.thinText,         hint: "1")
                        numField("Seed",           $viewModel.seedText,         hint: "random")
                        numField("Adapt Delta",    $viewModel.adaptDeltaText,   hint: "0.8")
                        numField("Max Tree Depth", $viewModel.maxTreedepthText, hint: "10")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Advanced")
#if os(macOS)
            .frame(minWidth: 420, minHeight: 360)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func numField(_ label: String, _ text: Binding<String>, hint: String) -> some View {
        LabeledContent(label) {
            TextField(hint, text: text)
                .multilineTextAlignment(.trailing)
                .frame(width: 120)
        }
    }
}
