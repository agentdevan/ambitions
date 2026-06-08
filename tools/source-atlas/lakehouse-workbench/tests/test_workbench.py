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
from catalog import compile_staged_artifacts

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
