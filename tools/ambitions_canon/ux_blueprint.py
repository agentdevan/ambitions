"""Deterministic validation and projection for the visual-rebaseline UX blueprint.

The blueprint is a requirement-linked design input.  It is deliberately outside
the normative specification atlas and cannot activate canon or visual authority.
"""

from __future__ import annotations

import json
import hashlib
import errno
import fcntl
import os
import re
import secrets
import stat
import subprocess
from contextlib import contextmanager
from contextvars import ContextVar
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Iterator, Mapping

from tools.ambitions_canon.build import (
    DIRECTORY_FLAGS,
    READ_FLAGS,
    WRITE_FLAGS,
    _AuditedCanonSnapshot,
    _open_directory_at,
    _load_audited_canon_snapshot,
    _open_directory_absolute_nofollow,
    _read_file_at,
    _read_file_at_with_identity,
    _read_confined_bytes,
    _tree_files_descriptor,
    _fsync_directory,
    _verify_audited_canon_snapshot,
)

from tools.ambitions_canon.model import (
    CanonError,
    CanonRegistry,
    StateCommand,
    StateCommandActivationPosture,
    StateCommandContract,
    StateCommandResolutionPosture,
)
from tools.ambitions_canon.command_resolution_registry import (
    CommandResolutionRegistry,
    compact_resolved_machine_contract,
    _load_command_resolution_registry_bytes,
    resolve_state_command_machine_contract,
    validate_command_resolution_bindings,
)
from tools.ambitions_canon.parser import (
    validate_state_command_contract_semantics,
)


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
SEARCH_FIND_ASK_ACT_INSPECT_STATE_IDS = (
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED",
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-INTERRUPTED",
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RECOVERED",
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RESUMED",
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-UNAVAILABLE-OFFLINE-FALLBACK",
    "UX-STATE-VARIANT-SEARCH-RESULTS-CAPTURE-HANDOFF",
    "UX-STATE-VARIANT-SEARCH-RESULTS-GROUNDED-ANSWER",
    "UX-STATE-VARIANT-SEARCH-RESULTS-SYNTHESIS-IN-PROGRESS",
)
SEARCH_FIND_ASK_ACT_INSPECT_VISUAL_REQUIREMENT_IDS = frozenset(
    {
        "JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT-001",
        "LAW-SEARCH-PRIVATE-COMMAND-LAYER-001",
        "SPEC-GLOBAL-SEARCH-ANSWER-EVIDENCE-001",
        "SPEC-GLOBAL-SEARCH-ASK-001",
        "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
        "SPEC-GLOBAL-SEARCH-CAPTURE-HANDOFF-001",
        "SPEC-GLOBAL-SEARCH-FIND-001",
        "SPEC-GLOBAL-SEARCH-INPUT-001",
        "SPEC-GLOBAL-SEARCH-INSPECT-001",
        "SPEC-GLOBAL-SEARCH-PRESENTATION-001",
        "SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001",
    }
)
SEARCH_FIND_ASK_ACT_INSPECT_STATE_REQUIREMENT_MATRIX = {
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED": frozenset(
        {
            "LAW-SEARCH-PRIVATE-COMMAND-LAYER-001",
            "SPEC-GLOBAL-SEARCH-ASK-001",
            "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
            "SPEC-GLOBAL-SEARCH-PRESENTATION-001",
            "SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001",
        }
    ),
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-INTERRUPTED": frozenset(
        {
            "JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT-001",
            "SPEC-GLOBAL-SEARCH-ASK-001",
            "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
            "SPEC-GLOBAL-SEARCH-INPUT-001",
        }
    ),
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RECOVERED": frozenset(
        {
            "SPEC-GLOBAL-SEARCH-ANSWER-EVIDENCE-001",
            "SPEC-GLOBAL-SEARCH-ASK-001",
            "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
            "SPEC-GLOBAL-SEARCH-INSPECT-001",
            "SPEC-GLOBAL-SEARCH-PRESENTATION-001",
        }
    ),
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RESUMED": frozenset(
        {
            "SPEC-GLOBAL-SEARCH-ASK-001",
            "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
            "SPEC-GLOBAL-SEARCH-INPUT-001",
        }
    ),
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-UNAVAILABLE-OFFLINE-FALLBACK": frozenset(
        {
            "JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT-001",
            "LAW-SEARCH-PRIVATE-COMMAND-LAYER-001",
            "SPEC-GLOBAL-SEARCH-ASK-001",
            "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
            "SPEC-GLOBAL-SEARCH-FIND-001",
            "SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001",
        }
    ),
    "UX-STATE-VARIANT-SEARCH-RESULTS-CAPTURE-HANDOFF": frozenset(
        {
            "JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT-001",
            "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
            "SPEC-GLOBAL-SEARCH-CAPTURE-HANDOFF-001",
            "SPEC-GLOBAL-SEARCH-INPUT-001",
        }
    ),
    "UX-STATE-VARIANT-SEARCH-RESULTS-GROUNDED-ANSWER": frozenset(
        {
            "JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT-001",
            "LAW-SEARCH-PRIVATE-COMMAND-LAYER-001",
            "SPEC-GLOBAL-SEARCH-ANSWER-EVIDENCE-001",
            "SPEC-GLOBAL-SEARCH-ASK-001",
            "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
            "SPEC-GLOBAL-SEARCH-INPUT-001",
            "SPEC-GLOBAL-SEARCH-INSPECT-001",
            "SPEC-GLOBAL-SEARCH-PRESENTATION-001",
            "SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001",
        }
    ),
    "UX-STATE-VARIANT-SEARCH-RESULTS-SYNTHESIS-IN-PROGRESS": frozenset(
        {
            "SPEC-GLOBAL-SEARCH-ASK-001",
            "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
            "SPEC-GLOBAL-SEARCH-FIND-001",
            "SPEC-GLOBAL-SEARCH-INPUT-001",
            "SPEC-GLOBAL-SEARCH-PRESENTATION-001",
        }
    ),
}
SEARCH_FIND_ASK_ACT_INSPECT_REQUIREMENT_STATE_SETS = {
    requirement_id: frozenset(
        state_id
        for state_id, requirement_ids in (
            SEARCH_FIND_ASK_ACT_INSPECT_STATE_REQUIREMENT_MATRIX.items()
        )
        if requirement_id in requirement_ids
    )
    for requirement_id in SEARCH_FIND_ASK_ACT_INSPECT_VISUAL_REQUIREMENT_IDS
}
SEARCH_SESSION_HISTORY_REQUIREMENT_ID = "SPEC-GLOBAL-SEARCH-SESSION-HISTORY-001"
SEARCH_ASK_COMMAND_REQUIREMENT_ID = (
    "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001"
)
SEARCH_ASK_ACTIVATION_GATE_REQUIREMENT_ID = (
    "SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"
)
SEARCH_ASK_COMMAND_OWNER = "global.search.ask-command-contract"
SEARCH_ASK_COMMAND_IDS = {
    state_id: state_id.replace("UX-STATE-VARIANT-", "CMD-") + "-001"
    for state_id in SEARCH_FIND_ASK_ACT_INSPECT_STATE_IDS
}
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
    add(
        "UX-SCREEN-SEARCH-RESULTS",
        {
            "ask-failed": ("failure", "operation", "failed"),
            "ask-interrupted": (
                "interruption",
                "interruption",
                "not_applicable",
            ),
            "ask-recovered": ("recovery", "recovery", "succeeded"),
            "ask-resumed": ("recovery", "recovery", "in_progress"),
            "ask-unavailable-offline-fallback": (
                "degraded",
                "availability",
                "not_applicable",
            ),
            "capture-handoff": ("transitional", "operation", "idle"),
            "grounded-answer": (
                "resting",
                "presentation",
                "not_applicable",
            ),
            "synthesis-in-progress": (
                "loading",
                "operation",
                "in_progress",
            ),
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
        "future_gated_commands",
        "machine_command_contracts",
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
FUTURE_GATED_COMMAND_FIELDS = frozenset(
    {"activation_posture", "command_id", "gate_requirement_ids", "label"}
)
BEHAVIOR_OWNED_FIELDS = frozenset(
    {
        "accessibility_focus",
        "allowed_commands",
        "durable_effect",
        "future_gated_commands",
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
class _CapturedInput:
    path: Path
    content: bytes
    identity: tuple[int, int, int, int, int]


@dataclass(frozen=True, slots=True)
class _UXOperationCommitAttestation:
    """Exact immutable input identity bound at the writer's commit point."""

    canon_content_sha: str
    inputs: tuple[_CapturedInput, ...]
    input_identity_sha256: str


@dataclass(slots=True)
class _UXOperationCommitState:
    attestation: _UXOperationCommitAttestation | None = None


@dataclass(frozen=True, slots=True)
class _UXOperationContext:
    """Loader-owned immutable identity for every input consumed by an operation."""

    root: Path
    root_descriptor: int
    canon: _AuditedCanonSnapshot
    command_resolution_registry: CommandResolutionRegistry
    command_gate_registry: object
    inputs: tuple[_CapturedInput, ...]
    excluded_paths: frozenset[Path]
    include_visual_evidence: bool
    commit_state: _UXOperationCommitState


_ACTIVE_OPERATION: ContextVar[_UXOperationContext | None] = ContextVar(
    "ambitions_ux_operation", default=None
)


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
    context = _ACTIVE_OPERATION.get()
    try:
        source = (
            _captured_input_bytes(context, BLUEPRINT_PATH)
            if context is not None
            else _read_confined_bytes(root, BLUEPRINT_PATH)
        )
        payload = json.loads(source)
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise UXBlueprintError(f"cannot load UX blueprint: {error}") from error
    if not isinstance(payload, dict):
        raise UXBlueprintError("UX blueprint root must be an object")
    return payload


def _freeze_mapping(
    value: Mapping[str, object], label: str
) -> dict[str, object]:
    """Detach caller-owned containers after the audited context is captured."""

    try:
        keys = tuple(value)
        first_read = {key: value.get(key) for key in keys}
        second_read = {key: value.get(key) for key in keys}
        if first_read != second_read:
            raise UXBlueprintError(f"{label} changed during capture")
        frozen = json.loads(
            json.dumps(second_read, ensure_ascii=False, sort_keys=True)
        )
    except (TypeError, ValueError, json.JSONDecodeError) as error:
        raise UXBlueprintError(f"{label} is not a closed JSON object") from error
    if not isinstance(frozen, dict):
        raise UXBlueprintError(f"{label} must be an object")
    return frozen


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


def _source_path_digest_at(root_descriptor: int, relative_path: Path) -> str:
    """Hash a file/tree below a pinned root without following any link."""

    try:
        directory_descriptor = _open_directory_path_at(
            root_descriptor, relative_path
        )
    except (CanonError, OSError):
        directory_descriptor = None
    if directory_descriptor is None:
        try:
            return hashlib.sha256(
                _read_stable_source_file_at(root_descriptor, relative_path)
            ).hexdigest()
        except (CanonError, OSError) as error:
            raise UXBlueprintError(
                f"source document path is unsafe: {relative_path.as_posix()}"
            ) from error
    try:
        paths = tuple(
            path
            for path in _tree_files_descriptor(directory_descriptor)
            if "__pycache__" not in path.parts
        )
        if not paths:
            raise UXBlueprintError(
                f"source document directory is empty: {relative_path.as_posix()}"
            )
        digest = hashlib.sha256()
        for child in paths:
            framed_path = child.as_posix().encode("utf-8")
            digest.update(len(framed_path).to_bytes(8, "big"))
            digest.update(framed_path)
            try:
                content = _read_stable_source_file_at(
                    directory_descriptor, child
                )
            except (CanonError, OSError) as error:
                raise UXBlueprintError(
                    f"source document path is unsafe: "
                    f"{(relative_path / child).as_posix()}"
                ) from error
            digest.update(len(content).to_bytes(8, "big"))
            digest.update(content)
        return digest.hexdigest()
    finally:
        os.close(directory_descriptor)


def _read_stable_source_file_at(
    root_descriptor: int, relative_path: Path
) -> bytes:
    descriptors = [os.dup(root_descriptor)]
    try:
        current = descriptors[0]
        for component in relative_path.parts[:-1]:
            current = _open_directory_at(current, component)
            descriptors.append(current)
        expected = os.stat(
            relative_path.parts[-1],
            dir_fd=current,
            follow_symlinks=False,
        )
        if not stat.S_ISREG(expected.st_mode):
            raise UXBlueprintError(
                f"source document path is unsafe: {relative_path.as_posix()}"
            )
        descriptor = os.open(
            relative_path.parts[-1], READ_FLAGS, dir_fd=current
        )
        descriptors.append(descriptor)
        before = os.fstat(descriptor)
        if (
            not stat.S_ISREG(before.st_mode)
            or (before.st_dev, before.st_ino)
            != (expected.st_dev, expected.st_ino)
        ):
            raise UXBlueprintError(
                "source document identity changed before open: "
                f"{relative_path.as_posix()}"
            )
        chunks: list[bytes] = []
        while chunk := os.read(descriptor, 64 * 1024):
            chunks.append(chunk)
        after = os.fstat(descriptor)
        live = os.stat(
            relative_path.parts[-1],
            dir_fd=current,
            follow_symlinks=False,
        )
        before_identity = (
            before.st_dev,
            before.st_ino,
            before.st_size,
            before.st_mtime_ns,
            before.st_ctime_ns,
        )
        after_identity = (
            after.st_dev,
            after.st_ino,
            after.st_size,
            after.st_mtime_ns,
            after.st_ctime_ns,
        )
        live_identity = (
            live.st_dev,
            live.st_ino,
            live.st_size,
            live.st_mtime_ns,
            live.st_ctime_ns,
        )
        if before_identity != after_identity or after_identity != live_identity:
            raise UXBlueprintError(
                "source document changed during validation: "
                f"{relative_path.as_posix()}"
            )
        return b"".join(chunks)
    except UXBlueprintError:
        raise
    except OSError as error:
        raise UXBlueprintError(
            f"source document path is unsafe: {relative_path.as_posix()}"
        ) from error
    finally:
        for descriptor in reversed(descriptors):
            os.close(descriptor)


def _source_path_digest_from_context(
    context: _UXOperationContext,
    relative_path: Path,
) -> str:
    exact = tuple(item for item in context.inputs if item.path == relative_path)
    if len(exact) == 1:
        return hashlib.sha256(exact[0].content).hexdigest()
    children: list[tuple[Path, bytes]] = []
    for item in context.inputs:
        try:
            child = item.path.relative_to(relative_path)
        except ValueError:
            continue
        if child.parts and "__pycache__" not in child.parts:
            children.append((child, item.content))
    if not children:
        raise UXBlueprintError(
            f"source document path is unsafe: {relative_path.as_posix()}"
        )
    digest = hashlib.sha256()
    for child, content in sorted(children, key=lambda item: item[0].as_posix()):
        framed_path = child.as_posix().encode("utf-8")
        digest.update(len(framed_path).to_bytes(8, "big"))
        digest.update(framed_path)
        digest.update(len(content).to_bytes(8, "big"))
        digest.update(content)
    return digest.hexdigest()


def validate_source_documents(
    root: Path, records: object
) -> tuple[tuple[str, str], ...]:
    source_records = _records(records, "source documents")
    normalized: list[tuple[str, str]] = []
    paths: list[Path] = []
    context = _ACTIVE_OPERATION.get()
    if context is not None:
        for record in source_records:
            _closed(record, SOURCE_DOCUMENT_FIELDS, "source document fields")
            relative = _string(record.get("path"), "source document path")
            declared = _string(record.get("sha256"), "source document digest")
            relative_path = Path(relative)
            if (
                relative_path.is_absolute()
                or ".." in relative_path.parts
                or not relative_path.parts
            ):
                raise UXBlueprintError(f"source document path is unsafe: {relative}")
            if not re.fullmatch(r"[0-9a-f]{64}", declared):
                raise UXBlueprintError(
                    f"source document digest is invalid: {relative}"
                )
            actual = _source_path_digest_from_context(context, relative_path)
            if actual != declared:
                raise UXBlueprintError(
                    f"source content digest is stale for {relative}: "
                    f"declared={declared} actual={actual}"
                )
            normalized.append((relative, declared))
        if normalized != sorted(set(normalized)):
            raise UXBlueprintError(
                "source documents must be sorted and unique by path"
            )
        return tuple(normalized)
    absolute_root = Path(os.path.abspath(root))
    with _open_directory_absolute_nofollow(absolute_root) as root_descriptor:
        first_digests: list[str] = []
        for record in source_records:
            _closed(record, SOURCE_DOCUMENT_FIELDS, "source document fields")
            relative = _string(record.get("path"), "source document path")
            declared = _string(record.get("sha256"), "source document digest")
            relative_path = Path(relative)
            if (
                relative_path.is_absolute()
                or ".." in relative_path.parts
                or not relative_path.parts
            ):
                raise UXBlueprintError(f"source document path is unsafe: {relative}")
            if not re.fullmatch(r"[0-9a-f]{64}", declared):
                raise UXBlueprintError(
                    f"source document digest is invalid: {relative}"
                )
            actual = _source_path_digest_at(root_descriptor, relative_path)
            if actual != declared:
                raise UXBlueprintError(
                    f"source content digest is stale for {relative}: "
                    f"declared={declared} actual={actual}"
                )
            paths.append(relative_path)
            first_digests.append(actual)
            normalized.append((relative, declared))
        second_digests = [
            _source_path_digest_at(root_descriptor, path) for path in paths
        ]
        if second_digests != first_digests:
            raise UXBlueprintError(
                "source document changed during validation"
            )
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


def _open_directory_path_at(root_descriptor: int, relative: Path) -> int:
    current = os.dup(root_descriptor)
    try:
        for component in relative.parts:
            next_descriptor = _open_directory_at(current, component)
            os.close(current)
            current = next_descriptor
        return current
    except BaseException:
        os.close(current)
        raise


def _operation_paths(
    root_descriptor: int,
    *,
    include_visual_evidence: bool,
) -> tuple[Path, ...]:
    """Enumerate the closed input trees beneath one pinned repository root."""

    roots = [Path("docs/canon")]
    if include_visual_evidence:
        roots.append(Path("docs/qa/evidence"))
    paths: list[Path] = []
    for relative_root in roots:
        try:
            descriptor = _open_directory_path_at(root_descriptor, relative_root)
        except (FileNotFoundError, CanonError, OSError):
            continue
        try:
            paths.extend(
                relative_root / child
                for child in _tree_files_descriptor(descriptor)
            )
        finally:
            os.close(descriptor)
    try:
        _read_file_at(root_descriptor, REPAIR_MATRIX_PATH)
    except (CanonError, OSError):
        pass
    else:
        paths.append(REPAIR_MATRIX_PATH)
    try:
        blueprint_source = _read_file_at(root_descriptor, BLUEPRINT_PATH)
        blueprint = json.loads(blueprint_source)
        declared_sources = blueprint.get("source_documents", [])
    except (CanonError, OSError, UnicodeError, json.JSONDecodeError, AttributeError):
        declared_sources = []
    for record in declared_sources:
        if not isinstance(record, dict) or not isinstance(record.get("path"), str):
            continue
        relative = Path(record["path"])
        if relative.is_absolute() or not relative.parts or ".." in relative.parts:
            continue
        try:
            descriptor = _open_directory_path_at(root_descriptor, relative)
        except (CanonError, OSError):
            paths.append(relative)
            continue
        try:
            paths.extend(relative / child for child in _tree_files_descriptor(descriptor))
        finally:
            os.close(descriptor)
    return tuple(sorted(set(paths), key=Path.as_posix))


def _capture_operation_inputs(
    root_descriptor: int,
    *,
    include_visual_evidence: bool,
    excluded_paths: frozenset[Path],
) -> tuple[_CapturedInput, ...]:
    result: list[_CapturedInput] = []
    for relative in _operation_paths(
        root_descriptor,
        include_visual_evidence=include_visual_evidence,
    ):
        if relative in excluded_paths:
            continue
        if relative.name.startswith(".") and relative.name.endswith(
            (
                ".tmp",
                ".backup",
                ".recovery",
                ".prepared-cleanup.json",
                ".committed-cleanup.json",
            )
        ):
            continue
        try:
            content, identity = _read_file_at_with_identity(
                root_descriptor, relative
            )
        except (CanonError, OSError) as error:
            raise UXBlueprintError(
                f"audited operation input is unsafe: {relative.as_posix()}"
            ) from error
        result.append(
            _CapturedInput(path=relative, content=content, identity=identity)
        )
    return tuple(result)


def _captured_input_bytes(
    context: _UXOperationContext,
    relative: Path,
) -> bytes:
    matches = tuple(item for item in context.inputs if item.path == relative)
    if len(matches) != 1:
        raise UXBlueprintError(
            f"audited operation input was not captured: {relative.as_posix()}"
        )
    return matches[0].content


def _operation_input_identity_sha256(
    inputs: tuple[_CapturedInput, ...],
) -> str:
    digest = hashlib.sha256()
    for item in inputs:
        path = item.path.as_posix().encode("utf-8")
        digest.update(len(path).to_bytes(8, "big"))
        digest.update(path)
        digest.update(len(item.content).to_bytes(8, "big"))
        digest.update(item.content)
        for value in item.identity:
            digest.update(value.to_bytes(16, "big", signed=False))
    return digest.hexdigest()


def _verify_operation_context(
    context: _UXOperationContext,
    *,
    projection_locked: bool = False,
) -> None:
    try:
        _verify_audited_canon_snapshot(context.root, context.canon)
        if projection_locked:
            current = _capture_operation_inputs(
                context.root_descriptor,
                include_visual_evidence=context.include_visual_evidence,
                excluded_paths=context.excluded_paths,
            )
        else:
            with _projection_lock(
                context.root_descriptor, exclusive=False
            ):
                current = _capture_operation_inputs(
                    context.root_descriptor,
                    include_visual_evidence=context.include_visual_evidence,
                    excluded_paths=context.excluded_paths,
                )
    except (CanonError, OSError, UXBlueprintError) as error:
        raise UXBlueprintError(
            "canonical source changed during UX blueprint operation; "
            "audited operation input changed during validation"
        ) from error
    if current != context.inputs:
        raise UXBlueprintError(
            "canonical source changed during UX blueprint operation; "
            "audited operation input changed during validation"
        )


@contextmanager
def _ux_operation(
    root: Path,
    *,
    include_visual_evidence: bool = False,
    excluded_paths: frozenset[Path] = frozenset(),
) -> Iterator[_UXOperationContext]:
    """Capture and end-verify one private, pinned, audited operation context."""

    active = _ACTIVE_OPERATION.get()
    absolute_root = Path(os.path.abspath(root))
    if active is not None:
        if active.root != absolute_root:
            raise UXBlueprintError("nested UX operation changed repository root")
        yield active
        return
    with _open_directory_absolute_nofollow(absolute_root) as root_descriptor:
        canon = _load_audited_canon_snapshot(absolute_root)
        with _projection_lock(root_descriptor, exclusive=False):
            inputs = _capture_operation_inputs(
                root_descriptor,
                include_visual_evidence=include_visual_evidence,
                excluded_paths=excluded_paths,
            )
        resolution_registry = _load_command_resolution_registry_bytes(
            absolute_root,
            next(
                item.content
                for item in inputs
                if item.path
                == Path("docs/canon/registries/command-resolution-registry.json")
            ),
            captured_sources={item.path: item.content for item in inputs},
        )
        from tools.ambitions_canon.command_gate_dependencies import (
            _COMMAND_GATE_INPUT_PATHS,
            _load_command_gate_dependency_registry_for_audited_canon,
        )

        command_gate_registry = (
            _load_command_gate_dependency_registry_for_audited_canon(
                absolute_root,
                canon,
                expected_canon_revision=canon.registry.manifest.canon_revision,
                captured_inputs=tuple(
                    (item.path, item.content)
                    for item in inputs
                    if item.path in _COMMAND_GATE_INPUT_PATHS
                ),
            )
        )
        context = _UXOperationContext(
            root=absolute_root,
            root_descriptor=root_descriptor,
            canon=canon,
            command_resolution_registry=resolution_registry,
            command_gate_registry=command_gate_registry,
            inputs=inputs,
            excluded_paths=excluded_paths,
            include_visual_evidence=include_visual_evidence,
            commit_state=_UXOperationCommitState(),
        )
        _verify_operation_context(context)
        token = _ACTIVE_OPERATION.set(context)
        try:
            try:
                yield context
            except BaseException as operation_error:
                if context.commit_state.attestation is None:
                    try:
                        _verify_operation_context(context)
                    except UXBlueprintError as freshness_error:
                        raise freshness_error from operation_error
                raise
            else:
                if context.commit_state.attestation is None:
                    _verify_operation_context(context)
                elif (
                    context.commit_state.attestation.canon_content_sha
                    != context.canon.content_sha
                    or context.commit_state.attestation.inputs != context.inputs
                    or context.commit_state.attestation.input_identity_sha256
                    != _operation_input_identity_sha256(context.inputs)
                ):
                    raise UXBlueprintError(
                        "committed UX operation attestation is internally stale"
                    )
        finally:
            _ACTIVE_OPERATION.reset(token)


def _requirement_ids(
    source_snapshot: _AuditedCanonSnapshot,
) -> tuple[frozenset[str], str, int, str]:
    registry = source_snapshot.registry
    return (
        frozenset(item.requirement_id for item in registry.requirements),
        source_snapshot.content_sha,
        registry.manifest.canon_revision,
        registry.manifest.authority_state.value,
    )


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


def load_requirement_source_records(
    root: Path,
) -> tuple[dict[str, str], ...]:
    """Load exact normative requirement text from the human-editable canon."""

    with _ux_operation(root) as context:
        return _load_requirement_source_records(root, context.canon)


def _load_requirement_source_records(
    root: Path,
    snapshot: _AuditedCanonSnapshot,
) -> tuple[dict[str, str], ...]:
    result = tuple(
        {
            "requirement_id": requirement.requirement_id,
            "source_path": requirement.source_path.as_posix(),
            "normative_text": requirement.body,
            "consequence_anchor": _consequence_anchor(requirement.body),
        }
        for requirement in snapshot.registry.requirements
    )
    return result


def load_state_command_contracts(
    root: Path,
) -> tuple[StateCommandContract, ...]:
    """Load independently authored state-command ownership from normative canon."""

    with _ux_operation(root) as context:
        return _load_state_command_contracts(root, context.canon)


def _load_state_command_contracts(
    root: Path,
    snapshot: _AuditedCanonSnapshot,
) -> tuple[StateCommandContract, ...]:
    canon = snapshot.registry
    contracts: list[StateCommandContract] = []
    state_ids: set[str] = set()
    command_ids: set[str] = set()
    for document in canon.documents:
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
    ordered = tuple(sorted(contracts, key=lambda item: item.state_id))
    _validate_search_ask_command_contracts(ordered)
    if any(
        command.gate_dependency_ids
        for contract in ordered
        for command in contract.commands
    ):
        from tools.ambitions_canon.command_gate_dependencies import (
            _validate_command_gate_dependency_bindings_for_audited_canon,
        )
        context = _ACTIVE_OPERATION.get()
        if context is None or context.canon is not snapshot:
            raise UXBlueprintError("state command load lacks audited operation context")
        _validate_command_gate_dependency_bindings_for_audited_canon(
            context.command_gate_registry,
            ordered,
            snapshot,
            canon_revision=canon.manifest.canon_revision,
        )
    context = _ACTIVE_OPERATION.get()
    if context is None or context.canon is not snapshot:
        raise UXBlueprintError("command resolution lacks audited operation context")
    validate_command_resolution_bindings(
        context.command_resolution_registry, canon
    )
    return ordered


def _validate_search_ask_command_contracts(
    contracts: tuple[StateCommandContract, ...],
) -> None:
    """Keep the eight shadow Search controls exact and non-authorizing."""

    expected_state_ids = frozenset(SEARCH_FIND_ASK_ACT_INSPECT_STATE_IDS)
    ask_contracts = tuple(
        contract
        for contract in contracts
        if contract.state_id in expected_state_ids
        or contract.requirement_id == SEARCH_ASK_COMMAND_REQUIREMENT_ID
    )
    if (
        frozenset(contract.state_id for contract in ask_contracts)
        != expected_state_ids
        or len(ask_contracts) != len(expected_state_ids)
    ):
        raise UXBlueprintError(
            "Search Ask command contract is stale or authorizing: state inventory"
        )

    exact_gate = (SEARCH_ASK_ACTIVATION_GATE_REQUIREMENT_ID,)
    for contract in ask_contracts:
        expected_command_id = SEARCH_ASK_COMMAND_IDS[contract.state_id]
        if (
            contract.requirement_id != SEARCH_ASK_COMMAND_REQUIREMENT_ID
            or contract.activation_posture
            is not StateCommandActivationPosture.FUTURE_GATED
            or contract.gate_requirement_ids != exact_gate
            or len(contract.commands) != 1
        ):
            raise UXBlueprintError(
                "Search Ask command contract is stale or authorizing: "
                f"{contract.state_id}"
            )
        command = contract.commands[0]
        if (
            command.command_id != expected_command_id
            or command.canonical_owner != SEARCH_ASK_COMMAND_OWNER
            or command.recovery_owner != SEARCH_ASK_COMMAND_OWNER
            or command.activation_posture
            is not StateCommandActivationPosture.FUTURE_GATED
            or command.gate_requirement_ids != exact_gate
        ):
            raise UXBlueprintError(
                "Search Ask command contract is stale or authorizing: "
                f"{contract.state_id} {command.command_id}"
            )


def _state_command_source_paths(
    source_snapshot: _AuditedCanonSnapshot,
) -> dict[str, Path]:
    """Map every closed state identity to its repository-relative source path."""

    result: dict[str, Path] = {}
    for document in source_snapshot.registry.documents:
        for contract in document.state_command_contracts:
            result[contract.state_id] = document.source_path
    return result


def declared_current_state_commands(
    contract: StateCommandContract,
) -> tuple[StateCommand, ...]:
    """Filter current declarations only; this function grants no authority."""

    return tuple(
        command
        for command in contract.commands
        if command.activation_posture is StateCommandActivationPosture.ACTIVE
        and all(
            posture is StateCommandResolutionPosture.CURRENT
            for posture in (
                command.destination_posture,
                command.success_focus_posture,
                command.failure_focus_posture,
                command.recovery_posture,
            )
        )
    )


def machine_state_command_contracts(
    contract: StateCommandContract,
    source_path: Path,
    registry: CommandResolutionRegistry,
) -> tuple[dict[str, object], ...]:
    """Resolve every active or future machine identity through the registry."""

    return tuple(
        compact_resolved_machine_contract(
            resolve_state_command_machine_contract(
                registry,
                source_path,
                contract,
                command,
            )
        )
        for command in contract.commands
    )


def future_gated_state_commands(
    contract: StateCommandContract,
) -> tuple[dict[str, object], ...]:
    """Project non-authorizing future commands with their exact machine gates."""

    return tuple(
        {
            "activation_posture": "future_gated",
            "command_id": command.command_id,
            "gate_requirement_ids": list(command.gate_requirement_ids),
            "label": command.label,
        }
        for command in contract.commands
        if command.activation_posture is StateCommandActivationPosture.FUTURE_GATED
    )


def active_state_transition_exit(contract: StateCommandContract) -> str:
    """Render only currently authorizing routes into the active blueprint field."""

    commands = declared_current_state_commands(contract)
    if not commands:
        future_ids = ", ".join(
            command.command_id
            for command in contract.commands
            if command.activation_posture
            is StateCommandActivationPosture.FUTURE_GATED
        )
        return (
            "No active command is exposed; future-gated command metadata "
            f"{future_ids} remains non-authorizing."
        )
    return "\n".join(
        f"{item.label} => destination: {item.destination}; effect: "
        f"{item.effect}; focus: {item.success_focus}."
        for item in commands
    )


def load_state_inventory(root: Path) -> dict[str, object]:
    """Load the explicit matrix-bound state inventory used by validation."""

    context = _ACTIVE_OPERATION.get()
    matrix_bytes = (
        _captured_input_bytes(context, REPAIR_MATRIX_PATH)
        if context is not None
        else _read_confined_bytes(root, REPAIR_MATRIX_PATH)
    )
    if hashlib.sha256(matrix_bytes).hexdigest() != REPAIR_MATRIX_SHA256:
        raise UXBlueprintError("visual repair matrix bytes are stale")
    try:
        inventory_bytes = (
            _captured_input_bytes(context, STATE_INVENTORY_PATH)
            if context is not None
            else _read_confined_bytes(root, STATE_INVENTORY_PATH)
        )
        payload = json.loads(inventory_bytes)
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

    with _ux_operation(root) as context:
        frozen = _freeze_mapping(blueprint, "UX blueprint")
        return _build_requirement_dispositions(
            root, frozen, known_blueprint_ids, context.canon
        )


def _build_requirement_dispositions(
    root: Path,
    blueprint: Mapping[str, object],
    known_blueprint_ids: frozenset[str],
    snapshot: _AuditedCanonSnapshot,
) -> tuple[dict[str, object], ...]:
    requirements = {
        item["requirement_id"]: item
        for item in _load_requirement_source_records(root, snapshot)
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
    result = tuple(dispositions)
    return result


def _validate_unlinked_gate_requirement_ids(
    blueprint: Mapping[str, object],
    unlinked_gate_ids: frozenset[str],
    known_requirement_ids: frozenset[str],
    state_id: str,
) -> None:
    """Allow only known, explicitly nonvisual gates to remain unlinked visually."""

    dispositions = {
        _string(item.get("requirement_id"), "requirement disposition ID"): item
        for item in _records(
            blueprint.get("requirement_dispositions"), "requirement dispositions"
        )
    }
    allowed = {
        requirement_id
        for requirement_id in unlinked_gate_ids
        if requirement_id in known_requirement_ids
        and requirement_id in dispositions
        and dispositions[requirement_id].get("disposition")
        == "nonvisual_with_rationale"
        and dispositions[requirement_id].get("blueprint_ids") == []
        and dispositions[requirement_id].get("state_blueprint_ids") == []
    }
    if allowed != set(unlinked_gate_ids):
        raise UXBlueprintError(
            f"state command contract requirements are not linked: {state_id}"
        )


def _validate_search_find_ask_act_inspect_mapping(
    blueprint: Mapping[str, object],
) -> None:
    """Keep the owner-approved Search amendment in deterministic UX input law."""

    models = _records(blueprint.get("state_models"), "state models")
    search_models = tuple(
        item
        for item in models
        if item.get("blueprint_id") == "UX-STATE-MODEL-SEARCH-RESULTS"
    )
    if len(search_models) != 1:
        raise UXBlueprintError(
            "Search Find / Ask / Act / Inspect state model is stale"
        )
    variants = _records(
        search_models[0].get("variants"), "Search Results state variants"
    )
    variants_by_id = {
        _string(item.get("blueprint_id"), "Search Results state variant ID"): item
        for item in variants
    }
    expected_state_ids = frozenset(SEARCH_FIND_ASK_ACT_INSPECT_STATE_IDS)
    if not expected_state_ids <= variants_by_id.keys():
        raise UXBlueprintError(
            "Search Find / Ask / Act / Inspect state inventory is stale"
        )

    for state_id in SEARCH_FIND_ASK_ACT_INSPECT_STATE_IDS:
        state = variants_by_id[state_id]
        requirement_ids = frozenset(
            _linked_ids(
                state.get("requirement_ids"),
                "Search Find / Ask / Act / Inspect state requirement IDs",
            )
        )
        if requirement_ids.intersection(
            SEARCH_FIND_ASK_ACT_INSPECT_VISUAL_REQUIREMENT_IDS
        ) != SEARCH_FIND_ASK_ACT_INSPECT_STATE_REQUIREMENT_MATRIX[state_id]:
            raise UXBlueprintError(
                "Search Find / Ask / Act / Inspect state requirement matrix is stale; "
                "Search Find / Ask / Act / Inspect visual requirement mapping is stale"
            )
        behavior_ids = frozenset(
            _linked_ids(
                state.get("behavior_requirement_ids"),
                "Search Find / Ask / Act / Inspect behavior requirement IDs",
            )
        )
        if (
            state.get("behavior_authority_posture") != "requirement_backed"
            or state.get("specification_gap_ids") != []
            or SEARCH_ASK_COMMAND_REQUIREMENT_ID not in requirement_ids
            or SEARCH_ASK_COMMAND_REQUIREMENT_ID not in behavior_ids
        ):
            raise UXBlueprintError(
                "Search Find / Ask / Act / Inspect state authority is stale"
            )
    all_records = tuple(
        item
        for key in (
            "screens",
            "state_models",
            "object_boundaries",
            "journeys",
            "cross_cutting",
            "sensitive_exposure_channels",
        )
        for item in _records(blueprint.get(key), key)
    )
    all_variants = tuple(
        variant
        for model in models
        for variant in _records(model.get("variants"), "state variants")
    )
    if any(
        SEARCH_SESSION_HISTORY_REQUIREMENT_ID
        in item.get("requirement_ids", [])
        for item in (*all_records, *all_variants)
    ):
        raise UXBlueprintError(
            "Search session-history requirement must remain nonvisual"
        )

    dispositions = {
        _string(item.get("requirement_id"), "requirement disposition ID"): item
        for item in _records(
            blueprint.get("requirement_dispositions"), "requirement dispositions"
        )
    }
    for requirement_id in SEARCH_FIND_ASK_ACT_INSPECT_VISUAL_REQUIREMENT_IDS:
        item = dispositions.get(requirement_id)
        if (
            item is None
            or item.get("disposition") != "visual_mapping_required"
            or frozenset(item.get("state_blueprint_ids", []))
            != SEARCH_FIND_ASK_ACT_INSPECT_REQUIREMENT_STATE_SETS[requirement_id]
        ):
            raise UXBlueprintError(
                "Search Find / Ask / Act / Inspect disposition state set is stale"
            )
    session = dispositions.get(SEARCH_SESSION_HISTORY_REQUIREMENT_ID)
    if (
        session is None
        or session.get("disposition") != "nonvisual_with_rationale"
        or session.get("blueprint_ids") != []
        or session.get("state_blueprint_ids") != []
    ):
        raise UXBlueprintError(
            "Search session-history disposition must remain nonvisual"
        )
    activation_gate = dispositions.get(
        SEARCH_ASK_ACTIVATION_GATE_REQUIREMENT_ID
    )
    if (
        activation_gate is None
        or activation_gate.get("disposition") != "nonvisual_with_rationale"
        or activation_gate.get("blueprint_ids") != []
        or activation_gate.get("state_blueprint_ids") != []
    ):
        raise UXBlueprintError(
            "Search Ask activation gate disposition must remain nonvisual"
        )


def _disposition_bytes(dispositions: tuple[dict[str, object], ...]) -> bytes:
    return (
        json.dumps(dispositions, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
        + "\n"
    ).encode("utf-8")


def render_requirement_dispositions(
    root: Path,
    blueprint: Mapping[str, object],
) -> bytes:
    with _ux_operation(root) as context:
        frozen = _freeze_mapping(blueprint, "UX blueprint")
        return _render_requirement_dispositions(root, frozen, context.canon)


def _render_requirement_dispositions(
    root: Path,
    blueprint: Mapping[str, object],
    snapshot: _AuditedCanonSnapshot,
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
    dispositions = _build_requirement_dispositions(
        root,
        blueprint,
        all_ids,
        snapshot,
    )
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
    result = (json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n").encode(
        "utf-8"
    )
    return result


def validate_ux_blueprint(
    root: Path,
    blueprint: Mapping[str, object],
) -> UXBlueprintSummary:
    with _ux_operation(root) as context:
        frozen = _freeze_mapping(blueprint, "UX blueprint")
        return _validate_ux_blueprint(root, frozen, context.canon)


def _validate_ux_blueprint(
    root: Path,
    blueprint: Mapping[str, object],
    snapshot: _AuditedCanonSnapshot,
) -> UXBlueprintSummary:
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

    known_requirements, canon_sha, canon_revision, authority_state = _requirement_ids(
        snapshot
    )
    # The UX blueprint remains an immutable pre-cutover migration snapshot after
    # canon activation. Active mode still verifies that snapshot's exact canon
    # identity; it must never turn the digest check off.
    expected_canon_sha = (
        canon_sha
        if authority_state == "shadow"
        else "b256dc7ceb74c1300aea9980758792692002be102ff706dfcc4a34d8a9a795fe"
    )
    if blueprint.get("canon_content_sha") != expected_canon_sha:
        raise UXBlueprintError("canon content SHA is stale")
    if blueprint.get("canon_revision") != canon_revision:
        raise UXBlueprintError("canon revision is stale")
    if authority_state not in {"shadow", "active"}:
        raise UXBlueprintError("requirement graph authority state is invalid")

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
    context = _ACTIVE_OPERATION.get()
    if context is None or context.canon is not snapshot:
        raise UXBlueprintError("blueprint validation lacks audited operation context")
    state_contracts = _load_state_command_contracts(root, snapshot)
    state_contracts_by_id = {item.state_id: item for item in state_contracts}
    state_source_paths = _state_command_source_paths(snapshot)
    resolution_registry = context.command_resolution_registry
    for contract in state_contracts:
        validate_state_command_contract_semantics(
            root / "docs/canon/manifest.toml",
            contract,
        )
        if contract.requirement_id not in known_requirements:
            raise UXBlueprintError(
                f"state contract references unknown requirement: {contract.state_id}"
            )
        if set(contract.gate_requirement_ids) - known_requirements:
            raise UXBlueprintError(
                f"state contract references unknown gate requirement: {contract.state_id}"
            )
        for command in contract.commands:
            if set(command.gate_requirement_ids) - known_requirements:
                raise UXBlueprintError(
                    "state command references unknown gate requirement: "
                    f"{command.command_id}"
                )
    matrix = json.loads(_captured_input_bytes(context, REPAIR_MATRIX_PATH))
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
        for record in _load_requirement_source_records(root, snapshot)
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
            future_command_values = _possibly_empty_records(
                variant.get("future_gated_commands"),
                "state variant future-gated commands",
            )
            machine_command_values = _possibly_empty_records(
                variant.get("machine_command_contracts"),
                "state variant machine command contracts",
            )
            future_commands: list[dict[str, object]] = []
            for command_value in future_command_values:
                command = _object(
                    command_value,
                    "state variant future-gated command",
                )
                _closed(
                    command,
                    FUTURE_GATED_COMMAND_FIELDS,
                    "future-gated command fields",
                )
                future_commands.append(command)
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
                    or future_commands
                    or machine_command_values
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
                unlinked_gate_ids = set(contract.gate_requirement_ids) - linked
                if contract.requirement_id not in linked:
                    raise UXBlueprintError(
                        f"state command contract requirements are not linked: {variant_id}"
                    )
                _validate_unlinked_gate_requirement_ids(
                    blueprint,
                    frozenset(unlinked_gate_ids),
                    known_requirements,
                    variant_id,
                )
                expected_labels = tuple(
                    command.label
                    for command in declared_current_state_commands(contract)
                )
                if allowed_commands != expected_labels:
                    raise UXBlueprintError(
                        f"allowed commands drift from structured canon: {variant_id}"
                    )
                expected_future_commands = future_gated_state_commands(contract)
                if tuple(future_commands) != expected_future_commands:
                    raise UXBlueprintError(
                        f"future-gated commands drift from structured canon: {variant_id}"
                    )
                if tuple(machine_command_values) != machine_state_command_contracts(
                    contract,
                    state_source_paths[contract.state_id],
                    resolution_registry,
                ):
                    raise UXBlueprintError(
                        f"machine command contracts drift from structured canon: {variant_id}"
                    )
                for field, expected in {
                    "transition_exit": active_state_transition_exit(contract),
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
                for command in allowed_commands + tuple(
                    _string(item.get("label"), "future-gated command label")
                    for item in future_commands
                ):
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
                if displayed_objects or allowed_commands or future_commands or variant.get(
                    "visible_content_copy"
                ) != "":
                    raise UXBlueprintError(
                        "no-disclosure variant must render no trust object, copy, or command"
                    )
            elif not displayed_objects or (
                behavior_posture == "requirement_backed"
                and not allowed_commands
                and not future_commands
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
            ) and not (future_commands and not allowed_commands):
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

    dispositions = _build_requirement_dispositions(
        root,
        blueprint,
        all_blueprint_ids,
        snapshot,
    )
    _validate_search_find_ask_act_inspect_mapping(blueprint)
    disposition_bytes = _disposition_bytes(dispositions)
    visual_mapping_count = sum(
        item["disposition"] == "visual_mapping_required" for item in dispositions
    )
    nonvisual_count = len(dispositions) - visual_mapping_count

    summary = UXBlueprintSummary(
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
    return summary


def render_ux_blueprint_markdown(
    blueprint: Mapping[str, object],
    root: Path | None = None,
) -> bytes:
    """Render the already-validated source in a stable human-reviewable form."""

    if root is None:
        root = Path(__file__).resolve().parents[2]
    with _ux_operation(root) as context:
        frozen = _freeze_mapping(blueprint, "UX blueprint")
        return _render_ux_blueprint_markdown(frozen, root, context.canon)


def _render_ux_blueprint_markdown(
    blueprint: Mapping[str, object],
    root: Path,
    snapshot: _AuditedCanonSnapshot,
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
    dispositions = _build_requirement_dispositions(
        root,
        blueprint,
        all_ids,
        snapshot,
    )
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
            "| Variant ID | Screen | Variant | Generic kind | Behavior posture | Visible contract | Active commands | Future-gated commands | Machine command identities | Requirements |",
            "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |",
        ]
    )
    for state_model in blueprint["state_models"]:  # type: ignore[index]
        for variant in state_model["variants"]:
            commands = ", ".join(variant["allowed_commands"])
            future_commands = ", ".join(
                f"{item['label']} [{', '.join(item['gate_requirement_ids'])}]"
                for item in variant["future_gated_commands"]
            )
            machine_commands = ", ".join(
                f"`{item['command_id']}` => `{item['destination']['id']}` / "
                f"`{item['success_focus']['id']}` / `{item['failure_focus']['id']}` / "
                f"`{item['recovery']['id']}`"
                for item in variant["machine_command_contracts"]
            )
            requirements = ", ".join(
                f"`{item}`" for item in variant["requirement_ids"]
            )
            lines.append(
                f"| `{variant['blueprint_id']}` | `{state_model['screen_id']}` | "
                f"{variant['title']} | `{variant['generic_kind']}` | "
                f"`{variant['behavior_authority_posture']}` | "
                f"{variant['visible_content_copy']} | {commands} | {future_commands} | "
                f"{machine_commands} | "
                f"{requirements} |"
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
    result = ("\n".join(lines) + "\n").encode("utf-8")
    return result


def state_variant_is_authority_eligible(
    blueprint: Mapping[str, object],
    variant_id: str,
    root: Path | None = None,
) -> bool:
    """Fail closed when a Phase 2 consumer asks for unresolved behavior."""

    return variant_id in authority_eligible_state_variant_ids(blueprint, root)


def authority_eligible_state_variant_ids(
    blueprint: Mapping[str, object],
    root: Path | None = None,
) -> frozenset[str]:
    """Return eligible IDs only after validating current local source and canon."""

    if root is None:
        root = Path(__file__).resolve().parents[2]
    try:
        with _ux_operation(root) as context:
            frozen = _freeze_mapping(blueprint, "UX blueprint")
            _validate_ux_blueprint(root, frozen, context.canon)
            contracts = {
                contract.state_id: contract
                for contract in _load_state_command_contracts(
                    root, context.canon
                )
            }
            eligible: set[str] = set()
            for model in frozen.get("state_models", []):
                for variant in model.get("variants", []):
                    behavior_requirements = variant.get(
                        "behavior_requirement_ids"
                    )
                    if (
                        variant.get("behavior_authority_posture")
                        == "requirement_backed"
                        and isinstance(behavior_requirements, list)
                        and bool(behavior_requirements)
                        and not variant.get("specification_gap_ids")
                        and set(behavior_requirements)
                        <= set(variant.get("requirement_ids", []))
                        and variant.get("blueprint_id") in contracts
                        and contracts[
                            str(variant["blueprint_id"])
                        ].activation_posture.value
                        == "active"
                    ):
                        eligible.add(str(variant["blueprint_id"]))
            return frozenset(eligible)
    except (CanonError, UXBlueprintError, OSError, TypeError, AttributeError):
        return frozenset()


@contextmanager
def _projection_lock(
    root_descriptor: int,
    *,
    exclusive: bool,
) -> Iterator[int]:
    """Coordinate all canon-tool readers with the two-output publisher."""

    descriptor = _open_directory_path_at(
        root_descriptor, PROJECTION_PATH.parent
    )
    try:
        fcntl.flock(
            descriptor,
            fcntl.LOCK_EX if exclusive else fcntl.LOCK_SH,
        )
        yield descriptor
    finally:
        try:
            fcntl.flock(descriptor, fcntl.LOCK_UN)
        finally:
            os.close(descriptor)


def _read_projection_pair_from_descriptor(
    root_descriptor: int,
) -> tuple[bytes, bytes]:
    with _projection_lock(root_descriptor, exclusive=False):
        return (
            _read_file_at(root_descriptor, PROJECTION_PATH),
            _read_file_at(root_descriptor, DISPOSITIONS_PATH),
        )


def _read_projection_pair(root: Path) -> tuple[bytes, bytes]:
    with _open_directory_absolute_nofollow(root) as root_descriptor:
        return _read_projection_pair_from_descriptor(root_descriptor)


def _read_projection_output_locked(root: Path, relative: Path) -> bytes:
    if relative not in {PROJECTION_PATH, DISPOSITIONS_PATH}:
        raise UXBlueprintError("requested path is not a UX projection output")
    with _open_directory_absolute_nofollow(root) as root_descriptor:
        with _projection_lock(root_descriptor, exclusive=False):
            return _read_file_at(root_descriptor, relative)


def check_ux_blueprint(root: Path) -> int:
    try:
        with _ux_operation(root) as context:
            blueprint = load_ux_blueprint(root)
            frozen = _freeze_mapping(blueprint, "UX blueprint")
            _validate_ux_blueprint(root, frozen, context.canon)
            expected = _render_ux_blueprint_markdown(
                frozen, root, context.canon
            )
            actual, actual_dispositions = _read_projection_pair_from_descriptor(
                context.root_descriptor
            )
            expected_dispositions = _render_requirement_dispositions(
                root, frozen, context.canon
            )
    except (CanonError, UXBlueprintError, OSError):
        return 1
    return (
        0
        if actual == expected and actual_dispositions == expected_dispositions
        else 1
    )


def _entry_identity_at(
    parent_descriptor: int, name: str
) -> tuple[int, int, int, int, int] | None:
    try:
        info = os.stat(name, dir_fd=parent_descriptor, follow_symlinks=False)
    except FileNotFoundError:
        return None
    if not stat.S_ISREG(info.st_mode):
        raise UXBlueprintError(f"projection path is unsafe: {name}")
    return (
        info.st_dev,
        info.st_ino,
        info.st_size,
        info.st_mtime_ns,
        info.st_ctime_ns,
    )


def _read_regular_at(
    parent_descriptor: int, name: str
) -> tuple[bytes, tuple[int, int, int, int, int]]:
    expected = _entry_identity_at(parent_descriptor, name)
    if expected is None:
        raise UXBlueprintError(f"projection path disappeared: {name}")
    try:
        descriptor = os.open(name, READ_FLAGS, dir_fd=parent_descriptor)
    except OSError as error:
        raise UXBlueprintError(f"projection path is unsafe: {name}") from error
    try:
        info = os.fstat(descriptor)
        if (
            not stat.S_ISREG(info.st_mode)
            or (info.st_dev, info.st_ino) != expected[:2]
        ):
            raise UXBlueprintError(f"projection path is unsafe: {name}")
        chunks: list[bytes] = []
        while chunk := os.read(descriptor, 64 * 1024):
            chunks.append(chunk)
        after = os.fstat(descriptor)
        identity = (
            info.st_dev,
            info.st_ino,
            info.st_size,
            info.st_mtime_ns,
            info.st_ctime_ns,
        )
        after_identity = (
            after.st_dev,
            after.st_ino,
            after.st_size,
            after.st_mtime_ns,
            after.st_ctime_ns,
        )
    finally:
        os.close(descriptor)
    if after_identity != identity or _entry_identity_at(parent_descriptor, name) != identity:
        raise UXBlueprintError(f"projection changed during read: {name}")
    return b"".join(chunks), identity


def _stage_regular_at(
    parent_descriptor: int, name: str, content: bytes
) -> tuple[int, int, int, int, int]:
    descriptor = os.open(
        name,
        WRITE_FLAGS,
        0o600,
        dir_fd=parent_descriptor,
    )
    try:
        view = memoryview(content)
        while view:
            written = os.write(descriptor, view)
            if written <= 0:
                raise OSError(errno.EIO, "short projection write")
            view = view[written:]
        os.fsync(descriptor)
        info = os.fstat(descriptor)
        identity = (
            info.st_dev,
            info.st_ino,
            info.st_size,
            info.st_mtime_ns,
            info.st_ctime_ns,
        )
    finally:
        os.close(descriptor)
    if _entry_identity_at(parent_descriptor, name) != identity:
        raise UXBlueprintError(f"staged projection changed during write: {name}")
    return identity


def _unlink_regular_if_present(
    parent_descriptor: int,
    name: str,
    *,
    expected_identity: tuple[int, int, int, int, int] | None = None,
) -> None:
    identity = _entry_identity_at(parent_descriptor, name)
    if identity is None:
        return
    if expected_identity is not None and identity != expected_identity:
        raise UXBlueprintError(f"projection identity changed during rollback: {name}")
    os.unlink(name, dir_fd=parent_descriptor)


_COMMITTED_CLEANUP_NAME = re.compile(
    r"^\.([0-9a-f]{16})\.committed-cleanup\.json$"
)


def _cleanup_identity_record(
    name: str,
    identity: tuple[int, int, int, int, int],
    content: bytes,
    **extra: str,
) -> dict[str, object]:
    return {
        "content_sha256": hashlib.sha256(content).hexdigest(),
        "device": identity[0],
        "inode": identity[1],
        "name": name,
        "size": identity[2],
        **extra,
    }


def _render_committed_cleanup_record(
    context: _UXOperationContext,
    token: str,
    relative_outputs: tuple[tuple[Path, bytes], ...],
    installed_identities: Mapping[str, tuple[int, int, int, int, int]],
    preimages: Mapping[
        str, tuple[bytes, tuple[int, int, int, int, int]] | None
    ],
    backup_names: Mapping[str, str],
    backup_identities: Mapping[str, tuple[int, int, int, int, int]],
    recovery_names: Mapping[str, str],
    recovery_identities: Mapping[str, tuple[int, int, int, int, int]],
) -> bytes:
    targets = [
        _cleanup_identity_record(
            relative.name,
            installed_identities[relative.name],
            content,
        )
        for relative, content in relative_outputs
    ]
    artifacts: list[dict[str, object]] = []
    for relative, _content in relative_outputs:
        name = relative.name
        preimage = preimages[name]
        if preimage is None:
            continue
        artifacts.extend(
            (
                _cleanup_identity_record(
                    backup_names[name],
                    backup_identities[name],
                    preimage[0],
                    kind="backup",
                    target=name,
                ),
                _cleanup_identity_record(
                    recovery_names[name],
                    recovery_identities[name],
                    preimage[0],
                    kind="recovery",
                    target=name,
                ),
            )
        )
    payload = {
        "artifacts": sorted(artifacts, key=lambda item: str(item["name"])),
        "canon_content_sha256": context.canon.content_sha,
        "input_identity_sha256": _operation_input_identity_sha256(
            context.inputs
        ),
        "schema_version": 1,
        "targets": sorted(targets, key=lambda item: str(item["name"])),
        "transaction_id": token,
    }
    return (
        json.dumps(
            payload,
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        )
        + "\n"
    ).encode("utf-8")


def _parse_cleanup_identity_record(
    value: object,
    *,
    fields: frozenset[str],
) -> dict[str, object]:
    if not isinstance(value, dict) or set(value) != fields:
        raise UXBlueprintError("committed cleanup identity fields are closed")
    for field in ("device", "inode", "size"):
        item = value[field]
        if isinstance(item, bool) or not isinstance(item, int) or item < 0:
            raise UXBlueprintError(
                f"committed cleanup {field} is invalid"
            )
    if (
        not isinstance(value["name"], str)
        or not value["name"]
        or "/" in value["name"]
        or not isinstance(value["content_sha256"], str)
        or re.fullmatch(r"[0-9a-f]{64}", value["content_sha256"])
        is None
    ):
        raise UXBlueprintError("committed cleanup identity is invalid")
    return value


def _load_committed_cleanup_record(
    parent_descriptor: int,
    marker_name: str,
) -> tuple[
    dict[str, object],
    tuple[int, int, int, int, int],
]:
    match = _COMMITTED_CLEANUP_NAME.fullmatch(marker_name)
    if match is None:
        raise UXBlueprintError("committed cleanup marker name is invalid")
    source, marker_identity = _read_regular_at(parent_descriptor, marker_name)
    try:
        payload = json.loads(source)
    except (UnicodeError, json.JSONDecodeError) as error:
        raise UXBlueprintError("committed cleanup marker is invalid") from error
    fields = {
        "artifacts",
        "canon_content_sha256",
        "input_identity_sha256",
        "schema_version",
        "targets",
        "transaction_id",
    }
    if not isinstance(payload, dict) or set(payload) != fields:
        raise UXBlueprintError("committed cleanup marker fields are closed")
    token = payload["transaction_id"]
    if (
        payload["schema_version"] != 1
        or isinstance(payload["schema_version"], bool)
        or token != match.group(1)
        or not isinstance(payload["canon_content_sha256"], str)
        or re.fullmatch(r"[0-9a-f]{64}", payload["canon_content_sha256"])
        is None
        or not isinstance(payload["input_identity_sha256"], str)
        or re.fullmatch(r"[0-9a-f]{64}", payload["input_identity_sha256"])
        is None
    ):
        raise UXBlueprintError("committed cleanup marker identity is invalid")
    raw_targets = payload["targets"]
    raw_artifacts = payload["artifacts"]
    if not isinstance(raw_targets, list) or not isinstance(raw_artifacts, list):
        raise UXBlueprintError("committed cleanup records must be arrays")
    target_fields = frozenset(
        {"content_sha256", "device", "inode", "name", "size"}
    )
    artifact_fields = target_fields | {"kind", "target"}
    targets = tuple(
        _parse_cleanup_identity_record(item, fields=target_fields)
        for item in raw_targets
    )
    artifacts = tuple(
        _parse_cleanup_identity_record(item, fields=artifact_fields)
        for item in raw_artifacts
    )
    target_names = tuple(str(item["name"]) for item in targets)
    expected_targets = tuple(
        sorted((PROJECTION_PATH.name, DISPOSITIONS_PATH.name))
    )
    if target_names != expected_targets:
        raise UXBlueprintError("committed cleanup target set is invalid")
    artifact_names = tuple(str(item["name"]) for item in artifacts)
    if artifact_names != tuple(sorted(set(artifact_names))):
        raise UXBlueprintError("committed cleanup artifacts are not unique")
    for item in artifacts:
        kind = item.get("kind")
        target = item.get("target")
        if (
            kind not in {"backup", "recovery"}
            or target not in expected_targets
            or item["name"] != f".{target}.{token}.{kind}"
        ):
            raise UXBlueprintError(
                "committed cleanup artifact binding is invalid"
            )
    payload["targets"] = targets
    payload["artifacts"] = artifacts
    return payload, marker_identity


def _record_matches_live_file(
    content: bytes,
    identity: tuple[int, int, int, int, int],
    record: Mapping[str, object],
) -> bool:
    return (
        identity[0] == record["device"]
        and identity[1] == record["inode"]
        and identity[2] == record["size"]
        and hashlib.sha256(content).hexdigest()
        == record["content_sha256"]
    )


def _publish_committed_cleanup_record_at(
    parent_descriptor: int,
    marker_name: str,
    marker_content: bytes,
) -> tuple[int, int, int, int, int]:
    """Durably publish one final-name record without replacing any entry."""

    if _COMMITTED_CLEANUP_NAME.fullmatch(marker_name) is None:
        raise UXBlueprintError("committed cleanup marker name is invalid")
    descriptor: int | None = None
    try:
        descriptor = os.open(
            marker_name,
            WRITE_FLAGS,
            0o600,
            dir_fd=parent_descriptor,
        )
        opened = os.fstat(descriptor)
        if not stat.S_ISREG(opened.st_mode):
            raise UXBlueprintError(
                "committed cleanup marker is not a regular file"
            )
        view = memoryview(marker_content)
        while view:
            written = os.write(descriptor, view)
            if written <= 0:
                raise OSError(errno.EIO, "short committed cleanup write")
            view = view[written:]
        os.fsync(descriptor)
        info = os.fstat(descriptor)
        identity = (
            info.st_dev,
            info.st_ino,
            info.st_size,
            info.st_mtime_ns,
            info.st_ctime_ns,
        )
        os.close(descriptor)
        descriptor = None
        source, live_identity = _read_regular_at(
            parent_descriptor, marker_name
        )
        if source != marker_content or live_identity != identity:
            raise UXBlueprintError(
                "committed cleanup marker changed during publication"
            )
        _fsync_directory(parent_descriptor)
        source, durable_identity = _read_regular_at(
            parent_descriptor, marker_name
        )
        if source != marker_content or durable_identity != identity:
            raise UXBlueprintError(
                "committed cleanup marker changed after directory fsync"
            )
        return identity
    except BaseException as publication_error:
        cleanup_details = [
            "committed cleanup marker pathname preserved as publication-"
            "failure evidence; no pathname unlink was attempted"
        ]
        if descriptor is not None:
            try:
                info = os.fstat(descriptor)
                _owned_identity = (
                    info.st_dev,
                    info.st_ino,
                    info.st_size,
                    info.st_mtime_ns,
                    info.st_ctime_ns,
                )
            except BaseException as cleanup_error:
                cleanup_details.append(
                    "committed cleanup marker cleanup fstat failed; "
                    "marker evidence preserved: "
                    f"{type(cleanup_error).__name__}: {cleanup_error}"
                )
            else:
                cleanup_details.append(
                    "committed cleanup marker descriptor fstat succeeded; "
                    "pathname evidence intentionally preserved"
                )
            try:
                os.close(descriptor)
            except BaseException as cleanup_error:
                cleanup_details.append(
                    "committed cleanup marker descriptor close failed; "
                    "marker evidence preserved: "
                    f"{type(cleanup_error).__name__}: "
                    f"{cleanup_error}"
                )
        for detail in cleanup_details:
            publication_error.add_note(detail)
        raise


def _committed_cleanup_targets_match_at(
    parent_descriptor: int,
    payload: Mapping[str, object],
) -> bool:
    for record in payload["targets"]:
        content, identity = _read_regular_at(
            parent_descriptor, str(record["name"])
        )
        if not _record_matches_live_file(content, identity, record):
            return False
    return True


def _cleanup_committed_projection_record_at(
    parent_descriptor: int,
    marker_name: str,
) -> tuple[str, ...]:
    payload, marker_identity = _load_committed_cleanup_record(
        parent_descriptor, marker_name
    )
    artifact_names = tuple(
        str(record["name"]) for record in payload["artifacts"]
    )
    for record in payload["targets"]:
        content, identity = _read_regular_at(
            parent_descriptor, str(record["name"])
        )
        if not _record_matches_live_file(content, identity, record):
            raise UXBlueprintError(
                "committed cleanup target identity changed"
            )
    for record in payload["artifacts"]:
        name = str(record["name"])
        if _entry_identity_at(parent_descriptor, name) is None:
            continue
        content, identity = _read_regular_at(parent_descriptor, name)
        if not _record_matches_live_file(content, identity, record):
            raise UXBlueprintError(
                "committed cleanup artifact identity changed"
            )
        _unlink_regular_if_present(
            parent_descriptor,
            name,
            expected_identity=identity,
        )
    _fsync_directory(parent_descriptor)
    if any(
        _entry_identity_at(parent_descriptor, str(record["name"]))
        is not None
        for record in payload["artifacts"]
    ):
        raise UXBlueprintError("committed cleanup artifacts remain")
    _unlink_regular_if_present(
        parent_descriptor,
        marker_name,
        expected_identity=marker_identity,
    )
    _fsync_directory(parent_descriptor)
    if _entry_identity_at(parent_descriptor, marker_name) is not None or any(
        _entry_identity_at(parent_descriptor, name) is not None
        for name in artifact_names
    ):
        raise UXBlueprintError(
            "committed cleanup evidence survived verified cleanup"
        )
    return artifact_names


def _cleanup_prior_committed_projection_records_at(
    parent_descriptor: int,
) -> None:
    for name in sorted(os.listdir(parent_descriptor)):
        if _COMMITTED_CLEANUP_NAME.fullmatch(name) is None:
            continue
        try:
            payload, _marker_identity = _load_committed_cleanup_record(
                parent_descriptor, name
            )
        except (OSError, UXBlueprintError):
            # Malformed or unrelated exact-name collisions are evidence.
            continue
        try:
            targets_match = _committed_cleanup_targets_match_at(
                parent_descriptor, payload
            )
        except (OSError, UXBlueprintError) as error:
            raise UXBlueprintError(
                "prior committed projection targets could not be verified; "
                "new projection write is blocked"
            ) from error
        if not targets_match:
            # A valid record for another installed generation is stale evidence.
            continue
        try:
            artifact_names = _cleanup_committed_projection_record_at(
                parent_descriptor, name
            )
        except Exception as error:
            raise UXBlueprintError(
                "prior committed projection cleanup failed; "
                "new projection write is blocked"
            ) from error
        if _entry_identity_at(parent_descriptor, name) is not None or any(
            _entry_identity_at(parent_descriptor, artifact_name) is not None
            for artifact_name in artifact_names
        ):
            raise UXBlueprintError(
                "prior committed projection cleanup is incomplete; "
                "new projection write is blocked"
            )


def _postcommit_cleanup_noexcept(
    parent_descriptor: int,
    committed_marker_name: str,
) -> None:
    try:
        _cleanup_committed_projection_record_at(
            parent_descriptor, committed_marker_name
        )
    except BaseException:
        # The outputs are already committed. Keep exact marker-bound evidence
        # for a later exclusive writer; post-commit cleanup cannot roll back or
        # misreport the successful commit.
        return


def _write_projection_outputs_transaction(
    context: _UXOperationContext,
    outputs: Mapping[Path, bytes],
) -> None:
    """Install both projections as one recoverable descriptor-confined transaction."""

    relative_outputs = tuple(
        sorted(outputs.items(), key=lambda item: item[0].as_posix())
    )
    if not relative_outputs or any(
        path.parent != PROJECTION_PATH.parent for path, _ in relative_outputs
    ):
        raise UXBlueprintError("projection transaction target set is invalid")
    token = secrets.token_hex(8)
    preimages: dict[
        str, tuple[bytes, tuple[int, int, int, int, int]] | None
    ] = {}
    backup_names: dict[str, str] = {}
    recovery_names: dict[str, str] = {}
    temporary_names: dict[str, str] = {}
    staged_identities: dict[
        str, tuple[int, int, int, int, int]
    ] = {}
    backup_identities: dict[
        str, tuple[int, int, int, int, int]
    ] = {}
    recovery_identities: dict[
        str, tuple[int, int, int, int, int]
    ] = {}
    installed_identities: dict[
        str, tuple[int, int, int, int, int]
    ] = {}
    committed_marker_name = f".{token}.committed-cleanup.json"
    committed_marker_identity: tuple[int, int, int, int, int] | None = None
    with _projection_lock(context.root_descriptor, exclusive=True) as parent_descriptor:
        _cleanup_prior_committed_projection_records_at(parent_descriptor)
        try:
            for relative, _content in relative_outputs:
                name = relative.name
                identity = _entry_identity_at(parent_descriptor, name)
                preimages[name] = (
                    None
                    if identity is None
                    else _read_regular_at(parent_descriptor, name)
                )
                backup_names[name] = f".{name}.{token}.backup"
                recovery_names[name] = f".{name}.{token}.recovery"
                temporary_names[name] = f".{name}.{token}.tmp"

            for relative, content in relative_outputs:
                name = relative.name
                staged_identities[name] = _stage_regular_at(
                    parent_descriptor, temporary_names[name], content
                )

            for relative, _content in relative_outputs:
                name = relative.name
                preimage = preimages[name]
                if preimage is None:
                    continue
                if _entry_identity_at(parent_descriptor, name) != preimage[1]:
                    raise UXBlueprintError(
                        f"projection changed before backup: {name}"
                    )
                os.link(
                    name,
                    backup_names[name],
                    src_dir_fd=parent_descriptor,
                    dst_dir_fd=parent_descriptor,
                    follow_symlinks=False,
                )
                backup_content, backup_identity = _read_regular_at(
                    parent_descriptor, backup_names[name]
                )
                current_content, current_identity = _read_regular_at(
                    parent_descriptor, name
                )
                if (
                    backup_content != preimage[0]
                    or current_content != preimage[0]
                    or backup_identity[:2] != preimage[1][:2]
                    or current_identity != backup_identity
                ):
                    raise UXBlueprintError(
                        f"projection backup is not the original identity: {name}"
                    )
                preimages[name] = (preimage[0], current_identity)
                backup_identities[name] = backup_identity
                os.link(
                    name,
                    recovery_names[name],
                    src_dir_fd=parent_descriptor,
                    dst_dir_fd=parent_descriptor,
                    follow_symlinks=False,
                )
                recovery_content, recovery_identity = _read_regular_at(
                    parent_descriptor, recovery_names[name]
                )
                backup_content, backup_identity = _read_regular_at(
                    parent_descriptor, backup_names[name]
                )
                current_content, current_identity = _read_regular_at(
                    parent_descriptor, name
                )
                if (
                    recovery_content != preimage[0]
                    or backup_content != preimage[0]
                    or current_content != preimage[0]
                    or recovery_identity[:2] != preimage[1][:2]
                    or current_identity != recovery_identity
                    or backup_identity != recovery_identity
                ):
                    raise UXBlueprintError(
                        f"projection recovery is not the original identity: {name}"
                    )
                preimages[name] = (preimage[0], current_identity)
                backup_identities[name] = backup_identity
                recovery_identities[name] = recovery_identity
            _fsync_directory(parent_descriptor)

            for relative, _content in relative_outputs:
                name = relative.name
                preimage = preimages[name]
                expected_original = None if preimage is None else preimage[1]
                if _entry_identity_at(parent_descriptor, name) != expected_original:
                    raise UXBlueprintError(
                        f"projection changed before install: {name}"
                    )
                os.replace(
                    temporary_names[name],
                    name,
                    src_dir_fd=parent_descriptor,
                    dst_dir_fd=parent_descriptor,
                )
                identity = _entry_identity_at(parent_descriptor, name)
                if identity is None or identity[:2] != staged_identities[name][:2]:
                    raise UXBlueprintError(
                        f"installed projection identity is stale: {name}"
                    )
                installed_identities[name] = identity
                backup_identity = backup_identities.get(name)
                recovery_identity = recovery_identities.get(name)
                preimage = preimages[name]
                if (
                    backup_identity is not None
                    and recovery_identity is not None
                    and preimage is not None
                ):
                    backup_content, live_backup_identity = _read_regular_at(
                        parent_descriptor, backup_names[name]
                    )
                    recovery_content, live_recovery_identity = _read_regular_at(
                        parent_descriptor, recovery_names[name]
                    )
                    if (
                        backup_content != preimage[0]
                        or recovery_content != preimage[0]
                        or live_backup_identity[:2] != backup_identity[:2]
                        or live_recovery_identity[:2] != recovery_identity[:2]
                        or live_backup_identity != live_recovery_identity
                    ):
                        raise UXBlueprintError(
                            f"projection recovery changed during install: {name}"
                        )
                    # Replacing the target removes one hard link to the backup
                    # inode and legitimately advances ctime. Preserve the exact
                    # post-replace identity used by cleanup and rollback.
                    backup_identities[name] = live_backup_identity
                    recovery_identities[name] = live_recovery_identity
            _fsync_directory(parent_descriptor)

            for relative, expected in relative_outputs:
                actual, identity = _read_regular_at(
                    parent_descriptor, relative.name
                )
                if (
                    actual != expected
                    or identity != installed_identities[relative.name]
                ):
                    raise UXBlueprintError(
                        f"installed projection content is stale: {relative.name}"
                    )
            marker_content = _render_committed_cleanup_record(
                context,
                token,
                relative_outputs,
                installed_identities,
                preimages,
                backup_names,
                backup_identities,
                recovery_names,
                recovery_identities,
            )
            committed_marker_identity = _publish_committed_cleanup_record_at(
                parent_descriptor,
                committed_marker_name,
                marker_content,
            )
            _verify_operation_context(context, projection_locked=True)
            context.commit_state.attestation = _UXOperationCommitAttestation(
                canon_content_sha=context.canon.content_sha,
                inputs=context.inputs,
                input_identity_sha256=_operation_input_identity_sha256(
                    context.inputs
                ),
            )
            _postcommit_cleanup_noexcept(
                parent_descriptor,
                committed_marker_name,
            )
            return
        except BaseException as operation_error:
            try:
                for relative, _content in reversed(relative_outputs):
                    name = relative.name
                    current = _entry_identity_at(parent_descriptor, name)
                    installed = installed_identities.get(name)
                    preimage = preimages.get(name)
                    if installed is None:
                        expected = None if preimage is None else preimage[1]
                        if current != expected:
                            raise UXBlueprintError(
                                f"uninstalled projection identity changed: {name}"
                            )
                        continue
                    if current != installed:
                        raise UXBlueprintError(
                            f"projection identity changed during rollback: {name}"
                        )
                    if preimage is None:
                        os.unlink(name, dir_fd=parent_descriptor)
                        if _entry_identity_at(parent_descriptor, name) is not None:
                            raise UXBlueprintError(
                                f"new projection survived rollback: {name}"
                            )
                        continue
                    recovery_identity = recovery_identities.get(name)
                    recovery_content, live_recovery_identity = _read_regular_at(
                        parent_descriptor, recovery_names[name]
                    )
                    if (
                        recovery_identity is None
                        or recovery_identity[:2] != preimage[1][:2]
                        or live_recovery_identity[:2] != recovery_identity[:2]
                        or recovery_content != preimage[0]
                    ):
                        raise UXBlueprintError(
                            f"projection recovery changed before rollback: {name}"
                        )
                    os.replace(
                        recovery_names[name],
                        name,
                        src_dir_fd=parent_descriptor,
                        dst_dir_fd=parent_descriptor,
                    )
                    restored_content, restored_identity = _read_regular_at(
                        parent_descriptor, name
                    )
                    if (
                        restored_content != preimage[0]
                        or restored_identity[:2] != preimage[1][:2]
                    ):
                        raise UXBlueprintError(
                            f"restored projection could not be verified: {name}"
                        )
                    backup_identity = backup_identities.get(name)
                    if backup_identity is not None and _entry_identity_at(
                        parent_descriptor, backup_names[name]
                    ) is not None:
                        backup_content, live_backup_identity = _read_regular_at(
                            parent_descriptor, backup_names[name]
                        )
                        if (
                            backup_content != preimage[0]
                            or live_backup_identity[:2]
                            != backup_identity[:2]
                        ):
                            raise UXBlueprintError(
                                f"projection backup changed during rollback: {name}"
                            )
                        backup_identities[name] = live_backup_identity
                _fsync_directory(parent_descriptor)
                for relative, _content in relative_outputs:
                    name = relative.name
                    staged = staged_identities.get(name)
                    if staged is not None:
                        _unlink_regular_if_present(
                            parent_descriptor,
                            temporary_names[name],
                            expected_identity=staged,
                        )
                    preimage = preimages[name]
                    recovery = recovery_identities.get(name)
                    if recovery is not None and _entry_identity_at(
                        parent_descriptor, recovery_names[name]
                    ) is not None:
                        recovery_content, live_recovery = _read_regular_at(
                            parent_descriptor, recovery_names[name]
                        )
                        if (
                            preimage is None
                            or recovery_content != preimage[0]
                            or live_recovery[:2] != recovery[:2]
                        ):
                            raise UXBlueprintError(
                                f"projection recovery changed during cleanup: {name}"
                            )
                        _unlink_regular_if_present(
                            parent_descriptor,
                            recovery_names[name],
                            expected_identity=live_recovery,
                        )
                    backup = backup_identities.get(name)
                    if backup is not None and _entry_identity_at(
                        parent_descriptor, backup_names[name]
                    ) is not None:
                        backup_content, live_backup = _read_regular_at(
                            parent_descriptor, backup_names[name]
                        )
                        if (
                            preimage is None
                            or backup_content != preimage[0]
                            or live_backup[:2] != backup[:2]
                        ):
                            raise UXBlueprintError(
                                f"projection backup changed during cleanup: {name}"
                            )
                        _unlink_regular_if_present(
                            parent_descriptor,
                            backup_names[name],
                            expected_identity=live_backup,
                        )
                if (
                    committed_marker_identity is not None
                    and _entry_identity_at(
                        parent_descriptor, committed_marker_name
                    )
                    is not None
                ):
                    _unlink_regular_if_present(
                        parent_descriptor,
                        committed_marker_name,
                        expected_identity=committed_marker_identity,
                    )
                _fsync_directory(parent_descriptor)
                for relative, _content in relative_outputs:
                    name = relative.name
                    preimage = preimages[name]
                    if preimage is None:
                        if _entry_identity_at(parent_descriptor, name) is not None:
                            raise UXBlueprintError(
                                f"absent preimage was not restored: {name}"
                            )
                        continue
                    restored_content, restored_identity = _read_regular_at(
                        parent_descriptor, name
                    )
                    if (
                        restored_content != preimage[0]
                        or restored_identity[:2] != preimage[1][:2]
                    ):
                        raise UXBlueprintError(
                            f"rollback postcondition is stale: {name}"
                        )
            except BaseException as rollback_error:
                raise CanonError(
                    "UX_BLUEPRINT_ROLLBACK_FAILED",
                    "projection transaction failed and rollback could not be verified",
                    context.root / PROJECTION_PATH.parent,
                ) from rollback_error
            raise CanonError(
                "UX_BLUEPRINT_WRITE_FAILED",
                "projection transaction failed and both preimages were restored",
                context.root / PROJECTION_PATH.parent,
            ) from operation_error


def write_ux_blueprint_projection(root: Path) -> UXBlueprintSummary:
    """Validate and replace both projections with rollback on every failure."""

    excluded = frozenset({PROJECTION_PATH, DISPOSITIONS_PATH})
    with _ux_operation(
        root,
        excluded_paths=excluded,
    ) as context:
        blueprint = load_ux_blueprint(root)
        frozen = _freeze_mapping(blueprint, "UX blueprint")
        summary = _validate_ux_blueprint(root, frozen, context.canon)
        outputs = {
            PROJECTION_PATH: _render_ux_blueprint_markdown(
                frozen, root, context.canon
            ),
            DISPOSITIONS_PATH: _render_requirement_dispositions(
                root, frozen, context.canon
            ),
        }
        _write_projection_outputs_transaction(context, outputs)
        return summary
