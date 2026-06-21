import AmbitionsDesignSystem
import SwiftUI

enum ObjectStageRole: String, CaseIterable, Sendable {
    case rootPrimaryObject
    case detailObject
    case overlayObject
}

struct ObjectStage<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    let role: ObjectStageRole
    let accessibilityIdentifier: String
    let content: Content

    init(
        role: ObjectStageRole = .rootPrimaryObject,
        accessibilityIdentifier: String,
        @ViewBuilder content: () -> Content
    ) {
        self.role = role
        self.accessibilityIdentifier = accessibilityIdentifier
        self.content = content()
    }

    var body: some View {
        content
            .padding(AmbitionsSpacing(theme: theme).primaryObjectPadding)
            .background(SurfaceMorphBackdrop(role: role))
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(accessibilityIdentifier)
    }
}
