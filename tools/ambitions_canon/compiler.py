"""Parse, validate, compile, and query Ambitions product canon.

The compiler intentionally has no authorization, signing, approval, task,
pack, attestation, receipt-ledger, or status-policing behavior. Its only job is
to make product direction deterministic and easy to inspect.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import tempfile
import tomllib
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable
from urllib.parse import unquote, urlparse


CANON_ROOT_PATH = Path("docs/canon")
MANIFEST_PATH = CANON_ROOT_PATH / "MANIFEST.toml"
GENERATED_PATHS = (
    "generated/CODEX_START_HERE.md",
    "generated/INDEX.md",
    "generated/canon-index.json",
    "generated/object-boundary-matrix.md",
    "generated/requirement-graph.json",
    "generated/requirement-traceability.json",
    "generated/visual-authority-manifest.json",
)

VISUAL_CLASSIFICATIONS = {
    "ACTIVE_RECONCILED_BASELINE",
    "HISTORICAL_REFERENCE",
    "DEFERRED_CANDIDATE_REQUIRING_OWNER_REVIEW",
    "IMPLEMENTATION_DETAIL_NOT_YET_AUTHORIZED",
    "SUPERSEDED",
}
VISUAL_CLOSURE_MACHINE_PATHS = (
    Path("docs/canon/design/visual-closure-input-contract.json"),
    Path("docs/canon/design/vc-wave-1-foundation-closure.json"),
    Path("docs/canon/design/vc-wave-2-surface-journey-closure.json"),
    Path("docs/canon/design/vc-wave-3-accessibility-stress-closure.json"),
)
EXPECTED_ACTIVE_VISUAL_DIRECTIONS = (
    "AVF-DNA-S07-R00",
    "AVF-SHELL-S07-R01",
    "AVF-CAPTURE-S07-R01",
    "AVF-GOALS-S08-R00",
    "AVF-TIME-S07-R01",
    "AVF-TODAY-S10-R00",
    "AVF-SEARCH-D07-R01",
    "AVF-YOU-D07-R02",
    "AVF-RECOVERY-S07-R01",
    "AVF-A11Y-S07-R00",
    "AVF-COHERENCE-S07-R00",
)
ACTIVE_VISUAL_DIRECTIONS = EXPECTED_ACTIVE_VISUAL_DIRECTIONS
WAVE_1_PACKAGE_STATUSES = {
    **{f"VC-{number:02d}": "CLOSED" for number in range(1, 7)},
    **{f"VC-{number:02d}": "OPEN" for number in range(7, 14)},
    "VC-14": "NOT_STARTED",
}
WAVE_2_PACKAGE_STATUSES = {
    **{f"VC-{number:02d}": "CLOSED" for number in range(1, 13)},
    "VC-13": "OPEN",
    "VC-14": "NOT_STARTED",
}
EXPECTED_EFFECTIVE_PACKAGE_STATUSES = {
    **{f"VC-{number:02d}": "CLOSED" for number in range(1, 14)},
    "VC-14": "NOT_STARTED",
}
FALSE_IMPLEMENTATION_AUTHORIZATION = {
    "figma": False,
    "implementation": False,
    "swiftui": False,
}
EXPECTED_WAVE_2_CANONICAL_SHA256 = (
    "a7adda3b7dc609e1626bc9456ad05ded0aea4d8619416db055d547e4790cb323"
)
EXPECTED_WAVE_3_CANONICAL_SHA256 = (
    "4d68629ba6da8d9d2b04f39ebf1b1ca189fe81f3b40bdd0fa91d4524eb1f240e"
)
EXPECTED_WAVE_3_HUMAN_SHA256 = (
    "bf4586bf1eabb92e6048795052e5703f9430e86a32f2a614a30bfb9ec63dc437"
)
WAVE_2_TOP_LEVEL_FIELDS = {
    "active_direction_ids",
    "architecture_dependencies",
    "authorization_state",
    "date",
    "deferred_calibration_register",
    "human_peer",
    "inherits",
    "package_id",
    "package_statuses",
    "packages",
    "schema_version",
    "shared_protected_characteristics",
    "shared_rejected_patterns",
    "source_paths",
    "status",
    "validation_requirements",
    "wave_3_entry_criteria",
    "wave_statuses",
}
WAVE_2_PACKAGE_FIELDS = {
    "applies_to_avf_ids",
    "architecture_dependencies",
    "authorization_state",
    "deferred_calibration",
    "locked_decisions",
    "package_id",
    "rejected_alternatives",
    "required_transformation",
    "selected_study_or_synthesis",
    "status",
}
EXPECTED_WAVE_2_SUMMARIES = {
    "today": {
        "package_id": "VC-07",
        "selected_name": "Balanced Semantic Execution Day",
    },
    "goals": {
        "package_id": "VC-08",
        "selected_name": "Singular Living Pursuit Passage",
    },
    "time": {
        "package_id": "VC-09",
        "selected_name": "Adaptive Dual-Truth Period Passage",
    },
    "capture": {
        "package_id": "VC-10",
        "selected_name": "Full-Screen Adaptive Meaning Passage",
    },
    "search": {
        "package_id": "VC-10",
        "selected_name": "Full-Screen Semantic Command Passage",
    },
    "you": {
        "package_id": "VC-11",
        "selected_name": "Personal Control Passage",
    },
    "resilience": {
        "package_id": "VC-12",
        "selected_name": "Contextual Combined-State Passage",
    },
}
EXPECTED_WAVE_2_AVF_MAPPINGS = {
    "VC-07": (
        "AVF-TODAY-S10-R00",
        "AVF-A11Y-S07-R00",
        "AVF-COHERENCE-S07-R00",
    ),
    "VC-08": (
        "AVF-GOALS-S08-R00",
        "AVF-A11Y-S07-R00",
        "AVF-COHERENCE-S07-R00",
    ),
    "VC-09": (
        "AVF-TIME-S07-R01",
        "AVF-A11Y-S07-R00",
        "AVF-COHERENCE-S07-R00",
    ),
    "VC-10": (
        "AVF-CAPTURE-S07-R01",
        "AVF-SEARCH-D07-R01",
        "AVF-SHELL-S07-R01",
        "AVF-A11Y-S07-R00",
        "AVF-COHERENCE-S07-R00",
    ),
    "VC-11": (
        "AVF-YOU-D07-R02",
        "AVF-A11Y-S07-R00",
        "AVF-COHERENCE-S07-R00",
    ),
    "VC-12": (
        "AVF-RECOVERY-S07-R01",
        "AVF-A11Y-S07-R00",
        "AVF-COHERENCE-S07-R00",
    ),
}
WAVE_1_SELECTED_RECORDS = {
    "VC-01": ("VC01-TYPE-STUDY-D", "Semantic Cadence"),
    "VC-02": (None, "Mineral Relief Continuum"),
    "VC-03": ("VC03-CROWN-D04", "Compact Semantic Stack"),
    "VC-04": ("VC04-DOCK-D04", "Articulated Edge Tray"),
    "VC-05": ("VC05-STATE-D04", "Semantic State Covenant"),
    "VC-06": ("VC06-GRAMMAR-D04", "Articulated Native Grammar"),
}
WAVE_1_REQUIRED_TRANSFORMATIONS = {
    "VC-01": None,
    "VC-02": None,
    "VC-03": ("VC03-CROWN-D06", "Adaptive Semantic Passage"),
    "VC-04": ("VC04-DOCK-D06", "Adaptive Navigation Passage"),
    "VC-05": ("VC05-STATE-D06", "Explicit Stress Scaffold"),
    "VC-06": ("VC06-GRAMMAR-D06", "Explicit Accessible Structure"),
}

REQUIRED_FRONTMATTER = {
    "spec_id": str,
    "title": str,
    "kind": str,
    "status": str,
    "owner_domain": str,
    "canon_revision": int,
    "owns_concepts": list,
    "inherits": list,
    "depends_on": list,
    "source_owners": list,
}
REQUIREMENT_FIELDS = (
    "Concept",
    "Modality",
    "Scope",
    "Status",
    "Verification",
    "Supersedes",
)
MODALITIES = {"MUST", "MUST NOT", "MAY", "SHOULD"}
UX_STATE_GENERIC_KINDS = (
    "degraded",
    "empty",
    "failure",
    "interruption",
    "loading",
    "recovery",
    "resting",
    "rollback",
    "transitional",
)
SPEC_ID_RE = re.compile(r"^[A-Z][A-Z0-9-]+$")
REQUIREMENT_ID_PATTERN = r"[A-Z][A-Z0-9]*(?:-[A-Z0-9]+)*-[0-9]{3}"
REQUIREMENT_HEADING_RE = re.compile(
    rf"^##\s+({REQUIREMENT_ID_PATTERN})\s+—\s+(.+?)\s*$", re.MULTILINE
)
HEADING_WITH_SEPARATOR_RE = re.compile(r"^##\s+(\S+)\s+—\s+(.+?)\s*$", re.MULTILINE)
LEVEL_TWO_HEADING_RE = re.compile(r"^##\s+.+$", re.MULTILINE)
FIELD_RE = re.compile(
    r"^- \*\*(Concept|Modality|Scope|Status|Verification|Supersedes):\*\*"
    r"\s*(.*?)\s*$",
    re.MULTILINE,
)
CONCEPT_RE = re.compile(r"^[a-z0-9]+(?:[.-][a-z0-9]+)*$")
MARKDOWN_LINK_RE = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")
HISTORICAL_CLAIM_RE = re.compile(r"^CLAIM-[A-Z0-9-]+$")
KNOWN_RETIRED_REQUIREMENT_IDS = {
    "SPEC-GLOBAL-SEARCH-IDENTITY-001",
}

REQUIRED_CONSTITUTION_IDS = {
    "MISSION-CATEGORY-001",
    "MISSION-FUNCTION-001",
    "MISSION-INTEGRATION-001",
    "MISSION-HARD-RED-001",
    "MISSION-ORIGIN-PROBLEM-001",
    "MISSION-USER-001",
    "MISSION-MOAT-001",
    "MISSION-ORCHESTRATION-LOOP-001",
    "CONST-IA-ROOT-001",
    "LAW-IA-ROOT-001",
    "LAW-IA-NONROOT-001",
    "LAW-SEARCH-PRIVATE-COMMAND-LAYER-001",
    "LAW-IA-PLAIN-LANGUAGE-001",
    "LAW-SHELL-STAGE-001",
    "CONTROL-FORCE-NOTHING-001",
    "CONTROL-MATERIAL-CONFIRMATION-001",
    "CONTROL-UNDO-RECOVERY-001",
    "OBJECT-CANONICAL-GRAPH-001",
    "CONST-RUNTIME-MUTATION-001",
    "RUNTIME-MUTATION-SEQUENCE-001",
    "LAW-LOCAL-AUTHORITY-001",
    "LAW-OFFLINE-NO-ACCOUNT-001",
    "LAW-R2-PUBLIC-ONLY-001",
    "PLATFORM-NATIVE-IPHONE-001",
    "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
    "LAW-DATA-LOSS-STOP-SHIP-001",
}

OBJECT_CAPABILITIES = (
    ("executable_completable", "Executable / completable"),
    ("occupies_duration", "Occupies duration"),
    ("consumes_capacity", "Consumes capacity"),
    ("due_date", "Due date"),
    ("recurrence", "Recurrence"),
    ("substeps", "Substeps"),
    ("goal_path_node", "Goal Path node"),
    ("proof_requirement", "Proof requirement"),
    ("attendees_rsvp", "Attendees / RSVP"),
    ("alerts", "Alerts"),
    ("type_conversion", "Type conversion"),
)
OBJECT_ORDER = ("Step", "Event", "Reminder", "Note")


class CanonError(Exception):
    """A concrete source or generated-canon defect."""


def _json_object_without_duplicate_keys(
    pairs: list[tuple[str, Any]],
) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise CanonError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def load_visual_closure_records(root: Path) -> tuple[dict[str, Any], ...]:
    """Load ordered visual-closure JSON records from the repository."""
    records: list[dict[str, Any]] = []
    for relative_path in VISUAL_CLOSURE_MACHINE_PATHS:
        path = _confined_path(root, relative_path)
        try:
            source = path.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError) as exc:
            raise CanonError(
                f"unable to load visual closure record {relative_path}: {exc}"
            ) from exc
        try:
            payload = json.loads(
                source,
                object_pairs_hook=_json_object_without_duplicate_keys,
            )
        except json.JSONDecodeError as exc:
            raise CanonError(f"{relative_path}: invalid JSON: {exc}") from exc
        if not isinstance(payload, dict):
            raise CanonError(f"{relative_path}: root must be an object")
        records.append(payload)
    return tuple(records)


@dataclass(frozen=True, slots=True)
class Requirement:
    requirement_id: str
    title: str
    concept: str
    modality: str
    scope: str
    status: str
    verification: tuple[str, ...]
    supersedes: tuple[str, ...]
    body: str
    source_path: str
    line: int
    owner_spec_id: str
    source_owners: tuple[str, ...]


@dataclass(frozen=True, slots=True)
class Document:
    spec_id: str
    title: str
    kind: str
    status: str
    owner_domain: str
    canon_revision: int
    owns_concepts: tuple[str, ...]
    inherits: tuple[str, ...]
    depends_on: tuple[str, ...]
    source_owners: tuple[str, ...]
    object_boundary: dict[str, Any] | None
    source_path: str
    source_bytes: bytes
    requirements: tuple[Requirement, ...]


@dataclass(frozen=True, slots=True)
class Manifest:
    schema_version: int
    canon_revision: int
    normative_files: tuple[str, ...]
    generated_files: tuple[str, ...]
    reference_files: tuple[str, ...]
    source_bytes: bytes


@dataclass(frozen=True, slots=True)
class Compilation:
    root: Path
    manifest: Manifest
    documents: tuple[Document, ...]
    canon_digest: str
    local_link_count: int
    json_count: int
    ux_screen_count: int
    visual_contract_count: int

    @property
    def requirements(self) -> tuple[Requirement, ...]:
        return tuple(
            requirement
            for document in self.documents
            for requirement in document.requirements
        )


def _strip_code(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value.startswith("`") and value.endswith("`"):
        return value[1:-1]
    return value


def _list_value(value: str) -> tuple[str, ...]:
    if value.strip().casefold() == "none":
        return ()
    backticks = tuple(re.findall(r"`([^`]+)`", value))
    if backticks:
        return backticks
    return (value.strip(),)


def _confined_path(root: Path, relative_path: Path, *, base: Path | None = None) -> Path:
    repository_root = root.resolve(strict=True)
    candidate = ((base or repository_root) / relative_path).resolve()
    try:
        candidate.relative_to(repository_root)
    except ValueError as exc:
        raise CanonError(f"path escapes repository: {relative_path.as_posix()}") from exc
    return candidate


def _wave_2_surface_summaries(
    wave_2_closure: dict[str, Any],
) -> dict[str, dict[str, str]]:
    packages = wave_2_closure.get("packages")
    if not isinstance(packages, list) or not all(
        isinstance(package, dict) for package in packages
    ):
        raise CanonError("Wave 2 closure packages must be a list of objects")
    by_id = {package.get("package_id"): package for package in packages}
    try:
        vc_10_records = by_id["VC-10"]["selected_study_or_synthesis"][
            "records"
        ]
        summaries = {
            "today": {
                "package_id": "VC-07",
                "selected_name": by_id["VC-07"][
                    "selected_study_or_synthesis"
                ]["name"],
            },
            "goals": {
                "package_id": "VC-08",
                "selected_name": by_id["VC-08"][
                    "selected_study_or_synthesis"
                ]["name"],
            },
            "time": {
                "package_id": "VC-09",
                "selected_name": by_id["VC-09"][
                    "selected_study_or_synthesis"
                ]["name"],
            },
            "capture": {
                "package_id": "VC-10",
                "selected_name": vc_10_records[0]["name"],
            },
            "search": {
                "package_id": "VC-10",
                "selected_name": vc_10_records[1]["name"],
            },
            "you": {
                "package_id": "VC-11",
                "selected_name": by_id["VC-11"][
                    "selected_study_or_synthesis"
                ]["primary"]["name"],
            },
            "resilience": {
                "package_id": "VC-12",
                "selected_name": by_id["VC-12"][
                    "selected_study_or_synthesis"
                ]["name"],
            },
        }
    except (KeyError, IndexError, TypeError) as exc:
        raise CanonError("Wave 2 closure selected records are invalid") from exc
    if summaries != EXPECTED_WAVE_2_SUMMARIES:
        raise CanonError("Wave 2 closure selected records are invalid")
    return summaries


def _validate_wave_2_machine_schema(
    root: Path,
    wave_2_closure: dict[str, Any],
) -> None:
    if set(wave_2_closure) - WAVE_2_TOP_LEVEL_FIELDS:
        raise CanonError("Wave 2 closure top-level fields are invalid")

    source_paths = wave_2_closure.get("source_paths")
    if not isinstance(source_paths, list) or not source_paths:
        raise CanonError("Wave 2 closure source paths are invalid")
    for source_path in source_paths:
        if not isinstance(source_path, str):
            raise CanonError("Wave 2 closure source paths are invalid")
        relative_path = Path(source_path)
        if (
            relative_path.is_absolute()
            or ".." in relative_path.parts
            or relative_path.as_posix() != source_path
            or not _confined_path(root, relative_path).is_file()
        ):
            raise CanonError(f"Wave 2 closure source path is invalid: {source_path}")

    packages = wave_2_closure.get("packages")
    if not isinstance(packages, list) or len(packages) != 6:
        raise CanonError("Wave 2 closure packages must be a six-object list")
    selection_fields = {
        "VC-07": {"inputs", "kind", "name"},
        "VC-08": {"id", "inputs", "kind", "name"},
        "VC-09": {"id", "inputs", "kind", "name"},
        "VC-10": {"kind", "records"},
        "VC-11": {"kind", "name", "native_substrate", "primary"},
        "VC-12": {"id", "inputs", "kind", "name"},
    }
    for index, package in enumerate(packages, start=7):
        package_id = f"VC-{index:02d}"
        if not isinstance(package, dict) or set(package) != WAVE_2_PACKAGE_FIELDS:
            raise CanonError(f"Wave 2 closure package fields are invalid: {package_id}")
        selection = package.get("selected_study_or_synthesis")
        transformation = package.get("required_transformation")
        if not isinstance(selection, dict) or set(selection) != selection_fields[
            package_id
        ]:
            raise CanonError(f"Wave 2 closure selected record is invalid: {package_id}")
        expected_transformation_fields = (
            {"name"} if package_id == "VC-10" else {"id", "name"}
        )
        if (
            not isinstance(transformation, dict)
            or set(transformation) != expected_transformation_fields
        ):
            raise CanonError(f"Wave 2 closure transformation is invalid: {package_id}")
        if package_id == "VC-10":
            records = selection.get("records")
            if (
                not isinstance(records, list)
                or len(records) != 2
                or not all(
                    isinstance(record, dict) and set(record) == {"id", "name"}
                    for record in records
                )
            ):
                raise CanonError(
                    "Wave 2 closure selected record is invalid: VC-10"
                )
        if package_id == "VC-11":
            for key in ("primary", "native_substrate"):
                record = selection.get(key)
                if not isinstance(record, dict) or set(record) != {"id", "name"}:
                    raise CanonError(
                        "Wave 2 closure selected record is invalid: VC-11"
                    )

def _validate_wave_2_closure(
    root: Path,
    manifest: Manifest,
    wave_2_closure: dict[str, Any],
) -> None:
    human_path = Path(
        "docs/canon/design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md"
    )
    wave_2_machine_path = VISUAL_CLOSURE_MACHINE_PATHS[2]
    _validate_wave_2_machine_schema(root, wave_2_closure)
    if wave_2_closure.get("schema_version") != 1:
        raise CanonError("Wave 2 closure schema version is invalid")
    if wave_2_closure.get("package_id") != (
        "AMB-VC-WAVE-2-SURFACE-JOURNEY-CLOSURE"
    ):
        raise CanonError("Wave 2 closure package ID is invalid")
    if wave_2_closure.get("status") != "CLOSED":
        raise CanonError("Wave 2 closure status must be closed")
    if wave_2_closure.get("active_direction_ids") != list(
        EXPECTED_ACTIVE_VISUAL_DIRECTIONS
    ):
        raise CanonError("Wave 2 closure active direction IDs are invalid")
    if (
        wave_2_closure.get("package_statuses")
        != WAVE_2_PACKAGE_STATUSES
    ):
        raise CanonError("Wave 2 closure package statuses are invalid")
    if wave_2_closure.get("wave_statuses") != {
        "vc_14_reconciled_matched_baseline": "NOT_STARTED",
        "wave_1_shared_foundation": "CLOSED",
        "wave_2_surfaces_and_journeys": "CLOSED",
        "wave_3_stress_and_matched_baseline": "OPEN",
    }:
        raise CanonError("Wave 2 closure wave statuses are invalid")
    if (
        wave_2_closure.get("authorization_state")
        != FALSE_IMPLEMENTATION_AUTHORIZATION
    ):
        raise CanonError("Wave 2 closure authorization state is invalid")
    if wave_2_closure.get("human_peer") != human_path.as_posix():
        raise CanonError("Wave 2 closure human peer is invalid")
    if wave_2_closure.get("inherits") != {
        "human": "docs/canon/design/VC_WAVE_1_FOUNDATION_CLOSURE.md",
        "machine": VISUAL_CLOSURE_MACHINE_PATHS[1].as_posix(),
    }:
        raise CanonError("Wave 2 closure Wave 1 inheritance is invalid")

    required_references = {
        human_path.relative_to(CANON_ROOT_PATH).as_posix(),
        wave_2_machine_path.relative_to(CANON_ROOT_PATH).as_posix(),
    }
    if not required_references.issubset(set(manifest.reference_files)):
        raise CanonError("Wave 2 closure human/machine peers are not manifested")

    packages = wave_2_closure.get("packages")
    if not isinstance(packages, list):
        raise CanonError("Wave 2 closure packages must be a list")
    package_ids = [
        package.get("package_id")
        for package in packages
        if isinstance(package, dict)
    ]
    if package_ids != [f"VC-{number:02d}" for number in range(7, 13)] or len(
        package_ids
    ) != len(packages):
        raise CanonError("Wave 2 closure package identities are invalid")

    required_fields = {
        "applies_to_avf_ids",
        "architecture_dependencies",
        "authorization_state",
        "deferred_calibration",
        "locked_decisions",
        "package_id",
        "rejected_alternatives",
        "required_transformation",
        "selected_study_or_synthesis",
        "status",
    }
    for package in packages:
        package_id = package["package_id"]
        if not required_fields.issubset(package):
            raise CanonError(
                f"Wave 2 closure package fields are incomplete: {package_id}"
            )
        if package.get("status") != "CLOSED":
            raise CanonError(
                f"Wave 2 closure package must be closed: {package_id}"
            )
        if (
            package.get("authorization_state")
            != FALSE_IMPLEMENTATION_AUTHORIZATION
        ):
            raise CanonError(
                f"Wave 2 closure package authorization is invalid: {package_id}"
            )
        if package.get("applies_to_avf_ids") != list(
            EXPECTED_WAVE_2_AVF_MAPPINGS[package_id]
        ):
            raise CanonError(
                f"Wave 2 closure AVF mapping is invalid: {package_id}"
            )
        for field in (
            "architecture_dependencies",
            "deferred_calibration",
            "rejected_alternatives",
        ):
            value = package.get(field)
            if not isinstance(value, list) or not value:
                raise CanonError(
                    f"Wave 2 closure {field} is invalid: {package_id}"
                )
        if not isinstance(package.get("locked_decisions"), dict) or not package[
            "locked_decisions"
        ]:
            raise CanonError(
                f"Wave 2 closure locked decisions are invalid: {package_id}"
            )
        if not isinstance(package.get("selected_study_or_synthesis"), dict):
            raise CanonError(
                f"Wave 2 closure selected record is invalid: {package_id}"
            )
        if not isinstance(package.get("required_transformation"), dict):
            raise CanonError(
                f"Wave 2 closure transformation is invalid: {package_id}"
            )

    canonical = json.dumps(
        wave_2_closure,
        sort_keys=True,
        separators=(",", ":"),
        ensure_ascii=False,
    ).encode("utf-8")
    if hashlib.sha256(canonical).hexdigest() != EXPECTED_WAVE_2_CANONICAL_SHA256:
        raise CanonError("Wave 2 closure semantic content is invalid")

    _wave_2_surface_summaries(wave_2_closure)
    by_id = {package["package_id"]: package for package in packages}
    if by_id["VC-07"]["locked_decisions"].get("ownership") != {
        "goals": "pursuit_progression",
        "mutation": "owner_routed",
        "time": "exact_chronology_and_temporal_mutation",
        "today": "immediate_execution_projection",
    }:
        raise CanonError("Wave 2 closure ownership boundary is invalid")
    if by_id["VC-07"]["locked_decisions"].get("density_law") != (
        "normal_readable_type_and_natural_scroll"
    ) or by_id["VC-08"]["locked_decisions"].get("density_law") != (
        "compress_preview_breadth_and_secondary_evidence_before_identity_or_type_size"
    ):
        raise CanonError("Wave 2 closure density boundary is invalid")
    if by_id["VC-09"]["locked_decisions"].get("truth_statuses") != [
        "accepted",
        "proposed",
        "external",
        "stale",
        "unknown",
        "historical",
    ]:
        raise CanonError("Wave 2 closure truth boundary is invalid")
    if by_id["VC-10"]["locked_decisions"].get("capability_gates") != [
        "dictation",
        "attachments",
        "direct_mutation",
        "pending",
        "partial_settlement",
        "receipt",
        "undo",
    ]:
        raise CanonError("Wave 2 closure capability boundary is invalid")

    human_markdown = _confined_path(root, human_path).read_text(encoding="utf-8")
    numbered_sections = tuple(
        re.finditer(
            r"(?ms)^## (?P<number>\d+)\. (?P<title>[^\n]+)$.*?"
            r"(?=^## \d+\.|\Z)",
            human_markdown,
        )
    )
    authority_section_specs = (
        ("2", "Active AVF direction set"),
        ("3", "Package status"),
        ("4", "Shared Wave 2 law"),
        ("16", "Authorization state"),
    )
    authority_sections: dict[str, str] = {}
    authority_positions: list[int] = []
    for expected_number, expected_title in authority_section_specs:
        matches = tuple(
            (position, section)
            for position, section in enumerate(numbered_sections)
            if section.group("number") == expected_number
            or section.group("title") == expected_title
        )
        if (
            len(matches) != 1
            or matches[0][1].group("number") != expected_number
            or matches[0][1].group("title") != expected_title
        ):
            raise CanonError(
                "Wave 2 closure human/machine mismatch: "
                f"section {expected_number} authority"
            )
        authority_positions.append(matches[0][0])
        authority_sections[expected_number] = matches[0][1].group(0)
    if authority_positions != sorted(authority_positions):
        raise CanonError(
            "Wave 2 closure human/machine mismatch: authority section order"
        )

    actual_directions = tuple(
        match.group(2)
        for match in re.finditer(
            r"(?m)^(\d+)\. `(AVF-[A-Z0-9-]+)`$",
            authority_sections["2"],
        )
    )
    expected_directions = tuple(wave_2_closure["active_direction_ids"])
    actual_direction_numbers = tuple(
        int(match.group(1))
        for match in re.finditer(
            r"(?m)^(\d+)\. `(AVF-[A-Z0-9-]+)`$",
            authority_sections["2"],
        )
    )
    all_section_direction_ids = tuple(
        re.findall(r"\bAVF-[A-Z0-9-]+\b", authority_sections["2"])
    )
    global_direction_declarations = tuple(
        (int(match.group(1)), match.group(2))
        for match in re.finditer(
            r"(?m)^(\d+)\. `(AVF-[A-Z0-9-]+)`$",
            human_markdown,
        )
    )
    if (
        actual_directions != expected_directions
        or actual_direction_numbers != tuple(range(1, 12))
        or all_section_direction_ids != expected_directions
        or global_direction_declarations
        != tuple(enumerate(expected_directions, start=1))
    ):
        raise CanonError(
            "Wave 2 closure human/machine mismatch: active directions"
        )

    expected_status_rows = (
        "| `VC-01`–`VC-06` | `CLOSED` | Wave 1 shared foundation |",
        "| `VC-07` | `CLOSED` | Today |",
        "| `VC-08` | `CLOSED` | Goals |",
        "| `VC-09` | `CLOSED` | Time |",
        "| `VC-10` | `CLOSED` | Capture and Search |",
        "| `VC-11` | `CLOSED` | You and Appearance Studio |",
        "| `VC-12` | `CLOSED` | Resilience combined states |",
        "| `VC-13` | `OPEN` | Extreme accessibility and content validation |",
        "| `VC-14` | `NOT_STARTED` | Reconciled matched-baseline closure |",
    )
    actual_status_rows = tuple(
        line
        for line in human_markdown.splitlines()
        if line.startswith("| `VC-")
    )
    expected_status_summary = (
        "- Wave 1 shared foundation: `CLOSED`.",
        "- Wave 2 surfaces and journeys: `CLOSED`.",
        "- Wave 3 stress and matched baseline: `OPEN`.",
        "- `VC-14`: `NOT_STARTED`.",
    )
    actual_status_summary = tuple(
        line
        for line in authority_sections["3"].splitlines()
        if line.startswith("- ")
    )
    if (
        actual_status_rows != expected_status_rows
        or actual_status_summary != expected_status_summary
    ):
        raise CanonError(
            "Wave 2 closure human/machine mismatch: package statuses"
        )

    expected_inherited_law = (
        "VC01-TYPE-STUDY-D — Semantic Cadence",
        "Mineral Relief Continuum",
        "VC03-CROWN-D04 — Compact Semantic Stack",
        "VC03-CROWN-D06 — Adaptive Semantic Passage",
        "VC04-DOCK-D04 — Articulated Edge Tray",
        "VC04-DOCK-D06 — Adaptive Navigation Passage",
        "VC05-STATE-D04 — Semantic State Covenant",
        "VC05-STATE-D06 — Explicit Stress Scaffold",
        "VC06-GRAMMAR-D04 — Articulated Native Grammar",
        "VC06-GRAMMAR-D01 — Native Minimal Substrate",
        "VC06-GRAMMAR-D06 — Explicit Accessible Structure",
    )
    actual_inherited_law = tuple(
        re.findall(r"(?m)^- `([^`]+)`$", authority_sections["4"])
    )
    expected_shared_requirements = (
        "Primary content is an opaque matte semantic plane.",
        "Identity precedes status, metrics, chronology, and action.",
        "Content uses readable production-scale typography and natural scrolling.",
        "Dense never means shrinking the entire model into one viewport.",
        "The crown remains compact.",
        "Peek is the ordinary eligible root-browsing dock posture.",
        "Search and Capture remain dock-owned global non-roots.",
        "Focused depth preserves native Back, editing, keyboard, focus, safe area, "
        "and dismissal.",
        "Current, proposed, accepted, external, stale, unknown, historical, saving, "
        "pending, settlement, conflict, and recovery truth remain distinct.",
        "Meaning survives Dynamic Type, VoiceOver, Increased Contrast, Reduce "
        "Transparency, Reduce Motion, localization, RTL, keyboard pressure, and "
        "one-handed reach.",
        "Receipt, Undo, pending, partial settlement, external mutation, and recovery "
        "remain capability-gated.",
        "No Wave 2 package authorizes Figma, SwiftUI, implementation, or final tokens.",
    )
    shared_requirement_matches = tuple(
        re.finditer(
            r"(?ms)^(\d+)\. (.*?)(?=^\d+\. |\Z)",
            authority_sections["4"],
        )
    )
    actual_shared_numbers = tuple(
        int(match.group(1)) for match in shared_requirement_matches
    )
    actual_shared_requirements = tuple(
        " ".join(match.group(2).split())
        for match in shared_requirement_matches
    )
    if (
        actual_inherited_law != expected_inherited_law
        or actual_shared_numbers != tuple(range(1, 13))
        or actual_shared_requirements != expected_shared_requirements
    ):
        raise CanonError(
            "Wave 2 closure human/machine mismatch: shared Wave 2 law"
        )

    expected_authorization_rows = (
        "- Figma authorization: `false`.",
        "- SwiftUI approval: `false`.",
        "- Implementation authorization: `false`.",
        "- Wave 1: `CLOSED`.",
        "- Wave 2: `CLOSED`.",
        "- Wave 3: `OPEN`.",
        "- `VC-13`: `OPEN`.",
        "- `VC-14`: `NOT_STARTED`.",
    )
    actual_authorization_block = tuple(
        line
        for line in authority_sections["16"].splitlines()
        if line
    )
    expected_authorization_block = (
        "## 16. Authorization state",
        *expected_authorization_rows,
    )
    global_authorization_declarations = tuple(
        match.group(0)
        for match in re.finditer(
            r"(?m)^- (?:Figma authorization|SwiftUI approval|"
            r"Implementation authorization): `(?:true|false)`\.$",
            human_markdown,
        )
    )
    if (
        actual_authorization_block != expected_authorization_block
        or global_authorization_declarations != expected_authorization_rows[:3]
    ):
        raise CanonError(
            "Wave 2 closure human/machine mismatch: authorization state"
        )

    package_status_sections = tuple(
        section
        for section in numbered_sections
        if section.group("title") == "Package status"
    )
    if (
        len(package_status_sections) != 1
        or package_status_sections[0].group("number") != "3"
    ):
        raise CanonError(
            "Wave 2 closure human/machine mismatch: "
            "Package status authority section"
        )
    package_status_section = package_status_sections[0]
    actual_package_rows = tuple(
        re.findall(
            r"(?m)^\| `(VC-(?:0[7-9]|1[0-2]))` \| `([^`]+)` \|",
            package_status_section.group(0),
        )
    )
    expected_package_rows = tuple(
        (package_id, wave_2_closure["package_statuses"][package_id])
        for package_id in (f"VC-{number:02d}" for number in range(7, 13))
    )
    if actual_package_rows != expected_package_rows:
        raise CanonError(
            "Wave 2 closure human/machine mismatch: package statuses"
        )

    human_direction_positions = {
        "VC-07": (0,),
        "VC-08": (0,),
        "VC-09": (0,),
        "VC-10": (0, 1),
        "VC-11": (0,),
        "VC-12": (0, 1),
    }
    package_sections: dict[str, str] = {}
    for package in packages:
        package_id = package["package_id"]
        section_matches = tuple(
            section
            for section in numbered_sections
            if re.match(
                rf"{re.escape(package_id)}\b",
                section.group("title"),
            )
        )
        if len(section_matches) != 1:
            raise CanonError(
                "Wave 2 closure human/machine mismatch: "
                f"owning authority section for {package_id}"
            )
        section = section_matches[0].group(0)
        package_sections[package_id] = section
        actual_directions = tuple(
            re.findall(r"\bAVF-[A-Z0-9-]+\b", section)
        )
        expected_directions = tuple(
            package["applies_to_avf_ids"][position]
            for position in human_direction_positions[package_id]
        )
        if actual_directions != expected_directions:
            raise CanonError(
                "Wave 2 closure human/machine mismatch: "
                f"package directions for {package_id}"
            )

    for package in packages:
        package_id = package["package_id"]
        selection = package["selected_study_or_synthesis"]
        if package_id == "VC-07":
            input_labels = " + ".join(
                item.rsplit("-", 1)[-1] for item in selection["inputs"]
            )
            expected_declarations = (
                (
                    "Selected synthesis",
                    f"`{input_labels} — {selection['name']}`",
                ),
            )
            expected_record_ids: tuple[str, ...] = ()
        elif package_id == "VC-10":
            expected_declarations = tuple(
                (
                    label,
                    f"`{record['id']} — {record['name']}`",
                )
                for label, record in zip(
                    ("Capture closure", "Search closure"),
                    selection["records"],
                    strict=True,
                )
            )
            expected_record_ids = tuple(
                record["id"] for record in selection["records"]
            )
        elif package_id == "VC-11":
            expected_declarations = tuple(
                (
                    label,
                    f"`{record['id']} — {record['name']}`",
                )
                for label, record in zip(
                    (
                        "Selected root structure",
                        "Native substrate",
                        "Required transformation",
                    ),
                    (
                        selection["primary"],
                        selection["native_substrate"],
                        package["required_transformation"],
                    ),
                    strict=True,
                )
            )
            expected_record_ids = (
                selection["primary"]["id"],
                selection["native_substrate"]["id"],
                package["required_transformation"]["id"],
            )
        else:
            expected_declarations = (
                (
                    "Locked closure",
                    f"`{selection['id']} — {selection['name']}`",
                ),
            )
            expected_record_ids = (selection["id"],)
        section = package_sections[package_id]
        for label, expected_identifier in expected_declarations:
            actual_identifiers = re.findall(
                rf"(?m)^{re.escape(label)}:\n\n(`[^`\n]+`)$",
                section,
            )
            if actual_identifiers != [expected_identifier] or section.count(
                expected_identifier
            ) != 1:
                raise CanonError(
                    "Wave 2 closure human/machine mismatch: "
                    f"selected identifiers for {package_id}"
                )
        actual_record_ids = tuple(
            re.findall(r"\bVC(?:0[7-9]|1[0-2])-[A-Z0-9-]+\b", section)
        )
        if actual_record_ids != expected_record_ids:
            raise CanonError(
                "Wave 2 closure human/machine mismatch: "
                f"selected record set for {package_id}"
            )

    expected_status_line = "Status: `CLOSED / ACTIVE_WAVE_2_CLOSURE_AUTHORITY`"
    if human_markdown.splitlines().count(expected_status_line) != 1:
        raise CanonError(
            "Wave 2 closure human/machine mismatch: authority status"
        )


def _validate_wave_3_closure(
    root: Path,
    manifest: Manifest,
    wave_3_closure: dict[str, Any],
) -> None:
    human_path = Path(
        "docs/canon/design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md"
    )
    machine_path = VISUAL_CLOSURE_MACHINE_PATHS[3]
    if wave_3_closure.get("schema_version") != 1:
        raise CanonError("Wave 3 closure schema version is invalid")
    if wave_3_closure.get("package_id") != (
        "AMB-VC-WAVE-3-ACCESSIBILITY-STRESS-CLOSURE"
    ):
        raise CanonError("Wave 3 closure package ID is invalid")
    if wave_3_closure.get("status") != "CLOSED":
        raise CanonError("Wave 3 closure status must be closed")
    if wave_3_closure.get("active_direction_ids") != list(
        EXPECTED_ACTIVE_VISUAL_DIRECTIONS
    ):
        raise CanonError("Wave 3 closure active direction IDs are invalid")
    if (
        wave_3_closure.get("package_statuses")
        != EXPECTED_EFFECTIVE_PACKAGE_STATUSES
    ):
        raise CanonError("Wave 3 closure package statuses are invalid")
    if (
        wave_3_closure.get("authorization_state")
        != FALSE_IMPLEMENTATION_AUTHORIZATION
    ):
        raise CanonError("Wave 3 closure authorization state is invalid")
    if wave_3_closure.get("human_peer") != human_path.as_posix():
        raise CanonError("Wave 3 closure human peer is invalid")
    if wave_3_closure.get("inherits") != {
        "input_contract_human": (
            "docs/canon/design/VISUAL_CLOSURE_INPUT_CONTRACT.md"
        ),
        "input_contract_machine": VISUAL_CLOSURE_MACHINE_PATHS[0].as_posix(),
        "wave_1_human": (
            "docs/canon/design/VC_WAVE_1_FOUNDATION_CLOSURE.md"
        ),
        "wave_1_machine": VISUAL_CLOSURE_MACHINE_PATHS[1].as_posix(),
        "wave_2_human": (
            "docs/canon/design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md"
        ),
        "wave_2_machine": VISUAL_CLOSURE_MACHINE_PATHS[2].as_posix(),
    }:
        raise CanonError("Wave 3 closure Wave 1/Wave 2 inheritance is invalid")
    if wave_3_closure.get("wave_statuses") != {
        "vc_14_reconciled_matched_baseline": "NOT_STARTED",
        "wave_1_shared_foundation": "CLOSED",
        "wave_2_surfaces_and_journeys": "CLOSED",
        "wave_3_accessibility_content_stress_validation": "CLOSED",
        "wave_3_overall_stress_and_matched_baseline": "OPEN_PENDING_VC_14",
    }:
        raise CanonError("Wave 3 closure wave statuses are invalid")

    required_references = {
        human_path.relative_to(CANON_ROOT_PATH).as_posix(),
        machine_path.relative_to(CANON_ROOT_PATH).as_posix(),
    }
    if not required_references.issubset(set(manifest.reference_files)):
        raise CanonError("Wave 3 closure human/machine peers are not manifested")

    package = wave_3_closure.get("package")
    if not isinstance(package, dict) or package.get("package_id") != "VC-13":
        raise CanonError("Wave 3 closure VC-13 package is invalid")
    if package.get("status") != "CLOSED":
        raise CanonError("Wave 3 closure VC-13 package must be closed")
    if package.get("selected_closure") != {
        "id": "VC13-A11Y-S01",
        "kind": "validation_synthesis",
        "name": "Stress-Proven Adaptive Semantic Continuity",
    }:
        raise CanonError("Wave 3 closure selected record is invalid")
    applies_to = package.get("applies_to_avf_ids")
    if (
        not isinstance(applies_to, list)
        or not applies_to
        or len(applies_to) != len(set(applies_to))
        or set(applies_to) - set(EXPECTED_ACTIVE_VISUAL_DIRECTIONS)
    ):
        raise CanonError("Wave 3 closure selected record AVF mapping is invalid")
    failure = package.get("failure_classification")
    overall = package.get("overall_result")
    if (
        not isinstance(failure, dict)
        or failure.get("structural_branch_required") is not False
        or not isinstance(overall, dict)
        or overall.get("structural_branch_required") is not False
        or overall.get("active_direction_change") is not False
        or overall.get("wave_1_or_wave_2_reopened") is not False
        or overall.get("direct_device_proof_required") is not True
    ):
        raise CanonError("Wave 3 closure structural result is invalid")
    for field in (
        "shared_first_viewport_doctrine",
        "compression_order",
        "never_compress",
        "surface_results",
        "shell_results",
        "keyboard_safe_action_boundary",
        "reduced_effects_contract",
        "rtl_semantic_invariants",
        "focus_entry",
        "focus_return_priority",
        "hidden_sensitive_value_contract",
        "combined_state_order",
        "combined_state_precedence",
    ):
        if not package.get(field):
            raise CanonError(f"Wave 3 closure structured field is invalid: {field}")
    for field in (
        "architecture_dependencies",
        "direct_device_proof_register",
        "vc_14_entry_criteria",
    ):
        value = wave_3_closure.get(field)
        if not isinstance(value, list) or not value:
            raise CanonError(f"Wave 3 closure register is invalid: {field}")

    canonical = json.dumps(
        wave_3_closure,
        sort_keys=True,
        separators=(",", ":"),
        ensure_ascii=False,
    ).encode("utf-8")
    if hashlib.sha256(canonical).hexdigest() != EXPECTED_WAVE_3_CANONICAL_SHA256:
        raise CanonError("Wave 3 closure semantic content is invalid")
    try:
        human_sha = hashlib.sha256(
            _confined_path(root, human_path).read_bytes()
        ).hexdigest()
    except OSError as exc:
        raise CanonError("Wave 3 closure human peer is missing") from exc
    if human_sha != EXPECTED_WAVE_3_HUMAN_SHA256:
        raise CanonError("Wave 3 closure human/machine mismatch")


def _wave_3_accessibility_stress(
    wave_3_closure: dict[str, Any],
) -> dict[str, Any]:
    return {
        **wave_3_closure["package"],
        "architecture_dependency_register": wave_3_closure[
            "architecture_dependencies"
        ],
        "direct_device_proof_register": wave_3_closure[
            "direct_device_proof_register"
        ],
        "vc_14_entry_criteria": wave_3_closure["vc_14_entry_criteria"],
    }


def load_manifest(root: Path) -> Manifest:
    path = _confined_path(root, MANIFEST_PATH)
    try:
        source = path.read_bytes()
        data = tomllib.loads(source.decode("utf-8"))
    except (OSError, UnicodeDecodeError, tomllib.TOMLDecodeError) as exc:
        raise CanonError(f"unable to parse {MANIFEST_PATH}: {exc}") from exc

    allowed = {
        "schema_version",
        "canon_revision",
        "normative_files",
        "generated_files",
        "reference_files",
    }
    unknown = sorted(set(data) - allowed)
    if unknown:
        raise CanonError(f"MANIFEST.toml has unknown field: {unknown[0]}")
    missing = sorted(allowed - set(data))
    if missing:
        raise CanonError(f"MANIFEST.toml is missing field: {missing[0]}")
    if data["schema_version"] != 2:
        raise CanonError("MANIFEST.toml schema_version must be 2")
    if not isinstance(data["canon_revision"], int) or data["canon_revision"] < 1:
        raise CanonError("MANIFEST.toml canon_revision must be a positive integer")

    lists: dict[str, tuple[str, ...]] = {}
    for key in ("normative_files", "generated_files", "reference_files"):
        values = data[key]
        if not isinstance(values, list) or not values or not all(
            isinstance(value, str) and value for value in values
        ):
            raise CanonError(f"MANIFEST.toml {key} must be a non-empty string list")
        if len(values) != len(set(values)):
            raise CanonError(f"MANIFEST.toml {key} contains duplicate paths")
        lists[key] = tuple(values)

    if lists["generated_files"] != GENERATED_PATHS:
        expected = ", ".join(GENERATED_PATHS)
        raise CanonError(f"MANIFEST.toml generated_files must be exactly: {expected}")

    canon_root = _confined_path(root, CANON_ROOT_PATH)
    for key in ("normative_files", "reference_files"):
        for value in lists[key]:
            path = _confined_path(root, Path(value), base=canon_root)
            if not path.is_file():
                raise CanonError(f"manifest path is missing: {value}")

    discovered = {"CONSTITUTION.md"}
    discovered.update(
        path.relative_to(canon_root).as_posix()
        for path in (canon_root / "specifications").rglob("*.md")
    )
    discovered.update(
        path.relative_to(canon_root).as_posix()
        for path in (canon_root / "standards").glob("*.md")
    )
    declared = set(lists["normative_files"])
    if discovered != declared:
        missing_paths = sorted(discovered - declared)
        stale_paths = sorted(declared - discovered)
        details = [*(f"unlisted normative file: {p}" for p in missing_paths)]
        details.extend(f"stale normative manifest path: {p}" for p in stale_paths)
        raise CanonError("; ".join(details))

    return Manifest(
        schema_version=data["schema_version"],
        canon_revision=data["canon_revision"],
        normative_files=lists["normative_files"],
        generated_files=lists["generated_files"],
        reference_files=lists["reference_files"],
        source_bytes=source,
    )


def _frontmatter(path: Path, text: str) -> tuple[dict[str, Any], int]:
    if not text.startswith("+++\n"):
        raise CanonError(f"{path}: missing opening TOML frontmatter delimiter")
    end = text.find("\n+++\n", 4)
    if end == -1:
        raise CanonError(f"{path}: missing closing TOML frontmatter delimiter")
    try:
        data = tomllib.loads(text[4:end])
    except tomllib.TOMLDecodeError as exc:
        raise CanonError(f"{path}: invalid TOML frontmatter: {exc}") from exc
    for key, expected_type in REQUIRED_FRONTMATTER.items():
        value = data.get(key)
        if not isinstance(value, expected_type) or (
            expected_type is list and not all(isinstance(item, str) for item in value)
        ):
            raise CanonError(f"{path}: invalid or missing frontmatter field: {key}")
    return data, end + len("\n+++\n")


def parse_document(root: Path, relative_path: str, manifest_revision: int) -> Document:
    canon_root = _confined_path(root, CANON_ROOT_PATH)
    path = _confined_path(root, Path(relative_path), base=canon_root)
    source = path.read_bytes()
    try:
        text = source.decode("utf-8")
    except UnicodeDecodeError as exc:
        raise CanonError(f"{relative_path}: source is not UTF-8") from exc
    metadata, body_start = _frontmatter(Path(relative_path), text)

    if metadata["status"] != "normative":
        raise CanonError(f"{relative_path}: document status must be normative")
    if not SPEC_ID_RE.fullmatch(metadata["spec_id"]):
        raise CanonError(f"{relative_path}: invalid spec_id: {metadata['spec_id']}")
    if not 1 <= metadata["canon_revision"] <= manifest_revision:
        raise CanonError(f"{relative_path}: canon_revision exceeds manifest revision")
    for key in ("owns_concepts", "inherits", "depends_on", "source_owners"):
        if len(metadata[key]) != len(set(metadata[key])):
            raise CanonError(f"{relative_path}: duplicate {key} value")
    for concept in metadata["owns_concepts"]:
        if not CONCEPT_RE.fullmatch(concept):
            raise CanonError(f"{relative_path}: invalid concept: {concept}")

    body = text[body_start:]
    matches = list(REQUIREMENT_HEADING_RE.finditer(body))
    candidate_ids = {match.group(1) for match in HEADING_WITH_SEPARATOR_RE.finditer(body)}
    valid_ids = {match.group(1) for match in matches}
    invalid_ids = sorted(candidate_ids - valid_ids)
    if invalid_ids:
        raise CanonError(f"{relative_path}: invalid requirement ID: {invalid_ids[0]}")
    if not matches:
        raise CanonError(f"{relative_path}: no canonical requirements")

    requirements: list[Requirement] = []
    for index, match in enumerate(matches):
        next_heading = LEVEL_TWO_HEADING_RE.search(body, match.end())
        block_end = next_heading.start() if next_heading else len(body)
        block = body[match.end() : block_end]
        field_matches = list(FIELD_RE.finditer(block))
        fields: dict[str, str] = {}
        for field_match in field_matches:
            key = field_match.group(1)
            if key in fields:
                raise CanonError(
                    f"{relative_path}:{text[: body_start + match.start()].count(chr(10)) + 1}: "
                    f"duplicate requirement field: {key}"
                )
            fields[key] = field_match.group(2)
        missing = [key for key in REQUIREMENT_FIELDS if key not in fields]
        line = text[: body_start + match.start()].count("\n") + 1
        if missing:
            raise CanonError(
                f"{relative_path}:{line}: {match.group(1)} missing field: {missing[0]}"
            )
        concept = _strip_code(fields["Concept"])
        modality = _strip_code(fields["Modality"])
        status = _strip_code(fields["Status"])
        if not CONCEPT_RE.fullmatch(concept):
            raise CanonError(f"{relative_path}:{line}: invalid concept: {concept}")
        if modality not in MODALITIES:
            raise CanonError(f"{relative_path}:{line}: invalid modality: {modality}")
        if status != "normative":
            raise CanonError(f"{relative_path}:{line}: requirement status must be normative")
        last_field_end = field_matches[-1].end() if field_matches else 0
        requirement_body = block[last_field_end:].strip()
        if not requirement_body:
            raise CanonError(f"{relative_path}:{line}: requirement body is empty")
        requirements.append(
            Requirement(
                requirement_id=match.group(1),
                title=match.group(2).strip(),
                concept=concept,
                modality=modality,
                scope=_strip_code(fields["Scope"]),
                status=status,
                verification=_list_value(fields["Verification"]),
                supersedes=_list_value(fields["Supersedes"]),
                body=requirement_body,
                source_path=relative_path,
                line=line,
                owner_spec_id=metadata["spec_id"],
                source_owners=tuple(metadata["source_owners"]),
            )
        )

    owned = set(metadata["owns_concepts"])
    actual = {requirement.concept for requirement in requirements}
    if owned != actual:
        missing = sorted(owned - actual)
        unowned = sorted(actual - owned)
        details = [*(f"owned concept has no requirement: {v}" for v in missing)]
        details.extend(f"requirement concept is not owned: {v}" for v in unowned)
        raise CanonError(f"{relative_path}: " + "; ".join(details))
    if len(actual) != len(requirements):
        raise CanonError(f"{relative_path}: duplicate requirement concept")

    object_boundary = metadata.get("object_boundary")
    if object_boundary is not None and not isinstance(object_boundary, dict):
        raise CanonError(f"{relative_path}: object_boundary must be a table")

    return Document(
        spec_id=metadata["spec_id"],
        title=metadata["title"],
        kind=metadata["kind"],
        status=metadata["status"],
        owner_domain=metadata["owner_domain"],
        canon_revision=metadata["canon_revision"],
        owns_concepts=tuple(metadata["owns_concepts"]),
        inherits=tuple(metadata["inherits"]),
        depends_on=tuple(metadata["depends_on"]),
        source_owners=tuple(metadata["source_owners"]),
        object_boundary=object_boundary,
        source_path=relative_path,
        source_bytes=source,
        requirements=tuple(requirements),
    )


def _find_cycle(graph: dict[str, tuple[str, ...]]) -> tuple[str, ...] | None:
    visited: set[str] = set()
    active: list[str] = []

    def visit(node: str) -> tuple[str, ...] | None:
        if node in active:
            start = active.index(node)
            return tuple(active[start:] + [node])
        if node in visited:
            return None
        active.append(node)
        for dependency in graph.get(node, ()):
            cycle = visit(dependency)
            if cycle:
                return cycle
        active.pop()
        visited.add(node)
        return None

    for node in sorted(graph):
        cycle = visit(node)
        if cycle:
            return cycle
    return None


def validate_documents(documents: tuple[Document, ...]) -> None:
    errors: list[str] = []
    spec_by_id: dict[str, Document] = {}
    requirement_by_id: dict[str, Requirement] = {}
    concept_owner: dict[str, Requirement] = {}
    for document in documents:
        if document.spec_id in spec_by_id:
            errors.append(f"duplicate spec_id: {document.spec_id}")
        spec_by_id[document.spec_id] = document
        for requirement in document.requirements:
            previous = requirement_by_id.get(requirement.requirement_id)
            if previous:
                errors.append(
                    f"duplicate requirement ID {requirement.requirement_id}: "
                    f"{previous.source_path} and {requirement.source_path}"
                )
            requirement_by_id[requirement.requirement_id] = requirement
            previous_concept = concept_owner.get(requirement.concept)
            if previous_concept:
                errors.append(
                    f"duplicate concept owner {requirement.concept}: "
                    f"{previous_concept.owner_spec_id} and {requirement.owner_spec_id}"
                )
            concept_owner[requirement.concept] = requirement

    for document in documents:
        for dependency in document.depends_on:
            if dependency not in spec_by_id:
                errors.append(f"{document.spec_id}: unknown dependency: {dependency}")
        for inherited in document.inherits:
            if inherited not in requirement_by_id:
                errors.append(f"{document.spec_id}: unknown inherited requirement: {inherited}")

    cycle = _find_cycle(
        {document.spec_id: document.depends_on for document in documents}
    )
    if cycle:
        errors.append("document dependency cycle: " + " -> ".join(cycle))

    constitution = spec_by_id.get("CONSTITUTION")
    if constitution is None:
        errors.append("CONSTITUTION is missing")
    else:
        constitution_ids = {req.requirement_id for req in constitution.requirements}
        for requirement_id in sorted(REQUIRED_CONSTITUTION_IDS - constitution_ids):
            errors.append(f"Constitution is missing product law: {requirement_id}")
        constitution_text = constitution.source_bytes.decode("utf-8")
        for article in range(1, 10):
            if f"# Article {article} " not in constitution_text:
                errors.append(f"Constitution is missing Article {article}")

    if errors:
        raise CanonError("\n".join(errors))


def validate_repository_bindings(
    root: Path,
    documents: tuple[Document, ...],
) -> None:
    """Validate live source ownership and explicit historical supersession."""
    repository_root = root.resolve(strict=True)
    active_requirement_ids = {
        requirement.requirement_id
        for document in documents
        for requirement in document.requirements
    }
    errors: list[str] = []
    for document in documents:
        for source_owner in document.source_owners:
            try:
                owner_path = _confined_path(
                    repository_root,
                    Path(source_owner),
                )
            except CanonError as exc:
                errors.append(f"{document.spec_id}: {exc}")
                continue
            if not owner_path.exists():
                errors.append(
                    f"{document.spec_id}: missing source owner: {source_owner}"
                )
        for requirement in document.requirements:
            for superseded in requirement.supersedes:
                if (
                    superseded in active_requirement_ids
                    or HISTORICAL_CLAIM_RE.fullmatch(superseded)
                    or superseded in KNOWN_RETIRED_REQUIREMENT_IDS
                ):
                    continue
                errors.append(
                    f"{requirement.requirement_id}: unknown superseded "
                    f"requirement: {superseded}"
                )
    if errors:
        raise CanonError("\n".join(errors))


def _manifest_markdown_paths(root: Path, manifest: Manifest) -> Iterable[Path]:
    canon_root = _confined_path(root, CANON_ROOT_PATH)
    for value in (*manifest.normative_files, *manifest.reference_files):
        path = _confined_path(root, Path(value), base=canon_root)
        if path.suffix.casefold() == ".md":
            yield path


def validate_local_links(root: Path, manifest: Manifest) -> int:
    repository_root = root.resolve(strict=True)
    count = 0
    errors: list[str] = []
    for path in _manifest_markdown_paths(root, manifest):
        text = path.read_text(encoding="utf-8")
        for match in MARKDOWN_LINK_RE.finditer(text):
            target = match.group(1).strip()
            if target.startswith("<") and ">" in target:
                target = target[1 : target.index(">")]
            else:
                target = target.split(maxsplit=1)[0]
            parsed = urlparse(target)
            if not target or parsed.scheme or target.startswith("#"):
                continue
            local_target = unquote(target.split("#", 1)[0])
            if not local_target:
                continue
            count += 1
            resolved = (path.parent / local_target).resolve()
            try:
                resolved.relative_to(repository_root)
            except ValueError:
                errors.append(
                    f"{path.relative_to(repository_root)}: link escapes repository: {target}"
                )
                continue
            if not resolved.exists():
                errors.append(
                    f"{path.relative_to(repository_root)}: broken local link: {target}"
                )
    if errors:
        raise CanonError("\n".join(errors))
    return count


def validate_structured_references(root: Path) -> int:
    repository_root = root.resolve(strict=True)
    roots = (
        repository_root / "docs/canon/design",
        repository_root / "docs/canon/migration",
        repository_root / "docs/canon/schemas",
        repository_root / "docs/design/provenance",
        repository_root / "docs/qa/evidence",
    )
    paths = sorted(path for scan_root in roots for path in scan_root.rglob("*.json"))
    errors: list[str] = []
    for path in paths:
        try:
            json.loads(path.read_text(encoding="utf-8"))
        except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
            errors.append(f"invalid JSON {path.relative_to(repository_root)}: {exc}")
    if errors:
        raise CanonError("\n".join(errors))
    return len(paths)


def validate_design_direction(root: Path) -> tuple[int, int]:
    canon_root = _confined_path(root, CANON_ROOT_PATH)
    blueprint = (canon_root / "migration/UX_BLUEPRINT.md").read_text(encoding="utf-8")
    visual_system = (canon_root / "design/VISUAL_SYSTEM_R1.md").read_text(
        encoding="utf-8"
    )
    provenance = (root / "docs/design/provenance/README.md").read_text(
        encoding="utf-8"
    )
    screens = set(re.findall(r"\bUX-SCREEN-[A-Z0-9-]+", blueprint))
    contracts = set(re.findall(r"\bVAD-R1-[A-Z0-9-]+", visual_system))
    if len(screens) < 30:
        raise CanonError(f"UX Blueprint has only {len(screens)} screen IDs")
    if len(contracts) < 25:
        raise CanonError(f"Visual System R1 has only {len(contracts)} contracts")
    for number in range(1, 11):
        vsp = f"VSP-{number:02d}"
        if vsp not in provenance:
            raise CanonError(f"visual provenance index is missing {vsp}")
    return len(screens), len(contracts)


def _validate_visual_system_provenance(
    root: Path,
    visual_system: str,
) -> None:
    provenance_matches = tuple(
        re.finditer(
            r"(?m)^- [^;\n]* SHA-256 for `(?P<path>[^`]+)`: "
            r"`(?P<sha>[0-9a-f]{64})`;$",
            visual_system,
        )
    )
    expected_paths = {
        "docs/canon/migration/ux-blueprint.json",
        "docs/canon/migration/ux-blueprint-state-inventory.json",
        "docs/canon/migration/ux-blueprint-requirement-dispositions.json",
        "docs/canon/design/VISUAL_CLOSURE_INPUT_CONTRACT.md",
        "docs/canon/design/visual-closure-input-contract.json",
        "docs/canon/design/VC_WAVE_1_FOUNDATION_CLOSURE.md",
        "docs/canon/design/vc-wave-1-foundation-closure.json",
        "docs/canon/design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md",
        "docs/canon/design/vc-wave-2-surface-journey-closure.json",
        "docs/canon/design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md",
        "docs/canon/design/vc-wave-3-accessibility-stress-closure.json",
        "docs/canon/generated/visual-authority-manifest.json",
    }
    provenance_by_path = {
        match.group("path"): match.group("sha") for match in provenance_matches
    }
    if (
        set(provenance_by_path) != expected_paths
        or len(provenance_matches) != len(expected_paths)
    ):
        raise CanonError("Visual System provenance declarations are invalid")
    ux_markdown_matches = re.findall(
        r"(?m)^- UX blueprint Markdown SHA-256: `([0-9a-f]{64})`;$",
        visual_system,
    )
    if len(ux_markdown_matches) != 1:
        raise CanonError("Visual System provenance declarations are invalid")
    provenance_by_path["docs/canon/migration/UX_BLUEPRINT.md"] = (
        ux_markdown_matches[0]
    )
    for source_path, declared_sha in provenance_by_path.items():
        relative_path = Path(source_path)
        if relative_path.is_absolute() or ".." in relative_path.parts:
            raise CanonError(
                f"Visual System provenance path is invalid: {source_path}"
            )
        source_file = _confined_path(root, relative_path)
        if not source_file.is_file():
            raise CanonError(
                f"Visual System provenance source is missing: {source_path}"
            )
        actual_sha = hashlib.sha256(source_file.read_bytes()).hexdigest()
        if actual_sha != declared_sha:
            raise CanonError(
                f"Visual System provenance SHA is stale: {source_path}"
            )


def validate_design_artifacts(compilation: Compilation) -> None:
    """Validate active UX and visual-design artifacts against compiled canon."""
    root = compilation.root

    def load(relative_path: str) -> dict[str, Any]:
        path = _confined_path(root, Path(relative_path))
        try:
            payload = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise CanonError(f"{relative_path}: invalid JSON: {exc}") from exc
        if not isinstance(payload, dict):
            raise CanonError(f"{relative_path}: root must be an object")
        return payload

    blueprint_path = "docs/canon/migration/ux-blueprint.json"
    dispositions_path = (
        "docs/canon/migration/ux-blueprint-requirement-dispositions.json"
    )
    visual_contract_path = VISUAL_CLOSURE_MACHINE_PATHS[0].as_posix()
    wave_1_closure_path = VISUAL_CLOSURE_MACHINE_PATHS[1].as_posix()
    blueprint = load(blueprint_path)
    dispositions = load(dispositions_path)
    visual_contract, wave_1_closure, wave_2_closure, wave_3_closure = (
        load_visual_closure_records(root)
    )

    state_models = blueprint.get("state_models")
    if not isinstance(state_models, list):
        raise CanonError("UX Blueprint state_models must be a list")
    for state_model in state_models:
        if not isinstance(state_model, dict):
            raise CanonError("UX Blueprint has an invalid state model")
        state_model_id = state_model.get("blueprint_id")
        title = state_model.get("title")
        variants = state_model.get("variants")
        taxonomy_rows = state_model.get("taxonomy")
        if not isinstance(state_model_id, str) or not isinstance(title, str):
            raise CanonError("UX Blueprint state model identity is invalid")
        if not title.endswith(" explicit state contract"):
            raise CanonError(
                f"UX Blueprint state model title is invalid: {state_model_id}"
            )
        if not isinstance(variants, list) or not isinstance(taxonomy_rows, list):
            raise CanonError(
                f"UX Blueprint state model variants/taxonomy are invalid: "
                f"{state_model_id}"
            )

        variants_by_kind = {kind: [] for kind in UX_STATE_GENERIC_KINDS}
        for variant in variants:
            if not isinstance(variant, dict):
                raise CanonError(
                    f"UX Blueprint state model has an invalid variant: "
                    f"{state_model_id}"
                )
            generic_kind = variant.get("generic_kind")
            variant_id = variant.get("blueprint_id")
            if (
                generic_kind not in variants_by_kind
                or not isinstance(variant_id, str)
            ):
                raise CanonError(
                    f"UX Blueprint state model variant identity is invalid: "
                    f"{state_model_id}"
                )
            variants_by_kind[generic_kind].append(variant_id)

        taxonomy_kinds: list[str] = []
        screen_title = title.removesuffix(" explicit state contract")
        for taxonomy in taxonomy_rows:
            if not isinstance(taxonomy, dict):
                raise CanonError(
                    f"UX Blueprint has an invalid taxonomy row: {state_model_id}"
                )
            generic_kind = taxonomy.get("generic_kind")
            if generic_kind not in variants_by_kind:
                raise CanonError(
                    f"UX Blueprint taxonomy kind is invalid: {state_model_id}"
                )
            taxonomy_kinds.append(generic_kind)
            expected_variant_ids = sorted(variants_by_kind[generic_kind])
            expected_applicability = (
                "applicable" if expected_variant_ids else "not_applicable"
            )
            if expected_variant_ids:
                expected_rationale = (
                    f"{screen_title} maps {generic_kind} only through the listed "
                    "exact named variants; no anonymous or inferred "
                    f"{generic_kind} presentation is authorized."
                )
            else:
                expected_rationale = (
                    f"{screen_title} declares no canonical named {generic_kind} "
                    "state in this blueprint; no synthetic "
                    f"{generic_kind} screen is authorized."
                )

            if taxonomy.get("variant_ids") != expected_variant_ids:
                raise CanonError(
                    "UX Blueprint taxonomy variant_ids do not match named "
                    f"variants: {state_model_id}/{generic_kind}"
                )
            if taxonomy.get("applicability") != expected_applicability:
                raise CanonError(
                    "UX Blueprint taxonomy applicability contradicts named "
                    f"variants: {state_model_id}/{generic_kind}"
                )
            if taxonomy.get("rationale") != expected_rationale:
                raise CanonError(
                    "UX Blueprint taxonomy rationale contradicts named "
                    f"variants: {state_model_id}/{generic_kind}"
                )

        if sorted(taxonomy_kinds) != sorted(UX_STATE_GENERIC_KINDS):
            raise CanonError(
                "UX Blueprint taxonomy must cover each generic kind exactly "
                f"once: {state_model_id}"
            )

    revision = compilation.manifest.canon_revision
    digest = compilation.canon_digest
    for label, payload in (
        ("UX Blueprint", blueprint),
        ("UX Blueprint dispositions", dispositions),
    ):
        if payload.get("canon_revision") != revision:
            raise CanonError(
                f"{label} canon_revision must be {revision}; "
                f"found {payload.get('canon_revision')!r}"
            )
        if payload.get("canon_content_sha") != digest:
            raise CanonError(
                f"{label} canon_content_sha must match compiled canon digest"
            )

    active_requirement_ids = {
        requirement.requirement_id for requirement in compilation.requirements
    }

    def disposition_ids(payload: Any, *, label: str) -> set[str]:
        if not isinstance(payload, list):
            raise CanonError(f"{label} must be a list")
        values = [
            item.get("requirement_id")
            for item in payload
            if isinstance(item, dict)
        ]
        if len(values) != len(payload) or not all(
            isinstance(value, str) for value in values
        ):
            raise CanonError(f"{label} contains an invalid requirement_id")
        if len(values) != len(set(values)):
            raise CanonError(f"{label} contains duplicate requirement IDs")
        return set(values)

    blueprint_dispositions = blueprint.get("requirement_dispositions")
    disposition_records = dispositions.get("dispositions")
    for label, payload in (
        ("UX Blueprint requirement dispositions", blueprint_dispositions),
        ("requirement dispositions", disposition_records),
    ):
        if disposition_ids(payload, label=label) != active_requirement_ids:
            raise CanonError(
                "requirement dispositions do not match active canon"
            )
    if blueprint_dispositions != disposition_records:
        raise CanonError(
            "UX Blueprint Markdown/JSON disposition sources disagree"
        )

    if visual_contract.get("status") != "ACTIVE_RECONCILED_BASELINE":
        raise CanonError("visual closure input status must be active reconciled")
    if set(visual_contract.get("classification_vocabulary", [])) != (
        VISUAL_CLASSIFICATIONS
    ):
        raise CanonError("visual closure classification vocabulary is invalid")
    authorization = visual_contract.get("authorization")
    if authorization != {
        "figma": False,
        "implementation": False,
        "swiftui": False,
        "visual_closure_planning": True,
    }:
        raise CanonError("visual closure authorization state is invalid")
    active_baseline = visual_contract.get("active_baseline")
    if not isinstance(active_baseline, dict):
        raise CanonError("visual closure active_baseline must be an object")
    if active_baseline.get("directions") != list(ACTIVE_VISUAL_DIRECTIONS):
        raise CanonError("visual closure active direction IDs are invalid")
    typography = active_baseline.get("typography")
    if not isinstance(typography, dict) or any(
        typography.get(key) != value
        for key, value in {
            "core_family": "San Francisco",
            "interface_roles": "SF Pro",
            "monospaced_digits": "San Francisco family only",
            "selected_study": "VC01-TYPE-STUDY-D — Semantic Cadence",
            "serif_active": False,
        }.items()
    ):
        raise CanonError("visual closure typography baseline is invalid")
    if typography.get("semantic_cadence") != [
        "identity",
        "current_truth",
        "consequence",
        "qualifying_state",
        "evidence",
        "action_or_return",
    ]:
        raise CanonError("visual closure semantic cadence is invalid")
    appearance = active_baseline.get("appearance")
    if (
        not isinstance(appearance, dict)
        or appearance.get("choices") != ["System", "Light", "Dark"]
        or appearance.get("selected_synthesis") != "Mineral Relief Continuum"
    ):
        raise CanonError("visual closure active appearance choices are invalid")
    accent = active_baseline.get("accent")
    if (
        not isinstance(accent, dict)
        or accent.get("default_family") != "restrained_violet_indigo"
        or accent.get("exact_values_status") != "deferred_calibration"
    ):
        raise CanonError("visual closure default accent is invalid")

    closure_packages = visual_contract.get("closure_packages")
    if not isinstance(closure_packages, dict):
        raise CanonError("visual closure package registry must be an object")
    if closure_packages.get("package_statuses") != WAVE_1_PACKAGE_STATUSES:
        raise CanonError("visual closure package statuses are invalid")
    contract_wave_1 = closure_packages.get("wave_1")
    if not isinstance(contract_wave_1, dict) or contract_wave_1 != {
        "human_record": "docs/canon/design/VC_WAVE_1_FOUNDATION_CLOSURE.md",
        "machine_record": wave_1_closure_path,
        "package_id": "AMB-VC-WAVE-1-FOUNDATION-CLOSURE",
        "selected_records": {
            "VC-01": "VC01-TYPE-STUDY-D — Semantic Cadence",
            "VC-02": "Mineral Relief Continuum",
            "VC-03": (
                "VC03-CROWN-D04 — Compact Semantic Stack / "
                "VC03-CROWN-D06 — Adaptive Semantic Passage"
            ),
            "VC-04": (
                "VC04-DOCK-D04 — Articulated Edge Tray / "
                "VC04-DOCK-D06 — Adaptive Navigation Passage"
            ),
            "VC-05": (
                "VC05-STATE-D04 — Semantic State Covenant / "
                "VC05-STATE-D06 — Explicit Stress Scaffold"
            ),
            "VC-06": (
                "VC06-GRAMMAR-D04 — Articulated Native Grammar / "
                "VC06-GRAMMAR-D01 — Native Minimal Substrate / "
                "VC06-GRAMMAR-D06 — Explicit Accessible Structure"
            ),
        },
        "status": "CLOSED",
    }:
        raise CanonError("visual closure Wave 1 registry is invalid")
    if closure_packages.get("wave_2_surfaces_and_journeys") != "OPEN":
        raise CanonError("visual closure Wave 2 status must remain open")
    if closure_packages.get("wave_3_stress_and_matched_baseline") != "OPEN":
        raise CanonError("visual closure Wave 3 status must remain open")

    if wave_1_closure.get("schema_version") != 1:
        raise CanonError("Wave 1 closure schema version is invalid")
    if wave_1_closure.get("package_id") != (
        "AMB-VC-WAVE-1-FOUNDATION-CLOSURE"
    ):
        raise CanonError("Wave 1 closure package ID is invalid")
    if wave_1_closure.get("status") != "CLOSED":
        raise CanonError("Wave 1 closure status must be closed")
    if wave_1_closure.get("active_direction_ids") != list(
        ACTIVE_VISUAL_DIRECTIONS
    ):
        raise CanonError("Wave 1 closure active direction IDs are invalid")
    if wave_1_closure.get("package_statuses") != WAVE_1_PACKAGE_STATUSES:
        raise CanonError("Wave 1 closure package statuses are invalid")
    if wave_1_closure.get("wave_status") != {
        "wave_1_shared_visual_foundation": "CLOSED",
        "wave_2_surfaces_and_journeys": "OPEN",
        "wave_3_stress_and_matched_baseline": "OPEN",
    }:
        raise CanonError("Wave 1 closure wave statuses are invalid")
    if wave_1_closure.get("authorization_state") != {
        "figma": False,
        "implementation": False,
        "swiftui": False,
    }:
        raise CanonError("Wave 1 closure authorization state is invalid")

    packages = wave_1_closure.get("packages")
    if not isinstance(packages, list):
        raise CanonError("Wave 1 closure packages must be a list")
    package_ids = [
        package.get("package_id")
        for package in packages
        if isinstance(package, dict)
    ]
    expected_package_ids = [f"VC-{number:02d}" for number in range(1, 7)]
    if package_ids != expected_package_ids or len(package_ids) != len(packages):
        raise CanonError("Wave 1 closure package identities are invalid")

    required_package_fields = {
        "applies_to_avf_ids",
        "architecture_dependencies",
        "authorization_state",
        "deferred_calibration",
        "locked_decisions",
        "package_id",
        "rejected_alternatives",
        "required_transformation",
        "selected_study_or_synthesis",
        "source_paths",
        "status",
        "validation_requirements",
    }
    active_direction_set = set(ACTIVE_VISUAL_DIRECTIONS)
    for package in packages:
        package_id = package["package_id"]
        if not required_package_fields.issubset(package):
            raise CanonError(
                f"Wave 1 closure package fields are incomplete: {package_id}"
            )
        if package.get("status") != "CLOSED":
            raise CanonError(
                f"Wave 1 closure package must be closed: {package_id}"
            )
        if package.get("authorization_state") != {
            "figma": False,
            "implementation": False,
            "swiftui": False,
        }:
            raise CanonError(
                f"Wave 1 closure package authorization is invalid: {package_id}"
            )
        applies_to = package.get("applies_to_avf_ids")
        if (
            not isinstance(applies_to, list)
            or not applies_to
            or len(applies_to) != len(set(applies_to))
            or set(applies_to) - active_direction_set
        ):
            raise CanonError(
                f"Wave 1 closure AVF mapping is invalid: {package_id}"
            )
        for field in (
            "architecture_dependencies",
            "deferred_calibration",
            "rejected_alternatives",
            "source_paths",
            "validation_requirements",
        ):
            value = package.get(field)
            if not isinstance(value, list) or not value:
                raise CanonError(
                    f"Wave 1 closure {field} is invalid: {package_id}"
                )
        if not isinstance(package.get("locked_decisions"), dict) or not package[
            "locked_decisions"
        ]:
            raise CanonError(
                f"Wave 1 closure locked decisions are invalid: {package_id}"
            )

        selection = package.get("selected_study_or_synthesis")
        expected_selection_id, expected_selection_name = (
            WAVE_1_SELECTED_RECORDS[package_id]
        )
        if (
            not isinstance(selection, dict)
            or selection.get("id") != expected_selection_id
            or selection.get("name") != expected_selection_name
        ):
            raise CanonError(
                f"Wave 1 closure selected record is invalid: {package_id}"
            )

        transformation = package.get("required_transformation")
        expected_transformation = WAVE_1_REQUIRED_TRANSFORMATIONS[package_id]
        if expected_transformation is None:
            if transformation is not None:
                raise CanonError(
                    f"Wave 1 closure transformation is invalid: {package_id}"
                )
        elif (
            not isinstance(transformation, dict)
            or (
                transformation.get("id"),
                transformation.get("name"),
            )
            != expected_transformation
        ):
            raise CanonError(
                f"Wave 1 closure transformation is invalid: {package_id}"
            )

        for source_path in package["source_paths"]:
            if not isinstance(source_path, str) or not _confined_path(
                root, Path(source_path)
            ).exists():
                raise CanonError(
                    f"Wave 1 closure source path is invalid: {package_id}"
                )

    vc_06 = packages[-1]
    if vc_06.get("native_substrate") != {
        "id": "VC06-GRAMMAR-D01",
        "name": "Native Minimal Substrate",
    }:
        raise CanonError("Wave 1 closure native substrate is invalid")
    interaction_target = vc_06["locked_decisions"].get(
        "interaction_target_points"
    )
    if interaction_target != {"height_minimum": 44, "width_minimum": 44}:
        raise CanonError("Wave 1 closure minimum interaction target is invalid")
    if not {
        "exact_typography_sizes",
        "exact_violet_indigo_values",
        "exact_radii",
        "exact_shadows",
        "exact_motion_durations_easing_distance_and_scale",
        "exact_component_tokens_apis_and_library_structure",
    }.issubset(set(wave_1_closure.get("deferred_calibration_register", []))):
        raise CanonError("Wave 1 closure deferred calibration is incomplete")

    required_reference_files = {
        "design/VC_WAVE_1_FOUNDATION_CLOSURE.md",
        "design/vc-wave-1-foundation-closure.json",
    }
    if not required_reference_files.issubset(
        set(compilation.manifest.reference_files)
    ):
        raise CanonError("Wave 1 closure is missing from the canon manifest")

    wave_1_markdown = _confined_path(
        root, Path("docs/canon/design/VC_WAVE_1_FOUNDATION_CLOSURE.md")
    ).read_text(encoding="utf-8")
    for required_text in (
        "Status: `CLOSED / ACTIVE_WAVE_1_CLOSURE_AUTHORITY`",
        "`VC-01` | `CLOSED`",
        "`VC-06` | `CLOSED`",
        "`VC-07` | `OPEN`",
        "`VC-13` | `OPEN`",
        "`VC-14` | `NOT_STARTED`",
        "Selected synthesis: `Mineral Relief Continuum`",
        "Selected primary study: `VC04-DOCK-D04 — Articulated Edge Tray`",
        "Selected primary study: `VC05-STATE-D04 — Semantic State Covenant`",
        "Selected primary study: `VC06-GRAMMAR-D04 — Articulated Native Grammar`",
        "Figma authorization: `false`",
        "SwiftUI approval: `false`",
        "Implementation authorization: `false`",
    ):
        if required_text not in wave_1_markdown:
            raise CanonError(
                f"Wave 1 closure Markdown is missing: {required_text}"
            )

    _validate_wave_2_closure(root, compilation.manifest, wave_2_closure)
    _validate_wave_3_closure(root, compilation.manifest, wave_3_closure)

    mappings = visual_contract.get("visual_requirement_mappings")
    if not isinstance(mappings, list) or not mappings:
        raise CanonError("visual closure requirement mappings must be a list")
    mapping_directions = [
        mapping.get("direction_id")
        for mapping in mappings
        if isinstance(mapping, dict)
    ]
    if mapping_directions != list(ACTIVE_VISUAL_DIRECTIONS):
        raise CanonError("visual closure mappings do not match active directions")
    for mapping in mappings:
        if not isinstance(mapping, dict):
            raise CanonError("visual closure has an invalid requirement mapping")
        if mapping.get("status") != "ACTIVE_RECONCILED_BASELINE":
            raise CanonError("active visual mapping has a non-active status")
        requirement_ids = mapping.get("requirement_ids")
        if not isinstance(requirement_ids, list) or not requirement_ids or not all(
            isinstance(value, str) for value in requirement_ids
        ):
            raise CanonError("visual closure mapping requirement_ids are invalid")
        inactive = sorted(set(requirement_ids) - active_requirement_ids)
        if inactive:
            raise CanonError(
                "visual authority references inactive requirement: "
                f"{inactive[0]}"
            )

    classifications = visual_contract.get("legacy_contract_classifications")
    if not isinstance(classifications, dict):
        raise CanonError("visual closure legacy classifications must be an object")
    visual_system = _confined_path(
        root, Path("docs/canon/design/VISUAL_SYSTEM_R1.md")
    ).read_text(encoding="utf-8")
    legacy_contract_ids = set(re.findall(r"\bVAD-R1-[A-Z0-9-]+", visual_system))
    if set(classifications) != legacy_contract_ids:
        raise CanonError("visual closure legacy classification coverage is incomplete")
    if not all(value in VISUAL_CLASSIFICATIONS for value in classifications.values()):
        raise CanonError("visual closure contains an invalid legacy classification")

    blueprint_markdown = _confined_path(
        root, Path("docs/canon/migration/UX_BLUEPRINT.md")
    ).read_text(encoding="utf-8")
    markdown_contracts = (
        (
            blueprint_markdown,
            f"- Canon revision: `{revision}`",
            "UX Blueprint Markdown canon revision",
        ),
        (
            blueprint_markdown,
            f"- Canon content SHA: `{digest}`",
            "UX Blueprint Markdown canon digest",
        ),
        (
            visual_system,
            f"- canon revision: `{revision}`;",
            "Visual System canon revision",
        ),
        (
            visual_system,
            f"- canon content SHA: `{digest}`;",
            "Visual System canon digest",
        ),
    )
    for text, expected, label in markdown_contracts:
        if expected not in text:
            raise CanonError(f"{label} does not match active canon")

    for state_model in state_models:
        state_model_id = state_model["blueprint_id"]
        for taxonomy in state_model["taxonomy"]:
            variant_ids = ", ".join(
                f"`{variant_id}`"
                for variant_id in taxonomy["variant_ids"]
            )
            expected_row = (
                f"| `{taxonomy['generic_kind']}` | "
                f"`{taxonomy['applicability']}` | {variant_ids} | "
                f"{taxonomy['rationale']} |"
            )
            if expected_row not in blueprint_markdown:
                raise CanonError(
                    "UX Blueprint Markdown/JSON taxonomy rows disagree: "
                    f"{state_model_id}/{taxonomy['generic_kind']}"
                )

    json_screen_ids = {
        item.get("blueprint_id")
        for item in blueprint.get("screens", [])
        if isinstance(item, dict)
    }
    markdown_screen_ids = set(
        re.findall(r"\bUX-SCREEN-[A-Z0-9-]+", blueprint_markdown)
    )
    if json_screen_ids != markdown_screen_ids:
        raise CanonError("UX Blueprint Markdown/JSON screen identities disagree")

    _validate_visual_system_provenance(root, visual_system)


def _canon_digest(root: Path, manifest: Manifest, documents: tuple[Document, ...]) -> str:
    """Digest the normative product canon without creating reference-file cycles.

    Reference artifacts bind this digest and are validated separately. Including
    their bytes here would make it impossible for those artifacts to embed the
    digest deterministically.
    """
    digest = hashlib.sha256()
    digest.update(b"ambitions-product-canon-v1\0")
    digest.update(manifest.source_bytes)
    digest.update(b"\0")
    for document in sorted(documents, key=lambda item: item.source_path):
        digest.update(document.source_path.encode("utf-8"))
        digest.update(b"\0")
        digest.update(document.source_bytes)
        digest.update(b"\0")
    return digest.hexdigest()


def compile_repository(root: Path) -> Compilation:
    root = root.resolve(strict=True)
    manifest = load_manifest(root)
    documents = tuple(
        sorted(
            (
                parse_document(root, path, manifest.canon_revision)
                for path in manifest.normative_files
            ),
            key=lambda document: (document.kind, document.spec_id),
        )
    )
    validate_documents(documents)
    validate_repository_bindings(root, documents)
    local_links = validate_local_links(root, manifest)
    json_count = validate_structured_references(root)
    screen_count, visual_contract_count = validate_design_direction(root)
    compilation = Compilation(
        root=root,
        manifest=manifest,
        documents=documents,
        canon_digest=_canon_digest(root, manifest, documents),
        local_link_count=local_links,
        json_count=json_count,
        ux_screen_count=screen_count,
        visual_contract_count=visual_contract_count,
    )
    validate_design_artifacts(compilation)
    return compilation


def _requirement_record(requirement: Requirement) -> dict[str, Any]:
    return {
        "concept": requirement.concept,
        "id": requirement.requirement_id,
        "line": requirement.line,
        "modality": requirement.modality,
        "scope": requirement.scope,
        "source_path": requirement.source_path,
        "source_owners": list(requirement.source_owners),
        "supersedes": list(requirement.supersedes),
        "title": requirement.title,
        "verification": list(requirement.verification),
    }


def render_index_json(compilation: Compilation) -> bytes:
    payload = {
        "canon_digest": compilation.canon_digest,
        "canon_revision": compilation.manifest.canon_revision,
        "documents": [
            {
                "depends_on": list(document.depends_on),
                "inherits": list(document.inherits),
                "kind": document.kind,
                "owner_domain": document.owner_domain,
                "owns_concepts": list(document.owns_concepts),
                "path": document.source_path,
                "requirements": [
                    _requirement_record(requirement)
                    for requirement in document.requirements
                ],
                "source_owners": list(document.source_owners),
                "spec_id": document.spec_id,
                "title": document.title,
            }
            for document in sorted(compilation.documents, key=lambda item: item.spec_id)
        ],
        "schema_version": 1,
    }
    return (json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n").encode(
        "utf-8"
    )


def render_graph_json(compilation: Compilation) -> bytes:
    dependents: dict[str, list[str]] = {
        document.spec_id: [] for document in compilation.documents
    }
    inherited_by: dict[str, list[str]] = {
        requirement.requirement_id: [] for requirement in compilation.requirements
    }
    for document in compilation.documents:
        for dependency in document.depends_on:
            dependents[dependency].append(document.spec_id)
        for requirement_id in document.inherits:
            inherited_by[requirement_id].append(document.spec_id)
    payload = {
        "canon_digest": compilation.canon_digest,
        "concepts": {
            requirement.concept: {
                "owner_spec_id": requirement.owner_spec_id,
                "requirement_id": requirement.requirement_id,
            }
            for requirement in sorted(
                compilation.requirements, key=lambda item: item.concept
            )
        },
        "requirements": {
            requirement.requirement_id: {
                "inherited_by": sorted(inherited_by[requirement.requirement_id]),
                "owner_spec_id": requirement.owner_spec_id,
                "source_path": requirement.source_path,
            }
            for requirement in sorted(
                compilation.requirements, key=lambda item: item.requirement_id
            )
        },
        "schema_version": 1,
        "specifications": {
            document.spec_id: {
                "dependencies": list(document.depends_on),
                "dependents": sorted(dependents[document.spec_id]),
                "inherits": list(document.inherits),
                "source_path": document.source_path,
            }
            for document in sorted(compilation.documents, key=lambda item: item.spec_id)
        },
    }
    return (json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n").encode(
        "utf-8"
    )


def render_index_markdown(compilation: Compilation) -> bytes:
    lines = [
        "# Ambitions Canon Index",
        "",
        "> Generated from normative product canon. Do not edit by hand.",
        "",
        f"- Canon revision: `{compilation.manifest.canon_revision}`",
        f"- Canon digest: `{compilation.canon_digest}`",
        f"- Documents: `{len(compilation.documents)}`",
        f"- Requirements: `{len(compilation.requirements)}`",
        "",
    ]
    kind_order = (
        "constitution",
        "app",
        "surface",
        "global",
        "object",
        "system",
        "journey",
        "standard",
    )
    by_kind: dict[str, list[Document]] = {}
    for document in compilation.documents:
        by_kind.setdefault(document.kind, []).append(document)
    for kind in (*kind_order, *sorted(set(by_kind) - set(kind_order))):
        documents = by_kind.get(kind)
        if not documents:
            continue
        lines.extend(
            [
                f"## {kind.replace('-', ' ').title()}",
                "",
                "| Specification | Title | Requirements | Concepts | Source |",
                "| --- | --- | ---: | ---: | --- |",
            ]
        )
        for document in sorted(documents, key=lambda item: item.spec_id):
            lines.append(
                f"| `{document.spec_id}` | {document.title} | "
                f"{len(document.requirements)} | {len(document.owns_concepts)} | "
                f"[{document.source_path}](../{document.source_path}) |"
            )
        lines.append("")
    return ("\n".join(lines).rstrip() + "\n").encode("utf-8")


def render_codex_start(compilation: Compilation) -> bytes:
    lines = [
        "# Codex Start Here",
        "",
        "> Generated navigation for Ambitions product canon. Do not edit by hand.",
        "",
        f"- Canon revision: `{compilation.manifest.canon_revision}`",
        f"- Documents: `{len(compilation.documents)}`",
        f"- Requirements: `{len(compilation.requirements)}`",
        "",
        "Canon defines product and engineering direction. It does not authorize",
        "repository work and creates no task, pack, signature, approval, attestation,",
        "or merge ceremony.",
        "",
        "## Fast route",
        "",
        "1. Read [the Constitution](../CONSTITUTION.md) for product mission, IA,",
        "   object/runtime invariants, privacy, accessibility, and native-platform law.",
        "2. Use the compiler query command to locate the exact owning specification,",
        "   requirement, concept, dependencies, and source-owner hints.",
        "3. Read that owning specification plus current source and tests; canon does not",
        "   establish current implementation state.",
        "4. Implement the smallest coherent change and run changed-scope engineering",
        "   validation.",
        "",
        "```sh",
        "python3 scripts/ambitions-canon.py query --id LAW-LOCAL-AUTHORITY-001",
        "python3 scripts/ambitions-canon.py query --concept surface.today.first-viewport",
        "python3 scripts/ambitions-canon.py query --spec SURFACE-TODAY",
        "python3 scripts/ambitions-canon.py query \"migration replay integrity\"",
        "```",
        "",
        "## Product and design entry points",
        "",
        "- [Full canon index](INDEX.md)",
        "- [Canon README and reading order](../README.md)",
        "- [Visual System R1](../design/VISUAL_SYSTEM_R1.md)",
        "- [Wave 1 Foundation Closure](../design/VC_WAVE_1_FOUNDATION_CLOSURE.md)",
        "- [Wave 2 Surface and Journey Closure]"
        "(../design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md)",
        "- [Wave 3 Accessibility and Content Stress Closure]"
        "(../design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md)",
        "- [Canonical UX Blueprint](../migration/UX_BLUEPRINT.md)",
        "- [Object Boundary Matrix](object-boundary-matrix.md)",
        "- [Requirement graph](requirement-graph.json)",
        "- [Machine index](canon-index.json)",
        "",
        "## Compiler maintenance",
        "",
        "```sh",
        "python3 scripts/ambitions-canon.py build",
        "python3 scripts/ambitions-canon.py check",
        "```",
        "",
        "`build` writes deterministic navigation outputs. `check` detects concrete",
        "parse, identity, dependency, concept, link, structured-data, and generated",
        "drift defects. Neither command performs authorization or process enforcement.",
    ]
    return ("\n".join(lines).rstrip() + "\n").encode("utf-8")


def _first_paragraph(body: str) -> str:
    visible = body.split("<!--", 1)[0].strip()
    paragraph = visible.split("\n\n", 1)[0]
    return " ".join(paragraph.split())


def render_object_boundary(compilation: Compilation) -> bytes:
    boundary_documents = {
        document.title: document
        for document in compilation.documents
        if document.object_boundary is not None
    }
    missing = [title for title in OBJECT_ORDER if title not in boundary_documents]
    if missing:
        raise CanonError("object boundary projection is missing: " + ", ".join(missing))
    requirement_by_id = {
        requirement.requirement_id: requirement for requirement in compilation.requirements
    }
    lines = [
        "<!-- markdownlint-disable MD013 -->",
        "",
        "# Object Boundary Matrix",
        "",
        "> Generated from normative object specifications. Do not edit by hand.",
        "",
        f"- Canon revision: `{compilation.manifest.canon_revision}`",
        f"- Canon digest: `{compilation.canon_digest}`",
        "",
        "| Capability | " + " | ".join(OBJECT_ORDER) + " |",
        "| --- | " + " | ".join("---" for _ in OBJECT_ORDER) + " |",
    ]
    for key, label in OBJECT_CAPABILITIES:
        values: list[str] = []
        for title in OBJECT_ORDER:
            boundary = boundary_documents[title].object_boundary or {}
            value = boundary.get(key)
            if not isinstance(value, str):
                raise CanonError(f"{title} object_boundary is missing {key}")
            values.append(value.replace("|", "\\|"))
        lines.append(f"| {label} | " + " | ".join(values) + " |")

    first_boundary = boundary_documents[OBJECT_ORDER[0]].object_boundary or {}
    laws = first_boundary.get("laws")
    if not isinstance(laws, dict):
        raise CanonError("object_boundary laws table is missing")
    lines.extend(["", "## Owning boundary laws", ""])
    for _, requirement_id in sorted(laws.items()):
        requirement = requirement_by_id.get(requirement_id)
        if requirement is None:
            raise CanonError(f"object boundary references unknown law: {requirement_id}")
        lines.append(
            f"- **{requirement.title}** (`{requirement.requirement_id}`): "
            f"{_first_paragraph(requirement.body)}"
        )
    return ("\n".join(lines).rstrip() + "\n").encode("utf-8")


def render_requirement_traceability(compilation: Compilation) -> bytes:
    """Render structural product traceability without manufacturing test proof."""
    dispositions_path = _confined_path(
        compilation.root,
        Path(
            "docs/canon/migration/"
            "ux-blueprint-requirement-dispositions.json"
        ),
    )
    disposition_document = json.loads(
        dispositions_path.read_text(encoding="utf-8")
    )
    blueprint_ids_by_requirement = {
        item["requirement_id"]: item["blueprint_ids"]
        for item in disposition_document["dispositions"]
    }
    payload = {
        "canon_digest": compilation.canon_digest,
        "canon_revision": compilation.manifest.canon_revision,
        "executable_resolution_policy": {
            "binding_source": "executed test result manifests",
            "required_phase": 8,
            "structural_traceability_is_runtime_proof": False,
        },
        "requirements": [
            {
                "blueprint_ids": blueprint_ids_by_requirement[
                    requirement.requirement_id
                ],
                "concept": requirement.concept,
                "executable_bindings": [],
                "executable_resolution": "not_evaluated_by_canon_compiler",
                "intended_outcome": _first_paragraph(requirement.body),
                "modality": requirement.modality,
                "owner_spec_id": requirement.owner_spec_id,
                "requirement_id": requirement.requirement_id,
                "scope": requirement.scope,
                "source_owners": list(requirement.source_owners),
                "source_path": requirement.source_path,
                "verification_declarations": list(requirement.verification),
            }
            for requirement in sorted(
                compilation.requirements,
                key=lambda item: item.requirement_id,
            )
        ],
        "schema_version": 1,
    }
    return (
        json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False)
        + "\n"
    ).encode("utf-8")


def render_visual_authority_manifest(compilation: Compilation) -> bytes:
    """Render the active visual authority from its source-owned VC contract."""
    contract, wave_1_closure, wave_2_closure, wave_3_closure = (
        load_visual_closure_records(compilation.root)
    )
    _validate_wave_2_closure(
        compilation.root,
        compilation.manifest,
        wave_2_closure,
    )
    _validate_wave_3_closure(
        compilation.root,
        compilation.manifest,
        wave_3_closure,
    )
    source_bytes = tuple(
        _confined_path(compilation.root, relative_path).read_bytes()
        for relative_path in VISUAL_CLOSURE_MACHINE_PATHS
    )

    def project_record(index: int, record: dict[str, Any]) -> dict[str, Any]:
        return {
            **record,
            "source_contract": VISUAL_CLOSURE_MACHINE_PATHS[index].as_posix(),
            "source_input_sha": hashlib.sha256(source_bytes[index]).hexdigest(),
        }

    wave_1_projection = project_record(1, wave_1_closure)
    wave_2_projection = project_record(2, wave_2_closure)
    wave_3_selected = wave_3_closure["package"]["selected_closure"]
    wave_3_projection = {
        **project_record(3, wave_3_closure),
        "human_record": wave_3_closure["human_peer"],
        "machine_record": VISUAL_CLOSURE_MACHINE_PATHS[3].as_posix(),
        "selected_record": (
            f"{wave_3_selected['id']} — {wave_3_selected['name']}"
        ),
        "status": "ACCESSIBILITY_STRESS_CLOSED_VC14_NOT_STARTED",
    }
    payload = {
        "active_baseline": {
            **contract["active_baseline"],
            "wave_2_summaries": _wave_2_surface_summaries(wave_2_closure),
            "wave_3_accessibility_stress": _wave_3_accessibility_stress(
                wave_3_closure
            ),
        },
        "authorities": [
            {
                "authority_role": "active_reconciled_direction",
                "authority_status": "provisional",
                "canon_revision": compilation.manifest.canon_revision,
                "classification": mapping["status"],
                "implementation_status": (
                    "target contract only; runtime and rendered proof required"
                ),
                "requirement_ids": mapping["requirement_ids"],
                "source": VISUAL_CLOSURE_MACHINE_PATHS[0].as_posix(),
                "visual_authority_id": mapping["direction_id"],
            }
            for mapping in contract["visual_requirement_mappings"]
        ],
        "authority_state": contract["authorization"],
        "canon_content_sha": compilation.canon_digest,
        "canon_revision": compilation.manifest.canon_revision,
        "classification_vocabulary": contract["classification_vocabulary"],
        "closure_packages": {
            "package_statuses": EXPECTED_EFFECTIVE_PACKAGE_STATUSES,
            "wave_1": contract["closure_packages"]["wave_1"],
            "wave_1_record": wave_1_projection,
            "wave_2": wave_2_projection,
            "wave_2_surfaces_and_journeys": "CLOSED",
            "wave_3": wave_3_projection,
            "wave_3_stress_and_matched_baseline": "OPEN_PENDING_VC_14",
        },
        "compiler_version": "0.5.0",
        "contract_id": contract["contract_id"],
        "historical_figma_references": contract["historical_figma_references"],
        "legacy_contract_classifications": contract[
            "legacy_contract_classifications"
        ],
        "schema_version": 3,
        "source_contract": VISUAL_CLOSURE_MACHINE_PATHS[0].as_posix(),
        "supersessions": contract["supersessions"],
        "traceability_input_sha": hashlib.sha256(source_bytes[0]).hexdigest(),
        "unsupported_visual_behaviors": contract[
            "unsupported_visual_behaviors"
        ],
        "visual_validation_decisions": contract[
            "visual_validation_decisions"
        ],
        "wave_1_foundation_closure": wave_1_projection,
        "wave_2_surface_journey_closure": wave_2_projection,
        "wave_3_accessibility_stress_closure": wave_3_projection,
    }
    return (
        json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False)
        + "\n"
    ).encode("utf-8")


def render_outputs(compilation: Compilation) -> dict[str, bytes]:
    return {
        "generated/CODEX_START_HERE.md": render_codex_start(compilation),
        "generated/INDEX.md": render_index_markdown(compilation),
        "generated/canon-index.json": render_index_json(compilation),
        "generated/object-boundary-matrix.md": render_object_boundary(compilation),
        "generated/requirement-graph.json": render_graph_json(compilation),
        "generated/requirement-traceability.json": (
            render_requirement_traceability(compilation)
        ),
        "generated/visual-authority-manifest.json": (
            render_visual_authority_manifest(compilation)
        ),
    }


def write_outputs(compilation: Compilation, outputs: dict[str, bytes]) -> None:
    canon_root = _confined_path(compilation.root, CANON_ROOT_PATH)
    for relative_path in GENERATED_PATHS:
        destination = _confined_path(
            compilation.root, Path(relative_path), base=canon_root
        )
        destination.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.NamedTemporaryFile(
            dir=destination.parent, prefix=f".{destination.name}.", delete=False
        ) as handle:
            handle.write(outputs[relative_path])
            temporary = Path(handle.name)
        os.replace(temporary, destination)


def output_drift(compilation: Compilation, outputs: dict[str, bytes]) -> tuple[str, ...]:
    canon_root = _confined_path(compilation.root, CANON_ROOT_PATH)
    drift: list[str] = []
    for relative_path in GENERATED_PATHS:
        destination = _confined_path(
            compilation.root, Path(relative_path), base=canon_root
        )
        try:
            current = destination.read_bytes()
        except OSError:
            drift.append(relative_path)
            continue
        if current != outputs[relative_path]:
            drift.append(relative_path)
    return tuple(drift)


def query(
    compilation: Compilation,
    term: str,
    *,
    mode: str = "any",
) -> tuple[Document | Requirement, ...]:
    normalized = term.casefold()
    if mode == "spec":
        return tuple(
            document
            for document in compilation.documents
            if document.spec_id.casefold() == normalized
        )
    if mode == "id":
        return tuple(
            requirement
            for requirement in compilation.requirements
            if requirement.requirement_id.casefold() == normalized
        )
    if mode == "concept":
        return tuple(
            requirement
            for requirement in compilation.requirements
            if requirement.concept.casefold() == normalized
        )

    exact: list[Document | Requirement] = []
    for document in compilation.documents:
        if document.spec_id.casefold() == normalized:
            exact.append(document)
    for requirement in compilation.requirements:
        if normalized in {
            requirement.requirement_id.casefold(),
            requirement.concept.casefold(),
        }:
            exact.append(requirement)
    if exact:
        return tuple(exact)

    tokens = tuple(token for token in re.split(r"\s+", normalized) if token)
    results: list[Document | Requirement] = []
    for requirement in compilation.requirements:
        haystack = " ".join(
            (
                requirement.requirement_id,
                requirement.title,
                requirement.concept,
                requirement.scope,
                requirement.body,
            )
        ).casefold()
        if all(token in haystack for token in tokens):
            results.append(requirement)
    for document in compilation.documents:
        haystack = " ".join(
            (document.spec_id, document.title, document.kind, *document.owns_concepts)
        ).casefold()
        if all(token in haystack for token in tokens):
            results.append(document)
    return tuple(results)


def query_record(item: Document | Requirement) -> dict[str, Any]:
    if isinstance(item, Document):
        return {
            "depends_on": list(item.depends_on),
            "inherits": list(item.inherits),
            "kind": "document",
            "owns_concepts": list(item.owns_concepts),
            "path": item.source_path,
            "requirements": [req.requirement_id for req in item.requirements],
            "source_owners": list(item.source_owners),
            "spec_id": item.spec_id,
            "title": item.title,
        }
    return {
        "body": item.body,
        "concept": item.concept,
        "id": item.requirement_id,
        "kind": "requirement",
        "line": item.line,
        "modality": item.modality,
        "owner_spec_id": item.owner_spec_id,
        "path": item.source_path,
        "scope": item.scope,
        "source_owners": list(item.source_owners),
        "supersedes": list(item.supersedes),
        "title": item.title,
        "verification": list(item.verification),
    }
