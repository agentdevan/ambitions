import AmbitionsDesignSystem
import SwiftUI

extension LifeShapeFieldView {
    var pressureSegment: LifeShapeSegment {
        suite.field.segments.first { $0.kind == .pressure } ?? LifeShapeSegment(
            kind: .pressure,
            detail: "Light pressure. Capacity has room.",
            valueLabel: "Light",
            weight: 0.24,
            visualState: .selected
        )
    }

    var pressureConditionTitle: String {
        let allowed = ["Light", "Crowded", "Tight", "Needs buffer"]
        return allowed.contains(pressureSegment.valueLabel) ? pressureSegment.valueLabel : "Light"
    }

    var pressureCaption: String {
        "\(pressureConditionTitle). Ordinal condition only."
    }

    var pressureDetail: String {
        pressureSegment.detail
    }
}
