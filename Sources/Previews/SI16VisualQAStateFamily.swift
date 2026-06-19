#if canImport(SwiftUI)
import SwiftUI

public enum SI16VisualQAStateFamily: String, CaseIterable, Identifiable, Sendable {
    case normal
    case selected
    case focused
    case loading
    case empty
    case disabled
    case degraded
    case privacySensitive
    case reducedMotion
    case dynamicType
    case staleSource
    case partialSource
    case offlineLocalOnly
    case blocked
    case waiting
    case needsReview
    case recovery
    case overwhelmingDay
    case setupNeeded
    case deniedSource
    case noDataYet

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .normal: "Normal"
        case .selected: "Selected"
        case .focused: "Focused"
        case .loading: "Loading"
        case .empty: "Empty"
        case .disabled: "Disabled"
        case .degraded: "Error or degraded"
        case .privacySensitive: "Privacy-sensitive"
        case .reducedMotion: "Reduced Motion"
        case .dynamicType: "Dynamic Type"
        case .staleSource: "Stale source"
        case .partialSource: "Partial source"
        case .offlineLocalOnly: "Offline or local-only"
        case .blocked: "Blocked"
        case .waiting: "Waiting"
        case .needsReview: "Needs review"
        case .recovery: "Recovery"
        case .overwhelmingDay: "Overwhelming day"
        case .setupNeeded: "Setup needed"
        case .deniedSource: "Denied source"
        case .noDataYet: "No data yet"
        }
    }

    public var loadingState: AmbitionsLoadingState {
        switch self {
        case .normal, .selected, .focused, .dynamicType, .reducedMotion:
            return .empty
        case .loading:
            return .loading
        case .empty:
            return .empty
        case .disabled:
            return .disabledPendingValidation
        case .degraded:
            return .sourceConflict
        case .privacySensitive:
            return .privacySensitive
        case .staleSource:
            return .staleSource
        case .partialSource:
            return .partialSource
        case .offlineLocalOnly:
            return .localOnly
        case .blocked:
            return .unsafeBlocked
        case .waiting:
            return .waiting
        case .needsReview:
            return .needsReview
        case .recovery:
            return .recovery
        case .overwhelmingDay:
            return .overwhelmingDay
        case .setupNeeded:
            return .setupNeeded
        case .deniedSource:
            return .deniedSource
        case .noDataYet:
            return .noDataYet
        }
    }
}
#endif
