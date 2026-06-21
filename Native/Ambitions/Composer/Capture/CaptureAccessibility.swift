import Foundation

struct CaptureAccessibility: Equatable, Sendable {
    let label: String
    let value: String
    let hint: String
    let announcement: String?
    let proofArtifactID: String?

    static func composer(
        input: CaptureInputModel,
        proofContract: CaptureComposerMutationProofContract,
        actionMessage: CaptureActionMessage? = nil
    ) -> CaptureAccessibility {
        CaptureAccessibility(
            label: "Capture",
            value: input.accessibilityValue,
            hint: proofContract.submitHint,
            announcement: actionMessage?.accessibilityAnnouncement,
            proofArtifactID: actionMessage?.proofArtifactID
        )
    }

    static func objectView(input: CaptureInputModel) -> CaptureAccessibility {
        CaptureAccessibility(
            label: "Open Field",
            value: input.accessibilityValue,
            hint: input.hasInput ? "Save or review the suggested route." : "Type one real thing before saving.",
            announcement: nil,
            proofArtifactID: nil
        )
    }
}
