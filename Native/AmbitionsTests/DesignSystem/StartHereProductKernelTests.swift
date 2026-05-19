import AmbitionsDesignSystem
import XCTest

final class StartHereProductKernelTests: XCTestCase {
    func testKernelRequiresStartHereProofStructure() {
        let kernel = makeKernel()

        XCTAssertTrue(kernel.hasRequiredProof)
        XCTAssertTrue(StartHereProductKernelAudit.failures(for: kernel).isEmpty)
        XCTAssertTrue(kernel.accessibilitySummary.contains("Start here"))
        XCTAssertTrue(kernel.accessibilitySummary.contains("Fits before work"))
        XCTAssertTrue(kernel.accessibilitySummary.contains("Receipt stays attached"))
    }

    func testKernelRejectsMissingProofFactDetail() {
        let kernel = makeKernel(
            contextEdge: StartHereProductFact(id: "context", title: "Why now", summary: "Open capacity", detail: "")
        )

        XCTAssertFalse(kernel.hasRequiredProof)
        XCTAssertTrue(StartHereProductKernelAudit.failures(for: kernel).contains("missing required Start Here proof structure"))
    }

    func testKernelRejectsGenericRecommendationLanguage() {
        let kernel = makeKernel(label: "Start here", becauseLine: "This is your best next move.")

        XCTAssertTrue(StartHereProductKernelAudit.failures(for: kernel).contains("banned phrase: best next move"))
    }

    func testKernelRequiresCanonicalPrimaryAction() {
        let kernel = makeKernel(primaryActionTitle: "Begin Focus")

        XCTAssertTrue(StartHereProductKernelAudit.failures(for: kernel).contains("primary action must be Start now or Open step"))
    }

    func testKernelBindsStartHereRoleWithoutDashboardOrTaskLanguage() {
        let kernel = makeKernel()

        XCTAssertEqual(kernel.fe04Role, .startHere)
        XCTAssertEqual(kernel.fe04Role.ownerSurface, "Today")
        XCTAssertTrue(kernel.accessibilitySummary.localizedCaseInsensitiveContains("Start here"))
        XCTAssertFalse(kernel.accessibilitySummary.localizedCaseInsensitiveContains("dashboard"))
        XCTAssertFalse(kernel.accessibilitySummary.localizedCaseInsensitiveContains("task list"))
        XCTAssertFalse(kernel.accessibilitySummary.localizedCaseInsensitiveContains("release ready"))
    }

    private func makeKernel(
        label: String = "Start here",
        becauseLine: String = "Because your calendar has a clean 30-minute opening.",
        contextEdge: StartHereProductFact = StartHereProductFact(id: "context", title: "Why now", summary: "Open capacity", detail: "Calendar and protected time checked"),
        primaryActionTitle: String = "Start now"
    ) -> StartHereProductKernel {
        StartHereProductKernel(
            label: label,
            title: "Draft launch notes",
            subtitle: "A focused step that keeps the goal moving.",
            becauseLine: becauseLine,
            durationLabel: "30 min",
            fitLabel: "Fits before work",
            sourceQualityLabel: "Local proof",
            contextEdge: contextEdge,
            timeFitProof: StartHereProductFact(id: "time-fit", title: "Time fit", summary: "Fits before work", detail: "30 minutes plus buffer"),
            goalThread: StartHereProductFact(id: "goal-thread", title: "Goal thread", summary: "Launch prep", detail: "Connected to the active goal"),
            receiptSummary: "Receipt stays attached",
            primaryActionTitle: primaryActionTitle,
            secondaryActionTitle: "Adjust plan"
        )
    }
}
