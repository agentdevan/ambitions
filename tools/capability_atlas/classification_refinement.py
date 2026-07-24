"""Authority-aware refinement for deterministic capability classification."""

from __future__ import annotations

import re
from dataclasses import replace
from typing import Iterable

from tools.capability_atlas.classification import (
    ClassificationDecision,
    classify_candidate,
)
from tools.capability_atlas.model import CandidateRecord


PATH_REFERENCE_PATTERN = re.compile(
    r"(?:^|[\s\"'`(])(?:\.?/?(?:docs|Native|tools|Packages|scripts|\.github|\.codex)/"
    r"[^\s\"'`,;|)]+|[^\s\"'`,;|)]+\.(?:json|md|swift|py|sh|yaml|yml|toml|png|"
    r"jpg|jpeg|docx|xcresult))(?:$|[\s\"'`,;|)])",
    re.IGNORECASE,
)
BARE_IDENTIFIER_PATTERN = re.compile(
    r"^[\"'`]?(?:[A-Z][A-Z0-9]*(?:-[A-Z0-9]+){2,}|[a-z][a-z0-9]*(?:[._][a-z0-9]+){2,})[\"'`]?,?$"
)
REQUIREMENT_HEADING_PATTERN = re.compile(
    r"^[A-Z][A-Z0-9]*(?:-[A-Z0-9]+)+\s+[—:-]\s+"
)
ISSUE_OR_PACKET_PATTERN = re.compile(
    r"^(?:#+\s*)?(?:AMB-\d+|VC-\d+|VSP-\d+|RP-\d+|CEBR-\d+)\b",
    re.IGNORECASE,
)
AUDIT_TABLE_PATTERN = re.compile(r"\|.*\|")
NORMATIVE_CONSTRAINT_PATTERN = re.compile(
    r"\b(?:MUST|MUST NOT|SHALL|SHALL NOT|REQUIRED|FORBIDDEN)\b"
)
NORMATIVE_OWNERSHIP_PATTERN = re.compile(
    r"\b(?:owns?|ownership|distinguishes?|triggers?|classif(?:y|ies)|requires?|"
    r"transfers?|SHOULD|MUST|MAY|is distinct|are distinct|remains canonical)\b",
    re.IGNORECASE,
)
NON_CAPABILITY_HEADING_PATTERN = re.compile(
    r"\b(?:requirements?|policy|rules?|law|thresholds?|lineage|correctness|scope|"
    r"scenario|interop|projection|operations?|authority|ownership|contract|matrix|"
    r"inventory|gating|tests?)\b",
    re.IGNORECASE,
)
SYSTEM_HEADING_PATTERN = re.compile(
    r"\b(?:lineage|projection|interop|operations?|adapter|runtime|engine|store|"
    r"coordinator|service|pipeline|registry)\b",
    re.IGNORECASE,
)
EVIDENCE_HEADING_PATTERN = re.compile(
    r"\b(?:scenario|matrix|inventory|gating|tests?|acceptance|evidence|proof)\b",
    re.IGNORECASE,
)
GOVERNANCE_OR_DELIVERY_PATTERN = re.compile(
    r"\b(?:acceptance|audit|evidence|proof|gate|packet|dossier|remediation|"
    r"reconciliation|readiness|inventory|ownership|authority|source acceptance|"
    r"current main|current repository|gates targeted|files created|focused final|"
    r"risk register|frontend recovery|planning)\b",
    re.IGNORECASE,
)

EVIDENCE_ONLY_FAMILIES = frozenset(
    {
        "SRC-AUDITS",
        "SRC-QA-REMEDIATION",
        "SRC-LINEAR-MIRRORS",
        "SRC-TESTS",
        "SRC-PRODUCTION",
        "SRC-HISTORICAL",
    }
)
DESIGN_REFERENCE_FAMILIES = frozenset({"SRC-DESIGN-CANON"})
NORMATIVE_FAMILIES = frozenset(
    {
        "SRC-CONSTITUTION",
        "SRC-NORMATIVE-SPECS",
        "SRC-STANDARDS",
    }
)
DECISION_FAMILIES = frozenset({"SRC-ADRS"})


def _decision(
    *,
    classification: str,
    qualification_status: str,
    reason_code: str,
    rationale: str,
    confidence: float,
) -> ClassificationDecision:
    if qualification_status == "qualified":
        disposition = "retain_as_qualified_capability_candidate"
    elif qualification_status == "ambiguous":
        disposition = "preserve_for_manual_capability_reconciliation"
    else:
        disposition = f"preserve_as_supporting_{classification}"
    return ClassificationDecision(
        classification=classification,
        qualification_status=qualification_status,
        reason_code=reason_code,
        rationale=rationale,
        confidence=confidence,
        disposition=disposition,
    )


def _clean_text(value: str) -> str:
    return value.strip().strip(" \t\r\n\"'`,[]{}()")


def refine_classification(
    candidate: CandidateRecord,
    base: ClassificationDecision,
) -> ClassificationDecision:
    """Apply authority and obvious-reference constraints after semantic rules."""

    if candidate.authority_status == "owner_seed":
        return base

    evidence = candidate.evidence[0]
    family_id = evidence.family_id
    text = candidate.exact_terminology.strip()
    cleaned = _clean_text(text)

    if PATH_REFERENCE_PATTERN.search(text):
        return _decision(
            classification="evidence",
            qualification_status="supporting",
            reason_code="file_or_artifact_reference",
            rationale="The record is or contains a repository path, generated artifact, result bundle, or file reference rather than a product promise.",
            confidence=0.99,
        )

    if BARE_IDENTIFIER_PATTERN.fullmatch(text.strip()):
        classification = "requirement" if family_id in NORMATIVE_FAMILIES else "evidence"
        return _decision(
            classification=classification,
            qualification_status="supporting",
            reason_code="bare_identifier_reference",
            rationale="A bare requirement, command, state, or taxonomy identifier is a reference to another contract rather than a self-contained capability promise.",
            confidence=0.98,
        )

    if REQUIREMENT_HEADING_PATTERN.search(cleaned):
        return _decision(
            classification="requirement",
            qualification_status="supporting",
            reason_code="requirement_heading_identity",
            rationale="The record is an identified law, policy, or requirement heading and should trace beneath a broader capability.",
            confidence=0.98,
        )

    if ISSUE_OR_PACKET_PATTERN.search(cleaned):
        return _decision(
            classification="project",
            qualification_status="supporting",
            reason_code="issue_packet_or_campaign_reference",
            rationale="The record is anchored to an issue, packet, campaign, or delivery identifier rather than stable person-facing value.",
            confidence=0.96,
        )

    if AUDIT_TABLE_PATTERN.search(text) and family_id in EVIDENCE_ONLY_FAMILIES:
        return _decision(
            classification="evidence",
            qualification_status="supporting",
            reason_code="operational_table_or_acceptance_row",
            rationale="The record is an operational, audit, coverage, or acceptance table row. It can support later traceability but does not independently define a capability.",
            confidence=0.94,
        )

    if family_id in EVIDENCE_ONLY_FAMILIES and base.classification == "capability":
        if GOVERNANCE_OR_DELIVERY_PATTERN.search(text):
            return _decision(
                classification="evidence",
                qualification_status="supporting",
                reason_code="capability_claim_in_operational_evidence",
                rationale="The source records an operational capability claim, acceptance state, gap, or proof statement. An owning product source is required before qualification.",
                confidence=0.92,
            )
        return _decision(
            classification="ambiguous",
            qualification_status="ambiguous",
            reason_code="capability_like_evidence_requires_authority_source",
            rationale="The evidence source appears to describe person-facing value, but implementation, audit, QA, or planning evidence cannot independently authorize a capability.",
            confidence=0.72,
        )

    if family_id in DESIGN_REFERENCE_FAMILIES and base.classification == "capability":
        return _decision(
            classification="ambiguous",
            qualification_status="ambiguous",
            reason_code="design_implied_capability_requires_product_authority",
            rationale="The design source implies a possible product capability. It remains preserved for reconciliation but requires product-law support or an owner decision.",
            confidence=0.7,
        )

    if base.classification == "capability" and evidence.extraction_kind == "capability_heading_hint":
        if NON_CAPABILITY_HEADING_PATTERN.search(cleaned):
            if EVIDENCE_HEADING_PATTERN.search(cleaned):
                classification = "evidence"
            elif SYSTEM_HEADING_PATTERN.search(cleaned):
                classification = "system"
            else:
                classification = "requirement"
            return _decision(
                classification=classification,
                qualification_status="supporting",
                reason_code="non_capability_governance_or_mechanism_heading",
                rationale="The heading names policy, scope, correctness, system mechanism, scenario, or governance rather than durable person-facing value.",
                confidence=0.9,
            )
        if family_id in DECISION_FAMILIES:
            return _decision(
                classification="ambiguous",
                qualification_status="ambiguous",
                reason_code="decision_heading_requires_product_promise_reconciliation",
                rationale="The accepted decision heading may imply a capability, but the heading alone does not state the durable person-facing promise.",
                confidence=0.67,
            )

    if (
        family_id in NORMATIVE_FAMILIES
        and base.classification == "capability"
        and evidence.extraction_kind == "person_facing_promise_hint"
        and (
            NORMATIVE_CONSTRAINT_PATTERN.search(text)
            or NORMATIVE_OWNERSHIP_PATTERN.search(text)
        )
    ):
        return _decision(
            classification="requirement",
            qualification_status="supporting",
            reason_code="normative_constraint_not_capability_identity",
            rationale="The statement is an enforceable constraint, ownership law, or behavior rule. It should trace to a capability but is not itself the stable capability identity.",
            confidence=0.88,
        )

    if (
        family_id in DECISION_FAMILIES
        and base.classification == "capability"
        and NORMATIVE_OWNERSHIP_PATTERN.search(text)
    ):
        return _decision(
            classification="requirement",
            qualification_status="supporting",
            reason_code="decision_ownership_or_transfer_rule",
            rationale="The accepted decision states an ownership, transfer, or interaction rule rather than a durable product capability.",
            confidence=0.84,
        )

    if (
        base.classification == "capability"
        and GOVERNANCE_OR_DELIVERY_PATTERN.search(text)
        and evidence.extraction_kind != "capability_heading_hint"
    ):
        return _decision(
            classification="evidence",
            qualification_status="supporting",
            reason_code="governance_or_delivery_claim",
            rationale="The statement is about governance, delivery, acceptance, proof, or current-state assessment rather than durable user-facing value.",
            confidence=0.86,
        )

    return base


def apply_refined_classification(candidate: CandidateRecord) -> CandidateRecord:
    base = classify_candidate(candidate)
    decision = refine_classification(candidate, base)
    return replace(
        candidate,
        classification=decision.classification,
        qualification_status=decision.qualification_status,
        classification_reason_code=decision.reason_code,
        classification_rationale=decision.rationale,
        classification_confidence=decision.confidence,
        disposition=decision.disposition,
    )


def classify_candidates(
    candidates: Iterable[CandidateRecord],
) -> tuple[CandidateRecord, ...]:
    return tuple(apply_refined_classification(candidate) for candidate in candidates)
