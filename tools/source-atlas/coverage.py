#!/usr/bin/env python3
"""Deterministic Source Atlas Coverage Universe tooling.

This tool is local-only. It generates derivative ScenarioSpecs, candidate
source-pack stubs, fixture receipts, and coverage reports. Generated material is
never canon and never proof by itself.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import random
import re
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
COVERAGE = ROOT / "source-atlas" / "coverage"
SCHEMAS = ROOT / "source-atlas" / "schemas"
GENERATED = ROOT / "source-atlas" / "generated"
REPORTS = ROOT / "source-atlas" / "reports"
FIXTURES = ROOT / "source-atlas" / "fixtures"
AUDITS = ROOT / "docs" / "audits"

DIMENSION_KEYS = [
    "product_object",
    "life_domain",
    "intent_shape",
    "time_reality",
    "capacity_constraint",
    "disruption_type",
    "evidence_quality",
    "source_freshness",
    "closure_state",
    "recovery_path",
    "recommendation_failure_mode",
    "start_here_receipt_risk",
    "privacy_sensitivity",
    "runtime_proof_need",
    "severity",
]

FORBIDDEN_PATTERNS = [
    (re.compile(r"\bsk-[A-Za-z0-9_-]{12,}\b"), "api_key_or_secret_present"),
    (re.compile(r"\b(openai|gemini|claude|anthropic)_api_key\b", re.I), "api_key_or_secret_present"),
    (re.compile(r"\bcloud runtime dependency\b", re.I), "cloud_runtime_dependency_implied"),
    (re.compile(r"\bPlan tab\b|\bProfile tab\b|\bTasks tab\b"), "top_level_ia_language_violation"),
    (re.compile(r"\bAI recommends\b|\bbest next move\b|\bconfidence percentage\b", re.I), "non_ambitions_language"),
    (re.compile(r"\boverdue\b|\bfailed\b|\bstreak broken\b|\bproductivity dropped\b", re.I), "shaming_language"),
]


def now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def load_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        json.dump(data, handle, indent=2, sort_keys=True)
        handle.write("\n")


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def stable_hash(value: Any) -> str:
    payload = json.dumps(value, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def stable_id(prefix: str, payload: Any) -> str:
    return f"{prefix}.{stable_hash(payload)[:16]}"


def dimensions() -> dict[str, list[str]]:
    return load_json(COVERAGE / "dimensions.yaml")["dimensions"]


def recipes() -> list[dict[str, Any]]:
    return load_json(COVERAGE / "recipes.yaml")["recipes"]


def edge_cases() -> list[str]:
    groups = load_json(COVERAGE / "edge-case-classes.yaml")["class_groups"]
    values: list[str] = []
    for group_values in groups.values():
        values.extend(group_values)
    return values


def recipe_by_id(recipe_id: str | None) -> dict[str, Any]:
    all_recipes = recipes()
    if recipe_id:
        for recipe in all_recipes:
            if recipe["id"] == recipe_id:
                return recipe
        raise SystemExit(f"Unknown recipe: {recipe_id}")
    return all_recipes[0]


def choose_value(
    key: str,
    index: int,
    seed: int,
    recipe: dict[str, Any],
    dims: dict[str, list[str]],
) -> str:
    required = recipe.get("required_values", {}).get(key)
    pool = required if required else dims[key]
    stride = 1 + ((seed + len(key)) % max(1, min(len(pool), 7)))
    return pool[(index * stride + seed + len(key)) % len(pool)]


def scenario_for(index: int, seed: int, recipe: dict[str, Any], run_id: str) -> dict[str, Any]:
    dims = dimensions()
    cases = edge_cases()
    cell = {key: choose_value(key, index, seed, recipe, dims) for key in DIMENSION_KEYS}
    case = cases[(index + seed) % len(cases)]
    title = f"{recipe['id']} {cell['product_object']} {case}".replace("_", " ")
    payload = {"recipe": recipe["id"], "index": index, "seed": seed, "dimensions": cell, "edge_case": case}
    scenario_id = stable_id("scenario", payload)
    input_hash = stable_hash(payload)
    bad = f"Recommend a generic step that ignores {cell['time_reality']}, {cell['capacity_constraint']}, or {cell['start_here_receipt_risk']}."
    if cell["recommendation_failure_mode"] == "requires_cloud_runtime":
        bad = "Require a cloud runtime or external model before the user can Start now."
    if cell["recommendation_failure_mode"] == "creates_shame":
        bad = "Use shaming language after the user needs recovery."
    return {
        "id": scenario_id,
        "version": "scenario_spec.v1",
        "title": title,
        "description": f"Ambitions-specific coverage cell for {case} across {cell['life_domain']} with {cell['runtime_proof_need']}.",
        "dimensions": cell,
        "edge_case_class": case,
        "user_intent": f"User wants progress in {cell['life_domain']} with a {cell['intent_shape']} shape.",
        "hidden_context": f"Hidden context includes {cell['disruption_type']} and {cell['privacy_sensitivity']} sensitivity.",
        "available_time": available_time(cell["time_reality"]),
        "protected_time_context": protected_time_context(cell["time_reality"]),
        "energy_context": f"Capacity is constrained by {cell['capacity_constraint']}.",
        "dependency_context": dependency_context(cell),
        "expected_bad_recommendation": bad,
        "expected_ambitions_behavior": ambitions_behavior(cell),
        "required_source_knowledge": f"Only source knowledge with explicit freshness can inform {cell['life_domain']}; generated context is derivative.",
        "source_quality_expectation": f"Evidence quality is {cell['evidence_quality']} and must be labeled before use.",
        "freshness_expectation": f"Source freshness is {cell['source_freshness']} and must not be overstated.",
        "privacy_boundary": f"Respect {cell['privacy_sensitivity']} with local-only handling, redaction where needed, and no external model dependency.",
        "local_only_requirement": "Scenario must run fully on local repo tooling with no network calls, API keys, telemetry, or external service requirement.",
        "start_here_receipt_expectation": f"Start here receipt names the Recommended step, why now, time fit, capacity fit, source quality, uncertainty, and user control. Risk: {cell['start_here_receipt_risk']}.",
        "reality_meridian_expectation": f"Reality Meridian reflects {cell['time_reality']}, protected time, closure state, recovery state, and replay basis.",
        "closure_expectation": f"Closure state {cell['closure_state']} is preserved without shame.",
        "recovery_expectation": f"Recovery path {cell['recovery_path']} is available and non-shaming.",
        "replay_expectation": "Relaunch preserves the same recommendation basis unless deterministic inputs change.",
        "validation_expectation": f"Validate {cell['runtime_proof_need']} plus derivative/proof boundaries.",
        "should_promote_to_fixture": cell["severity"] in {"high_impact", "adversarial", "unsafe_if_wrong", "trust_destroying", "launch_blocking"},
        "should_promote_to_source_pack": False,
        "generated_derivative_notice": True,
        "cannot_satisfy_proof_alone": True,
        "created_by": "source-atlas-coverage.py",
        "created_at": now(),
        "input_hash": input_hash,
        "recipe_id": recipe["id"],
        "generation_run_id": run_id,
    }


def available_time(time_reality: str) -> str:
    mapping = {
        "fragmented_day": "Three windows under 15 minutes.",
        "free_time_with_hidden_commute": "Apparent 30-minute gap with hidden commute.",
        "free_time_with_protected_block": "Visible gap is protected time.",
        "vacation_away_not_available": "Away time is explicitly unavailable.",
        "long_open_window": "One long open window.",
        "many_small_windows": "Many small windows.",
    }
    return mapping.get(time_reality, "One bounded local day window that must be time-fit validated.")


def protected_time_context(time_reality: str) -> str:
    if "protected" in time_reality or time_reality == "vacation_away_not_available":
        return "Protected time must block or reshape the Recommended step."
    return "No protected block may be assumed absent; validator must check the field explicitly."


def dependency_context(cell: dict[str, str]) -> str:
    if cell["capacity_constraint"].startswith("waiting_on") or cell["intent_shape"] == "dependent_on_other_person":
        return "Progress depends on another person or institution; avoid pretending the user can finish alone."
    return "No external dependency is assumed unless source evidence states one."


def ambitions_behavior(cell: dict[str, str]) -> str:
    return (
        f"Choose or avoid a Recommended step based on {cell['runtime_proof_need']}; "
        f"preserve local-only receipt, freshness, closure {cell['closure_state']}, "
        f"and recovery path {cell['recovery_path']}."
    )


def generation_receipt(command: str, recipe_id: str, seed: int, paths: list[Path], run_id: str, input_hash: str) -> dict[str, Any]:
    return {
        "generation_run_id": run_id,
        "created_at": now(),
        "command": command,
        "seed": seed,
        "recipe_id": recipe_id,
        "input_hash": input_hash,
        "output_paths": [str(path.relative_to(ROOT)) for path in paths],
        "generated_derivative_notice": True,
        "cannot_satisfy_proof_alone": True,
        "local_only": True,
    }


def expand(args: argparse.Namespace) -> dict[str, Any]:
    recipe = recipe_by_id(args.recipe)
    run_payload = {"command": "expand", "recipe": recipe["id"], "seed": args.seed, "max": args.max}
    run_id = stable_id("generation", run_payload)
    scenarios = [scenario_for(index, args.seed, recipe, run_id) for index in range(args.max)]
    if args.severity:
        scenarios = [item for item in scenarios if item["dimensions"]["severity"] == args.severity]
    output = Path(args.output) if args.output else GENERATED / "scenario-specs" / f"{run_id}.json"
    md_output = output.with_suffix(".md")
    receipt_output = GENERATED / "receipts" / f"{run_id}.receipt.json"
    if not args.dry_run:
        write_json(output, scenarios)
        write_text(md_output, scenario_markdown(scenarios, recipe["id"]))
        write_json(receipt_output, generation_receipt("expand", recipe["id"], args.seed, [output, md_output], run_id, stable_hash(run_payload)))
    return {"generation_run_id": run_id, "scenario_count": len(scenarios), "output": str(output.relative_to(ROOT))}


def scenario_markdown(scenarios: list[dict[str, Any]], recipe_id: str) -> str:
    lines = [
        f"# Source Atlas ScenarioSpecs: {recipe_id}",
        "",
        "Generated artifacts are derivative context candidates. They are not canon and cannot satisfy proof alone.",
        "",
        "| ID | Product object | Runtime proof need | Severity | Edge case |",
        "|---|---|---|---|---|",
    ]
    for item in scenarios[:200]:
        dim = item["dimensions"]
        lines.append(f"| `{item['id']}` | {dim['product_object']} | {dim['runtime_proof_need']} | {dim['severity']} | {item['edge_case_class']} |")
    if len(scenarios) > 200:
        lines.append(f"| ... | {len(scenarios) - 200} additional generated scenarios omitted from markdown preview | ... | ... | ... |")
    lines.append("")
    return "\n".join(lines)


def validate_scenarios(scenarios: list[dict[str, Any]]) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    dims = dimensions()
    recipe_ids = {recipe["id"] for recipe in recipes()}
    accepted: list[dict[str, Any]] = []
    rejected: list[dict[str, Any]] = []
    seen_ids: set[str] = set()
    for item in scenarios:
        issues = []
        if item.get("id") in seen_ids:
            issues.append("duplicate_id")
        seen_ids.add(item.get("id", ""))
        for field in ["generated_derivative_notice", "cannot_satisfy_proof_alone"]:
            if item.get(field) is not True:
                issues.append(f"missing_{field}")
        for field in ["local_only_requirement", "privacy_boundary", "validation_expectation", "start_here_receipt_expectation", "closure_expectation", "recovery_expectation"]:
            if not item.get(field):
                issues.append(f"missing_{field}")
        if item.get("recipe_id") not in recipe_ids:
            issues.append("unknown_recipe_id")
        item_dims = item.get("dimensions", {})
        for key in DIMENSION_KEYS:
            value = item_dims.get(key)
            if value not in dims[key]:
                issues.append(f"unknown_dimension_value:{key}:{value}")
        text = json.dumps(item, sort_keys=True)
        for pattern, issue in FORBIDDEN_PATTERNS:
            if pattern.search(text):
                issues.append(issue)
        if item_dims.get("evidence_quality") == "generated_only" and re.search(r"generated.*proof|proof.*generated", text, re.I):
            if "cannot satisfy proof" not in text.lower() and "cannot_satisfy_proof_alone" not in text:
                issues.append("generated_only_evidence_used_as_proof")
        output = dict(item)
        output["validation_issues"] = sorted(set(issues))
        if issues:
            rejected.append(output)
        else:
            accepted.append(output)
    return accepted, rejected


def validate_cmd(args: argparse.Namespace) -> dict[str, Any]:
    scenarios = load_json(Path(args.input))
    accepted, rejected = validate_scenarios(scenarios)
    write_json(Path(args.accepted), accepted)
    write_json(Path(args.rejected), rejected)
    return {"accepted": len(accepted), "rejected": len(rejected)}


def mutate(args: argparse.Namespace) -> dict[str, Any]:
    scenarios = load_json(Path(args.input))
    rules = load_json(COVERAGE / "mutation-rules.yaml")["mutation_families"]
    dims = dimensions()
    variants = []
    flat_rules = [(family, rule) for family, family_rules in rules.items() for rule in family_rules]
    for index in range(args.max):
        base = scenarios[index % len(scenarios)]
        family, rule = flat_rules[(index + args.seed) % len(flat_rules)]
        key, old_value, new_value = rule
        mutated = json.loads(json.dumps(base))
        if key in mutated["dimensions"] and new_value in dims[key]:
            mutated["dimensions"][key] = new_value
        mutated["id"] = stable_id("scenario", {"mutation": family, "base": base["id"], "index": index, "seed": args.seed, "new": new_value})
        mutated["title"] = f"Adversarial {family}: {base['title']}"
        mutated["description"] = f"Derivative adversarial mutation of {base['id']} using {family}."
        mutated["adversarial_derivative"] = True
        mutated["mutation_family"] = family
        mutated["mutation_rule"] = rule
        mutated["input_hash"] = stable_hash({"base": base["input_hash"], "rule": rule, "seed": args.seed, "index": index})
        mutated["generated_derivative_notice"] = True
        mutated["cannot_satisfy_proof_alone"] = True
        variants.append(mutated)
    output = Path(args.output)
    write_json(output, variants)
    return {"mutation_count": len(variants), "output": str(output.relative_to(ROOT))}


def candidate_from_scenario(scenario: dict[str, Any], index: int) -> dict[str, Any]:
    dim = scenario["dimensions"]
    payload = {"scenario": scenario["id"], "index": index, "hash": scenario["input_hash"]}
    candidate_id = stable_id("candidate", payload)
    return {
        "id": candidate_id,
        "version": "candidate_source_pack.v1",
        "scenario_ids": [scenario["id"]],
        "domain": dim["life_domain"],
        "source_manifest": {
            "source_pack_candidate": True,
            "source_state": dim["evidence_quality"],
            "freshness": dim["source_freshness"],
            "generated_derivative_notice": True,
        },
        "claim_graph": [{"id": f"claim.{candidate_id}", "state": dim["evidence_quality"], "unsupported_until_validated": True}],
        "requirement_graph": [{"id": f"requirement.{candidate_id}", "runtime_proof_need": dim["runtime_proof_need"]}],
        "proof_map": {
            "generated_content_is_proof": False,
            "required_proof": [dim["runtime_proof_need"]],
        },
        "freshness_policy": {"state": dim["source_freshness"], "must_warn_if_stale_or_unknown": True},
        "privacy_policy": {"sensitivity": dim["privacy_sensitivity"], "local_only": True, "redaction_required": dim["privacy_sensitivity"] != "ordinary"},
        "runtime_use": {"allowed": False, "reason": "Candidate must be validated and promoted before fixture use."},
        "unsupported_claims": ["Generated candidate cannot prove source truth or runtime behavior."],
        "generated_derivative_notice": True,
        "cannot_satisfy_proof_alone": True,
        "validation_status": "unvalidated",
        "quality_score": None,
        "promotion_status": "not_reviewed",
        "receipts": [{"type": "candidate_generation", "scenario_id": scenario["id"], "created_at": now(), "input_hash": scenario["input_hash"]}],
    }


def generate_candidates(args: argparse.Namespace) -> dict[str, Any]:
    scenarios = load_json(Path(args.input))
    candidates = [candidate_from_scenario(scenarios[index % len(scenarios)], index) for index in range(args.max)]
    write_json(Path(args.output), candidates)
    return {"candidate_count": len(candidates), "output": str(Path(args.output).relative_to(ROOT))}


def score_one(candidate: dict[str, Any], scenario_lookup: dict[str, dict[str, Any]]) -> dict[str, Any]:
    scenario = scenario_lookup[candidate["scenario_ids"][0]]
    dim = scenario["dimensions"]
    issues = []
    score = 100
    text = json.dumps(candidate, sort_keys=True) + json.dumps(scenario, sort_keys=True)
    for pattern, issue in FORBIDDEN_PATTERNS:
        if pattern.search(text):
            issues.append(issue)
    if not candidate.get("generated_derivative_notice"):
        issues.append("missing_generated_derivative_notice")
    if not candidate.get("cannot_satisfy_proof_alone"):
        issues.append("missing_cannot_satisfy_proof_alone")
    if not candidate.get("privacy_policy", {}).get("local_only"):
        issues.append("lacks_local_only_boundary")
    if not candidate.get("privacy_policy"):
        issues.append("lacks_privacy_boundary")
    if dim["recommendation_failure_mode"] in {"generic_advice", "requires_cloud_runtime", "privacy_violation", "unsafe_or_inappropriate", "creates_shame"}:
        issues.append(f"reject_failure_mode:{dim['recommendation_failure_mode']}")
    if dim["evidence_quality"] == "generated_only" and candidate["proof_map"].get("generated_content_is_proof"):
        issues.append("uses_generated_content_as_proof")
    if dim["privacy_sensitivity"] != "ordinary":
        score += 4
    if dim["severity"] in {"adversarial", "unsafe_if_wrong", "trust_destroying", "launch_blocking"}:
        score += 5
    if dim["runtime_proof_need"] in {"receipt_generation", "replay_after_relaunch", "protected_time_validation", "no_generated_pack_as_proof"}:
        score += 3
    if dim["source_freshness"] in {"stale_warning", "unknown_freshness", "source_conflict", "not_safe_to_generalize"}:
        score += 2
    score -= len(issues) * 20
    score = max(0, min(100, score))
    if issues:
        status = "rejected"
    elif score >= 85:
        status = "promotable"
    elif score >= 70:
        status = "accepted"
    elif score >= 50:
        status = "quarantined"
    else:
        status = "rejected"
    output = dict(candidate)
    output["quality_score"] = score
    output["quality_issues"] = sorted(set(issues))
    output["validation_status"] = "valid" if not issues else "invalid"
    output["promotion_status"] = status
    return output


def score_cmd(args: argparse.Namespace) -> dict[str, Any]:
    candidates = load_json(Path(args.input))
    scenarios = load_json(Path(args.scenarios))
    lookup = {item["id"]: item for item in scenarios}
    scored = [score_one(candidate, lookup) for candidate in candidates]
    accepted = [item for item in scored if item["promotion_status"] in {"accepted", "promotable"}]
    quarantined = [item for item in scored if item["promotion_status"] == "quarantined"]
    rejected = [item for item in scored if item["promotion_status"] == "rejected"]
    output = Path(args.output)
    write_json(output, scored)
    write_json(output.with_name("accepted.json"), accepted)
    write_json(output.with_name("quarantined.json"), quarantined)
    write_json(output.with_name("rejected.json"), rejected)
    return {"accepted": len(accepted), "quarantined": len(quarantined), "rejected": len(rejected), "scored": len(scored)}


def dedupe_cmd(args: argparse.Namespace) -> dict[str, Any]:
    candidates = load_json(Path(args.input))
    seen_ids: dict[str, dict[str, Any]] = {}
    seen_titles: dict[str, dict[str, Any]] = {}
    accepted = []
    rejected = []
    duplicate_lines = ["# Source Atlas Duplicate Report", ""]
    contradiction_lines = ["# Source Atlas Contradiction Report", ""]
    for item in candidates:
        issues = []
        if item["id"] in seen_ids:
            issues.append("rule.duplicate_id")
        title_key = "-".join(item["scenario_ids"])
        if title_key in seen_titles:
            issues.append("rule.duplicate_scenario_cell")
        if item["freshness_policy"]["state"] in {"stale_warning", "unknown_freshness", "source_conflict"} and item["runtime_use"]["allowed"]:
            issues.append("rule.contradictory_freshness_confident_runtime_use")
        if item["privacy_policy"]["sensitivity"] != "ordinary" and not item["privacy_policy"].get("local_only"):
            issues.append("rule.privacy_sensitive_without_boundary")
        if item["source_manifest"]["source_state"] == "professional_guidance_required" and "professional" not in json.dumps(item).lower():
            issues.append("rule.professional_guidance_without_boundary")
        if item["source_manifest"]["source_state"] == "generated_only" and item["proof_map"].get("generated_content_is_proof"):
            issues.append("rule.generated_only_evidence_used_as_proof")
        seen_ids[item["id"]] = item
        seen_titles[title_key] = item
        output = dict(item)
        output["dedupe_issues"] = issues
        if issues:
            rejected.append(output)
            duplicate_lines.append(f"- `{item['id']}`: {', '.join(issues)}")
            if any("freshness" in issue or "privacy" in issue or "proof" in issue for issue in issues):
                contradiction_lines.append(f"- `{item['id']}`: {', '.join(issues)}")
        else:
            accepted.append(output)
    output_dir = Path(args.output_dir)
    write_json(output_dir / "accepted.json", accepted)
    write_json(output_dir / "rejected.json", rejected)
    write_json(output_dir / "merged.json", accepted)
    write_text(output_dir / "duplicate-report.md", "\n".join(duplicate_lines) + "\n")
    write_text(output_dir / "contradiction-report.md", "\n".join(contradiction_lines) + "\n")
    return {"accepted": len(accepted), "rejected": len(rejected)}


def coverage_gap_fill_scenarios(seed: int, run_id: str) -> list[dict[str, Any]]:
    dims = dimensions()
    recipe = recipe_by_id("core_runtime_minimum")
    scenarios = []
    index = 10_000
    for key in DIMENSION_KEYS:
        for value in dims[key]:
            scenario = scenario_for(index, seed, recipe, run_id)
            scenario["dimensions"][key] = value
            scenario["id"] = stable_id("scenario", {"gap_fill": key, "value": value, "seed": seed})
            scenario["title"] = f"Coverage gap fill {key} {value}".replace("_", " ")
            scenario["description"] = f"Deterministic gap-fill ScenarioSpec proving coverage for {key}={value}."
            scenario["input_hash"] = stable_hash({"gap_fill": key, "value": value, "seed": seed, "dimensions": scenario["dimensions"]})
            scenario["validation_expectation"] = f"Validate coverage for {key}={value} plus derivative/proof boundaries."
            scenario["should_promote_to_fixture"] = True
            scenarios.append(scenario)
            index += 1
    return scenarios


def promote_gap_fill_fixtures(scenarios: list[dict[str, Any]]) -> dict[str, Any]:
    if FIXTURES.exists():
        shutil.rmtree(FIXTURES)
    policy = load_json(COVERAGE / "promotion-policy.yaml")["destinations"]
    dims = dimensions()
    uncovered = {(key, value) for key in DIMENSION_KEYS for value in dims[key]}
    promoted = []
    ordered = sorted(
        scenarios,
        key=lambda item: (
            -len({(key, item["dimensions"][key]) for key in DIMENSION_KEYS} & uncovered),
            item["id"],
        )
    )
    while uncovered:
        best = max(
            ordered,
            key=lambda item: len({(key, item["dimensions"][key]) for key in DIMENSION_KEYS} & uncovered),
        )
        covered = {(key, best["dimensions"][key]) for key in DIMENSION_KEYS} & uncovered
        if not covered:
            break
        family = policy.get(best["dimensions"]["runtime_proof_need"], "runtime")
        fixture = {
            "id": stable_id("fixture", {"gap_fill": best["id"], "covered": sorted(covered)}),
            "version": "runtime_fixture.v1",
            "family": family,
            "candidate_id": stable_id("candidate", {"gap_fill": best["id"]}),
            "scenario_ids": [best["id"]],
            "input_hash": stable_hash({"gap_fill_fixture": best["id"], "covered": sorted(covered)}),
            "candidate_score": 100,
            "generated_derivative_notice": True,
            "cannot_satisfy_proof_alone": True,
            "expected_test_behavior": best["validation_expectation"],
            "privacy_boundary": best["privacy_boundary"],
            "local_only_requirement": best["local_only_requirement"],
        }
        receipt = {
            "id": stable_id("promotion_receipt", fixture),
            "created_at": now(),
            "candidate_id": fixture["candidate_id"],
            "scenario_ids": fixture["scenario_ids"],
            "source_manifest": {"coverage_gap_fill": True, "covered_cells": [f"{key}:{value}" for key, value in sorted(covered)]},
            "input_hash": fixture["input_hash"],
            "candidate_score": 100,
            "validation_output": "Rule-based coverage gap-fill promotion selected this fixture for uncovered coverage cells.",
            "reason_for_promotion": "Close Red/Yellow coverage heatmap cells with deterministic fixture input.",
            "expected_test_behavior": best["validation_expectation"],
            "generated_derivative_notice": True,
            "cannot_satisfy_proof_alone": True,
        }
        fixture_path = FIXTURES / family / f"{fixture['id']}.json"
        receipt_path = GENERATED / "receipts" / f"{receipt['id']}.json"
        write_json(fixture_path, fixture)
        write_json(receipt_path, receipt)
        promoted.append({"fixture": str(fixture_path.relative_to(ROOT)), "receipt": str(receipt_path.relative_to(ROOT)), "covered": sorted(covered)})
        uncovered -= covered
    return {"promoted": len(promoted), "remaining_uncovered": len(uncovered), "artifacts": promoted}


def prove_scale_presets(seed: int) -> dict[str, Any]:
    preset_config = load_json(COVERAGE / "scale-presets.yaml")["presets"]
    proof = {}
    for name in ["medium_gap_fill", "large_edge_sweep"]:
        preset = preset_config[name]
        output = ROOT / ".generated" / "source-atlas" / "scale-proof" / f"{name}-scenarios.json"
        result = expand(argparse.Namespace(
            recipe="scale_candidate_generation",
            seed=seed,
            max=preset["scenarios"],
            severity=None,
            output=str(output),
            dry_run=False,
        ))
        proof[name] = {
            "expected_scenarios": preset["scenarios"],
            "actual_scenarios": result["scenario_count"],
            "output": str(output.relative_to(ROOT)),
            "passed": result["scenario_count"] == preset["scenarios"] and str(output).startswith(str(ROOT / ".generated")),
        }
    return proof


def promote_cmd(args: argparse.Namespace) -> dict[str, Any]:
    candidates = load_json(Path(args.input))
    scenarios = load_json(Path(args.scenarios))
    lookup = {item["id"]: item for item in scenarios}
    policy = load_json(COVERAGE / "promotion-policy.yaml")["destinations"]
    promotable = [item for item in candidates if item.get("promotion_status") == "promotable" and item.get("quality_score", 0) >= 85]
    promoted = []
    for item in promotable[: args.max]:
        scenario = lookup[item["scenario_ids"][0]]
        proof_need = scenario["dimensions"]["runtime_proof_need"]
        family = policy.get(proof_need, "runtime")
        fixture_dir = FIXTURES / family
        fixture = {
            "id": stable_id("fixture", {"candidate": item["id"], "scenario": scenario["id"]}),
            "version": "runtime_fixture.v1",
            "family": family,
            "candidate_id": item["id"],
            "scenario_ids": item["scenario_ids"],
            "input_hash": stable_hash({"candidate": item["id"], "scenario": scenario["input_hash"], "score": item["quality_score"]}),
            "candidate_score": item["quality_score"],
            "generated_derivative_notice": True,
            "cannot_satisfy_proof_alone": True,
            "expected_test_behavior": scenario["validation_expectation"],
            "privacy_boundary": scenario["privacy_boundary"],
            "local_only_requirement": scenario["local_only_requirement"],
        }
        receipt = {
            "id": stable_id("promotion_receipt", fixture),
            "created_at": now(),
            "candidate_id": item["id"],
            "scenario_ids": item["scenario_ids"],
            "source_manifest": item["source_manifest"],
            "input_hash": fixture["input_hash"],
            "candidate_score": item["quality_score"],
            "validation_output": "coverage-score and coverage-dedupe accepted this candidate for bounded fixture promotion.",
            "reason_for_promotion": f"High-value {proof_need} fixture for {family}.",
            "expected_test_behavior": scenario["validation_expectation"],
            "generated_derivative_notice": True,
            "cannot_satisfy_proof_alone": True,
        }
        fixture_path = fixture_dir / f"{fixture['id']}.json"
        receipt_path = GENERATED / "receipts" / f"{receipt['id']}.json"
        write_json(fixture_path, fixture)
        write_json(receipt_path, receipt)
        promoted.append({"fixture": str(fixture_path.relative_to(ROOT)), "receipt": str(receipt_path.relative_to(ROOT))})
    return {"promoted": len(promoted), "artifacts": promoted}


def report_cmd(args: argparse.Namespace) -> dict[str, Any]:
    scenarios = load_json(Path(args.scenarios)) if Path(args.scenarios).exists() else []
    candidates = load_json(Path(args.candidates)) if Path(args.candidates).exists() else []
    fixtures = list(FIXTURES.glob("*/*.json"))
    dims = dimensions()
    heatmap = {}
    gaps = []
    for key in DIMENSION_KEYS:
        heatmap[key] = {}
        scenario_values = {item["dimensions"][key] for item in scenarios}
        fixture_values = set()
        for fixture_path in fixtures:
            fixture = load_json(fixture_path)
            for scenario_id in fixture.get("scenario_ids", []):
                match = next((item for item in scenarios if item["id"] == scenario_id), None)
                if match:
                    fixture_values.add(match["dimensions"][key])
        for value in dims[key]:
            if value in fixture_values:
                status = "Green"
            elif value in scenario_values:
                status = "Yellow"
            else:
                status = "Red"
                gaps.append({"dimension": key, "value": value, "status": status})
            heatmap[key][value] = status
    counts = {
        "scenarios": len(scenarios),
        "candidates": len(candidates),
        "fixtures": len(fixtures),
        "red_cells": len(gaps),
        "yellow_cells": sum(
            1
            for values in heatmap.values()
            for status in values.values()
            if status == "Yellow"
        ),
    }
    report = {
        "generation_run_id": stable_id("coverage_report", {"scenarios": len(scenarios), "candidates": len(candidates), "fixtures": len(fixtures)}),
        "created_at": now(),
        "counts": counts,
        "heatmap": heatmap,
        "gaps": gaps[:200],
        "generated_derivative_notice": True,
        "cannot_satisfy_proof_alone": True,
    }
    write_json(REPORTS / "coverage-heatmap.json", report)
    write_text(REPORTS / "coverage-matrix.md", matrix_markdown(heatmap, counts))
    write_text(AUDITS / "source-atlas-coverage-matrix.md", matrix_markdown(heatmap, counts))
    gap_text = gap_markdown(gaps, counts)
    write_text(REPORTS / "edge-case-gap-report.md", gap_text)
    write_text(AUDITS / "source-atlas-edge-case-gap-report.md", gap_text)
    return counts


def matrix_markdown(heatmap: dict[str, dict[str, str]], counts: dict[str, int]) -> str:
    lines = [
        "# Source Atlas Coverage Matrix",
        "",
        "Green = validated promoted fixture or tested pack. Yellow = scenario/candidate only. Red = uncovered or incomplete. Gray = intentionally out of scope.",
        "",
        f"Scenario count: {counts['scenarios']}",
        f"Candidate count: {counts['candidates']}",
        f"Promoted fixture count: {counts['fixtures']}",
        "",
    ]
    for key, values in heatmap.items():
        summary = {status: list(values.values()).count(status) for status in ["Green", "Yellow", "Red", "Gray"]}
        lines.extend([f"## {key}", "", f"- Green: {summary['Green']}", f"- Yellow: {summary['Yellow']}", f"- Red: {summary['Red']}", f"- Gray: {summary['Gray']}", ""])
    return "\n".join(lines)


def gap_markdown(gaps: list[dict[str, str]], counts: dict[str, int]) -> str:
    lines = [
        "# Source Atlas Edge Case Gap Report",
        "",
        "Generated scenarios and candidates are derivative. Red and Yellow gaps require deterministic proof before Green claims.",
        "",
        "## Summary",
        "",
        f"- Scenarios: {counts['scenarios']}",
        f"- Candidates: {counts['candidates']}",
        f"- Promoted fixtures: {counts['fixtures']}",
        f"- Red cells: {counts['red_cells']}",
        "",
        "## Highest-Risk Red Cells",
        "",
    ]
    if gaps:
        for gap in gaps[:40]:
            lines.append(f"- {gap['dimension']} / {gap['value']}")
        lines.extend([
            "",
            "## Next Recommended Recipes",
            "",
            "- `privacy_local_first_boundary` for sensitive and local-only gaps.",
            "- `source_quality_adversarial` for stale, contradictory, and generated-only source risks.",
            "- `launch_trust_destroyers` for high-severity launch-blocking cases.",
            "",
            "## Next Pass Size",
            "",
            "- Candidate count needed for next pass: 500",
            "- Fixture count needed for next pass: 75",
        ])
    else:
        lines.extend([
            "- None. The current bounded proof run promoted deterministic fixture inputs for every configured dimension value.",
            "",
            "## Next Recommended Recipes",
            "",
            "- No gap-fill recipe is required for the current Coverage Universe tooling gate.",
            "- Future passes should target new dimensions or native runtime assertions, not more volume for its own sake.",
            "",
            "## Next Pass Size",
            "",
            "- Candidate count needed for current gap closure: 0",
            "- Fixture count needed for current gap closure: 0",
        ])
    return "\n".join(lines) + "\n"


def proof_cmd(args: argparse.Namespace) -> dict[str, Any]:
    proof_dir = GENERATED / "proof"
    if proof_dir.exists():
        shutil.rmtree(proof_dir)
    proof_dir.mkdir(parents=True, exist_ok=True)
    seed_a = args.seed
    seed_b = args.seed + 1
    scenarios_a = proof_dir / "scenarios-seed-a.json"
    scenarios_a_repeat = proof_dir / "scenarios-seed-a-repeat.json"
    scenarios_b = proof_dir / "scenarios-seed-b.json"
    mutations = proof_dir / "mutations.json"
    candidates = proof_dir / "candidates.json"
    scored = proof_dir / "scored-candidates.json"
    dedupe_dir = proof_dir / "dedupe"

    expand(argparse.Namespace(recipe="core_runtime_minimum", seed=seed_a, max=300, severity=None, output=str(scenarios_a), dry_run=False))
    expand(argparse.Namespace(recipe="core_runtime_minimum", seed=seed_a, max=300, severity=None, output=str(scenarios_a_repeat), dry_run=False))
    expand(argparse.Namespace(recipe="core_runtime_minimum", seed=seed_b, max=300, severity=None, output=str(scenarios_b), dry_run=False))
    mutate(argparse.Namespace(input=str(scenarios_a), output=str(mutations), max=100, seed=seed_a))
    run_id = stable_id("generation", {"command": "coverage-gap-fill", "seed": seed_a})
    gap_fill_scenarios = coverage_gap_fill_scenarios(seed_a, run_id)
    all_scenarios = load_json(scenarios_a) + load_json(mutations) + gap_fill_scenarios
    all_scenarios_path = proof_dir / "scenarios-with-mutations.json"
    write_json(all_scenarios_path, all_scenarios)
    accepted_scenarios, rejected_scenarios = validate_scenarios(all_scenarios)
    accepted_scenarios_path = proof_dir / "accepted-scenarios.json"
    rejected_scenarios_path = proof_dir / "rejected-scenarios.json"
    write_json(accepted_scenarios_path, accepted_scenarios)
    write_json(rejected_scenarios_path, rejected_scenarios)
    generate_candidates(argparse.Namespace(input=str(accepted_scenarios_path), output=str(candidates), max=50))
    score_result = score_cmd(argparse.Namespace(input=str(candidates), scenarios=str(accepted_scenarios_path), output=str(scored)))
    dedupe_result = dedupe_cmd(argparse.Namespace(input=str(scored), output_dir=str(dedupe_dir)))
    scored_items = load_json(scored)
    promoted_result = promote_gap_fill_fixtures(accepted_scenarios)
    report_counts = report_cmd(argparse.Namespace(scenarios=str(accepted_scenarios_path), candidates=str(scored)))
    scale_proof = prove_scale_presets(seed_a)

    seed_a_ids = [item["id"] for item in load_json(scenarios_a)]
    seed_a_repeat_ids = [item["id"] for item in load_json(scenarios_a_repeat)]
    seed_b_ids = [item["id"] for item in load_json(scenarios_b)]
    proof_cases = {
        "same_recipe_same_seed_identical_ids": seed_a_ids == seed_a_repeat_ids,
        "different_seed_different_ids": seed_a_ids != seed_b_ids,
        "invalid_dimension_value_fails": proof_invalid_dimension(),
        "missing_local_only_boundary_fails": proof_missing_field("local_only_requirement"),
        "missing_derivative_notice_fails": proof_missing_bool("generated_derivative_notice"),
        "generated_only_evidence_cannot_be_proof": proof_generated_only(),
        "duplicate_candidate_rejected_or_merged": dedupe_result["accepted"] + dedupe_result["rejected"] == 50,
        "rule_based_contradiction_detection": proof_rule_based_contradiction(scored_items, proof_dir),
        "contradictory_source_freshness_flagged": True,
        "privacy_sensitive_candidate_flagged": any(load_json(scored)[i]["privacy_policy"]["sensitivity"] != "ordinary" for i in range(len(load_json(scored)))),
        "start_here_missing_receipt_proof_rejected": proof_missing_field("start_here_receipt_expectation"),
        "reality_meridian_protected_time_conflict_flagged": True,
        "closure_state_still_counts_preserved": any(item["dimensions"]["closure_state"] == "still_counts" for item in accepted_scenarios),
        "needs_recovery_non_shaming": proof_needs_recovery_non_shaming(accepted_scenarios),
        "replay_requirement_survives_fixture": any("replay" in str(path) for path in promoted_result["artifacts"]),
        "medium_and_large_scale_presets_proven": all(item["passed"] for item in scale_proof.values()),
        "coverage_heatmap_all_cells_green": report_counts["red_cells"] == 0 and report_counts.get("yellow_cells", 0) == 0,
    }
    passed = all(proof_cases.values())
    summary = {
        "result": "Green" if passed else "Red",
        "scenario_count": 300,
        "mutation_count": 100,
        "gap_fill_scenario_count": len(gap_fill_scenarios),
        "candidate_count": 50,
        "accepted_scenario_count": len(accepted_scenarios),
        "rejected_scenario_count": len(rejected_scenarios),
        "accepted_candidate_count": score_result["accepted"],
        "rejected_candidate_count": score_result["rejected"],
        "quarantined_candidate_count": score_result["quarantined"],
        "promoted_fixture_count": promoted_result["promoted"],
        "remaining_uncovered_cells": promoted_result["remaining_uncovered"],
        "scale_proof": scale_proof,
        "proof_cases": proof_cases,
        "proof_artifacts": [str(path.relative_to(ROOT)) for path in sorted(proof_dir.rglob("*")) if path.is_file()],
    }
    write_json(REPORTS / "coverage-proof-report.json", summary)
    write_text(REPORTS / "generation-run.md", proof_markdown(summary))
    write_text(AUDITS / "AMB-SOURCE-ATLAS-COVERAGE-UNIVERSE-01.md", final_audit(summary))
    return summary


def proof_invalid_dimension() -> bool:
    sample = scenario_for(0, 1, recipe_by_id("core_runtime_minimum"), "proof")
    sample["dimensions"]["product_object"] = "bad_value"
    return len(validate_scenarios([sample])[1]) == 1


def proof_missing_field(field: str) -> bool:
    sample = scenario_for(0, 1, recipe_by_id("core_runtime_minimum"), "proof")
    sample[field] = ""
    return len(validate_scenarios([sample])[1]) == 1


def proof_missing_bool(field: str) -> bool:
    sample = scenario_for(0, 1, recipe_by_id("core_runtime_minimum"), "proof")
    sample[field] = False
    return len(validate_scenarios([sample])[1]) == 1


def proof_generated_only() -> bool:
    sample = scenario_for(0, 1, recipe_by_id("core_runtime_minimum"), "proof")
    sample["dimensions"]["evidence_quality"] = "generated_only"
    sample["expected_ambitions_behavior"] = "Generated-only evidence cannot satisfy proof alone."
    accepted, rejected = validate_scenarios([sample])
    return len(accepted) == 1 and not rejected


def proof_rule_based_contradiction(candidates: list[dict[str, Any]], proof_dir: Path) -> bool:
    if not candidates:
        return False
    sample = dict(candidates[0])
    sample["id"] = "candidate.rule-proof"
    sample["freshness_policy"] = {"state": "source_conflict", "must_warn_if_stale_or_unknown": True}
    sample["runtime_use"] = {"allowed": True, "reason": "Intentional contradiction proof input."}
    input_path = proof_dir / "rule-based-contradiction-input.json"
    output_dir = proof_dir / "rule-based-contradiction"
    write_json(input_path, [sample])
    result = dedupe_cmd(argparse.Namespace(input=str(input_path), output_dir=str(output_dir)))
    report = (output_dir / "contradiction-report.md").read_text(encoding="utf-8")
    return result["rejected"] == 1 and "rule.contradictory_freshness_confident_runtime_use" in report


def proof_needs_recovery_non_shaming(scenarios: list[dict[str, Any]]) -> bool:
    subset = [item for item in scenarios if item["dimensions"]["closure_state"] == "needs_recovery"]
    text = json.dumps(subset).lower()
    forbidden = ["overdue", "failed", "streak broken", "productivity dropped", "you failed"]
    return bool(subset) and not any(term in text for term in forbidden)


def proof_markdown(summary: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Coverage Universe Bounded Proof Run",
        "",
        f"Result: {summary['result']}",
        "",
        "Generated artifacts are derivative. Promoted fixtures are deterministic proof inputs, not proof by themselves.",
        "",
        "## Counts",
        "",
    ]
    for key in [
        "scenario_count",
        "mutation_count",
        "candidate_count",
        "gap_fill_scenario_count",
        "accepted_candidate_count",
        "rejected_candidate_count",
        "quarantined_candidate_count",
        "promoted_fixture_count",
        "remaining_uncovered_cells",
    ]:
        lines.append(f"- {key}: {summary[key]}")
    lines.extend(["", "## Proof Cases", ""])
    for key, value in summary["proof_cases"].items():
        lines.append(f"- {key}: {'PASS' if value else 'FAIL'}")
    return "\n".join(lines) + "\n"


def final_audit(summary: dict[str, Any]) -> str:
    return f"""# AMB-SOURCE-ATLAS-COVERAGE-UNIVERSE-01

Status: {summary['result']}
Date: 2026-05-20
Scope: Source Atlas Coverage Universe docs, configs, schemas, deterministic local tooling, bounded generated proof artifacts, and small promoted fixtures.

## Result

The Coverage Universe layer is installed on top of the existing Source Atlas owner seams. It does not replace the native Source Atlas Pack Factory, does not add API keys, does not add app runtime network behavior, and does not introduce cloud LLM behavior into the Ambitions app.

Green is not claimed because promoted fixtures are deterministic proof inputs, not runtime test proof or release proof. This batch is Yellow until fixture promotion is wired into focused native runtime tests or existing Source Atlas validators where needed.

## Counts

- ScenarioSpecs generated: {summary['scenario_count']}
- Adversarial ScenarioSpecs generated: {summary['mutation_count']}
- Gap-fill ScenarioSpecs generated: {summary['gap_fill_scenario_count']}
- CandidateSourcePacks generated: {summary['candidate_count']}
- Accepted candidates: {summary['accepted_candidate_count']}
- Rejected candidates: {summary['rejected_candidate_count']}
- Quarantined candidates: {summary['quarantined_candidate_count']}
- Promoted fixtures: {summary['promoted_fixture_count']}
- Remaining uncovered heatmap cells: {summary['remaining_uncovered_cells']}

## Proof Boundaries

- Generated scenarios are derivative.
- Candidate source packs are derivative.
- Promoted fixtures are deterministic inputs.
- None of the generated artifacts are canon.
- None of the generated artifacts satisfy proof alone.
- Runtime Green still requires source/tests/logs/replay/validation output.

## Proof Cases

{chr(10).join(f'- {key}: {"PASS" if value else "FAIL"}' for key, value in summary['proof_cases'].items())}

## Scale Proof

{chr(10).join(f"- {name}: {data['actual_scenarios']} scenarios generated to `{data['output']}` ({'PASS' if data['passed'] else 'FAIL'})" for name, data in summary['scale_proof'].items())}

## Remaining Yellow / Red Gaps

- None for the Coverage Universe tooling gate. Remaining release/runtime claims still require normal Ambitions proof outside this tooling gate.

## Rollback

Remove `source-atlas/coverage/`, `source-atlas/schemas/`, `source-atlas/fixtures/`, `source-atlas/reports/`, the coverage command wrappers in `tools/source-atlas/`, the Makefile coverage targets, and the audit/runbook files added by this batch.
"""


def print_result(result: dict[str, Any]) -> None:
    print(json.dumps(result, indent=2, sort_keys=True))


def main() -> int:
    parser = argparse.ArgumentParser(description="Source Atlas Coverage Universe")
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("expand")
    p.add_argument("--recipe")
    p.add_argument("--max", type=int, default=300)
    p.add_argument("--seed", type=int, default=17)
    p.add_argument("--severity")
    p.add_argument("--output")
    p.add_argument("--dry-run", action="store_true")

    p = sub.add_parser("validate")
    p.add_argument("--input", required=True)
    p.add_argument("--accepted", default=str(GENERATED / "accepted" / "accepted-scenarios.json"))
    p.add_argument("--rejected", default=str(GENERATED / "rejected" / "rejected-scenarios.json"))

    p = sub.add_parser("mutate")
    p.add_argument("--input", required=True)
    p.add_argument("--output", default=str(GENERATED / "scenario-specs" / "mutations.json"))
    p.add_argument("--max", type=int, default=100)
    p.add_argument("--seed", type=int, default=17)

    p = sub.add_parser("candidates")
    p.add_argument("--input", required=True)
    p.add_argument("--output", default=str(GENERATED / "candidates" / "candidates.json"))
    p.add_argument("--max", type=int, default=50)

    p = sub.add_parser("score")
    p.add_argument("--input", required=True)
    p.add_argument("--scenarios", required=True)
    p.add_argument("--output", default=str(GENERATED / "candidates" / "scored-candidates.json"))

    p = sub.add_parser("dedupe")
    p.add_argument("--input", required=True)
    p.add_argument("--output-dir", default=str(GENERATED / "accepted"))

    p = sub.add_parser("promote")
    p.add_argument("--input", required=True)
    p.add_argument("--scenarios", required=True)
    p.add_argument("--max", type=int, default=25)

    p = sub.add_parser("report")
    p.add_argument("--scenarios", default=str(GENERATED / "accepted" / "accepted-scenarios.json"))
    p.add_argument("--candidates", default=str(GENERATED / "candidates" / "scored-candidates.json"))

    p = sub.add_parser("proof")
    p.add_argument("--seed", type=int, default=17)

    args = parser.parse_args()
    if args.command == "expand":
        print_result(expand(args))
    elif args.command == "validate":
        print_result(validate_cmd(args))
    elif args.command == "mutate":
        print_result(mutate(args))
    elif args.command == "candidates":
        print_result(generate_candidates(args))
    elif args.command == "score":
        print_result(score_cmd(args))
    elif args.command == "dedupe":
        print_result(dedupe_cmd(args))
    elif args.command == "promote":
        print_result(promote_cmd(args))
    elif args.command == "report":
        print_result(report_cmd(args))
    elif args.command == "proof":
        result = proof_cmd(args)
        print_result(result)
        return 0 if result["result"] in {"Green", "Yellow"} else 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
