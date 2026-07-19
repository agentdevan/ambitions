import re
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field, model_validator, field_validator

class GoalDomain(BaseModel):
    code: str = Field(..., description="Unique alphanumeric identifier (e.g. 'finance')")
    title: str = Field(..., description="Human-readable domain title")
    description: str = Field(..., description="Detailed scope description")
    categories: List[str] = Field(default_factory=list, description="Associated categories/focus areas")

    @field_validator("code")
    @classmethod
    def validate_code(cls, v: str) -> str:
        if not re.match(r"^[a-z0-9_-]+$", v):
            raise ValueError("Domain code must be lowercase alphanumeric, hyphens, or underscores only.")
        return v

class GrammarBank(BaseModel):
    domain: str = Field(..., description="Domain code code references")
    category: str = Field(..., description="Domain category code references")
    templates: List[str] = Field(..., description="String templates with placeholders e.g., 'Learn [skill]'")
    vocab: Dict[str, List[str]] = Field(..., description="Lists of words to fill the placeholders")

    @model_validator(mode="after")
    def validate_templates_and_vocab(self) -> 'GrammarBank':
        # Ensure vocab contains all placeholders used in templates
        for temp in self.templates:
            placeholders = re.findall(r"\[([a-zA-Z0-9_-]+)\]", temp)
            for ph in placeholders:
                if ph not in self.vocab:
                    raise ValueError(f"Vocabulary list for placeholder '[{ph}]' not found in vocab.")
        return self

class SeedArchetype(BaseModel):
    id: str = Field(..., description="Stable seed ID")
    title: str = Field(..., description="Title of seed archetype")
    domain: str = Field(..., description="Target domain code")
    category: str = Field(..., description="Target category")
    intent_phrase: str = Field(..., description="Ground truth intent phrase")
    evidence_quality: str = Field("seed_archetype", description="Will be runtime ineligible")
    source_freshness: str = "current"
    risk_level: str = "ordinary"

class SourceCandidate(BaseModel):
    id: str = Field(..., description="Candidate ID")
    url: str = Field(..., description="Source URL reference")
    title: str = Field(..., description="Title of source document")
    domain: str = Field(..., description="Target domain")
    category: str = Field(..., description="Target category")
    extracted_intents: List[str] = Field(..., description="Intents extracted from this source")

class GoalIntentRecord(BaseModel):
    id: str = Field(..., description="Unique stable ID of the goal intent")
    domain: str = Field(..., description="Domain identifier")
    category: str = Field(..., description="Category identifier")
    intent_phrase: str = Field(..., description="The user goal intent expression")
    runtime_eligible: bool = Field(..., description="If true, eligible for candidate intent matching only")
    runtime_role: str = Field("intent_matching_only", description="Must be intent_matching_only")
    blocked_for_step_generation: bool = Field(True, description="Must be true to prevent raw step generation")
    evidence_quality: str = Field(..., description="generated_only, seed_archetype, peer_reviewed, professional_guidance_required")
    source_freshness: str = Field(..., description="current, stale_warning, unknown")
    risk_level: str = Field(..., description="ordinary, high, critical")
    private_data_flag: bool = Field(False, description="Flagged if contains sensitive PII")
    created_at: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    production_use: Optional[bool] = Field(None, description="Forbidden regression field")
    stores_final_schedule: Optional[bool] = Field(None, description="Forbidden regression field")

    @model_validator(mode="after")
    def validate_data_safety_rules(self) -> 'GoalIntentRecord':
        # Regression checks
        if self.production_use is not None:
            raise ValueError("Banned regression field 'production_use' must not be specified.")
        if self.stores_final_schedule is not None:
            raise ValueError("Banned regression field 'stores_final_schedule' must not be specified.")
        if self.evidence_quality in ["official", "official/current"]:
            raise ValueError("Banned evidence quality 'official' or 'official/current'.")
        if self.source_freshness == "official/current":
            raise ValueError("Banned source freshness 'official/current'.")

        # 1. Eligibility safety checks
        if self.runtime_eligible:
            if self.runtime_role != "intent_matching_only":
                raise ValueError("Goal intent may be runtime_eligible: true ONLY if runtime_role is 'intent_matching_only'.")
            if not self.blocked_for_step_generation:
                raise ValueError("Goal intent may be runtime_eligible: true ONLY if blocked_for_step_generation is true.")
        
        # Seeds and source-backed records remain runtime ineligible
        if self.evidence_quality in ["seed_archetype", "peer_reviewed", "professional_guidance_required"]:
            if self.runtime_eligible:
                raise ValueError(f"Evidence quality '{self.evidence_quality}' must not be runtime_eligible. Seeds and sources are runtime ineligible.")

        # 2. Prevent forbidden credentials / API keys / schedules in intent phrase
        lower_phrase = self.intent_phrase.lower()
        if re.search(r"sk-[a-za-z0-9_-]{12,}", lower_phrase):
            raise ValueError("Intent phrase contains potential API keys or secrets.")
        
        # Check private data indicators in intent phrase
        email_pattern = r"[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+"
        phone_pattern = r"\b\d{3}[-.]?\d{3}[-.]?\d{4}\b"
        if re.search(email_pattern, lower_phrase) or re.search(phone_pattern, lower_phrase):
            # Enforce that if PII exists, private_data_flag must be True
            if not self.private_data_flag:
                raise ValueError("Private PII detected in intent phrase but private_data_flag is False.")
        
        if self.private_data_flag:
            raise ValueError("Record contains private data and is rejected from clean warehouse.")

        # 3. Prevent shaming or fake urgency / productivity guilt
        banned_phrases = ["streak broken", "productivity dropped", "shame", "guilty", "streak alert", "overdue!!"]
        for bp in banned_phrases:
            if bp in lower_phrase:
                raise ValueError(f"Intent phrase contains shaming or fake urgency phrasing: '{bp}'")

        return self
