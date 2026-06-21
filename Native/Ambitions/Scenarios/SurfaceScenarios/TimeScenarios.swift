import Foundation

enum PreviewTimeScenarios {}

extension PreviewTimeScenarios {
    static var amb1165LifeShapeProofInputs: [LifeShapeEngineInput] {
        [
            LifeShapeStressScenarios.emptyManualInput,
            LifeShapeStressScenarios.calendarDeniedManualInput,
            LifeShapeStressScenarios.denseDayInput
        ]
    }
}
