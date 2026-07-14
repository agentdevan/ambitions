"""Deterministic validation and projection for the visual-rebaseline UX blueprint.

The blueprint is a requirement-linked design input.  It is deliberately outside
the normative specification atlas and cannot activate canon or visual authority.
"""

from __future__ import annotations

import json
import hashlib
import os
import re
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Mapping

from tools.ambitions_canon.parser import parse_canon_document


BLUEPRINT_PATH = Path("docs/canon/migration/ux-blueprint.json")
PROJECTION_PATH = Path("docs/canon/migration/UX_BLUEPRINT.md")
DISPOSITIONS_PATH = Path(
    "docs/canon/migration/ux-blueprint-requirement-dispositions.json"
)
REQUIREMENT_GRAPH_PATH = Path("docs/canon/generated/requirement-graph.json")
CANON_INDEX_PATH = Path("docs/canon/generated/canon-index.json")
BLUEPRINT_ID = "AMB-UX-BLUEPRINT-REBASELINE-001"
BLUEPRINT_TITLE = "Ambitions requirement-linked canonical UX blueprint"
PRIMARY_LINEAR_V3_ID = "96b93346-271d-46fc-beab-43ff7e286b5d"
PRIMARY_LINEAR_V3_TITLE = (
    "B1A-D01R — Ambitions Product / IA / Object Model Full Design Spec v3 — Canonical"
)
CLAIM_CEILING = (
    "Visual design input only; no source, runtime, rendered-app, accessibility, "
    "device, privacy/legal, distribution, or release claim."
)
RECORD_PROOF_CEILING = (
    "Design input only; no implementation, runtime, rendered-app, accessibility, "
    "device, privacy/legal, distribution, or release proof."
)
REQUIRED_SCOPES = frozenset(
    {
        "account",
        "app-shell",
        "capture",
        "goals",
        "offline-degraded",
        "permissions",
        "search",
        "setup",
        "time",
        "today",
        "trust",
        "you",
    }
)
REQUIRED_STATE_KINDS = frozenset(
    {
        "resting",
        "loading",
        "transitional",
        "empty",
        "degraded",
        "failure",
        "recovery",
        "rollback",
        "interruption",
    }
)
REQUIRED_FACETS = frozenset(
    {
        "dynamic-type",
        "focus-keyboard",
        "light-dark",
        "localization-long-copy",
        "motion-haptics",
        "non-color-semantics",
        "reduce-motion",
        "reduce-transparency",
        "sensitive-exposure-channels",
        "swiftui-anatomy",
        "voiceover-reading-order",
    }
)
REQUIRED_OBJECT_IDS = frozenset(
    {
        "attachment",
        "closure",
        "event",
        "goal",
        "goal-path",
        "history-event",
        "import-diff-record",
        "life-area",
        "note",
        "notification-rule",
        "proof",
        "receipt",
        "recovery-segment",
        "reminder",
        "saved-for-later-draft",
        "schedule-placement",
        "source-reference",
        "step",
    }
)
LEGACY_FIGMA_ROLES = (
    "exploration",
    "failure_evidence",
    "implementation_history",
    "provenance",
    "unique_content_source",
)
STATE_LAWS = {
    "degraded": frozenset(
        {"APP-DEGRADED-PRESENTATION-001", "APP-DEGRADED-STATE-001"}
    ),
    "empty": frozenset({"COPY-STATE-CONSEQUENCE-001"}),
    "failure": frozenset({"APP-DEGRADED-FAILURE-TAXONOMY-001"}),
    "interruption": frozenset({"COPY-STATE-CONSEQUENCE-001"}),
    "loading": frozenset({"COPY-STATE-CONSEQUENCE-001"}),
    "recovery": frozenset({"APP-DEGRADED-RECOVERY-001"}),
    "resting": frozenset({"COPY-STATE-CONSEQUENCE-001"}),
    "rollback": frozenset({"CONTROL-UNDO-RECOVERY-001"}),
    "transitional": frozenset({"COPY-STATE-CONSEQUENCE-001"}),
}
SEMANTIC_NONVISUAL_SENTINELS = frozenset(
    {
        "APP-DEEP-LINK-RESOLVE-001",
        "APP-DEEP-LINK-STATE-001",
        "APP-LAUNCH-READINESS-001",
        "DESIGN-004",
        "LAW-RUNTIME-NO-DIRECT-WRITE-001",
        "OBJ-CANONICAL-OWNER-001",
        "OBJ-COMMON-ENVELOPE-001",
        "OBJ-SCHEDULE-PLACEMENT-ATOMICITY-001",
        "PROOF-FIGMA-AUTHORITY-001",
        "SPEC-GLOBAL-CAPTURE-VISUAL-AUTHORITY-001",
        "SPEC-GLOBAL-SEARCH-INDEX-001",
        "SPEC-GLOBAL-SEARCH-INDEX-ACTIONS-001",
        "SPEC-GLOBAL-SEARCH-VISUAL-AUTHORITY-001",
        "SPEC-GLOBAL-TRUST-VISUAL-AUTHORITY-001",
        "SPEC-SURFACE-GOALS-VISUAL-AUTHORITY-001",
        "SPEC-SURFACE-TIME-VISUAL-AUTHORITY-001",
        "SPEC-SURFACE-TODAY-VISUAL-AUTHORITY-001",
        "SPEC-SURFACE-YOU-VISUAL-AUTHORITY-001",
        "STANDARD-VISUAL-REVIEW-001",
        "SYSTEM-APPLE-HANDOFF-001",
        "SYSTEM-APPLE-INTENTS-001",
        "SYSTEM-APPLE-PLATFORM-BASELINE-001",
        "SYSTEM-APPLE-SHARE-HANDOFF-001",
        "SYSTEM-APPLE-WIDGET-ACTION-001",
        "SYSTEM-PERSISTENCE-ATOMIC-001",
        "SYSTEM-PERSISTENCE-COMPACTION-001",
        "SYSTEM-PERSISTENCE-CORRUPTION-001",
        "SYSTEM-PERSISTENCE-MIGRATION-001",
        "SYSTEM-PERSISTENCE-REPLAY-001",
        "SYSTEM-SCHEDULING-FIT-001",
    }
)
SEMANTIC_VISUAL_SENTINELS = {
    "CONST-IA-ROOT-001": tuple(
        sorted(
            {
                "UX-SCREEN-APP-SHELL-ROOT",
                "UX-SCREEN-GOALS-ROOT",
                "UX-SCREEN-TIME-DAY",
                "UX-SCREEN-TODAY-ROOT",
                "UX-SCREEN-YOU-ROOT",
            }
        )
    ),
    "LAW-IA-NONROOT-001": tuple(
        sorted(
            {
                "UX-SCREEN-APP-SHELL-DRILLDOWN",
                "UX-SCREEN-APP-SHELL-SEARCH-CAPTURE",
                "UX-SCREEN-CAPTURE-COMPOSER",
                "UX-SCREEN-SEARCH-ROOT",
                "UX-SCREEN-TRUST-INLINE",
            }
        )
    ),
    "OBJECT-SAVED-FOR-LATER-001": (
        "UX-OBJECT-SAVED-FOR-LATER-DRAFT",
        "UX-SCREEN-CAPTURE-SAVED-FOR-LATER",
    ),
    "SECURITY-003": tuple(sorted((
        "UX-CROSS-SENSITIVE-EXPOSURE-CHANNELS",
        "UX-SECURITY-CHANNEL-APP-SWITCHER",
        "UX-SECURITY-CHANNEL-CAPTURE",
        "UX-SECURITY-CHANNEL-CLIPBOARD",
        "UX-SECURITY-CHANNEL-DIAGNOSTICS",
        "UX-SECURITY-CHANNEL-EXPORT",
        "UX-SECURITY-CHANNEL-NOTIFICATIONS",
        "UX-SECURITY-CHANNEL-SPOTLIGHT",
        "UX-SECURITY-CHANNEL-SUPPORT",
        "UX-SECURITY-CHANNEL-WIDGETS",
        "UX-SCREEN-ACCOUNT-SIGN-IN",
        "UX-SCREEN-APP-SHELL-ROOT",
        "UX-SCREEN-CAPTURE-ATTACHMENT",
        "UX-SCREEN-CAPTURE-COMPOSER",
        "UX-SCREEN-CAPTURE-PROPOSAL",
        "UX-SCREEN-PERMISSIONS-NOTIFICATIONS",
        "UX-SCREEN-SEARCH-ROOT",
        "UX-SCREEN-TRUST-DEEP",
        "UX-SCREEN-YOU-DATA",
        "UX-SCREEN-YOU-SETTINGS",
    ))),
    "SYSTEM-APPLE-PROJECTION-001": (
        "UX-SECURITY-CHANNEL-APP-SWITCHER",
        "UX-SECURITY-CHANNEL-SPOTLIGHT",
        "UX-SECURITY-CHANNEL-WIDGETS",
    ),
    "SYSTEM-APPLE-WIDGET-PROJECTION-001": (
        "UX-SECURITY-CHANNEL-WIDGETS",
    ),
}


def _required_state_variants() -> dict[str, tuple[str, ...]]:
    variants: dict[str, tuple[str, ...]] = {
        "UX-SCREEN-CAPTURE-ATTACHMENT": ("attachment-ready",),
        "UX-SCREEN-CAPTURE-COMPOSER": (
            "blank",
            "composing",
            "confirmation-required",
            "discard-review",
            "recovered",
            "saved",
            "saved-undo-eligible",
            "saved-undo-unavailable",
            "typed",
        ),
        "UX-SCREEN-CAPTURE-PROPOSAL": ("proposal-ready",),
        "UX-SCREEN-CAPTURE-SAVED-FOR-LATER": ("saved-for-later",),
        "UX-SCREEN-PERMISSIONS-CALENDAR": (
            "authorized",
            "denied",
            "eligibility-check",
            "limited",
            "local-fallback",
            "not-determined",
            "reconciling",
            "restricted",
            "unavailable",
        ),
        "UX-SCREEN-PERMISSIONS-NOTIFICATIONS": (
            "authorized",
            "denied",
            "eligibility-check",
            "limited",
            "local-fallback",
            "not-determined",
            "reconciling",
            "restricted",
            "unavailable",
        ),
        "UX-SCREEN-SEARCH-RESULTS": (
            "action-complete",
            "action-complete-undo-eligible",
            "action-complete-undo-unavailable",
            "action-preview",
            "filtered",
            "no-results",
            "results",
            "selected",
        ),
        "UX-SCREEN-SEARCH-ROOT": (
            "empty-query",
            "privacy-suppressed",
            "querying",
            "rebuilding",
            "recent",
            "restored",
        ),
        "UX-SCREEN-TIME-IMPORT": (
            "committing-import",
            "external-source-unchanged",
            "import-undo-unavailable",
            "native-import-undo",
            "reviewing-diff",
        ),
        "UX-SCREEN-TODAY-ROOT": (
            "dense",
            "empty",
            "low-density",
            "normal",
            "offline",
            "partial-failure",
            "permission-conflict",
            "restored",
            "stale",
        ),
        "UX-SCREEN-TODAY-START-HERE": (
            "active-execution",
            "closure-ready",
            "recovery-needed",
        ),
        "UX-SCREEN-TRUST-DEEP": (
            "correction-complete",
            "correction-required",
            "history-empty",
            "history-populated",
            "privacy-boundary-review",
            "privacy-redacted",
            "source-current",
            "source-stale",
            "source-unavailable",
        ),
        "UX-SCREEN-TRUST-INLINE": (
            "marker-present",
            "no-disclosure",
            "proof-optional",
            "proof-required",
            "proof-satisfied",
            "proof-suggested",
        ),
        "UX-SCREEN-TRUST-RECEIPT": (
            "receipt-committed",
            "receipt-committed-undo-eligible",
            "receipt-committed-undo-unavailable",
            "receipt-external-failed",
            "receipt-pending",
            "receipt-undone",
        ),
        "UX-SCREEN-YOU-DATA": (
            "backup-ready",
            "diagnostics-redacted",
            "export-failed",
            "export-preview",
            "export-progress",
            "permanent-delete-irreversible",
            "permanent-delete-review",
            "reset-review",
            "reset-rollback",
            "restore-review",
            "trash-empty",
            "trash-populated",
            "trash-restore",
        ),
        "UX-SCREEN-YOU-ROOT": (
            "account-signed-in",
            "account-signed-out",
            "action-required",
            "continuity-conflicted",
            "continuity-disabled",
            "continuity-pending",
            "diagnostics-degraded",
            "diagnostics-healthy",
            "life-capital-empty",
            "life-capital-populated",
            "no-account-healthy",
            "normal",
            "permissions-available",
            "permissions-denied",
            "setup-complete",
            "setup-partial",
        ),
        "UX-SCREEN-YOU-SETTINGS": (
            "app-lock-disabled",
            "app-lock-enabled",
            "appearance-dark",
            "appearance-light",
            "appearance-oled-dark",
            "appearance-system",
            "automation-policy",
            "biometric-unavailable",
            "increase-contrast",
            "notification-controls",
            "privacy-review",
            "time-preferences",
        ),
    }
    time_keys = (
        "conflicting",
        "dense",
        "editing",
        "empty",
        "external-hidden-capacity",
        "importing",
        "now-anchored",
        "populated",
        "previewing",
        "restored",
        "selected",
    )
    for suffix in ("DAY", "LIST", "MONTH", "WEEK", "YEAR"):
        variants[f"UX-SCREEN-TIME-{suffix}"] = time_keys
    variants.update(
        {
            "UX-SCREEN-GOALS-CLOSURE": (
                "completed", "ended", "needs-attention",
            ),
            "UX-SCREEN-GOALS-DETAIL": (
                "active", "archived", "blocked", "completed", "dense", "draft",
                "ended", "needs-attention", "paused", "ready-to-activate",
                "recovering", "waiting",
            ),
            "UX-SCREEN-GOALS-LIFE-AREA": (
                "dense", "empty-direction", "needs-attention", "populated",
            ),
            "UX-SCREEN-GOALS-PATH": (
                "active", "blocked", "completed", "dense", "draft",
                "needs-attention", "paused", "ready-to-activate", "recovering",
                "selected-node", "waiting",
            ),
            "UX-SCREEN-GOALS-RECOVERY": (
                "blocked", "needs-attention", "recovering", "waiting",
            ),
            "UX-SCREEN-GOALS-ROOT": (
                "dense", "empty-direction", "needs-attention", "populated",
            ),
        }
    )
    variants.update(
        {
            "UX-SCREEN-ACCOUNT-BOUNDARY": (
                "account-identity-only", "continuity-conflicted",
                "continuity-disabled", "continuity-enabled", "local-only",
            ),
            "UX-SCREEN-ACCOUNT-SIGN-IN": (
                "apple-in-progress", "cancelled", "failed", "google-in-progress",
                "provider-choice", "signed-in",
            ),
            "UX-SCREEN-ACCOUNT-STATUS": (
                "continuity-conflicted", "continuity-disabled", "continuity-pending",
                "entitlement-stale", "signed-in", "signed-out",
            ),
            "UX-SCREEN-APP-SHELL-DRILLDOWN": (
                "dismissed", "full-screen", "pushed", "restored", "sheet",
            ),
            "UX-SCREEN-APP-SHELL-ROOT": (
                "goals-selected", "time-selected", "today-selected", "you-selected",
            ),
            "UX-SCREEN-APP-SHELL-SEARCH-CAPTURE": (
                "capture-presented", "idle", "returning-focus", "search-presented",
            ),
            "UX-SCREEN-OFFLINE-DEGRADED-LOCAL-HEALTH": (
                "degraded-local-store", "local-healthy", "protected-data-unavailable",
                "stale-external-source", "storage-pressure",
            ),
            "UX-SCREEN-OFFLINE-DEGRADED-REPAIR": (
                "export-only", "repair-available", "repair-complete", "repair-failed",
                "repair-running",
            ),
            "UX-SCREEN-SETUP-FIRST-USE": (
                "complete", "local-ready", "optional-account", "permissions-choice",
                "welcome",
            ),
            "UX-SCREEN-SETUP-RESUME": (
                "checkpoint-found", "checkpoint-invalid", "resumed", "revalidating",
                "start-over",
            ),
            "UX-SCREEN-TIME-DETAIL": (
                "conflict-review", "editing", "saved", "undo-eligible",
                "undo-unavailable", "viewing",
            ),
            "UX-SCREEN-TODAY-DETAIL": (
                "active-execution", "closure-review", "recovery", "stale", "viewing",
            ),
        }
    )
    return variants


REQUIRED_STATE_VARIANTS = _required_state_variants()
PLACEHOLDER = re.compile(r"(?<!\w)(?:TBD|TODO|implement later)(?!\w)", re.IGNORECASE)
STALE_BLUEPRINT_LANGUAGE = re.compile(
    r"recommended next movement|capture history|\bno now\b|prior-current now",
    re.IGNORECASE,
)
STATE_VARIANT_NARRATIVE_FIELDS = (
    "visible_presentation",
    "visible_content_copy",
    "transition_exit",
    "durable_effect",
    "recovery_rollback",
    "offline_behavior",
    "accessibility_focus",
)
FORMULAIC_STATE_VARIANT_LANGUAGE = (
    "shows the exact current state, consequence, and available next action",
    "stable frameable",
    "uses verified local facts offline; unavailable external context",
    "returns to the exact owning",
    "current consequence, displayed objects, then actions",
    "remains non-durable until its separately confirmed command succeeds",
    "creates no durable effect",
    "without changing canonical data",
    "uses only its operation-specific recovery law",
    "consequence, consequence",
    "may produce the consequence declared",
    "canonical owner",
    "invoking object",
    "invoking context",
    "owner-specific Goal filter controls",
    "selected owner-specific Goal object",
    "compact native detail or full destination when depth requires",
)
FORMULAIC_STATE_VARIANT_PATTERNS = (
    re.compile(
        r"follows the declared owner for .+; .+ preserves or restores the invoking object",
        re.IGNORECASE,
    ),
    re.compile(r"no longer supports the declared condition", re.IGNORECASE),
    re.compile(
        r"any command needing external authority is unavailable with its reason",
        re.IGNORECASE,
    ),
    re.compile(
        r"Viewing .+ commits nothing; .+ is the explicit primary route",
        re.IGNORECASE,
    ),
)
NORMALIZED_NARRATIVE_SCREEN_IDS = frozenset(
    {
        "UX-SCREEN-ACCOUNT-BOUNDARY",
        "UX-SCREEN-ACCOUNT-SIGN-IN",
        "UX-SCREEN-ACCOUNT-STATUS",
        "UX-SCREEN-APP-SHELL-DRILLDOWN",
        "UX-SCREEN-APP-SHELL-ROOT",
        "UX-SCREEN-APP-SHELL-SEARCH-CAPTURE",
        "UX-SCREEN-GOALS-CLOSURE",
        "UX-SCREEN-GOALS-DETAIL",
        "UX-SCREEN-GOALS-LIFE-AREA",
        "UX-SCREEN-GOALS-PATH",
        "UX-SCREEN-GOALS-RECOVERY",
        "UX-SCREEN-GOALS-ROOT",
        "UX-SCREEN-OFFLINE-DEGRADED-LOCAL-HEALTH",
        "UX-SCREEN-OFFLINE-DEGRADED-REPAIR",
        "UX-SCREEN-SETUP-FIRST-USE",
        "UX-SCREEN-SETUP-RESUME",
        "UX-SCREEN-TIME-DETAIL",
        "UX-SCREEN-TODAY-DETAIL",
    }
)
COMPACT_COMMAND_CONTRACT_SCREEN_IDS = frozenset(
    NORMALIZED_NARRATIVE_SCREEN_IDS
    - {
        "UX-SCREEN-GOALS-CLOSURE",
        "UX-SCREEN-GOALS-DETAIL",
        "UX-SCREEN-GOALS-LIFE-AREA",
        "UX-SCREEN-GOALS-PATH",
        "UX-SCREEN-GOALS-RECOVERY",
        "UX-SCREEN-GOALS-ROOT",
    }
)
GOALS_COMMAND_CONTRACT_SCREEN_IDS = frozenset(
    NORMALIZED_NARRATIVE_SCREEN_IDS - COMPACT_COMMAND_CONTRACT_SCREEN_IDS
)

TOP_LEVEL_FIELDS = frozenset(
    {
        "schema_version",
        "blueprint_id",
        "title",
        "status",
        "authority_state",
        "canon_revision",
        "canon_content_sha",
        "source_sha",
        "source_documents",
        "primary_linear_v3",
        "requirement_dispositions",
        "legacy_figma_policy",
        "claim_ceiling",
        "screens",
        "state_models",
        "sensitive_exposure_channels",
        "object_boundaries",
        "journeys",
        "cross_cutting",
    }
)
SCREEN_FIELDS = frozenset(
    {
        "blueprint_id",
        "title",
        "scope",
        "purpose",
        "entry",
        "exit",
        "presentation",
        "objects",
        "state_model_id",
        "requirement_ids",
        "accessibility",
        "swiftui_anatomy",
        "implementation_status",
        "proof_ceiling",
    }
)
STATE_MODEL_FIELDS = frozenset(
    {
        "blueprint_id",
        "title",
        "screen_id",
        "taxonomy",
        "variants",
        "requirement_ids",
        "implementation_status",
        "proof_ceiling",
    }
)
STATE_TAXONOMY_FIELDS = frozenset(
    {"generic_kind", "applicability", "rationale", "variant_ids"}
)
SENSITIVE_EXPOSURE_FIELDS = frozenset(
    {
        "blueprint_id",
        "channel",
        "visible_fields",
        "defaults",
        "consent",
        "redaction",
        "retention",
        "protection",
        "user_control",
        "denial_behavior",
        "proof_behavior",
        "requirement_ids",
        "implementation_status",
        "proof_ceiling",
    }
)
STATE_VARIANT_FIELDS = frozenset(
    {
        "accessibility_focus",
        "allowed_commands",
        "blueprint_id",
        "displayed_objects",
        "durable_effect",
        "generic_kind",
        "implementation_status",
        "offline_behavior",
        "proof_ceiling",
        "recovery_rollback",
        "requirement_ids",
        "title",
        "transition_exit",
        "variant_key",
        "visible_content_copy",
        "visible_presentation",
    }
)
DISPOSITION_FIELDS = frozenset(
    {
        "blueprint_ids",
        "disposition",
        "rationale",
        "requirement_text_sha256",
        "requirement_id",
        "source_path",
        "state_blueprint_ids",
    }
)
SOURCE_DOCUMENT_FIELDS = frozenset({"path", "sha256"})
OBJECT_FIELDS = frozenset(
    {
        "blueprint_id",
        "object_id",
        "title",
        "presentation_boundaries",
        "create",
        "detail",
        "edit",
        "delete_restore",
        "history_inspection",
        "requirement_ids",
        "implementation_status",
        "proof_ceiling",
    }
)
JOURNEY_FIELDS = frozenset(
    {
        "blueprint_id",
        "title",
        "trigger",
        "preconditions",
        "happy_path",
        "branches",
        "cancellation",
        "interruption_resume",
        "commit_boundary",
        "failure",
        "recovery",
        "rollback",
        "offline",
        "accessibility",
        "tests",
        "requirement_ids",
        "implementation_status",
        "proof_ceiling",
    }
)
CROSS_CUTTING_FIELDS = frozenset(
    {
        "blueprint_id",
        "facet",
        "title",
        "contract",
        "variants",
        "requirement_ids",
        "implementation_status",
        "proof_ceiling",
    }
)


class UXBlueprintError(ValueError):
    """A deterministic blueprint-contract failure."""


@dataclass(frozen=True, slots=True)
class UXBlueprintSummary:
    screen_count: int
    state_model_count: int
    state_taxonomy_count: int
    state_variant_count: int
    object_boundary_count: int
    journey_count: int
    cross_cutting_count: int
    requirement_link_count: int
    scope_ids: tuple[str, ...]
    state_kinds: tuple[str, ...]
    accessibility_facets: tuple[str, ...]
    object_ids: tuple[str, ...]
    disposition_count: int
    visual_mapping_count: int
    nonvisual_count: int
    disposition_sha256: str


def load_ux_blueprint(root: Path) -> dict[str, object]:
    path = root / BLUEPRINT_PATH
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise UXBlueprintError(f"cannot load UX blueprint: {error}") from error
    if not isinstance(payload, dict):
        raise UXBlueprintError("UX blueprint root must be an object")
    return payload


def _object(value: object, label: str) -> dict[str, object]:
    if not isinstance(value, dict):
        raise UXBlueprintError(f"{label} must be an object")
    return value


def _records(value: object, label: str) -> list[dict[str, object]]:
    if not isinstance(value, list) or not value:
        raise UXBlueprintError(f"{label} must be a non-empty array")
    result: list[dict[str, object]] = []
    for index, item in enumerate(value):
        result.append(_object(item, f"{label}[{index}]"))
    return result


def _string(value: object, label: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise UXBlueprintError(f"{label} must be a non-empty string")
    return value


def _strings(value: object, label: str, *, sorted_unique: bool = False) -> tuple[str, ...]:
    if not isinstance(value, list) or not value:
        raise UXBlueprintError(f"{label} must be a non-empty string array")
    items = tuple(_string(item, label) for item in value)
    if sorted_unique and items != tuple(sorted(set(items))):
        raise UXBlueprintError(f"{label} must be sorted and unique")
    return items


def _possibly_empty_strings(
    value: object, label: str, *, sorted_unique: bool = False
) -> tuple[str, ...]:
    if not isinstance(value, list):
        raise UXBlueprintError(f"{label} must be a string array")
    items = tuple(_string(item, label) for item in value)
    if sorted_unique and items != tuple(sorted(set(items))):
        raise UXBlueprintError(f"{label} must be sorted and unique")
    return items


def _linked_ids(value: object, label: str) -> tuple[str, ...]:
    items = _strings(value, label)
    if len(items) != len(set(items)):
        raise UXBlueprintError(f"{label} must be unique")
    return items


def _closed(record: Mapping[str, object], expected: frozenset[str], label: str) -> None:
    fields = frozenset(record)
    if fields != expected:
        missing = sorted(expected - fields)
        extra = sorted(fields - expected)
        raise UXBlueprintError(
            f"{label} fields are closed; missing={missing} extra={extra}"
        )


def _sorted_unique_records(records: Iterable[Mapping[str, object]], label: str) -> tuple[str, ...]:
    identifiers = tuple(_string(item.get("blueprint_id"), f"{label}.blueprint_id") for item in records)
    if len(identifiers) != len(set(identifiers)):
        raise UXBlueprintError(f"duplicate blueprint ID in {label}")
    if identifiers != tuple(sorted(identifiers)):
        raise UXBlueprintError(f"{label} must be sorted by blueprint_id")
    return identifiers


def _walk_strings(value: object) -> Iterable[str]:
    if isinstance(value, str):
        yield value
    elif isinstance(value, dict):
        for child in value.values():
            yield from _walk_strings(child)
    elif isinstance(value, list):
        for child in value:
            yield from _walk_strings(child)


def source_path_digest(path: Path) -> str:
    """Hash a declared file or directory with stable relative-path framing."""

    if path.is_file():
        return hashlib.sha256(path.read_bytes()).hexdigest()
    if not path.is_dir():
        raise UXBlueprintError(f"source document does not exist: {path}")
    digest = hashlib.sha256()
    files = sorted(
        candidate
        for candidate in path.rglob("*")
        if candidate.is_file() and "__pycache__" not in candidate.parts
    )
    if not files:
        raise UXBlueprintError(f"source document directory is empty: {path}")
    for candidate in files:
        relative = candidate.relative_to(path).as_posix().encode("utf-8")
        digest.update(len(relative).to_bytes(8, "big"))
        digest.update(relative)
        content = candidate.read_bytes()
        digest.update(len(content).to_bytes(8, "big"))
        digest.update(content)
    return digest.hexdigest()


def validate_source_documents(
    root: Path, records: object
) -> tuple[tuple[str, str], ...]:
    source_records = _records(records, "source documents")
    normalized: list[tuple[str, str]] = []
    for record in source_records:
        _closed(record, SOURCE_DOCUMENT_FIELDS, "source document fields")
        relative = _string(record.get("path"), "source document path")
        declared = _string(record.get("sha256"), "source document digest")
        relative_path = Path(relative)
        if relative_path.is_absolute() or ".." in relative_path.parts:
            raise UXBlueprintError(f"source document path is unsafe: {relative}")
        if not re.fullmatch(r"[0-9a-f]{64}", declared):
            raise UXBlueprintError(f"source document digest is invalid: {relative}")
        actual = source_path_digest(root / relative_path)
        if actual != declared:
            raise UXBlueprintError(
                f"source content digest is stale for {relative}: "
                f"declared={declared} actual={actual}"
            )
        normalized.append((relative, declared))
    if normalized != sorted(set(normalized)):
        raise UXBlueprintError("source documents must be sorted and unique by path")
    return tuple(normalized)


def _validate_source_sha(
    root: Path, source_sha: object, source_paths: tuple[str, ...]
) -> str:
    sha = _string(source_sha, "source SHA")
    if not re.fullmatch(r"[0-9a-f]{40}", sha):
        raise UXBlueprintError("source SHA must be a full Git commit SHA")
    result = subprocess.run(
        ["git", "merge-base", "--is-ancestor", sha, "HEAD"],
        cwd=root,
        capture_output=True,
        check=False,
        text=True,
    )
    if result.returncode != 0:
        raise UXBlueprintError("source SHA is not an ancestor of current Git HEAD")
    freshness = subprocess.run(
        ["git", "diff", "--quiet", sha, "--", *source_paths],
        cwd=root,
        capture_output=True,
        check=False,
        text=True,
    )
    if freshness.returncode != 0:
        raise UXBlueprintError("source SHA is stale for declared source content")
    return sha


def _record_posture(record: Mapping[str, object], label: str) -> None:
    if record.get("implementation_status") != "design_input_only":
        raise UXBlueprintError(f"{label} implementation posture must remain design input only")
    if record.get("proof_ceiling") != RECORD_PROOF_CEILING:
        raise UXBlueprintError(f"{label} record proof ceiling exceeds design-input scope")


def _requirement_ids(root: Path) -> tuple[frozenset[str], str, int, str]:
    graph_path = root / REQUIREMENT_GRAPH_PATH
    try:
        graph = json.loads(graph_path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise UXBlueprintError(f"cannot load requirement graph: {error}") from error
    graph = _object(graph, "requirement graph")
    ids = _strings(graph.get("requirement_ids"), "requirement graph IDs", sorted_unique=True)
    return (
        frozenset(ids),
        _string(graph.get("canon_content_sha"), "canon content SHA"),
        int(graph.get("canon_revision", 0)),
        _string(graph.get("authority_state"), "canon authority state"),
    )


def _requirement_records(root: Path) -> tuple[dict[str, object], ...]:
    path = root / CANON_INDEX_PATH
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise UXBlueprintError(f"cannot load canon index: {error}") from error
    payload = _object(payload, "canon index")
    records = _records(payload.get("requirements"), "canon index requirements")
    return tuple(records)


def _consequence_anchor(body: str) -> str:
    """Return a stable, requirement-specific anchor from the normative body."""

    paragraphs = [
        " ".join(paragraph.split())
        for paragraph in body.split("\n\n")
        if paragraph.strip()
    ]
    if not paragraphs:
        raise UXBlueprintError("requirement body has no normative paragraph")
    return paragraphs[0]


def normalized_state_narrative_signature(
    text: str,
    screen_title: str,
    variant: Mapping[str, object],
) -> str:
    """Remove record tokens so prose interpolation cannot masquerade as authorship."""

    replacements = [(screen_title, "<screen>"), (_string(variant.get("title"), "variant title"), "<state>")]
    replacements.extend(
        (value, "<object>")
        for value in _possibly_empty_strings(
            variant.get("displayed_objects"), "signature displayed objects"
        )
    )
    replacements.extend(
        (value, "<command>")
        for value in _possibly_empty_strings(
            variant.get("allowed_commands"), "signature allowed commands"
        )
    )
    signature = text.casefold()
    for value, replacement in sorted(
        replacements, key=lambda item: len(item[0]), reverse=True
    ):
        signature = re.sub(re.escape(value.casefold()), replacement, signature)
    return " ".join(signature.split())


def load_requirement_source_records(root: Path) -> tuple[dict[str, str], ...]:
    """Load exact normative requirement text from the human-editable canon."""

    index = _requirement_records(root)
    paths = sorted({_string(item.get("source_path"), "source path") for item in index})
    parsed = {}
    for relative in paths:
        path = root / relative
        document = parse_canon_document(path, path.read_text(encoding="utf-8"))
        for requirement in document.requirements:
            parsed[requirement.requirement_id] = requirement
    records = []
    for item in index:
        requirement_id = _string(item.get("requirement_id"), "requirement ID")
        requirement = parsed.get(requirement_id)
        if requirement is None:
            raise UXBlueprintError(
                f"requirement source text is missing: {requirement_id}"
            )
        records.append(
            {
                "requirement_id": requirement_id,
                "source_path": requirement.source_path.relative_to(root).as_posix(),
                "normative_text": requirement.body,
                "consequence_anchor": _consequence_anchor(requirement.body),
            }
        )
    return tuple(records)


def build_requirement_dispositions(
    root: Path,
    blueprint: Mapping[str, object],
    known_blueprint_ids: frozenset[str],
) -> tuple[dict[str, object], ...]:
    """Validate the checked-in per-requirement semantic disposition ledger."""

    requirements = {
        item["requirement_id"]: item
        for item in load_requirement_source_records(root)
    }
    records = _records(
        blueprint.get("requirement_dispositions"), "requirement dispositions"
    )
    top_level_records = tuple(
        item
        for key in (
            "screens",
            "state_models",
            "object_boundaries",
            "journeys",
            "cross_cutting",
            "sensitive_exposure_channels",
        )
        for item in blueprint[key]
    )
    state_variants = tuple(
        variant
        for model in blueprint["state_models"]
        for variant in model["variants"]
    )
    top_level_ids = frozenset(item["blueprint_id"] for item in top_level_records)
    state_ids = frozenset(item["blueprint_id"] for item in state_variants)
    top_edges = {
        (requirement_id, item["blueprint_id"])
        for item in top_level_records
        for requirement_id in item["requirement_ids"]
    }
    state_edges = {
        (requirement_id, item["blueprint_id"])
        for item in state_variants
        for requirement_id in item["requirement_ids"]
    }
    identifiers: list[str] = []
    dispositions: list[dict[str, object]] = []
    for item in records:
        _closed(item, DISPOSITION_FIELDS, "requirement disposition fields")
        requirement_id = _string(item.get("requirement_id"), "disposition requirement ID")
        source_path = _string(item.get("source_path"), "disposition source path")
        disposition = _string(item.get("disposition"), "requirement disposition")
        rationale = _string(item.get("rationale"), "requirement rationale")
        requirement_text_sha256 = _string(
            item.get("requirement_text_sha256"), "requirement text digest"
        )
        if len(rationale.split()) < 8:
            raise UXBlueprintError(
                f"requirement rationale is not reviewable: {requirement_id}"
            )
        if re.search(r"[,;:]\.", rationale):
            raise UXBlueprintError(
                f"requirement rationale punctuation is malformed: {requirement_id}"
            )
        if rationale[-1] not in ".!?":
            raise UXBlueprintError(
                f"requirement rationale is incomplete: {requirement_id}"
            )
        identifiers.append(requirement_id)
        requirement = requirements.get(requirement_id)
        if requirement is None:
            raise UXBlueprintError(f"unknown requirement disposition: {requirement_id}")
        expected_source = requirement["source_path"]
        if source_path != expected_source:
            raise UXBlueprintError(
                f"requirement disposition source mismatch: {requirement_id}"
            )
        expected_digest = hashlib.sha256(
            requirement["normative_text"].encode("utf-8")
        ).hexdigest()
        if requirement_text_sha256 != expected_digest:
            raise UXBlueprintError(
                f"requirement text digest is stale: {requirement_id}"
            )
        if "These records alone present the" in rationale:
            raise UXBlueprintError(
                f"formulaic rationale is forbidden: {requirement_id}"
            )
        if requirement["consequence_anchor"] not in rationale:
            raise UXBlueprintError(
                f"requirement rationale omits its specific consequence: {requirement_id}"
            )
        blueprint_ids_value = item.get("blueprint_ids")
        if not isinstance(blueprint_ids_value, list):
            raise UXBlueprintError(
                f"requirement disposition blueprint IDs must be an array: {requirement_id}"
            )
        blueprint_ids = tuple(
            _string(value, "disposition blueprint ID") for value in blueprint_ids_value
        )
        state_blueprint_ids_value = item.get("state_blueprint_ids")
        if not isinstance(state_blueprint_ids_value, list):
            raise UXBlueprintError(
                f"requirement disposition state blueprint IDs must be an array: {requirement_id}"
            )
        state_blueprint_ids = tuple(
            _string(value, "disposition state blueprint ID")
            for value in state_blueprint_ids_value
        )
        if blueprint_ids != tuple(sorted(set(blueprint_ids))):
            raise UXBlueprintError(
                f"requirement disposition blueprint IDs must be sorted and unique: {requirement_id}"
            )
        if state_blueprint_ids != tuple(sorted(set(state_blueprint_ids))):
            raise UXBlueprintError(
                f"requirement disposition state blueprint IDs must be sorted and unique: {requirement_id}"
            )
        if set(blueprint_ids) - top_level_ids:
            raise UXBlueprintError(
                f"disposition blueprint IDs must name top-level records: {requirement_id}"
            )
        if set(state_blueprint_ids) - state_ids:
            raise UXBlueprintError(
                f"disposition state blueprint IDs must name state records: {requirement_id}"
            )
        unknown = sorted(set(blueprint_ids) - known_blueprint_ids)
        if unknown:
            raise UXBlueprintError(
                f"requirement disposition references unknown blueprint IDs: {unknown}"
            )
        if disposition == "visual_mapping_required":
            if not blueprint_ids and not state_blueprint_ids:
                raise UXBlueprintError(
                    f"visual requirement has no applicable blueprint record: {requirement_id}"
                )
        elif disposition == "nonvisual_with_rationale":
            if blueprint_ids or state_blueprint_ids:
                raise UXBlueprintError(
                    f"nonvisual requirement must not map blueprint records: {requirement_id}"
                )
        else:
            raise UXBlueprintError(
                f"requirement disposition is not a closed value: {requirement_id}"
            )
        dispositions.append(dict(item))
    if identifiers != sorted(identifiers):
        raise UXBlueprintError("requirement dispositions must be sorted by requirement_id")
    if len(identifiers) != len(set(identifiers)):
        raise UXBlueprintError("duplicate requirement disposition ID")
    missing = sorted(set(requirements) - set(identifiers))
    if missing:
        raise UXBlueprintError(f"missing requirement disposition: {missing}")
    if len(identifiers) != len(requirements):
        raise UXBlueprintError("requirement disposition count is incomplete")
    disposition_by_id = {item["requirement_id"]: item for item in dispositions}
    for requirement_id in sorted(SEMANTIC_NONVISUAL_SENTINELS):
        item = disposition_by_id[requirement_id]
        if (
            item["disposition"] != "nonvisual_with_rationale"
            or item["blueprint_ids"]
            or item["state_blueprint_ids"]
        ):
            raise UXBlueprintError(
                f"semantic disposition sentinel is inverted: {requirement_id}"
            )
    for requirement_id, expected_targets in sorted(
        SEMANTIC_VISUAL_SENTINELS.items()
    ):
        item = disposition_by_id[requirement_id]
        if (
            item["disposition"] != "visual_mapping_required"
            or tuple(item["blueprint_ids"]) != expected_targets
        ):
            raise UXBlueprintError(
                f"semantic disposition sentinel is stale: {requirement_id}"
            )
    for requirement_id, blueprint_id in sorted(top_edges):
        item = disposition_by_id[requirement_id]
        if blueprint_id not in item["blueprint_ids"]:
            raise UXBlueprintError(
                f"disposition edge is missing for {requirement_id} -> {blueprint_id}"
            )
    for requirement_id, blueprint_id in sorted(state_edges):
        item = disposition_by_id[requirement_id]
        if blueprint_id not in item["state_blueprint_ids"]:
            raise UXBlueprintError(
                f"state disposition edge is missing for {requirement_id} -> {blueprint_id}"
            )
    for item in dispositions:
        requirement_id = item["requirement_id"]
        for blueprint_id in item["blueprint_ids"]:
            if (requirement_id, blueprint_id) not in top_edges:
                raise UXBlueprintError(
                    f"disposition edge has no record declaration: "
                    f"{requirement_id} -> {blueprint_id}"
                )
        for blueprint_id in item["state_blueprint_ids"]:
            if (requirement_id, blueprint_id) not in state_edges:
                raise UXBlueprintError(
                    f"state disposition edge has no record declaration: "
                    f"{requirement_id} -> {blueprint_id}"
                )
    return tuple(dispositions)


def _disposition_bytes(dispositions: tuple[dict[str, object], ...]) -> bytes:
    return (
        json.dumps(dispositions, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
        + "\n"
    ).encode("utf-8")


def render_requirement_dispositions(
    root: Path, blueprint: Mapping[str, object]
) -> bytes:
    record_groups = (
        blueprint["screens"],
        blueprint["state_models"],
        blueprint["object_boundaries"],
        blueprint["journeys"],
        blueprint["cross_cutting"],
        blueprint["sensitive_exposure_channels"],
    )
    all_ids = frozenset(item["blueprint_id"] for group in record_groups for item in group)
    dispositions = build_requirement_dispositions(root, blueprint, all_ids)
    disposition_bytes = _disposition_bytes(dispositions)
    visual_count = sum(
        item["disposition"] == "visual_mapping_required" for item in dispositions
    )
    payload = {
        "schema_version": 1,
        "blueprint_id": blueprint["blueprint_id"],
        "authority_state": blueprint["authority_state"],
        "canon_revision": blueprint["canon_revision"],
        "canon_content_sha": blueprint["canon_content_sha"],
        "source_sha": blueprint["source_sha"],
        "requirement_count": len(dispositions),
        "visual_mapping_count": visual_count,
        "nonvisual_count": len(dispositions) - visual_count,
        "disposition_sha256": hashlib.sha256(disposition_bytes).hexdigest(),
        "dispositions": list(dispositions),
        "claim_ceiling": blueprint["claim_ceiling"],
    }
    return (json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n").encode(
        "utf-8"
    )


def validate_ux_blueprint(root: Path, blueprint: Mapping[str, object]) -> UXBlueprintSummary:
    _closed(blueprint, TOP_LEVEL_FIELDS, "top-level fields")
    if blueprint.get("schema_version") != 1:
        raise UXBlueprintError("schema_version must be 1")
    if (
        blueprint.get("blueprint_id") != BLUEPRINT_ID
        or blueprint.get("title") != BLUEPRINT_TITLE
    ):
        raise UXBlueprintError("blueprint identity must match the approved ID and title")
    if blueprint.get("status") != "design_input_non_authoritative":
        raise UXBlueprintError("blueprint status must remain non-authoritative")
    if blueprint.get("authority_state") != "shadow":
        raise UXBlueprintError("blueprint and canon must remain shadow")
    if blueprint.get("claim_ceiling") != CLAIM_CEILING:
        raise UXBlueprintError("claim ceiling exceeds the approved design-input scope")
    source_documents = validate_source_documents(
        root, blueprint.get("source_documents")
    )
    _validate_source_sha(
        root,
        blueprint.get("source_sha"),
        tuple(path for path, _digest in source_documents),
    )

    known_requirements, canon_sha, canon_revision, authority_state = _requirement_ids(root)
    if blueprint.get("canon_content_sha") != canon_sha:
        raise UXBlueprintError("canon content SHA is stale")
    if blueprint.get("canon_revision") != canon_revision:
        raise UXBlueprintError("canon revision is stale")
    if authority_state != "shadow":
        raise UXBlueprintError("requirement graph authority must remain shadow")

    linear = _object(blueprint.get("primary_linear_v3"), "primary Linear V3")
    if set(linear) != {"document_id", "title", "disposition"}:
        raise UXBlueprintError("primary Linear V3 fields are closed")
    if (
        linear.get("document_id") != PRIMARY_LINEAR_V3_ID
        or linear.get("title") != PRIMARY_LINEAR_V3_TITLE
        or linear.get("disposition") != "migration_corpus_unchanged"
    ):
        raise UXBlueprintError("primary Linear V3 must remain unchanged migration corpus")

    legacy = _object(blueprint.get("legacy_figma_policy"), "legacy Figma policy")
    if set(legacy) != {"rejected_as_final_target", "allowed_roles", "destructive_actions"}:
        raise UXBlueprintError("legacy Figma policy fields are closed")
    roles = _strings(legacy.get("allowed_roles"), "legacy Figma roles", sorted_unique=True)
    if (
        legacy.get("rejected_as_final_target") is not True
        or roles != LEGACY_FIGMA_ROLES
        or legacy.get("destructive_actions") != "withheld_gate_c"
    ):
        raise UXBlueprintError("legacy Figma cannot be treated as final authority")

    for text in _walk_strings(blueprint):
        if PLACEHOLDER.search(text):
            raise UXBlueprintError(f"placeholder language is forbidden: {text!r}")
        if STALE_BLUEPRINT_LANGUAGE.search(text):
            raise UXBlueprintError(f"stale vocabulary is forbidden: {text!r}")

    screens = _records(blueprint.get("screens"), "screens")
    states = _records(blueprint.get("state_models"), "state models")
    objects = _records(blueprint.get("object_boundaries"), "object boundaries")
    journeys = _records(blueprint.get("journeys"), "journeys")
    cross = _records(blueprint.get("cross_cutting"), "cross-cutting records")
    exposure_channels = _records(
        blueprint.get("sensitive_exposure_channels"),
        "sensitive exposure channels",
    )
    preliminary_ids = [
        _string(item.get("blueprint_id"), "blueprint ID")
        for records in (screens, states, objects, journeys, cross, exposure_channels)
        for item in records
    ]
    if len(preliminary_ids) != len(set(preliminary_ids)):
        raise UXBlueprintError("blueprint IDs must be globally unique typed IDs")
    for state_model in states:
        screen_id = _string(state_model.get("screen_id"), "state model screen_id")
        expected_model_id = (
            "UX-STATE-MODEL-" + screen_id.removeprefix("UX-SCREEN-")
        )
        if state_model.get("blueprint_id") != expected_model_id:
            raise UXBlueprintError(
                f"state model identity does not match screen owner: {screen_id}"
            )
    screen_ids = _sorted_unique_records(screens, "screens")
    state_model_ids = _sorted_unique_records(states, "state models")
    object_blueprint_ids = _sorted_unique_records(objects, "object boundaries")
    journey_ids = _sorted_unique_records(journeys, "journeys")
    cross_ids = _sorted_unique_records(cross, "cross-cutting records")

    linked_requirements: list[str] = []
    scopes: set[str] = set()
    referenced_state_models: set[str] = set()
    accessibility_contracts: set[tuple[str, ...]] = set()
    for screen in screens:
        _closed(screen, SCREEN_FIELDS, "screen fields")
        _record_posture(screen, "screen")
        scopes.add(_string(screen.get("scope"), "screen scope"))
        state_id = _string(screen.get("state_model_id"), "screen state model")
        if state_id not in state_model_ids:
            raise UXBlueprintError(f"screen references unknown state model: {state_id}")
        referenced_state_models.add(state_id)
        screen_objects = _strings(screen.get("objects"), "screen objects")
        if len(screen_objects) != len(set(screen_objects)):
            raise UXBlueprintError("screen objects must be unique")
        screen_accessibility = _strings(screen.get("accessibility"), "screen accessibility")
        if len(screen_accessibility) != len(set(screen_accessibility)):
            raise UXBlueprintError("screen accessibility entries must be unique")
        accessibility_contracts.add(screen_accessibility)
        linked_requirements.extend(
            _linked_ids(screen.get("requirement_ids"), "screen requirement IDs")
        )
    if scopes != REQUIRED_SCOPES:
        raise UXBlueprintError(f"screen scopes are incomplete or invented: {sorted(scopes)}")
    if referenced_state_models != set(state_model_ids):
        raise UXBlueprintError("every state model must be used by at least one screen")
    if len(accessibility_contracts) < 35:
        raise UXBlueprintError("screen accessibility contracts must be screen-specific")

    covered_screens: set[str] = set()
    state_kinds: set[str] = set()
    state_variant_ids: list[str] = []
    state_taxonomy_count = 0
    state_variant_count = 0
    screen_titles = {
        item["blueprint_id"]: item["title"]
        for item in screens
    }
    variant_narratives: dict[str, set[str]] = {
        field: set() for field in STATE_VARIANT_NARRATIVE_FIELDS
    }
    normalized_narratives: dict[str, dict[str, str]] = {
        field: {} for field in STATE_VARIANT_NARRATIVE_FIELDS
    }
    for state_model in states:
        _closed(state_model, STATE_MODEL_FIELDS, "state model fields")
        _record_posture(state_model, "state model")
        screen_id = _string(state_model.get("screen_id"), "state model screen_id")
        if screen_id not in screen_ids:
            raise UXBlueprintError(f"state model references unknown screen: {screen_id}")
        if screen_id in covered_screens:
            raise UXBlueprintError(f"screen has more than one state model: {screen_id}")
        covered_screens.add(screen_id)
        expected_model_id = (
            "UX-STATE-MODEL-" + screen_id.removeprefix("UX-SCREEN-")
        )
        if state_model.get("blueprint_id") != expected_model_id:
            raise UXBlueprintError(
                f"state model identity does not match screen owner: {screen_id}"
            )
        variant_value = state_model.get("variants")
        if not isinstance(variant_value, list):
            raise UXBlueprintError("state variants must be an array")
        variant_records = [
            _object(item, f"state variants[{index}]")
            for index, item in enumerate(variant_value)
        ]
        expected_variant_keys = REQUIRED_STATE_VARIANTS.get(screen_id, ())
        actual_variant_keys = tuple(
            _string(item.get("variant_key"), "state variant key")
            for item in variant_records
        )
        if actual_variant_keys != expected_variant_keys:
            raise UXBlueprintError(
                f"state variant inventory is incomplete or invented: {screen_id}"
            )
        for variant in variant_records:
            _closed(variant, STATE_VARIANT_FIELDS, "state variant fields")
            _record_posture(variant, "state variant")
            variant_key = _string(variant.get("variant_key"), "state variant key")
            generic_kind = _string(
                variant.get("generic_kind"), "state variant generic kind"
            )
            if generic_kind not in REQUIRED_STATE_KINDS:
                raise UXBlueprintError(
                    f"state variant generic kind is invalid: {variant_key}"
                )
            state_kinds.add(generic_kind)
            expected_variant_id = (
                f"UX-STATE-VARIANT-{screen_id.removeprefix('UX-SCREEN-')}-"
                f"{variant_key.upper()}"
            )
            variant_id = _string(
                variant.get("blueprint_id"), "state variant blueprint ID"
            )
            if variant_id != expected_variant_id:
                raise UXBlueprintError(
                    f"state variant identity does not match owner and key: {variant_id}"
                )
            state_variant_ids.append(variant_id)
            for field in (
                "title",
                "visible_presentation",
                "visible_content_copy",
                "transition_exit",
                "durable_effect",
                "recovery_rollback",
                "offline_behavior",
                "accessibility_focus",
            ):
                value = variant.get(field)
                if (
                    variant_id == "UX-STATE-VARIANT-TRUST-INLINE-NO-DISCLOSURE"
                    and field == "visible_content_copy"
                    and value == ""
                ):
                    text = ""
                else:
                    text = _string(value, f"state variant {field}")
                if field in variant_narratives:
                    folded = text.casefold()
                    if any(
                        formula.casefold() in folded
                        for formula in FORMULAIC_STATE_VARIANT_LANGUAGE
                    ) or any(
                        pattern.search(text)
                        for pattern in FORMULAIC_STATE_VARIANT_PATTERNS
                    ):
                        raise UXBlueprintError(
                            f"formulaic state variant narrative: {variant_id} {field}"
                        )
                    if text in variant_narratives[field]:
                        raise UXBlueprintError(
                            f"state variant narrative must be unique: {field}"
                        )
                    variant_narratives[field].add(text)
                    if screen_id in NORMALIZED_NARRATIVE_SCREEN_IDS:
                        signature = normalized_state_narrative_signature(
                            text, screen_titles[screen_id], variant
                        )
                        prior = normalized_narratives[field].get(signature)
                        if prior is not None:
                            raise UXBlueprintError(
                                "normalized narrative skeleton is repeated: "
                                f"{field} {prior} {variant_id}"
                            )
                        normalized_narratives[field][signature] = variant_id
            displayed_objects = _possibly_empty_strings(
                variant.get("displayed_objects"),
                "state variant displayed objects",
            )
            allowed_commands = _possibly_empty_strings(
                variant.get("allowed_commands"),
                "state variant allowed commands",
            )
            if variant_id == "UX-STATE-VARIANT-TRUST-INLINE-NO-DISCLOSURE":
                if displayed_objects or allowed_commands or variant.get(
                    "visible_content_copy"
                ) != "":
                    raise UXBlueprintError(
                        "no-disclosure variant must render no trust object, copy, or command"
                    )
            elif not displayed_objects or not allowed_commands:
                raise UXBlueprintError(
                    f"state variant requires exact objects and commands: {variant_id}"
                )
            invoking_feature_allowed = {
                "UX-STATE-VARIANT-PERMISSIONS-CALENDAR-ELIGIBILITY-CHECK",
                "UX-STATE-VARIANT-PERMISSIONS-NOTIFICATIONS-ELIGIBILITY-CHECK",
            }
            serialized_variant = json.dumps(variant, ensure_ascii=False).casefold()
            if (
                "invoking feature" in serialized_variant
                and variant_id not in invoking_feature_allowed
            ):
                raise UXBlueprintError(
                    f"state variant leaves invoking feature unresolved: {variant_id}"
                )
            if screen_id in (
                COMPACT_COMMAND_CONTRACT_SCREEN_IDS
                | GOALS_COMMAND_CONTRACT_SCREEN_IDS
            ):
                lines = tuple(
                    line for line in variant["transition_exit"].splitlines() if line
                )
                expected_commands = (
                    allowed_commands
                    if screen_id in GOALS_COMMAND_CONTRACT_SCREEN_IDS
                    else allowed_commands
                )
                if len(lines) != len(expected_commands):
                    raise UXBlueprintError(
                        f"command transition inventory is incomplete: {variant_id}"
                    )
                actual_commands = []
                for line in lines:
                    match = re.fullmatch(
                        r"(.+?) => destination: (.+); effect: (.+); focus: (.+)\.",
                        line,
                    )
                    if match is None or " or " in line.casefold():
                        raise UXBlueprintError(
                            f"command transition is not exact: {variant_id}"
                        )
                    command, _destination, effect, _focus = match.groups()
                    actual_commands.append(command)
                    if command.startswith(
                        ("Cancel", "Keep ", "Not Now", "Back", "Close", "Done", "Return ")
                    ) and "preserves" not in effect.casefold():
                        raise UXBlueprintError(
                            f"no-op command does not preserve state: {variant_id} {command}"
                        )
                if tuple(actual_commands) != expected_commands:
                    raise UXBlueprintError(
                        f"command transition set contradicts commands: {variant_id}"
                    )
            linked_variant_requirements = _linked_ids(
                variant.get("requirement_ids"),
                "state variant requirement IDs",
            )
            missing_state_laws = STATE_LAWS[generic_kind] - set(
                linked_variant_requirements
            )
            if missing_state_laws:
                raise UXBlueprintError(
                    "state variant omits required law: "
                    f"{variant_key} -> {sorted(missing_state_laws)}"
                )
            linked_requirements.extend(linked_variant_requirements)
            state_variant_count += 1
        taxonomy_records = _records(
            state_model.get("taxonomy"), "state taxonomy dispositions"
        )
        if len(taxonomy_records) != len(REQUIRED_STATE_KINDS):
            raise UXBlueprintError(
                "each screen requires nine compact taxonomy dispositions"
            )
        variants_by_kind: dict[str, list[str]] = {
            kind: [] for kind in REQUIRED_STATE_KINDS
        }
        for variant in variant_records:
            variants_by_kind[variant["generic_kind"]].append(variant["blueprint_id"])
        taxonomy_kinds: list[str] = []
        for taxonomy in taxonomy_records:
            _closed(taxonomy, STATE_TAXONOMY_FIELDS, "state taxonomy fields")
            kind = _string(taxonomy.get("generic_kind"), "taxonomy generic kind")
            taxonomy_kinds.append(kind)
            if kind not in REQUIRED_STATE_KINDS:
                raise UXBlueprintError(f"unknown taxonomy kind: {kind}")
            applicability = _string(
                taxonomy.get("applicability"), "taxonomy applicability"
            )
            if applicability not in {"applicable", "not_applicable"}:
                raise UXBlueprintError(
                    f"taxonomy applicability is not closed: {screen_id} {kind}"
                )
            rationale = _string(taxonomy.get("rationale"), "taxonomy rationale")
            if len(rationale.split()) < 8:
                raise UXBlueprintError(
                    f"taxonomy rationale is not grounded: {screen_id} {kind}"
                )
            variant_ids = _possibly_empty_strings(
                taxonomy.get("variant_ids"), "taxonomy variant IDs"
            )
            expected_ids = tuple(sorted(variants_by_kind[kind]))
            if variant_ids != expected_ids:
                raise UXBlueprintError(
                    f"taxonomy variant disposition is stale: {screen_id} {kind}"
                )
            expected_applicability = "applicable" if expected_ids else "not_applicable"
            if applicability != expected_applicability:
                raise UXBlueprintError(
                    f"taxonomy applicability contradicts named states: {screen_id} {kind}"
                )
            state_taxonomy_count += 1
        if tuple(taxonomy_kinds) != tuple(sorted(REQUIRED_STATE_KINDS)):
            raise UXBlueprintError(
                f"state taxonomy must be sorted and complete: {screen_id}"
            )
        linked_requirements.extend(
            _linked_ids(
                state_model.get("requirement_ids"), "state model requirement IDs"
            )
        )
    if covered_screens != set(screen_ids):
        raise UXBlueprintError("every screen must be covered by a complete state model")
    if state_variant_count != sum(len(keys) for keys in REQUIRED_STATE_VARIANTS.values()):
        raise UXBlueprintError("state variant inventory count is stale")

    object_ids: set[str] = set()
    for item in objects:
        _closed(item, OBJECT_FIELDS, "object boundary fields")
        _record_posture(item, "object boundary")
        object_ids.add(_string(item.get("object_id"), "object_id"))
        linked_requirements.extend(
            _linked_ids(item.get("requirement_ids"), "object requirement IDs")
        )
    if object_ids != REQUIRED_OBJECT_IDS:
        raise UXBlueprintError("canonical object boundaries are incomplete or invented")

    for journey in journeys:
        _closed(journey, JOURNEY_FIELDS, "journey fields")
        _record_posture(journey, "journey")
        _strings(journey.get("preconditions"), "journey preconditions")
        _strings(journey.get("happy_path"), "journey happy path")
        _strings(journey.get("branches"), "journey branches")
        _strings(journey.get("tests"), "journey tests")
        linked_requirements.extend(
            _linked_ids(journey.get("requirement_ids"), "journey requirement IDs")
        )

    facets: set[str] = set()
    for item in cross:
        _closed(item, CROSS_CUTTING_FIELDS, "cross-cutting fields")
        _record_posture(item, "cross-cutting")
        facets.add(_string(item.get("facet"), "cross-cutting facet"))
        _strings(item.get("variants"), "cross-cutting variants", sorted_unique=True)
        linked_requirements.extend(
            _linked_ids(item.get("requirement_ids"), "cross-cutting requirement IDs")
        )
    if facets != REQUIRED_FACETS:
        raise UXBlueprintError("cross-cutting facet inventory is incomplete or invented")

    required_channels = {
        "app-switcher",
        "notifications",
        "widgets",
        "spotlight",
        "clipboard",
        "capture",
        "diagnostics",
        "support",
        "export",
    }
    channel_names: set[str] = set()
    exposure_ids: list[str] = []
    for item in exposure_channels:
        _closed(item, SENSITIVE_EXPOSURE_FIELDS, "sensitive exposure fields")
        _record_posture(item, "sensitive exposure channel")
        channel = _string(item.get("channel"), "sensitive exposure channel")
        channel_names.add(channel)
        exposure_id = _string(item.get("blueprint_id"), "sensitive exposure ID")
        expected_id = "UX-SECURITY-CHANNEL-" + channel.upper()
        if exposure_id != expected_id:
            raise UXBlueprintError(
                f"sensitive exposure identity is stale: {exposure_id}"
            )
        exposure_ids.append(exposure_id)
        for field in (
            "visible_fields",
            "defaults",
            "consent",
            "redaction",
            "retention",
            "protection",
            "user_control",
            "denial_behavior",
            "proof_behavior",
        ):
            _string(item.get(field), f"sensitive exposure {field}")
        requirement_ids = _linked_ids(
            item.get("requirement_ids"), "sensitive exposure requirement IDs"
        )
        if "SECURITY-003" not in requirement_ids:
            raise UXBlueprintError(
                f"sensitive exposure channel omits SECURITY-003: {channel}"
            )
        linked_requirements.extend(requirement_ids)
    if channel_names != required_channels or len(exposure_channels) != 9:
        raise UXBlueprintError("sensitive exposure channel inventory is incomplete")

    typed_groups = (
        (screen_ids, r"UX-SCREEN-[A-Z0-9-]+"),
        (state_model_ids, r"UX-STATE-MODEL-[A-Z0-9-]+"),
        (tuple(state_variant_ids), r"UX-STATE-VARIANT-[A-Z0-9-]+"),
        (object_blueprint_ids, r"UX-OBJECT-[A-Z0-9-]+"),
        (journey_ids, r"UX-JOURNEY-[A-Z0-9-]+"),
        (cross_ids, r"UX-CROSS-[A-Z0-9-]+"),
        (tuple(exposure_ids), r"UX-SECURITY-CHANNEL-[A-Z0-9-]+"),
    )
    all_ids: list[str] = []
    for identifiers, pattern in typed_groups:
        if any(re.fullmatch(pattern, identifier) is None for identifier in identifiers):
            raise UXBlueprintError("blueprint IDs must be globally unique typed IDs")
        all_ids.extend(identifiers)
    if len(all_ids) != len(set(all_ids)):
        raise UXBlueprintError("blueprint IDs must be globally unique typed IDs")
    all_blueprint_ids = frozenset(all_ids)

    unknown_requirements = sorted(set(linked_requirements) - known_requirements)
    if unknown_requirements:
        raise UXBlueprintError(f"unknown requirement IDs: {unknown_requirements}")

    if len(screens) != 40 or len(states) != 40 or len(objects) != 18 or len(journeys) != 12 or len(cross) != 11:
        raise UXBlueprintError("blueprint inventory counts are stale")

    dispositions = build_requirement_dispositions(root, blueprint, all_blueprint_ids)
    disposition_bytes = _disposition_bytes(dispositions)
    visual_mapping_count = sum(
        item["disposition"] == "visual_mapping_required" for item in dispositions
    )
    nonvisual_count = len(dispositions) - visual_mapping_count

    return UXBlueprintSummary(
        screen_count=len(screens),
        state_model_count=len(states),
        state_taxonomy_count=state_taxonomy_count,
        state_variant_count=state_variant_count,
        object_boundary_count=len(objects),
        journey_count=len(journeys),
        cross_cutting_count=len(cross),
        requirement_link_count=len(linked_requirements),
        scope_ids=tuple(sorted(scopes)),
        state_kinds=tuple(sorted(state_kinds)),
        accessibility_facets=tuple(sorted(REQUIRED_FACETS)),
        object_ids=tuple(sorted(object_ids)),
        disposition_count=len(dispositions),
        visual_mapping_count=visual_mapping_count,
        nonvisual_count=nonvisual_count,
        disposition_sha256=hashlib.sha256(disposition_bytes).hexdigest(),
    )


def render_ux_blueprint_markdown(
    blueprint: Mapping[str, object], root: Path | None = None
) -> bytes:
    """Render the already-validated source in a stable human-reviewable form."""

    # Rendering is only called after validation in checked workflows.
    if root is None:
        root = Path(__file__).resolve().parents[2]
    record_groups = (
        blueprint["screens"],
        blueprint["state_models"],
        blueprint["object_boundaries"],
        blueprint["journeys"],
        blueprint["cross_cutting"],
        blueprint["sensitive_exposure_channels"],
    )
    all_ids = frozenset(item["blueprint_id"] for group in record_groups for item in group)
    dispositions = build_requirement_dispositions(root, blueprint, all_ids)
    disposition_bytes = _disposition_bytes(dispositions)
    visual = sum(item["disposition"] == "visual_mapping_required" for item in dispositions)
    disposition_line = (
        f"- Requirement dispositions: `{len(dispositions)}` total; `{visual}` visual; "
        f"`{len(dispositions) - visual}` nonvisual; SHA-256 "
        f"`{hashlib.sha256(disposition_bytes).hexdigest()}`"
    )
    lines = [
        "# Ambitions Canonical UX Blueprint",
        "",
        "> Shadow, non-authoritative visual-rebaseline design input.",
        "> It does not change product law, implementation state, or release proof.",
        "",
        f"- Blueprint ID: `{blueprint['blueprint_id']}`",
        f"- Canon revision: `{blueprint['canon_revision']}`",
        f"- Canon content SHA: `{blueprint['canon_content_sha']}`",
        f"- Source SHA: `{blueprint['source_sha']}`",
        f"- Authority state: `{blueprint['authority_state']}`",
        disposition_line,
        f"- Claim ceiling: {blueprint['claim_ceiling']}",
        "",
        "## Screens and presentations",
        "",
        "| Blueprint ID | Scope | Screen / state owner | Presentation | Requirements |",
        "| --- | --- | --- | --- | --- |",
    ]
    for screen in blueprint["screens"]:  # type: ignore[index]
        requirements = ", ".join(f"`{item}`" for item in screen["requirement_ids"])
        lines.append(
            f"| `{screen['blueprint_id']}` | `{screen['scope']}` | {screen['title']} | "
            f"{screen['presentation']} | {requirements} |"
        )
    lines.extend(
        [
            "",
            "## State taxonomy dispositions",
            "",
            "Every screen maps the nine completeness kinds to exact named variants or "
            "records a grounded not-applicable disposition.",
        ]
    )
    for state_model in blueprint["state_models"]:  # type: ignore[index]
        lines.extend(
            [
                "",
                f"### `{state_model['blueprint_id']}` — {state_model['title']}",
                "",
                f"Screen: `{state_model['screen_id']}`",
                "",
                "| Generic kind | Applicability | Named variant IDs | Rationale |",
                "| --- | --- | --- | --- |",
            ]
        )
        for taxonomy in state_model["taxonomy"]:
            variant_ids = ", ".join(
                f"`{item}`" for item in taxonomy["variant_ids"]
            )
            lines.append(
                f"| `{taxonomy['generic_kind']}` | `{taxonomy['applicability']}` | "
                f"{variant_ids} | {taxonomy['rationale']} |"
            )
    lines.extend(
        [
            "",
            "## Canonical named state variants",
            "",
            "These stable, frameable variants refine the nine completeness kinds without "
            "collapsing owner-specific state axes.",
            "",
            "| Variant ID | Screen | Variant | Generic kind | Visible contract | Commands | Requirements |",
            "| --- | --- | --- | --- | --- | --- | --- |",
        ]
    )
    for state_model in blueprint["state_models"]:  # type: ignore[index]
        for variant in state_model["variants"]:
            commands = ", ".join(variant["allowed_commands"])
            requirements = ", ".join(
                f"`{item}`" for item in variant["requirement_ids"]
            )
            lines.append(
                f"| `{variant['blueprint_id']}` | `{state_model['screen_id']}` | "
                f"{variant['title']} | `{variant['generic_kind']}` | "
                f"{variant['visible_content_copy']} | {commands} | {requirements} |"
            )
    lines.extend(
        [
            "",
            "## Sensitive exposure channels",
            "",
            "| Channel ID | Channel | Visible fields | Defaults | Consent and control | Redaction / protection | Denial / proof |",
            "| --- | --- | --- | --- | --- | --- | --- |",
        ]
    )
    for item in blueprint["sensitive_exposure_channels"]:  # type: ignore[index]
        lines.append(
            f"| `{item['blueprint_id']}` | `{item['channel']}` | "
            f"{item['visible_fields']} | {item['defaults']} | "
            f"{item['consent']} {item['user_control']} | "
            f"{item['redaction']} {item['protection']} | "
            f"{item['denial_behavior']} {item['proof_behavior']} |"
        )
    lines.extend(
        [
            "",
            "## Canonical object boundaries",
            "",
            "| Object | Presentation boundary | Delete / restore | Requirements |",
            "| --- | --- | --- | --- |",
        ]
    )
    for item in blueprint["object_boundaries"]:  # type: ignore[index]
        requirements = ", ".join(f"`{req}`" for req in item["requirement_ids"])
        lines.append(
            f"| `{item['object_id']}` | {item['presentation_boundaries']} | "
            f"{item['delete_restore']} | {requirements} |"
        )
    lines.extend(
        [
            "",
            "## Principal journeys",
            "",
            "| Blueprint ID | Journey | Commit boundary | Recovery / rollback | Requirements |",
            "| --- | --- | --- | --- | --- |",
        ]
    )
    for journey in blueprint["journeys"]:  # type: ignore[index]
        requirements = ", ".join(f"`{req}`" for req in journey["requirement_ids"])
        lines.append(
            f"| `{journey['blueprint_id']}` | {journey['title']} | "
            f"{journey['commit_boundary']} | {journey['recovery']} {journey['rollback']} | "
            f"{requirements} |"
        )
    lines.extend(
        [
            "",
            "## Cross-cutting design contracts",
            "",
            "| Facet | Contract | Variants | Requirements |",
            "| --- | --- | --- | --- |",
        ]
    )
    for item in blueprint["cross_cutting"]:  # type: ignore[index]
        variants = ", ".join(item["variants"])
        requirements = ", ".join(f"`{req}`" for req in item["requirement_ids"])
        lines.append(f"| `{item['facet']}` | {item['contract']} | {variants} | {requirements} |")
    lines.extend(
        [
            "",
            "## Authority and proof boundary",
            "",
            "The primary Linear V3 document remains unchanged migration corpus. Legacy Figma "
            "may be used only as provenance, exploration, failure evidence, implementation "
            "history, or a unique-content source pending extraction. It is rejected as the "
            "final visual target. Destructive actions remain withheld for Gate C.",
            "",
            "This projection does not assert source UI implementation, runtime behavior, "
            "rendered-app Visual Green, Accessibility Green, device readiness, privacy/legal "
            "approval, TestFlight readiness, App Store readiness, or Release Green.",
        ]
    )
    return ("\n".join(lines) + "\n").encode("utf-8")


def check_ux_blueprint(root: Path) -> int:
    try:
        blueprint = load_ux_blueprint(root)
        validate_ux_blueprint(root, blueprint)
        expected = render_ux_blueprint_markdown(blueprint, root)
        actual = (root / PROJECTION_PATH).read_bytes()
        expected_dispositions = render_requirement_dispositions(root, blueprint)
        actual_dispositions = (root / DISPOSITIONS_PATH).read_bytes()
    except (UXBlueprintError, OSError):
        return 1
    return (
        0
        if actual == expected and actual_dispositions == expected_dispositions
        else 1
    )


def write_ux_blueprint_projection(root: Path) -> UXBlueprintSummary:
    """Validate and atomically replace the deterministic human projection."""

    blueprint = load_ux_blueprint(root)
    summary = validate_ux_blueprint(root, blueprint)
    outputs = {
        root / PROJECTION_PATH: render_ux_blueprint_markdown(blueprint, root),
        root / DISPOSITIONS_PATH: render_requirement_dispositions(root, blueprint),
    }
    for target, rendered in outputs.items():
        target.parent.mkdir(parents=True, exist_ok=True)
        descriptor, temporary_name = tempfile.mkstemp(
            prefix=f".{target.name}.", suffix=".tmp", dir=target.parent
        )
        temporary = Path(temporary_name)
        try:
            with os.fdopen(descriptor, "wb") as stream:
                stream.write(rendered)
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(temporary, target)
            directory = os.open(target.parent, os.O_RDONLY)
            try:
                os.fsync(directory)
            finally:
                os.close(directory)
        except BaseException:
            temporary.unlink(missing_ok=True)
            raise
    return summary
