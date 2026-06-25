import json
from pathlib import Path
import pytest
from pydantic import ValidationError

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))

from schema import GoalDomain, GrammarBank, GoalIntentRecord
from validator import expand_grammar_bank, validate_domain_intents
from duckdb_qa import run_qa_audits
from catalog import compile_foundry_candidate_artifacts
from paths import DEFAULT_RUNS_BASE_DIR
from publisher import generate_wrangler_commands, verify_remote_integrity

def test_goal_domain_validation():
    # Valid domain
    dom = GoalDomain(code="fitness-health", title="Fitness & Health", description="Test", categories=["cardio"])
    assert dom.code == "fitness-health"
    
    # Invalid domain code (uppercase)
    with pytest.raises(ValidationError):
        GoalDomain(code="Fitness", title="Fitness", description="Test")

def test_goal_intent_record_safety():
    # Valid eligible matching intent
    record = GoalIntentRecord(
        id="intent.123",
        domain="finance",
        category="saving",
        intent_phrase="Save money weekly",
        runtime_eligible=True,
        runtime_role="intent_matching_only",
        blocked_for_step_generation=True,
        evidence_quality="generated_only",
        source_freshness="current",
        risk_level="ordinary"
    )
    assert record.runtime_eligible is True
    
    # Invalid: runtime_eligible but blocked_for_step_generation is False
    with pytest.raises(ValidationError):
        GoalIntentRecord(
            id="intent.123",
            domain="finance",
            category="saving",
            intent_phrase="Save money weekly",
            runtime_eligible=True,
            runtime_role="intent_matching_only",
            blocked_for_step_generation=False,
            evidence_quality="generated_only",
            source_freshness="current",
            risk_level="ordinary"
        )
        
    # Invalid: runtime_eligible but wrong role
    with pytest.raises(ValidationError):
        GoalIntentRecord(
            id="intent.123",
            domain="finance",
            category="saving",
            intent_phrase="Save money weekly",
            runtime_eligible=True,
            runtime_role="full_steps",
            blocked_for_step_generation=True,
            evidence_quality="generated_only",
            source_freshness="current",
            risk_level="ordinary"
        )
        
    # Invalid: Seed archetype must be runtime ineligible
    with pytest.raises(ValidationError):
        GoalIntentRecord(
            id="intent.123",
            domain="finance",
            category="saving",
            intent_phrase="Save money weekly",
            runtime_eligible=True,
            runtime_role="intent_matching_only",
            blocked_for_step_generation=True,
            evidence_quality="seed_archetype",
            source_freshness="current",
            risk_level="ordinary"
        )

def test_shaming_and_pii_filtering():
    # Invalid: Shaming phrasing
    with pytest.raises(ValidationError):
        GoalIntentRecord(
            id="intent.123",
            domain="finance",
            category="saving",
            intent_phrase="Streak broken, productivity dropped. Shame!",
            runtime_eligible=False,
            runtime_role="intent_matching_only",
            blocked_for_step_generation=True,
            evidence_quality="generated_only",
            source_freshness="current",
            risk_level="ordinary"
        )
        
    # Invalid: Potential API Key
    with pytest.raises(ValidationError):
        GoalIntentRecord(
            id="intent.123",
            domain="finance",
            category="saving",
            intent_phrase="Use API Key sk-12345678901234567890",
            runtime_eligible=False,
            runtime_role="intent_matching_only",
            blocked_for_step_generation=True,
            evidence_quality="generated_only",
            source_freshness="current",
            risk_level="ordinary"
        )

def test_grammar_expansion():
    bank = GrammarBank(
        domain="finance",
        category="saving",
        templates=["Save [amount] for [purpose]"],
        vocab={
            "amount": ["$100", "$500"],
            "purpose": ["holiday", "rainy day"]
        }
    )
    expanded = list(expand_grammar_bank(bank))
    assert len(expanded) == 4
    phrases = [item["intent_phrase"] for item in expanded]
    assert "Save $100 for holiday" in phrases
    assert "Save $500 for rainy day" in phrases
    # All must have safe runtime settings
    for item in expanded:
        assert item["runtime_eligible"] is True
        assert item["runtime_role"] == "intent_matching_only"
        assert item["blocked_for_step_generation"] is True


def test_default_runs_root_is_repo_local_output():
    assert "output/source-atlas/lakehouse-runs" in str(DEFAULT_RUNS_BASE_DIR)
    assert "C:/Users" not in str(DEFAULT_RUNS_BASE_DIR)


def test_compile_foundry_candidate_artifacts_emits_first_class_handoff(tmp_path: Path):
    run_dir = tmp_path / "run-foundry-candidate"
    (run_dir / "clean").mkdir(parents=True)
    (run_dir / "reports").mkdir(parents=True)

    domains_file = tmp_path / "domains.json"
    domains_file.write_text(
        json.dumps(
            {
                "domains": [
                    {
                        "code": "space-career",
                        "title": "Space Career",
                        "description": "Space-career candidate coverage.",
                        "categories": ["astronaut"],
                    }
                ]
            }
        ),
        encoding="utf-8",
    )

    record = GoalIntentRecord(
        id="intent.space.1",
        domain="space-career",
        category="astronaut",
        intent_phrase="Prepare for astronaut candidacy",
        runtime_eligible=True,
        runtime_role="intent_matching_only",
        blocked_for_step_generation=True,
        evidence_quality="generated_only",
        source_freshness="current",
        risk_level="ordinary",
    )
    (run_dir / "clean" / "domain_intents.jsonl").write_text(record.model_dump_json() + "\n", encoding="utf-8")

    manifest = compile_foundry_candidate_artifacts(run_dir, domains_file)

    assert manifest["candidateCount"] == 1
    assert manifest["domainCount"] == 1
    assert manifest["candidateFileCount"] >= 5
    assert not (run_dir / "publish" / "factory").exists()

    candidate_root = Path(manifest["candidateRoot"])
    candidate_manifest = candidate_root / "candidate-manifest.json"
    foundry_handoff = candidate_root / "foundry-handoff.json"
    candidate_index = candidate_root / "candidate-intent-index.jsonl"
    coverage_matrix = candidate_root / "candidate-coverage-matrix.json"

    assert candidate_manifest.exists()
    assert foundry_handoff.exists()
    assert candidate_index.exists()
    assert coverage_matrix.exists()
    assert "candidate_only" in foundry_handoff.read_text(encoding="utf-8")
    assert "Prepare for astronaut candidacy" in candidate_index.read_text(encoding="utf-8")

    commands = generate_wrangler_commands(run_dir, "ambitions-source-atlas-staging")
    assert commands
    assert all(isinstance(item["args"], list) for item in commands)
    assert any("source-atlas/v1/candidates/run-foundry-candidate" in item["remote_key"] for item in commands)
    assert not json.dumps(commands).count("CLOUDFLARE_R2_SECRET_ACCESS_KEY")

    verification = verify_remote_integrity(commands, run_dir, "ambitions-source-atlas-staging", mock=True)
    assert verification["success"] is True
