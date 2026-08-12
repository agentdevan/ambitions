#!/usr/bin/env python3
"""Validate, gate, and render the Ambitions unified frontend program ledger."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import pathlib
import subprocess
from typing import Any


PROGRAM_NAME = "Ambitions Unified Maximum Polish Frontend Program"
MILESTONE_IDS = [f"UFP-{number}" for number in range(9)]
MILESTONE_STATES = {"COMPLETE", "ACTIVE", "QUEUED"}
APPROVAL_FIELDS = (
    "frontend_design",
    "runtime_integration",
    "production_cutover",
    "legacy_deletion",
    "release",
)
PASS_FIELDS = ("swot", "review", "repair", "gap", "polish")
DESIGN_STATES = {
    "queued",
    "next",
    "active",
    "owner_approved_direction",
    "complete",
    "blocked",
}
STAGE_STATES = {"pending", "in_progress", "complete", "blocked"}


def load(path: pathlib.Path) -> dict[str, Any]:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def run_git(repo: pathlib.Path, *args: str) -> str:
    result = subprocess.run(
        ["git", *args], cwd=repo, check=True, text=True, capture_output=True
    )
    return result.stdout.rstrip("\n")


def component_map(data: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {item["id"]: item for item in data.get("components", [])}


def milestone_map(data: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {item.get("id", ""): item for item in data.get("milestones", [])}


def _validate_program(data: dict[str, Any], errors: list[str]) -> None:
    if data.get("schema_version") != 2:
        errors.append("schema_version must be 2")
    if data.get("program") != PROGRAM_NAME:
        errors.append(f"program must be {PROGRAM_NAME!r}")
    if data.get("program_kind") != "unified_frontend":
        errors.append("program_kind must be 'unified_frontend'")
    if data.get("single_authoritative_program") is not True:
        errors.append("single_authoritative_program must be true")

    expected_foundry = {
        "role": "fixture_rendering_and_proof_harness",
        "authority": "subordinate",
        "renders_canonical_ui": True,
        "owns_canonical_ui": False,
    }
    if data.get("foundry") != expected_foundry:
        errors.append("foundry must be the subordinate fixture rendering and proof harness")

    approvals = data.get("approvals", {})
    for field in APPROVAL_FIELDS:
        if not isinstance(approvals.get(field), bool):
            errors.append(f"approvals.{field} must be boolean")

    authorization = data.get("authorization", {})
    for field in ("approved_for_swiftui", "production_integration_authorized"):
        if not isinstance(authorization.get(field), bool):
            errors.append(f"authorization.{field} must be boolean")
    if (
        authorization.get("production_integration_authorized") is True
        and approvals.get("runtime_integration") is not True
    ):
        errors.append(
            "authorization.production_integration_authorized contradicts "
            "approvals.runtime_integration"
        )

    legacy = data.get("legacy_frontend", {})
    if legacy.get("disposition") != "delete_all":
        errors.append("legacy_frontend.disposition must be 'delete_all'")
    if legacy.get("reuse_boundary") != "nonvisual_runtime_behavior_only":
        errors.append(
            "legacy_frontend.reuse_boundary must be 'nonvisual_runtime_behavior_only'"
        )
    if legacy.get("zero_legacy_required") is not True:
        errors.append("legacy_frontend.zero_legacy_required must be true")
    verification = legacy.get("verification", {})
    if verification.get("status") not in {"not_started", "complete"}:
        errors.append(
            "legacy_frontend.verification.status must be 'not_started' or 'complete'"
        )
    if not isinstance(verification.get("evidence"), list):
        errors.append("legacy_frontend.verification.evidence must be an array")
    if verification.get("status") == "complete" and not verification.get("evidence"):
        errors.append("completed zero-legacy verification needs evidence")

    if authorization.get("approved_for_swiftui") is True:
        milestones = milestone_map(data)
        release_ceiling_met = (
            all(approvals.get(field) is True for field in APPROVAL_FIELDS)
            and milestones.get("UFP-8", {}).get("status") == "COMPLETE"
            and verification.get("status") == "complete"
            and bool(verification.get("evidence"))
        )
        if not release_ceiling_met:
            errors.append(
                "authorization.approved_for_swiftui exceeds the unified release ceiling"
            )


def _validate_milestones(data: dict[str, Any], errors: list[str]) -> None:
    milestones = data.get("milestones", [])
    ids = [item.get("id") for item in milestones]
    if ids != MILESTONE_IDS:
        errors.append("milestones must be exactly UFP-0 through UFP-8 in order")

    id_positions = {identifier: index for index, identifier in enumerate(ids)}
    active_count = 0
    seen_noncomplete = False
    for index, item in enumerate(milestones):
        identifier = item.get("id", f"milestone-{index}")
        for field in ("owner", "entry_conditions", "exit_conditions", "proof_required"):
            value = item.get(field)
            if field == "owner":
                if not isinstance(value, str) or not value.strip():
                    errors.append(f"{identifier}: owner must be a nonempty string")
            elif not isinstance(value, list) or not value or any(
                not isinstance(entry, str) or not entry.strip() for entry in value
            ):
                errors.append(f"{identifier}: {field} must be a nonempty string array")
        evidence = item.get("evidence")
        if not isinstance(evidence, list):
            errors.append(f"{identifier}: evidence must be an array")
        elif item.get("status") == "COMPLETE" and not evidence:
            errors.append(f"{identifier}: completed milestone needs evidence")
        status = item.get("status")
        if status not in MILESTONE_STATES:
            errors.append(f"{identifier}: invalid milestone status {status!r}")
        if status == "ACTIVE":
            active_count += 1
        if status == "COMPLETE" and seen_noncomplete:
            errors.append(f"{identifier}: completed milestone follows incomplete milestone")
        elif status != "COMPLETE":
            seen_noncomplete = True

        dependencies = item.get("depends_on")
        if not isinstance(dependencies, list):
            errors.append(f"{identifier}: depends_on must be an array")
            continue
        if len(dependencies) != len(set(dependencies)):
            errors.append(f"{identifier}: dependency ids must be unique")
        for dependency in dependencies:
            if dependency not in id_positions or id_positions[dependency] >= index:
                errors.append(
                    f"{identifier}: dependency {dependency!r} must name an earlier milestone"
                )
            elif status in {"ACTIVE", "COMPLETE"} and milestones[
                id_positions[dependency]
            ].get("status") != "COMPLETE":
                errors.append(
                    f"{identifier}: active or complete milestone dependency "
                    f"{dependency!r} must be complete"
                )
    if active_count > 1:
        errors.append("only one unified program milestone may be active")


def _validate_components(data: dict[str, Any], errors: list[str]) -> None:
    components = data.get("components", [])
    ids = [item.get("id") for item in components]
    if not components or len(ids) != len(set(ids)) or None in ids:
        errors.append("components must have unique nonempty ids")

    mapping = component_map(data)
    next_id = data.get("next_component_id")
    if next_id not in mapping:
        errors.append("next_component_id must name an existing component")
    elif mapping[next_id].get("design_status") not in {"next", "active"}:
        errors.append("next_component_id must have design_status next or active")

    active = [item["id"] for item in components if item.get("design_status") == "active"]
    if len(active) > 1:
        errors.append(f"only one component may be active: {active}")

    for item in components:
        cid = item.get("id", "<missing>")
        state = item.get("design_status")
        if state not in DESIGN_STATES:
            errors.append(f"{cid}: invalid design_status {state!r}")

        cycle = item.get("cycle", {})
        for stage_name in ("research", "audit", "exploration"):
            stage = cycle.get(stage_name, {})
            if stage.get("status") not in STAGE_STATES:
                errors.append(f"{cid}: {stage_name} has invalid status")
            if stage.get("status") == "complete" and not stage.get("evidence"):
                errors.append(f"{cid}: completed {stage_name} needs evidence")

        research = cycle.get("research", {})
        if research.get("status") == "complete":
            if not research.get("accessed_at"):
                errors.append(f"{cid}: completed research needs accessed_at")
            if not research.get("sources"):
                errors.append(f"{cid}: completed research needs source records")

        passes = cycle.get("passes", [])
        numbers = [entry.get("number") for entry in passes]
        if numbers != [1, 2, 3, 4, 5]:
            errors.append(f"{cid}: passes must be numbered 1 through 5")
            passes_are_ordered = False
        else:
            passes_are_ordered = True

        earlier_complete = True
        for entry in passes:
            pnum = entry.get("number")
            pstatus = entry.get("status")
            if pstatus not in STAGE_STATES:
                errors.append(f"{cid}: pass {pnum} has invalid status")
            prerequisites_complete = all(
                cycle.get(stage_name, {}).get("status") == "complete"
                for stage_name in ("research", "audit", "exploration")
            )
            if pstatus in {"in_progress", "complete"} and not prerequisites_complete:
                errors.append(
                    f"{cid}: pass {pnum} started before research, audit, "
                    "and exploration completion"
                )
            if pstatus in {"in_progress", "complete"} and not earlier_complete:
                errors.append(f"{cid}: pass {pnum} started before prior pass completion")
            if pstatus == "complete":
                for field in PASS_FIELDS:
                    if not str(entry.get(field, "")).strip():
                        errors.append(f"{cid}: completed pass {pnum} needs {field}")
                if not entry.get("evidence"):
                    errors.append(f"{cid}: completed pass {pnum} needs evidence")
            else:
                earlier_complete = False

        if state in {"owner_approved_direction", "complete"}:
            if cycle.get("research", {}).get("status") != "complete":
                errors.append(f"{cid}: approved design lacks completed research")
            if cycle.get("audit", {}).get("status") != "complete":
                errors.append(f"{cid}: approved design lacks completed audit")
            if cycle.get("exploration", {}).get("status") != "complete":
                errors.append(f"{cid}: approved design lacks completed exploration")
            if not passes_are_ordered or any(
                entry.get("status") != "complete" for entry in passes
            ):
                errors.append(f"{cid}: approved design lacks five completed passes")

    if data.get("authorization", {}).get("approved_for_swiftui"):
        for item in components:
            if item.get("native_proof", {}).get("status") != "complete":
                errors.append(f"{item['id']}: SwiftUI approval lacks complete native proof")
            if item.get("device_proof", {}).get("status") != "complete":
                errors.append(f"{item['id']}: SwiftUI approval lacks complete device proof")


def validate(
    data: dict[str, Any], repo: pathlib.Path | None = None
) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    _validate_program(data, errors)
    _validate_milestones(data, errors)
    _validate_components(data, errors)

    if repo is not None:
        expected = data.get("repository", {}).get("last_verified", {})
        actual_branch = run_git(repo, "branch", "--show-current")
        actual_head = run_git(repo, "rev-parse", "HEAD")
        actual_status = run_git(repo, "status", "--short").splitlines()
        if actual_branch != expected.get("branch"):
            errors.append(
                f"repository branch drift: ledger={expected.get('branch')} live={actual_branch}"
            )
        if actual_head != expected.get("head"):
            errors.append(
                f"repository HEAD drift: ledger={expected.get('head')} live={actual_head}"
            )
        if actual_status != expected.get("status_short", []):
            errors.append(
                "repository status drift; refresh the ledger without cleaning user changes"
            )

    verified_at = data.get("repository", {}).get("last_verified", {}).get("at")
    if verified_at:
        try:
            age = dt.datetime.now(dt.timezone.utc) - dt.datetime.fromisoformat(
                verified_at.replace("Z", "+00:00")
            )
            if age > dt.timedelta(days=1):
                warnings.append("repository verification is older than 24 hours")
        except ValueError:
            errors.append("repository.last_verified.at must be ISO-8601")

    return errors, warnings


def missing_owner_review(item: dict[str, Any]) -> list[str]:
    missing: list[str] = []
    cycle = item.get("cycle", {})
    for stage_name in ("research", "audit", "exploration"):
        if cycle.get(stage_name, {}).get("status") != "complete":
            missing.append(stage_name)
    for entry in cycle.get("passes", []):
        if entry.get("status") != "complete":
            missing.append(f"pass-{entry.get('number')}")
    gates = item.get("polish_gates", {})
    for number in range(1, 16):
        key = f"P{number:02d}"
        if gates.get(key) not in {"pass", "provisional", "not_applicable"}:
            missing.append(key)
    if not item.get("proof_ceiling"):
        missing.append("proof_ceiling")
    return missing


def missing_gate(
    data: dict[str, Any], kind: str, component_id: str | None = None
) -> list[str]:
    if kind == "owner-review":
        item = component_map(data).get(component_id or "")
        if item is None:
            return ["known_component"]
        return missing_owner_review(item)

    missing: list[str] = []
    milestones = milestone_map(data)
    approvals = data.get("approvals", {})
    if kind in {"frontend-complete", "runtime-integration"}:
        if milestones.get("UFP-5", {}).get("status") != "COMPLETE":
            missing.append("UFP-5")
        if approvals.get("frontend_design") is not True:
            missing.append("frontend_design_approval")
    if kind == "runtime-integration":
        if approvals.get("runtime_integration") is not True:
            missing.append("runtime_integration_approval")
    if kind == "cutover":
        if milestones.get("UFP-6", {}).get("status") != "COMPLETE":
            missing.append("UFP-6")
        if approvals.get("production_cutover") is not True:
            missing.append("production_cutover_approval")
        if approvals.get("legacy_deletion") is not True:
            missing.append("legacy_deletion_approval")
    if kind == "release":
        for milestone_id in ("UFP-7", "UFP-8"):
            if milestones.get(milestone_id, {}).get("status") != "COMPLETE":
                missing.append(milestone_id)
        verification = data.get("legacy_frontend", {}).get("verification", {})
        if verification.get("status") != "complete" or not verification.get("evidence"):
            missing.append("zero_legacy_verification")
        if approvals.get("release") is not True:
            missing.append("release_approval")
    return missing


def render(data: dict[str, Any]) -> str:
    mapping = component_map(data)
    next_id = data["next_component_id"]
    lines = [
        "# Ambitions Unified Frontend Program Status",
        "",
        f"Updated: {data.get('updated_at', 'unknown')}",
        f"Single authoritative program: `{str(data['single_authoritative_program']).lower()}`",
        f"Native Foundry: `{data['foundry']['role']}` (subordinate harness)",
        f"Next component: **{mapping[next_id]['label']}** (`{next_id}`)",
        "",
        "## Approvals",
        "",
        "| Gate | Approved |",
        "| --- | --- |",
    ]
    for field in APPROVAL_FIELDS:
        label = field.replace("_", " ").capitalize()
        lines.append(f"| {label} | {str(data['approvals'][field]).lower()} |")

    lines.extend(["", "## Unified milestones", ""])
    for milestone in data["milestones"]:
        dependencies = ", ".join(milestone["depends_on"]) or "none"
        lines.append(
            f"- **{milestone['id']}** — {milestone['status']}: {milestone['label']} "
            f"(depends on: {dependencies})"
        )

    lines.extend(
        [
            "",
            "## Components",
            "",
            "| Order | Component | Design status | Native proof | Device proof |",
            "| ---: | --- | --- | --- | --- |",
        ]
    )
    for item in sorted(data["components"], key=lambda value: value["order"]):
        lines.append(
            f"| {item['order']} | {item['label']} | {item['design_status']} | "
            f"{item['native_proof']['status']} | {item['device_proof']['status']} |"
        )
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    for command in ("status", "check", "gate", "render"):
        subparser = subparsers.add_parser(command)
        subparser.add_argument("--ledger", required=True, type=pathlib.Path)
        if command == "check":
            subparser.add_argument("--repo", type=pathlib.Path)
        if command == "gate":
            subparser.add_argument("--component")
            subparser.add_argument(
                "--kind",
                choices=(
                    "owner-review",
                    "frontend-complete",
                    "runtime-integration",
                    "cutover",
                    "release",
                ),
                required=True,
            )
        if command == "render":
            subparser.add_argument("--output", required=True, type=pathlib.Path)
    args = parser.parse_args()
    data = load(args.ledger)

    if args.command == "status":
        print(render(data), end="")
        return 0

    if args.command == "check":
        errors, warnings = validate(data, args.repo)
        for warning in warnings:
            print(f"WARNING: {warning}")
        for error in errors:
            print(f"ERROR: {error}")
        if errors:
            return 1
        print(f"OK: unified ledger valid; next={data['next_component_id']}")
        return 0

    if args.command == "gate":
        if args.kind == "owner-review" and not args.component:
            print("ERROR: --component is required for the owner-review gate")
            return 2
        if args.component and args.component not in component_map(data):
            print(f"ERROR: unknown component {args.component}")
            return 1
        missing = missing_gate(data, args.kind, args.component)
        if missing:
            print("BLOCKED: " + ", ".join(missing))
            return 1
        subject = args.component if args.kind == "owner-review" else "program"
        print(f"PASS: {subject} meets the {args.kind} gate")
        return 0

    output = args.output
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(render(data), encoding="utf-8")
    print(f"WROTE: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
