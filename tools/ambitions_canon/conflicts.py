"""Deterministic conceptual-conflict candidates and owner decision dockets."""

from __future__ import annotations

import hashlib
import json
import os
import re
import tomllib
from collections import Counter, defaultdict
from collections.abc import Iterable, Mapping, Sequence
from dataclasses import dataclass
from enum import StrEnum
from pathlib import Path

from tools.ambitions_canon.build import (
    _descriptor_identity,
    _entry_kind_and_identity,
    _open_directory_at,
    _open_directory_absolute_nofollow,
    _read_file_at,
    _tree_files_descriptor,
)
from tools.ambitions_canon.model import AtomicClaim, CanonError, Modality


IMPACT_DIMENSIONS = (
    "repo",
    "linear",
    "figma",
    "production_source",
    "tests",
    "proof",
    "privacy",
    "accessibility",
    "migration_rollback",
)
ALLOWED_STATUSES = frozenset({"unresolved", "resolved"})
ALLOWED_TARGET_REQUIREMENT_STATUSES = frozenset({"planned_uncreated", "created"})
ALLOWED_SEVERITIES = frozenset(
    {"P0_BLOCKER", "P1_REQUIRED", "P2_IMPROVEMENT", "INFORMATIONAL"}
)
ALLOWED_PRIORITIES = frozenset({"P0", "P1", "P2", "INFORMATIONAL"})
_IDENTIFIER = re.compile(r"^[A-Z][A-Z0-9]*(?:-[A-Z0-9]+)+$")
_CONCEPT = re.compile(r"^[a-z0-9]+(?:[._-][a-z0-9]+)*$")
_SHA256 = re.compile(r"^[0-9a-f]{64}$")
_FRONT_MATTER = re.compile(r"\A\+\+\+\n(.*?)\n\+\+\+\n", re.DOTALL)
_GLOBAL_SCOPES = frozenset({"*", "all", "global", "everywhere"})
_STRUCTURED_SCOPE = re.compile(r"^[a-z0-9]+(?:\.[a-z0-9_-]+)*$")
_DISJOINT_PREFIX = "conflict-disjoint:"


class ConflictResolution(StrEnum):
    KEEP_A = "keep_a"
    KEEP_B = "keep_b"
    COMPOSE = "compose"
    REJECT_BOTH = "reject_both"


class ConflictRecommendation(StrEnum):
    KEEP_A = "keep_a"
    KEEP_B = "keep_b"
    COMPOSE = "compose"
    REJECT_BOTH = "reject_both"

    @property
    def label(self) -> str:
        return {
            self.KEEP_A: "Keep A; supersede B",
            self.KEEP_B: "Keep B; supersede A",
            self.COMPOSE: "Compose A and B with explicit scopes",
            self.REJECT_BOTH: "Reject both and introduce a stronger third law",
        }[self]


@dataclass(frozen=True, slots=True)
class ConflictClaim:
    claim_id: str
    source_id: str
    source_location: str
    concept: str
    scope: str
    modality: Modality
    normalized_value: str
    evidence_sha256: str
    owner_approval: str | None = None
    owner_evidence_text_sha256: str | None = None
    owner_evidence_rationale_sha256: str | None = None

    @classmethod
    def from_atomic(cls, claim: AtomicClaim) -> "ConflictClaim":
        _validate_atomic_claim(claim)
        return cls(
            claim_id=claim.claim_id,
            source_id=claim.source_id,
            source_location=claim.source_location,
            concept=claim.concept,
            scope=_normalized_text(claim.scope),
            modality=claim.modality,
            normalized_value=_normalized_text(claim.value),
            evidence_sha256=hashlib.sha256(
                claim.original_text.encode("utf-8")
            ).hexdigest(),
            owner_approval=claim.owner_approval,
            owner_evidence_text_sha256=_optional_text_sha256(
                claim.owner_evidence_text
            ),
            owner_evidence_rationale_sha256=_optional_text_sha256(
                claim.owner_evidence_rationale
            ),
        )

    def __post_init__(self) -> None:
        for name in (
            "claim_id",
            "source_id",
            "source_location",
            "concept",
            "scope",
            "normalized_value",
        ):
            _required_string(getattr(self, name), name)
        if _IDENTIFIER.fullmatch(self.claim_id) is None:
            raise _error("CONFLICT_CLAIM_INVALID", "claim_id is invalid")
        if _CONCEPT.fullmatch(self.concept) is None:
            raise _error("CONFLICT_CLAIM_INVALID", "concept is invalid")
        if _SHA256.fullmatch(self.evidence_sha256) is None:
            raise _error(
                "CONFLICT_EVIDENCE_INVALID",
                "evidence_sha256 must be a lowercase SHA-256",
            )
        if not isinstance(self.modality, Modality):
            raise _error("CONFLICT_CLAIM_INVALID", "modality is invalid")
        if self.owner_approval is not None:
            _required_string(self.owner_approval, "owner_approval")
        for name in (
            "owner_evidence_text_sha256",
            "owner_evidence_rationale_sha256",
        ):
            value = getattr(self, name)
            if value is not None and _SHA256.fullmatch(value) is None:
                raise _error(
                    "CONFLICT_EVIDENCE_INVALID",
                    f"{name} must be a lowercase SHA-256 when present",
                )


@dataclass(frozen=True, slots=True)
class ConflictCandidate:
    candidate_id: str
    concept: str
    scopes: tuple[str, ...]
    severity: str
    claims: tuple[ConflictClaim, ...]
    recommendation: ConflictRecommendation | None = None

    def __post_init__(self) -> None:
        object.__setattr__(self, "scopes", tuple(self.scopes))
        object.__setattr__(self, "claims", tuple(self.claims))


@dataclass(frozen=True, slots=True)
class ConflictDocket:
    conflict_id: str
    status: str
    severity: str
    priority: str
    concepts: tuple[str, ...]
    scopes: tuple[str, ...]
    claims: tuple[ConflictClaim, ...]
    user_consequences: str
    compatibility_analysis: str
    recommendation: ConflictRecommendation
    recommendation_rationale: str
    stronger_composition: str
    proposed_canonical_law: str
    impacts: tuple[tuple[str, str], ...]
    artifacts_to_supersede: tuple[str, ...]
    target_requirement_status: str
    target_requirement_id: str | None
    owner_decision: str | None
    allowed_resolutions: tuple[str, ...]
    affected_task_scopes: tuple[str, ...]
    nonclaims: str
    claim_ceiling: str

    def __post_init__(self) -> None:
        for name in (
            "concepts",
            "scopes",
            "claims",
            "impacts",
            "artifacts_to_supersede",
            "allowed_resolutions",
            "affected_task_scopes",
        ):
            object.__setattr__(self, name, tuple(getattr(self, name)))
        _validate_docket(self)


@dataclass(frozen=True, slots=True)
class TrackedConflictClaim:
    claim_id: str
    source_id: str
    source_location: str
    concept: str
    disposition: str
    owner_approval_sha256: str | None
    owner_evidence_text_sha256: str | None
    owner_evidence_rationale_sha256: str | None


@dataclass(frozen=True, slots=True)
class ConflictRepositorySnapshot:
    source_catalog_bytes: bytes
    claim_dispositions_bytes: bytes
    baseline_bytes: bytes
    claim_dispositions_sha256: str


def conflict_candidates(
    claims: Iterable[AtomicClaim],
) -> tuple[ConflictCandidate, ...]:
    """Detect exact normalized semantic collisions without selecting a winner."""

    unique: dict[tuple[str, str, str], AtomicClaim] = {}
    for item in claims:
        _validate_atomic_claim(item)
        key = (item.claim_id, item.source_id, item.source_location)
        previous = unique.get(key)
        if previous is not None and previous != item:
            raise _error(
                "CONFLICT_CLAIM_DUPLICATE",
                f"claim provenance is duplicated with different semantics: {item.claim_id}",
            )
        unique[key] = item

    by_concept: dict[str, list[AtomicClaim]] = defaultdict(list)
    for item in unique.values():
        by_concept[item.concept].append(item)

    candidates: list[ConflictCandidate] = []
    for concept in sorted(by_concept):
        ordered = tuple(
            sorted(
                by_concept[concept],
                key=lambda item: (
                    item.claim_id,
                    item.source_id,
                    item.source_location,
                ),
            )
        )
        conflicting: set[AtomicClaim] = set()
        p0 = False
        for index, left in enumerate(ordered):
            for right in ordered[index + 1 :]:
                if not _claims_overlap(left, right):
                    continue
                same_value = _normalized_text(left.value) == _normalized_text(
                    right.value
                )
                modalities = {
                    left.modality,
                    right.modality,
                }
                modalities_conflict = modalities in (
                    {Modality.MUST, Modality.MUST_NOT},
                    {Modality.SHOULD, Modality.SHOULD_NOT},
                )
                if same_value and not modalities_conflict:
                    continue
                conflicting.update((left, right))
                p0 = p0 or modalities == {Modality.MUST, Modality.MUST_NOT}
        if not conflicting:
            continue
        rendered_claims = tuple(
            ConflictClaim.from_atomic(item)
            for item in sorted(
                conflicting,
                key=lambda item: (
                    item.claim_id,
                    item.source_id,
                    item.source_location,
                ),
            )
        )
        digest = hashlib.sha256(
            "\n".join(item.claim_id for item in rendered_claims).encode("utf-8")
        ).hexdigest()[:12].upper()
        candidates.append(
            ConflictCandidate(
                candidate_id=f"CONFLICT-CANDIDATE-{digest}",
                concept=concept,
                scopes=tuple(sorted({item.scope for item in rendered_claims})),
                severity="P0_BLOCKER" if p0 else "P1_REQUIRED",
                claims=rendered_claims,
                recommendation=None,
            )
        )
    return tuple(candidates)


def render_conflict_docket(docket: ConflictDocket) -> str:
    """Render one canonical, shadow-only owner docket with TOML front matter."""

    _validate_docket(docket)
    lines = [
        "+++",
        "schema_version = 1",
        f"conflict_id = {_toml_string(docket.conflict_id)}",
        f"status = {_toml_string(docket.status)}",
        f"severity = {_toml_string(docket.severity)}",
        f"priority = {_toml_string(docket.priority)}",
        f"concepts = {_toml_strings(docket.concepts)}",
        f"scopes = {_toml_strings(docket.scopes)}",
        f"recommendation = {_toml_string(docket.recommendation.value)}",
        f"recommendation_rationale = {_toml_string(docket.recommendation_rationale)}",
        f"stronger_composition = {_toml_string(docket.stronger_composition)}",
        f"proposed_canonical_law = {_toml_string(docket.proposed_canonical_law)}",
        f"artifacts_to_supersede = {_toml_strings(docket.artifacts_to_supersede)}",
        f"target_requirement_status = {_toml_string(docket.target_requirement_status)}",
        f"target_requirement_id = {_toml_string(docket.target_requirement_id or '')}",
        f"owner_decision = {_toml_string(docket.owner_decision or '')}",
        f"allowed_resolutions = {_toml_strings(docket.allowed_resolutions)}",
        f"affected_task_scopes = {_toml_strings(docket.affected_task_scopes)}",
        f"nonclaims = {_toml_string(docket.nonclaims)}",
        f"claim_ceiling = {_toml_string(docket.claim_ceiling)}",
    ]
    for item in docket.claims:
        lines.extend(
            [
                "",
                "[[claims]]",
                f"claim_id = {_toml_string(item.claim_id)}",
                f"source_id = {_toml_string(item.source_id)}",
                f"source_location = {_toml_string(item.source_location)}",
                f"concept = {_toml_string(item.concept)}",
                f"scope = {_toml_string(item.scope)}",
                f"modality = {_toml_string(item.modality.value)}",
                f"normalized_value = {_toml_string(item.normalized_value)}",
                f"evidence_sha256 = {_toml_string(item.evidence_sha256)}",
                f"owner_approval = {_toml_string(item.owner_approval or '')}",
                f"owner_evidence_text_sha256 = {_toml_string(item.owner_evidence_text_sha256 or '')}",
                f"owner_evidence_rationale_sha256 = {_toml_string(item.owner_evidence_rationale_sha256 or '')}",
            ]
        )
    for dimension, analysis in docket.impacts:
        lines.extend(
            [
                "",
                "[[impacts]]",
                f"dimension = {_toml_string(dimension)}",
                f"analysis = {_toml_string(analysis)}",
            ]
        )
    lines.extend(
        [
            "+++",
            "",
            f"# {docket.conflict_id}",
            "",
            (
                "> Shadow migration decision docket. It is non-authoritative and remains "
                "unresolved until the owner records a decision."
                if docket.status == "unresolved"
                else "> Shadow migration decision docket. Its recorded decision is not active law until integrated with its target requirement and supersession entry."
            ),
            "",
            "## Competing conceptual claims",
            "",
            "| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |",
            "| --- | --- | --- | --- | --- | --- |",
        ]
    )
    lines.extend(
        "| `{}` | {} | `{}` | {} | `{}:{}` | `{}` |".format(
            _cell(item.claim_id),
            _cell(item.normalized_value),
            _cell(item.modality.value),
            _cell(item.scope),
            _cell(item.source_id),
            _cell(item.source_location),
            item.evidence_sha256,
        )
        for item in docket.claims
    )
    impact_labels = {
        "repo": "repo",
        "linear": "Linear",
        "figma": "Figma",
        "production_source": "production source",
        "tests": "tests",
        "proof": "proof",
        "privacy": "privacy",
        "accessibility": "accessibility",
        "migration_rollback": "migration / rollback",
    }
    lines.extend(
        [
            "",
            "## User consequences",
            "",
            docket.user_consequences,
            "",
            "## Compatibility analysis",
            "",
            docket.compatibility_analysis,
            "",
            "## Recommendation",
            "",
            f"**{docket.recommendation.label}.** {docket.recommendation_rationale}",
            "",
            "This is a recommendation for Gate A, not an owner decision.",
            "",
            "## Stronger composition option",
            "",
            docket.stronger_composition,
            "",
            "## Proposed canonical law",
            "",
            docket.proposed_canonical_law,
            "",
            "## Impact analysis",
            "",
            "| Dimension | Impact |",
            "| --- | --- |",
        ]
    )
    lines.extend(
        f"| {impact_labels[dimension]} | {_cell(analysis)} |"
        for dimension, analysis in docket.impacts
    )
    lines.extend(
        [
            "",
            "## Artifacts to supersede",
            "",
            *(f"- `{item}`" for item in docket.artifacts_to_supersede),
            "",
            "## Target requirement",
            "",
            f"- Status: `{docket.target_requirement_status}`",
            (
                f"- Requirement ID: `{docket.target_requirement_id}`"
                if docket.target_requirement_id is not None
                else "- Requirement ID: not created; it becomes mandatory only after owner resolution."
            ),
            "",
            "## Owner decision",
            "",
            f"- Status: {docket.status}",
            (
                f"- Decision: `{docket.owner_decision}`"
                if docket.owner_decision is not None
                else "- Decision: blank"
            ),
            "- Allowed values: `keep_a`, `keep_b`, `compose`, `reject_both`",
            "",
            "## Explicit nonclaims and claim ceiling",
            "",
            f"- Nonclaims: {docket.nonclaims}",
            f"- Claim ceiling: {docket.claim_ceiling}",
        ]
    )
    return "\n".join(lines).rstrip() + "\n"


def load_conflict_dockets(root: Path) -> tuple[ConflictDocket, ...]:
    """Read the complete open-docket tree without following links."""

    canon_root = Path(root) / "docs/canon"
    open_root = canon_root / "decisions/open"
    descriptors: list[int] = []
    try:
        with _open_directory_absolute_nofollow(canon_root) as canon_descriptor:
            current = os.dup(canon_descriptor)
            descriptors.append(current)
            for component in ("decisions", "open"):
                kind, identity = _entry_kind_and_identity(current, component)
                if kind is None:
                    return ()
                if kind != "directory" or identity is None:
                    raise _error(
                        "CONFLICT_DOCKET_PATH_INVALID",
                        "open conflict docket path must contain only real directories",
                        open_root,
                    )
                child = _open_directory_at(current, component)
                descriptors.append(child)
                if _descriptor_identity(child) != identity:
                    raise _error(
                        "CONFLICT_DOCKET_PATH_INVALID",
                        "open conflict docket directory identity changed during read",
                        open_root,
                    )
                current = child
            paths = _tree_files_descriptor(current)
            if any(path.suffix != ".md" or len(path.parts) != 1 for path in paths):
                raise _error(
                    "CONFLICT_DOCKET_PATH_INVALID",
                    "open conflict dockets must be top-level Markdown files",
                    open_root,
                )
            parsed: list[ConflictDocket] = []
            for path in paths:
                docket = _parse_conflict_docket(
                    _read_file_at(current, path),
                    # The descriptor remains pinned through the complete parse.
                    open_root / path,
                )
                if path != docket_filename(docket):
                    raise _error(
                        "CONFLICT_DOCKET_PATH_INVALID",
                        "conflict docket filename must derive from its stable ID",
                        open_root / path,
                    )
                parsed.append(docket)
            loaded = tuple(parsed)
    except CanonError:
        raise
    except OSError as exc:
        raise _error(
            "CONFLICT_DOCKET_PATH_INVALID",
            "open conflict docket tree is missing, unsafe, or unreadable",
            open_root,
        ) from exc
    finally:
        for descriptor in reversed(descriptors):
            os.close(descriptor)
    identifiers = tuple(item.conflict_id for item in loaded)
    if len(identifiers) != len(set(identifiers)):
        raise _error(
            "CONFLICT_DOCKET_DUPLICATE",
            "conflict IDs must be globally unique",
            open_root,
        )
    return tuple(sorted(loaded, key=lambda item: item.conflict_id))


def docket_filename(docket: ConflictDocket) -> Path:
    """Return the only accepted stable filename for a conflict docket."""

    return Path(f"{docket.conflict_id.lower()}.md")


def validate_conflict_coverage(
    dockets: Sequence[ConflictDocket],
    expected_conflict_claim_ids: Iterable[str],
) -> None:
    """Require every accepted conflict claim in exactly one open docket."""

    expected = tuple(sorted(set(expected_conflict_claim_ids)))
    if any(_IDENTIFIER.fullmatch(item) is None for item in expected):
        raise _error(
            "CONFLICT_COVERAGE_INVALID",
            "expected conflict claim IDs must be valid stable IDs",
        )
    counts = Counter(
        item.claim_id
        for docket in dockets
        for item in docket.claims
        if item.claim_id in set(expected)
    )
    missing = tuple(item for item in expected if counts[item] == 0)
    duplicate = tuple(item for item in expected if counts[item] > 1)
    if missing or duplicate:
        detail = missing[0] if missing else duplicate[0]
        code = (
            "CONFLICT_CLAIM_UNDOCKETED" if missing else "CONFLICT_CLAIM_DUPLICATE"
        )
        raise _error(
            code,
            f"conflict claim must appear in exactly one docket: {detail}",
        )


def validate_docket_removals(
    previous_dockets: Sequence[ConflictDocket],
    current_dockets: Sequence[ConflictDocket],
    requirement_ids: Iterable[str],
    supersession_entries: Sequence[object],
) -> None:
    """Require an atomic target requirement and ledger row for every removal."""

    current_ids = {item.conflict_id for item in current_dockets}
    removed = {
        item.conflict_id for item in previous_dockets if item.conflict_id not in current_ids
    }
    requirements = set(requirement_ids)
    entries = {
        getattr(item, "conflict_id", None): item for item in supersession_entries
    }
    for conflict_id in sorted(removed):
        previous = next(
            item for item in previous_dockets if item.conflict_id == conflict_id
        )
        if previous.status != "resolved":
            raise _error(
                "CONFLICT_DOCKET_REMOVAL_BLOCKED",
                f"unresolved docket may not be removed: {conflict_id}",
            )
        entry = entries.get(conflict_id)
        resulting_id = getattr(entry, "resulting_id", None)
        if (
            entry is None
            or previous.owner_decision
            not in tuple(item.value for item in ConflictResolution)
            or not isinstance(resulting_id, str)
            or previous.target_requirement_id != resulting_id
            or previous.target_requirement_status != "created"
            or resulting_id not in requirements
            or tuple(getattr(entry, "old_ids", ()))
            != tuple(item.claim_id for item in previous.claims)
            or tuple(getattr(entry, "superseded_artifacts", ()))
            != previous.artifacts_to_supersede
        ):
            raise _error(
                "CONFLICT_DOCKET_REMOVAL_BLOCKED",
                (
                    "removed docket requires a same-change target requirement "
                    f"and supersession-ledger entry: {conflict_id}"
                ),
            )


def render_unresolved_report(
    dockets: Sequence[ConflictDocket],
    *,
    canon_revision: int,
    canon_content_sha: str | None = None,
    compiler_version: str = "0.1.0",
    authority_state: str = "shadow",
) -> bytes:
    """Render the sorted non-authoritative owner-gate inventory."""

    ordered = tuple(sorted(dockets, key=lambda item: item.conflict_id))
    lines = [
        "# Ambitions Unresolved Conflicts",
        "",
        "> Shadow, non-authoritative generated projection.",
        "",
        "- Schema version: `1`",
        f"- Canon revision: `{canon_revision}`",
        f"- Authority state: `{authority_state}`",
        f"- Compiler version: `{compiler_version}`",
    ]
    if canon_content_sha is not None:
        if _SHA256.fullmatch(canon_content_sha) is None:
            raise _error(
                "CONFLICT_REPORT_INVALID",
                "canon_content_sha must be a lowercase SHA-256",
            )
        lines.append(f"- Canon content SHA: `{canon_content_sha}`")
    lines.extend(
        [
            f"- Open dockets: `{sum(item.status == 'unresolved' for item in ordered)}`",
            "",
            "Open dockets block affected task packs and authority cutover. Recommendations are proposals, not owner decisions.",
            "",
            "| Conflict | Severity | Priority | Concepts | Affected task scopes | Recommendation |",
            "| --- | --- | --- | --- | --- | --- |",
        ]
    )
    lines.extend(
        "| `{}` | `{}` | `{}` | {} | {} | {} |".format(
            _cell(item.conflict_id),
            item.severity,
            item.priority,
            _cell(", ".join(item.concepts)),
            _cell(", ".join(item.affected_task_scopes)),
            _cell(item.recommendation.label),
        )
        for item in ordered
        if item.status == "unresolved"
    )
    return ("\n".join(lines).rstrip() + "\n").encode("utf-8")


def docket_known_issues(
    dockets: Sequence[ConflictDocket],
) -> tuple[dict[str, object], ...]:
    """Project open dockets into the existing task-pack issue contract."""

    return tuple(
        {
            "schema_version": 1,
            "issue_id": item.conflict_id,
            "severity": item.severity,
            "status": item.status,
            "kind": "conflict",
            "scope": list(item.affected_task_scopes),
            "summary": item.user_consequences,
        }
        for item in sorted(dockets, key=lambda value: value.conflict_id)
    )


def render_conflict_baseline(
    dockets: Sequence[ConflictDocket],
    claim_dispositions_bytes: bytes,
) -> bytes:
    """Render the durable offline conflict fingerprint and state baseline."""

    from tools.ambitions_canon.migration import (
        tracked_decision_evidence_fingerprint_sha256,
    )

    tracked = _parse_tracked_claims(
        claim_dispositions_bytes,
        Path("docs/canon/migration/claim-dispositions.json"),
    )
    ordered = tuple(sorted(dockets, key=lambda item: item.conflict_id))
    _validate_docket_claim_graph(ordered, tracked)
    decision_fingerprint = tracked_decision_evidence_fingerprint_sha256(
        claim_dispositions_bytes
    )
    payload = {
        "schema_version": 1,
        "claim_dispositions_sha256": hashlib.sha256(
            claim_dispositions_bytes
        ).hexdigest(),
        "decision_evidence_fingerprint_sha256": decision_fingerprint,
        "dockets": [
            _baseline_docket_record(item, tracked, decision_fingerprint)
            for item in ordered
        ],
    }
    return _stable_json(payload)


def validate_conflict_repository(
    root: Path,
    dockets: Sequence[ConflictDocket],
    requirement_ids: Iterable[str],
    supersession_entries: Sequence[object],
) -> ConflictRepositorySnapshot | None:
    """Validate accepted claim coverage, fingerprints, and removal state offline."""

    from tools.ambitions_canon.migration import validate_tracked_canon_evidence

    root = Path(root)
    dispositions_path = root / "docs/canon/migration/claim-dispositions.json"
    baseline_path = root / "docs/canon/migration/conflict-docket-baseline.json"
    evidence = validate_tracked_canon_evidence(root)
    if evidence is None and not dockets:
        return None
    if evidence is None:
        raise _error(
            "CONFLICT_BASELINE_MISSING",
            "claim dispositions and conflict docket baseline are both required",
            baseline_path,
        )
    disposition_bytes = evidence.claim_dispositions_bytes
    baseline_bytes = evidence.conflict_baseline_bytes
    tracked = _parse_tracked_claims(disposition_bytes, dispositions_path)
    baseline = _parse_conflict_baseline(baseline_bytes, baseline_path)
    disposition_sha = hashlib.sha256(disposition_bytes).hexdigest()
    if baseline["claim_dispositions_sha256"] != disposition_sha:
        raise _error(
            "CONFLICT_BASELINE_STALE",
            "conflict baseline is not bound to current claim dispositions",
            baseline_path,
        )
    current = {item.conflict_id: item for item in dockets}
    if len(current) != len(dockets):
        raise _error(
            "CONFLICT_DOCKET_DUPLICATE",
            "current conflict docket IDs must be unique",
        )
    baseline_records = {
        str(item["conflict_id"]): item for item in baseline["dockets"]
    }
    extra = sorted(set(current) - set(baseline_records))
    if extra:
        raise _error(
            "CONFLICT_BASELINE_UNKNOWN_DOCKET",
            f"current docket is absent from conflict baseline: {extra[0]}",
            baseline_path,
        )
    for conflict_id, record in baseline_records.items():
        docket = current.get(conflict_id)
        if docket is not None:
            expected = _baseline_docket_record(
                docket,
                tracked,
                baseline["decision_evidence_fingerprint_sha256"],
            )
            if record != expected:
                raise _error(
                    "CONFLICT_DOCKET_FINGERPRINT_MISMATCH",
                    f"docket differs from accepted conflict baseline: {conflict_id}",
                    baseline_path,
                )
            continue
        _validate_removed_baseline_record(
            record,
            set(requirement_ids),
            supersession_entries,
            baseline_path,
        )
    _validate_baseline_claim_coverage(baseline["dockets"], tracked)
    _validate_docket_claim_graph(tuple(dockets), tracked, require_complete=False)
    return ConflictRepositorySnapshot(
        source_catalog_bytes=evidence.source_catalog_bytes,
        claim_dispositions_bytes=disposition_bytes,
        baseline_bytes=baseline_bytes,
        claim_dispositions_sha256=disposition_sha,
    )


def _baseline_docket_record(
    docket: ConflictDocket,
    tracked: Mapping[str, TrackedConflictClaim],
    decision_evidence_fingerprint_sha256: str | None,
) -> dict[str, object]:
    claims: list[dict[str, str]] = []
    for item in docket.claims:
        tracked_item = tracked.get(item.claim_id)
        if tracked_item is None:
            raise _error(
                "CONFLICT_CLAIM_UNKNOWN",
                f"docket references an unknown accepted claim: {item.claim_id}",
            )
        claims.append(
            {
                "claim_id": item.claim_id,
                "source_id": item.source_id,
                "source_location": item.source_location,
                "fingerprint_sha256": _claim_fingerprint_sha256(item),
            }
        )
    record: dict[str, object] = {
        "conflict_id": docket.conflict_id,
        "status": docket.status,
        "owner_decision": docket.owner_decision,
        "target_requirement_status": docket.target_requirement_status,
        "target_requirement_id": docket.target_requirement_id,
        "claims": claims,
        "artifacts_to_supersede": list(docket.artifacts_to_supersede),
        "docket_sha256": hashlib.sha256(
            render_conflict_docket(docket).encode("utf-8")
        ).hexdigest(),
    }
    record["removal_state_sha256"] = _removal_state_sha256(
        record,
        decision_evidence_fingerprint_sha256,
    )
    return record


def _claim_fingerprint_sha256(claim: ConflictClaim) -> str:
    payload = {
        "claim_id": claim.claim_id,
        "source_id": claim.source_id,
        "source_location": claim.source_location,
        "concept": claim.concept,
        "scope": claim.scope,
        "modality": claim.modality.value,
        "normalized_value": claim.normalized_value,
        "evidence_sha256": claim.evidence_sha256,
        "owner_approval_sha256": _optional_text_sha256(claim.owner_approval),
        "owner_evidence_text_sha256": claim.owner_evidence_text_sha256,
        "owner_evidence_rationale_sha256": claim.owner_evidence_rationale_sha256,
    }
    return hashlib.sha256(_stable_json(payload)).hexdigest()


def _removal_state_sha256(
    record: Mapping[str, object],
    decision_evidence_fingerprint_sha256: str | None,
) -> str:
    payload = {
        "conflict_id": record["conflict_id"],
        "status": record["status"],
        "owner_decision": record["owner_decision"],
        "target_requirement_status": record["target_requirement_status"],
        "target_requirement_id": record["target_requirement_id"],
        "claims": record["claims"],
        "artifacts_to_supersede": record["artifacts_to_supersede"],
        "decision_evidence_fingerprint_sha256": decision_evidence_fingerprint_sha256,
    }
    return hashlib.sha256(_stable_json(payload)).hexdigest()


def _validate_docket_claim_graph(
    dockets: Sequence[ConflictDocket],
    tracked: Mapping[str, TrackedConflictClaim],
    *,
    require_complete: bool = True,
) -> None:
    expected_conflicts = {
        claim_id
        for claim_id, item in tracked.items()
        if item.disposition == "conflict"
    }
    all_current_claim_ids = [
        item.claim_id for docket in dockets for item in docket.claims
    ]
    if len(all_current_claim_ids) != len(set(all_current_claim_ids)):
        raise _error(
            "CONFLICT_CLAIM_DUPLICATE",
            "a docket claim may appear in only one conflict docket",
        )
    current_claim_ids = set(all_current_claim_ids)
    validate_conflict_coverage(
        dockets,
        (
            expected_conflicts
            if require_complete
            else expected_conflicts & current_claim_ids
        ),
    )
    for docket in dockets:
        for item in docket.claims:
            accepted = tracked.get(item.claim_id)
            if accepted is None:
                raise _error(
                    "CONFLICT_CLAIM_UNKNOWN",
                    f"docket references an unknown accepted claim: {item.claim_id}",
                )
            actual_provenance = (
                item.source_id,
                item.source_location,
                item.concept,
            )
            accepted_provenance = (
                accepted.source_id,
                accepted.source_location,
                accepted.concept,
            )
            if actual_provenance != accepted_provenance:
                raise _error(
                    "CONFLICT_PROVENANCE_MISMATCH",
                    f"docket provenance differs from tracked claim: {item.claim_id}",
                )
            if (
                _optional_text_sha256(item.owner_approval)
                != accepted.owner_approval_sha256
                or item.owner_evidence_text_sha256
                != accepted.owner_evidence_text_sha256
                or item.owner_evidence_rationale_sha256
                != accepted.owner_evidence_rationale_sha256
            ):
                raise _error(
                    "CONFLICT_OWNER_EVIDENCE_MISMATCH",
                    f"docket owner evidence differs from tracked claim: {item.claim_id}",
                )


def _validate_baseline_claim_coverage(
    records: Sequence[Mapping[str, object]],
    tracked: Mapping[str, TrackedConflictClaim],
) -> None:
    expected = {
        claim_id
        for claim_id, item in tracked.items()
        if item.disposition == "conflict"
    }
    all_claims = [claim for record in records for claim in record["claims"]]
    all_claim_ids = [str(claim["claim_id"]) for claim in all_claims]
    if len(all_claim_ids) != len(set(all_claim_ids)):
        raise _error(
            "CONFLICT_BASELINE_COVERAGE",
            "baseline claim IDs must be globally unique",
        )
    for claim in all_claims:
        accepted = tracked.get(str(claim["claim_id"]))
        if accepted is None:
            raise _error(
                "CONFLICT_BASELINE_COVERAGE",
                f"baseline references an unknown accepted claim: {claim['claim_id']}",
            )
        if (
            claim["source_id"] != accepted.source_id
            or claim["source_location"] != accepted.source_location
        ):
            raise _error(
                "CONFLICT_BASELINE_PROVENANCE",
                f"baseline source differs from accepted claim: {claim['claim_id']}",
            )
    counts = Counter(item for item in all_claim_ids if item in expected)
    missing = sorted(item for item in expected if counts[item] == 0)
    duplicate = sorted(item for item in expected if counts[item] > 1)
    if missing or duplicate:
        detail = missing[0] if missing else duplicate[0]
        raise _error(
            "CONFLICT_BASELINE_COVERAGE",
            f"baseline must cover every accepted conflict claim once: {detail}",
        )


def _validate_removed_baseline_record(
    record: Mapping[str, object],
    requirement_ids: set[str],
    supersession_entries: Sequence[object],
    path: Path,
) -> None:
    conflict_id = str(record["conflict_id"])
    if record["status"] != "resolved":
        raise _error(
            "CONFLICT_DOCKET_REMOVAL_BLOCKED",
            f"unresolved docket may not be removed: {conflict_id}",
            path,
        )
    decision = record["owner_decision"]
    target = record["target_requirement_id"]
    if (
        decision not in tuple(item.value for item in ConflictResolution)
        or record["target_requirement_status"] != "created"
        or not isinstance(target, str)
        or target not in requirement_ids
    ):
        raise _error(
            "CONFLICT_DOCKET_REMOVAL_BLOCKED",
            f"resolved removal lacks exact owner decision or target: {conflict_id}",
            path,
        )
    matches = [
        item
        for item in supersession_entries
        if getattr(item, "conflict_id", None) == conflict_id
    ]
    if len(matches) != 1:
        raise _error(
            "CONFLICT_DOCKET_REMOVAL_BLOCKED",
            f"resolved removal needs one supersession entry: {conflict_id}",
            path,
        )
    entry = matches[0]
    if (
        getattr(entry, "resulting_id", None) != target
        or tuple(getattr(entry, "old_ids", ()))
        != tuple(item["claim_id"] for item in record["claims"])
        or tuple(getattr(entry, "superseded_artifacts", ()))
        != tuple(record["artifacts_to_supersede"])
    ):
        raise _error(
            "CONFLICT_DOCKET_REMOVAL_BLOCKED",
            f"supersession entry does not match removed docket: {conflict_id}",
            path,
        )


def _parse_conflict_baseline(raw: bytes, path: Path) -> dict[str, object]:
    try:
        value = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise _error(
            "CONFLICT_BASELINE_INVALID",
            "conflict baseline must be UTF-8 JSON",
            path,
        ) from exc
    if (
        not isinstance(value, dict)
        or set(value)
        != {
            "schema_version",
            "claim_dispositions_sha256",
            "decision_evidence_fingerprint_sha256",
            "dockets",
        }
        or value.get("schema_version") != 1
        or _SHA256.fullmatch(str(value.get("claim_dispositions_sha256"))) is None
        or (
            value.get("decision_evidence_fingerprint_sha256") is not None
            and _SHA256.fullmatch(
                str(value.get("decision_evidence_fingerprint_sha256"))
            )
            is None
        )
        or not isinstance(value.get("dockets"), list)
    ):
        raise _error(
            "CONFLICT_BASELINE_INVALID",
            "conflict baseline uses an unsupported closed shape",
            path,
        )
    expected_docket_keys = {
        "conflict_id",
        "status",
        "owner_decision",
        "target_requirement_status",
        "target_requirement_id",
        "claims",
        "artifacts_to_supersede",
        "docket_sha256",
        "removal_state_sha256",
    }
    expected_claim_keys = {
        "claim_id",
        "source_id",
        "source_location",
        "fingerprint_sha256",
    }
    previous = ""
    seen: set[str] = set()
    for record in value["dockets"]:
        if not isinstance(record, dict) or set(record) != expected_docket_keys:
            raise _error("CONFLICT_BASELINE_INVALID", "docket baseline shape is invalid", path)
        conflict_id = record.get("conflict_id")
        artifacts = record.get("artifacts_to_supersede")
        if (
            not isinstance(conflict_id, str)
            or _IDENTIFIER.fullmatch(conflict_id) is None
            or conflict_id <= previous
            or conflict_id in seen
            or record.get("status") not in ALLOWED_STATUSES
            or (
                record.get("owner_decision") is not None
                and not isinstance(record.get("owner_decision"), str)
            )
            or record.get("target_requirement_status")
            not in ALLOWED_TARGET_REQUIREMENT_STATUSES
            or (
                record.get("target_requirement_id") is not None
                and (
                    not isinstance(record.get("target_requirement_id"), str)
                    or not record.get("target_requirement_id")
                )
            )
            or not isinstance(record.get("claims"), list)
            or not record["claims"]
            or not isinstance(artifacts, list)
            or not all(isinstance(item, str) and item for item in artifacts)
            or artifacts != sorted(set(artifacts))
            or _SHA256.fullmatch(str(record.get("docket_sha256"))) is None
            or _SHA256.fullmatch(str(record.get("removal_state_sha256"))) is None
        ):
            raise _error("CONFLICT_BASELINE_INVALID", "docket baseline values are invalid", path)
        claim_ids: list[str] = []
        for claim in record["claims"]:
            if (
                not isinstance(claim, dict)
                or set(claim) != expected_claim_keys
                or not isinstance(claim.get("claim_id"), str)
                or _IDENTIFIER.fullmatch(claim["claim_id"]) is None
                or not isinstance(claim.get("source_id"), str)
                or not claim["source_id"]
                or not isinstance(claim.get("source_location"), str)
                or not claim["source_location"]
                or _SHA256.fullmatch(str(claim.get("fingerprint_sha256"))) is None
            ):
                raise _error("CONFLICT_BASELINE_INVALID", "claim fingerprint shape is invalid", path)
            claim_ids.append(claim["claim_id"])
        if claim_ids != sorted(set(claim_ids)):
            raise _error("CONFLICT_BASELINE_INVALID", "baseline claim IDs differ", path)
        if record["removal_state_sha256"] != _removal_state_sha256(
            record,
            value["decision_evidence_fingerprint_sha256"],
        ):
            raise _error(
                "CONFLICT_BASELINE_INVALID",
                "removal state fingerprint differs from compact baseline",
                path,
            )
        previous = conflict_id
        seen.add(conflict_id)
    return value


def _stable_json(value: object) -> bytes:
    return (
        json.dumps(
            value,
            ensure_ascii=False,
            indent=2,
            sort_keys=True,
            separators=(",", ": "),
        )
        + "\n"
    ).encode("utf-8")


def report_conflicts(
    root: Path,
    *,
    require_resolved: bool,
    canon_revision: int = 0,
    canon_content_sha: str | None = None,
    compiler_version: str = "0.1.0",
    authority_state: str = "shadow",
) -> tuple[int, bytes]:
    """Validate the tracked claim-to-docket graph and render its report."""

    from tools.ambitions_canon.manifest import load_documents, load_manifest
    from tools.ambitions_canon.registry import build_registry

    root = Path(root)
    dockets = load_conflict_dockets(root)
    manifest = load_manifest(root)
    registry = build_registry(manifest, load_documents(root, manifest))
    validate_conflict_repository(
        root,
        dockets,
        (item.requirement_id for item in registry.requirements),
        registry.supersession_entries,
    )
    report = render_unresolved_report(
        dockets,
        canon_revision=canon_revision,
        canon_content_sha=canon_content_sha,
        compiler_version=compiler_version,
        authority_state=authority_state,
    )
    unresolved = any(item.status == "unresolved" for item in dockets)
    return (1 if require_resolved and unresolved else 0, report)


def _parse_tracked_claims(
    raw: bytes,
    path: Path,
) -> dict[str, TrackedConflictClaim]:
    try:
        data = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise _error(
            "CONFLICT_DISPOSITIONS_INVALID",
            "claim dispositions must be valid UTF-8 JSON",
            path,
        ) from exc
    if not isinstance(data, dict) or not isinstance(data.get("claims"), list):
        raise _error(
            "CONFLICT_DISPOSITIONS_INVALID",
            "claim dispositions must contain a claims array",
            path,
        )
    tracked: dict[str, TrackedConflictClaim] = {}
    for raw_claim in data["claims"]:
        if not isinstance(raw_claim, dict):
            raise _error(
                "CONFLICT_DISPOSITIONS_INVALID",
                "tracked claim must be an object",
                path,
            )
        disposition = raw_claim.get("disposition")
        if not isinstance(disposition, str) or not disposition:
            raise _error(
                "CONFLICT_DISPOSITIONS_INVALID",
                "tracked claim disposition is invalid",
                path,
            )
        try:
            claim_id = _required_string(raw_claim["claim_id"], "claim_id")
            source_id = _required_string(raw_claim["source_id"], "source_id")
            source_location = _required_string(
                raw_claim["source_location"], "source_location"
            )
            concept = _required_string(raw_claim["concept"], "concept")
            owner_approval_sha256 = _optional_sha_field(
                raw_claim, "owner_approval_sha256", path
            )
            owner_evidence_text_sha256 = _optional_sha_field(
                raw_claim, "owner_evidence_text_sha256", path
            )
            owner_evidence_rationale_sha256 = _optional_sha_field(
                raw_claim, "owner_evidence_rationale_sha256", path
            )
        except (KeyError, CanonError) as exc:
            raise _error(
                "CONFLICT_DISPOSITIONS_INVALID",
                "tracked conflict claim lacks closed provenance",
                path,
            ) from exc
        if claim_id in tracked:
            raise _error(
                "CONFLICT_DISPOSITIONS_INVALID",
                f"tracked conflict claim ID is duplicated: {claim_id}",
                path,
            )
        tracked[claim_id] = TrackedConflictClaim(
            claim_id=claim_id,
            source_id=source_id,
            source_location=source_location,
            concept=concept,
            disposition=disposition,
            owner_approval_sha256=owner_approval_sha256,
            owner_evidence_text_sha256=owner_evidence_text_sha256,
            owner_evidence_rationale_sha256=owner_evidence_rationale_sha256,
        )
    if not any(item.disposition == "conflict" for item in tracked.values()):
        raise _error(
            "CONFLICT_DISPOSITIONS_INVALID",
            "no accepted conflict claims are tracked",
            path,
        )
    return dict(sorted(tracked.items()))


def _optional_sha_field(
    value: Mapping[str, object],
    key: str,
    path: Path,
) -> str | None:
    raw = value.get(key)
    if raw is None:
        return None
    if not isinstance(raw, str) or _SHA256.fullmatch(raw) is None:
        raise _error(
            "CONFLICT_DISPOSITIONS_INVALID",
            f"{key} must be null or lowercase SHA-256",
            path,
        )
    return raw


def _parse_conflict_docket(raw: bytes, path: Path) -> ConflictDocket:
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError as exc:
        raise _error(
            "CONFLICT_DOCKET_UTF8",
            "conflict docket must be UTF-8",
            path,
        ) from exc
    match = _FRONT_MATTER.match(text)
    if match is None:
        raise _error(
            "CONFLICT_DOCKET_FRONT_MATTER",
            "conflict docket requires TOML front matter",
            path,
        )
    try:
        data = tomllib.loads(match.group(1))
    except tomllib.TOMLDecodeError as exc:
        raise _error(
            "CONFLICT_DOCKET_FRONT_MATTER",
            "conflict docket front matter is invalid TOML",
            path,
        ) from exc
    expected = {
        "schema_version",
        "conflict_id",
        "status",
        "severity",
        "priority",
        "concepts",
        "scopes",
        "recommendation",
        "recommendation_rationale",
        "stronger_composition",
        "proposed_canonical_law",
        "artifacts_to_supersede",
        "target_requirement_status",
        "target_requirement_id",
        "owner_decision",
        "allowed_resolutions",
        "affected_task_scopes",
        "nonclaims",
        "claim_ceiling",
        "claims",
        "impacts",
    }
    if set(data) != expected or data.get("schema_version") != 1:
        raise _error(
            "CONFLICT_DOCKET_SHAPE",
            "conflict docket uses an unsupported closed shape",
            path,
        )
    claims_raw = data["claims"]
    impacts_raw = data["impacts"]
    if not isinstance(claims_raw, list) or not isinstance(impacts_raw, list):
        raise _error("CONFLICT_DOCKET_SHAPE", "claims and impacts must be arrays", path)
    try:
        claims = tuple(
            ConflictClaim(
                claim_id=_mapping_string(item, "claim_id"),
                source_id=_mapping_string(item, "source_id"),
                source_location=_mapping_string(item, "source_location"),
                concept=_mapping_string(item, "concept"),
                scope=_mapping_string(item, "scope"),
                modality=Modality(_mapping_string(item, "modality")),
                normalized_value=_mapping_string(item, "normalized_value"),
                evidence_sha256=_mapping_string(item, "evidence_sha256"),
                owner_approval=_optional_mapping_string(item, "owner_approval"),
                owner_evidence_text_sha256=_optional_mapping_string(
                    item, "owner_evidence_text_sha256"
                ),
                owner_evidence_rationale_sha256=_optional_mapping_string(
                    item, "owner_evidence_rationale_sha256"
                ),
            )
            for item in claims_raw
        )
        impacts = tuple(
            (
                _mapping_string(item, "dimension"),
                _mapping_string(item, "analysis"),
            )
            for item in impacts_raw
        )
        docket = ConflictDocket(
            conflict_id=_mapping_string(data, "conflict_id"),
            status=_mapping_string(data, "status"),
            severity=_mapping_string(data, "severity"),
            priority=_mapping_string(data, "priority"),
            concepts=_string_tuple(data, "concepts"),
            scopes=_string_tuple(data, "scopes"),
            claims=claims,
            user_consequences=_body_section(text, "User consequences"),
            compatibility_analysis=_body_section(text, "Compatibility analysis"),
            recommendation=ConflictRecommendation(
                _mapping_string(data, "recommendation")
            ),
            recommendation_rationale=_mapping_string(
                data, "recommendation_rationale"
            ),
            stronger_composition=_mapping_string(data, "stronger_composition"),
            proposed_canonical_law=_mapping_string(data, "proposed_canonical_law"),
            impacts=impacts,
            artifacts_to_supersede=_string_tuple(data, "artifacts_to_supersede"),
            target_requirement_status=_mapping_string(
                data, "target_requirement_status"
            ),
            target_requirement_id=_optional_mapping_string(
                data, "target_requirement_id"
            ),
            owner_decision=_optional_mapping_string(data, "owner_decision"),
            allowed_resolutions=_string_tuple(data, "allowed_resolutions"),
            affected_task_scopes=_string_tuple(data, "affected_task_scopes"),
            nonclaims=_mapping_string(data, "nonclaims"),
            claim_ceiling=_mapping_string(data, "claim_ceiling"),
        )
    except (KeyError, TypeError, ValueError) as exc:
        raise _error(
            "CONFLICT_DOCKET_SHAPE",
            "conflict docket fields are invalid",
            path,
        ) from exc
    if text != render_conflict_docket(docket):
        raise _error(
            "CONFLICT_DOCKET_NONCANONICAL",
            "conflict docket differs from its deterministic rendering",
            path,
        )
    return docket


def _validate_atomic_claim(claim: AtomicClaim) -> None:
    if not isinstance(claim, AtomicClaim):
        raise _error("CONFLICT_CLAIM_INVALID", "candidate input is not AtomicClaim")
    for name in (
        "claim_id",
        "source_id",
        "source_location",
        "concept",
        "scope",
    ):
        _required_string(getattr(claim, name), name)
    for name in ("value", "original_text"):
        value = getattr(claim, name)
        if not isinstance(value, str) or not value.strip():
            raise _error(
                "CONFLICT_FIELD_REQUIRED", f"{name} must be a nonblank string"
            )
    if _IDENTIFIER.fullmatch(claim.claim_id) is None:
        raise _error("CONFLICT_CLAIM_INVALID", "claim_id is invalid")
    if _CONCEPT.fullmatch(claim.concept) is None:
        raise _error("CONFLICT_CLAIM_INVALID", "concept is invalid")


def _validate_docket(docket: ConflictDocket) -> None:
    if _IDENTIFIER.fullmatch(docket.conflict_id) is None:
        raise _error("CONFLICT_DOCKET_INVALID", "conflict_id is invalid")
    if docket.status not in ALLOWED_STATUSES:
        raise _error("CONFLICT_DOCKET_INVALID", "status is invalid")
    if docket.severity not in ALLOWED_SEVERITIES:
        raise _error("CONFLICT_DOCKET_INVALID", "severity is invalid")
    if docket.priority not in ALLOWED_PRIORITIES:
        raise _error("CONFLICT_DOCKET_INVALID", "priority is invalid")
    if not docket.concepts or tuple(sorted(set(docket.concepts))) != docket.concepts:
        raise _error("CONFLICT_DOCKET_INVALID", "concepts must be unique and sorted")
    if any(_CONCEPT.fullmatch(item) is None for item in docket.concepts):
        raise _error("CONFLICT_DOCKET_INVALID", "concept is invalid")
    for name, values in (
        ("scopes", docket.scopes),
        ("artifacts_to_supersede", docket.artifacts_to_supersede),
        ("affected_task_scopes", docket.affected_task_scopes),
    ):
        if not values or tuple(sorted(set(values))) != values:
            raise _error(
                "CONFLICT_DOCKET_INVALID",
                f"{name} must be nonempty, unique, and sorted",
            )
        for value in values:
            _required_string(value, name)
    if len(docket.claims) < 2:
        raise _error(
            "CONFLICT_DOCKET_INCOMPLETE", "a conflict docket needs competing claims"
        )
    claim_keys = tuple(
        (item.claim_id, item.source_id, item.source_location) for item in docket.claims
    )
    if tuple(sorted(set(claim_keys))) != claim_keys:
        raise _error(
            "CONFLICT_DOCKET_INVALID",
            "competing claims must be unique and sorted",
        )
    if not set(docket.concepts).issuperset(item.concept for item in docket.claims):
        raise _error(
            "CONFLICT_DOCKET_INVALID", "all claim concepts must be declared"
        )
    if set(dimension for dimension, _ in docket.impacts) != set(IMPACT_DIMENSIONS):
        raise _error(
            "CONFLICT_DOCKET_INCOMPLETE", "all impact dimensions are required"
        )
    if tuple(dimension for dimension, _ in docket.impacts) != IMPACT_DIMENSIONS:
        raise _error(
            "CONFLICT_DOCKET_INVALID", "impact dimensions must use canonical order"
        )
    for _, analysis in docket.impacts:
        _required_string(analysis, "impact analysis")
    for name in (
        "user_consequences",
        "compatibility_analysis",
        "recommendation_rationale",
        "stronger_composition",
        "proposed_canonical_law",
        "nonclaims",
        "claim_ceiling",
    ):
        _required_string(getattr(docket, name), name)
    if docket.severity == "P0_BLOCKER" and not re.search(
        r"\bMUST(?: NOT)?\b", docket.proposed_canonical_law
    ):
        raise _error(
            "CONFLICT_DOCKET_MODALITY",
            "P0 proposed canonical law must use MUST or MUST NOT",
        )
    exact_resolutions = tuple(item.value for item in ConflictResolution)
    if docket.allowed_resolutions != exact_resolutions:
        raise _error(
            "CONFLICT_DOCKET_RESOLUTION",
            "allowed resolutions must match the closed enum",
        )
    if docket.status == "unresolved":
        if (
            docket.owner_decision is not None
            or docket.target_requirement_id is not None
            or docket.target_requirement_status != "planned_uncreated"
        ):
            raise _error(
                "CONFLICT_DOCKET_UNRESOLVED",
                "unresolved docket cannot record a decision or created target",
            )
    else:
        if docket.owner_decision not in exact_resolutions:
            raise _error(
                "CONFLICT_DOCKET_RESOLUTION", "resolved docket needs an exact decision"
            )
        if (
            docket.target_requirement_id is None
            or _IDENTIFIER.fullmatch(docket.target_requirement_id) is None
            or docket.target_requirement_status != "created"
        ):
            raise _error(
                "CONFLICT_DOCKET_TARGET",
                "resolved docket needs a created stable target requirement",
            )


def _body_section(text: str, heading: str) -> str:
    marker = f"## {heading}\n\n"
    start = text.find(marker)
    if start < 0:
        raise _error(
            "CONFLICT_DOCKET_INCOMPLETE", f"missing body section: {heading}"
        )
    start += len(marker)
    end = text.find("\n\n## ", start)
    value = text[start:] if end < 0 else text[start:end]
    return _required_string(value, heading)


def _mapping_string(value: object, key: str) -> str:
    if not isinstance(value, Mapping) or set(value) != {
        "claim_id",
        "source_id",
        "source_location",
        "concept",
        "scope",
        "modality",
        "normalized_value",
        "evidence_sha256",
        "owner_approval",
        "owner_evidence_text_sha256",
        "owner_evidence_rationale_sha256",
    } and key in {"claim_id", "source_id", "source_location"}:
        # Exact nested shape is checked once through the first required claim key.
        raise KeyError(key)
    if not isinstance(value, Mapping) or key not in value:
        raise KeyError(key)
    return _required_string(value[key], key)


def _optional_mapping_string(value: Mapping[str, object], key: str) -> str | None:
    raw = value.get(key)
    if raw == "" or raw is None:
        return None
    return _required_string(raw, key)


def _string_tuple(value: Mapping[str, object], key: str) -> tuple[str, ...]:
    raw = value.get(key)
    if not isinstance(raw, list):
        raise TypeError(key)
    return tuple(_required_string(item, key) for item in raw)


def _required_string(value: object, name: str) -> str:
    if not isinstance(value, str) or not value.strip() or value != value.strip():
        raise _error(
            "CONFLICT_FIELD_REQUIRED", f"{name} must be a nonblank trimmed string"
        )
    return value


def _normalized_text(value: str) -> str:
    return " ".join(value.casefold().split())


def _optional_text_sha256(value: str | None) -> str | None:
    return hashlib.sha256(value.encode("utf-8")).hexdigest() if value else None


def _claims_overlap(left: AtomicClaim, right: AtomicClaim) -> bool:
    left_scope = _normalized_text(left.scope)
    right_scope = _normalized_text(right.scope)
    if left_scope == right_scope:
        return True
    if left_scope in _GLOBAL_SCOPES or right_scope in _GLOBAL_SCOPES:
        return True
    if _reciprocally_disjoint(left, right, left_scope, right_scope):
        return False
    if (
        _STRUCTURED_SCOPE.fullmatch(left_scope) is not None
        and _STRUCTURED_SCOPE.fullmatch(right_scope) is not None
    ):
        left_parts = tuple(left_scope.split("."))
        right_parts = tuple(right_scope.split("."))
        shortest = min(len(left_parts), len(right_parts))
        return left_parts[:shortest] == right_parts[:shortest]
    # Free-text scopes are ambiguous. Fail closed as overlapping unless both
    # claims explicitly declare the other scope disjoint.
    return True


def _reciprocally_disjoint(
    left: AtomicClaim,
    right: AtomicClaim,
    left_scope: str,
    right_scope: str,
) -> bool:
    left_markers = {_normalized_text(item) for item in left.conditions}
    right_markers = {_normalized_text(item) for item in right.conditions}
    return (
        f"{_DISJOINT_PREFIX}{right_scope}" in left_markers
        and f"{_DISJOINT_PREFIX}{left_scope}" in right_markers
    )


def _toml_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def _toml_strings(values: Sequence[str]) -> str:
    return "[" + ", ".join(_toml_string(item) for item in values) + "]"


def _cell(value: object) -> str:
    return (
        str(value)
        .replace("&", "&amp;")
        .replace("|", "&#124;")
        .replace("`", "&#96;")
        .replace("\r", "<br>")
        .replace("\n", "<br>")
    )


def _error(code: str, message: str, path: Path | None = None) -> CanonError:
    return CanonError(code, message, path)
