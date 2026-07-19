import AmbitionsDesignSystem
import Foundation

enum CaptureInteractions {
    static func canSubmit(_ input: CaptureInputModel) -> Bool {
        input.hasInput && input.isSaving == false
    }

    static func shouldResetSelectedRoute(previous: CaptureInputModel, next: CaptureInputModel) -> Bool {
        previous.hasInput && next.hasInput == false
    }

    static func livingState(for input: CaptureInputModel, hasActionReceipt: Bool) -> LivingVisualState {
        if hasActionReceipt {
            return .proof
        }
        if input.isRouteReviewVisible || input.hasInput {
            return .active
        }
        return .empty
    }

    static func routeReceiptMessage(for routeType: SmartAttachmentRouteType) -> String {
        "Route set to \(routeType.userFacingLabel). Save writes that route locally."
    }
}
