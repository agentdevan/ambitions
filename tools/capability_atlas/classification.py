"""Deterministic Phase B classification for capability candidates."""

from __future__ import annotations

import re
from dataclasses import dataclass, replace
from pathlib import PurePosixPath
from typing import Iterable

from tools.capability_atlas.model import CandidateRecord


CLASSIFICATIONS = frozenset(
    {
        "capability",
        "behavior",
        "requirement",
        "object",
        "surface",
        "system",
        "implementation",
        "design_language",
        "project",
        "evidence",
        "ambiguous",
    }
)
QUALIFICATION_STATUSES = frozenset({"qualified", "supporting", "ambiguous"})

REQUIREMENT_ID_PATTERN = re.compile(
    r"^[A-Z][A-Z0-9]*(?:-[A-Z0-9]+){2,}\s+[—:-]\s+"
)
TASK_PATTERN = re.compile(
    r"^(?:task|phase|wave|train|campaign|step)\s+\d+\b",
    re.IGNORECASE,
)
COMMAND_OR_PATH_PATTERN = re.compile(
    r"(?:^|[\s\"'`])(?:python3|pytest|swift\s+test|xcodebuild|git|jq|npx|bash|"
    r"scripts/|docs/|Native/|tools/|Packages/|\.github/|[A-Za-z0-9_.-]+\.(?:json|md|"
    r"swift|py|sh|yaml|yml|toml|png|jpg|jpeg|docx))(?:$|[\s\"'`,:])",
    re.IGNORECASE,
)
PROJECT_TERMS = re.compile(
    r"\b(?:implementation plan|reconstruction plan|review package|acceptance gate|"
    r"remediation|closeout|workstream|milestone|backlog|readiness gate|program plan|"
    r"owner review|validation plan|test plan)\b",
    re.IGNORECASE,
)
EVIDENCE_TERMS = re.compile(
    r"\b(?:evidence|proof ceiling|validation|test results?|audit finding|artifact|"
    r"screenshot|fixture|receipt|command output|current evidence|source map|traceability)\b",
    re.IGNORECASE,
)
DESIGN_TERMS = re.compile(
    r"\b(?:liquid glass|material|chrome|dock|crown|typography|palette|color|spacing|"
    r"radius|shadow|visual language|visual system|motion curve|layout anatomy|hero|"
    r"viewport|appearance treatment|rendering|matched transition)\b",
    re.IGNORECASE,
)
SYSTEM_TERMS = re.compile(
    r"\b(?:runtime|engine|store|coordinator|service|adapter|persistence|replay|sync|"
    r"diagnostics|scheduler|indexer|compiler|pipeline|registry|subsystem|source atlas)\b",
    re.IGNORECASE,
)
IMPLEMENTATION_TERMS = re.compile(
    r"\b(?:swiftui|swiftdata|sqlite|cloudkit|core spotlight|app intents?|xctest|"
    r"reducer|protocol|actor|struct|class|enum|module|package|api|schema|migration|"
    r"repository|code|implementation)\b",
    re.IGNORECASE,
)
BEHAVIOR_TERMS = re.compile(
    r"\b(?:tap|swipe|drag|drop|press|open|close|dismiss|select|insert|move|delete|"
    r"edit|commit|confirm|undo|redo|focus|announce|navigate|transfer|place|reorder|"
    r"filter|sort|pin|unpin|archive|restore)\b",
    re.IGNORECASE,
)
CAPABILITY_TERMS = re.compile(
    r"\b(?:simulation|pathing|reflow|search|command|appearance studio|share studio|"
    r"skill transference|learning|adaptation|recovery|continuity|planning|projection|"
    r"inspection|capture|export|import|privacy|personalization|recommendation|scenario|"
    r"orchestration|goal formation|decision support|knowledge|file storage|sharing)\b",
    re.IGNORECASE,
)
NORMATIVE_VERBS = re.compile(r"\b(?:must|should|shall|required|forbidden)\b", re.IGNORECASE)
PERSON_VALUE_VERBS = re.compile(
    r"\b(?:help|enable|allow|understand|generate|simulate|adapt|protect|preserve|"
    r"support|coordinate|reconcile|learn|transfer|restore|find|share|plan|decide|"
    r"inspect|control|compare|explore)\w*\b",
    re.IGNORECASE,
)

KNOWN_OBJECTS = frozenset(
    {
        "attachment",
        "branch viability certificate",
        "closure",
        "event",
        "goal",
        "goal path",
        "history event",
        "import diff record",
        "life area",
        "life branch",
        "note",
        "notification rule",
        "proof",
        "receipt",
        "recovery segment",
        "reminder",
        "saved for later draft",
        "schedule placement",
        "source reference",
        "step",
    }
)
KNOWN_SURFACES = frozenset({"today", "goals", "time", "you"})
KNOWN_GLOBAL_FACILITIES = frozenset({"capture", "search", "motion", "trust inspection"})


@dataclass(frozen=True, slots=True)
class ClassificationDecision:
    classification: str
    qualification_status: str
    reason_code: str
    rationale: str
    confidence: float
    disposition: str

    def __post_init__(self) -> None:
        if self.classification not in CLASSIFICATIONS:
            raise ValueError(f"unsupported classification: {self.classification}")
        if self.qualification_status not in QUALIFICATION_STATUSES:
            raise ValueError(
                f"unsupported qualification status: {self.qualification_status}"
            )
        if not 0.0 <= self.confidence <= 1.0:
            raise ValueError("classification confidence must be between 0 and 1")


def _decision(
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


def _source_context(candidate: CandidateRecord) -> tuple[str, PurePosixPath, str, str]:
    evidence = candidate.evidence[0]
    return (
        evidence.family_id,
        PurePosixPath(evidence.source_path),
        evidence.extraction_kind,
        candidate.exact_terminology.strip(),
    )


def _is_json_metadata(text: str) -> bool:
    stripped = text.strip()
    if stripped.startswith(('"', "'")) and ":" in stripped:
        return True
    if stripped.startswith(("{", "[")):
        return True
    return bool(re.match(r"^[A-Za-z0-9_]+\s*[:=]\s*", stripped))


def _object_from_path(path: PurePosixPath) -> str | None:
    parts = path.parts
    try:
        index = parts.index("objects")
    except ValueError:
        return None
    if index + 1 >= len(parts):
        return None
    return PurePosixPath(parts[index + 1]).stem.replace("-", " ").casefold()


def _surface_from_path(path: PurePosixPath) -> str | None:
    parts = path.parts
    try:
        index = parts.index("surfaces")
    except ValueError:
        return None
    if index + 1 >= len(parts):
        return None
    return PurePosixPath(parts[index + 1]).stem.casefold()


def classify_candidate(candidate: CandidateRecord) -> ClassificationDecision:
    """Classify one candidate without changing its authority status."""

    if candidate.authority_status == "owner_seed":
        return _decision(
            "capability",
            "qualified",
            "direct_owner_seed",
            "Direct owner-originated product promise; preserved for reconciliation without assuming canonization.",
            1.0,
        )

    family_id, source_path, extraction_kind, text = _source_context(candidate)
    lowered = text.casefold()
    name = candidate.normalized_name_hint.casefold()

    if _is_json_metadata(text) or COMMAND_OR_PATH_PATTERN.search(text):
        return _decision(
            "evidence",
            "supporting",
            "machine_metadata_or_command",
            "The extracted text is a command, file reference, structured-data field, or evidence pointer rather than a durable user-facing promise.",
            0.99,
        )

    if TASK_PATTERN.search(text) or PROJECT_TERMS.search(text):
        return _decision(
            "project",
            "supporting",
            "delivery_or_review_container",
            "The record names delivery, review, remediation, or program work rather than product capability.",
            0.97,
        )

    if family_id == "SRC-TESTS":
        return _decision(
            "evidence",
            "supporting",
            "test_evidence_source",
            "Test sources can verify a capability but cannot define or authorize one by themselves.",
            0.98,
        )

    if family_id == "SRC-PRODUCTION":
        return _decision(
            "implementation",
            "supporting",
            "implementation_evidence_source",
            "Production code is implementation evidence and cannot independently establish a durable product promise.",
            0.98,
        )

    if family_id == "SRC-HISTORICAL":
        return _decision(
            "project",
            "supporting",
            "historical_planning_source",
            "Historical planning material is preserved as provenance but does not independently qualify as a current capability.",
            0.94,
        )

    object_name = _object_from_path(source_path)
    if object_name is not None and (
        extraction_kind == "capability_heading_hint"
        or name in KNOWN_OBJECTS
        or object_name in name
    ):
        return _decision(
            "object",
            "supporting",
            "canonical_object_identity",
            "The record names or defines a canonical domain object. Objects support capabilities but are not capabilities themselves.",
            0.96,
        )

    surface_name = _surface_from_path(source_path)
    if surface_name is not None and (
        name in KNOWN_SURFACES
        or name.endswith(" surface")
        or name.endswith(" root")
        or text.casefold().startswith("surface ")
    ):
        return _decision(
            "surface",
            "supporting",
            "surface_identity",
            "The record names a root or presentation surface rather than the durable promise expressed through it.",
            0.96,
        )

    if REQUIREMENT_ID_PATTERN.search(text):
        return _decision(
            "requirement",
            "supporting",
            "explicit_requirement_identity",
            "The record is an identified requirement or invariant. It may support a capability but is too granular to be the capability itself.",
            0.96,
        )

    if source_path.as_posix().startswith("docs/canon/specifications/systems/") and (
        extraction_kind == "capability_heading_hint" or SYSTEM_TERMS.search(text)
    ):
        return _decision(
            "system",
            "supporting",
            "system_specification_identity",
            "The record identifies enabling runtime or system infrastructure rather than a person-facing promise.",
            0.91,
        )

    if source_path.as_posix().startswith("docs/canon/specifications/global/") and (
        name in KNOWN_GLOBAL_FACILITIES or name.endswith(" authority")
    ):
        return _decision(
            "system",
            "supporting",
            "global_facility_identity",
            "The record identifies a global facility or its authority boundary. The facility may contain multiple capabilities.",
            0.9,
        )

    if family_id == "SRC-DESIGN-CANON" and DESIGN_TERMS.search(text):
        return _decision(
            "design_language",
            "supporting",
            "visual_or_interaction_expression",
            "The record describes visual, layout, material, or motion expression rather than an implementation-independent product promise.",
            0.9,
        )

    if EVIDENCE_TERMS.search(text) and not PERSON_VALUE_VERBS.search(text):
        return _decision(
            "evidence",
            "supporting",
            "evidence_or_validation_record",
            "The record describes proof, audit, traceability, or validation material rather than a user-facing capability.",
            0.87,
        )

    if IMPLEMENTATION_TERMS.search(text) and not PERSON_VALUE_VERBS.search(text):
        classification = "system" if SYSTEM_TERMS.search(text) else "implementation"
        return _decision(
            classification,
            "supporting",
            "mechanism_or_architecture_record",
            "The record is dominated by mechanism, code, schema, or architecture terminology rather than durable person-facing value.",
            0.84,
        )

    if extraction_kind == "person_facing_promise_hint":
        if BEHAVIOR_TERMS.search(text) and not re.search(
            r"\b(?:simulation|learning|planning|continuity|personalization|orchestration)\b",
            text,
            re.IGNORECASE,
        ):
            return _decision(
                "behavior",
                "supporting",
                "bounded_user_interaction_or_state_change",
                "The record describes a bounded user action, mutation, transfer, or interaction that supports a broader capability.",
                0.78,
            )
        if PERSON_VALUE_VERBS.search(text) and CAPABILITY_TERMS.search(text):
            return _decision(
                "capability",
                "qualified",
                "durable_person_facing_promise",
                "The record states meaningful person-facing value using capability-level terminology and is not bound to one mechanism or control.",
                0.82,
            )
        if NORMATIVE_VERBS.search(text):
            return _decision(
                "requirement",
                "supporting",
                "normative_behavior_constraint",
                "The record is phrased as a normative behavior constraint and requires grouping beneath a broader capability promise.",
                0.72,
            )

    if extraction_kind == "capability_heading_hint" and CAPABILITY_TERMS.search(text):
        if any(
            token in lowered
            for token in (
                "test",
                "validation",
                "evidence",
                "audit",
                "inventory",
                "ownership",
                "authority",
                "gate",
                "matrix",
                "contract",
                "manifest",
            )
        ):
            return _decision(
                "evidence",
                "supporting",
                "capability_governance_heading",
                "The heading concerns capability governance, inventory, authority, or evidence rather than a product promise.",
                0.83,
            )
        return _decision(
            "capability",
            "qualified",
            "capability_oriented_heading",
            "The heading names a coherent capability-oriented concept that warrants product-level reconciliation.",
            0.7,
        )

    if DESIGN_TERMS.search(text):
        return _decision(
            "design_language",
            "supporting",
            "design_expression_without_product_promise",
            "The record is primarily a visual or interaction expression and needs a separate capability owner if one exists.",
            0.75,
        )

    if SYSTEM_TERMS.search(text):
        return _decision(
            "system",
            "supporting",
            "enabling_system_without_product_promise",
            "The record primarily identifies an enabling system or subsystem.",
            0.72,
        )

    return _decision(
        "ambiguous",
        "ambiguous",
        "insufficient_durable_promise_evidence",
        "The record cannot be safely promoted or excluded as a capability without semantic reconciliation against neighboring evidence.",
        0.45,
    )


def apply_classification(candidate: CandidateRecord) -> CandidateRecord:
    """Return a classified immutable candidate record."""

    decision = classify_candidate(candidate)
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
    """Classify candidates deterministically in input order."""

    return tuple(apply_classification(candidate) for candidate in candidates)
