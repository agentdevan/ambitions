#!/usr/bin/env python3
"""Audit the Code-Connect-free VSP provenance system."""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
PROVENANCE_DIR = ROOT / "docs" / "design" / "provenance"
GENERATED_DIR = PROVENANCE_DIR / "generated"
REPORT_PATH = GENERATED_DIR / "provenance-audit-report.generated.md"

REQUIRED_JSON = [
    PROVENANCE_DIR / "vsp-provenance.json",
    PROVENANCE_DIR / "component-registry.json",
    PROVENANCE_DIR / "figma-node-index.json",
    PROVENANCE_DIR / "proof-registry.json",
    PROVENANCE_DIR / "linear-map.json",
]

REQUIRED_DOCS = [
    PROVENANCE_DIR / "README.md",
    PROVENANCE_DIR / "VSP-SwiftUI-Provenance-Map.md",
    PROVENANCE_DIR / "Component-Gallery.md",
    PROVENANCE_DIR / "Gap-Register.md",
    PROVENANCE_DIR / "Figma-Annotation-Pack.md",
    PROVENANCE_DIR / "Linear-Issue-Pack.md",
    PROVENANCE_DIR / "Governance-Gates.md",
]

REQUIRED_GENERATED = [
    GENERATED_DIR / "swift-component-inventory.generated.json",
    GENERATED_DIR / "source-path-inventory.generated.json",
]

ALLOWED_CATEGORIES = {
    "shell_authority",
    "surface_content",
    "global_composer",
    "contextual_inspection",
    "external_boundary",
    "motion_accessibility_haptics",
    "implementation_anatomy",
}

ALLOWED_STATUSES = {
    "Backlog",
    "Designing",
    "Spec Ready",
    "Ready For Codex",
    "In Progress",
    "Needs Repair",
    "Ready For Review",
    "Accepted Yellow",
    "Done",
    "Won't Do",
}

ALLOWED_CEILINGS = {"Unknown", "Yellow", "Green"}
EXPECTED_VSPS = [f"VSP-{index:02d}" for index in range(1, 11)]
PROOF_KEYS = [
    "owner_approval",
    "live_swiftui_screenshot",
    "device_screenshot",
    "dynamic_type",
    "voiceover",
    "reduce_motion",
    "increase_contrast",
    "reduce_transparency",
    "haptics",
    "runtime_behavior",
    "validation_commands",
    "privacy_boundary",
]
PROOF_TYPE_FOR_KEY = {
    "owner_approval": "owner_approval",
    "live_swiftui_screenshot": "swiftui_simulator_screenshot",
    "device_screenshot": "swiftui_device_screenshot",
    "dynamic_type": "dynamic_type_screenshot",
    "voiceover": "voiceover_manual_note",
    "reduce_motion": "reduce_motion_walkthrough",
    "increase_contrast": "increase_contrast_check",
    "reduce_transparency": "reduce_transparency_check",
    "haptics": "haptic_device_note",
    "runtime_behavior": "runtime_behavior_test",
    "validation_commands": "validation_command",
    "privacy_boundary": "privacy_boundary_check",
}
STALE_TERMS = re.compile(r"\b(Plan|Profile|Habits|Insights|capture_root)\b")


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def load(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def is_path_like(value: str) -> bool:
    return "/" in value or value.endswith(".swift") or value.endswith(".md") or value.startswith("docs")


def path_exists(value: str) -> bool:
    if value.startswith("unknown:"):
        return True
    if not is_path_like(value):
        return True
    return (ROOT / value).exists()


def add(failures: list[str], message: str) -> None:
    failures.append(message)


def add_warn(warnings: list[str], message: str) -> None:
    warnings.append(message)


def vsp_packets(payload: dict[str, Any]) -> list[dict[str, Any]]:
    return sorted(payload["vsp_packets"], key=lambda row: int(row["vsp_id"].split("-")[1]))


def proof_lookup(proofs: list[dict[str, Any]]) -> dict[tuple[str, str], dict[str, Any]]:
    return {(proof["vsp_id"], proof["proof_type"]): proof for proof in proofs}


def validate_files(failures: list[str]) -> None:
    for path in REQUIRED_JSON + REQUIRED_DOCS + REQUIRED_GENERATED:
        if not path.exists():
            add(failures, f"Missing required provenance file: {rel(path)}")


def validate_vsp_registry(vsps: list[dict[str, Any]], proofs: list[dict[str, Any]], failures: list[str], warnings: list[str], yellow_gaps: list[str]) -> None:
    ids = [vsp["vsp_id"] for vsp in vsps]
    if ids != EXPECTED_VSPS:
        add(failures, f"VSP IDs must be exactly {EXPECTED_VSPS}; found {ids}")

    proof_by_key = proof_lookup(proofs)
    for vsp in vsps:
        vsp_id = vsp["vsp_id"]
        for key in [
            "vsp_id",
            "title",
            "category",
            "current_status_recommendation",
            "proof_ceiling",
            "figma",
            "shell_authority",
            "swiftui",
            "linear",
            "proof_required",
            "proof_present",
            "known_risks",
            "missing_evidence",
            "green_blockers",
            "notes",
        ]:
            if key not in vsp:
                add(failures, f"{vsp_id} missing required key `{key}`")

        if vsp.get("category") not in ALLOWED_CATEGORIES:
            add(failures, f"{vsp_id} has invalid category `{vsp.get('category')}`")
        if vsp.get("current_status_recommendation") not in ALLOWED_STATUSES:
            add(failures, f"{vsp_id} has invalid status `{vsp.get('current_status_recommendation')}`")
        if vsp.get("current_status_recommendation") == "Done":
            add(failures, f"{vsp_id} may not be marked Done")
        if vsp.get("current_status_recommendation") == "Accepted Yellow":
            add_warn(warnings, f"{vsp_id} is Accepted Yellow; ensure owner accepted risk and follow-up are explicit")
        if vsp.get("proof_ceiling") not in ALLOWED_CEILINGS:
            add(failures, f"{vsp_id} has invalid proof ceiling `{vsp.get('proof_ceiling')}`")

        if set(vsp.get("proof_required", {}).keys()) != set(PROOF_KEYS):
            add(failures, f"{vsp_id} proof_required must include exactly {PROOF_KEYS}")
        if set(vsp.get("proof_present", {}).keys()) != set(PROOF_KEYS):
            add(failures, f"{vsp_id} proof_present must include exactly {PROOF_KEYS}")

        for key, value in vsp.get("proof_present", {}).items():
            if not isinstance(value, list):
                add(failures, f"{vsp_id} proof_present.{key} must be an array")

        for key, required in vsp.get("proof_required", {}).items():
            if not required:
                continue
            proof_type = PROOF_TYPE_FOR_KEY[key]
            proof = proof_by_key.get((vsp_id, proof_type))
            if proof is None:
                add(failures, f"{vsp_id} missing proof-registry entry for {proof_type}")
            elif proof["status"] != "present":
                yellow_gaps.append(f"{vsp_id}: {proof_type} is {proof['status']}")

        figma = vsp.get("figma", {})
        if figma.get("node_id_status") == "known" and not figma.get("node_id"):
            add(failures, f"{vsp_id} has known Figma node status without node_id")
        if figma.get("node_id_status") == "unknown" and not figma.get("unknown_rationale"):
            add(failures, f"{vsp_id} unknown Figma node requires unknown_rationale")

        if vsp.get("proof_ceiling") == "Green":
            required_present = [
                "owner_approval",
                "live_swiftui_screenshot",
                "validation_commands",
            ]
            if any(not vsp["proof_present"].get(key) for key in required_present):
                add(failures, f"{vsp_id} claims Green without owner approval, live SwiftUI screenshot, and validation proof")
            if any(vsp["proof_required"].get(key) and not vsp["proof_present"].get(key) for key in ["dynamic_type", "voiceover", "reduce_motion"]):
                add(failures, f"{vsp_id} claims Green without required accessibility proof")
            if vsp_id == "VSP-08" and not vsp["proof_present"].get("privacy_boundary"):
                add(failures, "VSP-08 claims Green without privacy-boundary proof")

        swiftui = vsp.get("swiftui", {})
        for field in [
            "canonical_source_owners",
            "allowed_implementation_areas",
            "known_component_candidates",
            "known_tests",
            "known_preview_or_quality_files",
        ]:
            for value in swiftui.get(field, []):
                if not path_exists(value):
                    add(failures, f"{vsp_id} lists missing source path in {field}: {value}")
        if not swiftui.get("forbidden_implementation_areas"):
            add(failures, f"{vsp_id} must list forbidden implementation areas")

        canonical_text = " ".join(
            [
                vsp["title"],
                vsp["category"],
                " ".join(swiftui.get("allowed_implementation_areas", [])),
                " ".join(swiftui.get("canonical_source_owners", [])),
            ]
        )
        if STALE_TERMS.search(canonical_text):
            add(failures, f"{vsp_id} has stale top-level ownership term in canonical fields: {STALE_TERMS.search(canonical_text).group(0)}")


def validate_shell_and_product_law(vsps: list[dict[str, Any]], failures: list[str]) -> None:
    by_id = {vsp["vsp_id"]: vsp for vsp in vsps}
    vsp01 = by_id.get("VSP-01")
    if not vsp01:
        add(failures, "VSP-01 missing")
        return
    if vsp01["category"] != "shell_authority":
        add(failures, "VSP-01 category must be shell_authority")
    if vsp01["shell_authority"]["requires_vsp_01_shell"]:
        add(failures, "VSP-01 may not require itself as shell authority")
    for vsp_id in EXPECTED_VSPS[1:]:
        vsp = by_id[vsp_id]
        shell = vsp["shell_authority"]
        if not shell["requires_vsp_01_shell"]:
            add(failures, f"{vsp_id} must require VSP-01 shell authority")
        if shell["may_mutate_shell"]:
            add(failures, f"{vsp_id} may not mutate VSP-01 shell")

    vsp05 = by_id["VSP-05"]
    capture_text = " ".join(vsp05["swiftui"]["allowed_implementation_areas"]).lower()
    if "surfaces/capture" in capture_text or "root" in capture_text or "tab" in capture_text:
        add(failures, "VSP-05 allowed implementation areas imply Capture root/tab ownership")

    vsp09 = by_id["VSP-09"]
    motion_text = " ".join(vsp09["swiftui"]["allowed_implementation_areas"]).lower()
    if "surfaces/motion" in motion_text:
        add(failures, "VSP-09 allowed implementation areas imply Motion surface ownership")

    vsp07 = by_id["VSP-07"]
    trust_text = " ".join(vsp07["swiftui"]["allowed_implementation_areas"]).lower()
    if "surfaces/" in trust_text and "trust" in trust_text:
        add(failures, "VSP-07 allowed implementation areas imply Trust root surface ownership")

    vsp08_text = json.dumps(by_id["VSP-08"], sort_keys=True).lower()
    required_forbidden = [
        "r2 private life graph storage",
        "account-required core value",
        "external/cloud llm core runtime",
    ]
    for phrase in required_forbidden:
        if phrase not in vsp08_text:
            add(failures, f"VSP-08 must explicitly forbid {phrase}")


def validate_components(components: list[dict[str, Any]], failures: list[str]) -> None:
    required = {
        "component_id",
        "component_name",
        "source_path",
        "component_kind",
        "owning_vsp_ids",
        "owning_surface_or_layer",
        "used_by_paths",
        "known_tests",
        "known_previews",
        "proof_status",
        "stale_naming_risks",
        "accessibility_risks",
        "motion_risks",
        "notes",
    }
    ids: set[str] = set()
    for component in components:
        missing = required - component.keys()
        if missing:
            add(failures, f"Component {component.get('component_id', '<unknown>')} missing keys {sorted(missing)}")
        cid = component.get("component_id")
        if cid in ids:
            add(failures, f"Duplicate component_id {cid}")
        ids.add(cid)
        if not path_exists(component.get("source_path", "")):
            add(failures, f"Component {cid} source_path does not exist: {component.get('source_path')}")
        for field in ["used_by_paths", "known_tests", "known_previews"]:
            for value in component.get(field, []):
                if not path_exists(value):
                    add(failures, f"Component {cid} lists missing {field} path: {value}")


def validate_nodes(nodes: list[dict[str, Any]], failures: list[str]) -> None:
    required = {
        "figma_file_key",
        "node_id",
        "node_id_status",
        "frame_name",
        "vsp_id",
        "evidence_screenshot_paths",
        "evidence_doc_paths",
        "provenance_annotation_status",
        "annotation_copy_anchor",
        "notes",
    }
    seen: set[tuple[str, str, str]] = set()
    for node in nodes:
        missing = required - node.keys()
        if missing:
            add(failures, f"Figma node entry missing keys {sorted(missing)}")
        key = (node.get("vsp_id", ""), node.get("figma_file_key", ""), node.get("node_id", ""))
        if key in seen:
            add(failures, f"Duplicate figma node entry {key}")
        seen.add(key)
        for path in node.get("evidence_screenshot_paths", []) + node.get("evidence_doc_paths", []):
            if not path_exists(path):
                add(failures, f"Figma node entry lists missing evidence path: {path}")


def validate_proofs(proofs: list[dict[str, Any]], failures: list[str]) -> None:
    required = {
        "proof_id",
        "vsp_id",
        "proof_type",
        "status",
        "artifact_paths",
        "blocking_reason",
        "proof_ceiling_impact",
        "notes",
    }
    seen: set[str] = set()
    for proof in proofs:
        missing = required - proof.keys()
        if missing:
            add(failures, f"Proof entry {proof.get('proof_id', '<unknown>')} missing keys {sorted(missing)}")
        proof_id = proof.get("proof_id")
        if proof_id in seen:
            add(failures, f"Duplicate proof_id {proof_id}")
        seen.add(proof_id)
        if proof.get("status") not in {"missing", "present", "not_applicable", "blocked"}:
            add(failures, f"Proof {proof_id} has invalid status {proof.get('status')}")
        if proof.get("status") == "present":
            for path in proof.get("artifact_paths", []):
                if (ROOT / path) == REPORT_PATH:
                    continue
                if not path_exists(path):
                    add(failures, f"Proof {proof_id} lists missing artifact path: {path}")


def validate_linear(linear_items: list[dict[str, Any]], failures: list[str]) -> None:
    for item in linear_items:
        if item.get("recommended_status") == "Done":
            add(failures, f"{item.get('vsp_id')} Linear mirror may not recommend Done")
        if item.get("do_not_create_now") is not True:
            add(failures, f"{item.get('vsp_id')} Linear mirror must set do_not_create_now true")


def write_report(failures: list[str], warnings: list[str], yellow_gaps: list[str]) -> None:
    GENERATED_DIR.mkdir(parents=True, exist_ok=True)
    lines = [
        "# VSP Provenance Audit Report\n\n",
        "Generated: `deterministic-from-current-registry-inputs`\n\n",
        "Claim boundary: this audit checks provenance-system coherence only. It is not Code Connect, Visual Green, source implementation proof, device proof, accessibility conformance, or owner approval.\n\n",
        "## Summary\n\n",
        f"- Blocking failures: {len(failures)}\n",
        f"- Warnings: {len(warnings)}\n",
        f"- Yellow proof gaps: {len(yellow_gaps)}\n\n",
    ]
    lines.append("## Blocking Failures\n\n")
    lines.extend(f"- {failure}\n" for failure in failures) if failures else lines.append("- none\n")
    lines.append("\n## Warnings\n\n")
    lines.extend(f"- {warning}\n" for warning in warnings) if warnings else lines.append("- none\n")
    lines.append("\n## Yellow Proof Gaps\n\n")
    lines.extend(f"- {gap}\n" for gap in yellow_gaps) if yellow_gaps else lines.append("- none\n")
    REPORT_PATH.write_text("".join(lines), encoding="utf-8")


def main() -> int:
    failures: list[str] = []
    warnings: list[str] = []
    yellow_gaps: list[str] = []

    validate_files(failures)
    if failures:
        write_report(failures, warnings, yellow_gaps)
        print(f"VSP provenance audit failed: {len(failures)} blocking failures")
        return 1

    vsp_payload = load(PROVENANCE_DIR / "vsp-provenance.json")
    component_payload = load(PROVENANCE_DIR / "component-registry.json")
    node_payload = load(PROVENANCE_DIR / "figma-node-index.json")
    proof_payload = load(PROVENANCE_DIR / "proof-registry.json")
    linear_payload = load(PROVENANCE_DIR / "linear-map.json")

    vsps = vsp_packets(vsp_payload)
    validate_vsp_registry(vsps, proof_payload["proofs"], failures, warnings, yellow_gaps)
    validate_shell_and_product_law(vsps, failures)
    validate_components(component_payload["components"], failures)
    validate_nodes(node_payload["nodes"], failures)
    validate_proofs(proof_payload["proofs"], failures)
    validate_linear(linear_payload["linear_items"], failures)

    write_report(failures, warnings, yellow_gaps)

    if failures:
        print(f"VSP provenance audit failed: {len(failures)} blocking failures")
        for failure in failures:
            print(f"RED: {failure}")
        return 1

    print("VSP provenance audit passed")
    print(f"Warnings: {len(warnings)}")
    print(f"Yellow proof gaps: {len(yellow_gaps)}")
    print(f"Wrote {rel(REPORT_PATH)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
