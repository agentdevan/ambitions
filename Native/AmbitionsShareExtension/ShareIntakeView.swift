import SwiftUI

struct ShareIntakeView: View {
    let initialPayload: ShareExtensionPayload
    let onSave: (String, ExternalCreationLanding) -> Void
    let onCancel: () -> Void

    @State private var text: String
    @State private var landing: ExternalCreationLanding = .capturesInbox
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        initialPayload: ShareExtensionPayload,
        onSave: @escaping (String, ExternalCreationLanding) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initialPayload = initialPayload
        self.onSave = onSave
        self.onCancel = onCancel
        _text = State(initialValue: initialPayload.text)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Capture for Ambitions")
                        .font(.title2.weight(.semibold))
                    Text("Saved locally first. Ambitions opens the normal review path so this can become a plan or goal when you are ready.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                TextEditor(text: $text)
                    .font(.body)
                    .frame(minHeight: 150)
                    .padding(10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(.secondary.opacity(0.18))
                    )
                    .accessibilityLabel("Shared capture text")

                Picker("Landing", selection: $landing) {
                    Text("Review in Captures").tag(ExternalCreationLanding.capturesInbox)
                    Text("Start a Goal").tag(ExternalCreationLanding.createGoal)
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Ambitions landing")

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "lock.shield")
                        .foregroundStyle(.teal)
                    Text("This share is handed to the app through the local app group, then imported as a normal Ambitions capture.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(20)
            .navigationTitle("Ambitions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if reduceMotion {
                            onSave(text, landing)
                        } else {
                            withAnimation(.easeOut(duration: 0.12)) {
                                onSave(text, landing)
                            }
                        }
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onChange(of: initialPayload) { _, payload in
                text = payload.text
            }
        }
    }
}
