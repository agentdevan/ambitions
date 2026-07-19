import SwiftUI

struct CaptureSurface: View {
    let presentationMode: CaptureComposerPresentationMode

    init(presentationMode: CaptureComposerPresentationMode = .globalComposer) {
        self.presentationMode = presentationMode
    }

    var body: some View {
        CaptureComposerSurface(shellMode: presentationMode)
            .accessibilityIdentifier("capture.surface.global-composer")
    }
}
