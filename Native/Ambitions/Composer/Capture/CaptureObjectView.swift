import SwiftUI

struct CaptureObjectView: View {
    @Binding var text: String

    let input: CaptureInputModel
    let onSubmit: () -> Void
    let onRouteChoice: (SmartAttachmentRouteType) -> Void
    let accessibilityIDs: CaptureAtmosphereComposerAccessibilityIDs
    let shouldAutoFocus: Bool

    private var accessibility: CaptureAccessibility {
        CaptureAccessibility.objectView(input: input)
    }

    var body: some View {
        CaptureAtmosphereComposer(
            text: $text,
            routePreview: input.routePreview,
            error: input.error,
            isSubmitEnabled: CaptureInteractions.canSubmit(input),
            onSubmit: onSubmit,
            onRouteChoice: onRouteChoice,
            accessibilityIDs: accessibilityIDs,
            shouldAutoFocus: shouldAutoFocus
        )
        .accessibilityLabel(accessibility.label)
        .accessibilityValue(accessibility.value)
        .accessibilityHint(accessibility.hint)
    }
}
