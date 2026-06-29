import SwiftUI

struct StanCommandView: View {
    @State private var viewModel = RunViewModel()
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section {
                        Picker("Command", selection: $viewModel.command) {
                            ForEach(StanCommand.allCases) { cmd in
                                Text(cmd.rawValue).tag(cmd)
                            }
                        }
                        TextField("Model", text: $viewModel.model)
                    }
                    commandParameters
                    Section("Advanced") {
                        LabeledContent("Cmdstan path:") {
                            TextField("", text: $viewModel.cmdstanPath)
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
                .formStyle(.grouped)

                Divider()
                runBar
            }
#if os(macOS)
            .frame(minWidth: 560, minHeight: 500)
#endif
            .navigationTitle("SwiftStan")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .task { await viewModel.fetchHealth() }
    }

    @ViewBuilder
    private var commandParameters: some View {
        switch viewModel.command {
        case .sample:
            Section("Sampling Parameters") {
                Toggle("No Summary", isOn: $viewModel.nosummary)
                Toggle("Install Example", isOn: $viewModel.install)
                Toggle("Verbose", isOn: $viewModel.verbose)
                numField("Samples",       $viewModel.numSamplesText,   hint: "1000")
                numField("Warmup",        $viewModel.numWarmupText,    hint: "1000")
                numField("Chains",        $viewModel.numChainsText,    hint: "4")
                numField("Thin",          $viewModel.thinText,         hint: "1")
                numField("Seed",          $viewModel.seedText,         hint: "random")
                numField("Adapt Delta",   $viewModel.adaptDeltaText,   hint: "0.8")
                numField("Max Tree Depth",$viewModel.maxTreedepthText, hint: "10")
            }
        case .compile:
            Section("Compile Options") {
                Toggle("Force Recompile", isOn: $viewModel.force)
                Toggle("Install Example", isOn: $viewModel.install)
                Toggle("Verbose", isOn: $viewModel.verbose)
            }
        case .stan2alist, .ulam:
            Section("Options") {
                Toggle("Force", isOn: $viewModel.force)
                Toggle("Verbose", isOn: $viewModel.verbose)
            }
        case .optimize, .pathfinder, .laplace, .generatedQuantities, .stansummary,
             .csv2json, .alist2dsl, .stancode, .runinfo:
            Section("Options") {
                Toggle("Verbose", isOn: $viewModel.verbose)
            }
        }
    }

    @ViewBuilder
    private var runBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassEffectContainer(spacing: 12) {
                HStack(spacing: 12) {
                    Button("Run") { Task { await viewModel.run() } }
                        .buttonStyle(.glassProminent)
                        .disabled(viewModel.isRunning)
                    if viewModel.isRunning {
                        ProgressView().controlSize(.small)
                        Text("Running\u{2026}").foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }

            switch viewModel.phase {
            case .idle:
                EmptyView()
            case .running:
                EmptyView()
            case .finished(let result):
                resultView(result)
            case .failed(let msg):
                Label(msg, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.system(.callout, design: .monospaced))
                    .textSelection(.enabled)
            }
        }
        .padding(16)
    }

    private func resultView(_ result: StanResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !result.isSuccess {
                Label("Error", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
                    .font(.subheadline.weight(.semibold))
                Text(result.error)
                    .font(.system(.callout, design: .monospaced))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if !result.status.isEmpty {
                Text(result.isSuccess ? "Output" : "Status")
                    .font(.subheadline.weight(.semibold))
                ScrollView {
                    Text(result.status)
                        .font(.system(.callout, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
                .frame(maxHeight: 180)
                .background(.background.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(Color.secondary.opacity(0.3)))
            }
            if let path = result.outputPath, !path.isEmpty {
                HStack {
                    Text("Output:").font(.subheadline.weight(.semibold))
                    Text(path)
                        .font(.system(.callout, design: .monospaced))
                        .textSelection(.enabled)
                    Spacer()
#if os(macOS)
                    Button("Reveal in Finder") {
                        NSWorkspace.shared.activateFileViewerSelecting(
                            [URL(fileURLWithPath: path)])
                    }
                    .buttonStyle(.glass)
#endif
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
