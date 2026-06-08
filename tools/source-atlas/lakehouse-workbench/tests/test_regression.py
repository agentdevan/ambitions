import json
from pathlib import Path
import pytest
from pydantic import ValidationError

import sys
sys.path.append(str(Path(__file__).resolve().parents[1]))

from schema import GoalIntentRecord

# Banned values or combinations
# - production_use true
# - runtime_eligible true for non-intent matching (runtime_role != "intent_matching_only" or blocked_for_step_generation != True)
# - stores_final_schedule true
# - official/current source state
# - app-facing manifest path

def test_regression_schema_constraints():
    # 1. Check production_use is banned (even if True or False, field must not be specified / must be None)
    with pytest.raises(ValidationError, match="Banned regression field 'production_use'"):
        GoalIntentRecord(
            id="intent.test.1",
            domain="health",
            category="cardio",
            intent_phrase="Run 5k",
            runtime_eligible=False,
            runtime_role="intent_matching_only",
            blocked_for_step_generation=True,
            evidence_quality="generated_only",
            source_freshness="current",
            risk_level="ordinary",
            production_use=True
        )

    # 2. Check stores_final_schedule is banned
    with pytest.raises(ValidationError, match="Banned regression field 'stores_final_schedule'"):
        GoalIntentRecord(
            id="intent.test.2",
            domain="health",
            category="cardio",
            intent_phrase="Run 5k",
            runtime_eligible=False,
            runtime_role="intent_matching_only",
            blocked_for_step_generation=True,
            evidence_quality="generated_only",
            source_freshness="current",
            risk_level="ordinary",
            stores_final_schedule=True
        )

    # 3. Check runtime_eligible is True only for intent matching (runtime_role="intent_matching_only" and blocked_for_step_generation=True)
    with pytest.raises(ValidationError):
        GoalIntentRecord(
            id="intent.test.3",
            domain="health",
            category="cardio",
            intent_phrase="Run 5k",
            runtime_eligible=True,
            runtime_role="full_steps",  # Not intent_matching_only
            blocked_for_step_generation=True,
            evidence_quality="generated_only",
            source_freshness="current",
            risk_level="ordinary"
        )

    with pytest.raises(ValidationError):
        GoalIntentRecord(
            id="intent.test.4",
            domain="health",
            category="cardio",
            intent_phrase="Run 5k",
            runtime_eligible=True,
            runtime_role="intent_matching_only",
            blocked_for_step_generation=False,  # Not blocked
            evidence_quality="generated_only",
            source_freshness="current",
            risk_level="ordinary"
        )

    # 4. Check official/current source state / evidence quality is banned
    with pytest.raises(ValidationError, match="Banned evidence quality 'official' or 'official/current'"):
        GoalIntentRecord(
            id="intent.test.5",
            domain="health",
            category="cardio",
            intent_phrase="Run 5k",
            runtime_eligible=False,
            runtime_role="intent_matching_only",
            blocked_for_step_generation=True,
            evidence_quality="official",
            source_freshness="current",
            risk_level="ordinary"
        )

    with pytest.raises(ValidationError, match="Banned evidence quality 'official' or 'official/current'"):
        GoalIntentRecord(
            id="intent.test.6",
            domain="health",
            category="cardio",
            intent_phrase="Run 5k",
            runtime_eligible=False,
            runtime_role="intent_matching_only",
            blocked_for_step_generation=True,
            evidence_quality="official/current",
            source_freshness="current",
            risk_level="ordinary"
        )

    with pytest.raises(ValidationError, match="Banned source freshness 'official/current'"):
        GoalIntentRecord(
            id="intent.test.7",
            domain="health",
            category="cardio",
            intent_phrase="Run 5k",
            runtime_eligible=False,
            runtime_role="intent_matching_only",
            blocked_for_step_generation=True,
            evidence_quality="generated_only",
            source_freshness="official/current",
            risk_level="ordinary"
        )

def test_regression_staged_files_scan():
    # Scan C:\Users\Devan\SourceAtlasFactory\runs\ for any violations in generated files
    base_dir = Path("C:/Users/Devan/SourceAtlasFactory/runs")
    if not base_dir.exists():
        return  # No runs generated yet, skip scanning

    all_files = list(base_dir.rglob("*.jsonl")) + list(base_dir.rglob("*.json"))
    for file in all_files:
        # Ignore temporary bootsrap files or other logs/reports that are not data artifacts
        # We only check data files under clean/ and publish/ directories
        file_path_str = str(file).replace("\\", "/").lower()
        if "clean" not in file_path_str and "publish" not in file_path_str:
            continue

        # Check path guardrails
        assert "current.json" not in file_path_str, f"Forbidden app-facing path: {file}"
        assert "/packs/" not in file_path_str, f"Forbidden app-facing path: {file}"
        assert "/seeds/" not in file_path_str, f"Forbidden app-facing path: {file}"

        # Check content
        with file.open("r", encoding="utf-8") as f:
            if file.suffix == ".jsonl":
                for line_num, line in enumerate(f, 1):
                    if not line.strip():
                        continue
                    try:
                        record = json.loads(line.strip())
                        validate_record_fields(record, f"{file}:{line_num}")
                    except json.JSONDecodeError:
                        pass
            elif file.suffix == ".json":
                try:
                    content = json.load(f)
                    if isinstance(content, dict):
                        # Could be domain-index or staged-manifest or a single record
                        validate_record_fields(content, str(file))
                    elif isinstance(content, list):
                        for idx, item in enumerate(content):
                            if isinstance(item, dict):
                                validate_record_fields(item, f"{file}[{idx}]")
                except json.JSONDecodeError:
                    pass

def validate_record_fields(record: dict, source_label: str):
    # Check production_use
    if "production_use" in record:
        assert record["production_use"] is not True, f"Violation in {source_label}: 'production_use' is True"
        
    # Check stores_final_schedule
    if "stores_final_schedule" in record:
        assert record["stores_final_schedule"] is not True, f"Violation in {source_label}: 'stores_final_schedule' is True"

    # Check runtime_eligible constraints
    if record.get("runtime_eligible") is True:
        role = record.get("runtime_role")
        blocked = record.get("blocked_for_step_generation")
        assert role == "intent_matching_only", f"Violation in {source_label}: runtime_eligible is True but runtime_role is '{role}' (expected 'intent_matching_only')"
        assert blocked is True, f"Violation in {source_label}: runtime_eligible is True but blocked_for_step_generation is {blocked} (expected True)"

    # Check evidence_quality
    eq = record.get("evidence_quality")
    if eq:
        assert eq != "official", f"Violation in {source_label}: evidence_quality is 'official'"
        assert eq != "official/current", f"Violation in {source_label}: evidence_quality is 'official/current'"

    # Check source_freshness
    sf = record.get("source_freshness")
    if sf:
        assert sf != "official/current", f"Violation in {source_label}: source_freshness is 'official/current'"
