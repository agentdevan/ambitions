import SwiftUI

extension LifeShapeLayer {
    var sweepDegrees: Double {
        switch self {
        case .open:
            8
        case .protected:
            -32
        case .pressure:
            46
        case .buffer:
            88
        }
    }

    var actionSymbol: String {
        switch self {
        case .open:
            "arrow.forward.circle.fill"
        case .protected:
            "lock.fill"
        case .pressure:
            "arrow.down.forward.circle.fill"
        case .buffer:
            "plus.rectangle.fill"
        }
    }

    func centerValue(for field: LifeShapeFieldState, mark: LifeShapeSemanticMark?) -> String {
        switch self {
        case .open:
            field.reading(for: .week).capacityStatement.capacityValue(fallback: "Open")
        case .protected:
            mark?.valueLabel ?? "Protected"
        case .pressure:
            mark?.valueLabel ?? field.capacityFit.title
        case .buffer:
            mark?.valueLabel ?? "Buffer"
        }
    }

    func centerCaption(mark: LifeShapeSemanticMark?) -> String {
        switch self {
        case .open:
            "usable windows"
        case .protected:
            "protected time"
        case .pressure:
            mark?.kind.title ?? "pressure visible"
        case .buffer:
            "transition room"
        }
    }

    func cardTitle(mark: LifeShapeSemanticMark?) -> String {
        switch self {
        case .open:
            "Usable light window"
        case .protected:
            "Protected time"
        case .pressure:
            mark?.kind.title ?? "Pressure"
        case .buffer:
            "Buffer"
        }
    }

    func cardDetail(reading: LifeShapeReading, mark: LifeShapeSemanticMark?) -> String {
        mark?.detail.shortVisualLabel ?? reading.summary.shortVisualLabel
    }

    func centerMetric(for field: LifeShapeFieldState, mark: LifeShapeSemanticMark?) -> LifeShapeCenterMetric {
        let value = centerValue(for: field, mark: mark)
        let words = value.split(separator: " ", maxSplits: 1).map(String.init)
        if let primary = words.first,
           primary.rangeOfCharacter(from: .decimalDigits) != nil {
            return LifeShapeCenterMetric(
                primary: primary,
                secondary: words.dropFirst().first ?? centerCaption(mark: mark),
                caption: centerCaption(mark: mark)
            )
        }

        return LifeShapeCenterMetric(
            primary: value,
            secondary: centerCaption(mark: mark),
            caption: visualLayerCaption
        )
    }

    var visualLayerCaption: String {
        switch self {
        case .open:
            "Open time"
        case .protected:
            "Protected time"
        case .pressure:
            "Pressure"
        case .buffer:
            "Buffer"
        }
    }

    func realitySentence(for field: LifeShapeFieldState, mark: LifeShapeSemanticMark?) -> String {
        switch self {
        case .open:
            if let open = field.segments.first(where: { $0.kind == .openTime }),
               open.weight > 0.65 {
                return "This week is still mostly open."
            }
            return "Use the clearest opening before adding more."
        case .protected:
            if let protected = field.segments.first(where: { $0.kind == .protectedTime }),
               protected.weight > 0 {
                return "Protected time is already marked."
            }
            return "No protected time is marked yet."
        case .pressure:
            return mark?.detail.humanRootCopy ?? "Review the tightest part before adding more."
        case .buffer:
            return "Keep room around the next change."
        }
    }
}

extension LifeShapeSegmentKind {
    var instrumentLayer: LifeShapeLayer {
        switch self {
        case .openTime, .goalTime:
            .open
        case .protectedTime:
            .protected
        case .pressure:
            .pressure
        case .buffer, .recovery, .source:
            .buffer
        }
    }

    var instrumentTitle: String {
        switch self {
        case .openTime:
            "Open"
        case .protectedTime:
            "Protected"
        case .pressure:
            "Pressure"
        case .buffer:
            "Buffer"
        case .recovery:
            "Recovery"
        case .goalTime:
            "Goal"
        case .source:
            "Local"
        }
    }
}

struct LifeShapeCenterMetric {
    let primary: String
    let secondary: String
    let caption: String
}

extension LifeShapeSemanticMarkKind {
    var pointTitle: String {
        switch self {
        case .pressure:
            "Pressure"
        case .cognitiveLoad:
            "Load"
        case .physicalEnergy:
            "Energy"
        case .transitionFriction:
            "Transition"
        case .protectedTime:
            "Protected"
        case .recoveryNeed:
            "Reserve"
        case .freeTimeQuality:
            "Open"
        case .executionLanes:
            "Room"
        case .goalLoad:
            "Goal"
        case .sourceConflict:
            "Source"
        case .receiptReflow:
            "Proof"
        }
    }
}

extension String {
    var shortVisualLabel: String {
        let cleaned = trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.count > 44 else { return cleaned }
        let prefix = cleaned.prefix(41)
        return "\(prefix)..."
    }

    func capacityValue(fallback: String) -> String {
        let cleaned = trimmingCharacters(in: .whitespacesAndNewlines)
        guard let range = cleaned.range(of: "hold ") else {
            return fallback
        }
        let remainder = cleaned[range.upperBound...]
            .replacingOccurrences(of: ",", with: "")
            .split(separator: " ")
            .prefix(3)
            .joined(separator: " ")
        return remainder.isEmpty ? fallback : remainder
    }

    var humanInstrumentValue: String {
        replacingOccurrences(of: " protected", with: " fixed")
            .replacingOccurrences(of: "Local", with: "Local only")
    }

    var humanHorizonValue: String {
        let cleaned = trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.localizedCaseInsensitiveContains("Capacity: qualitative only") {
            return "taking shape"
        }
        if cleaned.localizedCaseInsensitiveContains("No blocks yet") {
            return "no fixed blocks yet"
        }
        return cleaned.shortVisualLabel
    }

    var humanRootCopy: String {
        trimmingCharacters(in: .whitespacesAndNewlines).shortVisualLabel
    }
}
