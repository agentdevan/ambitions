#!/usr/bin/env python3
"""Validate the PLOS M09 Step Quality Firewall contract and fixtures."""

from __future__ import annotations

import json
import re
import sys
from copy import deepcopy
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
CONTRACT_PATH = ROOT / "artifacts/personal-life-os/step-quality/STEP_QUALITY_FIREWALL_CONTRACT.json"
FIXTURES_PATH = ROOT / "artifacts/personal-life-os/step-quality/STEP_QUALITY_FIREWALL_FIXTURES.json"
SCANNER_PATH = ROOT / "artifacts/personal-life-os/step-quality/STEP_GENERIC_BLOCKED_LIST_SCANNER.json"
SCANNER_FIXTURES_PATH = ROOT / "artifacts/personal-life-os/step-quality/STEP_GENERIC_BLOCKED_LIST_SCANNER_FIXTURES.json"
CONTEXT_VALIDATOR_PATH = ROOT / "artifacts/personal-life-os/step-quality/STEP_CONTEXT_FIT_VALIDATOR.json"
CONTEXT_FIXTURES_PATH = ROOT / "artifacts/personal-life-os/step-quality/STEP_CONTEXT_FIT_VALIDATOR_FIXTURES.json"
SOURCE_PROOF_VALIDATOR_PATH = ROOT / "artifacts/personal-life-os/step-quality/STEP_SOURCE_PROOF_VALIDATOR.json"
SOURCE_PROOF_FIXTURES_PATH = ROOT / "artifacts/personal-life-os/step-quality/STEP_SOURCE_PROOF_VALIDATOR_FIXTURES.json"
ACCESSIBILITY_VALIDATOR_PATH = ROOT / "artifacts/personal-life-os/step-quality/STEP_ACCESSIBILITY_VALIDATOR.json"
ACCESSIBILITY_FIXTURES_PATH = ROOT / "artifacts/personal-life-os/step-quality/STEP_ACCESSIBILITY_VALIDATOR_FIXTURES.json"


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


def merge_nested(base: dict[str, Any], patch: dict[str, Any]) -> dict[str, Any]:
    merged = deepcopy(base)
    for key, value in patch.items():
        if isinstance(value, dict) and isinstance(merged.get(key), dict):
            merged[key] = merge_nested(merged[key], value)
        else:
            merged[key] = value
    return merged


def is_present(value: Any) -> bool:
    if value is None:
        return False
    if isinstance(value, str):
        return bool(value.strip())
    return True


def normalize_text(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip().lower())


def normalize_for_scan(value: str) -> str:
    lowered = value.strip().lower()
    without_punctuation = re.sub(r"[^a-z0-9\s]", " ", lowered)
    return re.sub(r"\s+", " ", without_punctuation).strip()


def contains_blocked_phrase(step_text: str, phrases: list[str]) -> bool:
    normalized = normalize_text(step_text)
    for phrase in phrases:
        phrase_pattern = r"\b" + re.escape(normalize_text(phrase)) + r"\b"
        if re.search(phrase_pattern, normalized):
            return True
    return False


def scanner_exact_phrase(step_text: str, phrases: list[str]) -> str | None:
    normalized = normalize_for_scan(step_text)
    for phrase in phrases:
        normalized_phrase = normalize_for_scan(phrase)
        pattern = r"\b" + re.escape(normalized_phrase) + r"\b"
        if re.search(pattern, normalized):
            return phrase
    return None


def has_generic_verb_object(step_text: str, scanner: dict[str, Any]) -> bool:
    normalized = normalize_for_scan(step_text)
    rules = scanner.get("genericVerbObjectRules", {})
    verbs = [normalize_for_scan(value) for value in rules.get("verbs", [])]
    objects = [normalize_for_scan(value) for value in rules.get("genericObjects", [])]
    for verb in verbs:
        for generic_object in objects:
            if re.search(r"\b" + re.escape(f"{verb} {generic_object}") + r"\b", normalized):
                return True
        if normalized == verb and verb == "continue":
            return True
    return False


def has_generic_progress_language(step_text: str, scanner: dict[str, Any]) -> bool:
    normalized = normalize_for_scan(step_text)
    concrete_signals = scanner.get("concreteObjectSignals", [])
    if any(re.search(r"\b" + re.escape(normalize_for_scan(signal)) + r"\b", normalized) for signal in concrete_signals):
        return False
    for term in scanner.get("genericProgressTerms", []):
        if re.search(r"\b" + re.escape(normalize_for_scan(term)) + r"\b", normalized):
            return True
    return False


def evaluate_generic_scanner(scanner: dict[str, Any], step_text: str) -> tuple[list[str], str | None]:
    codes: list[str] = []
    matched_phrase = scanner_exact_phrase(step_text, scanner.get("exactBlockedPhrases", []))
    if matched_phrase:
        codes.append("generic_step")
    if has_generic_verb_object(step_text, scanner):
        codes.append("generic_pattern")
    if has_generic_progress_language(step_text, scanner):
        codes.append("generic_progress_language")
    if codes:
        codes.append("generic_repair_required")
    return sorted(set(codes)), matched_phrase


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

    scanner = contract.get("genericScanner")
    if not isinstance(scanner, dict):
        errors.append("contract missing genericScanner linkage")
    else:
        for key in ("linearIssue", "schema", "fixtures", "requiredOutputs"):
            if not scanner.get(key):
                errors.append(f"contract genericScanner missing {key}")

    context_validator = contract.get("contextFitValidator")
    if not isinstance(context_validator, dict):
        errors.append("contract missing contextFitValidator linkage")
    else:
        for key in ("linearIssue", "schema", "fixtures", "requiredOutputs"):
            if not context_validator.get(key):
                errors.append(f"contract contextFitValidator missing {key}")

    source_proof_validator = contract.get("sourceProofValidator")
    if not isinstance(source_proof_validator, dict):
        errors.append("contract missing sourceProofValidator linkage")
    else:
        for key in ("linearIssue", "schema", "fixtures", "requiredOutputs"):
            if not source_proof_validator.get(key):
                errors.append(f"contract sourceProofValidator missing {key}")

    accessibility_validator = contract.get("accessibilityValidator")
    if not isinstance(accessibility_validator, dict):
        errors.append("contract missing accessibilityValidator linkage")
    else:
        for key in ("linearIssue", "schema", "fixtures", "requiredOutputs"):
            if not accessibility_validator.get(key):
                errors.append(f"contract accessibilityValidator missing {key}")

    return errors


def validate_scanner_shape(scanner: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    required_keys = (
        "inputModel",
        "verdictModel",
        "scannerOutputs",
        "exactBlockedPhrases",
        "genericVerbObjectRules",
        "genericProgressTerms",
        "repairLinkage",
    )
    for key in required_keys:
        if not scanner.get(key):
            errors.append(f"scanner missing {key}")
    if scanner.get("inputModel") != "StepQualityInput":
        errors.append("scanner inputModel must be StepQualityInput")
    if scanner.get("verdictModel") != "StepQualityVerdict":
        errors.append("scanner verdictModel must be StepQualityVerdict")
    required_outputs = {"generic_step", "generic_pattern", "generic_progress_language", "generic_repair_required"}
    missing_outputs = sorted(required_outputs.difference(scanner.get("scannerOutputs", [])))
    if missing_outputs:
        errors.append(f"scanner missing outputs {missing_outputs}")
    repair = scanner.get("repairLinkage", {})
    if not isinstance(repair, dict) or repair.get("requiredOwner") != "step-graph-compiler" or not repair.get("fallbacks"):
        errors.append("scanner repairLinkage must name Step Graph Compiler and safe fallbacks")
    return errors


def validate_context_validator_shape(context_validator: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    required_keys = ("inputModel", "verdictModel", "contextFields", "validatorOutputs", "repairLinkage")
    for key in required_keys:
        if not context_validator.get(key):
            errors.append(f"context validator missing {key}")
    if context_validator.get("inputModel") != "StepQualityInput":
        errors.append("context validator inputModel must be StepQualityInput")
    if context_validator.get("verdictModel") != "StepQualityVerdict":
        errors.append("context validator verdictModel must be StepQualityVerdict")
    required_outputs = {
        "context_mismatch",
        "context_time_mismatch",
        "context_energy_mismatch",
        "context_resource_mismatch",
        "context_location_mismatch",
        "context_deadline_mismatch",
        "context_dependency_mismatch",
        "context_repair_required",
    }
    missing_outputs = sorted(required_outputs.difference(context_validator.get("validatorOutputs", [])))
    if missing_outputs:
        errors.append(f"context validator missing outputs {missing_outputs}")
    context_fields = context_validator.get("contextFields", {})
    for field, expected_code in {
        "timeFit": "context_time_mismatch",
        "energyFit": "context_energy_mismatch",
        "resourceFit": "context_resource_mismatch",
        "locationFit": "context_location_mismatch",
        "deadlineFit": "context_deadline_mismatch",
        "dependencyFit": "context_dependency_mismatch",
    }.items():
        field_rule = context_fields.get(field)
        if not isinstance(field_rule, dict):
            errors.append(f"context validator missing field rule {field}")
        elif field_rule.get("blockingCode") != expected_code or not field_rule.get("accepted"):
            errors.append(f"context validator field rule {field} is incomplete")
    repair = context_validator.get("repairLinkage", {})
    if not isinstance(repair, dict) or repair.get("requiredOwner") != "step-graph-compiler" or not repair.get("fallbacks"):
        errors.append("context validator repairLinkage must name Step Graph Compiler and safe fallbacks")
    return errors


def validate_source_proof_validator_shape(source_proof_validator: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    required_keys = ("inputModel", "verdictModel", "sourceAuthorityRules", "proofExpectationRules", "validatorOutputs", "repairLinkage")
    for key in required_keys:
        if not source_proof_validator.get(key):
            errors.append(f"source/proof validator missing {key}")
    if source_proof_validator.get("inputModel") != "StepQualityInput":
        errors.append("source/proof validator inputModel must be StepQualityInput")
    if source_proof_validator.get("verdictModel") != "StepQualityVerdict":
        errors.append("source/proof validator verdictModel must be StepQualityVerdict")
    required_outputs = {
        "source_not_eligible",
        "source_state_blocked",
        "source_trace_missing",
        "source_freshness_invalid",
        "source_review_invalid",
        "source_risk_blocked",
        "source_runtime_ineligible",
        "hardcoded_step_output",
        "missing_proof_expectation",
        "proof_missing",
        "proof_receipt_missing",
        "proof_trace_missing",
        "source_proof_repair_required",
    }
    missing_outputs = sorted(required_outputs.difference(source_proof_validator.get("validatorOutputs", [])))
    if missing_outputs:
        errors.append(f"source/proof validator missing outputs {missing_outputs}")
    source_rules = source_proof_validator.get("sourceAuthorityRules", {})
    if not isinstance(source_rules, dict):
        errors.append("source/proof validator sourceAuthorityRules must be an object")
    else:
        for key in (
            "allowedStates",
            "blockedStates",
            "requiredTraceFields",
            "acceptedFreshnessStates",
            "acceptedReviewStates",
            "acceptedRiskClasses",
        ):
            if not source_rules.get(key):
                errors.append(f"source/proof validator sourceAuthorityRules missing {key}")
        if source_rules.get("runtimeEligibleMustBeTrue") is not True:
            errors.append("source/proof validator must require runtimeEligible true")
        if source_rules.get("hardcodedStepOutputMustBeFalse") is not True:
            errors.append("source/proof validator must block hardcoded Step outputs")
    proof_rules = source_proof_validator.get("proofExpectationRules", {})
    if not isinstance(proof_rules, dict) or not proof_rules.get("requiredFields"):
        errors.append("source/proof validator proofExpectationRules missing requiredFields")
    elif proof_rules.get("receiptRequiredMustBeTrue") is not True:
        errors.append("source/proof validator must require proof receipt")
    repair = source_proof_validator.get("repairLinkage", {})
    if not isinstance(repair, dict) or repair.get("requiredOwner") != "step-graph-compiler" or not repair.get("fallbacks"):
        errors.append("source/proof validator repairLinkage must name Step Graph Compiler and safe fallbacks")
    return errors


def validate_accessibility_validator_shape(accessibility_validator: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    required_keys = ("inputModel", "verdictModel", "accessibilityRules", "validatorOutputs", "repairLinkage")
    for key in required_keys:
        if not accessibility_validator.get(key):
            errors.append(f"accessibility validator missing {key}")
    if accessibility_validator.get("inputModel") != "StepQualityInput":
        errors.append("accessibility validator inputModel must be StepQualityInput")
    if accessibility_validator.get("verdictModel") != "StepQualityVerdict":
        errors.append("accessibility validator verdictModel must be StepQualityVerdict")
    required_outputs = {
        "missing_accessibility_semantics",
        "accessibility_label_missing",
        "accessibility_value_missing",
        "accessibility_hint_missing",
        "accessibility_summary_missing",
        "accessibility_visual_only",
        "accessibility_generic_label",
        "dynamic_type_unsafe",
        "reduce_motion_unsafe",
        "accessibility_repair_required",
    }
    missing_outputs = sorted(required_outputs.difference(accessibility_validator.get("validatorOutputs", [])))
    if missing_outputs:
        errors.append(f"accessibility validator missing outputs {missing_outputs}")
    rules = accessibility_validator.get("accessibilityRules", {})
    if not isinstance(rules, dict):
        errors.append("accessibility validator accessibilityRules must be an object")
    else:
        for key in ("requiredFields", "genericLabels", "acceptedDynamicTypeBehavior", "acceptedReduceMotionBehavior"):
            if not rules.get(key):
                errors.append(f"accessibility validator accessibilityRules missing {key}")
        if rules.get("visualOnlyMeaningMustBeFalse") is not True:
            errors.append("accessibility validator must block visual-only meaning")
    repair = accessibility_validator.get("repairLinkage", {})
    if not isinstance(repair, dict) or repair.get("requiredOwner") != "step-graph-compiler" or not repair.get("fallbacks"):
        errors.append("accessibility validator repairLinkage must name Step Graph Compiler and safe fallbacks")
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


def validate_scanner_fixtures(scanner: dict[str, Any], fixtures_packet: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    fixtures = fixtures_packet.get("fixtures")
    if not isinstance(fixtures, list) or not fixtures:
        return ["scanner fixture matrix has no fixtures"]

    accepted_seen = False
    rejected_codes_seen: set[str] = set()

    for fixture in fixtures:
        fixture_id = fixture.get("id", "<missing-id>")
        step_text = str(fixture.get("stepText", ""))
        codes, matched_phrase = evaluate_generic_scanner(scanner, step_text)
        actual_decision = "accept" if not codes else "reject"
        expected = fixture.get("expectedDecision")

        if expected == "accept":
            accepted_seen = True
            if actual_decision != "accept":
                errors.append(f"{fixture_id}: expected scanner accept but got reject codes={codes}")
        elif expected == "reject":
            if actual_decision != "reject":
                errors.append(f"{fixture_id}: expected scanner reject but got accept")
            expected_codes = set(fixture.get("expectedScannerCodes", []))
            missing_codes = sorted(expected_codes.difference(codes))
            if missing_codes:
                errors.append(f"{fixture_id}: missing expected scanner codes {missing_codes}; actual={codes}")
            expected_phrase = fixture.get("expectedPhrase")
            if expected_phrase and normalize_for_scan(expected_phrase) != normalize_for_scan(matched_phrase or ""):
                errors.append(f"{fixture_id}: expected matched phrase {expected_phrase!r} but got {matched_phrase!r}")
            rejected_codes_seen.update(expected_codes)
        else:
            errors.append(f"{fixture_id}: expectedDecision must be accept or reject")

    required_red_paths = {"generic_step", "generic_pattern", "generic_progress_language", "generic_repair_required"}
    missing_red_paths = sorted(required_red_paths.difference(rejected_codes_seen))
    if missing_red_paths:
        errors.append(f"scanner fixture matrix missing required rejected paths: {missing_red_paths}")

    if not accepted_seen:
        errors.append("scanner fixture matrix has no accepted fixture")

    return errors


def evaluate_context_validator(context_validator: dict[str, Any], step_input: dict[str, Any]) -> list[str]:
    codes: list[str] = []
    context = step_input.get("contextFit", {})
    if not isinstance(context, dict):
        return ["context_mismatch", "context_repair_required"]

    for field, rule in context_validator.get("contextFields", {}).items():
        accepted_values = set(rule.get("accepted", []))
        if context.get(field) not in accepted_values:
            codes.append(rule.get("blockingCode", "context_mismatch"))

    if codes:
        codes.append("context_mismatch")
        codes.append("context_repair_required")
    return sorted(set(codes))


def validate_context_fixtures(context_validator: dict[str, Any], fixtures_packet: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    fixtures = fixtures_packet.get("fixtures")
    if not isinstance(fixtures, list) or not fixtures:
        return ["context fixture matrix has no fixtures"]

    base_input: dict[str, Any] | None = None
    accepted_seen = False
    rejected_codes_seen: set[str] = set()

    for fixture in fixtures:
        if fixture.get("expectedDecision") == "accept" and isinstance(fixture.get("input"), dict):
            base_input = fixture["input"]
            break

    if base_input is None:
        return ["context fixture matrix has no accepted base input"]

    for fixture in fixtures:
        fixture_id = fixture.get("id", "<missing-id>")
        if isinstance(fixture.get("input"), dict):
            step_input = fixture["input"]
        else:
            step_input = merge_nested(base_input, fixture.get("inputPatch", {}))
        step_input["id"] = fixture_id

        context_codes = evaluate_context_validator(context_validator, step_input)
        actual_decision = "accept" if not context_codes else "reject"
        expected = fixture.get("expectedDecision")

        if expected == "accept":
            accepted_seen = True
            if actual_decision != "accept":
                errors.append(f"{fixture_id}: expected context accept but got reject codes={context_codes}")
            full_codes = evaluate_input(load_json(CONTRACT_PATH), step_input)
            if full_codes:
                errors.append(f"{fixture_id}: accepted context fixture fails base firewall codes={full_codes}")
        elif expected == "reject":
            if actual_decision != "reject":
                errors.append(f"{fixture_id}: expected context reject but got accept")
            expected_codes = set(fixture.get("expectedContextCodes", []))
            missing_codes = sorted(expected_codes.difference(context_codes))
            if missing_codes:
                errors.append(f"{fixture_id}: missing expected context codes {missing_codes}; actual={context_codes}")
            rejected_codes_seen.update(expected_codes)
        else:
            errors.append(f"{fixture_id}: expectedDecision must be accept or reject")

    required_red_paths = {
        "context_mismatch",
        "context_time_mismatch",
        "context_energy_mismatch",
        "context_resource_mismatch",
        "context_location_mismatch",
        "context_deadline_mismatch",
        "context_dependency_mismatch",
        "context_repair_required",
    }
    missing_red_paths = sorted(required_red_paths.difference(rejected_codes_seen))
    if missing_red_paths:
        errors.append(f"context fixture matrix missing required rejected paths: {missing_red_paths}")
    if not accepted_seen:
        errors.append("context fixture matrix has no accepted fixture")
    return errors


def evaluate_source_proof_validator(source_proof_validator: dict[str, Any], step_input: dict[str, Any]) -> list[str]:
    codes: list[str] = []
    source_rules = source_proof_validator.get("sourceAuthorityRules", {})
    proof_rules = source_proof_validator.get("proofExpectationRules", {})

    source = step_input.get("sourceAuthority", {})
    if not isinstance(source, dict):
        return ["source_not_eligible", "source_trace_missing", "source_proof_repair_required"]

    allowed_states = set(source_rules.get("allowedStates", []))
    blocked_states = set(source_rules.get("blockedStates", []))
    state = source.get("state")
    if state in blocked_states or state not in allowed_states:
        codes.append("source_not_eligible")
        codes.append("source_state_blocked")

    for field in source_rules.get("requiredTraceFields", []):
        if not is_present(source.get(field)):
            codes.append("source_trace_missing")

    if source.get("freshnessState") not in set(source_rules.get("acceptedFreshnessStates", [])):
        codes.append("source_not_eligible")
        codes.append("source_freshness_invalid")

    if source.get("reviewState") not in set(source_rules.get("acceptedReviewStates", [])):
        codes.append("source_not_eligible")
        codes.append("source_review_invalid")

    if source.get("riskClass") not in set(source_rules.get("acceptedRiskClasses", [])):
        codes.append("source_not_eligible")
        codes.append("source_risk_blocked")

    if source_rules.get("runtimeEligibleMustBeTrue") is True and source.get("runtimeEligible") is not True:
        codes.append("source_not_eligible")
        codes.append("source_runtime_ineligible")

    if source_rules.get("hardcodedStepOutputMustBeFalse") is True and source.get("hardcodedStepOutput") is True:
        codes.append("source_not_eligible")
        codes.append("hardcoded_step_output")

    proof = step_input.get("proofExpectation", {})
    if not isinstance(proof, dict):
        codes.extend(["missing_proof_expectation", "proof_missing", "proof_receipt_missing", "proof_trace_missing"])
    else:
        primitive = proof.get("primitive")
        if not is_present(primitive) or str(primitive).strip().lower() == "none":
            codes.append("missing_proof_expectation")
            codes.append("proof_missing")
        if proof_rules.get("receiptRequiredMustBeTrue") is True and proof.get("receiptRequired") is not True:
            codes.append("missing_proof_expectation")
            codes.append("proof_receipt_missing")
        if not is_present(proof.get("proofTraceId")):
            codes.append("missing_proof_expectation")
            codes.append("proof_trace_missing")
        receipt_kind = proof.get("receiptKind")
        accepted_receipt_kinds = set(proof_rules.get("acceptedReceiptKinds", []))
        if accepted_receipt_kinds and not is_present(receipt_kind):
            codes.append("missing_proof_expectation")
            codes.append("proof_receipt_missing")
        elif accepted_receipt_kinds and receipt_kind not in accepted_receipt_kinds:
            codes.append("missing_proof_expectation")
            codes.append("proof_receipt_missing")

    if codes:
        codes.append("source_proof_repair_required")
    return sorted(set(codes))


def validate_source_proof_fixtures(source_proof_validator: dict[str, Any], fixtures_packet: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    fixtures = fixtures_packet.get("fixtures")
    if not isinstance(fixtures, list) or not fixtures:
        return ["source/proof fixture matrix has no fixtures"]

    base_input: dict[str, Any] | None = None
    accepted_seen = False
    rejected_codes_seen: set[str] = set()

    for fixture in fixtures:
        if fixture.get("expectedDecision") == "accept" and isinstance(fixture.get("input"), dict):
            base_input = fixture["input"]
            break

    if base_input is None:
        return ["source/proof fixture matrix has no accepted base input"]

    for fixture in fixtures:
        fixture_id = fixture.get("id", "<missing-id>")
        if isinstance(fixture.get("input"), dict):
            step_input = fixture["input"]
        else:
            step_input = merge_nested(base_input, fixture.get("inputPatch", {}))
        step_input["id"] = fixture_id

        source_proof_codes = evaluate_source_proof_validator(source_proof_validator, step_input)
        actual_decision = "accept" if not source_proof_codes else "reject"
        expected = fixture.get("expectedDecision")

        if expected == "accept":
            accepted_seen = True
            if actual_decision != "accept":
                errors.append(f"{fixture_id}: expected source/proof accept but got reject codes={source_proof_codes}")
            full_codes = evaluate_input(load_json(CONTRACT_PATH), step_input)
            if full_codes:
                errors.append(f"{fixture_id}: accepted source/proof fixture fails base firewall codes={full_codes}")
        elif expected == "reject":
            if actual_decision != "reject":
                errors.append(f"{fixture_id}: expected source/proof reject but got accept")
            expected_codes = set(fixture.get("expectedSourceProofCodes", []))
            missing_codes = sorted(expected_codes.difference(source_proof_codes))
            if missing_codes:
                errors.append(f"{fixture_id}: missing expected source/proof codes {missing_codes}; actual={source_proof_codes}")
            rejected_codes_seen.update(expected_codes)
        else:
            errors.append(f"{fixture_id}: expectedDecision must be accept or reject")

    required_red_paths = {
        "source_not_eligible",
        "source_state_blocked",
        "source_trace_missing",
        "source_freshness_invalid",
        "source_review_invalid",
        "source_risk_blocked",
        "source_runtime_ineligible",
        "hardcoded_step_output",
        "missing_proof_expectation",
        "proof_missing",
        "proof_receipt_missing",
        "proof_trace_missing",
        "source_proof_repair_required",
    }
    missing_red_paths = sorted(required_red_paths.difference(rejected_codes_seen))
    if missing_red_paths:
        errors.append(f"source/proof fixture matrix missing required rejected paths: {missing_red_paths}")
    if not accepted_seen:
        errors.append("source/proof fixture matrix has no accepted fixture")
    return errors


def evaluate_accessibility_validator(accessibility_validator: dict[str, Any], step_input: dict[str, Any]) -> list[str]:
    codes: list[str] = []
    rules = accessibility_validator.get("accessibilityRules", {})
    accessibility = step_input.get("accessibility", {})
    if not isinstance(accessibility, dict):
        return ["missing_accessibility_semantics", "accessibility_repair_required"]

    field_codes = {
        "voiceOverLabel": "accessibility_label_missing",
        "voiceOverValue": "accessibility_value_missing",
        "voiceOverHint": "accessibility_hint_missing",
        "nonVisualSummary": "accessibility_summary_missing",
    }
    for field in rules.get("requiredFields", []):
        if not is_present(accessibility.get(field)):
            codes.append(field_codes.get(field, "missing_accessibility_semantics"))

    label = normalize_text(str(accessibility.get("voiceOverLabel", "")))
    generic_labels = {normalize_text(value) for value in rules.get("genericLabels", [])}
    if label in generic_labels:
        codes.append("accessibility_generic_label")

    if rules.get("visualOnlyMeaningMustBeFalse") is True and accessibility.get("visualOnlyMeaning") is not False:
        codes.append("accessibility_visual_only")

    dynamic_type = accessibility.get("dynamicTypeBehavior")
    if dynamic_type not in set(rules.get("acceptedDynamicTypeBehavior", [])):
        codes.append("dynamic_type_unsafe")

    reduce_motion = accessibility.get("reduceMotionBehavior")
    if reduce_motion not in set(rules.get("acceptedReduceMotionBehavior", [])):
        codes.append("reduce_motion_unsafe")

    if codes:
        codes.append("missing_accessibility_semantics")
        codes.append("accessibility_repair_required")
    return sorted(set(codes))


def validate_accessibility_fixtures(accessibility_validator: dict[str, Any], fixtures_packet: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    fixtures = fixtures_packet.get("fixtures")
    if not isinstance(fixtures, list) or not fixtures:
        return ["accessibility fixture matrix has no fixtures"]

    base_input: dict[str, Any] | None = None
    accepted_seen = False
    rejected_codes_seen: set[str] = set()

    for fixture in fixtures:
        if fixture.get("expectedDecision") == "accept" and isinstance(fixture.get("input"), dict):
            base_input = fixture["input"]
            break

    if base_input is None:
        return ["accessibility fixture matrix has no accepted base input"]

    for fixture in fixtures:
        fixture_id = fixture.get("id", "<missing-id>")
        if isinstance(fixture.get("input"), dict):
            step_input = fixture["input"]
        else:
            step_input = merge_nested(base_input, fixture.get("inputPatch", {}))
        step_input["id"] = fixture_id

        accessibility_codes = evaluate_accessibility_validator(accessibility_validator, step_input)
        actual_decision = "accept" if not accessibility_codes else "reject"
        expected = fixture.get("expectedDecision")

        if expected == "accept":
            accepted_seen = True
            if actual_decision != "accept":
                errors.append(f"{fixture_id}: expected accessibility accept but got reject codes={accessibility_codes}")
            full_codes = evaluate_input(load_json(CONTRACT_PATH), step_input)
            if full_codes:
                errors.append(f"{fixture_id}: accepted accessibility fixture fails base firewall codes={full_codes}")
        elif expected == "reject":
            if actual_decision != "reject":
                errors.append(f"{fixture_id}: expected accessibility reject but got accept")
            expected_codes = set(fixture.get("expectedAccessibilityCodes", []))
            missing_codes = sorted(expected_codes.difference(accessibility_codes))
            if missing_codes:
                errors.append(f"{fixture_id}: missing expected accessibility codes {missing_codes}; actual={accessibility_codes}")
            rejected_codes_seen.update(expected_codes)
        else:
            errors.append(f"{fixture_id}: expectedDecision must be accept or reject")

    required_red_paths = {
        "missing_accessibility_semantics",
        "accessibility_label_missing",
        "accessibility_value_missing",
        "accessibility_hint_missing",
        "accessibility_summary_missing",
        "accessibility_visual_only",
        "accessibility_generic_label",
        "dynamic_type_unsafe",
        "reduce_motion_unsafe",
        "accessibility_repair_required",
    }
    missing_red_paths = sorted(required_red_paths.difference(rejected_codes_seen))
    if missing_red_paths:
        errors.append(f"accessibility fixture matrix missing required rejected paths: {missing_red_paths}")
    if not accepted_seen:
        errors.append("accessibility fixture matrix has no accepted fixture")
    return errors


def main() -> int:
    contract = load_json(CONTRACT_PATH)
    fixtures = load_json(FIXTURES_PATH)
    scanner = load_json(SCANNER_PATH)
    scanner_fixtures = load_json(SCANNER_FIXTURES_PATH)
    context_validator = load_json(CONTEXT_VALIDATOR_PATH)
    context_fixtures = load_json(CONTEXT_FIXTURES_PATH)
    source_proof_validator = load_json(SOURCE_PROOF_VALIDATOR_PATH)
    source_proof_fixtures = load_json(SOURCE_PROOF_FIXTURES_PATH)
    accessibility_validator = load_json(ACCESSIBILITY_VALIDATOR_PATH)
    accessibility_fixtures = load_json(ACCESSIBILITY_FIXTURES_PATH)

    errors = []
    errors.extend(validate_contract_shape(contract))
    errors.extend(validate_scanner_shape(scanner))
    errors.extend(validate_context_validator_shape(context_validator))
    errors.extend(validate_source_proof_validator_shape(source_proof_validator))
    errors.extend(validate_accessibility_validator_shape(accessibility_validator))
    errors.extend(validate_fixtures(contract, fixtures))
    errors.extend(validate_scanner_fixtures(scanner, scanner_fixtures))
    errors.extend(validate_context_fixtures(context_validator, context_fixtures))
    errors.extend(validate_source_proof_fixtures(source_proof_validator, source_proof_fixtures))
    errors.extend(validate_accessibility_fixtures(accessibility_validator, accessibility_fixtures))

    if errors:
        print("FAIL Step Quality Firewall validator")
        for error in errors:
            print(f"- {error}")
        return 1

    print("PASS Step Quality Firewall validator")
    print(f"contract={CONTRACT_PATH.relative_to(ROOT)}")
    print(f"fixtures={FIXTURES_PATH.relative_to(ROOT)}")
    print(f"scanner={SCANNER_PATH.relative_to(ROOT)}")
    print(f"scanner_fixtures={SCANNER_FIXTURES_PATH.relative_to(ROOT)}")
    print(f"context_validator={CONTEXT_VALIDATOR_PATH.relative_to(ROOT)}")
    print(f"context_fixtures={CONTEXT_FIXTURES_PATH.relative_to(ROOT)}")
    print(f"source_proof_validator={SOURCE_PROOF_VALIDATOR_PATH.relative_to(ROOT)}")
    print(f"source_proof_fixtures={SOURCE_PROOF_FIXTURES_PATH.relative_to(ROOT)}")
    print(f"accessibility_validator={ACCESSIBILITY_VALIDATOR_PATH.relative_to(ROOT)}")
    print(f"accessibility_fixtures={ACCESSIBILITY_FIXTURES_PATH.relative_to(ROOT)}")
    print("models=StepQualityInput, StepQualityVerdict")
    print("generic_scanner=runnable")
    print("context_fit_validator=runnable")
    print("source_proof_validator=runnable")
    print("accessibility_validator=runnable")
    print("m10_dependency=runnable")
    return 0


if __name__ == "__main__":
    sys.exit(main())
