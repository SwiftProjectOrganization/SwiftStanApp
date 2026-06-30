import SwiftUI

struct SettingsView: View {
    @AppStorage("serverURL") private var serverURL: String = ""
    @AppStorage("cmdstanPath") private var cmdstanPath: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Server URL:") {
                    TextField("http://127.0.0.1:8080", text: $serverURL)
#if os(macOS)
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 240)
#endif
                        .font(.system(.body, design: .monospaced))
                    Text("Leave blank to use the default http://127.0.0.1:8080. SwiftStanServer must be running.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Section("Cmdstan path:") {
                    TextField("seeded from server", text: $cmdstanPath)
#if os(macOS)
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 240)
#endif
                        .font(.system(.body, design: .monospaced))
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
#if os(macOS)
            .frame(width: 480)
            .padding(.bottom)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
#else
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
#endif
        }
    }
}
