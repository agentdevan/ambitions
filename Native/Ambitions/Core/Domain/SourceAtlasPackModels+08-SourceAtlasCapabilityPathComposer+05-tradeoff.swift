import Foundation

extension SourceAtlasCapabilityPathComposer {

    func tradeoff(
        from rejectedPath: SourceAtlasCapabilityPath,
        against selectedPath: SourceAtlasCapabilityPath
    ) -> SourceAtlasPathTradeoff {
        let scoreDelta = selectedPath.score - rejectedPath.score
        var advantages: [String] = []
        var drawbacks: [String] = []

        if rejectedPath.selectedPathOverlayIDs != selectedPath.selectedPathOverlayIDs {
            drawbacks.append("Different overlay path.")
        }
        if rejectedPath.blockedNodes.count > selectedPath.blockedNodes.count {
            drawbacks.append("Needs more blocker cleanup.")
        }
        if rejectedPath.staleNodes.count > selectedPath.staleNodes.count {
            drawbacks.append("Carries more stale source.")
        }
        if rejectedPath.missingSourceNodes.count > selectedPath.missingSourceNodes.count {
            drawbacks.append("Depends on more missing source nodes.")
        }
        if rejectedPath.planSkeleton.feasibilityBand != selectedPath.planSkeleton.feasibilityBand {
            drawbacks.append("Different feasibility band: \(rejectedPath.planSkeleton.feasibilityBand.accessibilityLabel).")
        }
        if rejectedPath.score > selectedPath.score {
            advantages.append("Scores higher than the selected path.")
        } else if rejectedPath.score < selectedPath.score {
            drawbacks.append("Scores lower than the selected path by \(String(format: "%.2f", scoreDelta)).")
        }

        if advantages.isEmpty {
            advantages.append("Provides an alternate route if the selected path becomes unavailable.")
        }
        if drawbacks.isEmpty {
            drawbacks.append("No clear advantage over the selected path.")
        }

        return SourceAtlasPathTradeoff(
            id: "\(rejectedPath.id).tradeoff",
            pathID: rejectedPath.id,
            summary: "Rejected in favor of \(selectedPath.id).",
            advantages: advantages,
            drawbacks: drawbacks
        )
    }


    func explanationSummary(
        for selectedPath: SourceAtlasCapabilityPath,
        alternatives: [SourceAtlasPathTradeoff]
    ) -> String {
        var parts = [selectedPath.pathSummary]
        if alternatives.isEmpty == false {
            parts.append("Compared against \(alternatives.count) alternative path\(alternatives.count == 1 ? "" : "s").")
        }
        if selectedPath.planSkeleton.feasibilityBand != .comfortablyOnTrack {
            parts.append("Feasibility is \(selectedPath.planSkeleton.feasibilityBand.accessibilityLabel.lowercased()).")
        }
        return parts.joined(separator: " ")
    }


    func explanationReasons(
        for selectedPath: SourceAtlasCapabilityPath,
        alternatives: [SourceAtlasPathTradeoff]
    ) -> [String] {
        var reasons: [String] = []
        if selectedPath.blockedNodes.isEmpty == false {
            reasons.append("Blocked nodes stay visible in the trace: \(selectedPath.blockedNodes.joined(separator: ", ")).")
        }
        if selectedPath.staleNodes.isEmpty == false {
            reasons.append("Stale nodes are preserved for review: \(selectedPath.staleNodes.joined(separator: ", ")).")
        }
        if selectedPath.missingSourceNodes.isEmpty == false {
            reasons.append("Missing source nodes are retained in the trace: \(selectedPath.missingSourceNodes.joined(separator: ", ")).")
        }
        reasons.append("Plan skeleton uses \(selectedPath.planSkeleton.feasibilityBand.accessibilityLabel.lowercased()).")
        reasons.append(contentsOf: alternatives.prefix(2).flatMap(\.drawbacks))
        return reasons
    }


    struct TraversalSnapshot {
        let selectedNodeIDs: [String]
        let selectedEdgeIDs: [String]
        let traversalTrace: [String]
        let blockedNodes: [String]
        let staleNodes: [String]
        let missingSourceNodes: [String]
    }


    static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }


    static func orderedUniquePreservingOrder(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        var ordered: [String] = []
        for value in values {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.isEmpty == false, seen.insert(trimmed).inserted else {
                continue
            }
            ordered.append(trimmed)
        }
        return ordered
    }


    static func tokens(_ text: String) -> Set<String> {
        Set(
            text
                .lowercased()
                .unicodeScalars
                .map { CharacterSet.alphanumerics.contains($0) ? String($0) : " " }
                .joined()
                .split(whereSeparator: \.isWhitespace)
                .map(String.init)
                .filter { $0.isEmpty == false }
        )
    }


    static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}
