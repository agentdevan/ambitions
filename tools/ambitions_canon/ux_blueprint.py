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

from tools.ambitions_canon.model import StateCommandContract
from tools.ambitions_canon.parser import parse_canon_document


BLUEPRINT_PATH = Path("docs/canon/migration/ux-blueprint.json")
PROJECTION_PATH = Path("docs/canon/migration/UX_BLUEPRINT.md")
DISPOSITIONS_PATH = Path(
    "docs/canon/migration/ux-blueprint-requirement-dispositions.json"
)
REPAIR_MATRIX_PATH = Path(
    "tests/canon/fixtures/visual-blueprint-phase1-repair-matrix.json"
)
STATE_INVENTORY_PATH = Path(
    "docs/canon/migration/ux-blueprint-state-inventory.json"
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
REPAIR_MATRIX_SHA256 = (
    "f319153d552ab557798f289d7e838e94364a2e21b43903343c672af207dbdbbe"
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
        "DESIGN-004",
        "LAW-RUNTIME-NO-DIRECT-WRITE-001",
        "OBJ-CANONICAL-OWNER-001",
        "OBJ-COMMON-ENVELOPE-001",
        "PROOF-FIGMA-AUTHORITY-001",
        "SPEC-GLOBAL-CAPTURE-VISUAL-AUTHORITY-001",
        "SPEC-GLOBAL-SEARCH-VISUAL-AUTHORITY-001",
        "SPEC-GLOBAL-TRUST-VISUAL-AUTHORITY-001",
        "SPEC-SURFACE-GOALS-VISUAL-AUTHORITY-001",
        "SPEC-SURFACE-TIME-VISUAL-AUTHORITY-001",
        "SPEC-SURFACE-TODAY-VISUAL-AUTHORITY-001",
        "SPEC-SURFACE-YOU-VISUAL-AUTHORITY-001",
        "STANDARD-VISUAL-REVIEW-001",
        "SYSTEM-APPLE-PLATFORM-BASELINE-001",
        "SYSTEM-PERSISTENCE-COMPACTION-001",
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
if SEMANTIC_NONVISUAL_SENTINELS & frozenset(SEMANTIC_VISUAL_SENTINELS):
    raise RuntimeError("semantic visual and nonvisual sentinel sets overlap")


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
BANNED_VISIBLE_INTERNAL_LANGUAGE = re.compile(
    r"deep link envelope|application launch readiness gate|stop ship data risk|"
    r"time degraded-state owner|review pressure|shape time|inspect privacy law|"
    r"requirement[- ]backed|gap[- ]blocked|specification gap|proof ceiling|"
    r"current canon|canonical owner|architecture vocabulary|release gate|"
    r"\baffecting\b|the last confirmed information remains unchanged|"
    r"available local work remains open, with the limitation explained in place|"
    r"CloudKit|private[- ](?:life )?graph|\bbackend\b|\bactive root\b|"
    r"\bfifth root\b|durable event (?:order|sequence)|\bsuccess claim\b|"
    r"command and receipt commit|committed command|canonical (?:data|object)|"
    r"release or product-completeness proof|private runtime taxonomy|"
    r"semantic[- ]tokens?|\blocal graph\b|\blocal authority\b|"
    r"authoritative local copy|private query scope|product objects|"
    r"primary object precedes|global actions and navigation|"
    r"checkpoint is being revalidated|optional-service state|last durable state|"
    r"corrective event|receipt committed|durable consequence|"
    r"declared external effect|full success|continuity metadata|healthy claim|"
    r"continuity authority|approved transition commits|declared confirmation policy|"
    r"productivity scores?",
    re.IGNORECASE,
)

GAP_BLOCKED_ACTION_IMPLICATION_PATTERNS = (
    re.compile(
        r"(?:^|[.!?]\s+)(?:please\s+)?"
        r"(?:review|undo(?!\s+(?:history\b|is\s+unavailable\b|"
        r"remains\s+unavailable\b))|try|remove|confirm|restore|enable|export|run)\b",
        re.IGNORECASE,
    ),
    re.compile(
        r"(?:^|[.!?]\s+)(?:enabling|exporting|restoring|confirming|undoing)\b",
        re.IGNORECASE,
    ),
    re.compile(
        r"\b(?:undo|restore|export|repair)\s+"
        r"(?:removes?|returns?|creates?|changes?|replaces?|sends?|restores?|runs?)\b",
        re.IGNORECASE,
    ),
    re.compile(
        r"\b(?:undo|confirm|review|restore|export|repair)\s+"
        r"(?:is|are)\s+(?:available|possible|ready)\b",
        re.IGNORECASE,
    ),
    re.compile(
        r"\b(?:you\s+)?(?:can|may)\s+"
        r"(?:undo|confirm|try|remove|review|restore|enable|export|run)\b",
        re.IGNORECASE,
    ),
)


def gap_blocked_copy_implies_action(text: str) -> bool:
    """Return whether copy tells or promises an unsupported user action."""

    return any(pattern.search(text) for pattern in GAP_BLOCKED_ACTION_IMPLICATION_PATTERNS)


ALL_CORPUS_VISIBLE_COPY_REVIEW_IDS = frozenset(
    {
        "UX-STATE-VARIANT-ACCOUNT-BOUNDARY-CONTINUITY-CONFLICTED",
        "UX-STATE-VARIANT-ACCOUNT-STATUS-CONTINUITY-DISABLED",
        "UX-STATE-VARIANT-APP-SHELL-ROOT-UNAVAILABLE-ROUTE-DUPLICATE-PRESENTATION-OWNER",
        "UX-STATE-VARIANT-APP-SHELL-SEARCH-CAPTURE-IDLE",
        "UX-STATE-VARIANT-APP-SHELL-SEARCH-CAPTURE-RETURNING-FOCUS",
        "UX-STATE-VARIANT-CAPTURE-COMPOSER-PARTIAL-ROUTING",
        "UX-STATE-VARIANT-CAPTURE-COMPOSER-ROUTING",
        "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-PENDING",
        "UX-STATE-VARIANT-SETUP-RESUME-CHECKPOINT-INVALID",
        "UX-STATE-VARIANT-TODAY-DETAIL-ACTIVE-EXECUTION",
        "UX-STATE-VARIANT-TODAY-DETAIL-CLOSURE-REVIEW",
        "UX-STATE-VARIANT-TODAY-DETAIL-RECOVERY",
        "UX-STATE-VARIANT-TRUST-DEEP-RESTORING",
        "UX-STATE-VARIANT-TRUST-RECEIPT-RECEIPT-RESOLVING",
        "UX-STATE-VARIANT-TRUST-RECEIPT-RESTORING",
        "UX-STATE-VARIANT-TRUST-RECEIPT-UNDOING",
        "UX-STATE-VARIANT-YOU-ROOT-CONTINUITY-CONFLICTED",
        "UX-STATE-VARIANT-YOU-SETTINGS-APPEARANCE-OLED-DARK",
    }
)
ALL_CORPUS_VISIBLE_COPY_INTERNAL_LANGUAGE = re.compile(
    r"(?:\bauthoritative\b[^.!?;]{0,64}\blocal copy\b|"
    r"\blocal copy\b[^.!?;]{0,64}\bauthoritative\b|"
    r"\bcurrent\b[^.!?;]{0,64}\bauthority\b|"
    r"\bauthority\b[^.!?;]{0,64}\bcurrent\b|"
    r"\bduplicate\b[^.!?;]{0,48}\b(?:owner|presentation)\b|"
    r"\b(?:owner|presentation)\b[^.!?;]{0,48}\bduplicate\b|"
    r"\banother presentation\b|\bglobal actions\b|\boverlay\b|"
    r"\boriginating object control\b|\bCapture route\b|"
    r"\blocal object type\b|\bstale completion\b|\breplay(?:ed|ing)?\b|"
    r"\bactive execution\b|\bexecution is active\b|"
    r"\bclosure consequence\b|\bclosure[- ]contract\b|\bproof rule\b|"
    r"\breceipt preview precedes commitment\b|\bdurable Step state\b|"
    r"\btrust state\b|\bcurrent subject\b|\bcorrective receipts\b|"
    r"\bsemantic grouping\b)",
    re.IGNORECASE,
)


def all_corpus_visible_copy_exposes_internal_language(
    variant_id: str, text: str
) -> bool:
    """Detect reviewed internal phrases without banning legitimate product nouns."""

    return (
        variant_id in ALL_CORPUS_VISIBLE_COPY_REVIEW_IDS
        and ALL_CORPUS_VISIBLE_COPY_INTERNAL_LANGUAGE.search(text) is not None
    )


SEMANTIC_CORPUS_REVIEWED_INTERNAL_PHRASES = tuple(["Ambitions objects","Checkpoint","Core Ambitions","Core local","Current-period control","Local core","Object detail","Scheduled objects","Time Day — conflicting","Time Day — dense","Time Day — editing","Time Day — empty","Time Day — importing","Time Day — now anchored","Time Day — populated","Time Day — previewing","Time Day — restored","Time Day — selected","Time Year Conflicting — Conflict presence is visible at month-summary level without exposing object detail","Time Year Dense — Dense annual content remains grouped by month and requires drilldown for object detail","Time Year Editing — Editing is unavailable at year depth and moves to month drilldown","Time Year Empty — No month contains local time objects; the year remains a month-summary overview","Time Year External Hidden Capacity — External calendar detail remains hidden; only aggregate month capacity is visible","Time Year Importing — Import progress is summarized by affected month; exact imported objects stay in review depth","Time Year Now Anchored — Current-period control identifies the year and current month without a day-level Now marker","Time Year Populated — Month summaries show annual rhythm without exposing granular objects","Time Year Previewing — Preview is summarized by month and granular consequence review requires drilldown","Time Year Restored — Restoration returns to the saved year and month summary without opening an object","Time Year Selected — Selection identifies one month summary and exposes no granular edit control","Underlying Goals, Steps, and time objects","Viewing — Object detail explains why it fits, current state, time context, and safe actions","account state","actions owned by that item type","calendar state","checkpoint","commands owned by its type","commit","committed","committing","control actions","core local","created object","current local state","current state","current subject","current-period control","declared fields","declared outcome","declared scope","declared scopes","delivery state","device state","diff review","drilldown","exact subject","external-ownership","granular","healthy local core","import state","lifecycle","linked object","local core","local object","local objects","local-core","month-summary level","month-summary overview","object detail","object type","object types","preference state","previously focused control remains identified","prior local state","referenced source or object","restorable local objects","restorable objects","revalidated","review depth","safe actions","saved objects","shape, and state","subject links","this operation","time object","time objects","underlying Ambitions objects","underlying Goal, Step, or time object","underlying Step or object","underlying object","underlying work"])
SEMANTIC_CORPUS_REVIEWED_GAP_ACTION_PHRASES = tuple(["Changes still follow the confirmation choices shown here","Clearing them does not change","Closure needs review","Continue Without Account preserves full local core use","Decisions must not treat it as current until refresh succeeds","Enter a query","Goals need review","Start Over","Starting over clears setup progress","This Goal needs review","available for correction","both choices remain visible","can be recovered","can be revisited later","choices remain changeable later","confirmed search action is being applied locally","export remain explicit","for review before it joins the Capture","needs a user review","needs review","next review point visible","opening an item rechecks","opening the selected item’s inspection view","proposed repair and its consequences are visible before anything changes","protected for review","ready for activation review","ready for inspection before any repair or export choice","recovery choices are considered","safe options are ready for review","selected search action is being checked","selected search action was not accepted","settings action needs review","until it is finished or dismissed","until review","until the user chooses to activate it","until the user confirms","until the user reviews a safe resolution","until you resume","waiting for review before they can alter","whether this permission can be requested","will be validated against current local information","will not repeat a completed action","will not run again","will open this link after checking its destination and access"])
SEMANTIC_CORPUS_INTERNAL_LANGUAGE_PATTERNS = (
    re.compile(
        r"(?<!\w)(?:core|lifecycle|checkpoint|drilldown|granular(?:ity)?|"
        r"runtime|authority|canonical|semantic|implementation|governance|"
        r"release|projection|overlay|root)(?!\w)",
        re.IGNORECASE,
    ),
    re.compile(r"(?<!\w)commit(?:s|ted|ting)?(?!\w)", re.IGNORECASE),
    re.compile(
        r"(?<!\w)(?:account|local|import|calendar|device|preference|"
        r"delivery|current)\s+state(?!\w)",
        re.IGNORECASE,
    ),
    re.compile(
        r"(?<!\w)revalidat(?:e|ed|ing)(?!\w)|"
        r"(?<!\w)diff\s+review(?!\w)",
        re.IGNORECASE,
    ),
    re.compile(
        r"(?<!\w)(?:commands?|actions?)[^.!?;]{0,64}"
        r"(?:own(?:s|ed)?|owner|authority)(?!\w)|"
        r"(?<!\w)(?:own(?:s|ed)?|owner|authority)[^.!?;]{0,64}"
        r"(?:commands?|actions?)(?!\w)",
        re.IGNORECASE,
    ),
    re.compile(
        r"^(?:Time Day\s+—\s+[^.]+|Time Year\s+[^—]+—|Viewing\s+—)",
        re.IGNORECASE,
    ),
)
SEMANTIC_CORPUS_GAP_ACTION_PATTERNS = (
    re.compile(
        r"(?:^|[.!?;:—]\s+)(?:please\s+)?"
        r"(?:continue|enter|resume|start(?!\s+here\b)|review|"
        r"undo(?!\s+(?:history\b|is\s+unavailable\b|remains\s+unavailable\b))|"
        r"try|remove|confirm|"
        r"restore|enable|export|run|open|clear|activate|inspect|correct|"
        r"dismiss)\b",
        re.IGNORECASE,
    ),
    re.compile(
        r"\b(?:you|the user)\s+(?:can|may|will|chooses? to)\s+"
        r"(?:continue|enter|resume|start|review|undo|try|remove|confirm|"
        r"restore|enable|export|run|open|clear|activate|inspect|correct|"
        r"dismiss)\b",
        re.IGNORECASE,
    ),
    re.compile(
        r"\b(?:ready|available)\s+(?:for|to)\s+"
        r"(?:review|correction|activation|repair|export|resume)\b|"
        r"\bready\s+for\s+inspection\b",
        re.IGNORECASE,
    ),
    re.compile(
        r"\b(?:clearing|opening|starting over|confirming|restoring|"
        r"enabling|exporting|repairing)\b[^.!?]{0,96}"
        r"\b(?:does|will|clears|rechecks|creates|changes|removes|returns|"
        r"sends|restores)\b",
        re.IGNORECASE,
    ),
    re.compile(r"\bneeds?\s+(?:a\s+|user\s+)?review\b", re.IGNORECASE),
)


def _reviewed_phrase_present(text: str, phrase: str) -> bool:
    return re.search(
        rf"(?<!\w){re.escape(phrase)}(?!\w)", text, re.IGNORECASE
    ) is not None


def semantic_corpus_internal_language_matches(text: str) -> tuple[str, ...]:
    """Return corpus-wide internal-language matches for visible user copy."""

    matches = [
        f"pattern:{index}"
        for index, pattern in enumerate(SEMANTIC_CORPUS_INTERNAL_LANGUAGE_PATTERNS)
        if pattern.search(text)
    ]
    matches.extend(
        f"phrase:{phrase}"
        for phrase in SEMANTIC_CORPUS_REVIEWED_INTERNAL_PHRASES
        if _reviewed_phrase_present(text, phrase)
    )
    return tuple(matches)


def semantic_corpus_gap_action_implication_matches(text: str) -> tuple[str, ...]:
    """Return unsupported action implications in gap-blocked visible copy."""

    matches = [
        f"pattern:{index}"
        for index, pattern in enumerate(SEMANTIC_CORPUS_GAP_ACTION_PATTERNS)
        if pattern.search(text)
    ]
    matches.extend(
        f"phrase:{phrase}"
        for phrase in SEMANTIC_CORPUS_REVIEWED_GAP_ACTION_PHRASES
        if _reviewed_phrase_present(text, phrase)
    )
    return tuple(matches)


def _owner_state_classifications() -> dict[tuple[str, str], tuple[str, str, str]]:
    """Return owner-law classifications for state machines called out by review."""

    rows: dict[tuple[str, str], tuple[str, str, str]] = {}

    def add(
        screen_id: str,
        values: Mapping[str, tuple[str, str, str]],
    ) -> None:
        for key, classification in values.items():
            rows[(screen_id, key)] = classification

    add(
        "UX-SCREEN-APP-DEEP-LINK-INTAKE",
        {
            "consumed": ("resting", "lifecycle", "succeeded"),
            "presented": ("resting", "lifecycle", "succeeded"),
            "queued": ("transitional", "lifecycle", "idle"),
            "recoverable": ("recovery", "lifecycle", "idle"),
            "rejected": ("failure", "lifecycle", "failed"),
            "resolving": ("loading", "lifecycle", "in_progress"),
        },
    )
    add(
        "UX-SCREEN-SETUP-FIRST-USE",
        {
            "in-progress": ("loading", "lifecycle", "in_progress"),
            "not-started": ("empty", "lifecycle", "not_applicable"),
            "revisitable": ("recovery", "lifecycle", "not_applicable"),
            "skipped": ("interruption", "lifecycle", "not_applicable"),
            "sufficient-for-local-use": ("resting", "lifecycle", "succeeded"),
        },
    )
    add(
        "UX-SCREEN-GOALS-PATH",
        {
            "active": ("resting", "lifecycle", "not_applicable"),
            "blocked": ("degraded", "lifecycle", "not_applicable"),
            "completed": ("resting", "lifecycle", "succeeded"),
            "draft": ("resting", "lifecycle", "not_applicable"),
            "needs-attention": ("degraded", "lifecycle", "not_applicable"),
            "paused": ("interruption", "lifecycle", "not_applicable"),
            "ready-to-activate": ("transitional", "lifecycle", "idle"),
            "recovering": ("recovery", "lifecycle", "in_progress"),
            "restoring": ("recovery", "lifecycle", "in_progress"),
            "rolled-back": ("rollback", "lifecycle", "succeeded"),
            "waiting": ("interruption", "lifecycle", "not_applicable"),
        },
    )
    add(
        "UX-SCREEN-YOU-ENTITLEMENT",
        {
            "active": ("resting", "lifecycle", "not_applicable"),
            "expired": ("degraded", "lifecycle", "not_applicable"),
            "grace": ("degraded", "lifecycle", "not_applicable"),
            "mismatch": ("degraded", "lifecycle", "not_applicable"),
            "offline-cached": ("degraded", "lifecycle", "not_applicable"),
            "restored": ("recovery", "lifecycle", "succeeded"),
            "retry": ("recovery", "lifecycle", "in_progress"),
            "revoked": ("degraded", "lifecycle", "not_applicable"),
            "supported-sharing": ("resting", "lifecycle", "not_applicable"),
            "trial": ("resting", "lifecycle", "not_applicable"),
            "unknown": ("degraded", "lifecycle", "not_applicable"),
        },
    )
    add(
        "UX-SCREEN-YOU-NOTIFICATIONS",
        {
            "acted": ("resting", "lifecycle", "not_applicable"),
            "delivered": ("resting", "lifecycle", "not_applicable"),
            "disabled": ("resting", "lifecycle", "not_applicable"),
            "externally-failed": ("failure", "lifecycle", "failed"),
            "permission-allowed": ("resting", "lifecycle", "not_applicable"),
            "permission-denied": ("failure", "lifecycle", "failed"),
            "permission-not-requested": ("empty", "lifecycle", "not_applicable"),
            "reconciled": ("recovery", "lifecycle", "succeeded"),
            "removed": ("resting", "lifecycle", "not_applicable"),
            "scheduled": ("resting", "lifecycle", "not_applicable"),
            "superseded": ("interruption", "lifecycle", "not_applicable"),
        },
    )
    add(
        "UX-SCREEN-TIME-DEGRADED",
        {
            "external-write-failure": ("failure", "availability", "failed"),
            "local-store-degradation": ("degraded", "availability", "not_applicable"),
            "offline-healthy": ("resting", "availability", "not_applicable"),
            "partial-import": ("degraded", "availability", "failed"),
            "pending-external-diff": ("loading", "availability", "in_progress"),
            "permission-denied": ("failure", "availability", "failed"),
            "stale-source": ("degraded", "availability", "not_applicable"),
            "sync-conflict": ("degraded", "availability", "failed"),
            "sync-pending": ("loading", "availability", "in_progress"),
        },
    )
    return rows


OWNER_STATE_CLASSIFICATIONS = _owner_state_classifications()
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
        "specification_gaps",
        "legacy_figma_policy",
        "claim_ceiling",
        "screens",
        "setup_contract",
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
        "behavior_authority_evidence",
        "behavior_authority_posture",
        "behavior_authority_rationale",
        "behavior_requirement_ids",
        "blueprint_id",
        "displayed_objects",
        "durable_effect",
        "generic_kind",
        "implementation_status",
        "offline_behavior",
        "operation_phase",
        "proof_ceiling",
        "recovery_rollback",
        "requirement_ids",
        "specification_gap_ids",
        "state_axis",
        "title",
        "transition_exit",
        "variant_key",
        "visible_content_copy",
        "visible_presentation",
    }
)
SETUP_CONTRACT_FIELDS = frozenset(
    {"lifecycle_states", "resume_checkpoint_mapping", "subordinate_content"}
)
SETUP_CONTENT_FIELDS = frozenset(
    {"content_id", "purpose", "requirement_ids"}
)
SPECIFICATION_GAP_FIELDS = frozenset(
    {
        "affected_state_ids",
        "affected_screen_families",
        "authority_consequence",
        "blocked_fields",
        "gap_id",
        "source_rationale",
    }
)
BEHAVIOR_AUTHORITY_EVIDENCE_FIELDS = frozenset(
    {"normative_clause", "owned_fields", "requirement_id"}
)
BEHAVIOR_OWNED_FIELDS = frozenset(
    {
        "accessibility_focus",
        "allowed_commands",
        "durable_effect",
        "offline_behavior",
        "recovery_rollback",
        "transition_exit",
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


def _possibly_empty_records(value: object, label: str) -> list[dict[str, object]]:
    if not isinstance(value, list):
        raise UXBlueprintError(f"{label} must be an array")
    return [_object(item, f"{label}[{index}]") for index, item in enumerate(value)]


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
    root: Path, source_sha: object, _source_paths: tuple[str, ...]
) -> str:
    sha = _string(source_sha, "source SHA")
    if not re.fullmatch(r"[0-9a-f]{40}", sha):
        raise UXBlueprintError("source SHA must be a full Git commit SHA")
    result = subprocess.run(
        ["git", "cat-file", "-e", f"{sha}^{{commit}}"],
        cwd=root,
        capture_output=True,
        check=False,
        text=True,
    )
    if result.returncode != 0:
        raise UXBlueprintError("source SHA is not an immutable reviewed commit object")
    # Exact current bytes are independently bound by source_documents.  The Git
    # SHA is a lineage anchor and cannot self-reference the commit that records
    # a newly reviewed source digest.
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
        signature = re.sub(
            rf"(?<![\w-]){re.escape(value.casefold())}(?![\w-])",
            replacement,
            signature,
        )
    return " ".join(signature.split())


def normalized_visible_copy_signature(
    text: str,
    screen_id: str,
    variant_key: str,
    variant: Mapping[str, object],
) -> str:
    """Normalize record labels so title substitution cannot hide repeated copy."""

    replacements = {
        _string(variant.get("title"), "variant title"),
        variant_key.replace("-", " "),
        screen_id.removeprefix("UX-SCREEN-").replace("-", " "),
    }
    replacements.update(
        _possibly_empty_strings(
            variant.get("displayed_objects"), "copy displayed objects"
        )
    )
    signature = text.casefold()
    for value in sorted((item for item in replacements if item), key=len, reverse=True):
        signature = re.sub(
            rf"(?<!\w){re.escape(value.casefold())}(?!\w)",
            "<record>",
            signature,
        )
    signature = re.sub(r"[^a-z0-9<>]+", " ", signature)
    return " ".join(signature.split())


VISIBLE_COPY_SEMANTIC_STOPWORDS = frozenset(
    {
        "a", "an", "and", "are", "as", "at", "be", "by", "for", "from",
        "has", "have", "in", "is", "it", "of", "on", "or", "that", "the",
        "this", "to", "was", "were", "while", "with", "your",
    }
)


def visible_copy_semantic_bag_signature(
    text: str,
    screen_id: str,
    variant_key: str,
    variant: Mapping[str, object],
) -> str:
    """Collapse word order after record labels are removed from visible copy."""

    normalized = normalized_visible_copy_signature(
        text, screen_id, variant_key, variant
    )
    tokens = []
    for token in re.findall(r"[a-z0-9]+", normalized):
        if token in VISIBLE_COPY_SEMANTIC_STOPWORDS or token == "record":
            continue
        if token.endswith("ies") and len(token) > 4:
            token = token[:-3] + "y"
        elif token.endswith("s") and len(token) > 4 and not token.endswith("ss"):
            token = token[:-1]
        tokens.append(token)
    return " ".join(sorted(tokens))


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


def load_state_command_contracts(root: Path) -> tuple[StateCommandContract, ...]:
    """Load independently authored state-command ownership from normative canon."""

    index = _requirement_records(root)
    paths = sorted({_string(item.get("source_path"), "source path") for item in index})
    contracts: list[StateCommandContract] = []
    state_ids: set[str] = set()
    command_ids: set[str] = set()
    for relative in paths:
        path = root / relative
        document = parse_canon_document(path, path.read_text(encoding="utf-8"))
        for contract in document.state_command_contracts:
            if contract.state_id in state_ids:
                raise UXBlueprintError(
                    f"duplicate canonical state command contract: {contract.state_id}"
                )
            state_ids.add(contract.state_id)
            for command in contract.commands:
                if command.command_id in command_ids:
                    raise UXBlueprintError(
                        f"duplicate canonical command ID: {command.command_id}"
                    )
                command_ids.add(command.command_id)
            contracts.append(contract)
    return tuple(sorted(contracts, key=lambda item: item.state_id))


def load_state_inventory(root: Path) -> dict[str, object]:
    """Load the explicit matrix-bound state inventory used by validation."""

    matrix_bytes = (root / REPAIR_MATRIX_PATH).read_bytes()
    if hashlib.sha256(matrix_bytes).hexdigest() != REPAIR_MATRIX_SHA256:
        raise UXBlueprintError("visual repair matrix bytes are stale")
    try:
        payload = json.loads((root / STATE_INVENTORY_PATH).read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise UXBlueprintError(f"cannot load explicit state inventory: {error}") from error
    inventory = _object(payload, "explicit state inventory")
    expected_fields = {
        "matrix_sha256",
        "schema_version",
        "setup_subordinate_content",
        "state_variants",
    }
    if set(inventory) != expected_fields:
        raise UXBlueprintError("explicit state inventory fields are closed")
    if inventory.get("schema_version") != 1:
        raise UXBlueprintError("explicit state inventory schema is stale")
    if inventory.get("matrix_sha256") != REPAIR_MATRIX_SHA256:
        raise UXBlueprintError("explicit state inventory matrix binding is stale")
    return inventory


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
        described_ids = frozenset(re.findall(r"UX-[A-Z0-9-]+", rationale))
        structured_ids = frozenset(blueprint_ids) | frozenset(state_blueprint_ids)
        if described_ids != structured_ids:
            raise UXBlueprintError(
                f"requirement rationale UX IDs contradict structured edges: {requirement_id}"
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

    setup_contract = _object(blueprint.get("setup_contract"), "setup contract")
    _closed(setup_contract, SETUP_CONTRACT_FIELDS, "setup contract fields")
    lifecycle_states = _strings(
        setup_contract.get("lifecycle_states"),
        "setup lifecycle states",
        sorted_unique=True,
    )
    if lifecycle_states != (
        "in-progress",
        "not-started",
        "revisitable",
        "skipped",
        "sufficient-for-local-use",
    ):
        raise UXBlueprintError("setup lifecycle states are incomplete or invented")
    setup_content = _records(
        setup_contract.get("subordinate_content"), "setup subordinate content"
    )
    content_ids = []
    for content in setup_content:
        _closed(content, SETUP_CONTENT_FIELDS, "setup subordinate content fields")
        content_ids.append(_string(content.get("content_id"), "setup content ID"))
        _string(content.get("purpose"), "setup content purpose")
        _linked_ids(content.get("requirement_ids"), "setup content requirement IDs")
    if content_ids != ["optional-account", "permissions-choice", "welcome"]:
        raise UXBlueprintError("setup subordinate content is incomplete or invented")
    resume_mapping = _object(
        setup_contract.get("resume_checkpoint_mapping"),
        "setup resume checkpoint mapping",
    )
    if set(resume_mapping.values()) - set(lifecycle_states):
        raise UXBlueprintError("setup resume mapping references an unknown lifecycle")

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
    specification_gaps = _possibly_empty_records(
        blueprint.get("specification_gaps"), "specification gaps"
    )
    state_contracts = load_state_command_contracts(root)
    state_contracts_by_id = {item.state_id: item for item in state_contracts}
    for contract in state_contracts:
        if contract.requirement_id not in known_requirements:
            raise UXBlueprintError(
                f"state contract references unknown requirement: {contract.state_id}"
            )
        if set(contract.gate_requirement_ids) - known_requirements:
            raise UXBlueprintError(
                f"state contract references unknown gate requirement: {contract.state_id}"
            )
    matrix = json.loads((root / REPAIR_MATRIX_PATH).read_text(encoding="utf-8"))
    matrix_gap_families = {
        _string(item.get("gap_id"), "matrix gap ID"): frozenset(
            _strings(item.get("screen_families"), "matrix screen families")
        )
        for item in _records(matrix.get("gaps"), "matrix gaps")
    }
    gap_ids: list[str] = []
    declared_gap_states: dict[str, tuple[str, ...]] = {}
    for gap in specification_gaps:
        _closed(gap, SPECIFICATION_GAP_FIELDS, "specification gap fields")
        gap_id = _string(gap.get("gap_id"), "specification gap ID")
        if re.fullmatch(r"GAP-UX-[A-Z0-9-]+-\d{3}", gap_id) is None:
            raise UXBlueprintError(f"specification gap ID is invalid: {gap_id}")
        gap_ids.append(gap_id)
        declared_gap_states[gap_id] = _strings(
            gap.get("affected_state_ids"),
            "specification gap affected state IDs",
            sorted_unique=True,
        )
        _strings(
            gap.get("affected_screen_families"),
            "specification gap affected screen families",
            sorted_unique=True,
        )
        _strings(
            gap.get("blocked_fields"),
            "specification gap blocked fields",
            sorted_unique=True,
        )
        if len(_string(gap.get("source_rationale"), "specification gap source rationale").split()) < 10:
            raise UXBlueprintError(f"specification gap source rationale is incomplete: {gap_id}")
        consequence = _string(
            gap.get("authority_consequence"),
            "specification gap authority consequence",
        )
        if "not" not in consequence.casefold():
            raise UXBlueprintError(f"specification gap does not fail closed: {gap_id}")
    if gap_ids != sorted(set(gap_ids)):
        raise UXBlueprintError("specification gap inventory is stale")
    known_gap_ids = frozenset(gap_ids)
    preliminary_ids = [
        _string(item.get("blueprint_id"), "blueprint ID")
        for records in (screens, states, objects, journeys, cross, exposure_channels)
        for item in records
    ]
    if len(preliminary_ids) != len(set(preliminary_ids)):
        raise UXBlueprintError("blueprint IDs must be globally unique typed IDs")
    declared_state_ids = {
        _string(variant.get("blueprint_id"), "state variant ID")
        for model in states
        for variant in _records(model.get("variants"), "state variants")
    }
    unknown_contract_states = set(state_contracts_by_id) - declared_state_ids
    if unknown_contract_states:
        raise UXBlueprintError(
            f"state contract references unknown state ID: {sorted(unknown_contract_states)[0]}"
        )
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
    visible_copy_signatures: dict[str, str] = {}
    visible_copy_semantic_bags: dict[str, str] = {}
    visible_copy_clause_counts: dict[str, int] = {}
    explicit_inventory = load_state_inventory(root)
    expected_inventory_rows = [
        {
            "blueprint_id": _string(variant.get("blueprint_id"), "state variant ID"),
            "generic_kind": _string(variant.get("generic_kind"), "state generic kind"),
            "operation_phase": _string(
                variant.get("operation_phase"), "state operation phase"
            ),
            "screen_id": _string(model.get("screen_id"), "state model screen_id"),
            "state_axis": _string(variant.get("state_axis"), "state axis"),
            "variant_key": _string(variant.get("variant_key"), "state variant key"),
        }
        for model in states
        for variant in _records(model.get("variants"), "state variants")
    ]
    if explicit_inventory.get("state_variants") != expected_inventory_rows:
        raise UXBlueprintError("explicit state inventory is incomplete or invented")
    if explicit_inventory.get("setup_subordinate_content") != setup_content:
        raise UXBlueprintError("explicit setup content inventory is incomplete or invented")
    requirement_source_text = {
        record["requirement_id"]: record["normative_text"]
        for record in load_requirement_source_records(root)
    }
    observed_gap_states: dict[str, list[str]] = {gap_id: [] for gap_id in gap_ids}
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
        actual_variant_keys = tuple(
            _string(item.get("variant_key"), "state variant key")
            for item in variant_records
        )
        if actual_variant_keys != tuple(sorted(set(actual_variant_keys))):
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
            state_axis = _string(variant.get("state_axis"), "state variant axis")
            if state_axis not in {
                "availability", "checkpoint", "interruption", "lifecycle",
                "operation", "presentation", "recovery",
            }:
                raise UXBlueprintError(f"state variant axis is invalid: {variant_key}")
            operation_phase = _string(
                variant.get("operation_phase"), "state operation phase"
            )
            if operation_phase not in {
                "failed", "idle", "in_progress", "not_applicable",
                "rolling_back", "succeeded",
            }:
                raise UXBlueprintError(
                    f"state operation phase is invalid: {variant_key}"
                )
            expected_owner_classification = OWNER_STATE_CLASSIFICATIONS.get(
                (screen_id, variant_key)
            )
            if expected_owner_classification is not None and (
                generic_kind,
                state_axis,
                operation_phase,
            ) != expected_owner_classification:
                raise UXBlueprintError(
                    "owner state classification is stale: "
                    f"{screen_id} {variant_key} expected "
                    f"{expected_owner_classification}"
                )
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
                    if field == "visible_content_copy" and text:
                        if BANNED_VISIBLE_INTERNAL_LANGUAGE.search(text):
                            raise UXBlueprintError(
                                f"visible copy exposes internal language: {variant_id}"
                            )
                        if semantic_corpus_internal_language_matches(text):
                            raise UXBlueprintError(
                                "semantic corpus visible copy exposes internal language: "
                                f"{variant_id}"
                            )
                        if all_corpus_visible_copy_exposes_internal_language(
                            variant_id, text
                        ):
                            raise UXBlueprintError(
                                "all-corpus visible copy exposes internal language: "
                                f"{variant_id}"
                            )
                        copy_signature = normalized_visible_copy_signature(
                            text, screen_id, variant_key, variant
                        )
                        prior_copy = visible_copy_signatures.get(copy_signature)
                        if prior_copy is not None:
                            raise UXBlueprintError(
                                "normalized visible-copy skeleton is repeated: "
                                f"{prior_copy} {variant_id}"
                            )
                        visible_copy_signatures[copy_signature] = variant_id
                        semantic_bag = visible_copy_semantic_bag_signature(
                            text, screen_id, variant_key, variant
                        )
                        prior_semantic_bag = visible_copy_semantic_bags.get(
                            semantic_bag
                        )
                        if prior_semantic_bag is not None:
                            raise UXBlueprintError(
                                "visible-copy semantic bag is repeated: "
                                f"{prior_semantic_bag} {variant_id}"
                            )
                        visible_copy_semantic_bags[semantic_bag] = variant_id
                        for clause in re.split(r"[.!?;]+", text):
                            if not clause.strip():
                                continue
                            clause_bag = visible_copy_semantic_bag_signature(
                                clause, screen_id, variant_key, variant
                            )
                            if len(clause_bag.split()) < 4:
                                continue
                            visible_copy_clause_counts[clause_bag] = (
                                visible_copy_clause_counts.get(clause_bag, 0) + 1
                            )
                            if visible_copy_clause_counts[clause_bag] > 3:
                                raise UXBlueprintError(
                                    "visible-copy clause is repeated: "
                                    f"{clause_bag}"
                                )
                    if (
                        variant.get("behavior_authority_posture")
                        == "requirement_backed"
                        and screen_id in NORMALIZED_NARRATIVE_SCREEN_IDS
                        and field in BEHAVIOR_OWNED_FIELDS
                    ):
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
            behavior_posture = _string(
                variant.get("behavior_authority_posture"),
                "state behavior authority posture",
            )
            behavior_rationale = _string(
                variant.get("behavior_authority_rationale"),
                "state behavior authority rationale",
            )
            behavior_requirements = _possibly_empty_strings(
                variant.get("behavior_requirement_ids"),
                "state behavior requirement IDs",
            )
            state_gap_ids = _possibly_empty_strings(
                variant.get("specification_gap_ids"),
                "state specification gap IDs",
            )
            evidence_value = variant.get("behavior_authority_evidence")
            if not isinstance(evidence_value, list):
                raise UXBlueprintError(
                    f"behavior authority evidence must be an array: {variant_id}"
                )
            evidence: list[dict[str, object]] = []
            for index, item in enumerate(evidence_value):
                record = _object(item, f"behavior authority evidence[{index}]")
                _closed(
                    record,
                    BEHAVIOR_AUTHORITY_EVIDENCE_FIELDS,
                    "behavior authority evidence fields",
                )
                evidence.append(record)
            if state_gap_ids != tuple(sorted(set(state_gap_ids))) or set(state_gap_ids) - known_gap_ids:
                raise UXBlueprintError(
                    f"state behavior references unknown specification gap: {variant_id}"
                )
            for gap_id in state_gap_ids:
                screen_family = screen_id.removeprefix("UX-SCREEN-").casefold()
                if screen_family not in matrix_gap_families.get(gap_id, frozenset()):
                    raise UXBlueprintError(
                        f"state gap mapping is outside approved matrix screen family: "
                        f"{variant_id} {gap_id}"
                    )
                observed_gap_states[gap_id].append(variant_id)
            if behavior_posture == "exploratory_blocked_by_specification_gap":
                if (
                    allowed_commands
                    or behavior_requirements
                    or evidence
                    or not state_gap_ids
                ):
                    raise UXBlueprintError(
                        f"gap-blocked behavior must authorize no command: {variant_id}"
                    )
                visible_copy_value = variant.get("visible_content_copy")
                if (
                    variant_id == "UX-STATE-VARIANT-TRUST-INLINE-NO-DISCLOSURE"
                    and visible_copy_value == ""
                ):
                    visible_copy = ""
                else:
                    visible_copy = _string(
                        visible_copy_value,
                        "gap-blocked visible content copy",
                    )
                if gap_blocked_copy_implies_action(visible_copy):
                    raise UXBlueprintError(
                        "gap-blocked visible copy implies an unauthorized action: "
                        f"{variant_id}"
                    )
                if semantic_corpus_gap_action_implication_matches(visible_copy):
                    raise UXBlueprintError(
                        "semantic corpus gap-blocked copy implies an action: "
                        f"{variant_id}"
                    )
                serialized_behavior = " ".join(
                    str(variant[field])
                    for field in (
                        "transition_exit", "durable_effect", "recovery_rollback",
                        "offline_behavior", "accessibility_focus",
                        "behavior_authority_rationale",
                    )
                ).casefold()
                if "no exact command authorized by current canon" not in serialized_behavior:
                    raise UXBlueprintError(
                        f"gap-blocked behavior omits authority consequence: {variant_id}"
                    )
            elif behavior_posture == "requirement_backed":
                contract = state_contracts_by_id.get(variant_id)
                if contract is None:
                    raise UXBlueprintError(
                        "requirement-backed behavior requires independent structured canon "
                        f"field ownership: {variant_id}"
                    )
                linked = set(variant.get("requirement_ids", []))
                if (
                    not behavior_requirements
                    or not evidence
                    or state_gap_ids
                    or set(behavior_requirements) - linked
                    or len(behavior_rationale.split()) < 10
                ):
                    raise UXBlueprintError(
                        f"unsupported behavior authority: {variant_id}"
                    )
                if contract.requirement_id not in linked or not set(
                    contract.gate_requirement_ids
                ) <= linked:
                    raise UXBlueprintError(
                        f"state command contract requirements are not linked: {variant_id}"
                    )
                expected_labels = tuple(command.label for command in contract.commands)
                if allowed_commands != expected_labels:
                    raise UXBlueprintError(
                        f"allowed commands drift from structured canon: {variant_id}"
                    )
                for field, expected in {
                    "transition_exit": contract.transition_exit,
                    "durable_effect": contract.durable_effect,
                    "recovery_rollback": contract.recovery_rollback,
                    "offline_behavior": contract.offline_behavior,
                    "accessibility_focus": contract.accessibility_focus,
                }.items():
                    if variant.get(field) != expected:
                        raise UXBlueprintError(
                            f"blueprint command contract drift: {variant_id} {field}"
                        )
                owned_fields: set[str] = set()
                evidence_requirements: list[str] = []
                evidence_clauses: list[str] = []
                for item in evidence:
                    requirement_id = _string(
                        item.get("requirement_id"), "evidence requirement ID"
                    )
                    if requirement_id not in behavior_requirements:
                        raise UXBlueprintError(
                            f"evidence requirement mismatch: {variant_id}"
                        )
                    normative_clause = _string(
                        item.get("normative_clause"), "evidence normative clause"
                    )
                    if requirement_source_text.get(requirement_id) != normative_clause:
                        raise UXBlueprintError(
                            f"non-exact normative clause: {variant_id} {requirement_id}"
                        )
                    fields = _strings(
                        item.get("owned_fields"),
                        "evidence owned fields",
                        sorted_unique=True,
                    )
                    if set(fields) - BEHAVIOR_OWNED_FIELDS:
                        raise UXBlueprintError(
                            f"evidence owns unknown behavior field: {variant_id}"
                        )
                    owned_fields.update(fields)
                    evidence_requirements.append(requirement_id)
                    evidence_clauses.append(normative_clause)
                if tuple(evidence_requirements) != tuple(sorted(set(evidence_requirements))):
                    raise UXBlueprintError(
                        f"behavior evidence must be sorted and unique: {variant_id}"
                    )
                if set(evidence_requirements) != set(behavior_requirements):
                    raise UXBlueprintError(
                        f"evidence requirement mismatch: {variant_id}"
                    )
                if set(behavior_requirements) != {contract.requirement_id}:
                    raise UXBlueprintError(
                        f"behavior owner contradicts state command contract: {variant_id}"
                    )
                if owned_fields != set(BEHAVIOR_OWNED_FIELDS):
                    raise UXBlueprintError(
                        f"behavior fields lack exact ownership: {variant_id}"
                    )
                for command in allowed_commands:
                    if BANNED_VISIBLE_INTERNAL_LANGUAGE.search(command):
                        raise UXBlueprintError(
                            f"command exposes internal language: {variant_id} {command}"
                        )
                    pattern = re.compile(
                        rf"(?<!\w){re.escape(command)}(?!\w)", re.IGNORECASE
                    )
                    if not any(pattern.search(clause) for clause in evidence_clauses):
                        raise UXBlueprintError(
                            f"command lacks exact lexical ownership: {variant_id} {command}"
                        )
            else:
                raise UXBlueprintError(f"unsupported behavior authority: {variant_id}")
            if "Undo" in allowed_commands and (
                "CONTROL-UNDO-RECOVERY-001" not in variant.get("requirement_ids", [])
            ):
                raise UXBlueprintError(
                    "Undo command omits CONTROL-UNDO-RECOVERY-001: "
                    f"{variant_id}"
                )
            if variant_id == "UX-STATE-VARIANT-TRUST-INLINE-NO-DISCLOSURE":
                if displayed_objects or allowed_commands or variant.get(
                    "visible_content_copy"
                ) != "":
                    raise UXBlueprintError(
                        "no-disclosure variant must render no trust object, copy, or command"
                    )
            elif not displayed_objects or (
                behavior_posture == "requirement_backed" and not allowed_commands
            ):
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
            if behavior_posture == "requirement_backed" and screen_id in (
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
                    if match is None:
                        raise UXBlueprintError(
                            f"command transition is not exact: {variant_id}"
                        )
                    command, _destination, effect, _focus = match.groups()
                    if " or " in command.casefold():
                        raise UXBlueprintError(
                            f"command transition is not exact: {variant_id}"
                        )
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
    for gap_id, state_ids in observed_gap_states.items():
        if declared_gap_states[gap_id] != tuple(sorted(state_ids)):
            raise UXBlueprintError(
                f"gap affected state inventory is stale: {gap_id}"
            )
    requirement_backed_state_ids = {
        _string(variant.get("blueprint_id"), "state variant ID")
        for model in states
        for variant in _records(model.get("variants"), "state variants")
        if variant.get("behavior_authority_posture") == "requirement_backed"
    }
    if set(state_contracts_by_id) != requirement_backed_state_ids:
        raise UXBlueprintError(
            "structured state command contract inventory must exactly equal "
            "requirement-backed blueprint states"
        )
    setup_first_use = next(
        model for model in states if model["screen_id"] == "UX-SCREEN-SETUP-FIRST-USE"
    )
    if {
        variant["variant_key"] for variant in setup_first_use["variants"]
    } != set(lifecycle_states):
        raise UXBlueprintError("setup lifecycle variants contradict setup contract")
    setup_resume = next(
        model for model in states if model["screen_id"] == "UX-SCREEN-SETUP-RESUME"
    )
    resume_keys = {variant["variant_key"] for variant in setup_resume["variants"]}
    if set(resume_mapping) != resume_keys:
        raise UXBlueprintError("setup resume checkpoint mapping is incomplete")

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

    if len(screens) != 47 or len(states) != 47 or len(objects) != 18 or len(journeys) != 12 or len(cross) != 11:
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
        f"- Specification gaps: `{len(blueprint['specification_gaps'])}`; all gap-blocked behavior is ineligible for Phase 2 authority and task-pack selection.",
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
            "| Variant ID | Screen | Variant | Generic kind | Behavior posture | Visible contract | Commands | Requirements |",
            "| --- | --- | --- | --- | --- | --- | --- | --- |",
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
                f"`{variant['behavior_authority_posture']}` | "
                f"{variant['visible_content_copy']} | {commands} | {requirements} |"
            )
    lines.extend(
        [
            "",
            "## Specification gaps",
            "",
            f"These {len(blueprint['specification_gaps'])} specification gaps fail closed. A linked state with posture "
            "`exploratory_blocked_by_specification_gap` is design exploration only and "
            "must not be selected as Phase 2 visual authority or emitted as task-pack behavior.",
            "",
            "| Gap ID | Affected screen families | Blocked fields | Authority consequence |",
            "| --- | --- | --- | --- |",
        ]
    )
    for gap in blueprint["specification_gaps"]:  # type: ignore[index]
        lines.append(
            f"| `{gap['gap_id']}` | {', '.join(gap['affected_screen_families'])} | "
            f"{', '.join(gap['blocked_fields'])} | {gap['authority_consequence']} |"
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


def state_variant_is_authority_eligible(
    blueprint: Mapping[str, object],
    variant_id: str,
    root: Path | None = None,
) -> bool:
    """Fail closed when a Phase 2 consumer asks for unresolved behavior."""

    return variant_id in authority_eligible_state_variant_ids(blueprint, root)


def authority_eligible_state_variant_ids(
    blueprint: Mapping[str, object], root: Path | None = None
) -> frozenset[str]:
    """Return eligible IDs only after validating current local source and canon."""

    if root is None:
        root = Path(__file__).resolve().parents[2]
    try:
        validate_ux_blueprint(root, blueprint)
    except (UXBlueprintError, OSError):
        return frozenset()
    contracts = {
        contract.state_id: contract
        for contract in load_state_command_contracts(root)
    }
    eligible: set[str] = set()
    for model in blueprint.get("state_models", []):  # type: ignore[union-attr]
        for variant in model.get("variants", []):
            behavior_requirements = variant.get("behavior_requirement_ids")
            if (
                variant.get("behavior_authority_posture") == "requirement_backed"
                and isinstance(behavior_requirements, list)
                and bool(behavior_requirements)
                and not variant.get("specification_gap_ids")
                and set(behavior_requirements)
                <= set(variant.get("requirement_ids", []))
                and variant.get("blueprint_id") in contracts
                and contracts[str(variant["blueprint_id"])].activation_posture.value
                == "active"
            ):
                eligible.add(str(variant["blueprint_id"]))
    return frozenset(eligible)


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
