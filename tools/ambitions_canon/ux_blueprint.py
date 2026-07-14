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
PLACEHOLDER = re.compile(r"(?<!\w)(?:TBD|TODO|implement later)(?!\w)", re.IGNORECASE)

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
        "states",
        "requirement_ids",
        "implementation_status",
        "proof_ceiling",
    }
)
STATE_RECORD_FIELDS = frozenset(
    {
        "accessibility_focus",
        "allowed_commands",
        "blueprint_id",
        "displayed_objects",
        "durable_effect",
        "implementation_status",
        "kind",
        "offline_behavior",
        "proof_ceiling",
        "recovery_rollback",
        "requirement_ids",
        "transition_exit",
        "visible_content_copy",
        "visible_presentation",
    }
)
DISPOSITION_FIELDS = frozenset(
    {
        "blueprint_ids",
        "disposition",
        "rationale",
        "requirement_id",
        "source_path",
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
    state_record_count: int
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


def build_requirement_dispositions(
    root: Path,
    blueprint: Mapping[str, object],
    known_blueprint_ids: frozenset[str],
) -> tuple[dict[str, object], ...]:
    """Validate the checked-in per-requirement semantic disposition ledger."""

    requirements = {
        _string(item.get("requirement_id"), "requirement_id"): item
        for item in _requirement_records(root)
    }
    records = _records(
        blueprint.get("requirement_dispositions"), "requirement dispositions"
    )
    identifiers: list[str] = []
    dispositions: list[dict[str, object]] = []
    for item in records:
        _closed(item, DISPOSITION_FIELDS, "requirement disposition fields")
        requirement_id = _string(item.get("requirement_id"), "disposition requirement ID")
        source_path = _string(item.get("source_path"), "disposition source path")
        disposition = _string(item.get("disposition"), "requirement disposition")
        rationale = _string(item.get("rationale"), "requirement rationale")
        if len(rationale.split()) < 8:
            raise UXBlueprintError(
                f"requirement rationale is not reviewable: {requirement_id}"
            )
        identifiers.append(requirement_id)
        requirement = requirements.get(requirement_id)
        if requirement is None:
            raise UXBlueprintError(f"unknown requirement disposition: {requirement_id}")
        expected_source = _string(
            requirement.get("source_path"), "requirement source path"
        )
        if source_path != expected_source:
            raise UXBlueprintError(
                f"requirement disposition source mismatch: {requirement_id}"
            )
        blueprint_ids_value = item.get("blueprint_ids")
        if not isinstance(blueprint_ids_value, list):
            raise UXBlueprintError(
                f"requirement disposition blueprint IDs must be an array: {requirement_id}"
            )
        blueprint_ids = tuple(
            _string(value, "disposition blueprint ID") for value in blueprint_ids_value
        )
        if blueprint_ids != tuple(sorted(set(blueprint_ids))):
            raise UXBlueprintError(
                f"requirement disposition blueprint IDs must be sorted and unique: {requirement_id}"
            )
        unknown = sorted(set(blueprint_ids) - known_blueprint_ids)
        if unknown:
            raise UXBlueprintError(
                f"requirement disposition references unknown blueprint IDs: {unknown}"
            )
        if disposition == "visual_mapping_required":
            if not blueprint_ids:
                raise UXBlueprintError(
                    f"visual requirement has no applicable blueprint record: {requirement_id}"
                )
        elif disposition == "nonvisual_with_rationale":
            if blueprint_ids:
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

    screens = _records(blueprint.get("screens"), "screens")
    states = _records(blueprint.get("state_models"), "state models")
    objects = _records(blueprint.get("object_boundaries"), "object boundaries")
    journeys = _records(blueprint.get("journeys"), "journeys")
    cross = _records(blueprint.get("cross_cutting"), "cross-cutting records")
    preliminary_ids = [
        _string(item.get("blueprint_id"), "blueprint ID")
        for records in (screens, states, objects, journeys, cross)
        for item in records
    ]
    if len(preliminary_ids) != len(set(preliminary_ids)):
        raise UXBlueprintError("blueprint IDs must be globally unique typed IDs")
    screen_ids = _sorted_unique_records(screens, "screens")
    state_model_ids = _sorted_unique_records(states, "state models")
    object_blueprint_ids = _sorted_unique_records(objects, "object boundaries")
    journey_ids = _sorted_unique_records(journeys, "journeys")
    cross_ids = _sorted_unique_records(cross, "cross-cutting records")

    linked_requirements: list[str] = []
    scopes: set[str] = set()
    referenced_state_models: set[str] = set()
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
        linked_requirements.extend(
            _linked_ids(screen.get("requirement_ids"), "screen requirement IDs")
        )
    if scopes != REQUIRED_SCOPES:
        raise UXBlueprintError(f"screen scopes are incomplete or invented: {sorted(scopes)}")
    if referenced_state_models != set(state_model_ids):
        raise UXBlueprintError("every state model must be used by at least one screen")

    covered_screens: set[str] = set()
    state_kinds: set[str] = set()
    state_record_ids: list[str] = []
    state_record_count = 0
    for state_model in states:
        _closed(state_model, STATE_MODEL_FIELDS, "state model fields")
        _record_posture(state_model, "state model")
        screen_id = _string(state_model.get("screen_id"), "state model screen_id")
        if screen_id not in screen_ids:
            raise UXBlueprintError(f"state model references unknown screen: {screen_id}")
        if screen_id in covered_screens:
            raise UXBlueprintError(f"screen has more than one state model: {screen_id}")
        covered_screens.add(screen_id)
        state_records = _records(state_model.get("states"), "state records")
        if len(state_records) != len(REQUIRED_STATE_KINDS):
            raise UXBlueprintError("each screen requires nine explicit state records")
        kinds: set[str] = set()
        for state_record in state_records:
            _closed(state_record, STATE_RECORD_FIELDS, "state record fields")
            _record_posture(state_record, "state")
            kind = _string(state_record.get("kind"), "state kind")
            kinds.add(kind)
            state_kinds.add(kind)
            state_record_id = _string(
                state_record.get("blueprint_id"), "state record blueprint ID"
            )
            state_record_ids.append(state_record_id)
            for field in (
                "visible_presentation",
                "visible_content_copy",
                "transition_exit",
                "durable_effect",
                "recovery_rollback",
                "offline_behavior",
                "accessibility_focus",
            ):
                text = _string(state_record.get(field), f"state {field}")
                if field == "visible_content_copy" and (
                    len(text.split()) < 4
                    or text.casefold()
                    in {"loading", "empty", "error", "failure", "try again", "no data"}
                ):
                    raise UXBlueprintError(
                        f"state requires explicit visible content: {state_record_id}"
                    )
            _strings(state_record.get("displayed_objects"), "state displayed objects")
            _strings(state_record.get("allowed_commands"), "state allowed commands")
            linked_requirements.extend(
                _linked_ids(state_record.get("requirement_ids"), "state requirement IDs")
            )
            state_record_count += 1
        if kinds != REQUIRED_STATE_KINDS:
            raise UXBlueprintError("each state model must cover the complete state taxonomy")
        linked_requirements.extend(
            _linked_ids(
                state_model.get("requirement_ids"), "state model requirement IDs"
            )
        )
    if covered_screens != set(screen_ids):
        raise UXBlueprintError("every screen must be covered by a complete state model")

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

    typed_groups = (
        (screen_ids, r"UX-SCREEN-[A-Z0-9-]+"),
        (state_model_ids, r"UX-STATE-MODEL-[A-Z0-9-]+"),
        (tuple(state_record_ids), r"UX-STATE-[A-Z0-9-]+-(?:DEGRADED|EMPTY|FAILURE|INTERRUPTION|LOADING|RECOVERY|RESTING|ROLLBACK|TRANSITIONAL)"),
        (object_blueprint_ids, r"UX-OBJECT-[A-Z0-9-]+"),
        (journey_ids, r"UX-JOURNEY-[A-Z0-9-]+"),
        (cross_ids, r"UX-CROSS-[A-Z0-9-]+"),
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

    if len(screens) != 40 or len(states) != 40 or len(objects) != 18 or len(journeys) != 12 or len(cross) != 10:
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
        state_record_count=state_record_count,
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
            "## Explicit screen state contracts",
            "",
            "Every screen owns explicit resting, loading, transitional, empty, degraded, "
            "failure, recovery, rollback, and interruption records.",
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
                "| State ID | Kind | Visible presentation | Content / copy | Displayed objects | Allowed commands | Transition / exit | Durable effect | Recovery / rollback | Offline behavior | Accessibility / focus | Requirements |",
                "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |",
            ]
        )
        for state in state_model["states"]:
            displayed = ", ".join(state["displayed_objects"])
            commands = ", ".join(state["allowed_commands"])
            requirements = ", ".join(
                f"`{item}`" for item in state["requirement_ids"]
            )
            lines.append(
                f"| `{state['blueprint_id']}` | `{state['kind']}` | "
                f"{state['visible_presentation']} | {state['visible_content_copy']} | "
                f"{displayed} | {commands} | {state['transition_exit']} | "
                f"{state['durable_effect']} | {state['recovery_rollback']} | "
                f"{state['offline_behavior']} | {state['accessibility_focus']} | "
                f"{requirements} |"
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
