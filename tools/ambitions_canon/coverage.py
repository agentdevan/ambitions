"""Deterministic specification-completeness coverage for canonical documents."""

from __future__ import annotations

import html
import re
import tomllib
import unicodedata
from collections.abc import Mapping
from dataclasses import dataclass
from enum import StrEnum
from pathlib import Path
from types import MappingProxyType

from tools.ambitions_canon.model import (
    CanonDocument,
    CanonError,
    CanonRegistry,
    DocumentKind,
    Finding,
    GapSeverity,
)
from tools.ambitions_canon.parser import parse_front_matter


PROFILE_SCHEMA_VERSION = 1


def _profile_cells(value: str) -> tuple[str, ...]:
    return tuple(value.split())


APPROVED_PROFILES: Mapping[str, tuple[str, ...]] = MappingProxyType(
    {
        "surface-v1": _profile_cells(
            """
            purpose-user-question entry-exit routes-presentation displayed-objects
            resting-states loading-transitional empty-degraded commands-actions
            durable-effects failure-rollback offline privacy-data-classification
            accessibility-reading-order dynamic-type reduce-motion reduce-transparency
            copy-state-language visual-authority source-ownership tests proof performance
            """
        ),
        "object-v1": _profile_cells(
            """
            stable-identity user-meaning relationships lifecycle valid-transitions
            invalid-transitions commands recurrence-scheduling
            deletion-trash-restore-archive history-receipts privacy-sync-classification
            import-export projection-surfaces accessibility source-test-ownership
            """
        ),
        "journey-v1": _profile_cells(
            """
            trigger-starting-state preconditions happy-path branches cancellation
            interruption-resume commit-boundary failure recovery undo-rollback
            receipts-proof accessibility offline scenario-tests
            """
        ),
        "system-v1": _profile_cells(
            """
            responsibility-non-responsibility inputs-outputs authority-boundary
            data-classification state-model failure-recovery local-network-boundary
            determinism observability source-ownership tests-proof
            performance-resource-constraints
            """
        ),
        "standard-v1": _profile_cells(
            """
            purpose scope requirements exceptions verification source-ownership proof
            amendment-impact
            """
        ),
    }
)
PROFILE_NAMES = frozenset(APPROVED_PROFILES)
PROFILE_REQUIRED_KINDS = frozenset(
    {
        DocumentKind.APP,
        DocumentKind.SURFACE,
        DocumentKind.GLOBAL,
        DocumentKind.OBJECT,
        DocumentKind.JOURNEY,
        DocumentKind.SYSTEM,
        DocumentKind.STANDARD,
    }
)
PROFILE_BY_KIND: Mapping[DocumentKind, str] = MappingProxyType(
    {
        DocumentKind.APP: "system-v1",
        DocumentKind.SURFACE: "surface-v1",
        DocumentKind.OBJECT: "object-v1",
        DocumentKind.JOURNEY: "journey-v1",
        DocumentKind.SYSTEM: "system-v1",
        DocumentKind.STANDARD: "standard-v1",
    }
)
GLOBAL_PROFILES = frozenset({"surface-v1", "system-v1"})
SECTION_KEY = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
SECTION_MARKER = re.compile(r"^<!--\s*canon-section:\s*([a-z0-9-]+)\s*-->$")
FENCE_START = re.compile(r"^\s*(`{3,}|~{3,})")
MARKDOWN_HEADING = re.compile(r"^\s{0,3}#{1,6}(?:\s+|$)")
HTML_TAG = re.compile(r"<[^>]*>")
RESIDUAL_HTML_ENTITY = re.compile(
    r"&(?:#[xX]?[0-9A-Fa-f]+|[A-Za-z][A-Za-z0-9]+);"
)
SEMANTIC_TOKEN = re.compile(r"[^\W_]+", re.UNICODE)
SKELETON_TOKEN = re.compile(r"[a-z0-9]+")
PLACEHOLDER_CODES = (
    ("tbd",),
    ("t", "b", "d"),
    ("tba",),
    ("t", "b", "a"),
    ("tbc",),
    ("t", "b", "c"),
    ("todo",),
    ("wip",),
    ("w", "i", "p"),
    ("na",),
    ("n", "a"),
)
PLACEHOLDER_POLICY_TERMS = frozenset(
    {
        "ban",
        "banned",
        "bans",
        "disallow",
        "disallowed",
        "forbid",
        "forbidden",
        "prohibit",
        "prohibited",
        "reject",
        "rejected",
        "rejects",
    }
)
ABSENCE_TERMS = frozenset(
    {
        "nobody",
        "none",
        "ownerless",
        "unowned",
        "unmaintained",
        "unassigned",
        "vacancy",
        "vacant",
    }
)
UNKNOWN_TERMS = frozenset(
    {"unknown", "undecided", "undetermined", "unnamed", "unspecified"}
)
DEFERRAL_TERMS = frozenset(
    {"awaiting", "deferred", "eventually", "forthcoming", "ongoing", "pending", "upcoming"}
)
DEFERRAL_TARGETS = frozenset(
    {
        "accountable",
        "assignee",
        "assignment",
        "approval",
        "content",
        "details",
        "decision",
        "definition",
        "determination",
        "documentation",
        "evidence",
        "explanation",
        "implementation",
        "maintainer",
        "name",
        "naming",
        "owner",
        "ownership",
        "outcome",
        "party",
        "responsible",
        "rationale",
        "review",
        "role",
        "specification",
        "steward",
        "custodian",
        "work",
    }
)
STATUS_ONLY_TERMS = frozenset(
    {
        "draft",
        "eventually",
        "forthcoming",
        "incomplete",
        "later",
        "partial",
        "soon",
        "stub",
        "unfinished",
        "upcoming",
    }
)
OWNER_ABSENCE_TERMS = frozenset(
    {
        "any",
        "anybody",
        "anyone",
        "default",
        "fallback",
        "nobody",
        "ownerless",
        "someone",
        "somebody",
        "unassigned",
        "unmaintained",
        "unnamed",
        "unowned",
        "vacancy",
        "vacant",
        "whoever",
    }
)
FUTURE_PASSIVE_TERMS = frozenset(
    {
        "added",
        "confirmed",
        "defined",
        "decided",
        "documented",
        "named",
        "assigned",
        "provided",
        "supplied",
        "written",
    }
)
DELIVERABLE_ABSENCE_TERMS = frozenset(
    {"defined", "described", "documented", "implemented", "specified"}
)
REVISION_HORIZON_TERMS = frozenset(
    {"future", "later", "next", "release", "revision", "subsequent", "version"}
)
RATIONALE_BOILERPLATE = frozenset(
    {
        "applicable",
        "apply",
        "applies",
        "because",
        "being",
        "does",
        "due",
        "exist",
        "existence",
        "exists",
        "future",
        "it",
        "no",
        "not",
        "rationale",
        "reason",
        "reasons",
        "release",
        "revision",
        "see",
        "since",
        "subsequent",
        "that",
        "this",
        "to",
        "version",
        "next",
        "later",
        "a",
    }
)
OWNER_BOILERPLATE = frozenset(
    {
        "accountable",
        "assign",
        "assigned",
        "assignment",
        "assignee",
        "be",
        "current",
        "custodian",
        "maintainer",
        "nobody",
        "no",
        "not",
        "one",
        "owner",
        "ownerless",
        "owned",
        "ownership",
        "party",
        "pending",
        "person",
        "role",
        "responsible",
        "steward",
        "team",
        "tba",
        "tbc",
        "to",
        "unassigned",
        "undecided",
        "unknown",
        "unnamed",
        "unowned",
        "unmaintained",
        "vacancy",
        "vacant",
        "yet",
    }
)
OWNER_ROLE_TERMS = frozenset(
    {
        "accountable",
        "assignee",
        "custodian",
        "maintainer",
        "owned",
        "owner",
        "ownership",
        "person",
        "responsible",
        "role",
        "steward",
        "team",
    }
)
RATIONALE_UNCERTAINTY_TERMS = frozenset(
    {
        "ambiguous",
        "indeterminate",
        "uncertain",
        "unclear",
        "undetermined",
        "unknown",
        "unresolved",
        "unsure",
    }
)
RATIONALE_DECISION_TERMS = frozenset(
    {
        "approval",
        "conclusion",
        "confirmation",
        "decision",
        "determination",
        "review",
        "signoff",
    }
)
RATIONALE_RESULT_TERMS = frozenset(
    {
        "approved",
        "concluded",
        "confirmed",
        "determined",
        "made",
        "obtained",
        "reached",
        "resolved",
        "reviewed",
        "signed",
    }
)
RATIONALE_STATUS_TERMS = frozenset(
    {"awaiting", "needed", "outstanding", "pending", "required", "unresolved"}
)
RATIONALE_FUTURE_RESOLUTION_TERMS = frozenset(
    {"approve", "approved", "decide", "determine", "establish", "resolve", "review"}
)
OWNER_CONDITIONAL_TERMS = frozenset(
    {
        "candidate",
        "conditional",
        "nominee",
        "prospective",
        "proposed",
        "suggested",
        "tentative",
    }
)
OWNER_FUTURE_AUXILIARIES = frozenset({"expected", "will"})
OWNER_ACCOUNTABILITY_TERMS = frozenset(
    {
        "accountable",
        "assign",
        "assigned",
        "become",
        "designate",
        "name",
        "own",
        "owner",
        "responsible",
    }
)
OWNER_STATUS_SUBJECT_TERMS = frozenset(
    {"approval", "approved", "confirmation", "confirmed", "review", "signoff"}
)
OWNER_STATUS_QUALIFIER_TERMS = frozenset(
    {
        "after",
        "awaiting",
        "if",
        "needed",
        "not",
        "obtained",
        "once",
        "outstanding",
        "pending",
        "required",
        "subject",
        "upon",
        "unresolved",
    }
)
OWNER_TIMING_TERMS = frozenset({"eventually", "later"})
CONFUSABLE_ASCII_TRANSLATION = str.maketrans(
    {
        "Τ": "T",
        "τ": "t",
        "Β": "B",
        "β": "b",
        "Ϲ": "C",
        "ϲ": "c",
        "Т": "T",
        "т": "t",
        "В": "B",
        "в": "b",
        "С": "C",
        "с": "c",
    }
)
DEFAULT_IGNORABLE_RANGES = (
    (0x034F, 0x034F),
    (0x115F, 0x1160),
    (0x17B4, 0x17B5),
    (0x180B, 0x180F),
    (0x2060, 0x206F),
    (0x3164, 0x3164),
    (0xFE00, 0xFE0F),
    (0xFFA0, 0xFFA0),
    (0xE0000, 0xE0FFF),
)


class GapClass(StrEnum):
    """Stable application-specification gap classes."""

    CANON_TO_CODE = "canon_to_code"
    CODE_TO_CANON = "code_to_canon"
    FIGMA_TO_CANON = "figma_to_canon"
    LINEAR_TO_CANON = "linear_to_canon"
    INTERNAL_SPECIFICATION = "internal_specification"


class _SemanticCategory(StrEnum):
    SUBSTANTIVE = "substantive"
    ABSENCE = "absence"
    UNKNOWN = "unknown"
    DEFERRAL = "deferral"
    FUTURE_WORK = "future_work"
    PLACEHOLDER = "placeholder"
    VACUOUS_TAUTOLOGY = "vacuous_tautology"


GAP_SEVERITY: Mapping[GapClass, GapSeverity] = MappingProxyType(
    {
        GapClass.CANON_TO_CODE: GapSeverity.P0_BLOCKER,
        GapClass.CODE_TO_CANON: GapSeverity.P0_BLOCKER,
        GapClass.FIGMA_TO_CANON: GapSeverity.P1_REQUIRED,
        GapClass.LINEAR_TO_CANON: GapSeverity.P1_REQUIRED,
        GapClass.INTERNAL_SPECIFICATION: GapSeverity.P0_BLOCKER,
    }
)


@dataclass(frozen=True, slots=True)
class GapDescriptor:
    """Stable serialized context shared by coverage findings and projections."""

    gap_class: GapClass
    affected_ids: tuple[str, ...]

    def __post_init__(self) -> None:
        normalized = tuple(sorted(set(self.affected_ids)))
        if not normalized or any(not item or item != item.strip() for item in normalized):
            raise ValueError("affected_ids must contain non-empty canonical IDs")
        object.__setattr__(self, "affected_ids", normalized)

    @property
    def severity(self) -> GapSeverity:
        return GAP_SEVERITY[self.gap_class]

    def serialize(self) -> str:
        return (
            f"gap_class={self.gap_class.value} "
            f"affected_ids={','.join(self.affected_ids)}"
        )


@dataclass(frozen=True, slots=True)
class _NotApplicableEntry:
    section: str
    rationale: str | None
    owner: str | None
    exact_shape: bool = True

    @property
    def is_valid(self) -> bool:
        return bool(
            self.exact_shape
            and self.rationale
            and self.rationale == self.rationale.strip()
            and _has_substantive_rationale(self.rationale)
            and self.owner
            and self.owner == self.owner.strip()
            and _has_substantive_owner(self.owner)
        )


def load_profiles(path: Path) -> Mapping[str, tuple[str, ...]]:
    """Load the closed completeness-profile configuration."""

    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as exc:
        raise CanonError(
            "CANON_PROFILE_READ",
            "unable to read completeness profiles",
            path,
        ) from exc
    try:
        data = tomllib.loads(text)
    except tomllib.TOMLDecodeError as exc:
        raise CanonError(
            "CANON_PROFILE_PARSE",
            "invalid completeness-profile TOML",
            path,
        ) from exc

    if set(data) != {"schema_version", "profiles"}:
        raise CanonError(
            "CANON_PROFILE_SCHEMA",
            "completeness profiles require only schema_version and profiles",
            path,
        )
    schema_version = data["schema_version"]
    if (
        not isinstance(schema_version, int)
        or isinstance(schema_version, bool)
        or schema_version != PROFILE_SCHEMA_VERSION
    ):
        raise CanonError(
            "CANON_PROFILE_SCHEMA",
            f"unsupported completeness-profile schema version: {schema_version!r}",
            path,
        )
    raw_profiles = data["profiles"]
    if not isinstance(raw_profiles, dict) or set(raw_profiles) != PROFILE_NAMES:
        raise CanonError(
            "CANON_PROFILE_SCHEMA",
            "completeness profiles must define the exact approved profile set",
            path,
        )

    profiles: dict[str, tuple[str, ...]] = {}
    for name in sorted(raw_profiles):
        raw_sections = raw_profiles[name]
        if not isinstance(raw_sections, list) or not raw_sections:
            raise CanonError(
                "CANON_PROFILE_SCHEMA",
                f"profile must contain required sections: {name}",
                path,
            )
        if not all(
            isinstance(section, str) and SECTION_KEY.fullmatch(section)
            for section in raw_sections
        ):
            raise CanonError(
                "CANON_PROFILE_SCHEMA",
                f"profile contains a noncanonical section key: {name}",
                path,
            )
        if len(raw_sections) != len(set(raw_sections)):
            raise CanonError(
                "CANON_PROFILE_SCHEMA",
                f"profile contains a duplicate section key: {name}",
                path,
            )
        profiles[name] = tuple(raw_sections)
    if profiles != APPROVED_PROFILES:
        raise CanonError(
            "CANON_PROFILE_SCHEMA",
            "completeness-profile cells differ from the approved design",
            path,
        )
    return MappingProxyType(profiles)


def coverage_findings(
    registry: CanonRegistry,
    profiles: Mapping[str, tuple[str, ...]],
) -> tuple[Finding, ...]:
    """Return deterministic completeness gaps for the registry's documents."""

    findings: list[Finding] = []
    for document in sorted(
        registry.documents,
        key=lambda item: (item.source_path.as_posix(), item.spec_id),
    ):
        if document.profile is None:
            if document.kind in PROFILE_REQUIRED_KINDS:
                findings.append(
                    _coverage_finding(
                        document,
                        "CANON_PROFILE_REQUIRED",
                        "profile=none required completeness profile is missing",
                    )
                )
            continue
        if document.profile not in profiles:
            findings.append(
                _coverage_finding(
                    document,
                    "CANON_PROFILE_UNKNOWN",
                    f"profile={document.profile} is not defined",
                )
            )
            continue
        expected_profile = PROFILE_BY_KIND.get(document.kind)
        allowed_profiles = (
            GLOBAL_PROFILES
            if document.kind is DocumentKind.GLOBAL
            else frozenset({expected_profile})
        )
        if document.profile in PROFILE_NAMES and document.profile not in allowed_profiles:
            findings.append(
                _coverage_finding(
                    document,
                    "CANON_PROFILE_KIND_MISMATCH",
                    (
                        f"profile={document.profile} does not match kind={document.kind.value}; "
                        f"expected={','.join(sorted(value for value in allowed_profiles if value)) or 'none'}"
                    ),
                )
            )
            continue

        source_contract = _source_contract(document)
        evidence = _section_evidence(source_contract)
        not_applicable = _not_applicable_entries(source_contract)
        required_sections = profiles[document.profile]
        for section in sorted(set(not_applicable) - set(required_sections)):
            findings.append(
                _coverage_finding(
                    document,
                    "CANON_PROFILE_NOT_APPLICABLE_INVALID",
                    f"profile={document.profile} section={section} "
                    "is not required by the profile",
                )
            )
        for section in required_sections:
            entry = not_applicable.get(section)
            if entry is not None:
                if not entry.is_valid:
                    findings.append(
                        _coverage_finding(
                            document,
                            "CANON_PROFILE_NOT_APPLICABLE_INVALID",
                            (
                                f"profile={document.profile} section={section} "
                                "not_applicable "
                                "requires non-empty rationale and owner"
                            ),
                        )
                    )
                continue
            if not evidence.get(section, False):
                findings.append(
                    _coverage_finding(
                        document,
                        "CANON_PROFILE_SECTION_MISSING",
                        f"profile={document.profile} section={section} "
                        "lacks explicit body evidence",
                    )
                )

    return tuple(sorted(findings, key=_finding_sort_key))


def _coverage_finding(
    document: CanonDocument,
    code: str,
    detail: str,
) -> Finding:
    descriptor = GapDescriptor(
        gap_class=GapClass.INTERNAL_SPECIFICATION,
        affected_ids=(document.spec_id,),
    )
    return Finding(
        code=code,
        severity=descriptor.severity,
        message=f"{descriptor.serialize()} {detail}",
        path=document.source_path,
    )


def _source_contract(
    document: CanonDocument,
) -> tuple[Mapping[str, object], str] | None:
    if document.source_bytes is None:
        return None
    try:
        text = document.source_bytes.decode("utf-8")
        metadata, body, _ = parse_front_matter(text, document.source_path)
    except (UnicodeDecodeError, CanonError):
        return None
    return metadata, body


def _section_evidence(
    source_contract: tuple[Mapping[str, object], str] | None,
) -> Mapping[str, bool]:
    if source_contract is None:
        return MappingProxyType({})
    _, body = source_contract
    lines = body.splitlines()
    markers = _unfenced_markers(lines)
    evidence: dict[str, bool] = {}
    for marker_index, (line_index, section) in enumerate(markers):
        end = markers[marker_index + 1][0] if marker_index + 1 < len(markers) else len(lines)
        content_lines = lines[line_index + 1 : end]
        evidence[section] = evidence.get(section, False) or _has_body_evidence(
            content_lines
        )
    return MappingProxyType(evidence)


def profile_section_bodies(document: CanonDocument) -> tuple[tuple[str, str], ...]:
    """Return the closed, fence-aware applicable profile body contract."""

    if document.profile is None:
        return ()
    required = APPROVED_PROFILES.get(document.profile)
    if required is None:
        raise CanonError(
            "PACK_PROFILE_CONTRACT_INVALID",
            f"unknown completeness profile: {document.profile}",
            document.source_path,
        )
    source_contract = _source_contract(document)
    if source_contract is None:
        raise CanonError(
            "PACK_PROFILE_CONTRACT_INVALID",
            "profile source contract is unavailable",
            document.source_path,
        )
    _, body = source_contract
    lines = body.splitlines()
    markers = _unfenced_markers(lines)
    marker_names = tuple(section for _, section in markers)
    duplicate_names = tuple(
        sorted(
            section
            for section in set(marker_names)
            if marker_names.count(section) > 1
        )
    )
    applicable = tuple(
        section
        for section in required
        if section not in {entry.section for entry in document.not_applicable}
    )
    unexpected = tuple(sorted(set(marker_names) - set(applicable)))
    missing = tuple(sorted(set(applicable) - set(marker_names)))
    if duplicate_names or unexpected or missing:
        raise CanonError(
            "PACK_PROFILE_CONTRACT_INVALID",
            "profile markers must be one closed applicable set; "
            f"duplicate={','.join(duplicate_names) or 'none'}; "
            f"unexpected={','.join(unexpected) or 'none'}; "
            f"missing={','.join(missing) or 'none'}",
            document.source_path,
        )
    positions = {section: index for index, section in markers}
    ordered_positions = sorted(markers)
    end_by_section = {
        section: (
            ordered_positions[offset + 1][0]
            if offset + 1 < len(ordered_positions)
            else len(lines)
        )
        for offset, (_, section) in enumerate(ordered_positions)
    }
    result: list[tuple[str, str]] = []
    for section in applicable:
        content_lines = lines[positions[section] + 1 : end_by_section[section]]
        if not _has_body_evidence(content_lines):
            raise CanonError(
                "PACK_PROFILE_CONTRACT_INVALID",
                f"profile section lacks body evidence: {section}",
                document.source_path,
            )
        result.append((section, "\n".join(content_lines).strip()))
    return tuple(result)


def _unfenced_markers(lines: list[str]) -> tuple[tuple[int, str], ...]:
    markers: list[tuple[int, str]] = []
    for index, line in _unfenced_lines(lines):
        marker = SECTION_MARKER.fullmatch(line)
        if marker is not None:
            markers.append((index, marker.group(1)))
    return tuple(markers)


def _unfenced_lines(lines: list[str]) -> tuple[tuple[int, str], ...]:
    visible: list[tuple[int, str]] = []
    fence_character: str | None = None
    fence_length = 0
    in_html_comment = False
    for index, line in enumerate(lines):
        if fence_character is not None:
            fence = FENCE_START.match(line)
            if fence is not None:
                token = fence.group(1)
                if (
                    token[0] == fence_character
                    and len(token) >= fence_length
                    and line[fence.end() :].strip() == ""
                ):
                    fence_character = None
                    fence_length = 0
            continue
        if not in_html_comment and SECTION_MARKER.fullmatch(line) is not None:
            visible.append((index, line))
            continue
        uncommented, in_html_comment = _strip_html_comments(
            line,
            in_html_comment,
        )
        fence = FENCE_START.match(uncommented)
        if fence is not None:
            token = fence.group(1)
            if fence_character is None:
                fence_character = token[0]
                fence_length = len(token)
            continue
        visible.append((index, uncommented))
    return tuple(visible)


def _strip_html_comments(line: str, in_comment: bool) -> tuple[str, bool]:
    visible: list[str] = []
    cursor = 0
    while cursor < len(line):
        if in_comment:
            end = line.find("-->", cursor)
            if end < 0:
                return "".join(visible), True
            in_comment = False
            cursor = end + 3
            continue
        start = line.find("<!--", cursor)
        if start < 0:
            visible.append(line[cursor:])
            break
        visible.append(line[cursor:start])
        in_comment = True
        cursor = start + 4
    return "".join(visible), in_comment


def _has_body_evidence(lines: list[str]) -> bool:
    for _, line in _unfenced_lines(lines):
        candidate = line.strip()
        if not candidate:
            continue
        if MARKDOWN_HEADING.match(line):
            continue
        if FENCE_START.match(line):
            continue
        if _has_semantic_value(candidate):
            return True
    return False


def _has_semantic_value(value: str) -> bool:
    tokens = _semantic_tokens(value)
    skeleton_tokens = _placeholder_skeleton_tokens(value)
    return (
        _classify_semantic_value(tokens, skeleton_tokens)
        is _SemanticCategory.SUBSTANTIVE
    )


def _semantic_tokens(value: str) -> tuple[str, ...]:
    scanner_text = _scanner_text(value, map_confusables=False)
    tokens = tuple(SEMANTIC_TOKEN.findall(scanner_text.casefold()))
    canonical: list[str] = []
    for token in tokens:
        if token in {"inapplicable", "nonapplicable"}:
            canonical.extend(("not", "applicable"))
        else:
            canonical.append(token)
    return tuple(canonical)


def _placeholder_skeleton_tokens(value: str) -> tuple[str, ...]:
    scanner_text = _scanner_text(value, map_confusables=True)
    return tuple(SKELETON_TOKEN.findall(scanner_text.casefold()))


def _scanner_text(value: str, *, map_confusables: bool) -> str:
    decoded = html.unescape(value)
    without_residual_entities = RESIDUAL_HTML_ENTITY.sub("", decoded)
    normalized = unicodedata.normalize("NFKC", without_residual_entities)
    if map_confusables:
        normalized = normalized.translate(CONFUSABLE_ASCII_TRANSLATION)
    without_ignorables_or_marks = "".join(
        character
        for character in normalized
        if not _is_default_ignorable(character)
        and not unicodedata.category(character).startswith("M")
    )
    return HTML_TAG.sub(" ", without_ignorables_or_marks)


def _is_default_ignorable(character: str) -> bool:
    if unicodedata.category(character) == "Cf":
        return True
    codepoint = ord(character)
    return any(start <= codepoint <= end for start, end in DEFAULT_IGNORABLE_RANGES)


def _contains_phrase(tokens: tuple[str, ...], phrase: tuple[str, ...]) -> bool:
    width = len(phrase)
    return any(tokens[index : index + width] == phrase for index in range(len(tokens)))


def _phrase_positions(
    tokens: tuple[str, ...], phrase: tuple[str, ...]
) -> tuple[int, ...]:
    width = len(phrase)
    return tuple(
        index
        for index in range(len(tokens))
        if tokens[index : index + width] == phrase
    )


def _discusses_placeholder_policy(
    tokens: tuple[str, ...], skeleton_tokens: tuple[str, ...]
) -> bool:
    token_set = set(tokens)
    has_placeholder_reference = bool(
        any(_contains_phrase(skeleton_tokens, code) for code in PLACEHOLDER_CODES)
        or _contains_phrase(skeleton_tokens, ("not", "applicable"))
        or "placeholder" in token_set
    )
    prohibited_usage = bool(
        token_set & PLACEHOLDER_POLICY_TERMS
        or "invalid" in token_set
        or "cannot" in token_set
        or {"must", "never"} <= token_set
        or ({"should", "never"} <= token_set)
        or {"not", "allowed"} <= token_set
        or (
            "not" in token_set
            and bool({"may", "must", "shall", "should"} & token_set)
            and bool(
                {
                    "appear",
                    "be",
                    "count",
                    "remain",
                    "remains",
                    "serve",
                    "use",
                    "used",
                }
                & token_set
            )
        )
        or {"permitted", "only"} <= token_set
        or {"allowed", "only"} <= token_set
    )
    owned_rationale_requirement = bool(
        {"owner", "owned", "rationale"} & token_set
        and (
            {"require", "requires"} & token_set
            or {"must", "include"} <= token_set
        )
    )
    return has_placeholder_reference and (
        prohibited_usage or owned_rationale_requirement
    )


def _has_unnegated_placeholder_code(tokens: tuple[str, ...]) -> bool:
    for code in PLACEHOLDER_CODES:
        for index in _phrase_positions(tokens, code):
            if index == 0 or tokens[index - 1] != "not":
                return True
    return False


def _is_vacuous_tautology(tokens: tuple[str, ...]) -> bool:
    if "because" not in tokens:
        return False
    split = tokens.index("because")
    ignored = {"being", "does", "is", "it", "this", "that"}
    before = tuple(token for token in tokens[:split] if token not in ignored)
    after = tuple(token for token in tokens[split + 1 :] if token not in ignored)
    return bool(before) and before == after


def _classify_semantic_value(
    tokens: tuple[str, ...], skeleton_tokens: tuple[str, ...]
) -> _SemanticCategory:
    if not tokens:
        return _SemanticCategory.ABSENCE
    if _discusses_placeholder_policy(tokens, skeleton_tokens):
        return _SemanticCategory.SUBSTANTIVE
    if _has_unnegated_placeholder_code(skeleton_tokens):
        return _SemanticCategory.PLACEHOLDER
    token_set = set(tokens)
    if token_set <= ABSENCE_TERMS:
        return _SemanticCategory.ABSENCE
    if token_set <= STATUS_ONLY_TERMS:
        return _SemanticCategory.DEFERRAL
    if _contains_phrase(tokens, ("no", "one")):
        return _SemanticCategory.ABSENCE
    if token_set & UNKNOWN_TERMS:
        return _SemanticCategory.UNKNOWN
    if _is_vacuous_tautology(tokens):
        return _SemanticCategory.VACUOUS_TAUTOLOGY
    if "later" in token_set and {
        "implement",
        "implemented",
        "provided",
        "written",
        "added",
    } & token_set:
        return _SemanticCategory.FUTURE_WORK
    if _contains_phrase(tokens, ("future", "work")):
        return _SemanticCategory.FUTURE_WORK
    if (
        any(
            _contains_phrase(tokens, prefix)
            for prefix in (("to", "be"), ("will", "be"))
        )
        and token_set & FUTURE_PASSIVE_TERMS
    ):
        return _SemanticCategory.FUTURE_WORK
    if _contains_phrase(tokens, ("work", "in", "progress")) or {
        "work",
        "progress",
    } <= token_set:
        return _SemanticCategory.FUTURE_WORK
    if _contains_phrase(tokens, ("in", "progress")) or (
        "under" in token_set and bool({"construction", "development"} & token_set)
    ):
        return _SemanticCategory.FUTURE_WORK
    if {"work", "ongoing"} <= token_set:
        return _SemanticCategory.FUTURE_WORK
    if "not" in token_set and token_set & DELIVERABLE_ABSENCE_TERMS:
        return _SemanticCategory.UNKNOWN
    if _contains_phrase(tokens, ("to", "be", "determined")):
        return _SemanticCategory.UNKNOWN
    if (
        {"specified", "not", "yet"} <= token_set
        or {"specified", "not"} <= token_set
        or {"determined", "not"} <= token_set
        or _contains_phrase(tokens, ("yet", "to", "be", "specified"))
    ):
        return _SemanticCategory.UNKNOWN
    if "missing" in token_set and token_set & DEFERRAL_TARGETS:
        return _SemanticCategory.UNKNOWN
    if "needs" in token_set and token_set & DEFERRAL_TARGETS:
        return _SemanticCategory.UNKNOWN
    if "unavailable" in token_set:
        return _SemanticCategory.UNKNOWN
    if "applicability" in token_set and bool(
        {"cannot", "determine", "determined", "undetermined"} & token_set
    ):
        return _SemanticCategory.UNKNOWN
    if {"decision", "determination"} & token_set and {
        "needed",
        "required",
    } & token_set:
        return _SemanticCategory.DEFERRAL
    if "will" in token_set and bool({"decide", "decided"} & token_set):
        return _SemanticCategory.DEFERRAL
    if REVISION_HORIZON_TERMS & token_set and (
        "revision" in token_set
        or "release" in token_set
        or "version" in token_set
        or token_set & DEFERRAL_TARGETS
    ):
        return _SemanticCategory.DEFERRAL
    if token_set & DEFERRAL_TERMS and (
        token_set & DEFERRAL_TARGETS or len(tokens) == 1
    ):
        return _SemanticCategory.DEFERRAL
    if {"will", "follow"} <= token_set or (
        {"follow", "follows"} & token_set and token_set & DEFERRAL_TARGETS
    ):
        return _SemanticCategory.DEFERRAL
    if _contains_phrase(tokens, ("to", "follow")):
        return _SemanticCategory.DEFERRAL
    if (
        _contains_phrase(tokens, ("coming", "soon"))
        or _contains_phrase(tokens, ("coming", "shortly"))
        or _contains_phrase(tokens, ("details", "to", "follow"))
    ):
        return _SemanticCategory.DEFERRAL
    if _contains_phrase(tokens, ("not", "applicable")):
        explanatory_terms = {"because", "due", "since", "when"}
        if not token_set & explanatory_terms:
            return _SemanticCategory.ABSENCE
    if "placeholder" in token_set:
        return _SemanticCategory.PLACEHOLDER
    if _contains_phrase(tokens, ("pending", "specification")) or _contains_phrase(
        tokens, ("specification", "pending")
    ):
        return _SemanticCategory.DEFERRAL
    return _SemanticCategory.SUBSTANTIVE


def _has_substantive_rationale(value: str) -> bool:
    tokens = _semantic_tokens(value)
    skeleton_tokens = _placeholder_skeleton_tokens(value)
    if (
        _classify_semantic_value(tokens, skeleton_tokens)
        is not _SemanticCategory.SUBSTANTIVE
    ):
        return False
    token_set = set(tokens)
    if token_set & RATIONALE_UNCERTAINTY_TERMS or {"not", "sure"} <= token_set:
        return False
    if token_set & RATIONALE_DECISION_TERMS and token_set & RATIONALE_STATUS_TERMS:
        return False
    if (
        token_set & RATIONALE_DECISION_TERMS
        and "not" in token_set
        and token_set & RATIONALE_RESULT_TERMS
    ):
        return False
    if (
        token_set & RATIONALE_DECISION_TERMS
        and _contains_phrase(tokens, ("to", "be"))
        and token_set & RATIONALE_RESULT_TERMS
    ):
        return False
    if "will" in token_set and token_set & RATIONALE_FUTURE_RESOLUTION_TERMS:
        return False
    meaningful = tuple(token for token in tokens if token not in RATIONALE_BOILERPLATE)
    return len(set(meaningful)) >= 2


def _has_substantive_owner(value: str) -> bool:
    tokens = _semantic_tokens(value)
    skeleton_tokens = _placeholder_skeleton_tokens(value)
    if (
        _classify_semantic_value(tokens, skeleton_tokens)
        is not _SemanticCategory.SUBSTANTIVE
    ):
        return False
    token_set = set(tokens)
    if "not" in token_set or token_set & OWNER_ABSENCE_TERMS:
        return False
    if token_set & OWNER_CONDITIONAL_TERMS:
        return False
    if token_set & OWNER_TIMING_TERMS:
        return False
    if (
        token_set & OWNER_FUTURE_AUXILIARIES
        and token_set & OWNER_ACCOUNTABILITY_TERMS
    ):
        return False
    if (
        token_set & OWNER_STATUS_SUBJECT_TERMS
        and token_set & OWNER_STATUS_QUALIFIER_TERMS
    ):
        return False
    if "will" in token_set and bool({"assign", "name", "designate"} & token_set):
        return False
    if {"no", "not"} & token_set and token_set & OWNER_ROLE_TERMS:
        return False
    assignment_status = {
        "assign",
        "assigned",
        "assignment",
        "follow",
        "follows",
        "forthcoming",
        "pending",
        "undecided",
    }
    if token_set & assignment_status and not token_set - OWNER_BOILERPLATE:
        return False
    identifying = tuple(token for token in tokens if token not in OWNER_BOILERPLATE)
    return bool(identifying)


def _not_applicable_entries(
    source_contract: tuple[Mapping[str, object], str] | None,
) -> Mapping[str, _NotApplicableEntry]:
    entries: dict[str, _NotApplicableEntry] = {}
    if source_contract is None:
        return MappingProxyType(entries)
    metadata, _ = source_contract
    raw_table = metadata.get("not_applicable")
    if raw_table is None:
        return MappingProxyType(entries)
    if not isinstance(raw_table, dict):
        entries["<invalid>"] = _NotApplicableEntry("<invalid>", None, None)
        return MappingProxyType(entries)
    for section, raw_entry in raw_table.items():
        if not isinstance(section, str) or not isinstance(raw_entry, dict):
            entries[str(section)] = _NotApplicableEntry(str(section), None, None)
            continue
        rationale = raw_entry.get("rationale")
        owner = raw_entry.get("owner")
        entries[section] = _NotApplicableEntry(
            section=section,
            rationale=rationale if isinstance(rationale, str) else None,
            owner=owner if isinstance(owner, str) else None,
            exact_shape=set(raw_entry) == {"rationale", "owner"},
        )
    return MappingProxyType(entries)


def _finding_sort_key(finding: Finding) -> tuple[str, str, str, int, str]:
    return (
        finding.severity.value,
        finding.code,
        finding.path.as_posix() if finding.path is not None else "",
        finding.line if finding.line is not None else 0,
        finding.message,
    )
