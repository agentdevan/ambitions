#!/usr/bin/env python3
from __future__ import annotations
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FRONTEND = ROOT / "frontend" / "visual-encyclopedia"
ACTIVE = FRONTEND / "decisions" / "active"
LEDGER = FRONTEND / "decisions" / "UI_DECISION_LEDGER.yaml"
SURFACE_MATRIX = FRONTEND / "trace" / "UI_DECISION_TO_SURFACE_MATRIX.yaml"
SYSTEM_MATRIX = FRONTEND / "trace" / "UI_DECISION_TO_DESIGN_SYSTEM_MATRIX.yaml"
REPORT_ROOT = ROOT / "build" / "reports" / "ui-decisions"
OUT_JSON = ROOT / "build" / "reports" / "ui-decision-final-gate.json"
OUT_MD = ROOT / "build" / "reports" / "ui-decision-final-gate.md"

REQUIRED_REPORTS = ["decision-summary.md", "design-system-gap-report.md", "proof-contract.md", "generated-implementation-prompt.md"]
REQUIRED_SOURCE_INSTALLED_REPORTS = ["implementation-receipt.md"]
REQUIRED_PROMPT_MARKERS = [
    "<!-- AMBITIONS_RUNNER_REQUIRED: true -->",
    "<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->",
    "<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->",
]

CURRENT_TIME_DECISION_ID = "UID-2026-05-15-today-live-current-time-cursor"
CURRENT_TIME_FUSION = ROOT / "Native/Ambitions/Features/Today/TodayDayRailCurrentTimeFusion.swift"
OBSOLETE_FUSED_WRAPPER = ROOT / "Native/Ambitions/Features/Today/TodayRealityMeridianFusedRail.swift"
TODAY_SCREEN = ROOT / "Native/Ambitions/Features/Today/TodayScreen.swift"
TEMPORAL_TESTS = ROOT / "Native/AmbitionsTests/DesignSystem/RealityMeridianTemporalWindowTests.swift"
TIME_BAND = ROOT / "Sources/Components/RealityMeridianTimeBand.swift"
TIME_BAND_PREVIEW = ROOT / "Sources/Previews/RealityMeridianRichnessPreviews.swift"

START_HERE_DECISION_ID = "UID-2026-05-16-start-here-product-kernel"
START_HERE_PRIMITIVES = ROOT / "Sources/Components/StartHereProductPrimitives.swift"
START_HERE_TESTS = ROOT / "Native/AmbitionsTests/DesignSystem/StartHereProductKernelTests.swift"
START_HERE_PROJECTION = ROOT / "Native/Ambitions/Features/Today/StartHereProductKernelProjection.swift"
TODAY_RAIL_PANELS = ROOT / "Native/Ambitions/Features/Today/TodayDayRailPanels.swift"
START_HERE_BANNED_PHRASES = [
    "best next move",
    "next best move",
    "recommended next step",
    "ai recommendation card",
    "recommendation card",
    "dashboard card",
    "task card",
    "productivity score",
    "streak broken",
    "begin focus",
]


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8") if path.exists() else ""


def decision_rows() -> list[dict]:
    return [load_json(path) for path in sorted(ACTIVE.glob("*.yaml"))]


def ids_from_matrix(path: Path) -> set[str]:
    if not path.exists():
        return set()
    payload = load_json(path)
    return {str(row.get("id")) for row in payload.get("decisions", []) if row.get("id")}


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def is_source_installed(row: dict) -> bool:
    return row.get("implementation_proof_status") == "proof_required_after_implementation"


def validate_current_time_cursor_lane(errors: list[str], checks: dict[str, object]) -> None:
    fusion_text = read_text(CURRENT_TIME_FUSION)
    today_text = read_text(TODAY_SCREEN)
    test_text = read_text(TEMPORAL_TESTS)
    band_text = read_text(TIME_BAND)

    checks["current_time_fusion_exists"] = CURRENT_TIME_FUSION.exists()
    checks["current_time_obsolete_wrapper_absent"] = not OBSOLETE_FUSED_WRAPPER.exists()
    checks["current_time_temporal_tests_exist"] = TEMPORAL_TESTS.exists()
    checks["current_time_uses_rail_overlay_presentation"] = "presentation: .railOverlay" in fusion_text
    checks["reality_meridian_time_band_exists"] = TIME_BAND.exists()
    checks["reality_meridian_time_band_preview_exists"] = TIME_BAND_PREVIEW.exists()
    checks["rail_fusion_uses_time_band"] = "RealityMeridianTimeBand" in fusion_text

    if not CURRENT_TIME_FUSION.exists():
        errors.append(f"{CURRENT_TIME_DECISION_ID}: missing rail-layer fusion file")
    if OBSOLETE_FUSED_WRAPPER.exists():
        errors.append(f"{CURRENT_TIME_DECISION_ID}: obsolete fused wrapper still exists")
    if ".fusedCurrentTimeCursor()" not in today_text:
        errors.append(f"{CURRENT_TIME_DECISION_ID}: TodayScreen is not using RealityMeridianView.fusedCurrentTimeCursor()")
    if "extension RealityMeridianView" not in fusion_text:
        errors.append(f"{CURRENT_TIME_DECISION_ID}: fusion file does not extend RealityMeridianView")
    if "RealityMeridianTimeBand" not in fusion_text:
        errors.append(f"{CURRENT_TIME_DECISION_ID}: rail fusion is not rendering RealityMeridianTimeBand")
    if "presentation: .railOverlay" not in fusion_text:
        errors.append(f"{CURRENT_TIME_DECISION_ID}: rail fusion is not using embedded rail overlay cursor presentation")
    if "allowsHitTesting(false)" not in fusion_text:
        errors.append(f"{CURRENT_TIME_DECISION_ID}: fusion cursor must not block rail taps")
    if "RealityMeridianTemporalWindowTests" not in test_text:
        errors.append(f"{CURRENT_TIME_DECISION_ID}: missing temporal window tests")
    if "testProgressMapsExactMinutePosition" not in test_text:
        errors.append(f"{CURRENT_TIME_DECISION_ID}: missing exact minute-position test")
    for symbol in ["RealityMeridianTimeBand", "RealityMeridianTimeBandZone", "canonicalToday"]:
        if symbol not in band_text:
            errors.append(f"{CURRENT_TIME_DECISION_ID}: time band missing symbol {symbol}")


def validate_start_here_lane(errors: list[str], checks: dict[str, object]) -> None:
    primitive_text = read_text(START_HERE_PRIMITIVES)
    test_text = read_text(START_HERE_TESTS)
    projection_text = read_text(START_HERE_PROJECTION)
    today_rail_text = read_text(TODAY_RAIL_PANELS)
    lowered_today = today_rail_text.lower()

    checks["start_here_primitives_exist"] = START_HERE_PRIMITIVES.exists()
    checks["start_here_kernel_tests_exist"] = START_HERE_TESTS.exists()
    checks["start_here_projection_exists"] = START_HERE_PROJECTION.exists()
    checks["start_here_today_surface_exists"] = "private struct StartHereSurface" in today_rail_text
    checks["start_here_audit_exists"] = "StartHereProductKernelAudit" in primitive_text
    checks["start_here_proof_stack_exists"] = "StartHereProductProofStack" in primitive_text

    if not START_HERE_PRIMITIVES.exists():
        errors.append(f"{START_HERE_DECISION_ID}: missing StartHereProductPrimitives.swift")
    if not START_HERE_TESTS.exists():
        errors.append(f"{START_HERE_DECISION_ID}: missing StartHereProductKernelTests.swift")
    if not START_HERE_PROJECTION.exists():
        errors.append(f"{START_HERE_DECISION_ID}: missing Today Start Here product-kernel projection")
    for symbol in ["StartHereProductKernel", "StartHereProductFact", "StartHereProductKernelAudit", "StartHereProductProofStack"]:
        if symbol not in primitive_text:
            errors.append(f"{START_HERE_DECISION_ID}: missing design-system symbol {symbol}")
    for test_name in ["testKernelRequiresStartHereProofStructure", "testKernelRejectsGenericRecommendationLanguage", "testKernelRequiresCanonicalPrimaryAction"]:
        if test_name not in test_text:
            errors.append(f"{START_HERE_DECISION_ID}: missing test {test_name}")
    for projection_marker in ["startHereProductKernel", "StartHereProductKernel", "StartHereProductFact", "receiptItem.accessibilitySummary"]:
        if projection_marker not in projection_text:
            errors.append(f"{START_HERE_DECISION_ID}: projection missing marker {projection_marker}")
    for marker in ["TodayStartHereBecauseLine", "TodayStartHereReceiptDrawer", "TodayStartHereTimeFitProof", "TodayStartHereGoalThread"]:
        if marker not in today_rail_text:
            errors.append(f"{START_HERE_DECISION_ID}: active Today Start Here surface missing marker {marker}")
    for phrase in START_HERE_BANNED_PHRASES:
        if phrase in lowered_today:
            errors.append(f"{START_HERE_DECISION_ID}: banned Start Here phrase in active Today rail surface: {phrase}")


def main() -> int:
    rows = decision_rows()
    active_rows = [row for row in rows if row.get("status") == "active"]
    active_ids = {row.get("id") for row in active_rows}
    source_installed_ids = {row.get("id") for row in active_rows if is_source_installed(row)}
    surface_ids = ids_from_matrix(SURFACE_MATRIX)
    system_ids = ids_from_matrix(SYSTEM_MATRIX)
    errors: list[str] = []
    checks: dict[str, object] = {
        "decision_count": len(rows),
        "active_decision_count": len(active_ids),
        "source_installed_decision_count": len(source_installed_ids),
        "ledger_exists": LEDGER.exists(),
        "surface_matrix_exists": SURFACE_MATRIX.exists(),
        "design_system_matrix_exists": SYSTEM_MATRIX.exists(),
    }
    if not LEDGER.exists():
        errors.append("missing UI decision ledger")
    if not SURFACE_MATRIX.exists():
        errors.append("missing UI decision surface matrix")
    if not SYSTEM_MATRIX.exists():
        errors.append("missing UI decision design-system matrix")
    for row in active_rows:
        decision_id = str(row.get("id"))
        if decision_id not in surface_ids:
            errors.append(f"{decision_id}: missing surface matrix row")
        if decision_id not in system_ids:
            errors.append(f"{decision_id}: missing design-system matrix row")
        report_dir = REPORT_ROOT / decision_id
        for name in REQUIRED_REPORTS:
            path = report_dir / name
            if not path.exists():
                errors.append(f"{decision_id}: missing generated report {name}")
        if is_source_installed(row):
            for name in REQUIRED_SOURCE_INSTALLED_REPORTS:
                path = report_dir / name
                if not path.exists():
                    errors.append(f"{decision_id}: source-installed decision missing {name}")
        prompt = report_dir / "generated-implementation-prompt.md"
        if prompt.exists():
            text = prompt.read_text(encoding="utf-8")
            for marker in REQUIRED_PROMPT_MARKERS:
                if marker not in text:
                    errors.append(f"{decision_id}: generated prompt missing runner marker {marker}")
    if CURRENT_TIME_DECISION_ID in active_ids:
        validate_current_time_cursor_lane(errors, checks)
    if START_HERE_DECISION_ID in active_ids:
        validate_start_here_lane(errors, checks)
    status = "green" if not errors else "red"
    payload = {"status": status, "checks": checks, "errors": errors}
    write(OUT_JSON, json.dumps(payload, indent=2, sort_keys=True) + "\n")
    lines = ["# UI Decision Final Gate", "", f"Status: `{status}`", "", "## Checks"]
    for key, value in checks.items():
        lines.append(f"- {key}: {value}")
    lines.extend(["", "## Errors"])
    lines.extend(f"- {error}" for error in (errors or ["None"]))
    lines.extend(["", "## Boundary", "", "This gate checks the UI-decision control plane, source-install receipts, and selected source-shape guards. It does not prove compile, simulator, device, accessibility, release, or App Store readiness."])
    write(OUT_MD, "\n".join(lines).rstrip() + "\n")
    print(status.upper())
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
