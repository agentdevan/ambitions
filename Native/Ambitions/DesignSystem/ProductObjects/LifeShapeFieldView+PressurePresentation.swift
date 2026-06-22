import AmbitionsDesignSystem
import SwiftUI

extension LifeShapeFieldView {
    var primaryActionTitle: String {
        switch selectedLayer {
        case .open:
            "Place Step"
        case .protected:
            "Protect window"
        case .pressure:
            "Make today lighter"
        case .buffer:
            "Review buffer"
        }
    }

    var nowInstrumentTitle: String {
        selectedLayer == .pressure ? "Pressure" : reading.title
    }

    var nowInstrumentCaption: String {
        selectedLayer == .pressure ? pressureCaption : reading.capacityStatement
    }

    var nowInstrumentDetail: String {
        selectedLayer == .pressure ? pressureDetail : reading.summary
    }

    var nowInstrumentVisualState: AmbitionVisualState {
        selectedLayer == .pressure ? pressureSegment.visualState : suite.field.capacityFit.visualState
    }

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
