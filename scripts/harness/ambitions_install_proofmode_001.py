#!/usr/bin/env python3
"""Install PROOFMODE-001 bounded local app-driving proof router.

Main-only local runner. It writes a deterministic, local-only proof-mode router,
a focused XCTest, and proof documentation. It attempts local validation when
available, commits locally, and never pushes.
"""

from __future__ import annotations

import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from textwrap import dedent

ROOT = Path(__file__).resolve().parents[2]
COMMIT_MESSAGE = "AMB-307 install bounded local app-driving proof router"

SOURCE = "Native/Ambitions/Domain/ProofMode/AppDrivingProofModeRouter.swift"
TEST = "Native/AmbitionsTests/ProofMode/AppDrivingProofModeRouterTests.swift"
DOC = "docs/codex/harness/PROOFMODE_001_APP_DRIVING_PROOF_ROUTER.md"
SUMMARY = "docs/proof/harness/PROOFMODE-001-app-driving-proof-router-summary.md"
PROMPT = "prompts/batches/PROOFMODE-001-app-driving-proof-router.md"

FORBIDDEN_PREFIXES = ("docs/truth/", "build/reports/")
FORBIDDEN_EXACT = {"project.yml", "Package.swift"}
ALLOWED_PATHS = {SOURCE, TEST, DOC, SUMMARY, PROMPT}


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def run(args: list[str], *, check: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(args, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=check)


def git(args: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    proc = run(["git", *args])
    if check and proc.returncode != 0:
        sys.stderr.write(proc.stdout)
        sys.stderr.write(proc.stderr)
        raise SystemExit(proc.returncode)
    return proc


def git_text(args: list[str]) -> str:
    return git(args).stdout.strip()


def require_main_clean() -> None:
    branch = git_text(["branch", "--show-current"])
    if branch != "main":
        raise SystemExit(f"Expected main-only execution. Current branch: {branch}")
    status = git_text(["status", "--porcelain"])
    if status:
        print(status)
        raise SystemExit("Worktree must be clean before running PROOFMODE-001.")


def write(path: str, content: str) -> None:
    target = ROOT / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(dedent(content).lstrip("\n"), encoding="utf-8")


def install_source() -> None:
    write(SOURCE, r'''
    import Foundation

    /// Local-only deterministic proof-mode router for harness validation.
    ///
    /// This type is intentionally pure: it has no persistence writes, no network access,
    /// no clock dependency, and no production user-data mutation. It exists to prove
    /// the shape of Ambitions' same-intent / different-context recommendation moat.
    struct AppDrivingProofModeRouter: Sendable {
        enum EnergyLevel: String, Codable, Sendable, Equatable {
            case low
            case medium
            case high
        }

        struct LocalContext: Codable, Sendable, Equatable {
            let id: String
            let protectedTimeMinutes: Int
            let openWindowMinutes: Int
            let energy: EnergyLevel
            let closureResidueCount: Int
            let sourceFreshnessMinutes: Int

            init(
                id: String,
                protectedTimeMinutes: Int,
                openWindowMinutes: Int,
                energy: EnergyLevel,
                closureResidueCount: Int,
                sourceFreshnessMinutes: Int
            ) {
                self.id = id
                self.protectedTimeMinutes = protectedTimeMinutes
                self.openWindowMinutes = openWindowMinutes
                self.energy = energy
                self.closureResidueCount = closureResidueCount
                self.sourceFreshnessMinutes = sourceFreshnessMinutes
            }
        }

        struct ProofOutput: Codable, Sendable, Equatable {
            let intent: String
            let contextID: String
            let recommendedStep: String
            let whyNow: String
            let timeFit: String
            let plannedMinutes: Int
            let receiptID: String
            let replayID: String
            let sourceFreshness: String
            let claimsNotMade: [String]
        }

        func route(intent: String, context: LocalContext) -> ProofOutput {
            let normalizedIntent = intent.trimmingCharacters(in: .whitespacesAndNewlines)
            let recommendation = recommendationShape(for: context)
            let plannedMinutes = plannedMinutes(for: context)
            let receiptSeed = stableSeed(intent: normalizedIntent, context: context, suffix: "receipt")
            let replaySeed = stableSeed(intent: normalizedIntent, context: context, suffix: "replay")

            return ProofOutput(
                intent: normalizedIntent,
                contextID: context.id,
                recommendedStep: recommendation.step,
                whyNow: recommendation.whyNow,
                timeFit: "Fits \(plannedMinutes)m inside \(context.openWindowMinutes)m open window with \(context.protectedTimeMinutes)m protected.",
                plannedMinutes: plannedMinutes,
                receiptID: "proof-receipt-\(receiptSeed)",
                replayID: "proof-replay-\(replaySeed)",
                sourceFreshness: context.sourceFreshnessMinutes <= 30 ? "fresh" : "stale-review-needed",
                claimsNotMade: Self.claimsNotMade
            )
        }

        func routePair(intent: String, first: LocalContext, second: LocalContext) -> [ProofOutput] {
            [route(intent: intent, context: first), route(intent: intent, context: second)]
        }

        static let certificationExamIntent = "Prepare for a certification exam without burning out."

        static let protectedTimeHeavyContext = LocalContext(
            id: "protected_time_heavy_low_energy",
            protectedTimeMinutes: 420,
            openWindowMinutes: 25,
            energy: .low,
            closureResidueCount: 3,
            sourceFreshnessMinutes: 12
        )

        static let openDeepWorkContext = LocalContext(
            id: "open_deep_work_medium_energy",
            protectedTimeMinutes: 60,
            openWindowMinutes: 95,
            energy: .medium,
            closureResidueCount: 0,
            sourceFreshnessMinutes: 8
        )

        static let claimsNotMade: [String] = [
            "No production user data was mutated.",
            "No cloud AI or hosted inference was used.",
            "No build success claim is made by this router alone.",
            "No UI test success claim is made by this router alone.",
            "No release readiness claim is made.",
            "No TestFlight readiness claim is made.",
            "No App Store readiness claim is made.",
            "No device validation claim is made.",
            "No accessibility validation claim is made.",
            "No privacy/legal approval claim is made."
        ]

        private func recommendationShape(for context: LocalContext) -> (step: String, whyNow: String) {
            if context.energy == .low || context.openWindowMinutes < 35 || context.closureResidueCount > 0 {
                return (
                    "Review one exam topic for 15 minutes and close the loop with a Still Counts note.",
                    "Protected time and recovery pressure make a short, closure-aware step safer than deep work."
                )
            }

            return (
                "Start a 60-minute focused exam practice block with proof notes after completion.",
                "A longer open window and steadier energy can support focused progress without forcing the day."
            )
        }

        private func plannedMinutes(for context: LocalContext) -> Int {
            if context.energy == .low || context.openWindowMinutes < 35 || context.closureResidueCount > 0 {
                return min(15, max(10, context.openWindowMinutes))
            }
            return min(60, max(30, context.openWindowMinutes - 15))
        }

        private func stableSeed(intent: String, context: LocalContext, suffix: String) -> String {
            let raw = "\(intent)|\(context.id)|\(context.protectedTimeMinutes)|\(context.openWindowMinutes)|\(context.energy.rawValue)|\(context.closureResidueCount)|\(context.sourceFreshnessMinutes)|\(suffix)"
            let hash = raw.unicodeScalars.reduce(UInt64(1469598103934665603)) { partial, scalar in
                (partial ^ UInt64(scalar.value)) &* 1099511628211
            }
            return String(hash, radix: 16)
        }
    }
    ''')


def install_tests() -> None:
    write(TEST, r'''
    import XCTest
    @testable import Ambitions

    final class AppDrivingProofModeRouterTests: XCTestCase {
        func testSameIntentDifferentLocalContextsProduceDifferentInspectableOutputs() {
            let router = AppDrivingProofModeRouter()

            let outputs = router.routePair(
                intent: AppDrivingProofModeRouter.certificationExamIntent,
                first: AppDrivingProofModeRouter.protectedTimeHeavyContext,
                second: AppDrivingProofModeRouter.openDeepWorkContext
            )

            XCTAssertEqual(outputs.count, 2)
            XCTAssertEqual(Set(outputs.map(\.intent)), [AppDrivingProofModeRouter.certificationExamIntent])
            XCTAssertNotEqual(outputs[0].contextID, outputs[1].contextID)
            XCTAssertNotEqual(outputs[0].recommendedStep, outputs[1].recommendedStep)
            XCTAssertNotEqual(outputs[0].plannedMinutes, outputs[1].plannedMinutes)
            XCTAssertNotEqual(outputs[0].whyNow, outputs[1].whyNow)
            XCTAssertTrue(outputs[0].recommendedStep.localizedCaseInsensitiveContains("Still Counts"))
            XCTAssertTrue(outputs[1].recommendedStep.localizedCaseInsensitiveContains("focused exam practice"))
            XCTAssertTrue(outputs[0].timeFit.contains("Fits"))
            XCTAssertTrue(outputs[1].timeFit.contains("Fits"))
            XCTAssertTrue(outputs[0].receiptID.hasPrefix("proof-receipt-"))
            XCTAssertTrue(outputs[0].replayID.hasPrefix("proof-replay-"))
        }

        func testProofModeRouterIsDeterministicForSameIntentAndContext() {
            let router = AppDrivingProofModeRouter()

            let first = router.route(
                intent: AppDrivingProofModeRouter.certificationExamIntent,
                context: AppDrivingProofModeRouter.protectedTimeHeavyContext
            )
            let second = router.route(
                intent: AppDrivingProofModeRouter.certificationExamIntent,
                context: AppDrivingProofModeRouter.protectedTimeHeavyContext
            )

            XCTAssertEqual(first, second)
        }

        func testProofModeRouterKeepsNonClaimBoundariesVisible() {
            let output = AppDrivingProofModeRouter().route(
                intent: AppDrivingProofModeRouter.certificationExamIntent,
                context: AppDrivingProofModeRouter.openDeepWorkContext
            )

            XCTAssertTrue(output.claimsNotMade.contains("No production user data was mutated."))
            XCTAssertTrue(output.claimsNotMade.contains("No cloud AI or hosted inference was used."))
            XCTAssertTrue(output.claimsNotMade.contains("No release readiness claim is made."))
            XCTAssertFalse(output.claimsNotMade.isEmpty)
        }
    }
    ''')


def install_docs() -> None:
    write(PROMPT, '''
    <!-- AMBITIONS_RUNNER_REQUIRED: true -->
    <!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
    <!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

    # PROOFMODE-001 — Bounded Local App-Driving Proof Router

    Issue: AMB-307

    ## Control Plane

    - Main-only execution.
    - No `docs/truth/*` edits.
    - No production user-data mutation.
    - No cloud AI, hosted inference, analytics, backend, telemetry, tracking, signing, or App Store automation.
    - No release, TestFlight, App Store, device, accessibility, privacy/legal, or app-completion claims.
    ''')

    write(DOC, '''
    # PROOFMODE-001 App-Driving Proof Router

    Status: Bounded source proof seam installed
    Issue: AMB-307

    ## Purpose

    This installs a deterministic, local-only proof-mode router for the Ambitions moat scenario: the same user intent plus different local contexts should produce different, inspectable recommendation outputs.

    ## Installed Source

    - `Native/Ambitions/Domain/ProofMode/AppDrivingProofModeRouter.swift`
    - `Native/AmbitionsTests/ProofMode/AppDrivingProofModeRouterTests.swift`

    ## Scenario

    Intent: prepare for a certification exam without burning out.

    Context A: protected-time heavy, low energy, closure residue present. Expected shape: short recovery-aware recommended step.

    Context B: longer open window, medium energy, no closure residue. Expected shape: focused exam practice block.

    ## Boundaries

    The router is pure and deterministic. It does not persist data, call a network, use cloud AI, or mutate production user data.

    ## Claims Not Made

    - No full app-driving proof completion claim.
    - No full Private Life Runtime completion claim.
    - No build success claim without local logs.
    - No UI test success claim.
    - No accessibility validation claim.
    - No device validation claim.
    - No privacy/legal approval claim.
    - No TestFlight claim.
    - No App Store claim.
    - No release readiness claim.
    ''')


def attempt_validation() -> tuple[int, int, str, str]:
    xcodegen = run(["xcodegen", "generate"])
    test_log = ROOT / "build" / "reports" / "harness" / "PROOFMODE-001-xcodebuild-test.log"
    test_log.parent.mkdir(parents=True, exist_ok=True)

    if xcodegen.returncode != 0:
        test_log.write_text(xcodegen.stdout + xcodegen.stderr, encoding="utf-8")
        return xcodegen.returncode, -1, "xcodegen generate", str(test_log.relative_to(ROOT))

    test = run([
        "xcodebuild",
        "test",
        "-project", "Ambitions.xcodeproj",
        "-scheme", "Ambitions",
        "-destination", "platform=iOS Simulator,name=iPhone 17",
        "-only-testing:AmbitionsTests/AppDrivingProofModeRouterTests",
        "CODE_SIGNING_ALLOWED=NO",
    ])
    test_log.write_text(test.stdout + test.stderr, encoding="utf-8")
    return xcodegen.returncode, test.returncode, "xcodegen generate; focused xcodebuild test", str(test_log.relative_to(ROOT))


def write_summary(xcodegen_exit: int, test_exit: int, validation: str, log_path: str) -> None:
    status = "Green" if xcodegen_exit == 0 and test_exit == 0 else "Yellow"
    write(SUMMARY, f'''
    # PROOFMODE-001 App-Driving Proof Router Summary

    Status: {status}
    Issue: AMB-307
    Created UTC: {utc_now()}

    ## Installed Files

    - `{SOURCE}`
    - `{TEST}`
    - `{DOC}`
    - `{PROMPT}`

    ## Validation Attempted

    - {validation}
    - xcodegen exit: {xcodegen_exit}
    - focused test exit: {test_exit}
    - local log path: `{log_path}`

    ## Proof Result

    The source-level proof router is deterministic and local-only. The focused test verifies that the same intent with two different contexts produces different recommended outputs and keeps explicit non-claim boundaries.

    ## Claims Not Made

    - No full Ambitions implementation completion claim.
    - No full app-driving proof completion claim.
    - No release readiness claim.
    - No TestFlight readiness claim.
    - No App Store readiness claim.
    - No device validation claim.
    - No accessibility validation claim.
    - No privacy/legal approval claim.
    ''')


def stage_and_commit() -> None:
    git(["add", SOURCE, TEST, DOC, SUMMARY, PROMPT])
    staged = git_text(["diff", "--cached", "--name-only"]).splitlines()
    forbidden = [p for p in staged if p.startswith("docs/truth/") or p.startswith("build/reports/") or p in {"project.yml", "Package.swift"}]
    if forbidden:
        raise SystemExit("Forbidden staged paths:\n" + "\n".join(forbidden))
    if not staged:
        print("No staged changes; nothing to commit.")
        return
    git(["commit", "-m", COMMIT_MESSAGE])
    print(git_text(["log", "-1", "--oneline"]))


def main() -> int:
    require_main_clean()
    install_source()
    install_tests()
    install_docs()
    xcodegen_exit, test_exit, validation, log_path = attempt_validation()
    write_summary(xcodegen_exit, test_exit, validation, log_path)
    stage_and_commit()
    print("\nPush command:\n  git push origin main")
    print("\nAfter pushing, tell ChatGPT:\n  proofmode pushed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
