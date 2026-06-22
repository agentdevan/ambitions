import SwiftUI

extension LifeShapeLayer {
    var tint: Color {
        switch self {
        case .open:
            Color(red: 0.48, green: 0.95, blue: 0.60)
        case .protected:
            Color(red: 0.28, green: 0.58, blue: 1.0)
        case .pressure:
            Color(red: 1.0, green: 0.55, blue: 0.20)
        case .buffer:
            Color(red: 0.68, green: 0.38, blue: 1.0)
        }
    }

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
            "open layer"
        case .protected:
            "protected layer"
        case .pressure:
            "pressure layer"
        case .buffer:
            "buffer layer"
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
}
