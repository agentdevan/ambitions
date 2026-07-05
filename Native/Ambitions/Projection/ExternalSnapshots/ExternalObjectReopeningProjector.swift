import Foundation

struct ExternalObjectReopeningProjector: Sendable {
    func canonicalRecords(
        gate: ExternalObjectReopeningIndexGate = .disabledUntilProof
    ) -> [ExternalObjectReopeningCanonicalRecord] {
        guard gate.isEnabled else { return [] }
        return ExternalObjectReopeningRoot.allCases.compactMap { root in
            guard let rootFallbackURL = root.fallbackURL else {
                return nil
            }
            return ExternalObjectReopeningCanonicalRecord(
                id: root.rawValue,
                root: root,
                title: root.canonicalTitle,
                rootFallbackURL: rootFallbackURL,
                metadataClass: .canonicalRoot,
                redaction: .safeSummary
            )
        }
    }

    func indexRecords(
        for candidates: [ExternalObjectReopeningCandidate],
        gate: ExternalObjectReopeningIndexGate = .disabledUntilProof
    ) -> [ExternalObjectReopeningIndexRecord] {
        guard gate.isEnabled else { return [] }
        return candidates.compactMap { candidate in
            guard let routeURL = routeURL(for: candidate, origin: .spotlight) else { return nil }
            let redaction = candidate.isSensitive ? ExternalObjectReopeningRedaction.redactedPrivate : .safeSummary
            return ExternalObjectReopeningIndexRecord(
                id: candidate.id,
                kind: candidate.kind,
                domainIdentifier: "ambitions.\(candidate.kind.rawValue)",
                title: safeTitle(for: candidate),
                contentDescription: safeDetail(for: candidate),
                routeURL: routeURL,
                redaction: redaction,
                eligibleForPublicIndexing: false,
                gateReason: gate.reason
            )
        }
    }

    func handoffRecord(for candidate: ExternalObjectReopeningCandidate) -> ExternalObjectReopeningHandoffRecord? {
        guard candidate.kind == .goal || candidate.kind == .currentStep,
              let routeURL = routeURL(for: candidate, origin: .handoff) else {
            return nil
        }
        let token = continuationToken(for: candidate)
        var userInfo: [String: String] = [
            ExternalSurfaceActionPayload.Key.kind: candidate.kind.rawValue,
            "id": candidate.id,
            ExternalSurfaceActionPayload.Key.root: token.root.rawValue,
            ExternalSurfaceActionPayload.Key.metadataClass: token.metadataClass.rawValue,
            ExternalSurfaceActionPayload.Key.redaction: token.redaction.rawValue,
        ]
        if token.metadataClass == .exactReopen {
            if let goalID = nonEmpty(candidate.goalID) {
                userInfo[ExternalSurfaceActionPayload.Key.goalID] = goalID
            }
            if let stepID = nonEmpty(candidate.stepID) {
                userInfo[ExternalSurfaceActionPayload.Key.stepID] = stepID
            }
        }

        return ExternalObjectReopeningHandoffRecord(
            id: candidate.id,
            kind: candidate.kind,
            activityType: candidate.kind.activityType,
            title: safeTitle(for: candidate),
            routeURL: routeURL,
            userInfo: userInfo,
            eligibleForHandoff: true
        )
    }

    func routeURL(
        for candidate: ExternalObjectReopeningCandidate,
        origin: ExternalSurfaceOrigin
    ) -> URL? {
        continuationToken(for: candidate).routeURL(origin: origin)
    }

    func continuationToken(for candidate: ExternalObjectReopeningCandidate) -> ExternalObjectContinuationToken {
        ExternalObjectContinuationToken(
            kind: candidate.kind,
            root: fallbackRoot(for: candidate.kind),
            goalID: nonEmpty(candidate.goalID),
            stepID: nonEmpty(candidate.stepID),
            receiptID: nonEmpty(candidate.receiptID),
            captureID: nonEmpty(candidate.captureID),
            metadataClass: candidate.isSensitive ? .fallbackRoot : .exactReopen,
            redaction: candidate.isSensitive ? .redactedPrivate : .safeSummary
        )
    }
}

extension ExternalObjectReopeningProjector {
    func fallbackRoot(for kind: ExternalObjectReopeningKind) -> ExternalObjectReopeningRoot {
        switch kind {
        case .goal, .currentStep:
            return .goals
        case .receipt:
            return .today
        case .capture:
            return .today
        }
    }

    func safeTitle(for candidate: ExternalObjectReopeningCandidate) -> String {
        guard candidate.isSensitive == false, let title = nonEmpty(candidate.title) else {
            return candidate.kind.safeSystemTitle
        }
        return truncated(title, limit: 64)
    }

    func safeDetail(for candidate: ExternalObjectReopeningCandidate) -> String {
        guard candidate.isSensitive == false, let detail = nonEmpty(candidate.detail) else {
            return "Details stay private until you open Ambitions."
        }
        return truncated(detail, limit: 96)
    }

    func truncated(_ value: String, limit: Int) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > limit else { return trimmed }
        let end = trimmed.index(trimmed.startIndex, offsetBy: limit)
        return String(trimmed[..<end])
    }

    func nonEmpty(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}

extension ExternalObjectContinuationToken {
    var routePayload: [String: String] {
        var payload: [String: String] = [
            ExternalSurfaceActionPayload.Key.kind: kind.rawValue,
            ExternalSurfaceActionPayload.Key.root: root.rawValue,
            ExternalSurfaceActionPayload.Key.metadataClass: metadataClass.rawValue,
            ExternalSurfaceActionPayload.Key.redaction: redaction.rawValue
        ]

        guard metadataClass == .exactReopen else {
            return payload
        }

        if let goalID {
            payload[ExternalSurfaceActionPayload.Key.goalID] = goalID
        }
        if let stepID {
            payload[ExternalSurfaceActionPayload.Key.stepID] = stepID
        }
        if let receiptID {
            payload[ExternalSurfaceActionPayload.Key.receiptID] = receiptID
        }
        if let captureID {
            payload[ExternalSurfaceActionPayload.Key.captureID] = captureID
        }

        return payload
    }

    func routeURL(origin: ExternalSurfaceOrigin) -> URL? {
        guard metadataClass == .exactReopen else {
            return ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: root.rawValue, origin: origin)
        }

        switch kind {
        case .goal:
            guard let goalID else {
                return ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: root.rawValue, origin: origin)
            }
            return ExternalSurfaceActionPayload.deepLinkURL(
                surface: .goalDetail,
                goalID: goalID,
                origin: origin
            )
        case .currentStep:
            guard let goalID else {
                return ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: root.rawValue, origin: origin)
            }
            guard var components = ExternalSurfaceActionPayload.deepLinkURL(
                surface: .goalDetail,
                goalID: goalID,
                origin: origin
            ).flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false) }) else {
                return nil
            }
            if let stepID {
                var queryItems = components.queryItems ?? []
                queryItems.append(URLQueryItem(name: ExternalSurfaceActionPayload.Key.stepID, value: stepID))
                components.queryItems = queryItems
            }
            return components.url
        case .receipt:
            if let receiptID {
                return externalObjectMemoryLensURL(query: "receipt:\(receiptID)", origin: origin)
            }
            return ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: root.rawValue, origin: origin)
        case .capture:
            guard var components = ExternalSurfaceActionPayload.deepLinkURL(surface: .captureComposer, origin: origin).flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false) }) else {
                return ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: root.rawValue, origin: origin)
            }
            if let captureID {
                var queryItems = components.queryItems ?? []
                queryItems.append(URLQueryItem(name: ExternalSurfaceActionPayload.Key.captureID, value: captureID))
                components.queryItems = queryItems
            }
            return components.url
        }
    }
}

func externalObjectMemoryLensURL(query: String, origin: ExternalSurfaceOrigin) -> URL? {
    var components = URLComponents()
    components.scheme = "ambitions"
    components.host = "overlay"
    components.path = "/memory-lens"
    components.queryItems = [
        URLQueryItem(name: "intent", value: "memory_lens"),
        URLQueryItem(name: "q", value: query),
        URLQueryItem(name: "origin", value: origin.rawValue),
    ]
    return components.url
}
