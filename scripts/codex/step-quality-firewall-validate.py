#!/usr/bin/env python3
"""Validate the PLOS M09 Step Quality Firewall contract and fixtures."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
CONTRACT_PATH = ROOT / "artifacts/personal-life-os/step-quality/STEP_QUALITY_FIREWALL_CONTRACT.json"
FIXTURES_PATH = ROOT / "artifacts/personal-life-os/step-quality/STEP_QUALITY_FIREWALL_FIXTURES.json"


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def get_nested(value: dict[str, Any], path: str) -> Any:
    current: Any = value
    for part in path.split("."):
        if not isinstance(current, dict) or part not in current:
            return None
        current = current[part]
    return current


def is_present(value: Any) -> bool:
    if value is None:
        return False
    if isinstance(value, str):
        return bool(value.strip())
    return True


def normalize_text(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip().lower())


def contains_blocked_phrase(step_text: str, phrases: list[str]) -> bool:
    normalized = normalize_text(step_text)
    for phrase in phrases:
        phrase_pattern = r"\b" + re.escape(normalize_text(phrase)) + r"\b"
        if re.search(phrase_pattern, normalized):
            return True
    return False


def validate_contract_shape(contract: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    for model_name in ("StepQualityInput", "StepQualityVerdict"):
        model = contract.get("models", {}).get(model_name)
        if not isinstance(model, dict):
            errors.append(f"missing model {model_name}")
            continue
        required = model.get("requiredFields")
        if not isinstance(required, list) or not required:
            errors.append(f"model {model_name} has no requiredFields")

    for key in ("blockedGenericPhrases", "blockedSourceStates", "allowedSourceStatesForAcceptance", "blockingCodes"):
        if not contract.get(key):
            errors.append(f"contract missing {key}")

    if not Path(FIXTURES_PATH).exists():
        errors.append("fixture matrix is missing")

    return errors


def evaluate_input(contract: dict[str, Any], step_input: dict[str, Any]) -> list[str]:
    codes: list[str] = []
    input_model = contract["models"]["StepQualityInput"]

    for field in input_model["requiredFields"]:
        if not is_present(step_input.get(field)):
            codes.append(f"missing_required_field:{field}")

    for group, fields in input_model.get("fieldRequirements", {}).items():
        group_value = step_input.get(group)
        if not isinstance(group_value, dict):
            codes.append(f"missing_required_field:{group}")
            continue
        for field in fields:
            if not is_present(group_value.get(field)):
                if group == "proofExpectation":
                    codes.append("missing_proof_expectation")
                elif group == "accessibility":
                    codes.append("missing_accessibility_semantics")
                elif group == "repairPath":
                    codes.append("missing_repair_path")
                else:
                    codes.append(f"missing_required_field:{group}.{field}")

    if contains_blocked_phrase(str(step_input.get("stepText", "")), contract["blockedGenericPhrases"]):
        codes.append("generic_step")

    if not is_present(step_input.get("actionVerb")):
        codes.append("missing_specific_action")
    if not is_present(step_input.get("object")):
        codes.append("missing_clear_object")

    duration = step_input.get("durationMinutes")
    limits = contract["acceptanceRules"]["durationMinutes"]
    if not isinstance(duration, int) or duration < limits["min"] or duration > limits["max"]:
        codes.append("invalid_duration")

    capability = step_input.get("capabilityTarget", {})
    if isinstance(capability, dict):
        user_level = capability.get("userSkillLevel")
        candidate_level = capability.get("candidateSkillLevel")
        proof_state = capability.get("proofState")
        if user_level == "beginner" and candidate_level in contract["acceptanceRules"]["capabilityFit"]["beginnerCannotReceive"]:
            codes.append("beginner_expert_mismatch")
        if (
            user_level == "expert"
            and proof_state == "proof-established"
            and candidate_level in contract["acceptanceRules"]["capabilityFit"]["expertWithProofCannotReceive"]
        ):
            codes.append("expert_after_proof_mismatch")

    context = step_input.get("contextFit", {})
    allowed_context_values = set(contract["acceptanceRules"]["requiredContextFitValues"])
    if isinstance(context, dict):
        for field in contract["models"]["StepQualityInput"]["fieldRequirements"]["contextFit"]:
            if context.get(field) not in allowed_context_values:
                codes.append("context_mismatch")
                break

    source = step_input.get("sourceAuthority", {})
    if isinstance(source, dict):
        state = source.get("state")
        freshness = source.get("freshnessState")
        review = source.get("reviewState")
        runtime_eligible = source.get("runtimeEligible")
        if (
            state in contract["blockedSourceStates"]
            or state not in contract["allowedSourceStatesForAcceptance"]
            or freshness in ("expired", "revoked", "unknown")
            or review in ("blocked", "review-required")
            or runtime_eligible is not True
        ):
            codes.append("source_not_eligible")

    proof = step_input.get("proofExpectation", {})
    if not isinstance(proof, dict) or not proof.get("primitive") or proof.get("receiptRequired") is not True or not proof.get("proofTraceId"):
        codes.append("missing_proof_expectation")

    unsafe_terms = ("overdue", "failed", "streak broken", "productivity dropped", "ai recommends")
    if any(term in normalize_text(str(step_input.get("stepText", ""))) for term in unsafe_terms):
        codes.append("unsafe_or_shaming_tone")

    accessibility = step_input.get("accessibility", {})
    if not isinstance(accessibility, dict) or any(
        not accessibility.get(field)
        for field in contract["models"]["StepQualityInput"]["fieldRequirements"]["accessibility"]
    ):
        codes.append("missing_accessibility_semantics")

    elasticity = step_input.get("elasticityCoverage", {})
    required_elasticity = contract["acceptanceRules"]["requiredElasticityForAcceptance"]
    if not isinstance(elasticity, dict) or any(elasticity.get(field) is not True for field in required_elasticity):
        codes.append("missing_elasticity_coverage")

    repair = step_input.get("repairPath", {})
    if not isinstance(repair, dict) or not repair.get("owner") or not repair.get("fallback") or not repair.get("annotationCode"):
        codes.append("missing_repair_path")

    return sorted(set(codes))


def expected_decision(codes: list[str]) -> str:
    return "accept" if not codes else "reject"


def validate_fixtures(contract: dict[str, Any], fixtures_packet: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    fixtures = fixtures_packet.get("fixtures")
    if not isinstance(fixtures, list) or not fixtures:
        return ["fixture matrix has no fixtures"]

    accepted_seen = False
    rejected_codes_seen: set[str] = set()

    for fixture in fixtures:
        fixture_id = fixture.get("id", "<missing-id>")
        step_input = fixture.get("input", {})
        codes = evaluate_input(contract, step_input)
        actual_decision = expected_decision(codes)
        expected = fixture.get("expectedDecision")

        if expected == "accept":
            accepted_seen = True
            if actual_decision != "accept":
                errors.append(f"{fixture_id}: expected accept but got reject codes={codes}")
        elif expected == "reject":
            if actual_decision != "reject":
                errors.append(f"{fixture_id}: expected reject but got accept")
            expected_codes = set(fixture.get("expectedBlockingCodes", []))
            missing_codes = sorted(expected_codes.difference(codes))
            if missing_codes:
                errors.append(f"{fixture_id}: missing expected blocking codes {missing_codes}; actual={codes}")
            rejected_codes_seen.update(expected_codes)
        else:
            errors.append(f"{fixture_id}: expectedDecision must be accept or reject")

        if fixture_id != step_input.get("id"):
            errors.append(f"{fixture_id}: fixture id does not match StepQualityInput.id")

    required_red_paths = {
        "generic_step",
        "beginner_expert_mismatch",
        "expert_after_proof_mismatch",
        "source_not_eligible",
        "missing_proof_expectation",
        "missing_accessibility_semantics",
        "missing_elasticity_coverage"
    }
    missing_red_paths = sorted(required_red_paths.difference(rejected_codes_seen))
    if missing_red_paths:
        errors.append(f"fixture matrix missing required rejected paths: {missing_red_paths}")

    if not accepted_seen:
        errors.append("fixture matrix has no accepted fixture")

    return errors


def main() -> int:
    contract = load_json(CONTRACT_PATH)
    fixtures = load_json(FIXTURES_PATH)

    errors = []
    errors.extend(validate_contract_shape(contract))
    errors.extend(validate_fixtures(contract, fixtures))

    if errors:
        print("FAIL Step Quality Firewall validator")
        for error in errors:
            print(f"- {error}")
        return 1

    print("PASS Step Quality Firewall validator")
    print(f"contract={CONTRACT_PATH.relative_to(ROOT)}")
    print(f"fixtures={FIXTURES_PATH.relative_to(ROOT)}")
    print("models=StepQualityInput, StepQualityVerdict")
    print("m10_dependency=runnable")
    return 0


if __name__ == "__main__":
    sys.exit(main())
