"""Data model and deterministic serialization for capability discovery."""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Mapping


class CapabilityDiscoveryError(RuntimeError):
    """Raised when capability discovery input or output is invalid."""


def canonical_json(value: object) -> str:
    """Return repository-stable JSON text."""

    return json.dumps(
        value,
        indent=2,
        sort_keys=True,
        ensure_ascii=False,
    ) + "\n"


def stable_digest(*parts: str) -> str:
    """Return a stable SHA-256 digest for ordered text parts."""

    payload = "\x1f".join(parts).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def normalize_space(value: str) -> str:
    """Collapse whitespace without changing substantive wording."""

    return " ".join(value.split())


@dataclass(frozen=True, slots=True)
class SourceFamily:
    family_id: str
    name: str
    path_patterns: tuple[str, ...]
    authority_class: str
    configured_status: str
    coverage_note: str | None = None

    @classmethod
    def from_mapping(cls, payload: Mapping[str, Any]) -> "SourceFamily":
        try:
            family_id = str(payload["id"])
            name = str(payload["name"])
            patterns = tuple(str(item) for item in payload["path_patterns"])
            authority_class = str(payload["authority_class"])
            status = str(payload["status"])
        except (KeyError, TypeError) as exc:
            raise CapabilityDiscoveryError(
                f"invalid source family record: {payload!r}"
            ) from exc
        if not family_id or not patterns:
            raise CapabilityDiscoveryError(
                f"source family requires id and path patterns: {payload!r}"
            )
        note = payload.get("coverage_note")
        return cls(
            family_id=family_id,
            name=name,
            path_patterns=patterns,
            authority_class=authority_class,
            configured_status=status,
            coverage_note=str(note) if note is not None else None,
        )


@dataclass(frozen=True, slots=True)
class SourceFile:
    family_id: str
    authority_class: str
    path: str
    sha256: str
    byte_count: int
    line_count: int

    def as_record(self) -> dict[str, object]:
        return {
            "authority_class": self.authority_class,
            "byte_count": self.byte_count,
            "family_id": self.family_id,
            "line_count": self.line_count,
            "path": self.path,
            "sha256": self.sha256,
        }


@dataclass(frozen=True, slots=True)
class EvidenceExcerpt:
    family_id: str
    authority_class: str
    source_path: str
    start_line: int
    end_line: int
    exact_text: str
    extraction_kind: str
    extraction_rationale: str
    evidence_fingerprint: str

    @classmethod
    def create(
        cls,
        *,
        family_id: str,
        authority_class: str,
        source_path: str,
        start_line: int,
        end_line: int,
        exact_text: str,
        extraction_kind: str,
        extraction_rationale: str,
    ) -> "EvidenceExcerpt":
        normalized = normalize_space(exact_text)
        fingerprint = stable_digest(
            family_id,
            authority_class,
            source_path,
            str(start_line),
            str(end_line),
            normalized,
            extraction_kind,
        )
        return cls(
            family_id=family_id,
            authority_class=authority_class,
            source_path=source_path,
            start_line=start_line,
            end_line=end_line,
            exact_text=normalized,
            extraction_kind=extraction_kind,
            extraction_rationale=extraction_rationale,
            evidence_fingerprint=fingerprint,
        )

    def as_record(self) -> dict[str, object]:
        return {
            "authority_class": self.authority_class,
            "end_line": self.end_line,
            "evidence_fingerprint": self.evidence_fingerprint,
            "exact_text": self.exact_text,
            "extraction_kind": self.extraction_kind,
            "extraction_rationale": self.extraction_rationale,
            "family_id": self.family_id,
            "source_path": self.source_path,
            "start_line": self.start_line,
        }


@dataclass(frozen=True, slots=True)
class CandidateRecord:
    candidate_id: str
    authority_status: str
    exact_terminology: str
    normalized_name_hint: str
    classification: str
    specification_maturity: str
    implementation_status: str
    verification_status: str
    disposition: str
    evidence: tuple[EvidenceExcerpt, ...]
    owner_seed_id: str | None = None
    note: str | None = None

    @classmethod
    def from_evidence(
        cls,
        evidence: EvidenceExcerpt,
        *,
        normalized_name_hint: str,
    ) -> "CandidateRecord":
        candidate_id = (
            "CAND-" + stable_digest(evidence.evidence_fingerprint)[:16].upper()
        )
        return cls(
            candidate_id=candidate_id,
            authority_status="repository_candidate",
            exact_terminology=evidence.exact_text,
            normalized_name_hint=normalize_space(normalized_name_hint),
            classification="unclassified",
            specification_maturity="unframed",
            implementation_status="not_assessed",
            verification_status="not_assessed",
            disposition="preserve_for_capability_extraction",
            evidence=(evidence,),
        )

    def as_record(self) -> dict[str, object]:
        record: dict[str, object] = {
            "authority_status": self.authority_status,
            "candidate_id": self.candidate_id,
            "classification": self.classification,
            "disposition": self.disposition,
            "evidence": [item.as_record() for item in self.evidence],
            "exact_terminology": self.exact_terminology,
            "implementation_status": self.implementation_status,
            "normalized_name_hint": self.normalized_name_hint,
            "specification_maturity": self.specification_maturity,
            "verification_status": self.verification_status,
        }
        if self.owner_seed_id is not None:
            record["owner_seed_id"] = self.owner_seed_id
        if self.note is not None:
            record["note"] = self.note
        return record


@dataclass(frozen=True, slots=True)
class FamilyCoverage:
    family_id: str
    status: str
    matched_paths: tuple[str, ...]
    extracted_candidate_count: int
    blockers: tuple[str, ...] = ()
    note: str | None = None

    def as_record(self) -> dict[str, object]:
        record: dict[str, object] = {
            "blockers": list(self.blockers),
            "extracted_candidate_count": self.extracted_candidate_count,
            "family_id": self.family_id,
            "matched_path_count": len(self.matched_paths),
            "matched_paths": list(self.matched_paths),
            "status": self.status,
        }
        if self.note is not None:
            record["note"] = self.note
        return record


def load_json_object(path: Path) -> dict[str, Any]:
    """Load a JSON object and reject non-object roots."""

    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise CapabilityDiscoveryError(f"cannot load JSON {path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise CapabilityDiscoveryError(f"JSON root must be an object: {path}")
    return payload


def sorted_records(records: Iterable[CandidateRecord]) -> list[CandidateRecord]:
    """Return deterministic candidate ordering."""

    return sorted(
        records,
        key=lambda item: (
            item.authority_status != "owner_seed",
            item.normalized_name_hint.casefold(),
            item.candidate_id,
        ),
    )
