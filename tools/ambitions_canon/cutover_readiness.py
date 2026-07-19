"""Offline, fail-closed Gate B evidence verification and rendering."""

from __future__ import annotations

import ast
import base64
import binascii
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
import tomllib
import zlib
from collections.abc import Mapping
from contextlib import contextmanager
from pathlib import Path

from tools.ambitions_canon.authorization import (
    AuthorizationError,
    approval_attestation_digest,
    canonical_tree_delta,
    canonical_json_bytes,
    load_base_policy,
    load_trusted_bindings,
    task_finalize,
    task_start,
    trusted_event_projection_digest,
)
from tools.ambitions_canon.authorization_benchmark import (
    AUTHORIZATION_SCENARIO_IDS,
    BenchmarkError,
    canonical_benchmark_bytes,
    load_authorization_benchmark_scenarios,
    run_authorization_benchmark,
)
from tools.ambitions_canon.model import CanonError, GapSeverity


BOOTSTRAP_CLAIM_CEILING = (
    "Gate B authorizes Task 26 authority/routing cutover by owner-approved direct "
    "integration under OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z only; "
    "exact SHA-bound local authorization, one exact high-risk review, rollback, and "
    "Gate C remain required; protected CI installation and protected enforcement are "
    "explicitly excluded, and live_enforcement_proven remains false."
)
OWNER_DIRECT_INTEGRATION_DECISION_ID = (
    "OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z"
)
OWNER_DIRECT_INTEGRATION_DECISION_DATE = "2026-07-17"
OWNER_DIRECT_INTEGRATION_SCOPE_LABEL = (
    "Task 26 authority/routing cutover only"
)
_MAX_PRIMARY_EVIDENCE_BYTES = 4 * 1024 * 1024
_MAX_ARTIFACT_BYTES = 64 * 1024 * 1024
_MAX_PINNED_INPUT_BYTES = 8 * 1024 * 1024
_MAX_PRIMARY_EVIDENCE_DEPTH = 64
_MAX_PRIMARY_EVIDENCE_NODES = 100_000
_VERIFIER_SUBPROCESS_TIMEOUT_SECONDS = 60
_TRUSTED_PYTHON_VERSION = (3, 12)
_VISUAL_POLICY_PATH = "docs/canon/references/task-25-authorization-benchmark-policy.json"
_VISUAL_CLAIM_CEILING = (
    "Figma design authority only; no simulator, runtime, device, accessibility, "
    "privacy, or release proof."
)
_VISUAL_LEDGER_PATHS = (
    "docs/canon/generated/canon-index.json",
    "docs/canon/generated/visual-authority-manifest.json",
    "docs/canon/migration/ux-blueprint.json",
    "docs/canon/migration/visual-authority-rebaseline.json",
)
GATE_B_REQUIRED_EVIDENCE_IDS = (
    "active-authority-dispositions",
    "authorization-eight-scenarios",
    "exact-tree-delta",
    "external-references-resolve",
    "generated-output-reproducible",
    "independent-ci-regeneration",
    "no-p0-conflict",
    "no-p0-gap",
    "old-audit-green",
    "request-only-handoff",
    "rollback-proven",
    "single-concept-owner",
    "skill-freshness",
    "stale-input-negative-proof",
    "task-pack-representatives",
    "trusted-attestation-binding",
    "unique-concepts-preserved",
    "visual-reconciliation-green",
)
_DOMAIN_OBSERVATION_KINDS = {
    "active-authority-dispositions": "authority-disposition-corpus",
    "authorization-eight-scenarios": "authorization-scenario-policy",
    "exact-tree-delta": "canon-manifest-tree-input",
    "external-references-resolve": "external-reference-impact",
    "generated-output-reproducible": "generated-index-output",
    "independent-ci-regeneration": "ci-regeneration-test",
    "no-p0-conflict": "conflict-docket-projection",
    "no-p0-gap": "specification-coverage-projection",
    "old-audit-green": "legacy-audit-parity",
    "request-only-handoff": "request-only-intake-schema",
    "rollback-proven": "rollback-report-input",
    "single-concept-owner": "concept-owner-projection",
    "skill-freshness": "skill-dependency-registry",
    "stale-input-negative-proof": "stale-input-negative-test",
    "task-pack-representatives": "task-pack-representative-test",
    "trusted-attestation-binding": "trust-anchor-registry",
    "unique-concepts-preserved": "requirement-graph-projection",
    "visual-reconciliation-green": "visual-ledger-completeness",
}

_TOP_LEVEL_FIELDS = frozenset(
    {
        "schema_version",
        "evidence_revision",
        "canon_revision",
        "canon_manifest_path",
        "canon_manifest_sha256",
        "source_sha",
        "source_tree_sha",
        "expected_base_sha",
        "gate_b_requested_state",
        "bootstrap_approval_ceiling",
        "evidence_registry",
        "verifier",
        "requirements",
        "authorization_benchmark",
        "reviews",
        "owner_decision",
        "rollback",
        "protected_boundary",
        "visual_owner_approval",
    }
)
_REQUIREMENT_FIELDS = frozenset(
    {
        "requirement_id",
        "status",
        "artifact_path",
        "artifact_sha256",
        "authorization_path",
        "authorization_sha256",
        "approval_attestation_path",
        "approval_attestation_sha256",
        "finalization_path",
        "finalization_sha256",
        "checkout_tree_sha",
        "source_sha",
        "validation_attestation_path",
        "validation_attestation_sha256",
    }
)
_BENCHMARK_FIELDS = frozenset(
    {"report_path", "report_sha256", "packages_root", "source_sha"}
)
_REVIEW_FIELDS = frozenset(
    {
        "review_id",
        "reviewer_class",
        "verdict",
        "verdicts",
        "dimensions",
        "base_sha",
        "head_sha",
        "commit_range",
        "artifact_path",
        "artifact_sha256",
        "review_attestation_path",
        "review_attestation_sha256",
        "critical_findings",
        "important_findings",
    }
)
_OWNER_FIELDS = frozenset(
    {
        "approved",
        "decision_id",
        "approval_date",
        "approved_scope",
        "delegated",
        "waived_checks",
        "request_path",
        "request_sha256",
        "approval_attestation_path",
        "approval_attestation_sha256",
    }
)
_ROLLBACK_FIELDS = frozenset(
    {"ref", "tag_object_sha", "commit_sha", "tree_sha", "restore_receipt_sha256"}
)
_PROTECTED_FIELDS = frozenset(
    {
        "authority_routing_cutover_only",
        "live_enforcement_proven",
        "post_merge_receipt_required",
    }
)
_VISUAL_FIELDS = frozenset(
    {
        "approval_attestation_path",
        "approval_attestation_sha256",
        "canon_revision",
        "claim_ceiling",
        "decision_receipt_path",
        "decision_receipt_sha256",
        "delegated",
        "evidence_kind",
        "figma_exports",
        "final_frame_ids",
        "gap_blocked_state_ids",
        "manifest_path",
        "manifest_sha256",
        "merged_visual_ledger_sha256",
        "review",
        "simulator_renders",
        "source_sha",
    }
)
_FIGMA_EXPORT_FIELDS = frozenset(
    {
        "accessibility_variants",
        "artifact_path",
        "artifact_sha256",
        "byte_size",
        "claim_ceiling",
        "evidence_kind",
        "figma_file_key",
        "figma_node_id",
        "frame_id",
        "frame_version",
        "journey_ids",
        "media_type",
        "merged_visual_ledger_sha256",
        "object_ids",
        "screen_ids",
        "state_ids",
        "visual_requirement_ids",
    }
)
_VISUAL_REVIEW_FIELDS = frozenset(
    {
        "artifact_path",
        "artifact_sha256",
        "base_sha",
        "head_sha",
        "commit_range",
        "attestation_path",
        "attestation_sha256",
    }
)
_SCREENSHOT_FIELDS = frozenset(
    {
        "frame_id",
        "artifact_path",
        "artifact_sha256",
        "media_type",
        "byte_size",
        "pixel_width",
        "pixel_height",
        "scale",
        "device",
        "os_version",
        "build_identity",
        "capture_kind",
        "source_sha",
        "source_tree_sha",
    }
)
_EVIDENCE_REGISTRY_FIELDS = frozenset({"path", "sha256", "base_sha"})
_VERIFIER_FIELDS = frozenset(
    {
        "path",
        "ref",
        "base_sha",
        "base_tree_sha",
        "blob_sha256",
        "check_identity",
        "integration_id",
    }
)


class GateBEvidenceError(ValueError):
    """Stable error for a malformed outer Gate B contract."""

    def __init__(self, code: str, message: str) -> None:
        super().__init__(f"{code}: {message}")
        self.code = code


class _EvidenceProblem(Exception):
    def __init__(self, code: str) -> None:
        super().__init__(code)
        self.code = code


def validate_gate_b_evidence_schema(
    value: object, *, repo_root: Path, expected_base_sha: str
) -> None:
    """Validate the complete checked-in Gate B schema with strict JSON types."""

    repo = _git_checkout(repo_root)
    try:
        if not _git_sha(expected_base_sha):
            raise GateBEvidenceError(
                "GATE_B_EXPECTED_BASE", "authenticated expected base is invalid"
            )
        schema_bytes = _git(
            repo,
            "show",
            f"{expected_base_sha}:docs/canon/schemas/gate-b-evidence.schema.json",
        )
        schema = json.loads(schema_bytes.decode("utf-8"))
        if not isinstance(schema, Mapping):
            raise ValueError
        _validate_json_schema(value, schema, root_schema=schema, location="$")
    except GateBEvidenceError:
        raise
    except (
        _EvidenceProblem,
        OSError,
        UnicodeError,
        json.JSONDecodeError,
        ValueError,
        KeyError,
        subprocess.CalledProcessError,
    ) as exc:
        raise GateBEvidenceError(
            "GATE_B_SCHEMA", "evidence does not match the base-owned schema"
        ) from exc


def _validate_json_schema(
    value: object,
    schema: Mapping[str, object],
    *,
    root_schema: Mapping[str, object],
    location: str,
) -> None:
    reference = schema.get("$ref")
    if reference is not None:
        if not isinstance(reference, str) or not reference.startswith("#/$defs/"):
            raise ValueError(f"unsupported schema reference at {location}")
        name = reference.removeprefix("#/$defs/")
        definitions = root_schema.get("$defs")
        if not isinstance(definitions, Mapping) or not isinstance(
            definitions.get(name), Mapping
        ):
            raise ValueError(f"unknown schema reference at {location}")
        _validate_json_schema(
            value,
            definitions[name],
            root_schema=root_schema,
            location=location,
        )
        return

    if "const" in schema and not _json_scalar_equal(value, schema["const"]):
        raise ValueError(f"const mismatch at {location}")
    expected_type = schema.get("type")
    if expected_type is not None and not _json_type_matches(value, expected_type):
        raise ValueError(f"type mismatch at {location}")

    if isinstance(value, Mapping):
        properties = schema.get("properties", {})
        if not isinstance(properties, Mapping):
            raise ValueError(f"invalid properties schema at {location}")
        required = schema.get("required", [])
        if not isinstance(required, list) or any(
            not isinstance(item, str) for item in required
        ):
            raise ValueError(f"invalid required schema at {location}")
        missing = set(required) - set(value)
        if missing:
            raise ValueError(f"missing property at {location}")
        if schema.get("additionalProperties") is False and set(value) - set(
            properties
        ):
            raise ValueError(f"unknown property at {location}")
        for key, item in value.items():
            child = properties.get(key)
            if isinstance(child, Mapping):
                _validate_json_schema(
                    item,
                    child,
                    root_schema=root_schema,
                    location=f"{location}.{key}",
                )
    elif isinstance(value, list):
        minimum = schema.get("minItems")
        if isinstance(minimum, bool) or (
            minimum is not None and not isinstance(minimum, int)
        ):
            raise ValueError(f"invalid minItems at {location}")
        if isinstance(minimum, int) and len(value) < minimum:
            raise ValueError(f"too few items at {location}")
        if schema.get("uniqueItems") is True:
            encoded = [canonical_json_bytes(item) for item in value]
            if len(set(encoded)) != len(encoded):
                raise ValueError(f"duplicate items at {location}")
        item_schema = schema.get("items")
        if isinstance(item_schema, Mapping):
            for index, item in enumerate(value):
                _validate_json_schema(
                    item,
                    item_schema,
                    root_schema=root_schema,
                    location=f"{location}[{index}]",
                )
    elif isinstance(value, str):
        minimum_length = schema.get("minLength")
        if isinstance(minimum_length, bool) or (
            minimum_length is not None and not isinstance(minimum_length, int)
        ):
            raise ValueError(f"invalid minLength at {location}")
        if isinstance(minimum_length, int) and len(value) < minimum_length:
            raise ValueError(f"string too short at {location}")
        pattern = schema.get("pattern")
        if pattern is not None and (
            not isinstance(pattern, str) or re.search(pattern, value) is None
        ):
            raise ValueError(f"pattern mismatch at {location}")
    elif isinstance(value, (int, float)) and not isinstance(value, bool):
        minimum = schema.get("minimum")
        if minimum is not None and (
            isinstance(minimum, bool)
            or not isinstance(minimum, (int, float))
            or value < minimum
        ):
            raise ValueError(f"minimum mismatch at {location}")


def _json_type_matches(value: object, expected: object) -> bool:
    if expected == "object":
        return isinstance(value, Mapping)
    if expected == "array":
        return isinstance(value, list)
    if expected == "string":
        return isinstance(value, str)
    if expected == "integer":
        return not isinstance(value, bool) and isinstance(value, int)
    if expected == "number":
        return not isinstance(value, bool) and isinstance(value, (int, float))
    if expected == "boolean":
        return isinstance(value, bool)
    if expected == "null":
        return value is None
    raise ValueError("unsupported JSON schema type")


def _json_scalar_equal(left: object, right: object) -> bool:
    if isinstance(left, bool) or isinstance(right, bool):
        return type(left) is type(right) and left == right
    if isinstance(left, (int, float)) or isinstance(right, (int, float)):
        return type(left) is type(right) and left == right
    return left == right


def _verify_verifier_binding(
    value: object, repo: Path, *, expected_base_sha: str
) -> dict[str, object]:
    if not _closed(value, _VERIFIER_FIELDS):
        raise _EvidenceProblem("GATE_B_VERIFIER_INVALID")
    if (
        value["path"] != "tools/ambitions_canon/cutover_readiness.py"
        or value["ref"] != "refs/heads/main"
        or value["check_identity"] != "gate-b-cutover-readiness"
        or value["integration_id"] != "isolated-base-checkout"
        or not _git_sha(value["base_sha"])
        or not _git_sha(value["base_tree_sha"])
        or not isinstance(value["blob_sha256"], str)
        or re.fullmatch(r"[0-9a-f]{64}", value["blob_sha256"]) is None
    ):
        raise _EvidenceProblem("GATE_B_VERIFIER_INVALID")
    base = str(value["base_sha"])
    path = str(value["path"])
    if (
        base != expected_base_sha
        or _git_text(repo, "cat-file", "-t", expected_base_sha) != "commit"
        or _git_text(repo, "rev-parse", f"{base}^{{tree}}")
        != value["base_tree_sha"]
    ):
        raise _EvidenceProblem("GATE_B_VERIFIER_INVALID")
    verifier_bytes = _git(repo, "show", f"{base}:{path}")
    if hashlib.sha256(verifier_bytes).hexdigest() != value["blob_sha256"]:
        raise _EvidenceProblem("GATE_B_VERIFIER_INVALID")
    return {
        "base_sha": base,
        "base_tree_sha": value["base_tree_sha"],
        "blob_sha256": value["blob_sha256"],
        "check_identity": value["check_identity"],
        "integration_id": value["integration_id"],
        "path": path,
    }


def _run_isolated_base_verifier(
    evidence_path: Path,
    *,
    repo: Path,
    artifact_root: Path,
    receipt: Mapping[str, object],
    expected_base_sha: str,
    authenticated_rollback: Mapping[str, object],
    authenticated_current_event: Mapping[str, object],
) -> dict[str, object]:
    with tempfile.TemporaryDirectory(prefix="ambitions-gate-b-verifier-") as directory:
        checkout = Path(directory) / "checkout"
        environment = _isolated_environment()
        try:
            _git(repo, "clone", "-q", "--no-hardlinks", str(repo), str(checkout))
        except subprocess.CalledProcessError:
            return _red_assessment(["GATE_B_VERIFIER_INVALID"])
        try:
            _git(checkout, "checkout", "-q", "--detach", str(receipt["base_sha"]))
        except subprocess.CalledProcessError:
            return _red_assessment(["GATE_B_VERIFIER_INVALID"])
        script = (
            "import json,os,sys;"
            "from pathlib import Path;"
            "sys.path.insert(0,os.environ['GATE_B_CHECKOUT']);"
            "from tools.ambitions_canon.cutover_readiness import _evaluate_gate_b_core;"
            "value=_evaluate_gate_b_core(Path(os.environ['GATE_B_EVIDENCE']),"
            "repo_root=Path(os.environ['GATE_B_SOURCE']),"
            "artifact_root=Path(os.environ['GATE_B_ARTIFACTS']),"
            "expected_base_sha=os.environ['GATE_B_EXPECTED_BASE'],"
            "authenticated_rollback=json.loads(os.environ['GATE_B_ROLLBACK']),"
            "authenticated_current_event=json.loads(os.environ['GATE_B_CURRENT_EVENT']));"
            "sys.stdout.write(json.dumps(value,sort_keys=True,separators=(',',':'))+'\\n')"
        )
        environment.update(
            {
                "GATE_B_ARTIFACTS": str(artifact_root.resolve(strict=True)),
                "GATE_B_CHECKOUT": str(checkout),
                "GATE_B_EVIDENCE": str(evidence_path.resolve(strict=True)),
                "GATE_B_EXPECTED_BASE": expected_base_sha,
                "GATE_B_CURRENT_EVENT": canonical_json_bytes(
                    authenticated_current_event
                ).decode("utf-8"),
                "GATE_B_ROLLBACK": canonical_json_bytes(
                    authenticated_rollback
                ).decode("utf-8"),
                "GATE_B_SOURCE": str(repo),
            }
        )
        try:
            completed = subprocess.run(
                [sys.executable, "-I", "-c", script],
                cwd=checkout,
                check=False,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                env=environment,
                timeout=_VERIFIER_SUBPROCESS_TIMEOUT_SECONDS,
            )
        except (OSError, subprocess.SubprocessError):
            return _red_assessment(["GATE_B_VERIFIER_EXECUTION"])
        if completed.returncode != 0:
            return _red_assessment(["GATE_B_VERIFIER_EXECUTION"])
        try:
            assessment = json.loads(completed.stdout.decode("utf-8"))
        except (UnicodeError, json.JSONDecodeError):
            return _red_assessment(["GATE_B_VERIFIER_EXECUTION"])
        if not isinstance(assessment, dict):
            return _red_assessment(["GATE_B_VERIFIER_EXECUTION"])
        return assessment


def _isolated_environment() -> dict[str, str]:
    allowed = ("SYSTEMROOT", "TMPDIR", "WINDIR")
    environment = {key: os.environ[key] for key in allowed if key in os.environ}
    environment.update(
        {
            "GIT_CONFIG_GLOBAL": "/dev/null",
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CONFIG_SYSTEM": "/dev/null",
            "GIT_TERMINAL_PROMPT": "0",
            "HOME": "/nonexistent",
            "LANG": "C",
            "LC_ALL": "C",
            "PATH": "/usr/bin:/bin:/usr/local/bin",
            "PYTHONDONTWRITEBYTECODE": "1",
            "PYTHONHASHSEED": "0",
            "TZ": "UTC",
        }
    )
    return environment


def evaluate_gate_b(
    evidence_path: Path,
    *,
    repo_root: Path,
    artifact_root: Path,
    expected_base_sha: str,
    authenticated_rollback: Mapping[str, object],
    authenticated_current_event: Mapping[str, object],
) -> dict[str, object]:
    """Execute the SHA-bound verifier from an isolated trusted-base checkout."""

    evidence = _read_primary_evidence(evidence_path, artifact_root)
    unknown = sorted(set(evidence) - _TOP_LEVEL_FIELDS)
    if unknown:
        raise GateBEvidenceError("GATE_B_FIELDS", f"unknown field: {unknown[0]}")
    if "visual_owner_approval" not in evidence:
        return _red_assessment(["GATE_B_VISUAL_OWNER_MISSING"])
    repo = _git_checkout(repo_root)
    validate_gate_b_evidence_schema(
        evidence, repo_root=repo, expected_base_sha=expected_base_sha
    )
    try:
        receipt = _verify_verifier_binding(
            evidence["verifier"], repo, expected_base_sha=expected_base_sha
        )
    except (
        _EvidenceProblem,
        KeyError,
        TypeError,
        ValueError,
        UnicodeError,
        subprocess.CalledProcessError,
    ):
        return _red_assessment(["GATE_B_VERIFIER_INVALID"])
    assessment = _run_isolated_base_verifier(
        evidence_path,
        repo=repo,
        artifact_root=artifact_root,
        receipt=receipt,
        expected_base_sha=expected_base_sha,
        authenticated_rollback=authenticated_rollback,
        authenticated_current_event=authenticated_current_event,
    )
    assessment["verifier_receipt"] = receipt
    return assessment


def _evaluate_gate_b_core(
    evidence_path: Path,
    *,
    repo_root: Path,
    artifact_root: Path,
    expected_base_sha: str,
    authenticated_rollback: Mapping[str, object],
    authenticated_current_event: Mapping[str, object],
) -> dict[str, object]:
    """Verify current Git, artifact bytes, approvals, reviews, and benchmark output."""

    evidence = _read_primary_evidence(evidence_path, artifact_root)
    repo = _git_checkout(repo_root)
    validate_gate_b_evidence_schema(
        evidence, repo_root=repo, expected_base_sha=expected_base_sha
    )
    unknown = sorted(set(evidence) - _TOP_LEVEL_FIELDS)
    if unknown:
        raise GateBEvidenceError("GATE_B_FIELDS", f"unknown field: {unknown[0]}")
    if "visual_owner_approval" not in evidence:
        return _red_assessment(["GATE_B_VISUAL_OWNER_MISSING"])
    if set(evidence) != _TOP_LEVEL_FIELDS:
        return _red_assessment(["GATE_B_FIELD_MISSING"])

    artifacts = artifact_root.resolve(strict=True)
    blockers: list[str] = []
    source_sha = _git_text(repo, "rev-parse", "HEAD")
    source_tree = _git_text(repo, "rev-parse", "HEAD^{tree}")
    if evidence["schema_version"] != 1:
        blockers.append("GATE_B_SCHEMA_VERSION")
    if evidence["expected_base_sha"] != expected_base_sha:
        blockers.append("GATE_B_EXPECTED_BASE")
    if not _text(evidence["evidence_revision"]):
        blockers.append("GATE_B_EVIDENCE_REVISION")
    if evidence["source_sha"] != source_sha or evidence["source_tree_sha"] != source_tree:
        blockers.append("GATE_B_SOURCE_STALE")
    if evidence["gate_b_requested_state"] != "green":
        blockers.append("GATE_B_NOT_REQUESTED_GREEN")
    if evidence["bootstrap_approval_ceiling"] != BOOTSTRAP_CLAIM_CEILING:
        blockers.append("GATE_B_CLAIM_CEILING")

    requirement_preflight = _preflight_requirement_ids(evidence["requirements"])
    if requirement_preflight:
        return _red_assessment(requirement_preflight)

    try:
        _preflight_task25_candidate_paths(
            repo,
            expected_base_sha=expected_base_sha,
            source_sha=source_sha,
            source_tree=source_tree,
        )
    except (
        AuthorizationError,
        KeyError,
        TypeError,
        ValueError,
        subprocess.CalledProcessError,
    ):
        return _red_assessment(["GATE_B_CANDIDATE_PATH_UNAUTHORIZED"])

    try:
        manifest_path = _repo_file(repo, evidence["canon_manifest_path"])
        manifest_bytes = _bounded_file_bytes(
            manifest_path, _MAX_PINNED_INPUT_BYTES
        )
        if manifest_bytes != _git(repo, "show", f"{source_sha}:{evidence['canon_manifest_path']}"):
            raise _EvidenceProblem("GATE_B_CANON_STALE")
        if hashlib.sha256(manifest_bytes).hexdigest() != evidence["canon_manifest_sha256"]:
            raise _EvidenceProblem("GATE_B_CANON_DIGEST")
        manifest = tomllib.loads(manifest_bytes.decode("utf-8"))
        revision = manifest.get("canon_revision")
        if (
            isinstance(revision, bool)
            or not isinstance(revision, int)
            or revision != evidence["canon_revision"]
        ):
            raise _EvidenceProblem("GATE_B_CANON_REVISION")
    except (OSError, UnicodeError, tomllib.TOMLDecodeError, _EvidenceProblem) as exc:
        blockers.append(exc.code if isinstance(exc, _EvidenceProblem) else "GATE_B_CANON_INVALID")

    if blockers:
        return _red_assessment(blockers)

    evidence_registry = _load_evidence_registry(
        evidence["evidence_registry"], repo, expected_base_sha, blockers
    )
    trust_anchors = _load_trust_anchors(repo, expected_base_sha, blockers)
    if blockers:
        return _red_assessment(blockers)

    requirement_event, requirement_plan = _prepare_requirements(
        evidence["requirements"],
        source_sha,
        source_tree,
        repo,
        artifacts,
        trust_anchors,
        evidence_registry,
        expected_base_sha,
        blockers,
    )
    if blockers or requirement_plan is None:
        return _red_assessment(blockers or ["GATE_B_REQUIREMENTS_INVALID"])

    current_event = _verify_current_event(
        authenticated_current_event, requirement_event, blockers
    )
    if blockers:
        return _red_assessment(blockers)

    _verify_rollback(
        evidence["rollback"],
        repo,
        blockers,
        expected_base_sha=expected_base_sha,
        authenticated_rollback=authenticated_rollback,
        source_sha=source_sha,
    )
    if blockers:
        return _red_assessment(blockers)

    _verify_protected(evidence["protected_boundary"], blockers)
    if blockers:
        return _red_assessment(blockers)

    seen_approval_nonces: set[str] = set()
    _verify_reviews(
        evidence["reviews"],
        source_sha,
        repo,
        artifacts,
        trust_anchors,
        evidence_registry,
        evidence["rollback"],
        expected_base_sha,
        current_event,
        seen_approval_nonces,
        blockers,
    )
    if blockers:
        return _red_assessment(blockers)

    _preflight_owner_artifacts(evidence["owner_decision"], artifacts, blockers)
    if blockers:
        return _red_assessment(blockers)
    _verify_owner(
        evidence["owner_decision"],
        evidence["reviews"],
        source_sha,
        repo,
        artifacts,
        trust_anchors,
        evidence["rollback"],
        expected_base_sha,
        current_event,
        seen_approval_nonces,
        blockers,
    )
    if blockers:
        return _red_assessment(blockers)

    _verify_visual_owner_v2(
        evidence["visual_owner_approval"],
        evidence["canon_revision"],
        source_sha,
        source_tree,
        repo,
        artifacts,
        trust_anchors,
        expected_base_sha,
        current_event,
        seen_approval_nonces,
        blockers,
    )
    if blockers:
        return _red_assessment(blockers)

    benchmark_plan = _prepare_benchmark(
        evidence["authorization_benchmark"],
        source_sha,
        repo,
        artifacts,
        expected_base_sha,
        blockers,
    )
    if blockers or benchmark_plan is None:
        return _red_assessment(blockers or ["GATE_B_BENCHMARK_MISMATCH"])

    with tempfile.TemporaryDirectory(prefix="ambitions-gate-b-source-") as directory:
        command_repo = Path(directory) / "checkout"
        verifier_repo = Path(directory) / "verifier"
        try:
            _git(
                repo,
                "clone",
                "-q",
                "--no-hardlinks",
                "--no-checkout",
                str(repo),
                str(command_repo),
            )
            _git(command_repo, "checkout", "-q", "--detach", source_sha)
            _git(
                repo,
                "clone",
                "-q",
                "--no-hardlinks",
                "--no-checkout",
                str(repo),
                str(verifier_repo),
            )
            _git(verifier_repo, "checkout", "-q", "--detach", expected_base_sha)
            if (
                _git_text(command_repo, "rev-parse", "HEAD") != source_sha
                or _git_text(command_repo, "rev-parse", "HEAD^{tree}")
                != source_tree
                or _git_text(command_repo, "status", "--porcelain=v1")
                or not _is_exact_clean_gate_b_source(
                    verifier_repo, expected_base_sha
                )
            ):
                raise subprocess.CalledProcessError(1, ["git", "checkout"])
            _execute_requirement_semantics(
                requirement_plan, command_repo, verifier_repo, blockers
            )
            if not blockers:
                _execute_benchmark(benchmark_plan, command_repo, blockers)
        except subprocess.CalledProcessError:
            blockers.append("GATE_B_SOURCE_STALE")
    if blockers:
        return _red_assessment(blockers)
    return {
        "schema_version": 1,
        "gate_b": "green",
        "task_26_authority_routing_cutover_authorized": True,
        "live_enforcement_proven": False,
        "post_merge_receipt_required": False,
        "claim_ceiling": BOOTSTRAP_CLAIM_CEILING,
        "blocking_codes": [],
    }


def _preflight_task25_candidate_paths(
    repo: Path, *, expected_base_sha: str, source_sha: str, source_tree: str
) -> dict[str, object]:
    """Authorize the inert candidate path set from exact expected-base policy bytes."""

    if (
        _git_text(repo, "rev-parse", f"{source_sha}^{{tree}}") != source_tree
        or _git_text(repo, "merge-base", expected_base_sha, source_sha)
        != expected_base_sha
    ):
        raise ValueError("candidate is not based on the expected verifier base")
    policy = load_base_policy(repo, expected_base_sha)
    rules = [
        rule
        for rule in policy.get("task_rules", [])
        if isinstance(rule, Mapping) and rule.get("task_id") == "TASK-25"
    ]
    if len(rules) != 1 or rules[0].get("task_types") != ["release"]:
        raise ValueError("expected-base Task 25 release rule is unavailable")
    authorized = set(rules[0].get("authorized_files", []))
    delta = canonical_tree_delta(repo, expected_base_sha, source_sha)
    changed: list[str] = []
    for record in delta["records"]:
        display = record.get("path_display_utf8")
        if not isinstance(display, str) or display not in authorized:
            raise ValueError("candidate path is outside expected-base Task 25 policy")
        if record.get("new_mode") not in {None, "100644"}:
            raise ValueError("candidate executable, symlink, or gitlink is forbidden")
        changed.append(display)
    return {
        "schema_version": 1,
        "expected_base_sha": expected_base_sha,
        "source_sha": source_sha,
        "source_tree_sha": source_tree,
        "changed_files": sorted(changed),
        "tree_delta_sha256": delta["digest"],
    }


def render_cutover_readiness(
    evidence_path: Path,
    *,
    repo_root: Path,
    artifact_root: Path,
    expected_base_sha: str,
    authenticated_rollback: Mapping[str, object],
    authenticated_current_event: Mapping[str, object],
) -> str:
    """Render a deterministic proof-bounded report from verified local evidence."""

    evidence = _read_primary_evidence(evidence_path, artifact_root)
    assessment = evaluate_gate_b(
        evidence_path,
        repo_root=repo_root,
        artifact_root=artifact_root,
        expected_base_sha=expected_base_sha,
        authenticated_rollback=authenticated_rollback,
        authenticated_current_event=authenticated_current_event,
    )
    lines = [
        "# Ambitions Canon Cutover Readiness",
        "",
        f"gate_b = {assessment['gate_b']}",
        "task_26_authority_routing_cutover_authorized = "
        + str(assessment["task_26_authority_routing_cutover_authorized"]).lower(),
        "live_enforcement_proven = false",
        "post_merge_protected_boundary_receipt_required = false",
        f"claim_ceiling = {assessment['claim_ceiling']}",
        "",
        "## Required evidence",
        "",
    ]
    requirements = evidence.get("requirements", [])
    if isinstance(requirements, list):
        for item in sorted(
            (item for item in requirements if isinstance(item, Mapping)),
            key=lambda item: str(item.get("requirement_id", "")),
        ):
            lines.append(
                f"- {item.get('requirement_id', 'invalid')}: {item.get('status', 'invalid')}"
            )
    lines.extend(["", "## Representative authorization scenarios", ""])
    lines.extend(f"- {scenario_id}: verified" for scenario_id in AUTHORIZATION_SCENARIO_IDS)
    lines.extend(["", "## Blocking codes", ""])
    lines.extend(
        (f"- {code}" for code in assessment["blocking_codes"])
        if assessment["blocking_codes"]
        else ["- none"]
    )
    lines.extend(
        [
            "",
            "This report is governance evidence only. It does not prove live required-CI "
            "enforcement, product implementation, Runtime, rendered-app Visual, "
            "Accessibility, Privacy, Device, TestFlight, App Store, or Release Green.",
        ]
    )
    return "\n".join(lines) + "\n"


def _preflight_requirement_ids(value: object) -> list[str]:
    if not isinstance(value, list):
        return ["GATE_B_REQUIREMENTS_INVALID"]
    identifiers = [
        item.get("requirement_id") if isinstance(item, Mapping) else None
        for item in value
    ]
    if any(not isinstance(item, str) for item in identifiers):
        return ["GATE_B_REQUIREMENT_INVALID"]
    if len(set(identifiers)) != len(identifiers):
        return ["GATE_B_REQUIREMENT_DUPLICATE"]
    observed = set(identifiers)
    blockers: list[str] = []
    if observed - set(GATE_B_REQUIRED_EVIDENCE_IDS):
        blockers.append("GATE_B_REQUIREMENT_UNKNOWN")
    if set(GATE_B_REQUIRED_EVIDENCE_IDS) - observed:
        blockers.append("GATE_B_REQUIREMENT_MISSING")
    return blockers


def _load_evidence_registry(
    value: object,
    repo: Path,
    expected_base_sha: str,
    blockers: list[str],
) -> Mapping[str, object] | None:
    try:
        if not _closed(value, _EVIDENCE_REGISTRY_FIELDS):
            raise _EvidenceProblem("GATE_B_EVIDENCE_REGISTRY")
        base = str(value["base_sha"])
        path = str(value["path"])
        if (
            path != "docs/canon/references/gate-b-evidence-registry.json"
            or not _git_sha(base)
            or base != expected_base_sha
        ):
            raise _EvidenceProblem("GATE_B_EVIDENCE_REGISTRY")
        raw = _git(repo, "show", f"{base}:{path}")
        if hashlib.sha256(raw).hexdigest() != value["sha256"]:
            raise _EvidenceProblem("GATE_B_EVIDENCE_REGISTRY")
        registry = json.loads(raw.decode("utf-8"))
        if (
            not isinstance(registry, Mapping)
            or set(registry)
            != {
                "schema_version",
                "registry_revision",
                "output_schemas",
                "payload_schema",
                "requirements",
                "independent_review",
            }
            or registry["schema_version"] != 1
            or not _text(registry["registry_revision"])
            or not isinstance(registry["output_schemas"], Mapping)
            or not isinstance(registry["payload_schema"], Mapping)
            or not isinstance(registry["requirements"], list)
            or not isinstance(registry["independent_review"], Mapping)
        ):
            raise _EvidenceProblem("GATE_B_EVIDENCE_REGISTRY")
        entries = registry["requirements"]
        if [item.get("evidence_id") for item in entries if isinstance(item, Mapping)] != list(
            GATE_B_REQUIRED_EVIDENCE_IDS
        ):
            raise _EvidenceProblem("GATE_B_EVIDENCE_REGISTRY")
        expected_bindings = [
            "command_argv_sha256",
            "expected_base_sha",
            "input_sha256",
            "merge_base_sha",
            "source_sha",
            "source_tree_sha",
        ]
        if any(
            not isinstance(item, Mapping)
            or set(item)
            != {
                "check_identity",
                "command_id",
                "evidence_id",
                "input_paths",
                "observation_kind",
                "output_schema",
                "required_bindings",
                "result_parser",
                "semantic",
            }
            or item.get("command_id") != f"gate-b-{item.get('evidence_id')}"
            or item.get("check_identity") != f"gate-b:{item.get('evidence_id')}"
            or item.get("output_schema")
            != f"gate-b-{item.get('evidence_id')}-envelope-v1"
            or not isinstance(item.get("semantic"), str)
            or not str(item.get("semantic")).strip()
            or not isinstance(item.get("observation_kind"), str)
            or not str(item.get("observation_kind")).strip()
            or item.get("observation_kind")
            != _DOMAIN_OBSERVATION_KINDS.get(str(item.get("evidence_id")))
            or not isinstance(item.get("input_paths"), list)
            or not item.get("input_paths")
            or any(not _text(path) for path in item.get("input_paths", []))
            or item.get("required_bindings") != expected_bindings
            or item.get("result_parser")
            != {
                "kind": "gate-b-substantive-observation-v1",
                "evidence_id": item.get("evidence_id"),
                "semantic": item.get("semantic"),
                "observation_kind": item.get("observation_kind"),
            }
            for item in entries
        ):
            raise _EvidenceProblem("GATE_B_EVIDENCE_REGISTRY")
        return registry
    except (
        _EvidenceProblem,
        KeyError,
        TypeError,
        ValueError,
        UnicodeError,
        json.JSONDecodeError,
        subprocess.CalledProcessError,
    ):
        blockers.append("GATE_B_EVIDENCE_REGISTRY")
        return None


def _preflight_requirement_trust(
    ordered_requirements: list[Mapping[str, object]],
    entries: Mapping[str, Mapping[str, object]],
    verified_artifacts: Mapping[
        str, tuple[Mapping[str, object], Mapping[str, object], str]
    ],
    source_sha: str,
    source_tree: str,
    repo: Path,
    artifacts: Path,
    trust_anchors: Mapping[str, object] | None,
    expected_base_sha: str,
    blockers: list[str],
) -> Mapping[str, object] | None:
    try:
        shared_contexts = {
            (
                item["authorization_path"],
                item["authorization_sha256"],
                item["approval_attestation_path"],
                item["approval_attestation_sha256"],
                item["finalization_path"],
                item["finalization_sha256"],
                item["checkout_tree_sha"],
            )
            for item in ordered_requirements
        }
        if len(shared_contexts) != 1:
            raise _EvidenceProblem("GATE_B_REQUIREMENT_CONTEXT_INVALID")
        (
            authorization_path,
            authorization_digest,
            approval_path,
            approval_digest,
            finalization_path,
            finalization_digest,
            _checkout_tree,
        ) = next(iter(shared_contexts))
        authorization = _artifact_json(
            artifacts,
            authorization_path,
            authorization_digest,
            "GATE_B_REQUIREMENT_CONTEXT",
        )
        approval = _artifact_json(
            artifacts,
            approval_path,
            approval_digest,
            "GATE_B_REQUIREMENT_CONTEXT",
        )
        if not isinstance(authorization, Mapping) or not isinstance(
            approval, Mapping
        ):
            raise _EvidenceProblem("GATE_B_REQUIREMENT_CONTEXT_INVALID")
        event = authorization["trusted_event_provenance"]
        intake = authorization["intake"]
        tree_delta = authorization.get("tree_delta")
        if (
            not isinstance(event, Mapping)
            or not isinstance(intake, Mapping)
            or event.get("trusted_head_sha") != source_sha
            or event.get("trusted_base_sha") != expected_base_sha
            or not isinstance(tree_delta, Mapping)
            or tree_delta.get("new_tree_sha") != source_tree
        ):
            raise _EvidenceProblem("GATE_B_REQUIREMENT_CONTEXT_INVALID")
        base = str(event["trusted_base_sha"])
        policy = load_base_policy(repo, base)
        bindings = load_trusted_bindings(repo, base, intake, policy)
        recomputed_authorization = task_start(
            repo_root=repo,
            mode="ci-pr-range",
            intake_data=intake,
            trusted_event_data=event,
            trusted_bindings=bindings,
            policy_data=policy,
            approval_attestations=(approval,),
            verification_epoch=int(event["verification_epoch"]),
        )
        if canonical_json_bytes(recomputed_authorization) != canonical_json_bytes(
            authorization
        ):
            raise _EvidenceProblem("GATE_B_REQUIREMENT_CONTEXT_INVALID")
    except (
        AuthorizationError,
        _EvidenceProblem,
        KeyError,
        TypeError,
        ValueError,
        subprocess.CalledProcessError,
    ) as exc:
        blockers.append(
            exc.code
            if isinstance(exc, _EvidenceProblem)
            else "GATE_B_REQUIREMENT_CONTEXT_INVALID"
        )
        return None

    for item in ordered_requirements:
        requirement_id = str(item["requirement_id"])
        entry = entries[requirement_id]
        argv_digest = verified_artifacts[requirement_id][2]
        if argv_digest != authorization.get("computed_command_digests", {}).get(
            entry.get("command_id")
        ):
            blockers.append("GATE_B_REQUIREMENT_REGISTRY")
            return event

    try:
        if trust_anchors is None:
            raise _EvidenceProblem("GATE_B_REQUIREMENT_ATTESTATION_INVALID")
        attestations: list[Mapping[str, object]] = []
        for item in ordered_requirements:
            requirement_id = str(item["requirement_id"])
            entry = entries[requirement_id]
            argv_digest = verified_artifacts[requirement_id][2]
            attestation = _artifact_json(
                artifacts,
                item["validation_attestation_path"],
                item["validation_attestation_sha256"],
                "GATE_B_REQUIREMENT_ATTESTATION",
            )
            if (
                not isinstance(attestation, Mapping)
                or attestation.get("artifact_digest") != item["artifact_sha256"]
                or attestation.get("command_id") != entry.get("command_id")
                or attestation.get("command_argv_digest") != argv_digest
            ):
                raise _EvidenceProblem("GATE_B_REQUIREMENT_ATTESTATION_INVALID")
            attestations.append(attestation)
        finalization = _artifact_json(
            artifacts,
            finalization_path,
            finalization_digest,
            "GATE_B_REQUIREMENT_CONTEXT",
        )
        if not isinstance(finalization, Mapping):
            raise _EvidenceProblem("GATE_B_REQUIREMENT_ATTESTATION_INVALID")
        recomputed_finalization = task_finalize(
            repo_root=repo,
            authorization=authorization,
            intake_data=intake,
            trusted_event_data=event,
            trusted_bindings=bindings,
            policy_data=policy,
            approval_attestations=(approval,),
            validation_attestations=tuple(attestations),
            verification_epoch=int(event["verification_epoch"]),
        )
        if canonical_json_bytes(recomputed_finalization) != canonical_json_bytes(
            finalization
        ):
            raise _EvidenceProblem("GATE_B_REQUIREMENT_ATTESTATION_INVALID")
    except (
        AuthorizationError,
        _EvidenceProblem,
        KeyError,
        TypeError,
        ValueError,
        UnicodeError,
        json.JSONDecodeError,
        subprocess.CalledProcessError,
    ):
        blockers.append("GATE_B_REQUIREMENT_ATTESTATION_INVALID")
    return event


def _prepare_requirements(
    value: object,
    source_sha: str,
    source_tree: str,
    repo: Path,
    artifacts: Path,
    trust_anchors: Mapping[str, object] | None,
    evidence_registry: Mapping[str, object] | None,
    expected_base_sha: str,
    blockers: list[str],
) -> tuple[Mapping[str, object] | None, Mapping[str, object] | None]:
    """Prepare canonical requirement inputs and trust without executing commands."""

    if not isinstance(value, list) or evidence_registry is None:
        blockers.append("GATE_B_REQUIREMENTS_INVALID")
        return None, None
    requirement_preflight = _preflight_requirement_ids(value)
    if requirement_preflight:
        blockers.append(requirement_preflight[0])
        return None, None
    requirements_by_id = {
        str(item["requirement_id"]): item
        for item in value
        if isinstance(item, Mapping)
    }
    ordered_requirements = [
        requirements_by_id[evidence_id]
        for evidence_id in GATE_B_REQUIRED_EVIDENCE_IDS
    ]
    entries = {
        str(item["evidence_id"]): item
        for item in evidence_registry["requirements"]
        if isinstance(item, Mapping) and isinstance(item.get("evidence_id"), str)
    }
    output_schemas = evidence_registry["output_schemas"]
    payload_schema = evidence_registry["payload_schema"]
    verified_artifacts: dict[
        str, tuple[Mapping[str, object], Mapping[str, object], str]
    ] = {}

    for item in ordered_requirements:
        if not _closed(item, _REQUIREMENT_FIELDS):
            blockers.append("GATE_B_REQUIREMENT_INVALID")
            return None, None
        requirement_id = str(item["requirement_id"])
        entry = entries.get(requirement_id)
        if (
            entry is None
            or item["status"] != "green"
            or item["source_sha"] != source_sha
            or item["checkout_tree_sha"] != source_tree
        ):
            blockers.append("GATE_B_REQUIREMENT_NOT_GREEN")
            return None, None
        try:
            artifact = _artifact_json(
                artifacts,
                item["artifact_path"],
                item["artifact_sha256"],
                "GATE_B_ARTIFACT",
            )
            schema = output_schemas.get(entry.get("output_schema"))
            if not isinstance(artifact, Mapping) or not isinstance(schema, Mapping):
                raise _EvidenceProblem("GATE_B_REQUIREMENT_REGISTRY")
            _validate_json_schema(
                artifact,
                schema,
                root_schema=schema,
                location="$.validation_envelope",
            )
            if artifact.get("command_id") != entry.get("command_id"):
                raise _EvidenceProblem("GATE_B_REQUIREMENT_REGISTRY")
            argv = artifact.get("argv")
            if (
                not isinstance(argv, list)
                or argv != _gate_b_command_argv(requirement_id)
            ):
                raise _EvidenceProblem("GATE_B_REQUIREMENT_REGISTRY")
            argv_digest = hashlib.sha256(canonical_json_bytes(argv)).hexdigest()
            stdout = _base64url_decode_strict(
                artifact.get("stdout_base64url"),
                "GATE_B_REQUIREMENT_REGISTRY",
            )
            _base64url_decode_strict(
                artifact.get("stderr_base64url"),
                "GATE_B_REQUIREMENT_REGISTRY",
                allow_empty=True,
            )
            try:
                payload = json.loads(stdout.decode("utf-8"))
            except (UnicodeError, json.JSONDecodeError) as exc:
                raise _EvidenceProblem("GATE_B_REQUIREMENT_REGISTRY") from exc
            if (
                not isinstance(payload, Mapping)
                or stdout != canonical_json_bytes(payload)
                or not isinstance(payload_schema, Mapping)
            ):
                raise _EvidenceProblem("GATE_B_REQUIREMENT_REGISTRY")
            _validate_json_schema(
                payload,
                payload_schema,
                root_schema=payload_schema,
                location="$.validation_payload",
            )
            if (
                entry.get("result_parser")
                != {
                    "kind": "gate-b-substantive-observation-v1",
                    "evidence_id": requirement_id,
                    "semantic": entry.get("semantic"),
                    "observation_kind": entry.get("observation_kind"),
                }
                or entry.get("required_bindings")
                != [
                    "command_argv_sha256",
                    "expected_base_sha",
                    "input_sha256",
                    "merge_base_sha",
                    "source_sha",
                    "source_tree_sha",
                ]
            ):
                raise _EvidenceProblem("GATE_B_REQUIREMENT_REGISTRY")
            verified_artifacts[requirement_id] = (artifact, payload, argv_digest)
        except _EvidenceProblem as exc:
            blockers.append(exc.code)
            return None, None
        except (KeyError, TypeError, ValueError):
            blockers.append("GATE_B_REQUIREMENT_REGISTRY")
            return None, None

    event = _preflight_requirement_trust(
        ordered_requirements,
        entries,
        verified_artifacts,
        source_sha,
        source_tree,
        repo,
        artifacts,
        trust_anchors,
        expected_base_sha,
        blockers,
    )
    if event is None or blockers:
        return event, None

    return event, {
        "entries": entries,
        "ordered_requirements": tuple(ordered_requirements),
        "source_sha": source_sha,
        "source_tree": source_tree,
        "verified_artifacts": verified_artifacts,
    }


def _execute_requirement_semantics(
    plan: Mapping[str, object],
    command_repo: Path,
    verifier_repo: Path,
    blockers: list[str],
) -> None:
    """Execute the prepared requirements once in canonical registry order."""

    ordered_requirements = plan.get("ordered_requirements")
    entries = plan.get("entries")
    verified_artifacts = plan.get("verified_artifacts")
    source_sha = plan.get("source_sha")
    source_tree = plan.get("source_tree")
    if (
        not isinstance(ordered_requirements, tuple)
        or not isinstance(entries, Mapping)
        or not isinstance(verified_artifacts, Mapping)
        or not isinstance(source_sha, str)
        or not isinstance(source_tree, str)
    ):
        blockers.append("GATE_B_REQUIREMENT_SEMANTICS")
        return

    for item in ordered_requirements:
        if not isinstance(item, Mapping):
            blockers.append("GATE_B_REQUIREMENT_SEMANTICS")
            break
        requirement_id = str(item["requirement_id"])
        try:
            entry = entries[requirement_id]
            prepared_artifact = verified_artifacts[requirement_id]
            if (
                not isinstance(entry, Mapping)
                or not isinstance(prepared_artifact, tuple)
                or len(prepared_artifact) != 3
            ):
                raise _EvidenceProblem("GATE_B_REQUIREMENT_SEMANTICS")
            artifact, payload, _argv_digest = prepared_artifact
            if not isinstance(artifact, Mapping) or not isinstance(payload, Mapping):
                raise _EvidenceProblem("GATE_B_REQUIREMENT_SEMANTICS")
            if canonical_json_bytes(artifact) != _execute_gate_b_command(
                command_repo, requirement_id, executable_repo=verifier_repo
            ):
                raise _EvidenceProblem("GATE_B_REQUIREMENT_SEMANTICS")
            expected_payload = _gate_b_substantive_payload(
                command_repo,
                source_sha=source_sha,
                source_tree=source_tree,
                entry=entry,
                executable_repo=verifier_repo,
            )
            if payload != expected_payload:
                raise _EvidenceProblem("GATE_B_REQUIREMENT_SEMANTICS")
        except _EvidenceProblem as exc:
            blockers.append(exc.code)
            break
        except (KeyError, TypeError, ValueError, subprocess.CalledProcessError):
            blockers.append("GATE_B_REQUIREMENT_SEMANTICS")
            break


def _verify_requirements(
    value: object,
    source_sha: str,
    source_tree: str,
    repo: Path,
    command_repo: Path,
    verifier_repo: Path,
    artifacts: Path,
    trust_anchors: Mapping[str, object] | None,
    evidence_registry: Mapping[str, object] | None,
    expected_base_sha: str,
    blockers: list[str],
) -> Mapping[str, object] | None:
    """Compatibility wrapper for focused requirement verification tests."""

    event, plan = _prepare_requirements(
        value,
        source_sha,
        source_tree,
        repo,
        artifacts,
        trust_anchors,
        evidence_registry,
        expected_base_sha,
        blockers,
    )
    if plan is not None and not blockers:
        _execute_requirement_semantics(plan, command_repo, verifier_repo, blockers)
    return event


def _verify_current_event(
    authenticated: object,
    requirement_event: Mapping[str, object] | None,
    blockers: list[str],
) -> Mapping[str, object] | None:
    if (
        not isinstance(authenticated, Mapping)
        or requirement_event is None
        or canonical_json_bytes(authenticated)
        != canonical_json_bytes(requirement_event)
        or authenticated.get("event_attestation_origin") != "trusted-ci"
        or authenticated.get("event_projection_digest")
        != trusted_event_projection_digest(authenticated)
    ):
        blockers.append("GATE_B_CURRENT_EVENT_INVALID")
        return None
    return authenticated


def _gate_b_substantive_payload(
    repo: Path,
    *,
    source_sha: str,
    source_tree: str,
    entry: Mapping[str, object],
    executable_repo: Path | None = None,
) -> dict[str, object]:
    paths = entry.get("input_paths")
    if not isinstance(paths, list) or not paths:
        raise _EvidenceProblem("GATE_B_REQUIREMENT_SEMANTICS")
    records: list[dict[str, object]] = []
    input_bytes: dict[str, bytes] = {}
    for path in paths:
        if not isinstance(path, str) or not path:
            raise _EvidenceProblem("GATE_B_REQUIREMENT_SEMANTICS")
        try:
            raw = _git(repo, "show", f"{source_sha}:{path}")
        except subprocess.CalledProcessError as exc:
            raise _EvidenceProblem("GATE_B_REQUIREMENT_SEMANTICS") from exc
        records.append(
            {
                "path": path,
                "byte_size": len(raw),
                "sha256": hashlib.sha256(raw).hexdigest(),
            }
        )
        input_bytes[path] = raw
    record_bytes = canonical_json_bytes(records)
    semantic = str(entry.get("semantic", ""))
    observation_kind = str(entry.get("observation_kind", ""))
    if _git_text(repo, "rev-parse", f"{source_sha}^{{tree}}") != source_tree:
        raise _EvidenceProblem("GATE_B_REQUIREMENT_SEMANTICS")
    with _detached_gate_b_source(repo, source_sha) as command_repo:
        facts = _gate_b_domain_facts(
            command_repo,
            executable_repo=executable_repo
            or Path(__file__).resolve().parents[2],
            source_sha=source_sha,
            observation_kind=observation_kind,
            input_bytes=input_bytes,
        )
    facts_bytes = canonical_json_bytes(facts)
    return {
        "schema_version": 1,
        "evidence_id": entry.get("evidence_id"),
        "check_identity": entry.get("check_identity"),
        "semantic": semantic,
        "source_sha": source_sha,
        "source_tree_sha": source_tree,
        "input_paths": paths,
        "input_sha256": hashlib.sha256(record_bytes).hexdigest(),
        "observation": {
            "kind": observation_kind,
            "subject_count": len(records),
            "subject_sha256": hashlib.sha256(
                observation_kind.encode("utf-8")
                + b"\0"
                + record_bytes
                + b"\0"
                + facts_bytes
            ).hexdigest(),
        },
        "validator_id": f"gate-b-domain-v1:python-3.12:{observation_kind}",
    }


@contextmanager
def _detached_gate_b_source(repo: Path, source_sha: str):
    """Expose only committed source bytes to base-owned domain validators."""

    if _is_exact_clean_gate_b_source(repo, source_sha):
        yield repo
        return
    with tempfile.TemporaryDirectory(prefix="ambitions-gate-b-domain-source-") as directory:
        checkout = Path(directory) / "checkout"
        try:
            _git(
                repo,
                "-c",
                "init.templateDir=",
                "clone",
                "-q",
                "--no-hardlinks",
                str(repo),
                str(checkout),
            )
            _git(checkout, "checkout", "-q", "--detach", source_sha)
            if (
                _git_text(checkout, "rev-parse", "HEAD") != source_sha
                or not _is_exact_clean_gate_b_source(checkout, source_sha)
            ):
                raise _EvidenceProblem("GATE_B_REQUIREMENT_SEMANTICS")
            yield checkout
        except (OSError, subprocess.CalledProcessError) as exc:
            raise _EvidenceProblem("GATE_B_REQUIREMENT_SEMANTICS") from exc


def _is_exact_clean_gate_b_source(repo: Path, source_sha: str) -> bool:
    """Prove a checkout is already safe for inert-data domain validation."""

    try:
        repo.resolve(strict=True)
        if repo.is_symlink():
            return False
        if (
            _git_text(repo, "rev-parse", "HEAD") != source_sha
            or _git_text(repo, "rev-parse", "HEAD^{tree}")
            != _git_text(repo, "rev-parse", f"{source_sha}^{{tree}}")
            or _git_text(repo, "status", "--porcelain=v1", "--untracked-files=all")
        ):
            return False
        index = _git(repo, "ls-files", "-s", "-z")
        for record in index.split(b"\0"):
            if record and record.split(b" ", 1)[0] in {b"120000", b"160000"}:
                return False
    except subprocess.CalledProcessError:
        return False
    try:
        _git(repo, "ls-files", "--error-unmatch", ".gitmodules")
    except subprocess.CalledProcessError:
        pass
    else:
        return False
    try:
        hooks = Path(_git_text(repo, "rev-parse", "--git-path", "hooks"))
        if not hooks.is_absolute():
            hooks = repo / hooks
        if hooks.is_dir() and any(
            item.is_file() and os.access(item, os.X_OK) for item in hooks.iterdir()
        ):
            return False
        _git(repo, "config", "--local", "--get-regexp", r"^core\.hooksPath$")
    except subprocess.CalledProcessError:
        return True
    return False


def _gate_b_command_argv(evidence_id: str) -> list[str]:
    if evidence_id not in _DOMAIN_OBSERVATION_KINDS:
        raise _EvidenceProblem("GATE_B_REQUIREMENT_REGISTRY")
    return [
        "python3",
        "-m",
        "tools.ambitions_canon.cutover_readiness",
        "validate-requirement",
        evidence_id,
    ]


def _execute_gate_b_command(
    repo: Path, evidence_id: str, *, executable_repo: Path | None = None
) -> bytes:
    argv = _gate_b_command_argv(evidence_id)
    if sys.version_info[:2] != _TRUSTED_PYTHON_VERSION:
        raise _EvidenceProblem("GATE_B_REQUIREMENT_SEMANTICS")
    try:
        source_sha = _git_text(repo, "rev-parse", "HEAD")
        source_tree = _git_text(repo, "rev-parse", "HEAD^{tree}")
        registry = json.loads(
            _git(
                repo,
                "show",
                f"{source_sha}:docs/canon/references/gate-b-evidence-registry.json",
            ).decode("utf-8")
        )
        entries = registry.get("requirements")
        if not isinstance(entries, list):
            raise ValueError
        entry = next(
            item
            for item in entries
            if isinstance(item, Mapping) and item.get("evidence_id") == evidence_id
        )
        if entry.get("observation_kind") != _DOMAIN_OBSERVATION_KINDS[evidence_id]:
            raise ValueError
        stdout = canonical_json_bytes(
            _gate_b_substantive_payload(
                repo,
                source_sha=source_sha,
                source_tree=source_tree,
                entry=entry,
                executable_repo=executable_repo,
            )
        )
    except (
        OSError,
        UnicodeError,
        ValueError,
        KeyError,
        TypeError,
        StopIteration,
        json.JSONDecodeError,
        subprocess.CalledProcessError,
    ) as exc:
        raise _EvidenceProblem("GATE_B_REQUIREMENT_SEMANTICS") from exc
    return canonical_json_bytes(
        {
            "schema_version": 1,
            "command_id": f"gate-b-{evidence_id}",
            "argv": argv,
            "exit_status": 0,
            "stdout_base64url": base64.urlsafe_b64encode(stdout)
            .rstrip(b"=")
            .decode("ascii"),
            "stderr_base64url": base64.urlsafe_b64encode(b"")
            .rstrip(b"=")
            .decode("ascii"),
        }
    )


def _validated_gate_b_canon_graph(repo: Path):
    """Load the exact audited canon graph through trusted compiler code."""

    from tools.ambitions_canon.build import _load_audited_registry

    registry = _load_audited_registry(repo)
    requirement_ids = {item.requirement_id for item in registry.requirements}
    document_ids = {item.spec_id for item in registry.documents}
    if (
        not requirement_ids
        or not document_ids
        or len(requirement_ids) != len(registry.requirements)
        or len(document_ids) != len(registry.documents)
    ):
        raise ValueError
    return registry


def _require_pinned_inputs(input_bytes: Mapping[str, bytes]) -> None:
    """Reject candidate replacements for executable proof modules as inert data."""

    pinned_root = Path(__file__).resolve().parents[2]
    for relative, raw in input_bytes.items():
        pinned = pinned_root / relative
        if (
            not pinned.is_file()
            or pinned.is_symlink()
            or len(raw) >= _MAX_PINNED_INPUT_BYTES
            or _bounded_file_bytes(pinned, _MAX_PINNED_INPUT_BYTES) != raw
        ):
            raise ValueError


def _run_pinned_unittest(
    input_bytes: Mapping[str, bytes], test_names: tuple[str, ...]
) -> dict[str, object]:
    """Run only verifier-owned tests from the immutable verifier checkout."""

    _require_pinned_inputs(input_bytes)
    if sys.version_info[:2] != _TRUSTED_PYTHON_VERSION:
        raise ValueError
    pinned_root = Path(__file__).resolve().parents[2]
    runner = (
        "import io,json,sys,unittest;"
        "root=sys.argv[1];names=json.loads(sys.argv[2]);"
        "sys.path.insert(0,root);"
        "suite=unittest.defaultTestLoader.loadTestsFromNames(names);"
        "result=unittest.TextTestRunner(stream=io.StringIO(),verbosity=0).run(suite);"
        "payload={'executed_test_count':result.testsRun,'python_version':"
        "f'{sys.version_info.major}.{sys.version_info.minor}','status':"
        "'green' if result.wasSuccessful() else 'red','test_ids':names};"
        "print(json.dumps(payload,sort_keys=True,separators=(',',':')));"
        "sys.exit(0 if result.wasSuccessful() and result.testsRun==len(names) else 1)"
    )
    completed = subprocess.run(
        [
            sys.executable,
            "-I",
            "-c",
            runner,
            str(pinned_root),
            json.dumps(list(test_names), separators=(",", ":")),
        ],
        cwd=pinned_root,
        env=_isolated_environment(),
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=_VERIFIER_SUBPROCESS_TIMEOUT_SECONDS,
    )
    if completed.returncode != 0:
        raise ValueError
    value = json.loads(completed.stdout.decode("utf-8"))
    if value != {
        "executed_test_count": len(test_names),
        "python_version": "3.12",
        "status": "green",
        "test_ids": list(test_names),
    }:
        raise ValueError
    return value


_LEGACY_REPLACEMENT_COMMANDS = {
    "audit": (["audit"], "GREEN ambitions canon audit ", "AUDIT"),
    "authority-sprawl": (
        ["authority-sprawl", "--check"],
        "GREEN authority sprawl ",
        "AUTHORITY-SPRAWL",
    ),
    "build-check": (
        ["build", "--check"],
        "GREEN ambitions canon generated outputs",
        "BUILD-CHECK",
    ),
    "p0-coverage": (
        ["coverage", "--fail-on-p0-gap"],
        "GREEN ambitions canon coverage ",
        "P0-COVERAGE",
    ),
    "traceability": (
        ["traceability", "--check"],
        "GREEN ambitions canon traceability ",
        "TRACEABILITY",
    ),
}


def _legacy_audit_invariants(raw: bytes) -> list[dict[str, object]]:
    try:
        source = raw.decode("utf-8")
        tree = ast.parse(source)
    except (UnicodeError, SyntaxError) as exc:
        raise _EvidenceProblem("GATE_B_LEGACY_AUDIT_PARITY") from exc
    nodes: list[tuple[ast.AST, str]] = []
    for node in ast.walk(tree):
        if isinstance(node, ast.Assert):
            nodes.append((node, "assert"))
        elif isinstance(node, ast.Raise):
            raised = node.exc
            is_assertion = (
                isinstance(raised, ast.Call)
                and isinstance(raised.func, ast.Name)
                and raised.func.id == "AssertionError"
            ) or (isinstance(raised, ast.Name) and raised.id == "AssertionError")
            if is_assertion:
                nodes.append((node, "raise-assertion"))
    nodes.sort(
        key=lambda item: (
            int(getattr(item[0], "lineno", 0)),
            int(getattr(item[0], "col_offset", 0)),
        )
    )
    invariants: list[dict[str, object]] = []
    for node, kind in nodes:
        segment = ast.get_source_segment(source, node)
        if not isinstance(segment, str) or not segment.strip():
            raise _EvidenceProblem("GATE_B_LEGACY_AUDIT_PARITY")
        node_sha256 = hashlib.sha256(segment.encode("utf-8")).hexdigest()
        invariants.append(
            {
                "legacy_invariant_id": (
                    f"OLD-AUDIT-{node.lineno:03d}-{node_sha256[:12].upper()}"
                ),
                "source_line": node.lineno,
                "source_node_kind": kind,
                "source_node_sha256": node_sha256,
            }
        )
    return invariants


def _validate_legacy_audit_parity(
    input_bytes: Mapping[str, bytes],
) -> tuple[int, list[str]]:
    parity_path = "docs/canon/references/legacy-audit-invariant-parity.json"
    audit_path = "scripts/ambitions-constitution-audit.py"
    if set(input_bytes) != {parity_path, audit_path}:
        raise _EvidenceProblem("GATE_B_LEGACY_AUDIT_PARITY")
    try:
        parity = json.loads(input_bytes[parity_path].decode("utf-8"))
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise _EvidenceProblem("GATE_B_LEGACY_AUDIT_PARITY") from exc
    if (
        not isinstance(parity, Mapping)
        or set(parity)
        != {
            "invariants",
            "legacy_audit",
            "registry_revision",
            "replacement_commands",
            "schema_version",
        }
        or parity.get("schema_version") != 1
        or not _text(parity.get("registry_revision"))
        or parity.get("legacy_audit")
        != {
            "path": audit_path,
            "sha256": hashlib.sha256(input_bytes[audit_path]).hexdigest(),
        }
    ):
        raise _EvidenceProblem("GATE_B_LEGACY_AUDIT_PARITY")
    commands = parity.get("replacement_commands")
    command_ids = (
        [
            item.get("command_id") if isinstance(item, Mapping) else None
            for item in commands
        ]
        if isinstance(commands, list)
        else []
    )
    if (
        command_ids != sorted(_LEGACY_REPLACEMENT_COMMANDS)
        or any(
            not isinstance(item, Mapping)
            or set(item)
            != {
                "argv",
                "command_id",
                "green_stdout_prefix",
                "invariant_id_prefix",
                "parser_id",
                "required_exit_status",
            }
            or item.get("parser_id")
            != f"ambitions-canon-{item.get('command_id')}-v1"
            and not (
                item.get("command_id") == "authority-sprawl"
                and item.get("parser_id") == "ambitions-authority-sprawl-v1"
            )
            or item.get("argv")
            != _LEGACY_REPLACEMENT_COMMANDS.get(str(item.get("command_id")), (None,))[0]
            or item.get("green_stdout_prefix")
            != _LEGACY_REPLACEMENT_COMMANDS.get(str(item.get("command_id")), (None, None))[1]
            or item.get("invariant_id_prefix")
            != _LEGACY_REPLACEMENT_COMMANDS.get(
                str(item.get("command_id")), (None, None, None)
            )[2]
            or item.get("required_exit_status") != 0
            for item in commands or []
        )
    ):
        raise _EvidenceProblem("GATE_B_LEGACY_AUDIT_PARITY")
    expected = _legacy_audit_invariants(input_bytes[audit_path])
    mappings = parity.get("invariants")
    if not isinstance(mappings, list) or len(mappings) != len(expected):
        raise _EvidenceProblem("GATE_B_LEGACY_AUDIT_PARITY")
    expected_by_id = {item["legacy_invariant_id"]: item for item in expected}
    seen: set[str] = set()
    for mapping in mappings:
        if (
            not isinstance(mapping, Mapping)
            or set(mapping)
            != {
                "coverage_strength",
                "legacy_invariant_id",
                "replacement_command_id",
                "replacement_invariant_id",
                "source_line",
                "source_node_kind",
                "source_node_sha256",
            }
        ):
            raise _EvidenceProblem("GATE_B_LEGACY_AUDIT_PARITY")
        identifier = mapping.get("legacy_invariant_id")
        expected_item = expected_by_id.get(identifier)
        if (
            not isinstance(identifier, str)
            or identifier in seen
            or expected_item is None
            or mapping.get("coverage_strength") != "equivalent-or-stronger"
            or mapping.get("replacement_command_id") not in command_ids
            or mapping.get("replacement_invariant_id")
            != (
                f"{_LEGACY_REPLACEMENT_COMMANDS[str(mapping.get('replacement_command_id'))][2]}-"
                f"{expected_item['source_line']:03d}"
            )
            or any(
                mapping.get(field) != expected_item[field]
                for field in (
                    "source_line",
                    "source_node_kind",
                    "source_node_sha256",
                )
            )
        ):
            raise _EvidenceProblem("GATE_B_LEGACY_AUDIT_PARITY")
        seen.add(identifier)
    if seen != set(expected_by_id):
        raise _EvidenceProblem("GATE_B_LEGACY_AUDIT_PARITY")
    return len(expected), [str(item) for item in command_ids]


def _run_legacy_replacement_commands(
    repo: Path, command_ids: list[str]
) -> dict[str, str]:
    results: dict[str, str] = {}
    for command_id in command_ids:
        argv, prefix, _invariant_prefix = _LEGACY_REPLACEMENT_COMMANDS[command_id]
        try:
            completed = subprocess.run(
                [sys.executable, "scripts/ambitions-canon.py", *argv],
                cwd=repo,
                env=_isolated_environment(),
                check=False,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=_VERIFIER_SUBPROCESS_TIMEOUT_SECONDS,
            )
            stdout = completed.stdout.decode("utf-8")
        except (
            OSError,
            UnicodeError,
            subprocess.SubprocessError,
        ) as exc:
            raise _EvidenceProblem("GATE_B_LEGACY_COMMAND_RESULT") from exc
        if completed.returncode != 0 or not stdout.startswith(prefix):
            raise _EvidenceProblem("GATE_B_LEGACY_COMMAND_RESULT")
        results[command_id] = "green"
    return results


def _run_base_owned_legacy_audit(repo: Path) -> str:
    try:
        completed = subprocess.run(
            [sys.executable, "scripts/ambitions-constitution-audit.py"],
            cwd=repo,
            env=_isolated_environment(),
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=_VERIFIER_SUBPROCESS_TIMEOUT_SECONDS,
        )
        stdout = completed.stdout.decode("utf-8")
    except (OSError, UnicodeError, subprocess.SubprocessError) as exc:
        raise _EvidenceProblem("GATE_B_LEGACY_COMMAND_RESULT") from exc
    if (
        completed.returncode != 0
        or not stdout.startswith("GREEN ambitions constitutional registry audit\n")
    ):
        raise _EvidenceProblem("GATE_B_LEGACY_COMMAND_RESULT")
    return "green"


def _gate_b_domain_facts(
    repo: Path,
    *,
    executable_repo: Path,
    source_sha: str,
    observation_kind: str,
    input_bytes: Mapping[str, bytes],
) -> dict[str, object]:
    """Validate one evidence domain and return its deterministic observed facts."""

    try:
        if observation_kind == "authority-disposition-corpus":
            from tools.ambitions_canon.migration import (
                validate_compact_semantic_loss_review,
                validate_tracked_canon_evidence,
            )

            expected_paths = {
                "docs/canon/migration/source-catalog.json",
                "docs/canon/migration/claim-dispositions.json",
                "docs/canon/migration/conflict-docket-baseline.json",
                "docs/canon/migration/semantic-equivalence-sets.json",
                "docs/canon/migration/semantic-loss-review.json",
            }
            if set(input_bytes) != expected_paths:
                raise ValueError
            snapshot = validate_tracked_canon_evidence(repo)
            if snapshot is None:
                raise ValueError
            expected_bytes = {
                "docs/canon/migration/source-catalog.json": snapshot.source_catalog_bytes,
                "docs/canon/migration/claim-dispositions.json": snapshot.claim_dispositions_bytes,
                "docs/canon/migration/conflict-docket-baseline.json": snapshot.conflict_baseline_bytes,
                "docs/canon/migration/semantic-equivalence-sets.json": (
                    _bounded_file_bytes(
                        repo / "docs/canon/migration/semantic-equivalence-sets.json",
                        _MAX_PINNED_INPUT_BYTES,
                    )
                ),
                "docs/canon/migration/semantic-loss-review.json": (
                    _bounded_file_bytes(
                        repo / "docs/canon/migration/semantic-loss-review.json",
                        _MAX_PINNED_INPUT_BYTES,
                    )
                ),
            }
            if dict(input_bytes) != expected_bytes:
                raise ValueError
            value = json.loads(snapshot.claim_dispositions_bytes.decode("utf-8"))
            claims = value["claims"]
            registry = _validated_gate_b_canon_graph(repo)
            semantic_review = validate_compact_semantic_loss_review(repo, registry)
            if (
                snapshot.claim_count != len(claims)
                or semantic_review.claim_count != snapshot.claim_count
                or semantic_review.review_status != "independently_reviewed"
                or any(
                    semantic_review.classification_counts[name] != 0
                    for name in ("duplicated", "missing", "weakened")
                )
            ):
                raise ValueError
            return {
                "claim_count": snapshot.claim_count,
                "uncovered_count": 0,
                "target_count": len(
                    {
                        str(item["target_id"])
                        for item in claims
                        if item.get("target_id") is not None
                    }
                ),
            }
        if observation_kind == "authorization-scenario-policy":
            value = _single_json_input(input_bytes)
            scenarios = value.get("scenarios")
            identifiers = [
                item.get("scenario_id") if isinstance(item, Mapping) else None
                for item in scenarios
            ] if isinstance(scenarios, list) else []
            if (
                value.get("schema_version") != 1
                or identifiers != list(AUTHORIZATION_SCENARIO_IDS)
                or any(
                    not isinstance(item, Mapping)
                    or not isinstance(item.get("authorized_files"), list)
                    or not item.get("authorized_files")
                    or not isinstance(item.get("required_checks"), list)
                    or len(item.get("required_checks", [])) != 1
                    or not isinstance(item.get("proof_obligations"), list)
                    or not item.get("proof_obligations")
                    or not isinstance(item.get("approval_required"), bool)
                    for item in scenarios
                )
            ):
                raise ValueError
            return {
                "scenario_ids": identifiers,
                "approval_required_count": sum(
                    bool(item["approval_required"]) for item in scenarios
                ),
            }
        if observation_kind == "canon-manifest-tree-input":
            _prove_tree_delta_behavior()
            raw = next(iter(input_bytes.values()))
            manifest = tomllib.loads(raw.decode("utf-8"))
            if (
                manifest.get("schema_version") != 1
                or not isinstance(manifest.get("normative_files"), list)
                or not manifest["normative_files"]
            ):
                raise ValueError
            return {
                "old_tree_diff_proven": True,
                "record_statuses": ["added", "deleted", "modified"],
            }
        if observation_kind == "external-reference-impact":
            from tools.ambitions_canon.external_authority import (
                external_reference_findings,
                load_external_reference_snapshot,
                validate_external_reference_snapshot,
            )

            registry = _validated_gate_b_canon_graph(repo)
            snapshot = load_external_reference_snapshot(repo)
            findings = external_reference_findings(
                registry, snapshot.references, repo
            )
            validate_external_reference_snapshot(repo, snapshot)
            if findings:
                raise ValueError
            text_value = _single_text_input(input_bytes)
            invalid = _markdown_integer(text_value, "Invalid external findings")
            stable = _markdown_integer(text_value, "Stable references")
            if invalid != 0 or stable <= 0 or "**Representation status:** Represented" not in text_value:
                raise ValueError
            return {"invalid_findings": invalid, "stable_reference_count": stable}
        if observation_kind == "generated-index-output":
            from tools.ambitions_canon.build import build_canon

            registry = _validated_gate_b_canon_graph(repo)
            expected_paths = [
                f"docs/canon/{path.as_posix()}"
                for path in registry.manifest.generated_files
            ]
            if list(input_bytes) != expected_paths or len(expected_paths) != 14:
                raise ValueError
            if build_canon(repo, check=True):
                raise ValueError
            for relative, raw in input_bytes.items():
                if _bounded_file_bytes(
                    repo / relative, _MAX_PINNED_INPUT_BYTES
                ) != raw:
                    raise ValueError
            return {
                "specification_row_count": len(registry.documents),
                "requirement_row_count": len(registry.requirements),
            }
        if observation_kind == "ci-regeneration-test":
            result = _run_pinned_unittest(
                input_bytes,
                (
                    "tests.canon.test_authorization_benchmark.AuthorizationBenchmarkTests.test_eight_scenarios_project_from_independent_policy_and_real_task_packs",
                ),
            )
            text_value = _single_text_input(input_bytes)
            required = (
                "test_all_eight_scenarios_run_start_resume_finalize_and_negatives",
                "canonical_benchmark_bytes(first)",
                "canonical_benchmark_bytes(second)",
            )
            if any(token not in text_value for token in required):
                raise ValueError
            return {
                "fresh_run_count": 2,
                "exact_byte_comparison": True,
                "pinned_test_count": result["executed_test_count"],
            }
        if observation_kind == "conflict-docket-projection":
            from tools.ambitions_canon.conflicts import report_conflicts

            exit_status, _report = report_conflicts(repo, require_resolved=True)
            if exit_status != 0:
                raise ValueError
            text_value = _single_text_input(input_bytes)
            open_dockets = _markdown_integer(text_value, "Open dockets")
            if open_dockets != 0:
                raise ValueError
            return {"open_docket_count": open_dockets}
        if observation_kind == "specification-coverage-projection":
            from tools.ambitions_canon.coverage import coverage_findings, load_profiles

            registry = _validated_gate_b_canon_graph(repo)
            profiles = load_profiles(
                repo / "docs/canon/schemas/completeness-profiles.toml"
            )
            p0_findings = tuple(
                finding
                for finding in coverage_findings(registry, profiles)
                if finding.severity is GapSeverity.P0_BLOCKER
            )
            if p0_findings:
                raise ValueError
            text_value = _single_text_input(input_bytes)
            rows = re.findall(r"^\| `([^`]+)` \| ([^|]+) \| (\d+) \|$", text_value, re.MULTILINE)
            if not rows or any(int(markers) == 0 and identifier != "CONSTITUTION" for identifier, _profile, markers in rows):
                raise ValueError
            return {"specification_count": len(rows), "incomplete_profile_count": 0}
        if observation_kind == "legacy-audit-parity":
            legacy_path = "scripts/ambitions-constitution-audit.py"
            if input_bytes.get(legacy_path) != _bounded_file_bytes(
                executable_repo / legacy_path, _MAX_PINNED_INPUT_BYTES
            ):
                raise ValueError
            invariant_count, command_ids = _validate_legacy_audit_parity(
                input_bytes
            )
            old_audit_result = _run_base_owned_legacy_audit(executable_repo)
            command_results = _run_legacy_replacement_commands(
                executable_repo, command_ids
            )
            return {
                "invariant_count": invariant_count,
                "old_audit_result": old_audit_result,
                "replacement_command_results": command_results,
            }
        if observation_kind == "request-only-intake-schema":
            value = _single_json_input(input_bytes)
            properties = value.get("properties")
            forbidden = {
                "approval",
                "authorized_files",
                "validation_results",
                "proof_claims",
                "break_glass",
                "merge_permission",
            }
            if (
                value.get("additionalProperties") is not False
                or not isinstance(properties, Mapping)
                or set(properties) & forbidden
                or set(value.get("required", [])) != set(properties)
            ):
                raise ValueError
            return {
                "request_field_count": len(properties),
                "authority_field_count": 0,
            }
        if observation_kind == "rollback-report-input":
            text_value = _single_text_input(input_bytes)
            if (
                "Gate B: Red" not in text_value
                or "rollback" not in text_value.lower()
                or "non-authoritative" not in text_value
            ):
                raise ValueError
            return {"gate_b_posture": "red", "authority_state": "non-authoritative"}
        if observation_kind == "concept-owner-projection":
            value = _single_json_input(input_bytes)
            registry = _validated_gate_b_canon_graph(repo)
            concepts = value.get("concepts")
            expected = [
                {"concept": concept, "spec_id": spec_id}
                for concept, spec_id in sorted(registry.concept_owners)
            ]
            document_ids = {item.spec_id for item in registry.documents}
            if (
                concepts != expected
                or any(item["spec_id"] not in document_ids for item in expected)
            ):
                raise ValueError
            return {"concept_count": len(expected), "duplicate_owner_count": 0}
        if observation_kind == "skill-dependency-registry":
            from tools.ambitions_canon import __version__
            from tools.ambitions_canon.skill_conformance import (
                check_skill_conformance,
            )

            value = _single_json_input(input_bytes)
            result = check_skill_conformance(
                repo,
                value,
                compiler_version=__version__,
            )
            skills = value["skills"]
            dependency_count = sum(
                len(skill["dependencies"])
                for skill in skills
                if isinstance(skill, Mapping)
            )
            return {
                "skill_count": len(result["skill_ids"]),
                "fresh_dependency_count": dependency_count,
                "registry_digest": result["registry_digest"],
            }
        if observation_kind == "stale-input-negative-test":
            result = _run_pinned_unittest(
                input_bytes,
                (
                    "tests.canon.test_authorization.StartFinalizeTests.test_finalize_rejects_stale_bindings_and_exact_delta_drift",
                    "tests.canon.test_authorization.StartFinalizeTests.test_attestation_validation_fails_closed_for_revocation_reuse_and_expiry",
                ),
            )
            text_value = _single_text_input(input_bytes)
            required = (
                "AUTH_EVENT_STALE",
                "AUTH_INTAKE",
                "AUTH_APPROVAL_REUSED",
            )
            if any(token not in text_value for token in required):
                raise ValueError
            return {
                "negative_contract_count": len(required),
                "pinned_test_count": result["executed_test_count"],
            }
        if observation_kind == "task-pack-representative-test":
            result = _run_pinned_unittest(
                input_bytes,
                (
                    "tests.canon.test_task_pack.TaskPackTests.test_pack_contains_every_approved_consumption_field",
                    "tests.canon.test_task_pack.TaskPackTests.test_stale_canon_repository_and_intake_sha_fail_independently",
                ),
            )
            text_value = _single_text_input(input_bytes)
            test_count = len(re.findall(r"^\s+def test_", text_value, re.MULTILINE))
            if test_count < 1 or "build_task_pack" not in text_value or "stale" not in text_value.lower():
                raise ValueError
            return {
                "task_pack_test_count": test_count,
                "stale_pack_proof_present": True,
                "pinned_test_count": result["executed_test_count"],
            }
        if observation_kind == "trust-anchor-registry":
            policy = _single_json_input(input_bytes)
            if set(policy) != {
                "approval_nonce_state",
                "approval_policies",
                "approval_trust_anchor_id",
                "compiler_version",
                "event_trust_anchor_id",
                "issue_state",
                "policy_revision",
                "repository_identity",
                "schema_revision",
                "schema_version",
                "snapshot_paths",
                "task_rules",
                "trust_anchors",
                "validation_trust_anchor_id",
            }:
                raise ValueError
            value = policy.get("trust_anchors")
            if not isinstance(value, Mapping):
                raise ValueError
            anchors = value.get("anchors")
            if not isinstance(anchors, list) or not anchors:
                raise ValueError
            identifiers = [
                item.get("anchor_id") if isinstance(item, Mapping) else None
                for item in anchors
            ]
            purposes = {
                purpose
                for item in anchors
                if isinstance(item, Mapping)
                for purpose in item.get("purposes", [])
                if isinstance(purpose, str)
            }
            repository_identity = value.get("repository_identity")
            if (
                value.get("schema_version") != 1
                or not _text(value.get("registry_revision"))
                or not isinstance(repository_identity, Mapping)
                or not _text(repository_identity.get("repository_id"))
                or not _text(repository_identity.get("repository_full_name"))
                or any(not _text(identifier) for identifier in identifiers)
                or len(identifiers) != len(set(identifiers))
                or any(
                    not isinstance(item, Mapping)
                    or item.get("algorithm") != "rsa-pkcs1v15-sha256"
                    or not isinstance(item.get("purposes"), list)
                    or not item["purposes"]
                    or any(
                        purpose not in {"approval", "event", "validation"}
                        for purpose in item["purposes"]
                    )
                    or not _text(item.get("modulus_hex"))
                    or item.get("public_exponent") != 65537
                    for item in anchors
                )
                or not {"approval", "event", "validation"} <= purposes
            ):
                raise ValueError
            return {"anchor_count": len(anchors), "purposes": sorted(purposes)}
        if observation_kind == "requirement-graph-projection":
            from tools.ambitions_canon.graph import document_edges, requirement_edges

            value = _single_json_input(input_bytes)
            registry = _validated_gate_b_canon_graph(repo)
            identifiers = sorted(
                item.requirement_id for item in registry.requirements
            )
            expected_requirement_edges = [
                {"from": source, "to": destination}
                for source, destination in requirement_edges(registry)
            ]
            expected_document_edges = [
                {"from": source, "to": destination}
                for source, destination in document_edges(registry)
            ]
            if (
                value.get("requirement_ids") != identifiers
                or value.get("requirement_edges") != expected_requirement_edges
                or value.get("document_edges") != expected_document_edges
            ):
                raise ValueError
            return {
                "requirement_count": len(identifiers),
                "edge_count": len(expected_requirement_edges),
                "document_edge_count": len(expected_document_edges),
            }
        if observation_kind == "visual-ledger-completeness":
            completeness = _derive_visual_completeness_from_bytes(input_bytes)
            if completeness["gap_blocked_state_ids"]:
                raise ValueError
            return {
                "accessibility_variant_count": len(
                    completeness["accessibility_variants"]
                ),
                "journey_count": len(completeness["journey_ids"]),
                "merged_visual_ledger_sha256": completeness[
                    "merged_visual_ledger_sha256"
                ],
                "object_count": len(completeness["object_ids"]),
                "review_dimension_count": len(
                    completeness["required_review_dimensions"]
                ),
                "screen_count": len(completeness["screen_ids"]),
                "state_count": len(completeness["state_ids"]),
                "visual_requirement_count": len(
                    completeness["visual_requirement_ids"]
                ),
            }
    except (
        _EvidenceProblem,
        OSError,
        UnicodeError,
        ValueError,
        KeyError,
        TypeError,
        json.JSONDecodeError,
        tomllib.TOMLDecodeError,
        subprocess.CalledProcessError,
        CanonError,
    ) as exc:
        raise _EvidenceProblem("GATE_B_REQUIREMENT_SEMANTICS") from exc
    raise _EvidenceProblem("GATE_B_REQUIREMENT_SEMANTICS")


def _single_json_input(input_bytes: Mapping[str, bytes]) -> Mapping[str, object]:
    if len(input_bytes) != 1:
        raise ValueError
    value = json.loads(next(iter(input_bytes.values())).decode("utf-8"))
    if not isinstance(value, Mapping):
        raise ValueError
    return value


def _single_text_input(input_bytes: Mapping[str, bytes]) -> str:
    if len(input_bytes) != 1:
        raise ValueError
    return next(iter(input_bytes.values())).decode("utf-8")


def _markdown_integer(text_value: str, label: str) -> int:
    match = re.search(rf"^- {re.escape(label)}: `([0-9]+)`$", text_value, re.MULTILINE)
    if match is None:
        raise ValueError
    return int(match.group(1))


def _prove_tree_delta_behavior() -> None:
    with tempfile.TemporaryDirectory(prefix="ambitions-gate-b-tree-domain-") as directory:
        repo = Path(directory)
        _git(repo, "init", "-q")
        _git(repo, "config", "user.name", "Gate B Domain")
        _git(repo, "config", "user.email", "gate-b-domain@example.invalid")
        (repo / "deleted.txt").write_bytes(b"delete\n")
        (repo / "modified.txt").write_bytes(b"before\n")
        _git(repo, "add", "-A")
        _git(repo, "commit", "-qm", "domain base")
        base = _git_text(repo, "rev-parse", "HEAD")
        (repo / "deleted.txt").unlink()
        (repo / "modified.txt").write_bytes(b"after\n")
        (repo / "added.txt").write_bytes(b"add\n")
        _git(repo, "add", "-A")
        _git(repo, "commit", "-qm", "domain head")
        head = _git_text(repo, "rev-parse", "HEAD")
        delta = canonical_tree_delta(repo, base, head)
        statuses = sorted(str(item["status"]) for item in delta["records"])
        if statuses != ["added", "deleted", "modified"]:
            raise ValueError


def _verify_reviews(
    value: object,
    source_sha: str,
    repo: Path,
    artifacts: Path,
    trust_anchors: Mapping[str, object] | None,
    evidence_registry: Mapping[str, object] | None,
    rollback: object,
    expected_base_sha: str,
    current_event: Mapping[str, object] | None,
    seen_approval_nonces: set[str],
    blockers: list[str],
) -> None:
    if not isinstance(value, list) or not value or evidence_registry is None:
        blockers.append("GATE_B_REVIEW_MISSING")
        return
    review_contract = evidence_registry.get("independent_review")
    if not isinstance(review_contract, Mapping):
        blockers.append("GATE_B_REVIEW_INVALID")
        return
    required_dimensions = review_contract.get("required_dimensions")
    required_verdicts = review_contract.get("required_verdicts")
    if not isinstance(required_dimensions, list) or not isinstance(
        required_verdicts, list
    ):
        blockers.append("GATE_B_REVIEW_INVALID")
        return
    for review in value:
        if not _closed(review, _REVIEW_FIELDS):
            blockers.append("GATE_B_REVIEW_INVALID")
            continue
        expected_artifact = {
            key: review[key]
            for key in _REVIEW_FIELDS
            - {
                "artifact_path",
                "artifact_sha256",
                "review_attestation_path",
                "review_attestation_sha256",
            }
        }
        try:
            dimensions = review["dimensions"]
            verdicts = review["verdicts"]
            if (
                review["reviewer_class"] != "independent"
                or review["verdict"] != "green"
                or not _zero(review["critical_findings"])
                or not _zero(review["important_findings"])
                or not isinstance(dimensions, list)
                or dimensions
                != [
                    {"dimension_id": dimension, "verdict": "green"}
                    for dimension in required_dimensions
                ]
                or not isinstance(verdicts, Mapping)
                or verdicts
                != {verdict: "green" for verdict in required_verdicts}
            ):
                raise _EvidenceProblem("GATE_B_REVIEW_NOT_GREEN")
            artifact = _artifact_json(
                artifacts,
                review["artifact_path"],
                review["artifact_sha256"],
                "GATE_B_REVIEW",
            )
            if artifact != expected_artifact:
                raise _EvidenceProblem("GATE_B_REVIEW_INVALID")
            _verify_review_range(
                review,
                source_sha,
                repo,
                expected_base_sha=expected_base_sha,
            )
        except (_EvidenceProblem, subprocess.CalledProcessError) as exc:
            blockers.append(
                exc.code if isinstance(exc, _EvidenceProblem) else "GATE_B_REVIEW_RANGE"
            )
            continue
        try:
            attestation = _artifact_json(
                artifacts,
                review["review_attestation_path"],
                review["review_attestation_sha256"],
                "GATE_B_REVIEW_ATTESTATION",
            )
            scope = [
                f"review:{review['review_id']}",
                f"review-artifact-sha256:{review['artifact_sha256']}",
                f"review-range:{review['commit_range']}",
                f"source-sha:{source_sha}",
                "critical-findings:0",
                "important-findings:0",
                *(
                    f"review-dimension:{dimension}:green"
                    for dimension in required_dimensions
                ),
                *(
                    f"review-verdict:{name}:green"
                    for name in sorted(required_verdicts)
                ),
                *(
                    _rollback_scope(rollback)
                    if isinstance(rollback, Mapping)
                    else []
                ),
            ]
            _verify_approval(
                attestation,
                trust_anchors,
                source_sha=source_sha,
                intake_digest=str(review["artifact_sha256"]),
                approved_scope=scope,
                repo=repo,
                expected_principal="reviewer:independent",
                expected_policy_id="independent-review",
                expected_task_id="TASK-25-GATE-B-REVIEW",
                expected_intake_id=f"REVIEW-{review['review_id']}",
                expected_base_sha=expected_base_sha,
                current_event=current_event,
                seen_nonces=seen_approval_nonces,
            )
        except (
            AuthorizationError,
            _EvidenceProblem,
            KeyError,
            TypeError,
            ValueError,
            UnicodeError,
            json.JSONDecodeError,
            subprocess.CalledProcessError,
        ):
            blockers.append("GATE_B_REVIEW_ATTESTATION_INVALID")


def _verify_owner(
    value: object,
    reviews: object,
    source_sha: str,
    repo: Path,
    artifacts: Path,
    trust_anchors: Mapping[str, object] | None,
    rollback: object,
    expected_base_sha: str,
    current_event: Mapping[str, object] | None,
    seen_approval_nonces: set[str],
    blockers: list[str],
) -> None:
    if not _closed(value, _OWNER_FIELDS):
        blockers.append("GATE_B_OWNER_DECISION_INVALID")
        return
    if value["approved"] is not True:
        blockers.append("GATE_B_OWNER_APPROVAL_MISSING")
        return
    if value["waived_checks"] is not False:
        blockers.append("GATE_B_CHECK_WAIVER_FORBIDDEN")
        return
    if (
        value["decision_id"] != OWNER_DIRECT_INTEGRATION_DECISION_ID
        or value["approval_date"] != OWNER_DIRECT_INTEGRATION_DECISION_DATE
        or value["delegated"] is not False
    ):
        blockers.append("GATE_B_OWNER_DECISION_INVALID")
        return
    rollback_scope = _rollback_scope(rollback) if isinstance(rollback, Mapping) else []
    owner_scope = [OWNER_DIRECT_INTEGRATION_SCOPE_LABEL, *rollback_scope]
    if value["approved_scope"] != owner_scope:
        blockers.append("GATE_B_OWNER_SCOPE")
        return
    try:
        if not isinstance(reviews, list):
            raise _EvidenceProblem("GATE_B_OWNER_APPROVAL_INVALID")
        review_bindings = sorted(
            (
                {
                    "review_id": review["review_id"],
                    "commit_range": review["commit_range"],
                    "artifact_sha256": review["artifact_sha256"],
                    "attestation_sha256": review["review_attestation_sha256"],
                }
                for review in reviews
                if isinstance(review, Mapping)
            ),
            key=lambda item: str(item["review_id"]),
        )
        if len(review_bindings) != len(reviews):
            raise _EvidenceProblem("GATE_B_OWNER_APPROVAL_INVALID")
        request = _artifact_json(
            artifacts,
            value["request_path"],
            value["request_sha256"],
            "GATE_B_OWNER_APPROVAL",
        )
        if request != {
            "decision_id": value["decision_id"],
            "approval_date": value["approval_date"],
            "delegated": value["delegated"],
            "requested_scope": owner_scope,
            "source_sha": source_sha,
            "review_bindings": review_bindings,
            "rollback_binding": dict(rollback) if isinstance(rollback, Mapping) else None,
        }:
            raise _EvidenceProblem("GATE_B_OWNER_APPROVAL_INVALID")
        attestation = _artifact_json(
            artifacts,
            value["approval_attestation_path"],
            value["approval_attestation_sha256"],
            "GATE_B_OWNER_APPROVAL",
        )
        _verify_approval(
            attestation,
            trust_anchors,
            source_sha=source_sha,
            intake_digest=str(value["request_sha256"]),
            approved_scope=owner_scope,
            repo=repo,
            expected_intake_id="GATE-B-OWNER-REQUEST",
            expected_base_sha=expected_base_sha,
            current_event=current_event,
            seen_nonces=seen_approval_nonces,
        )
    except (
        AuthorizationError,
        _EvidenceProblem,
        KeyError,
        TypeError,
        ValueError,
        UnicodeError,
        json.JSONDecodeError,
        subprocess.CalledProcessError,
    ):
        blockers.append("GATE_B_OWNER_APPROVAL_INVALID")


def _verify_rollback(
    value: object,
    repo: Path,
    blockers: list[str],
    *,
    expected_base_sha: str,
    authenticated_rollback: Mapping[str, object],
    source_sha: str,
) -> None:
    if (
        not _closed(value, _ROLLBACK_FIELDS)
        or not _closed(authenticated_rollback, _ROLLBACK_FIELDS)
        or canonical_json_bytes(value) != canonical_json_bytes(authenticated_rollback)
    ):
        blockers.append("GATE_B_ROLLBACK_AUTHENTICATION")
        return
    try:
        if (
            not isinstance(value["ref"], str)
            or not str(value["ref"]).startswith("refs/tags/")
            or not _git_sha(value["tag_object_sha"])
            or not _git_sha(value["commit_sha"])
            or not _git_sha(value["tree_sha"])
            or not isinstance(value["restore_receipt_sha256"], str)
            or re.fullmatch(r"[0-9a-f]{64}", value["restore_receipt_sha256"])
            is None
        ):
            raise _EvidenceProblem("GATE_B_ROLLBACK_UNVERIFIED")
        _git(repo, "check-ref-format", str(value["ref"]))
        if (
            _git_text(
                repo,
                "show-ref",
                "--verify",
                "--hash",
                str(value["ref"]),
            )
            != value["tag_object_sha"]
            or _git_text(repo, "cat-file", "-t", str(value["tag_object_sha"]))
            != "tag"
            or _git_text(repo, "rev-parse", f"{value['tag_object_sha']}^{{commit}}")
            != value["commit_sha"]
            or _git_text(repo, "cat-file", "-t", str(value["commit_sha"]))
            != "commit"
            or _git_text(repo, "rev-parse", f"{value['commit_sha']}^{{tree}}")
            != value["tree_sha"]
            or value["commit_sha"] in {expected_base_sha, source_sha}
            or value["tree_sha"]
            in {
                _git_text(repo, "rev-parse", f"{expected_base_sha}^{{tree}}"),
                _git_text(repo, "rev-parse", f"{source_sha}^{{tree}}"),
            }
        ):
            raise _EvidenceProblem("GATE_B_ROLLBACK_UNVERIFIED")
        _git(repo, "merge-base", "--is-ancestor", str(value["commit_sha"]), expected_base_sha)
        _git(repo, "merge-base", "--is-ancestor", str(value["commit_sha"]), source_sha)
        receipt = _rollback_restore_receipt(
            repo,
            expected_base_sha=expected_base_sha,
            source_sha=source_sha,
            rollback_commit_sha=str(value["commit_sha"]),
            rollback_tree_sha=str(value["tree_sha"]),
        )
        if (
            hashlib.sha256(canonical_json_bytes(receipt)).hexdigest()
            != value["restore_receipt_sha256"]
        ):
            raise _EvidenceProblem("GATE_B_ROLLBACK_UNVERIFIED")
    except (subprocess.CalledProcessError, _EvidenceProblem):
        blockers.append("GATE_B_ROLLBACK_UNVERIFIED")


def _rollback_restore_receipt(
    repo: Path,
    *,
    expected_base_sha: str,
    source_sha: str,
    rollback_commit_sha: str,
    rollback_tree_sha: str,
) -> dict[str, object]:
    with tempfile.TemporaryDirectory(prefix="ambitions-gate-b-rollback-") as directory:
        checkout = Path(directory) / "checkout"
        _git(repo, "clone", "-q", "--no-hardlinks", str(repo), str(checkout))
        _git(checkout, "checkout", "-q", "--detach", rollback_commit_sha)
        restored_head = _git_text(checkout, "rev-parse", "HEAD")
        restored_tree = _git_text(checkout, "rev-parse", "HEAD^{tree}")
        status = _git_text(checkout, "status", "--porcelain=v1")
        if (
            restored_head != rollback_commit_sha
            or restored_tree != rollback_tree_sha
            or status
        ):
            raise _EvidenceProblem("GATE_B_ROLLBACK_UNVERIFIED")
        return {
            "schema_version": 1,
            "operation": "detached-clean-rollback-restore",
            "expected_base_sha": expected_base_sha,
            "source_sha": source_sha,
            "rollback_commit_sha": rollback_commit_sha,
            "rollback_tree_sha": rollback_tree_sha,
            "restored_head_sha": restored_head,
            "restored_tree_sha": restored_tree,
            "worktree_status": "clean",
        }


def _rollback_scope(value: Mapping[str, object]) -> list[str]:
    return [
        f"rollback-ref:{value['ref']}",
        f"rollback-commit-sha:{value['commit_sha']}",
        f"rollback-tree-sha:{value['tree_sha']}",
        f"rollback-restore-receipt-sha256:{value['restore_receipt_sha256']}",
    ]


def _verify_protected(value: object, blockers: list[str]) -> None:
    if not _closed(value, _PROTECTED_FIELDS):
        blockers.append("GATE_B_PROTECTED_BOUNDARY_INVALID")
    elif value != {
        "authority_routing_cutover_only": True,
        "live_enforcement_proven": False,
        "post_merge_receipt_required": False,
    }:
        blockers.append("GATE_B_LIVE_ENFORCEMENT_OVERCLAIM")


def _strict_string_list(value: object, *, allow_empty: bool = False) -> list[str]:
    if (
        not isinstance(value, list)
        or (not allow_empty and not value)
        or any(not _text(item) for item in value)
        or value != sorted(set(value))
    ):
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
    return [str(item) for item in value]


def _visual_ledger_digest(input_bytes: Mapping[str, bytes]) -> str:
    digest = hashlib.sha256()
    for path in _VISUAL_LEDGER_PATHS:
        raw = input_bytes[path]
        label = path.encode("utf-8")
        digest.update(len(label).to_bytes(8, "big"))
        digest.update(label)
        digest.update(len(raw).to_bytes(8, "big"))
        digest.update(raw)
    return digest.hexdigest()


def _ids_from_records(value: object, field: str) -> list[str]:
    if not isinstance(value, list) or not value:
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
    identifiers = [
        item.get(field) if isinstance(item, Mapping) else None for item in value
    ]
    if any(not _text(identifier) for identifier in identifiers):
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
    normalized = sorted(str(identifier) for identifier in identifiers)
    if len(normalized) != len(set(normalized)):
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
    return normalized


def _derive_visual_completeness_from_bytes(
    input_bytes: Mapping[str, bytes],
) -> dict[str, object]:
    expected_paths = {*_VISUAL_LEDGER_PATHS, _VISUAL_POLICY_PATH}
    if set(input_bytes) != expected_paths or any(
        len(raw) > 8 * 1024 * 1024 for raw in input_bytes.values()
    ):
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
    try:
        values = {
            path: json.loads(input_bytes[path].decode("utf-8"))
            for path in expected_paths
        }
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING") from exc
    if any(not isinstance(value, Mapping) for value in values.values()):
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
    canon_index = values[_VISUAL_LEDGER_PATHS[0]]
    authority_manifest = values[_VISUAL_LEDGER_PATHS[1]]
    ux_blueprint = values[_VISUAL_LEDGER_PATHS[2]]
    rebaseline = values[_VISUAL_LEDGER_PATHS[3]]
    policy = values[_VISUAL_POLICY_PATH]
    visual_policy = policy.get("visual_review_policy")
    if (
        not isinstance(visual_policy, Mapping)
        or set(visual_policy)
        != {
            "accessibility_variants_source",
            "claim_ceiling",
            "figma_evidence_kind",
            "merged_visual_ledger_paths",
            "required_review_dimensions",
        }
        or visual_policy.get("accessibility_variants_source")
        != "docs/canon/migration/visual-authority-rebaseline.json"
        or visual_policy.get("claim_ceiling") != _VISUAL_CLAIM_CEILING
        or visual_policy.get("figma_evidence_kind") != "figma-design-export"
        or visual_policy.get("merged_visual_ledger_paths")
        != list(_VISUAL_LEDGER_PATHS)
    ):
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
    review_dimensions = _strict_string_list(
        visual_policy.get("required_review_dimensions")
    )
    if review_dimensions != [
        "accessibility-coverage",
        "frame-completeness",
        "journey-coverage",
        "object-coverage",
        "requirement-coverage",
        "screenshot-authenticity",
        "state-coverage",
    ]:
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")

    screens = _ids_from_records(ux_blueprint.get("screens"), "blueprint_id")
    journeys = _ids_from_records(ux_blueprint.get("journeys"), "blueprint_id")
    objects = _ids_from_records(
        ux_blueprint.get("object_boundaries"), "blueprint_id"
    )
    state_models = ux_blueprint.get("state_models")
    if not isinstance(state_models, list) or not state_models:
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
    state_ids = sorted(
        str(variant.get("blueprint_id"))
        for model in state_models
        if isinstance(model, Mapping)
        for variant in model.get("variants", [])
        if isinstance(variant, Mapping) and _text(variant.get("blueprint_id"))
    )
    if len(state_ids) != len(set(state_ids)) or not state_ids:
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
    presentation = rebaseline.get("presentation_matrix")
    coverage = rebaseline.get("coverage")
    posture = rebaseline.get("state_posture")
    canon = rebaseline.get("canon")
    if not all(
        isinstance(item, Mapping)
        for item in (presentation, coverage, posture, canon)
    ):
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
    accessibility_variants = _strict_string_list(
        presentation.get("required_accessibility_variants")
    )
    recorded_visual_requirement_ids = _strict_string_list(
        coverage.get("visual_requirement_ids")
    )
    requirement_dispositions = ux_blueprint.get("requirement_dispositions")
    if not isinstance(requirement_dispositions, list):
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
    visual_requirement_ids = sorted(
        str(item.get("requirement_id"))
        for item in requirement_dispositions
        if isinstance(item, Mapping)
        and item.get("disposition") == "visual_mapping_required"
        and _text(item.get("requirement_id"))
    )
    if (
        not visual_requirement_ids
        or len(visual_requirement_ids) != len(set(visual_requirement_ids))
        or visual_requirement_ids != recorded_visual_requirement_ids
    ):
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
    gap_blocked_state_ids = _strict_string_list(
        posture.get("gap_blocked_state_ids"), allow_empty=True
    )
    all_requirement_ids = set(
        _ids_from_records(canon_index.get("requirements"), "requirement_id")
    )
    content_sha = canon_index.get("canon_content_sha")
    canon_revision = canon_index.get("canon_revision")
    if (
        not _text(content_sha)
        or isinstance(canon_revision, bool)
        or not isinstance(canon_revision, int)
        or ux_blueprint.get("canon_content_sha") != content_sha
        or ux_blueprint.get("canon_revision") != canon_revision
        or authority_manifest.get("canon_content_sha") != content_sha
        or authority_manifest.get("canon_revision") != canon_revision
        or canon.get("content_sha") != content_sha
        or canon.get("revision") != canon_revision
        or not set(visual_requirement_ids) <= all_requirement_ids
        or coverage.get("screen_count") != len(screens)
        or coverage.get("state_count") != len(state_ids)
        or coverage.get("journey_count") != len(journeys)
        or coverage.get("object_count") != len(objects)
        or coverage.get("visual_requirement_count") != len(visual_requirement_ids)
    ):
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
    return {
        "accessibility_variants": accessibility_variants,
        "canon_revision": canon_revision,
        "claim_ceiling": _VISUAL_CLAIM_CEILING,
        "evidence_kind": "figma-design-export",
        "gap_blocked_state_ids": gap_blocked_state_ids,
        "journey_ids": journeys,
        "merged_visual_ledger_sha256": _visual_ledger_digest(input_bytes),
        "object_ids": objects,
        "required_review_dimensions": review_dimensions,
        "screen_ids": screens,
        "state_ids": state_ids,
        "visual_requirement_ids": visual_requirement_ids,
    }


def derive_visual_completeness(repo: Path, revision: str) -> dict[str, object]:
    """Derive exact visual coverage from fixed, merged ledger paths."""

    input_bytes = {
        path: _git(repo, "show", f"{revision}:{path}")
        for path in (*_VISUAL_LEDGER_PATHS, _VISUAL_POLICY_PATH)
    }
    return _derive_visual_completeness_from_bytes(input_bytes)


def _verify_figma_design_exports(
    value: object,
    completeness: Mapping[str, object],
    artifacts: Path,
) -> list[dict[str, object]]:
    if not isinstance(value, list) or not value:
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
    normalized: list[dict[str, object]] = []
    coverage_fields = {
        "screen_ids": "screen_ids",
        "state_ids": "state_ids",
        "journey_ids": "journey_ids",
        "object_ids": "object_ids",
        "accessibility_variants": "accessibility_variants",
        "visual_requirement_ids": "visual_requirement_ids",
    }
    observed: dict[str, set[str]] = {field: set() for field in coverage_fields}
    frame_ids: list[str] = []
    for item in value:
        if not _closed(item, _FIGMA_EXPORT_FIELDS):
            raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
        assert isinstance(item, Mapping)
        raw = _artifact_bytes(
            artifacts,
            item["artifact_path"],
            item["artifact_sha256"],
            "GATE_B_FIGMA_DESIGN_EXPORT",
        )
        if (
            item["evidence_kind"] != "figma-design-export"
            or item["claim_ceiling"] != _VISUAL_CLAIM_CEILING
            or item["merged_visual_ledger_sha256"]
            != completeness["merged_visual_ledger_sha256"]
            or not _text(item["frame_id"])
            or not _text(item["figma_file_key"])
            or re.fullmatch(r"[A-Za-z0-9_-]+", str(item["figma_file_key"])) is None
            or not _text(item["figma_node_id"])
            or not _text(item["frame_version"])
            or not _text(item["media_type"])
            or isinstance(item["byte_size"], bool)
            or not isinstance(item["byte_size"], int)
            or item["byte_size"] != len(raw)
        ):
            raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
        candidate = dict(item)
        for export_field, completeness_field in coverage_fields.items():
            identifiers = _strict_string_list(item[export_field])
            if not set(identifiers) <= set(completeness[completeness_field]):
                raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
            observed[export_field].update(identifiers)
            candidate[export_field] = identifiers
        normalized.append(candidate)
        frame_ids.append(str(item["frame_id"]))
    if frame_ids != sorted(set(frame_ids)):
        raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
    for export_field, completeness_field in coverage_fields.items():
        if sorted(observed[export_field]) != completeness[completeness_field]:
            raise _EvidenceProblem("GATE_B_VISUAL_COMPLETENESS")
    return normalized


def _verify_optional_simulator_renders(
    value: object,
    *,
    frames: list[str],
    source_sha: str,
    source_tree: str,
    artifacts: Path,
) -> list[dict[str, object]]:
    if not isinstance(value, list):
        raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID")
    normalized: list[dict[str, object]] = []
    seen: set[str] = set()
    for screenshot in value:
        if not _closed(screenshot, _SCREENSHOT_FIELDS):
            raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID")
        assert isinstance(screenshot, Mapping)
        raw = _artifact_bytes(
            artifacts,
            screenshot["artifact_path"],
            screenshot["artifact_sha256"],
            "GATE_B_VISUAL_SCREENSHOT",
        )
        width, height = _png_dimensions(raw)
        frame_id = str(screenshot["frame_id"])
        if (
            frame_id not in frames
            or frame_id in seen
            or screenshot["media_type"] != "image/png"
            or screenshot["byte_size"] != len(raw)
            or screenshot["pixel_width"] != width
            or screenshot["pixel_height"] != height
            or isinstance(screenshot["scale"], bool)
            or not isinstance(screenshot["scale"], int)
            or screenshot["scale"] < 1
            or not _text(screenshot["device"])
            or not _text(screenshot["os_version"])
            or not _text(screenshot["build_identity"])
            or screenshot["capture_kind"] != "simulator-render"
            or screenshot["source_sha"] != source_sha
            or screenshot["source_tree_sha"] != source_tree
        ):
            raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID")
        seen.add(frame_id)
        normalized.append(dict(screenshot))
    return sorted(normalized, key=lambda item: str(item["frame_id"]))


def _verify_visual_owner_v2(
    value: object,
    canon_revision: object,
    source_sha: str,
    source_tree: str,
    repo: Path,
    artifacts: Path,
    trust_anchors: Mapping[str, object] | None,
    expected_base_sha: str,
    current_event: Mapping[str, object] | None,
    seen_approval_nonces: set[str],
    blockers: list[str],
) -> None:
    if not _closed(value, _VISUAL_FIELDS):
        blockers.append("GATE_B_VISUAL_OWNER_INVALID")
        return
    assert isinstance(value, Mapping)
    if value["delegated"] is not False:
        blockers.append("GATE_B_VISUAL_OWNER_DELEGATED")
        return
    if (
        value["canon_revision"] != canon_revision
        or value["source_sha"] != source_sha
        or value["evidence_kind"] != "figma-design-export"
        or value["claim_ceiling"] != _VISUAL_CLAIM_CEILING
    ):
        blockers.append("GATE_B_VISUAL_BINDING")
        return
    try:
        completeness = derive_visual_completeness(repo, expected_base_sha)
        if (
            completeness["canon_revision"] != canon_revision
            or value["merged_visual_ledger_sha256"]
            != completeness["merged_visual_ledger_sha256"]
            or value["gap_blocked_state_ids"]
            != completeness["gap_blocked_state_ids"]
        ):
            raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
        if completeness["gap_blocked_state_ids"]:
            raise _EvidenceProblem("GATE_B_VISUAL_GAP_BLOCKED")
        exports = _verify_figma_design_exports(
            value["figma_exports"], completeness, artifacts
        )
        frames = [str(item["frame_id"]) for item in exports]
        if value["final_frame_ids"] != frames:
            raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
        renders = _verify_optional_simulator_renders(
            value["simulator_renders"],
            frames=frames,
            source_sha=source_sha,
            source_tree=source_tree,
            artifacts=artifacts,
        )
        manifest = _artifact_json(
            artifacts,
            value["manifest_path"],
            value["manifest_sha256"],
            "GATE_B_VISUAL_BINDING",
        )
        expected_manifest = {
            "schema_version": 1,
            "canon_revision": canon_revision,
            "claim_ceiling": _VISUAL_CLAIM_CEILING,
            "evidence_kind": "figma-design-export",
            "figma_exports": exports,
            "final_frame_ids": frames,
            "gap_blocked_state_ids": [],
            "merged_visual_ledger_sha256": completeness[
                "merged_visual_ledger_sha256"
            ],
            "required_review_dimensions": completeness[
                "required_review_dimensions"
            ],
            "simulator_renders": renders,
            "source_sha": source_sha,
            "source_tree_sha": source_tree,
        }
        if manifest != expected_manifest:
            raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
        review = value["review"]
        if not _closed(review, _VISUAL_REVIEW_FIELDS):
            raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
        assert isinstance(review, Mapping)
        review_artifact = _artifact_json(
            artifacts,
            review["artifact_path"],
            review["artifact_sha256"],
            "GATE_B_VISUAL_BINDING",
        )
        expected_review = {
            "review_id": "gate-b-visual-independent-review",
            "reviewer_class": "independent",
            "verdict": "green",
            "dimensions": [
                {"dimension_id": dimension, "verdict": "green"}
                for dimension in completeness["required_review_dimensions"]
            ],
            "base_sha": review["base_sha"],
            "head_sha": review["head_sha"],
            "commit_range": review["commit_range"],
            "critical_findings": 0,
            "important_findings": 0,
            "manifest_sha256": value["manifest_sha256"],
            "merged_visual_ledger_sha256": completeness[
                "merged_visual_ledger_sha256"
            ],
            "final_frame_ids": frames,
            "claim_ceiling": _VISUAL_CLAIM_CEILING,
        }
        if review_artifact != expected_review:
            raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
        _verify_review_range(
            review, source_sha, repo, expected_base_sha=expected_base_sha
        )
        review_attestation = _artifact_json(
            artifacts,
            review["attestation_path"],
            review["attestation_sha256"],
            "GATE_B_VISUAL_REVIEW_ATTESTATION",
        )
        review_scope = [
            "visual-independent-review",
            f"visual-ledger-sha256:{completeness['merged_visual_ledger_sha256']}",
            f"visual-manifest-sha256:{value['manifest_sha256']}",
            f"review-range:{review['commit_range']}",
            f"claim-ceiling:{_VISUAL_CLAIM_CEILING}",
            *(
                f"review-dimension:{dimension}:green"
                for dimension in completeness["required_review_dimensions"]
            ),
            *(f"frame:{frame}" for frame in frames),
        ]
        _verify_approval(
            review_attestation,
            trust_anchors,
            source_sha=source_sha,
            intake_digest=str(review["artifact_sha256"]),
            approved_scope=review_scope,
            repo=repo,
            expected_principal="reviewer:independent",
            expected_policy_id="independent-review",
            expected_task_id="TASK-25-GATE-B-VISUAL-REVIEW",
            expected_intake_id="VISUAL-INDEPENDENT-REVIEW",
            expected_base_sha=expected_base_sha,
            current_event=current_event,
            seen_nonces=seen_approval_nonces,
        )
        decision = _artifact_json(
            artifacts,
            value["decision_receipt_path"],
            value["decision_receipt_sha256"],
            "GATE_B_VISUAL_BINDING",
        )
        expected_decision = {
            "decision_id": "visual-owner-final",
            "delegated": False,
            "canon_revision": canon_revision,
            "source_sha": source_sha,
            "source_tree_sha": source_tree,
            "evidence_kind": "figma-design-export",
            "merged_visual_ledger_sha256": completeness[
                "merged_visual_ledger_sha256"
            ],
            "manifest_sha256": value["manifest_sha256"],
            "review_sha256": review["artifact_sha256"],
            "review_attestation_sha256": review["attestation_sha256"],
            "final_frame_ids": frames,
            "gap_blocked_state_ids": [],
            "claim_ceiling": _VISUAL_CLAIM_CEILING,
        }
        if decision != expected_decision:
            raise _EvidenceProblem("GATE_B_VISUAL_BINDING")
        scope = [
            "visual-owner-final",
            f"canon-revision:{canon_revision}",
            f"source-sha:{source_sha}",
            f"source-tree-sha:{source_tree}",
            "evidence-kind:figma-design-export",
            f"visual-ledger-sha256:{completeness['merged_visual_ledger_sha256']}",
            f"visual-manifest-sha256:{value['manifest_sha256']}",
            f"visual-review-sha256:{review['artifact_sha256']}",
            f"visual-review-attestation-sha256:{review['attestation_sha256']}",
            f"visual-review-range:{review['commit_range']}",
            f"claim-ceiling:{_VISUAL_CLAIM_CEILING}",
            *(f"frame:{frame}" for frame in frames),
            *(
                "figma-export:"
                f"{item['frame_id']}:{item['figma_file_key']}:{item['figma_node_id']}:"
                f"{item['frame_version']}:{item['artifact_sha256']}:{item['byte_size']}"
                for item in exports
            ),
        ]
        owner_attestation = _artifact_json(
            artifacts,
            value["approval_attestation_path"],
            value["approval_attestation_sha256"],
            "GATE_B_VISUAL_BINDING",
        )
        _verify_approval(
            owner_attestation,
            trust_anchors,
            source_sha=source_sha,
            intake_digest=str(value["decision_receipt_sha256"]),
            approved_scope=scope,
            repo=repo,
            expected_intake_id="VISUAL-OWNER-DECISION",
            expected_base_sha=expected_base_sha,
            current_event=current_event,
            seen_nonces=seen_approval_nonces,
        )
    except AuthorizationError:
        blockers.append("GATE_B_VISUAL_REVIEW_ATTESTATION")
    except _EvidenceProblem as exc:
        blockers.append(exc.code)
    except (
        KeyError,
        TypeError,
        ValueError,
        UnicodeError,
        json.JSONDecodeError,
        subprocess.CalledProcessError,
    ):
        blockers.append("GATE_B_VISUAL_BINDING")


def _png_dimensions(raw: bytes) -> tuple[int, int]:
    if (
        len(raw) < 57
        or len(raw) > 64 * 1024 * 1024
        or raw[:8] != b"\x89PNG\r\n\x1a\n"
    ):
        raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID")
    offset = 8
    width: int | None = None
    height: int | None = None
    idat = bytearray()
    saw_idat = False
    idat_closed = False
    saw_end = False
    while offset + 12 <= len(raw):
        length = int.from_bytes(raw[offset : offset + 4], "big")
        kind = raw[offset + 4 : offset + 8]
        end = offset + 12 + length
        if end > len(raw):
            raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID")
        data = raw[offset + 8 : offset + 8 + length]
        expected_crc = int.from_bytes(raw[offset + 8 + length : end], "big")
        if zlib.crc32(kind + data) != expected_crc:
            raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID")
        if kind == b"IHDR":
            if length != 13 or width is not None or offset != 8:
                raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID")
            width = int.from_bytes(data[:4], "big")
            height = int.from_bytes(data[4:8], "big")
            if (
                width < 1
                or height < 1
                or width > 8192
                or height > 8192
                or width * height > 16_777_216
                or data[8:] != bytes((8, 6, 0, 0, 0))
            ):
                raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID")
        elif kind == b"IDAT":
            if width is None or idat_closed or saw_end:
                raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID")
            saw_idat = True
            idat.extend(data)
            if len(idat) > 64 * 1024 * 1024:
                raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID")
        elif kind == b"IEND":
            if length != 0 or end != len(raw) or not saw_idat:
                raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID")
            saw_end = True
        elif kind[:1].isupper():
            raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID")
        if saw_idat and kind != b"IDAT":
            idat_closed = True
        offset = end
    if not saw_end or width is None or height is None or not saw_idat:
        raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID")
    expected_size = height * (1 + width * 4)
    try:
        decompressor = zlib.decompressobj()
        pixels = decompressor.decompress(bytes(idat), expected_size + 1)
    except zlib.error as exc:
        raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID") from exc
    if (
        len(pixels) != expected_size
        or not decompressor.eof
        or decompressor.unused_data
        or decompressor.unconsumed_tail
    ):
        raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID")
    stride = width * 4
    previous = bytearray(stride)
    for row_index in range(height):
        start = row_index * (stride + 1)
        filter_kind = pixels[start]
        if filter_kind > 4:
            raise _EvidenceProblem("GATE_B_VISUAL_SCREENSHOT_INVALID")
        row = bytearray(pixels[start + 1 : start + 1 + stride])
        for index in range(stride):
            left = row[index - 4] if index >= 4 else 0
            above = previous[index]
            upper_left = previous[index - 4] if index >= 4 else 0
            if filter_kind == 1:
                predictor = left
            elif filter_kind == 2:
                predictor = above
            elif filter_kind == 3:
                predictor = (left + above) // 2
            elif filter_kind == 4:
                predictor = _paeth_predictor(left, above, upper_left)
            else:
                predictor = 0
            row[index] = (row[index] + predictor) & 0xFF
        previous = row
    return width, height


def _paeth_predictor(left: int, above: int, upper_left: int) -> int:
    estimate = left + above - upper_left
    distances = (
        (abs(estimate - left), left),
        (abs(estimate - above), above),
        (abs(estimate - upper_left), upper_left),
    )
    return min(distances, key=lambda item: item[0])[1]


def _preflight_benchmark_report(
    value: object,
    source_sha: str,
    artifacts: Path,
    blockers: list[str],
) -> bytes | None:
    if not _closed(value, _BENCHMARK_FIELDS) or value["source_sha"] != source_sha:
        blockers.append("GATE_B_BENCHMARK_INVALID")
        return None
    try:
        report_bytes = _artifact_bytes(
            artifacts,
            value["report_path"],
            value["report_sha256"],
            "GATE_B_BENCHMARK",
        )
        report = json.loads(report_bytes.decode("utf-8"))
        matrix = report.get("task24_tree_matrix", {}) if isinstance(report, Mapping) else {}
        if (
            not isinstance(report, Mapping)
            or report.get("status") != "green"
            or report.get("scenario_ids") != list(AUTHORIZATION_SCENARIO_IDS)
            or not isinstance(matrix, Mapping)
            or matrix.get("source_sha") != source_sha
            or matrix.get("python_implementation") != "cpython"
            or matrix.get("python_version") != "3.12"
            or matrix.get("executed_test_count") != 2
            or not isinstance(matrix.get("test_ids"), list)
            or len(matrix["test_ids"]) != matrix["executed_test_count"]
        ):
            raise _EvidenceProblem("GATE_B_BENCHMARK_MISMATCH")
    except (OSError, UnicodeError, json.JSONDecodeError, _EvidenceProblem):
        blockers.append("GATE_B_BENCHMARK_MISMATCH")
        return None
    return report_bytes


def _preflight_owner_artifacts(
    value: object, artifacts: Path, blockers: list[str]
) -> None:
    artifact_fields = (
        ("request_path", "request_sha256"),
        ("approval_attestation_path", "approval_attestation_sha256"),
    )
    required_fields = {
        field for path_field, digest_field in artifact_fields for field in (path_field, digest_field)
    }
    if not isinstance(value, Mapping) or not required_fields.issubset(value):
        return
    try:
        for path_field, digest_field in artifact_fields:
            _artifact_bytes(
                artifacts,
                value[path_field],
                value[digest_field],
                "GATE_B_OWNER_APPROVAL",
            )
    except (_EvidenceProblem, KeyError, TypeError, ValueError):
        blockers.append("GATE_B_OWNER_APPROVAL_INVALID")


def _prepare_benchmark(
    value: object,
    source_sha: str,
    repo: Path,
    artifacts: Path,
    expected_base_sha: str,
    blockers: list[str],
) -> Mapping[str, object] | None:
    """Pin benchmark report, package, policy, and fixture identity without execution."""

    report_bytes = _preflight_benchmark_report(
        value, source_sha, artifacts, blockers
    )
    if report_bytes is None:
        return None
    try:
        packages = _artifact_directory(artifacts, value["packages_root"])
        benchmark_policy = "docs/canon/references/task-25-authorization-benchmark-policy.json"
        fixture_root = "tests/canon/fixtures/authorization-benchmarks"
        policy_bytes = _git(repo, "show", f"{source_sha}:{benchmark_policy}")
        if (
            not policy_bytes
            or len(policy_bytes) >= _MAX_PINNED_INPUT_BYTES
            or policy_bytes
            != _git(repo, "show", f"{expected_base_sha}:{benchmark_policy}")
        ):
            raise _EvidenceProblem("GATE_B_BENCHMARK_MISMATCH")

        def fixture_paths(revision: str) -> tuple[str, ...]:
            raw = _git(
                repo,
                "ls-tree",
                "-r",
                "--name-only",
                "-z",
                revision,
                "--",
                fixture_root,
            )
            if len(raw) >= _MAX_PINNED_INPUT_BYTES:
                raise _EvidenceProblem("GATE_B_BENCHMARK_MISMATCH")
            try:
                paths = tuple(
                    item.decode("utf-8", errors="strict")
                    for item in raw.split(b"\0")
                    if item
                )
            except UnicodeError as exc:
                raise _EvidenceProblem("GATE_B_BENCHMARK_MISMATCH") from exc
            prefix = f"{fixture_root}/"
            if (
                not paths
                or paths != tuple(sorted(set(paths)))
                or any(
                    not path.startswith(prefix)
                    or "/" in path.removeprefix(prefix)
                    or not path.endswith(".json")
                    for path in paths
                )
            ):
                raise _EvidenceProblem("GATE_B_BENCHMARK_MISMATCH")
            return paths

        source_fixture_paths = fixture_paths(source_sha)
        if source_fixture_paths != fixture_paths(expected_base_sha):
            raise _EvidenceProblem("GATE_B_BENCHMARK_MISMATCH")
        fixture_inputs: list[tuple[str, bytes]] = []
        for relative in source_fixture_paths:
            raw = _git(repo, "show", f"{source_sha}:{relative}")
            if (
                not raw
                or len(raw) >= _MAX_PINNED_INPUT_BYTES
                or raw != _git(repo, "show", f"{expected_base_sha}:{relative}")
            ):
                raise _EvidenceProblem("GATE_B_BENCHMARK_MISMATCH")
            fixture_inputs.append((relative, raw))

        with tempfile.TemporaryDirectory(
            prefix="ambitions-gate-b-benchmark-fixtures-"
        ) as directory:
            fixture_directory = Path(directory)
            for relative, raw in fixture_inputs:
                (fixture_directory / Path(relative).name).write_bytes(raw)
            scenarios = load_authorization_benchmark_scenarios(fixture_directory)

        return {
            "fixture_identity": tuple(
                (relative, hashlib.sha256(raw).hexdigest())
                for relative, raw in fixture_inputs
            ),
            "packages": packages,
            "policy_sha256": hashlib.sha256(policy_bytes).hexdigest(),
            "report_bytes": report_bytes,
            "scenarios": scenarios,
        }
    except (
        BenchmarkError,
        OSError,
        UnicodeError,
        json.JSONDecodeError,
        subprocess.CalledProcessError,
        _EvidenceProblem,
    ):
        blockers.append("GATE_B_BENCHMARK_MISMATCH")
        return None


def _execute_benchmark(
    plan: Mapping[str, object], source_root: Path, blockers: list[str]
) -> None:
    """Recompute the benchmark once from the prepared static inputs."""

    try:
        report_bytes = plan.get("report_bytes")
        packages = plan.get("packages")
        scenarios = plan.get("scenarios")
        if (
            not isinstance(report_bytes, bytes)
            or not isinstance(packages, Path)
            or not isinstance(scenarios, tuple)
        ):
            raise _EvidenceProblem("GATE_B_BENCHMARK_MISMATCH")
        recomputed = run_authorization_benchmark(
            scenarios, packages, source_root=source_root
        )
        if report_bytes != canonical_benchmark_bytes(recomputed):
            raise _EvidenceProblem("GATE_B_BENCHMARK_MISMATCH")
    except (
        BenchmarkError,
        OSError,
        UnicodeError,
        json.JSONDecodeError,
        _EvidenceProblem,
    ):
        blockers.append("GATE_B_BENCHMARK_MISMATCH")


def _verify_benchmark(
    value: object,
    source_sha: str,
    repo: Path,
    artifacts: Path,
    expected_base_sha: str,
    blockers: list[str],
) -> None:
    """Compatibility wrapper for focused benchmark verification tests."""

    plan = _prepare_benchmark(
        value, source_sha, repo, artifacts, expected_base_sha, blockers
    )
    if plan is not None and not blockers:
        _execute_benchmark(plan, repo, blockers)


def _verify_approval(
    attestation: object,
    trust_anchors: Mapping[str, object] | None,
    *,
    source_sha: str,
    intake_digest: str,
    approved_scope: list[str],
    repo: Path,
    expected_principal: str = "owner:devan",
    expected_policy_id: str = "owner-gate",
    expected_task_id: str = "TASK-26-GATE-B",
    expected_intake_id: str | None = None,
    expected_base_sha: str,
    current_event: Mapping[str, object] | None,
    seen_nonces: set[str],
) -> None:
    if (
        not isinstance(attestation, Mapping)
        or trust_anchors is None
        or current_event is None
    ):
        raise _EvidenceProblem("GATE_B_APPROVAL_INVALID")
    base = str(attestation.get("trusted_base_sha", ""))
    if not _git_sha(base) or base != expected_base_sha:
        raise _EvidenceProblem("GATE_B_APPROVAL_INVALID")
    policy = load_base_policy(repo, base)
    snapshots = policy["snapshot_paths"]
    if not isinstance(snapshots, Mapping):
        raise _EvidenceProblem("GATE_B_APPROVAL_INVALID")
    base_anchors = policy.get("trust_anchors")
    if not isinstance(base_anchors, Mapping):
        raise _EvidenceProblem("GATE_B_APPROVAL_INVALID")
    nonce_snapshot = policy.get("approval_nonce_state")
    if (
        not isinstance(nonce_snapshot, Mapping)
        or not isinstance(nonce_snapshot.get("consumed_nonces"), list)
        or any(
            not isinstance(item, str)
            for item in nonce_snapshot.get("consumed_nonces", [])
        )
        or nonce_snapshot.get("consumption_generation")
        != current_event.get("consumption_generation")
    ):
        raise _EvidenceProblem("GATE_B_APPROVAL_INVALID")
    seen_nonces.update(str(item) for item in nonce_snapshot["consumed_nonces"])
    nonce = attestation.get("one_time_use_nonce")
    if not isinstance(nonce, str) or nonce in seen_nonces:
        raise _EvidenceProblem("GATE_B_APPROVAL_INVALID")
    approval_attestation_digest(
        attestation,
        verification_epoch=int(current_event["verification_epoch"]),
        trust_anchors=base_anchors,
    )
    manifest_bytes = _git(repo, "show", f"{base}:{snapshots['command_manifest']}")
    manifest = json.loads(manifest_bytes.decode("utf-8"))
    workflow = manifest["trusted_workflow"]
    repository_identity = policy["repository_identity"]
    current_bindings = {
        "repository_id": current_event.get("repository_id"),
        "repository_full_name": current_event.get("repository_full_name"),
        "pull_request_number": current_event.get("pull_request_number"),
        "trusted_base_sha": current_event.get("trusted_base_sha"),
        "trusted_head_sha": current_event.get("trusted_head_sha"),
        "merge_base_sha": current_event.get("merge_base_sha"),
        "workflow_run_id": current_event.get("workflow_run_id"),
        "workflow_run_attempt": current_event.get("workflow_run_attempt"),
        "event_projection_digest": current_event.get("event_projection_digest"),
        "consumption_generation": current_event.get("consumption_generation"),
        "verification_epoch": current_event.get("verification_epoch"),
    }
    if (
        attestation.get("trusted_head_sha") != source_sha
        or any(attestation.get(key) != value for key, value in current_bindings.items())
        or attestation.get("intake_digest") != intake_digest
        or attestation.get("approved_scope") != sorted(approved_scope)
        or attestation.get("authenticated_principal") != expected_principal
        or attestation.get("approval_policy_id") != expected_policy_id
        or attestation.get("approval_policy_revision") != "1"
        or attestation.get("task_id") != expected_task_id
        or (
            expected_intake_id is not None
            and attestation.get("intake_id") != expected_intake_id
        )
        or attestation.get("policy_revision") != policy["policy_revision"]
        or attestation.get("repository_id")
        != repository_identity["repository_id"]
        or attestation.get("repository_full_name")
        != repository_identity["repository_full_name"]
        or base_anchors.get("repository_identity") != repository_identity
        or attestation.get("break_glass") is not False
        or attestation.get("command_manifest_digest")
        != hashlib.sha256(manifest_bytes).hexdigest()
        or attestation.get("workflow_path") != workflow["path"]
        or attestation.get("workflow_ref") != workflow["ref"]
        or attestation.get("workflow_digest") != workflow["digest"]
        or attestation.get("check_identity") != workflow["check_identity"]
        or attestation.get("integration_id") != workflow["integration_id"]
        or attestation.get("app_id") != workflow["app_id"]
    ):
        raise _EvidenceProblem("GATE_B_APPROVAL_INVALID")
    merge = str(attestation["merge_base_sha"])
    if not _git_sha(merge):
        raise _EvidenceProblem("GATE_B_APPROVAL_INVALID")
    if (
        _git_text(repo, "cat-file", "-t", base) != "commit"
        or _git_text(repo, "merge-base", base, source_sha) != merge
    ):
        raise _EvidenceProblem("GATE_B_APPROVAL_INVALID")
    seen_nonces.add(nonce)


def _verify_review_range(
    value: Mapping[str, object],
    source_sha: str,
    repo: Path,
    *,
    expected_base_sha: str,
) -> None:
    base = value["base_sha"]
    head = value["head_sha"]
    if (
        not _git_sha(base)
        or not _git_sha(head)
        or head != source_sha
        or base != expected_base_sha
        or value["commit_range"] != f"{base}..{head}"
        or _git_text(repo, "cat-file", "-t", base) != "commit"
        or _git_text(repo, "merge-base", base, str(head)) != base
    ):
        raise _EvidenceProblem("GATE_B_REVIEW_RANGE")


def _load_trust_anchors(
    repo: Path, expected_base_sha: str, blockers: list[str]
) -> Mapping[str, object] | None:
    try:
        policy = load_base_policy(repo, expected_base_sha)
        value = policy.get("trust_anchors")
        if not isinstance(value, Mapping):
            raise ValueError
        return value
    except (
        OSError,
        UnicodeError,
        json.JSONDecodeError,
        ValueError,
        AuthorizationError,
        subprocess.CalledProcessError,
    ):
        blockers.append("GATE_B_TRUST_ANCHORS")
        return None


def _read_primary_evidence(path: Path, artifact_root: Path) -> Mapping[str, object]:
    try:
        safe = _confined_file(artifact_root, path)
        raw = _bounded_file_bytes(safe, _MAX_PRIMARY_EVIDENCE_BYTES)
        value = json.loads(raw.decode("utf-8"))
        _verify_primary_evidence_shape(value)
        canonical = canonical_json_bytes(value)
    except GateBEvidenceError:
        raise
    except (MemoryError, RecursionError, UnicodeEncodeError) as exc:
        raise GateBEvidenceError(
            "GATE_B_EVIDENCE_BOUNDS", "evidence exceeds deterministic parser bounds"
        ) from exc
    except (OSError, ValueError, UnicodeError, json.JSONDecodeError) as exc:
        if isinstance(exc, ValueError) and str(exc) == "bounded file exceeds limit":
            raise GateBEvidenceError(
                "GATE_B_EVIDENCE_BOUNDS", "evidence exceeds the byte limit"
            ) from exc
        raise GateBEvidenceError("GATE_B_FIELDS", "evidence is unreadable") from exc
    if not isinstance(value, Mapping) or raw != canonical:
        raise GateBEvidenceError("GATE_B_FIELDS", "evidence is non-canonical")
    return value


def _verify_primary_evidence_shape(value: object) -> None:
    stack: list[tuple[object, int]] = [(value, 1)]
    nodes = 0
    while stack:
        current, depth = stack.pop()
        nodes += 1
        if (
            depth > _MAX_PRIMARY_EVIDENCE_DEPTH
            or nodes > _MAX_PRIMARY_EVIDENCE_NODES
        ):
            raise GateBEvidenceError(
                "GATE_B_EVIDENCE_BOUNDS", "evidence exceeds structural bounds"
            )
        if isinstance(current, Mapping):
            for key, item in current.items():
                stack.append((key, depth + 1))
                stack.append((item, depth + 1))
        elif isinstance(current, list):
            stack.extend((item, depth + 1) for item in current)


def _artifact_json(
    root: Path, relative: object, expected_digest: object, code: str
) -> object:
    raw = _artifact_bytes(root, relative, expected_digest, code)
    try:
        value = json.loads(raw.decode("utf-8"))
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise _EvidenceProblem(f"{code}_INVALID") from exc
    if raw != canonical_json_bytes(value):
        raise _EvidenceProblem(f"{code}_INVALID")
    return value


def _artifact_bytes(
    root: Path, relative: object, expected_digest: object, code: str
) -> bytes:
    if not isinstance(relative, str) or not isinstance(expected_digest, str):
        raise _EvidenceProblem(f"{code}_INVALID")
    try:
        path = _confined_file(root, root / relative)
        raw = _bounded_file_bytes(path, _MAX_ARTIFACT_BYTES)
    except (OSError, ValueError) as exc:
        raise _EvidenceProblem(f"{code}_PATH") from exc
    if hashlib.sha256(raw).hexdigest() != expected_digest:
        raise _EvidenceProblem(f"{code}_DIGEST")
    return raw


def _bounded_file_bytes(path: Path, limit: int) -> bytes:
    """Read at most ``limit - 1`` bytes after an explicit size preflight."""

    size = path.stat().st_size
    if size >= limit:
        raise ValueError("bounded file exceeds limit")
    with path.open("rb") as handle:
        raw = handle.read(limit)
    if len(raw) >= limit:
        raise ValueError("bounded file exceeds limit")
    return raw


def _base64url_decode_strict(
    value: object, code: str, *, allow_empty: bool = False
) -> bytes:
    if not isinstance(value, str) or (not value and not allow_empty):
        raise _EvidenceProblem(code)
    if any(
        character
        not in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
        for character in value
    ):
        raise _EvidenceProblem(code)
    try:
        decoded = base64.b64decode(
            value + "=" * (-len(value) % 4), altchars=b"-_", validate=True
        )
    except (binascii.Error, ValueError) as exc:
        raise _EvidenceProblem(code) from exc
    if base64.urlsafe_b64encode(decoded).rstrip(b"=").decode("ascii") != value:
        raise _EvidenceProblem(code)
    return decoded


def _artifact_directory(root: Path, relative: object) -> Path:
    if not isinstance(relative, str):
        raise _EvidenceProblem("GATE_B_BENCHMARK_PATH")
    try:
        path = _confined_path(root, root / relative)
    except (OSError, ValueError) as exc:
        raise _EvidenceProblem("GATE_B_BENCHMARK_PATH") from exc
    if not path.is_dir():
        raise _EvidenceProblem("GATE_B_BENCHMARK_PATH")
    return path


def _repo_file(repo: Path, relative: object) -> Path:
    if not isinstance(relative, str):
        raise _EvidenceProblem("GATE_B_CANON_INVALID")
    try:
        return _confined_file(repo, repo / relative)
    except (OSError, ValueError) as exc:
        raise _EvidenceProblem("GATE_B_CANON_INVALID") from exc


def _confined_file(root: Path, path: Path) -> Path:
    candidate = _confined_path(root, path)
    if not candidate.is_file():
        raise ValueError("not a regular file")
    return candidate


def _confined_path(root: Path, path: Path) -> Path:
    root_path = root.absolute()
    candidate = path if path.is_absolute() else root_path / path
    candidate = candidate.absolute()
    relative = candidate.relative_to(root_path)
    current = root_path
    for part in relative.parts:
        current = current / part
        if current.is_symlink():
            raise ValueError("symlink evidence is forbidden")
    resolved_root = root_path.resolve(strict=True)
    resolved = candidate.resolve(strict=True)
    resolved.relative_to(resolved_root)
    return resolved


def _git_checkout(path: Path) -> Path:
    repo = path.resolve(strict=True)
    if _git_text(repo, "rev-parse", "--is-inside-work-tree") != "true":
        raise GateBEvidenceError("GATE_B_SOURCE", "source is not a Git checkout")
    return repo


def _git(repo: Path, *arguments: str) -> bytes:
    with tempfile.TemporaryDirectory(prefix="ambitions-gate-b-git-home-") as home:
        environment = {
            key: os.environ[key]
            for key in ("SYSTEMROOT", "TMPDIR", "WINDIR")
            if key in os.environ
        }
        environment.update(
            {
                "GIT_CONFIG_GLOBAL": "/dev/null",
                "GIT_CONFIG_NOSYSTEM": "1",
                "GIT_CONFIG_SYSTEM": "/dev/null",
                "GIT_TERMINAL_PROMPT": "0",
                "HOME": home,
                "LANG": "C",
                "LC_ALL": "C",
                "PATH": "/usr/bin:/bin:/usr/local/bin",
                "PYTHONHASHSEED": "0",
                "TZ": "UTC",
            }
        )
        try:
            return subprocess.run(
                [
                    "git",
                    "-c",
                    "core.hooksPath=/dev/null",
                    "-c",
                    "core.fsmonitor=false",
                    "-c",
                    "core.pager=cat",
                    *arguments,
                ],
                cwd=repo,
                env=environment,
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=_VERIFIER_SUBPROCESS_TIMEOUT_SECONDS,
            ).stdout
        except subprocess.TimeoutExpired as exc:
            raise subprocess.CalledProcessError(124, ["git", *arguments]) from exc


def _git_text(repo: Path, *arguments: str) -> str:
    return _git(repo, *arguments).decode("ascii", errors="strict").strip()


def _red_assessment(blockers: list[str]) -> dict[str, object]:
    return {
        "schema_version": 1,
        "gate_b": "red",
        "task_26_authority_routing_cutover_authorized": False,
        "live_enforcement_proven": False,
        "post_merge_receipt_required": False,
        "claim_ceiling": (
            "Gate B is Red; Task 26 authority/routing cutover is not authorized, and "
            "protected CI installation or protected-enforcement claims remain excluded."
        ),
        "blocking_codes": sorted(set(blockers)),
    }


def _closed(value: object, fields: frozenset[str]) -> bool:
    return isinstance(value, Mapping) and set(value) == fields


def _text(value: object) -> bool:
    return isinstance(value, str) and bool(value.strip())


def _zero(value: object) -> bool:
    return not isinstance(value, bool) and isinstance(value, int) and value == 0


def _git_sha(value: object) -> bool:
    return isinstance(value, str) and re.fullmatch(r"[0-9a-f]{40}", value) is not None


def _main(arguments: list[str]) -> int:
    if sys.version_info[:2] != _TRUSTED_PYTHON_VERSION:
        return 1
    if len(arguments) != 2 or arguments[0] != "validate-requirement":
        return 2
    evidence_id = arguments[1]
    if evidence_id not in _DOMAIN_OBSERVATION_KINDS:
        return 2
    repo = _git_checkout(Path.cwd())
    source_sha = _git_text(repo, "rev-parse", "HEAD")
    source_tree = _git_text(repo, "rev-parse", "HEAD^{tree}")
    try:
        registry = json.loads(
            _git(
                repo,
                "show",
                f"{source_sha}:docs/canon/references/gate-b-evidence-registry.json",
            ).decode("utf-8")
        )
        entries = registry.get("requirements") if isinstance(registry, Mapping) else None
        if not isinstance(entries, list):
            return 1
        entry = next(
            item
            for item in entries
            if isinstance(item, Mapping) and item.get("evidence_id") == evidence_id
        )
        if entry.get("observation_kind") != _DOMAIN_OBSERVATION_KINDS[evidence_id]:
            return 1
        payload = _gate_b_substantive_payload(
            repo,
            source_sha=source_sha,
            source_tree=source_tree,
            entry=entry,
        )
    except (
        StopIteration,
        OSError,
        UnicodeError,
        ValueError,
        KeyError,
        TypeError,
        json.JSONDecodeError,
        subprocess.CalledProcessError,
        _EvidenceProblem,
    ):
        return 1
    sys.stdout.buffer.write(canonical_json_bytes(payload))
    return 0


if __name__ == "__main__":
    raise SystemExit(_main(sys.argv[1:]))
