
import Foundation

/// Typed global Capture presentation contract.
///
/// Capture is global input and placement, not a root tab. Root shell code can use
/// this as the single route language for Open Field, placement, and clarification
/// flows without inventing a sixth destination.
enum CapturePresentation: Identifiable, Hashable, Sendable {
    case openField(seed: String?, source: CaptureEntrySource)
    case placement(heldObjectID: String)
    case clarification(heldObjectID: String)

    var id: String {
        switch self {
        case let .openField(seed, source):
            "open-field-\(source.rawValue)-\(seed ?? "empty")"
        case let .placement(heldObjectID):
            "placement-\(heldObjectID)"
        case let .clarification(heldObjectID):
            "clarification-\(heldObjectID)"
        }
    }
}

enum CaptureEntrySource: String, Sendable {
    case shellHeader
    case commandSheet
    case today
    case shortcut
    case url
}
