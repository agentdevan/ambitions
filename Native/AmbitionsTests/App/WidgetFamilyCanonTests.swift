import AmbitionsWidgetUI
import XCTest

final class WidgetFamilyCanonTests: XCTestCase {
    func testWidgetFamiliesUseRitualAndRhythmVocabulary() {
        let rawValues = Set(AmbitionsWidgetFamily.allCases.map(\.rawValue))

        XCTAssertTrue(rawValues.contains("ritualSummary"))
        XCTAssertTrue(rawValues.contains("ritualRhythm"))
        XCTAssertFalse(rawValues.contains("habitSummary"))
        XCTAssertFalse(rawValues.contains("streak"))
    }
}
