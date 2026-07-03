@testable import Ambitions
import XCTest

final class TimeEngineTests: XCTestCase {
    private let now = ISO8601DateFormatter().date(from: "2027-02-19T12:20:00Z")!

    func testTimeEngineOwnerFilesExistUnderCanonicalTreeAndOldPolicyOwnersAreRemoved() throws {
        let root = try repoRoot()
        let requiredPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LifeCalendarStore.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/TimeBlockGraph.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ProtectedTimeEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ConstraintEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/CapacityEnvelopeEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/RecurrenceEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ConflictProposalEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/PlacementEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/RecoveryWindowEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/TemporalMath.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ProtectedStepPlacementPolicy.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/PriorityPlacementPolicy.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LocalScheduleBlockFileStore.swift",
        ]

        for path in requiredPaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent(removedRuntimeOwnerPath("ProtectedStepPlacementPolicy.swift")).path),
            "Protected placement policy must be owned by Core/LocalRuntimeOS/TimeEngine."
        )
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent(removedRuntimeOwnerPath("PriorityPlacementPolicy.swift")).path),
            "Priority placement policy must be owned by Core/LocalRuntimeOS/TimeEngine."
        )
        let realityModels = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Core/Domain/RealityModels.swift"),
            encoding: .utf8
        )
        XCTAssertFalse(realityModels.contains("saveLocalScheduleBlocks"), "Local schedule file writes must not live in Core/Domain/RealityModels.swift.")
        XCTAssertFalse(realityModels.contains("FileManager.default"), "Reality domain models must not own local schedule file IO.")
    }

    func testPlacementEngineBlocksAutomaticProtectedPlacementBeforeMutation() throws {
        let command = placementCommand(
            actor: .system,
            start: now.addingTimeInterval(2 * 24 * 60 * 60),
            approved: false
        )

        let decision = try XCTUnwrap(
            PlacementEngine().evaluate(
                command: command,
                context: CommandExecutionContext(now: now, actor: .system, sourceSurface: "Time")
            )
        )

        XCTAssertEqual(decision.protectedPlacementDecision.kind, .blockedFromSilentMovement)
        XCTAssertEqual(decision.protectedPlacementDecision.trigger, .automatic)
        XCTAssertTrue(decision.requiresReviewBeforeMutation)
        XCTAssertFalse(decision.canCommit)
        XCTAssertTrue(decision.runtimeTrace.satisfiesRuntimeSpine)
    }

    func testPlacementEngineSurfacesGraphConflictEvenWhenUserApprovedProtectedMove() throws {
        let proposedStart = now.addingTimeInterval(2 * 24 * 60 * 60)
        let protectedBlock = TimeBlock(
            title: "Protected focus",
            start: proposedStart,
            end: proposedStart.addingTimeInterval(60 * 60),
            kind: .protected,
            source: .user
        )
        let graph = TimeBlockGraph(blocks: [protectedBlock])
        let command = placementCommand(actor: .user, start: proposedStart, approved: true)

        let decision = try XCTUnwrap(
            PlacementEngine().evaluate(
                command: command,
                context: CommandExecutionContext(now: now, actor: .user, sourceSurface: "Time"),
                graph: graph
            )
        )

        XCTAssertEqual(decision.protectedPlacementDecision.kind, .allowed)
        XCTAssertTrue(decision.requiresReviewBeforeMutation)
        XCTAssertFalse(decision.canCommit)
        XCTAssertTrue(decision.conflictProposals.contains { $0.kind == .holdForReview })
        XCTAssertTrue(decision.conflictProposals.contains { $0.kind == .keepExistingPlacement })
        XCTAssertTrue(decision.protectedEvaluation.constraintEvaluation.blockingViolations.contains { $0.kind == .overlappingBlocks })
    }

    func testRecurrenceEngineKeepsLocalWallClockAcrossDST() throws {
        let timeZone = try XCTUnwrap(TimeZone(identifier: "America/New_York"))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let start = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 3, day: 7, hour: 9, minute: 0)))
        let seed = TimeRecurrenceSeed(
            id: "daily-review",
            title: "Daily review",
            startsAt: start,
            rule: TimeRecurrenceRule(cadenceDays: 1, timeZone: timeZone)
        )

        let occurrences = RecurrenceEngine().occurrences(seed: seed, from: start, limit: 3)

        XCTAssertEqual(occurrences.count, 3)
        XCTAssertEqual(occurrences.map { calendar.component(.hour, from: $0.scheduledAt) }, [9, 9, 9])
        XCTAssertEqual(occurrences.map { calendar.component(.day, from: $0.scheduledAt) }, [7, 8, 9])
        XCTAssertTrue(occurrences.allSatisfy { $0.runtimeTrace.satisfiesRuntimeSpine })
    }

    func testLifeCalendarStorePersistsAndReloadsLocalBlocks() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("ambitions-time-engine-\(UUID().uuidString)")
            .appendingPathComponent("life-calendar.json")
        let block = TimeBlock(
            title: "Draft section",
            start: now,
            end: now.addingTimeInterval(45 * 60),
            kind: .scheduledStep,
            source: .command,
            stepID: "step-draft",
            commandID: "command-time-draft"
        )
        let store = LifeCalendarStore(fileURL: fileURL)

        let receipt = try await store.save(block, occurredAt: now)
        let reloaded = LifeCalendarStore(fileURL: fileURL)
        _ = try await reloaded.loadFromDisk()
        let graph = await reloaded.graph()
        let objectStates = await reloaded.objectStateRecords()

        XCTAssertTrue(receipt.runtimeTrace.satisfiesRuntimeSpine)
        XCTAssertEqual(graph.blocks.map(\.id), [block.id])
        XCTAssertEqual(objectStates.first?.id, block.id)
        XCTAssertEqual(objectStates.first?.privacyClass, .privateConstraint)
    }

    private func placementCommand(actor: AmbitionsCommandActor, start: Date, approved: Bool) -> AmbitionsCommand {
        let end = start.addingTimeInterval(30 * 60)
        return AmbitionsCommand(
            id: "command.time.place.\(actor.rawValue).\(approved ? "approved" : "held")",
            kind: .placeStepInTime,
            source: .time,
            target: AmbitionsCommandTarget(goalID: "goal-draft", timeID: "time-window", stepID: "step-draft"),
            payload: AmbitionsCommandPayload(
                title: "Draft the section",
                metadata: [
                    "proposedStartAt": TemporalMath.string(from: start),
                    "proposedEndAt": TemporalMath.string(from: end),
                    "placementTrigger": actor == .system ? ProtectedStepPlacementTrigger.automatic.rawValue : ProtectedStepPlacementTrigger.userInitiated.rawValue,
                    "explicitUserApproval": approved ? "true" : "false",
                    "protectedPlacementAutomationPolicy": ProtectedStepPlacementAutomationPolicy.allowedByExistingPolicy.rawValue,
                ]
            ),
            createdAt: TemporalMath.string(from: now),
            actor: actor,
            sourceSurface: "Time"
        )
    }
}

private extension TimeEngineTests {
    func repoRoot() throws -> URL {
        var candidate = URL(fileURLWithPath: #filePath)
        while candidate.path != "/" {
            if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("project.yml").path) {
                return candidate
            }
            candidate.deleteLastPathComponent()
        }
        throw NSError(domain: "TimeEngineTests", code: 1)
    }
}
