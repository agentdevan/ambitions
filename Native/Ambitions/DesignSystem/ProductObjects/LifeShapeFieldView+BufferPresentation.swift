import AmbitionsDesignSystem
import SwiftUI

extension LifeShapeFieldView {
    var bufferSegment: LifeShapeSegment {
        suite.field.segments.first { $0.kind == .buffer } ?? LifeShapeSegment(
            kind: .buffer,
            detail: "Room available around the next block.",
            valueLabel: "Room available",
            weight: 0.22,
            visualState: .selected
        )
    }

    var bufferConditionTitle: String {
        let allowed = ["Room available", "Keep light", "Add room", "Needs buffer"]
        return allowed.contains(bufferSegment.valueLabel) ? bufferSegment.valueLabel : "Room available"
    }

    var bufferCaption: String {
        "\(bufferConditionTitle). Schedule room only."
    }

    var bufferDetail: String {
        bufferSegment.detail
    }
}
