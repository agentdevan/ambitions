"""Deterministic repository archaeology for the Ambitions Capability Atlas."""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Mapping

from tools.capability_atlas.model import (
    CandidateRecord,
    CapabilityDiscoveryError,
    EvidenceExcerpt,
    FamilyCoverage,
    SourceFile,
    canonical_json,
    load_json_object,
    normalize_space,
    sorted_records,
)
from tools.capability_atlas.source_policy import (
    SOURCE_REGISTER_PATH,
    enumerate_family_paths,
    is_text_candidate,
    load_source_families,
    read_source_file,
    read_text,
)


SEED_PATH = Path("docs/capabilities/seed-capabilities.json")
OUTPUT_PATHS = (
    Path("docs/capabilities/candidate-capabilities.json"),
    Path("docs/capabilities/CANDIDATE_CAPABILITY_INVENTORY.md"),
    Path("docs/capabilities/discovery-coverage.json"),
    Path("docs/capabilities/discovery-sources.json"),
)

HEADING_PATTERN = re.compile(r"^(#{2,5})\s+(.+?)\s*$")
MARKDOWN_PREFIX_PATTERN = re.compile(r"^(?:[-*+]\s+|>\s*|\d+[.)]\s+)")
PROMISE_PATTERN = re.compile(
    r"\b(?:Ambitions|the person|a person|people|users?|the system|Today|Goals|Time|You|Capture|Search)\b"
    r".{0,120}?\b(?:must|can|will|should|may|allows?|enables?|helps?|generates?|simulates?|"
    r"reflows?|adapts?|preserves?|protects?|supports?|provides?|shows?|offers?|creates?|"
    r"coordinates?|reconciles?|learns?|transfers?|restores?|exports?|imports?|shares?|finds?)\b",
    re.IGNORECASE,
)
CAPABILITY_TERM_PATTERN = re.compile(
    r"\b(?:capabilit|simulation|pathing|reflow|search|command|appearance|share|sharing|"
    r"attachment|file storage|learning|skill|adaptation|recovery|restoration|privacy|"
    r"continuity|scheduling|planning|projection|inspection|capture|export|import|proof|"
    r"scenario|recommendation|personalization|context)\w*\b",
    re.IGNORECASE,
)
GENERIC_HEADINGS = frozenset(
    {
        "acceptance criteria",
        "architecture",
        "background",
        "constraints",
        "dependencies",
        "evidence",
        "examples",
        "files",
        "global constraints",
        "goal",
        "implementation",
        "interfaces",
        "maintenance",
        "non-goals",
        "overview",
        "purpose",
        "requirements",
        "scope",
        "status",
        "summary",
        "tests",
        "validation",
    }
)


@dataclass(frozen=True, slots=True)
class DiscoveryCompilation:
    repository: str
    baseline_ref: str
    candidates: tuple[CandidateRecord, ...]
    source_files: tuple[SourceFile, ...]
    coverage: tuple[FamilyCoverage, ...]


def _strip_markdown(value: str) -> str:
    text = value.strip()
    text = MARKDOWN_PREFIX_PATTERN.sub("", text)
    text = text.strip("| ")
    text = re.sub(r"`([^`]+)`", r"\1", text)
    text = re.sub(r"\[([^\]]+)\]\([^\)]+\)", r"\1", text)
    text = re.sub(r"[*_]{1,2}([^*_]+)[*_]{1,2}", r"\1", text)
    return normalize_space(text)


def _is_noise(text: str) -> bool:
    lowered = text.casefold()
    if len(text) < 12 or len(text) > 300:
        return True
    if text.startswith(("```", "---", "<!--", "{")):
        return True
    if lowered.startswith(("http://", "https://")):
        return True
    if lowered.startswith(("do not ", "must not ", "never ")):
        return True
    if re.fullmatch(r"[\W_]+", text):
        return True
    if re.match(r"^[A-Za-z0-9_.-]+\s*[:=]\s*[^.]+$", text) and " " not in text.split(":", 1)[0]:
        return True
    return False


def _heading_name_hint(title: str) -> str:
    title = re.sub(r"^[A-Z]{1,8}-\d+(?:\.\d+)*\s*[—:-]\s*", "", title)
    title = re.sub(r"^\d+(?:\.\d+)*[.)]?\s+", "", title)
    return normalize_space(title)


def _sentence_name_hint(sentence: str) -> str:
    text = sentence.strip().rstrip(".")
    prefixes = (
        r"^Ambitions\s+(?:must|can|will|should|may)\s+",
        r"^(?:The|A)\s+person\s+(?:must|can|will|should|may)\s+",
        r"^Users?\s+(?:must|can|will|should|may)\s+",
        r"^The\s+system\s+(?:must|can|will|should|may)\s+",
    )
    for pattern in prefixes:
        text = re.sub(pattern, "", text, flags=re.IGNORECASE)
    text = re.split(r"[;—]", text, maxsplit=1)[0]
    text = normalize_space(text)
    if len(text) > 140:
        text = text[:137].rstrip() + "..."
    if not text:
        return sentence[:140]
    return text[0].upper() + text[1:]


def _make_evidence(
    *,
    family_id: str,
    authority_class: str,
    source_path: str,
    line_number: int,
    exact_text: str,
    extraction_kind: str,
    rationale: str,
) -> EvidenceExcerpt:
    return EvidenceExcerpt.create(
        family_id=family_id,
        authority_class=authority_class,
        source_path=source_path,
        start_line=line_number,
        end_line=line_number,
        exact_text=exact_text,
        extraction_kind=extraction_kind,
        extraction_rationale=rationale,
    )


def extract_candidate_records(
    *,
    family_id: str,
    authority_class: str,
    source_path: str,
    text: str,
) -> tuple[CandidateRecord, ...]:
    """Extract conservative, non-authoritative capability hints from one file."""

    records: list[CandidateRecord] = []
    seen_fingerprints: set[str] = set()
    in_fence = False
    for line_number, raw_line in enumerate(text.splitlines(), start=1):
        stripped = raw_line.strip()
        if stripped.startswith("```"):
            in_fence = not in_fence
            continue
        if in_fence:
            continue

        heading_match = HEADING_PATTERN.match(stripped)
        if heading_match:
            title = _strip_markdown(heading_match.group(2))
            name_hint = _heading_name_hint(title)
            if (
                not _is_noise(title)
                and name_hint.casefold() not in GENERIC_HEADINGS
                and CAPABILITY_TERM_PATTERN.search(name_hint)
            ):
                evidence = _make_evidence(
                    family_id=family_id,
                    authority_class=authority_class,
                    source_path=source_path,
                    line_number=line_number,
                    exact_text=title,
                    extraction_kind="capability_heading_hint",
                    rationale=(
                        "Heading contains capability-oriented product terminology; "
                        "preserved as a candidate hint without authority inference."
                    ),
                )
                if evidence.evidence_fingerprint not in seen_fingerprints:
                    seen_fingerprints.add(evidence.evidence_fingerprint)
                    records.append(
                        CandidateRecord.from_evidence(
                            evidence,
                            normalized_name_hint=name_hint,
                        )
                    )
            continue

        sentence = _strip_markdown(stripped)
        if _is_noise(sentence):
            continue
        if PROMISE_PATTERN.search(sentence) and CAPABILITY_TERM_PATTERN.search(sentence):
            evidence = _make_evidence(
                family_id=family_id,
                authority_class=authority_class,
                source_path=source_path,
                line_number=line_number,
                exact_text=sentence,
                extraction_kind="person_facing_promise_hint",
                rationale=(
                    "Sentence combines an Ambitions/person-facing subject, an enabling "
                    "verb, and capability-oriented terminology."
                ),
            )
            if evidence.evidence_fingerprint in seen_fingerprints:
                continue
            seen_fingerprints.add(evidence.evidence_fingerprint)
            records.append(
                CandidateRecord.from_evidence(
                    evidence,
                    normalized_name_hint=_sentence_name_hint(sentence),
                )
            )
    return tuple(records)


def _load_owner_seed_candidates(repository_root: Path) -> tuple[CandidateRecord, ...]:
    payload = load_json_object(repository_root / SEED_PATH)
    seeds = payload.get("seeds")
    if not isinstance(seeds, list):
        raise CapabilityDiscoveryError(f"seeds must be a list: {SEED_PATH}")
    records: list[CandidateRecord] = []
    for index, item in enumerate(seeds, start=1):
        if not isinstance(item, Mapping):
            raise CapabilityDiscoveryError(f"invalid owner seed at index {index}")
        try:
            seed_id = str(item["seed_id"])
            wording = str(item["owner_wording"])
            proposed_name = str(item["proposed_name"])
        except KeyError as exc:
            raise CapabilityDiscoveryError(
                f"owner seed missing required field at index {index}"
            ) from exc
        evidence = EvidenceExcerpt.create(
            family_id="SRC-OWNER-SEEDS",
            authority_class="owner_seed_non_normative",
            source_path=SEED_PATH.as_posix(),
            start_line=1,
            end_line=1,
            exact_text=wording,
            extraction_kind="owner_seed",
            extraction_rationale="Direct owner-originated capability seed preserved verbatim.",
        )
        records.append(
            CandidateRecord(
                candidate_id=f"CAND-{seed_id}",
                authority_status="owner_seed",
                exact_terminology=wording,
                normalized_name_hint=proposed_name,
                classification="capability_candidate",
                specification_maturity=str(item.get("specification_maturity", "unframed")),
                implementation_status=str(item.get("implementation_status", "not_assessed")),
                verification_status=str(item.get("verification_status", "not_assessed")),
                disposition=str(
                    item.get("disposition", "preserve_for_repository_reconciliation")
                ),
                evidence=(evidence,),
                owner_seed_id=seed_id,
                note=str(item["note"]) if item.get("note") is not None else None,
            )
        )
    return tuple(records)


def compile_discovery(repository_root: Path) -> DiscoveryCompilation:
    """Compile all configured source families into non-normative candidates."""

    root = repository_root.resolve()
    register = load_json_object(root / SOURCE_REGISTER_PATH)
    repository = str(register.get("repository", "agentdevan/ambitions"))
    baseline_ref = str(register.get("baseline_ref", "main"))
    candidates: list[CandidateRecord] = list(_load_owner_seed_candidates(root))
    source_files: list[SourceFile] = []
    coverage: list[FamilyCoverage] = []

    for family in load_source_families(root):
        paths = enumerate_family_paths(root, family)
        family_candidates: list[CandidateRecord] = []
        blockers: list[str] = []
        readable_paths: list[str] = []
        for path in paths:
            if not is_text_candidate(path):
                blockers.append(f"unsupported_text_format:{path.as_posix()}")
                continue
            try:
                source_file = read_source_file(root, family, path)
                text = read_text(root, path)
            except CapabilityDiscoveryError as exc:
                blockers.append(str(exc))
                continue
            source_files.append(source_file)
            readable_paths.append(path.as_posix())
            if family.family_id == "SRC-OWNER-SEEDS":
                continue
            family_candidates.extend(
                extract_candidate_records(
                    family_id=family.family_id,
                    authority_class=family.authority_class,
                    source_path=path.as_posix(),
                    text=text,
                )
            )

        candidates.extend(family_candidates)
        if readable_paths:
            status = "covered"
        elif paths:
            status = "blocked"
        else:
            status = "blocked"
            blockers.append("no_paths_matched")
        if family.family_id == "SRC-OWNER-SEEDS" and family.configured_status == "covered":
            status = "covered"
        coverage.append(
            FamilyCoverage(
                family_id=family.family_id,
                status=status,
                matched_paths=tuple(path.as_posix() for path in paths),
                extracted_candidate_count=(
                    len(_load_owner_seed_candidates(root))
                    if family.family_id == "SRC-OWNER-SEEDS"
                    else len(family_candidates)
                ),
                blockers=tuple(sorted(set(blockers))),
                note=family.coverage_note,
            )
        )

    deduplicated = {item.candidate_id: item for item in candidates}
    return DiscoveryCompilation(
        repository=repository,
        baseline_ref=baseline_ref,
        candidates=tuple(sorted_records(deduplicated.values())),
        source_files=tuple(
            sorted(source_files, key=lambda item: (item.family_id, item.path))
        ),
        coverage=tuple(sorted(coverage, key=lambda item: item.family_id)),
    )


def _candidate_payload(compilation: DiscoveryCompilation) -> dict[str, object]:
    owner_seed_count = sum(
        item.authority_status == "owner_seed" for item in compilation.candidates
    )
    return {
        "authority": "non_normative_discovery_inventory",
        "baseline_ref": compilation.baseline_ref,
        "counts": {
            "owner_seed_candidates": owner_seed_count,
            "repository_candidates": len(compilation.candidates) - owner_seed_count,
            "total_candidates": len(compilation.candidates),
        },
        "repository": compilation.repository,
        "schema_version": 1,
        "candidates": [item.as_record() for item in compilation.candidates],
    }


def _coverage_payload(compilation: DiscoveryCompilation) -> dict[str, object]:
    statuses: dict[str, int] = {}
    for item in compilation.coverage:
        statuses[item.status] = statuses.get(item.status, 0) + 1
    return {
        "authority": "non_normative_discovery_coverage",
        "baseline_ref": compilation.baseline_ref,
        "coverage_summary": dict(sorted(statuses.items())),
        "repository": compilation.repository,
        "schema_version": 1,
        "source_families": [item.as_record() for item in compilation.coverage],
    }


def _sources_payload(compilation: DiscoveryCompilation) -> dict[str, object]:
    return {
        "authority": "non_normative_source_fingerprint_inventory",
        "baseline_ref": compilation.baseline_ref,
        "repository": compilation.repository,
        "schema_version": 1,
        "source_file_count": len(compilation.source_files),
        "source_files": [item.as_record() for item in compilation.source_files],
    }


def render_inventory_markdown(compilation: DiscoveryCompilation) -> str:
    """Render a readable projection without changing candidate authority."""

    owner_seeds = [
        item for item in compilation.candidates if item.authority_status == "owner_seed"
    ]
    repository_candidates = [
        item
        for item in compilation.candidates
        if item.authority_status == "repository_candidate"
    ]
    lines = [
        "# Candidate Capability Inventory",
        "",
        "> Non-normative discovery output. Inclusion is not canonization, approval,",
        "> implementation readiness, or evidence that current code fulfills the promise.",
        "",
        "## Discovery summary",
        "",
        f"- Owner-originated seeds: **{len(owner_seeds)}**",
        f"- Repository-derived candidate hints: **{len(repository_candidates)}**",
        f"- Fingerprinted source files: **{len(compilation.source_files)}**",
        f"- Configured source families: **{len(compilation.coverage)}**",
        "",
        "## Source-family coverage",
        "",
        "| Source family | Status | Paths | Candidate hints | Blockers |",
        "|---|---:|---:|---:|---|",
    ]
    for item in compilation.coverage:
        blocker_text = "; ".join(item.blockers) if item.blockers else "—"
        lines.append(
            f"| `{item.family_id}` | {item.status} | {len(item.matched_paths)} | "
            f"{item.extracted_candidate_count} | {blocker_text} |"
        )

    lines.extend(["", "## Owner-originated seeds", ""])
    for item in owner_seeds:
        lines.extend(
            [
                f"### {item.candidate_id} — {item.normalized_name_hint}",
                "",
                f"- Owner wording: {item.exact_terminology}",
                f"- Authority: `{item.authority_status}`",
                f"- Disposition: `{item.disposition}`",
                "",
            ]
        )

    lines.extend(["## Repository-derived candidate hints", ""])
    current_family: str | None = None
    for item in repository_candidates:
        evidence = item.evidence[0]
        if evidence.family_id != current_family:
            current_family = evidence.family_id
            lines.extend([f"### {current_family}", ""])
        lines.extend(
            [
                f"- **{item.normalized_name_hint}** (`{item.candidate_id}`)",
                f"  - Source: `{evidence.source_path}:{evidence.start_line}`",
                f"  - Exact terminology: {item.exact_terminology}",
                f"  - Extraction: `{evidence.extraction_kind}`",
            ]
        )
    if not repository_candidates:
        lines.append("No repository-derived candidate hints were extracted.")
    lines.append("")
    return "\n".join(lines)


def render_outputs(compilation: DiscoveryCompilation) -> dict[Path, str]:
    """Render all deterministic discovery artifacts."""

    return {
        OUTPUT_PATHS[0]: canonical_json(_candidate_payload(compilation)),
        OUTPUT_PATHS[1]: render_inventory_markdown(compilation),
        OUTPUT_PATHS[2]: canonical_json(_coverage_payload(compilation)),
        OUTPUT_PATHS[3]: canonical_json(_sources_payload(compilation)),
    }


def output_drift(repository_root: Path, outputs: Mapping[Path, str]) -> tuple[Path, ...]:
    """Return generated paths whose checked-in contents differ."""

    drift: list[Path] = []
    for relative_path, expected in sorted(outputs.items(), key=lambda item: item[0].as_posix()):
        absolute_path = repository_root / relative_path
        try:
            actual = absolute_path.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError):
            drift.append(relative_path)
            continue
        if actual != expected:
            drift.append(relative_path)
    return tuple(drift)


def write_outputs(repository_root: Path, outputs: Mapping[Path, str]) -> None:
    """Write deterministic discovery artifacts."""

    for relative_path, content in sorted(outputs.items(), key=lambda item: item[0].as_posix()):
        absolute_path = repository_root / relative_path
        absolute_path.parent.mkdir(parents=True, exist_ok=True)
        absolute_path.write_text(content, encoding="utf-8")
