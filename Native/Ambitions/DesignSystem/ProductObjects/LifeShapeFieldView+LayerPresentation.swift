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
            "Add buffer"
        }
    }

    var nowInstrumentTitle: String {
        switch selectedLayer {
        case .pressure:
            "Pressure"
        case .buffer:
            "Buffer"
        case .open, .protected:
            reading.title
        }
    }

    var nowInstrumentCaption: String {
        switch selectedLayer {
        case .pressure:
            pressureCaption
        case .buffer:
            bufferCaption
        case .open, .protected:
            reading.capacityStatement
        }
    }

    var nowInstrumentDetail: String {
        switch selectedLayer {
        case .pressure:
            pressureDetail
        case .buffer:
            bufferDetail
        case .open, .protected:
            reading.summary
        }
    }

    var nowInstrumentVisualState: AmbitionVisualState {
        switch selectedLayer {
        case .pressure:
            pressureSegment.visualState
        case .buffer:
            bufferSegment.visualState
        case .open, .protected:
            suite.field.capacityFit.visualState
        }
    }
}
