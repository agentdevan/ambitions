import Foundation

struct RecoveryState: Codable, Sendable, Equatable, Hashable, Identifiable {
    let state: NowRecoveryState
    let reason: String?
    let proofEventIDs: [String]
    let receiptID: String?
    let reentryStepID: String?

    var id: String { state.rawValue }

    init(
        state: NowRecoveryState,
        reason: String? = nil,
        proofEventIDs: [String] = [],
        receiptID: String? = nil,
        reentryStepID: String? = nil
    ) {
        self.state = state
        self.reason = Self.normalizedOptional(reason)
        self.proofEventIDs = Self.orderedUnique(proofEventIDs)
        self.receiptID = Self.normalizedOptional(receiptID)
        self.reentryStepID = Self.normalizedOptional(reentryStepID)
    }

    init(thread: RecoveryThread) {
        self.init(
            state: thread.status.nowRecoveryState,
            reason: thread.whatChanged ?? thread.trigger,
            proofEventIDs: thread.effectiveProofRefs,
            receiptID: thread.receiptID,
            reentryStepID: thread.reentryStep?.id
        )
    }

    var needsVisibleRecovery: Bool {
        switch state {
        case .stable:
            false
        case .watch, .needsRecovery, .recovering, .blocked:
            true
        }
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.compactMap(normalizedOptional).filter { seen.insert($0).inserted }
    }
}

extension AmbitionRecoveryStatus {
    var nowRecoveryState: NowRecoveryState {
        switch self {
        case .active, .held, .paused:
            .recovering
        case .stalled, .interruptedButStillUseful:
            .needsRecovery
        case .notNeeded, .complete:
            .stable
        }
    }
}

extension RecoveryThread {
    var recoveryState: RecoveryState {
        RecoveryState(thread: self)
    }
}
