#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "docs" / "contracts" / "AMB_PROJECTION_CONTRACT_REGISTRY.md"

REQUIRED = [
    "StartHereDecisionPacket",
    "RealityMeridianProjection",
    "LifeShapeProjection",
    "GoalConstellationProjection",
    "CaptureAtmosphereProjection",
    "ClosurePromptProjection",
    "ProofTrailProjection",
    "TrustReceiptProjection",
    "SourceFreshnessProjection",
    "DiagnosticsProjection",
    "UserSystemProjection",
    "ContinuityProjection",
    "AccessibilitySemanticProjection",
    "ScreenshotCandidateProjection",
    "MemoryLensProjection",
    "LocalControlKnobsProjection",
    "NotChosenReasonsProjection",
    "DecisionReplayProjection",
    "PrivacyRedactionProjection",
]

REQUIRED_KEYS = {
    "owner",
    "consumer",
    "schema_maturity",
    "required_fields",
    "forbidden_fields",
    "runtime_identity",
    "projection_identity",
    "freshness_semantics",
    "proof_semantics",
    "not_chosen_semantics",
    "privacy_semantics",
    "unavailable_stale_conflict_states",
    "fixtures",
    "preview_requirements",
    "test_expectations",
    "migration/versioning expectations",
    "rollback considerations",
}


def main() -> int:
    if not PATH.exists():
        print("RED")
        print(f"missing file: {PATH}")
        return 1

    text = PATH.read_text(encoding="utf-8")
    lower = text.lower()
    for contract in REQUIRED:
        if f"## Contract: {contract}" not in text:
            print("RED")
            print(f"missing contract: {contract}")
            return 1

    issues = []
    blocks = re.split(r"^## Contract: ", text, flags=re.MULTILINE)[1:]
    for block in blocks:
        lines = block.splitlines()
        header = lines[0].strip()
        body = "\n".join(lines[1:]).lower()
        body = body.replace("migration/versioning:", "migration/versioning expectations:")
        body = body.replace("rollback_considerations:", "rollback considerations:")
        missing = [key for key in REQUIRED_KEYS if key not in body]
        if missing:
            issues.append(f"contract {header}: missing fields {', '.join(missing)}")

    if issues:
        print("RED")
        print("\n".join(issues))
        return 1

    # minimal content check for core runtime contracts
    core = [
        "startheredecisionpacket",
        "realitymeridianprojection",
        "lifeshapeprojection",
        "goalconstellationprojection",
        "closurepromptprojection",
        "sourcefreshnessprojection",
        "prooftrailprojection",
    ]
    for key in core:
        if key not in lower:
            print("RED")
            print(f"core term not found in body: {key}")
            return 1

    print("GREEN")
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
