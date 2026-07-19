import Foundation

struct CaptureInputModel: Equatable, Sendable {
    let text: String
    let routePreview: CaptureDraftRoutePreview?
    let error: String?
    let presentationMode: CaptureComposerPresentationMode
    let saveStateLabel: String?
    let isSaving: Bool

    init(
        text: String,
        routePreview: CaptureDraftRoutePreview?,
        error: String?,
        presentationMode: CaptureComposerPresentationMode,
        saveStateLabel: String? = nil,
        isSaving: Bool = false
    ) {
        self.text = text
        self.routePreview = routePreview
        self.error = error
        self.presentationMode = presentationMode
        self.saveStateLabel = saveStateLabel
        self.isSaving = isSaving
    }

    var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var hasInput: Bool {
        trimmedText.isEmpty == false
    }

    var isRouteReviewVisible: Bool {
        hasInput && routePreview != nil
    }

    var suggestedRouteLabel: String {
        CaptureCopyPolicy.primaryDisplayLabel(routePreview?.destinationLabel ?? "Private intake")
    }

    var privacyLabel: String {
        CaptureCopyPolicy.primaryDisplayLabel(routePreview?.privacyLabel ?? "Stored locally when saved")
    }

    var postInputStateTitle: String {
        CaptureCopyPolicy.primaryDisplayLabel(routePreview?.postInputStateTitle ?? (hasInput ? "Ready to Place" : "Needs review"))
    }

    var accessibilityValue: String {
        [
            presentationMode.eyebrow,
            postInputStateTitle,
            suggestedRouteLabel,
            privacyLabel,
            routePreview.map { CaptureCopyPolicy.primaryDisplayLabel($0.accessibilityValue) },
            error,
            saveStateLabel,
            isSaving ? "Saving locally" : nil,
        ]
        .compactMap { $0 }
        .joined(separator: ". ")
    }
}
