import UserNotifications
import XCTest
@testable import Ambitions

final class NotificationResponsePayloadParserTests: XCTestCase {
    func testParserMapsSystemOpenToOpenAction() {
        let parser = NotificationResponsePayloadParser()

        let payload = parser.payload(
            actionIdentifier: UNNotificationDefaultActionIdentifier,
            userInfo: ["goalID": "goal-1", "stepID": "step-1"]
        )

        XCTAssertEqual(payload?.action, "open")
        XCTAssertEqual(payload?.values["goalID"], "goal-1")
        XCTAssertEqual(payload?.values["stepID"], "step-1")
    }

    func testParserMapsSnoozeAndCompleteActions() {
        let parser = NotificationResponsePayloadParser()

        let snooze = parser.payload(actionIdentifier: AppNotificationConstants.snoozeActionID, userInfo: [:])
        let complete = parser.payload(actionIdentifier: AppNotificationConstants.completeActionID, userInfo: [:])

        XCTAssertEqual(snooze?.action, "snooze")
        XCTAssertEqual(complete?.action, "complete")
    }
}
