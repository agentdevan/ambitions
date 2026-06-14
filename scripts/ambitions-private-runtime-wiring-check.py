#!/usr/bin/env python3
"""Repo-derived Private Life Runtime to frontend wiring gauntlet."""

from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "build/reports/intelligence-consolidation"
LINEAR_ISSUE = "AMB-41"
LINEAR_URL = "https://linear.app/ambitionsos/issue/AMB-41/add-runtime-to-frontend-wiring-gauntlet"


@dataclass(frozen=True)
class EvidenceCheck:
    label: str
    path: str
    patterns: tuple[str, ...]
    mode: str = "all"


@dataclass(frozen=True)
class RuntimeSystem:
    id: str
    title: str
    source: tuple[EvidenceCheck, ...]
    wiring: tuple[EvidenceCheck, ...]
    ui: tuple[EvidenceCheck, ...]
    tests: tuple[EvidenceCheck, ...]


def read(path: str) -> str:
    full = ROOT / path
    if not full.exists():
        return ""
    return full.read_text(encoding="utf-8", errors="replace")


def present(path: str) -> bool:
    return (ROOT / path).exists()


def check_evidence(check: EvidenceCheck) -> dict[str, object]:
    text = read(check.path)
    if not text:
        return {
            "label": check.label,
            "path": check.path,
            "status": "missing",
            "missing_patterns": list(check.patterns),
        }
    hits = [pattern for pattern in check.patterns if pattern in text]
    if check.mode == "all":
        passed = len(hits) == len(check.patterns)
    elif check.mode == "any":
        passed = bool(hits)
    else:
        passed = len(hits) == len(check.patterns)
    return {
        "label": check.label,
        "path": check.path,
        "status": "passed" if passed else "failed",
        "matched_patterns": hits,
        "missing_patterns": [pattern for pattern in check.patterns if pattern not in hits],
    }


def evaluate_group(checks: tuple[EvidenceCheck, ...]) -> tuple[str, list[dict[str, object]]]:
    if not checks:
        return "not_applicable", []
    results = [check_evidence(check) for check in checks]
    statuses = {str(result["status"]) for result in results}
    if "missing" in statuses or "failed" in statuses:
        return "unproven", results
    return "verified", results


def runtime_systems() -> list[RuntimeSystem]:
    factory = "Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift"
    contracts = "Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift"
    kernel = "Native/Ambitions/Runtime/PrivateLifeRuntimeKernelContracts.swift"
    container = "Native/Ambitions/App/AppContainerFactory.swift"
    root = "Native/Ambitions/App/AmbitionsRootView.swift"
    app_container = "Native/Ambitions/App/AppContainer.swift"
    app_tests = "Native/AmbitionsTests/App/CoreSurfaceIntegrationScenarioTests.swift"
    boundary_tests = "Native/AmbitionsTests/Runtime/AmbitionsRuntimeBoundaryTests.swift"
    root_environment = "Native/Ambitions/App/AppEnvironment.swift"

    return [
        RuntimeSystem(
            id="private_life_runtime_kernel",
            title="Private Life Runtime Kernel",
            source=(EvidenceCheck("kernel contract source", kernel, ("PrivateLifeRuntimeKernelContracting", "PrivateLifeRuntimeKernelDecisionInput", "PrivateLifeRuntimeKernelDecisionOutput")),),
            wiring=(
                EvidenceCheck("factory creates kernel", factory, ("let privateLifeRuntimeKernel = PrivateLifeRuntimeKernel()", "privateLifeRuntimeKernel: privateLifeRuntimeKernel")),
                EvidenceCheck("runtime stores kernel", contracts, ("let privateLifeRuntimeKernel: PrivateLifeRuntimeKernel", "self.privateLifeRuntimeKernel = privateLifeRuntimeKernel")),
            ),
            ui=(EvidenceCheck("top-level environment exposes runtime capability", root_environment, ("appRuntimeCapability", "container.runtimeCapability"), "all"),),
            tests=(EvidenceCheck("runtime boundary test observes kernel", boundary_tests, ("runtime.privateLifeRuntimeKernel.boundary", "isLocalOnly")),),
        ),
        RuntimeSystem(
            id="goal_intelligence_service",
            title="Runtime Goal Intelligence Service",
            source=(EvidenceCheck("goal intelligence source", "Native/Ambitions/Runtime/AmbitionsRuntimeGoalIntelligence.swift", ("RuntimeGoalIntelligenceServicing", "RepositoryBackedRuntimeGoalIntelligenceService")),),
            wiring=(
                EvidenceCheck("factory creates and injects goal intelligence", factory, ("RepositoryBackedRuntimeGoalIntelligenceService", "goalIntelligenceService: goalIntelligenceService")),
                EvidenceCheck("runtime stores goal intelligence", contracts, ("let goalIntelligenceService: any RuntimeGoalIntelligenceServicing", "self.goalIntelligenceService = goalIntelligenceService")),
            ),
            ui=(
                EvidenceCheck("Today service can receive runtime intelligence", "Native/Ambitions/Features/Today/TodayFeatureService.swift", ("goalIntelligenceService", "loadContexts")),
                EvidenceCheck("Goals service can receive runtime intelligence", "Native/Ambitions/Features/Goals/GoalsFeatureService.swift", ("goalIntelligenceService", "loadContext")),
            ),
            tests=(
                EvidenceCheck("container exposes runtime intelligence", "Native/AmbitionsTests/App/AppContainerFactoryTests.swift", ("container.runtime.goalIntelligenceService", "RepositoryBackedRuntimeGoalIntelligenceService")),
                EvidenceCheck("surface integration exercises goal flow", app_tests, ("makePromotedGoalContext", "turnCaptureIntoGoal")),
            ),
        ),
        RuntimeSystem(
            id="capture_service",
            title="Capture Service",
            source=(
                EvidenceCheck("capture service protocol", "Native/Ambitions/Services/AppServices.swift", ("protocol CaptureServicing",)),
                EvidenceCheck("capture service implementation", "Native/Ambitions/Services/CaptureService.swift", ("DefaultCaptureService",)),
            ),
            wiring=(
                EvidenceCheck("factory creates capture service", factory, ("let captureService = DefaultCaptureService", "captureService: captureService")),
                EvidenceCheck("app container exposes capture service", app_container, ("let captureService: any CaptureServicing", "self.captureService = captureService")),
            ),
            ui=(EvidenceCheck("Capture surface uses capture/goals service", "Native/Ambitions/Features/Capture/CaptureScreen.swift", ("featureFactory.captureService", "featureFactory.goalsService"), "any"),),
            tests=(EvidenceCheck("end-to-end test creates and promotes capture", app_tests, ("captureService.createCapture", "captureService.turnCaptureIntoGoal", "CaptureGoalBinding")),),
        ),
        RuntimeSystem(
            id="goals_service",
            title="Goals Service",
            source=(
                EvidenceCheck("goals service protocol", "Native/Ambitions/Services/AppServices.swift", ("protocol GoalsServicing",)),
                EvidenceCheck("goals service implementation", "Native/Ambitions/Features/Goals/GoalsFeatureService.swift", ("RepositoryBackedGoalsService",)),
            ),
            wiring=(
                EvidenceCheck("factory creates goals service", factory, ("let goalsService = NotificationSchedulingGoalsService", "goalsService: goalsService")),
                EvidenceCheck("app container exposes goals service", app_container, ("let goalsService: any GoalsServicing", "self.goalsService = goalsService")),
            ),
            ui=(EvidenceCheck("Goals surface uses goals service", "Native/Ambitions/Features/Goals/GoalsScreen.swift", ("featureFactory.goalsService", "container.goalsService"), "any"),),
            tests=(EvidenceCheck("end-to-end test verifies promoted goal", app_tests, ("repositories.goals.goal", "goal?.title", "goal.plan")),),
        ),
        RuntimeSystem(
            id="today_service",
            title="Today Service",
            source=(
                EvidenceCheck("today service protocol", "Native/Ambitions/Services/AppServices.swift", ("protocol TodayServicing",)),
                EvidenceCheck("today service implementation", "Native/Ambitions/Features/Today/TodayFeatureService.swift", ("RepositoryBackedTodayService",)),
            ),
            wiring=(
                EvidenceCheck("factory creates today service", factory, ("let todayService = NotificationSchedulingTodayService", "todayService: todayService")),
                EvidenceCheck("app container exposes today service", app_container, ("let todayService: any TodayServicing", "self.todayService = todayService")),
            ),
            ui=(EvidenceCheck("Today surface uses today service", "Native/Ambitions/Features/Today/TodayScreen.swift", ("featureFactory.todayService", "container.todayService"), "any"),),
            tests=(EvidenceCheck("end-to-end test completes Today action", app_tests, ("todayService.performAction", "TodayInlineAction", "Completion recorded")),),
        ),
        RuntimeSystem(
            id="time_service",
            title="Time Service",
            source=(
                EvidenceCheck("time service protocol", "Native/Ambitions/Services/AppServices.swift", ("protocol TimeServicing",)),
                EvidenceCheck("time service implementation", "Native/Ambitions/Features/Time/TimeFeatureService.swift", ("RepositoryBackedTimeService",)),
            ),
            wiring=(
                EvidenceCheck("factory creates time service", factory, ("timeService: RepositoryBackedTimeService", "calendarRealityService")),
                EvidenceCheck("app container exposes time service", app_container, ("let timeService: any TimeServicing", "self.timeService = timeService")),
            ),
            ui=(EvidenceCheck("Time surface uses time service", "Native/Ambitions/Features/Time/TimeScreen.swift", ("featureFactory.timeService", "container.timeService"), "any"),),
            tests=(EvidenceCheck("root covers Time surface", app_tests, ("coveredSurfaces", ".plan")),),
        ),
        RuntimeSystem(
            id="you_service",
            title="You Service",
            source=(
                EvidenceCheck("you service protocol", "Native/Ambitions/Services/AppServices.swift", ("protocol YouServicing",)),
                EvidenceCheck("you service implementation", "Native/Ambitions/Features/You/YouFeatureService.swift", ("RepositoryBackedYouService",)),
            ),
            wiring=(
                EvidenceCheck("factory creates You service", factory, ("let youService = RepositoryBackedYouService", "youService: youService")),
                EvidenceCheck("app container exposes You service", app_container, ("let youService: any YouServicing", "self.youService = youService")),
            ),
            ui=(EvidenceCheck("You surface uses you service", "Native/Ambitions/Features/You/YouScreen.swift", ("featureFactory.youService", "container.youService"), "any"),),
            tests=(EvidenceCheck("end-to-end test loads You proof dashboard", app_tests, ("youService.loadYouDashboard", "crossSurfaceProofReview", "Local proof available")),),
        ),
        RuntimeSystem(
            id="memory_context_and_action_runtime",
            title="Memory, Context, and Action Runtime",
            source=(EvidenceCheck("runtime service source", "Native/Ambitions/Runtime/AmbitionsRuntimeServices.swift", ("RepositoryBackedRuntimeMemoryService", "RepositoryBackedRuntimeContextService", "DefaultRuntimeActionCommandExecutor")),),
            wiring=(
                EvidenceCheck("factory wires memory context action runtime", factory, ("let memoryService = RepositoryBackedRuntimeMemoryService", "let contextService = RepositoryBackedRuntimeContextService", "let actionExecutor = DefaultRuntimeActionCommandExecutor")),
                EvidenceCheck("external action service uses runtime executor", container, ("runtimeExecutor: runtime.actionExecutor", "DefaultExternalActionCommandService")),
            ),
            ui=(EvidenceCheck("root exposes command and external routes", root, ("shellUtilityButtons", "AppShellOverlayView")),),
            tests=(EvidenceCheck("runtime boundary test loads context", boundary_tests, ("RepositoryBackedRuntimeMemoryService", "contextService.loadContext", "memorySummary")),),
        ),
    ]


def classify_system(system: RuntimeSystem) -> dict[str, object]:
    source_status, source_results = evaluate_group(system.source)
    wiring_status, wiring_results = evaluate_group(system.wiring)
    ui_status, ui_results = evaluate_group(system.ui)
    test_status, test_results = evaluate_group(system.tests)
    unproven: list[str] = []
    if source_status != "verified":
        unproven.append("source-present")
    if wiring_status != "verified":
        unproven.append("wired")
    if ui_status == "unproven":
        unproven.append("UI-accessible")
    if test_status != "verified":
        unproven.append("tested")

    if source_status == "verified" and wiring_status == "verified" and ui_status == "not_applicable":
        classification = "wired_not_direct_ui_accessible"
    elif unproven:
        classification = "unproven"
    else:
        classification = "source-present_wired_UI-accessible_tested"

    severity = "yellow" if classification in {"unproven", "wired_not_direct_ui_accessible"} else "green"
    return {
        "id": system.id,
        "title": system.title,
        "classification": classification,
        "severity": severity,
        "source_present": source_status,
        "wired": wiring_status,
        "ui_accessible": ui_status,
        "tested": test_status,
        "unproven_dimensions": unproven,
        "evidence": {
            "source": source_results,
            "wiring": wiring_results,
            "ui": ui_results,
            "tests": test_results,
        },
    }


def surface_access() -> list[dict[str, object]]:
    checks = [
        EvidenceCheck("Today", "Native/Ambitions/Features/Today/TodayScreen.swift", ("featureFactory.todayService", "container.todayService"), "any"),
        EvidenceCheck("Goals", "Native/Ambitions/Features/Goals/GoalsScreen.swift", ("featureFactory.goalsService", "container.goalsService"), "any"),
        EvidenceCheck("Capture", "Native/Ambitions/Features/Capture/CaptureScreen.swift", ("featureFactory.captureService", "container.captureService"), "any"),
        EvidenceCheck("Time", "Native/Ambitions/Features/Time/TimeScreen.swift", ("featureFactory.timeService", "container.timeService"), "any"),
        EvidenceCheck("You", "Native/Ambitions/Features/You/YouScreen.swift", ("featureFactory.youService", "container.youService"), "any"),
    ]
    return [check_evidence(check) for check in checks]


def end_to_end_path() -> dict[str, object]:
    test_path = "Native/AmbitionsTests/App/CoreSurfaceIntegrationScenarioTests.swift"
    required = (
        "makeLiveSurfaceHarness",
        "AmbitionsRuntimeFactory.make",
        "captureService.createCapture",
        "captureService.turnCaptureIntoGoal",
        "repositories.goals.goal",
        "todayService.performAction",
        "repositories.evidence.listEvidence",
        "repositories.feedback.listEvents",
        "repositories.eventLedger.fetchRecent",
        "youService.loadYouDashboard",
        "cross-review-today-goal-proof",
    )
    result = check_evidence(EvidenceCheck("capture-goal-step-today-proof-you local path", test_path, required))
    return {
        "status": "verified" if result["status"] == "passed" else "unproven",
        "path": test_path,
        "evidence": result,
        "no_claim_boundary": "Source and test-path presence are not current XCTest proof unless the focused test is run and passes.",
    }


def status_for(systems: list[dict[str, object]], surfaces: list[dict[str, object]], e2e: dict[str, object]) -> str:
    if any(system["source_present"] == "unproven" or system["wired"] == "unproven" for system in systems):
        return "RED"
    if any(surface["status"] != "passed" for surface in surfaces):
        return "RED"
    if e2e["status"] != "verified":
        return "RED"
    if any(system["severity"] == "yellow" for system in systems):
        return "YELLOW"
    return "GREEN"


def write_reports(payload: dict[str, object]) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    json_path = OUT / "private-runtime-wiring-check.json"
    md_path = OUT / "private-runtime-wiring-check.md"
    json_path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Private Life Runtime Wiring Gauntlet",
        "",
        f"Status: {payload['status']}",
        f"Generated UTC: {payload['generated_utc']}",
        f"Linear: [{LINEAR_ISSUE}]({LINEAR_URL})",
        "",
        "This is a repo-derived wiring gate. It does not prove build, focused XCTest, device, accessibility, performance, privacy, TestFlight, App Store, or release readiness.",
        "",
        "## Runtime Systems",
        "",
        "| Runtime system | Classification | Source-present | Wired | UI-accessible | Tested |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for system in payload["runtime_systems"]:
        lines.append(
            "| {title} | `{classification}` | `{source_present}` | `{wired}` | `{ui_accessible}` | `{tested}` |".format(
                **system
            )
        )
    lines.extend(["", "## Red/Yellow Findings"])
    findings = payload["findings"]
    if findings:
        for finding in findings:
            lines.append(f"- `{finding['severity']}` `{finding['system_id']}`: {finding['message']}")
    else:
        lines.append("- None")

    lines.extend(["", "## Surface Access"])
    for surface in payload["surface_access"]:
        lines.append(f"- `{surface['label']}`: `{surface['status']}` at `{surface['path']}`")

    e2e = payload["end_to_end_path"]
    lines.extend(
        [
            "",
            "## End-to-End Local Path",
            f"- Status: `{e2e['status']}`",
            f"- Test path: `{e2e['path']}`",
            "- Path shape: capture -> goal -> step -> Today action -> proof/evidence -> You/review.",
            f"- Boundary: {e2e['no_claim_boundary']}",
            "",
            "## Proof Artifacts",
            "- `build/reports/intelligence-consolidation/private-runtime-wiring-check.json`",
            "- `build/reports/intelligence-consolidation/private-runtime-wiring-check.md`",
            "",
        ]
    )
    md_path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    systems = [classify_system(system) for system in runtime_systems()]
    surfaces = surface_access()
    e2e = end_to_end_path()
    status = status_for(systems, surfaces, e2e)
    findings: list[dict[str, str]] = []
    for system in systems:
        if system["classification"] == "unproven":
            findings.append(
                {
                    "severity": "red",
                    "system_id": str(system["id"]),
                    "message": "Missing source, wiring, UI-access, or test evidence; inspect exact paths in JSON evidence.",
                }
            )
        elif system["classification"] == "wired_not_direct_ui_accessible":
            findings.append(
                {
                    "severity": "yellow",
                    "system_id": str(system["id"]),
                    "message": "Runtime is source-present and wired, but no direct top-level UI access path is expected or proven.",
                }
            )

    payload: dict[str, object] = {
        "status": status,
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "linear_issue": LINEAR_ISSUE,
        "linear_url": LINEAR_URL,
        "runtime_systems": systems,
        "surface_access": surfaces,
        "end_to_end_path": e2e,
        "findings": findings,
        "non_claims": [
            "Presence checks are not end-to-end proof.",
            "This gauntlet is not current focused XCTest proof unless the test command is run and passes.",
            "This gauntlet is not release, device, accessibility, performance, privacy, TestFlight, or App Store proof.",
        ],
    }
    write_reports(payload)
    print(f"STATUS: {status}")
    print(f"Report: {OUT / 'private-runtime-wiring-check.md'}")
    return 0 if status != "RED" else 1


if __name__ == "__main__":
    raise SystemExit(main())
