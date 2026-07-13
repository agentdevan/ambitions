"""Deterministic, offline benchmark for bounded Codex canon consumption."""

from __future__ import annotations

import hashlib
import json
import os
import re
import stat
import tempfile
from collections.abc import Mapping, Sequence
from dataclasses import dataclass, replace
from pathlib import Path

from tools.ambitions_canon.audit import audit_registry
from tools.ambitions_canon.build import _content_sha_entries, write_outputs_atomic
from tools.ambitions_canon.conflicts import (
    docket_known_issues,
    load_conflict_dockets,
    validate_conflict_repository,
)
from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.model import CanonError, CanonRegistry
from tools.ambitions_canon.registry import build_registry
from tools.ambitions_canon.render import stable_json
from tools.ambitions_canon.task_pack import (
    TaskIntake,
    build_task_pack,
    estimate_tokens,
    require_pack_authorization_current as _require_pack_authorization_current,
    write_task_pack,
)


BENCHMARK_FIXTURE_DIR = Path("tests/canon/fixtures/benchmarks")
BENCHMARK_REPORT = Path("docs/canon/generated/codex-consumption-benchmark.md")
SEMANTIC_COMPARISON = Path(
    "tests/canon/fixtures/benchmark-semantic-evidence/final-semantic-comparison.json"
)
SEMANTIC_EVIDENCE_HASHES = {
    "final-new-pack-evaluation.json": "77616d5171d6cb2ab7fb81b8e02ee1dbfa9d88fc48072fd8622c863a7ec5bad3",
    "final-new-pack-prompt.md": "928a72050ce0f978e2827aa93654e11cda41cc0cfdccaaa55bff6e87bf3d69ec",
    "final-semantic-comparison.json": "c6172e41528ef4cd281aa5c995d6420f3fc8836eb57f0c9ffd646544489ebfb9",
    "old-path-evaluation.json": "dca20fc2ade0981a5aaa6554edd05d2f54ec2782cf18357b2fc8a0e1ad069c3a",
    "old-path-prompt.md": "833c89beb06195668634252bd9407ee371ca54e710add4a41bf5a279f97ae1b1",
}
BENCHMARK_REPOSITORY_STATE = "benchmark-repository-state-v1"
SEMANTIC_REVIEW_PACK_DIR = Path(".codex/canon-semantic-review")
ROOT_SURFACE_LAWS = frozenset(
    {
        "SURFACE-TODAY-IDENTITY-001",
        "SURFACE-GOALS-IDENTITY-001",
        "SURFACE-TIME-IDENTITY-001",
        "SURFACE-YOU-IDENTITY-001",
    }
)
SCENARIO_ORDER = (
    "today-swiftui",
    "time-recurrence",
    "capture-proposal",
    "local-runtime-mutation",
    "cloudkit-continuity",
    "source-atlas-boundary",
    "accessibility-repair",
    "release-proof-claim",
)
_FIXTURE_FIELDS = frozenset(
    {
        "schema_version",
        "scenario_id",
        "title",
        "intake",
        "applicable_requirement_ids",
        "shared_law_allowlist",
        "expected_source_owners",
        "expected_validation",
        "expected_verification_ids",
        "expected_proof",
        "approved_budget_class",
        "approved_budget",
    }
)
_SHA256 = re.compile(r"^[0-9a-f]{64}$")
_GIT_SHA = re.compile(r"^[0-9a-f]{40}$")


@dataclass(frozen=True, slots=True)
class BenchmarkFixture:
    schema_version: int
    scenario_id: str
    title: str
    intake: TaskIntake
    applicable_requirement_ids: tuple[str, ...]
    shared_law_allowlist: tuple[str, ...]
    expected_source_owners: tuple[str, ...]
    expected_validation: tuple[str, ...]
    expected_verification_ids: tuple[str, ...]
    expected_proof: tuple[str, ...]
    approved_budget_class: str
    approved_budget: int
    source_path: Path


@dataclass(frozen=True, slots=True)
class ScenarioResult:
    scenario_id: str
    title: str
    context_characters: int
    context_tokens: int
    approved_budget_class: str
    approved_budget: int
    required_ids_recalled: int
    required_ids_total: int
    approved_ids_present: int
    present_ids_total: int
    shared_laws_recalled: int
    shared_laws_total: int
    missing_required_ids: tuple[str, ...]
    unexpected_requirement_ids: tuple[str, ...]
    missing_shared_laws: tuple[str, ...]
    unexpected_shared_laws: tuple[str, ...]
    contradictory_active_requirement_count: int
    unrelated_root_surface_laws: tuple[str, ...]
    source_owner_mapping_count: int
    required_source_owner_count: int
    approved_source_owner_count: int
    present_source_owner_count: int
    missing_source_owners: tuple[str, ...]
    unexpected_source_owners: tuple[str, ...]
    missing_verification_ids: tuple[str, ...]
    unexpected_verification_ids: tuple[str, ...]
    validation_present: bool
    proof_present: bool
    passed: bool
    pack: dict[str, object]
    included_ids: tuple[str, ...]
    pack_markdown: str


@dataclass(frozen=True, slots=True)
class SemanticDimensionScore:
    dimension: str
    old_score: int
    new_score: int


@dataclass(frozen=True, slots=True)
class SemanticScenarioScore:
    scenario_id: str
    old_score: int
    new_score: int


@dataclass(frozen=True, slots=True)
class SemanticPackEvidence:
    scenario_id: str
    markdown_sha256: str
    json_sha256: str
    applicable_requirement_ids: tuple[str, ...]
    applicable_laws: tuple[str, ...]
    source_owners: tuple[str, ...]
    required_validation: tuple[str, ...]
    required_proof: tuple[str, ...]
    forbidden_changes: tuple[str, ...]
    claim_ceiling: str


@dataclass(frozen=True, slots=True)
class SemanticComparison:
    reviewer: str
    model: str
    prompt_sha256: str
    canon_sha256: str
    git_base_sha: str
    old_evidence_sha256: str
    new_evidence_sha256: str
    score_evidence_sha256: str
    score_max: int
    old_score: int
    new_score: int
    dimension_score_max: int
    dimensions: tuple[SemanticDimensionScore, ...]
    scenario_score_max: int
    scenarios: tuple[SemanticScenarioScore, ...]
    protocol_deviations: tuple[str, ...]
    winner: str
    proof_ceiling: str
    prompt_path: str
    old_evidence_path: str
    new_evidence_path: str
    score_evidence_path: str
    compiler_input_sha256: str
    semantic_recall_numerator: int
    semantic_recall_denominator: int
    semantic_precision_numerator: int
    semantic_precision_denominator: int
    missing_identifier_count: int
    unexpected_identifier_count: int
    owner_false_negative_count: int
    owner_false_positive_count: int
    conclusion: str
    evaluated_pack_hashes: tuple[SemanticPackEvidence, ...]


@dataclass(frozen=True, slots=True)
class BenchmarkResult:
    canon_revision: int
    canon_sha: str
    authority_state: str
    scenarios: tuple[ScenarioResult, ...]
    semantic_comparison: SemanticComparison


def load_benchmark_fixtures(directory: Path) -> tuple[BenchmarkFixture, ...]:
    """Load the exact closed eight-scenario benchmark corpus."""

    fixtures: list[BenchmarkFixture] = []
    for path in sorted(directory.glob("*.json")):
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, UnicodeError, json.JSONDecodeError) as exc:
            raise CanonError(
                "BENCHMARK_FIXTURE_INVALID",
                "benchmark fixture must be valid UTF-8 JSON",
                path,
            ) from exc
        if not isinstance(data, dict) or set(data) != _FIXTURE_FIELDS:
            raise CanonError(
                "BENCHMARK_FIXTURE_INVALID",
                "benchmark fixture fields do not match schema version 1",
                path,
            )
        if isinstance(data["schema_version"], bool) or data["schema_version"] != 2:
            raise CanonError(
                "BENCHMARK_FIXTURE_INVALID",
                "benchmark fixture schema_version must be integer 2",
                path,
            )
        scenario_id = _string(data["scenario_id"], "scenario_id", path)
        title = _string(data["title"], "title", path)
        intake_data = data["intake"]
        if not isinstance(intake_data, Mapping):
            raise CanonError(
                "BENCHMARK_FIXTURE_INVALID", "intake must be an object", path
            )
        approved_budget_class = _string(
            data["approved_budget_class"], "approved_budget_class", path
        )
        approved_budget = data["approved_budget"]
        if (
            isinstance(approved_budget, bool)
            or not isinstance(approved_budget, int)
            or approved_budget < 1
        ):
            raise CanonError(
                "BENCHMARK_FIXTURE_INVALID",
                "approved_budget must be a positive integer",
                path,
            )
        fixtures.append(
            BenchmarkFixture(
                schema_version=2,
                scenario_id=scenario_id,
                title=title,
                intake=TaskIntake.from_json(intake_data).with_source_path(
                    (BENCHMARK_FIXTURE_DIR / path.name).as_posix()
                ),
                applicable_requirement_ids=_strings(
                    data["applicable_requirement_ids"],
                    "applicable_requirement_ids",
                    path,
                ),
                shared_law_allowlist=_strings(
                    data["shared_law_allowlist"], "shared_law_allowlist", path
                ),
                expected_source_owners=_strings(
                    data["expected_source_owners"], "expected_source_owners", path
                ),
                expected_validation=_strings(
                    data["expected_validation"], "expected_validation", path
                ),
                expected_verification_ids=_strings(
                    data["expected_verification_ids"],
                    "expected_verification_ids",
                    path,
                ),
                expected_proof=_strings(
                    data["expected_proof"], "expected_proof", path
                ),
                approved_budget_class=approved_budget_class,
                approved_budget=approved_budget,
                source_path=path,
            )
        )
    scenario_ids = tuple(item.scenario_id for item in fixtures)
    if scenario_ids != SCENARIO_ORDER:
        raise CanonError(
            "BENCHMARK_SCENARIOS_INVALID",
            "benchmark corpus must contain the exact sorted eight scenarios",
            directory,
        )
    return tuple(fixtures)


def load_semantic_comparison(path: Path) -> SemanticComparison:
    """Verify confined semantic evidence bytes and derive the bounded score summary."""

    evidence_root = path.parent
    artifacts: dict[str, bytes] = {}
    for name, expected_sha in SEMANTIC_EVIDENCE_HASHES.items():
        candidate = evidence_root / name
        try:
            info = candidate.lstat()
            content = candidate.read_bytes()
        except OSError as exc:
            raise CanonError(
                "BENCHMARK_SEMANTIC_INVALID",
                "semantic evidence artifact is missing or unreadable",
                candidate,
            ) from exc
        if not stat.S_ISREG(info.st_mode):
            raise CanonError(
                "BENCHMARK_SEMANTIC_INVALID",
                "semantic evidence artifact must be a real regular file",
                candidate,
            )
        actual_sha = hashlib.sha256(content).hexdigest()
        if actual_sha != expected_sha:
            raise CanonError(
                "BENCHMARK_SEMANTIC_STALE",
                f"semantic evidence hash mismatch: {name}",
                candidate,
            )
        artifacts[name] = content

    try:
        comparison = json.loads(artifacts["final-semantic-comparison.json"])
        final_evaluation = json.loads(artifacts["final-new-pack-evaluation.json"])
        json.loads(artifacts["old-path-evaluation.json"])
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "semantic evidence JSON is invalid",
            path,
        ) from exc
    expected_fields = {
        "schema_version",
        "reviewer",
        "model_assignment",
        "evidence",
        "scoring_protocol",
        "paths",
        "winner",
        "score_delta",
        "protocol_deviations",
        "conclusion",
        "proof_ceiling",
    }
    if not isinstance(comparison, dict) or set(comparison) != expected_fields:
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "final semantic comparison fields do not match schema version 2",
            path,
        )
    if comparison.get("schema_version") != 2:
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "final semantic comparison schema_version must be integer 2",
            path,
        )
    evaluation_fields = {
        "reviewer",
        "model",
        "prompt_sha256",
        "compiler_input_sha256",
        "evaluation_metadata",
        "verified_pack_hashes",
        "scenarios",
        "proof_ceiling",
    }
    if not isinstance(final_evaluation, dict) or set(final_evaluation) != evaluation_fields:
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "final semantic evaluation fields do not match the closed v3 contract",
            path,
        )
    evaluation_metadata = final_evaluation.get("evaluation_metadata")
    metadata_fields = {
        "evaluation_base_commit",
        "scenario_count",
        "pack_authority_state",
        "pack_repository_sha",
        "canon_revision",
        "canon_sha256",
        "compiler_version",
        "schema_version",
        "all_binding_hashes_verified",
    }
    if (
        not isinstance(evaluation_metadata, dict)
        or set(evaluation_metadata) != metadata_fields
    ):
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "final evaluation metadata does not match the closed v3 contract",
            path,
        )
    evidence = comparison.get("evidence")
    paths = comparison.get("paths")
    if not isinstance(evidence, dict) or not isinstance(paths, dict):
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "semantic evidence and score paths must be objects",
            path,
        )
    old_binding = evidence.get("old_path")
    new_binding = evidence.get("final_new_pack")
    if not isinstance(old_binding, dict) or not isinstance(new_binding, dict):
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "semantic evidence bindings are missing",
            path,
        )
    expected_old_sha = SEMANTIC_EVIDENCE_HASHES["old-path-evaluation.json"]
    expected_old_prompt_sha = SEMANTIC_EVIDENCE_HASHES["old-path-prompt.md"]
    expected_new_sha = SEMANTIC_EVIDENCE_HASHES["final-new-pack-evaluation.json"]
    expected_prompt_sha = SEMANTIC_EVIDENCE_HASHES["final-new-pack-prompt.md"]
    if (
        old_binding.get("sha256") != expected_old_sha
        or old_binding.get("prompt_sha256") != expected_old_prompt_sha
        or new_binding.get("sha256") != expected_new_sha
        or new_binding.get("prompt_sha256") != expected_prompt_sha
    ):
        raise CanonError(
            "BENCHMARK_SEMANTIC_STALE",
            "semantic comparison does not bind the tracked prompt/response bytes",
            path,
        )
    compiler_input_sha = _semantic_string(
        new_binding.get("compiler_input_sha256"),
        "compiler_input_sha256",
        path,
    )
    evaluation_base = _semantic_string(
        new_binding.get("evaluation_base_commit"),
        "evaluation_base_commit",
        path,
    )
    if _SHA256.fullmatch(compiler_input_sha) is None or _GIT_SHA.fullmatch(
        evaluation_base
    ) is None:
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "compiler input or evaluation base is malformed",
            path,
        )
    prompt_text = artifacts["final-new-pack-prompt.md"].decode("utf-8")
    if compiler_input_sha not in prompt_text or evaluation_base not in prompt_text:
        raise CanonError(
            "BENCHMARK_SEMANTIC_STALE",
            "frozen prompt does not bind compiler input and evaluation base",
            evidence_root / "final-new-pack-prompt.md",
        )
    if (
        final_evaluation.get("reviewer") != "task_21_transitive_final_new_pack_eval"
        or final_evaluation.get("model") != "Ultra"
        or final_evaluation.get("prompt_sha256") != expected_prompt_sha
        or final_evaluation.get("compiler_input_sha256") != compiler_input_sha
        or evaluation_metadata.get("evaluation_base_commit") != evaluation_base
        or evaluation_metadata.get("scenario_count") != len(SCENARIO_ORDER)
        or evaluation_metadata.get("pack_authority_state") != "shadow"
        or evaluation_metadata.get("pack_repository_sha")
        != BENCHMARK_REPOSITORY_STATE
        or evaluation_metadata.get("canon_revision") != 1
        or evaluation_metadata.get("schema_version") != 1
        or evaluation_metadata.get("all_binding_hashes_verified") is not True
    ):
        raise CanonError(
            "BENCHMARK_SEMANTIC_STALE",
            "final response metadata differs from its frozen prompt/comparison",
            evidence_root / "final-new-pack-evaluation.json",
        )

    fixture_hashes = evidence.get("fixture_sha256")
    if not isinstance(fixture_hashes, dict):
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID", "fixture hashes are missing", path
        )
    try:
        repository_root = path.parents[4]
    except IndexError as exc:
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "semantic evidence path is outside the repository fixture tree",
            path,
        ) from exc
    fixtures = load_benchmark_fixtures(repository_root / BENCHMARK_FIXTURE_DIR)
    for fixture in fixtures:
        actual_fixture_sha = hashlib.sha256(fixture.source_path.read_bytes()).hexdigest()
        if fixture_hashes.get(fixture.scenario_id) != actual_fixture_sha:
            raise CanonError(
                "BENCHMARK_SEMANTIC_STALE",
                f"semantic comparison fixture hash mismatch: {fixture.scenario_id}",
                fixture.source_path,
            )

    verification = evidence.get("verification")
    expected_verification = {
        "old_evidence_hash_matches": True,
        "new_evidence_hash_matches": True,
        "old_prompt_hash_matches": True,
        "new_prompt_hash_matches": True,
        "compiler_input_value_matches_prompt_and_new_response": True,
        "compiler_input_independently_recomputed_from_output_corpus": True,
        "evaluation_base_matches_head": True,
        "canon_sha_matches_between_responses_and_all_packs": True,
        "all_sixteen_pack_file_hashes_match_disk_prompt_and_new_response": True,
        "scenario_count_old": len(SCENARIO_ORDER),
        "scenario_count_new": len(SCENARIO_ORDER),
        "scenario_ids_exact_and_ordered_old": True,
        "scenario_ids_exact_and_ordered_new": True,
        "new_semantic_arrays_exact_and_ordered_against_fixtures": True,
        "new_owner_validation_and_proof_arrays_exact_and_ordered": True,
        "release_fixture_task_type": "release",
        "release_fixture_approved_budget_class": "complex",
        "release_fixture_approved_token_budget": 30_000,
        "budget_ceiling_unit": "estimated_tokens",
        "characters_are_informational_only": True,
    }
    if verification != expected_verification:
        raise CanonError(
            "BENCHMARK_SEMANTIC_STALE",
            "semantic verification bindings differ from the approved v3 contract",
            path,
        )

    score_paths = {
        name: paths.get(name) for name in ("old_path", "final_new_pack")
    }
    if not all(isinstance(value, dict) for value in score_paths.values()):
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "semantic score paths are incomplete",
            path,
        )
    old_path = score_paths["old_path"]
    new_path = score_paths["final_new_pack"]
    assert isinstance(old_path, dict) and isinstance(new_path, dict)
    old_aggregate = old_path.get("aggregate")
    new_aggregate = new_path.get("aggregate")
    if not isinstance(old_aggregate, dict) or not isinstance(new_aggregate, dict):
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "semantic aggregate scores are missing",
            path,
        )
    score_max = _integer(new_aggregate.get("total_possible"), "score_max", path)
    old_score = _integer(old_aggregate.get("total"), "old_score", path)
    new_score = _integer(new_aggregate.get("total"), "new_score", path)
    if score_max != 96 or old_score != 63 or new_score != 96:
        raise CanonError(
            "BENCHMARK_SEMANTIC_STALE",
            "semantic aggregate scores differ from frozen evidence",
            path,
        )
    final_recall = new_aggregate.get("exact_identifier_recall")
    final_precision = new_aggregate.get("exact_identifier_precision")
    if not isinstance(final_recall, dict) or not isinstance(final_precision, dict):
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "final semantic recall and precision aggregates are missing",
            path,
        )
    semantic_recall_numerator = _integer(
        final_recall.get("numerator"), "semantic recall numerator", path
    )
    semantic_recall_denominator = _integer(
        final_recall.get("denominator"), "semantic recall denominator", path
    )
    semantic_precision_numerator = _integer(
        final_precision.get("numerator"), "semantic precision numerator", path
    )
    semantic_precision_denominator = _integer(
        final_precision.get("denominator"), "semantic precision denominator", path
    )
    missing_identifier_count = _integer(
        new_aggregate.get("missing_identifier_count"),
        "missing identifier count",
        path,
    )
    unexpected_identifier_count = _integer(
        new_aggregate.get("unexpected_identifier_count"),
        "unexpected identifier count",
        path,
    )
    owner_false_negative_count = _integer(
        new_aggregate.get("owner_false_negative_count"),
        "owner false-negative count",
        path,
    )
    owner_false_positive_count = _integer(
        new_aggregate.get("owner_false_positive_count"),
        "owner false-positive count",
        path,
    )
    semantic_total = sum(
        len(fixture.applicable_requirement_ids)
        + len(fixture.shared_law_allowlist)
        for fixture in fixtures
    )
    if (
        semantic_recall_numerator,
        semantic_recall_denominator,
        semantic_precision_numerator,
        semantic_precision_denominator,
        missing_identifier_count,
        unexpected_identifier_count,
        owner_false_negative_count,
        owner_false_positive_count,
    ) != (
        semantic_total,
        semantic_total,
        semantic_total,
        semantic_total,
        0,
        0,
        0,
        0,
    ):
        raise CanonError(
            "BENCHMARK_SEMANTIC_STALE",
            "final semantic union or owner mapping differs from frozen evidence",
            path,
        )
    protocol = comparison.get("scoring_protocol")
    if not isinstance(protocol, dict):
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID", "scoring protocol is missing", path
        )
    dimension_names = protocol.get("dimensions")
    old_dimensions = old_aggregate.get("dimension_totals")
    new_dimensions = new_aggregate.get("dimension_totals")
    if (
        not isinstance(dimension_names, list)
        or not isinstance(old_dimensions, dict)
        or not isinstance(new_dimensions, dict)
        or tuple(dimension_names) != tuple(old_dimensions)
        or tuple(dimension_names) != tuple(new_dimensions)
    ):
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "semantic dimension rows are not exact and ordered",
            path,
        )
    dimensions = tuple(
        SemanticDimensionScore(
            dimension=str(name).replace("_", "-"),
            old_score=_integer(old_dimensions[name], "old dimension score", path),
            new_score=_integer(new_dimensions[name], "new dimension score", path),
        )
        for name in dimension_names
    )
    old_rows = old_path.get("scenarios")
    new_rows = new_path.get("scenarios")
    evaluation_rows = final_evaluation.get("scenarios")
    if not all(isinstance(rows, list) for rows in (old_rows, new_rows, evaluation_rows)):
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID", "semantic scenario rows are missing", path
        )
    assert isinstance(old_rows, list)
    assert isinstance(new_rows, list)
    assert isinstance(evaluation_rows, list)
    if tuple(row.get("scenario_id") for row in old_rows) != SCENARIO_ORDER or tuple(
        row.get("scenario_id") for row in new_rows
    ) != SCENARIO_ORDER or tuple(
        row.get("scenario_id") for row in evaluation_rows
    ) != SCENARIO_ORDER:
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "semantic scenario IDs are not exact and ordered",
            path,
        )
    scenarios = tuple(
        SemanticScenarioScore(
            scenario_id=scenario_id,
            old_score=_integer(old_rows[index].get("total"), "old scenario score", path),
            new_score=_integer(new_rows[index].get("total"), "new scenario score", path),
        )
        for index, scenario_id in enumerate(SCENARIO_ORDER)
    )
    comparison_pack_hashes = evidence.get("evaluated_pack_hashes")
    evaluation_pack_hashes = final_evaluation.get("verified_pack_hashes")
    if not isinstance(comparison_pack_hashes, dict) or comparison_pack_hashes != evaluation_pack_hashes:
        raise CanonError(
            "BENCHMARK_SEMANTIC_STALE",
            "comparison and response pack hashes differ",
            path,
        )
    pack_evidence: list[SemanticPackEvidence] = []
    for index, scenario_id in enumerate(SCENARIO_ORDER):
        hashes = comparison_pack_hashes.get(scenario_id)
        row = evaluation_rows[index]
        if not isinstance(hashes, dict) or not isinstance(row, dict):
            raise CanonError(
                "BENCHMARK_SEMANTIC_INVALID", "pack evidence row is malformed", path
            )
        markdown_sha = _semantic_string(
            hashes.get("markdown_sha256"), "pack markdown hash", path
        )
        json_sha = _semantic_string(hashes.get("json_sha256"), "pack json hash", path)
        if _SHA256.fullmatch(markdown_sha) is None or _SHA256.fullmatch(json_sha) is None:
            raise CanonError(
                "BENCHMARK_SEMANTIC_INVALID", "pack hashes are malformed", path
            )
        if markdown_sha not in prompt_text or json_sha not in prompt_text:
            raise CanonError(
                "BENCHMARK_SEMANTIC_STALE",
                f"frozen prompt omits pack hashes: {scenario_id}",
                evidence_root / "final-new-pack-prompt.md",
            )
        assumptions = _semantic_strings(
            row.get("assumptions"), "assumptions", path, allow_empty=True
        )
        contradictions = _semantic_strings(
            row.get("contradictions"),
            "contradictions",
            path,
            allow_empty=True,
        )
        comparison_row = new_rows[index]
        if (
            comparison_row.get("reported_assumption_count") != len(assumptions)
            or comparison_row.get("reported_contradiction_count")
            != len(contradictions)
        ):
            raise CanonError(
                "BENCHMARK_SEMANTIC_STALE",
                f"final response assumption/contradiction counts differ: {scenario_id}",
                path,
            )
        pack_evidence.append(
            SemanticPackEvidence(
                scenario_id=scenario_id,
                markdown_sha256=markdown_sha,
                json_sha256=json_sha,
                applicable_requirement_ids=_semantic_strings(
                    row.get("applicable_requirement_ids"),
                    "applicable_requirement_ids",
                    path,
                ),
                applicable_laws=_semantic_strings(
                    row.get("applicable_laws"), "applicable_laws", path
                ),
                source_owners=_semantic_strings(
                    row.get("source_owners"), "source_owners", path
                ),
                required_validation=_semantic_strings(
                    row.get("required_validation"), "required_validation", path
                ),
                required_proof=_semantic_strings(
                    row.get("required_proof"), "required_proof", path
                ),
                forbidden_changes=_semantic_strings(
                    row.get("forbidden_changes"), "forbidden_changes", path
                ),
                claim_ceiling=_semantic_string(
                    row.get("claim_ceiling"), "claim_ceiling", path
                ),
            )
        )
    if sum(item.old_score for item in scenarios) != old_score or sum(
        item.new_score for item in scenarios
    ) != new_score:
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "semantic scenario totals do not equal aggregates",
            path,
        )
    if sum(item.old_score for item in dimensions) != old_score or sum(
        item.new_score for item in dimensions
    ) != new_score:
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "semantic dimension totals do not equal aggregates",
            path,
        )
    if comparison.get("winner") != "new-pack":
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID", "semantic winner is not exact", path
        )
    return SemanticComparison(
        reviewer=_semantic_string(comparison.get("reviewer"), "reviewer", path),
        model=_semantic_string(comparison.get("model_assignment"), "model", path),
        prompt_sha256=expected_prompt_sha,
        canon_sha256=_semantic_string(
            evaluation_metadata.get("canon_sha256"), "canon_sha256", path
        ),
        git_base_sha=evaluation_base,
        old_evidence_sha256=expected_old_sha,
        new_evidence_sha256=expected_new_sha,
        score_evidence_sha256=SEMANTIC_EVIDENCE_HASHES[
            "final-semantic-comparison.json"
        ],
        score_max=score_max,
        old_score=old_score,
        new_score=new_score,
        dimension_score_max=_integer(
            new_aggregate.get("dimension_score_max"),
            "dimension_score_max",
            path,
        ),
        dimensions=dimensions,
        scenario_score_max=_integer(
            protocol.get("scenario_score_max"), "scenario_score_max", path
        ),
        scenarios=scenarios,
        protocol_deviations=_semantic_strings(
            comparison.get("protocol_deviations"),
            "protocol_deviations",
            path,
            allow_empty=True,
        ),
        winner="new-pack",
        proof_ceiling=_semantic_string(
            comparison.get("proof_ceiling"), "proof_ceiling", path
        ),
        prompt_path=(evidence_root / "final-new-pack-prompt.md").as_posix(),
        old_evidence_path=(evidence_root / "old-path-evaluation.json").as_posix(),
        new_evidence_path=(
            evidence_root / "final-new-pack-evaluation.json"
        ).as_posix(),
        score_evidence_path=(
            evidence_root / "final-semantic-comparison.json"
        ).as_posix(),
        compiler_input_sha256=compiler_input_sha,
        semantic_recall_numerator=semantic_recall_numerator,
        semantic_recall_denominator=semantic_recall_denominator,
        semantic_precision_numerator=semantic_precision_numerator,
        semantic_precision_denominator=semantic_precision_denominator,
        missing_identifier_count=missing_identifier_count,
        unexpected_identifier_count=unexpected_identifier_count,
        owner_false_negative_count=owner_false_negative_count,
        owner_false_positive_count=owner_false_positive_count,
        conclusion=_semantic_string(comparison.get("conclusion"), "conclusion", path),
        evaluated_pack_hashes=tuple(pack_evidence),
    )


def run_benchmark(root: Path, fixture_directory: Path) -> BenchmarkResult:
    """Build and measure every representative task pack without network/model use."""

    registry = _load_registry(root)
    known_issues = _known_issues(root, registry)
    fixtures = load_benchmark_fixtures(fixture_directory)
    scenarios = tuple(
        _measure_scenario(registry, known_issues, fixture)
        for fixture in fixtures
    )
    first_pack = scenarios[0].pack
    semantic_comparison = load_semantic_comparison(root / SEMANTIC_COMPARISON)
    if semantic_comparison.canon_sha256 != first_pack["canon_sha"]:
        raise CanonError(
            "BENCHMARK_SEMANTIC_STALE",
            "semantic comparison canon SHA does not match benchmark canon",
            root / SEMANTIC_COMPARISON,
        )
    fixture_by_id = {fixture.scenario_id: fixture for fixture in fixtures}
    evidence_by_id = {
        item.scenario_id: item
        for item in semantic_comparison.evaluated_pack_hashes
    }
    compiler_entries: list[tuple[str, bytes]] = []
    for scenario in scenarios:
        evidence = evidence_by_id[scenario.scenario_id]
        fixture = fixture_by_id[scenario.scenario_id]
        markdown_bytes = scenario.pack_markdown.encode("utf-8")
        json_bytes = stable_json(scenario.pack)
        compiler_entries.extend(
            (
                (f"{scenario.scenario_id}.md", markdown_bytes),
                (f"{scenario.scenario_id}.json", json_bytes),
            )
        )
        if (
            hashlib.sha256(markdown_bytes).hexdigest()
            != evidence.markdown_sha256
            or hashlib.sha256(json_bytes).hexdigest() != evidence.json_sha256
            or tuple(scenario.pack["applicable_requirement_ids"])
            != evidence.applicable_requirement_ids
            or tuple(scenario.pack["constitutional_laws"])
            != evidence.applicable_laws
            or tuple(scenario.pack["source_owners"]) != evidence.source_owners
            or tuple(scenario.pack["required_validation"])
            != evidence.required_validation
            or tuple(scenario.pack["required_proof"]) != evidence.required_proof
            or tuple(scenario.pack["forbidden_changes"])
            != evidence.forbidden_changes
            or scenario.pack["claim_ceiling"] != evidence.claim_ceiling
            or set(evidence.applicable_requirement_ids)
            | set(evidence.applicable_laws)
            != set(fixture.applicable_requirement_ids)
            | set(fixture.shared_law_allowlist)
        ):
            raise CanonError(
                "BENCHMARK_SEMANTIC_STALE",
                f"tracked semantic evidence differs from current pack: {scenario.scenario_id}",
                root / SEMANTIC_COMPARISON,
            )
    if (
        _content_sha_entries(compiler_entries)
        != semantic_comparison.compiler_input_sha256
    ):
        raise CanonError(
            "BENCHMARK_SEMANTIC_STALE",
            "framed compiler input differs from current 16 pack bytes",
            root / SEMANTIC_COMPARISON,
        )
    return BenchmarkResult(
        canon_revision=registry.manifest.canon_revision,
        canon_sha=str(first_pack["canon_sha"]),
        authority_state=registry.manifest.authority_state.value,
        scenarios=scenarios,
        semantic_comparison=semantic_comparison,
    )


def _measure_scenario(
    registry: CanonRegistry,
    known_issues: Sequence[Mapping[str, object]],
    fixture: BenchmarkFixture,
) -> ScenarioResult:
    pack = build_task_pack(
        registry,
        fixture.intake,
        BENCHMARK_REPOSITORY_STATE,
        known_issues,
    )
    if (
        pack.budget_class != fixture.approved_budget_class
        or pack.token_budget != fixture.approved_budget
    ):
        raise CanonError(
            "BENCHMARK_BUDGET_CONTRACT_MISMATCH",
            "fixture budget class or token ceiling differs from generated pack",
            fixture.source_path,
        )
    markdown = pack.to_markdown()
    present_ids = frozenset(
        (*pack.applicable_requirement_ids, *pack.constitutional_laws)
    )
    actual_laws = frozenset(pack.constitutional_laws)
    actual_requirements = frozenset(pack.applicable_requirement_ids)
    expected_requirements = frozenset(fixture.applicable_requirement_ids)
    expected_laws = frozenset(fixture.shared_law_allowlist)
    missing_ids = tuple(sorted(expected_requirements - actual_requirements))
    unexpected_ids = tuple(sorted(actual_requirements - expected_requirements))
    missing_laws = tuple(sorted(expected_laws - actual_laws))
    unexpected_laws = tuple(sorted(actual_laws - expected_laws))
    unrelated_root_laws = tuple(sorted((ROOT_SURFACE_LAWS & actual_laws) - expected_laws))
    actual_owners = frozenset(pack.source_owners)
    expected_owners = frozenset(fixture.expected_source_owners)
    missing_owners = tuple(sorted(expected_owners - actual_owners))
    unexpected_owners = tuple(sorted(actual_owners - expected_owners))
    actual_verification = frozenset(pack.required_tests)
    expected_verification = frozenset(fixture.expected_verification_ids)
    missing_verification = tuple(sorted(expected_verification - actual_verification))
    unexpected_verification = tuple(sorted(actual_verification - expected_verification))
    validation_present = tuple(pack.required_validation) == fixture.expected_validation
    proof_present = tuple(pack.required_proof) == fixture.expected_proof
    contradictions = _active_contradictions(
        registry,
        present_ids,
        tuple(pack.open_conflicts),
    )
    context_characters = len(markdown)
    context_tokens = estimate_tokens(markdown)
    passed = not any(
        (
            missing_ids,
            unexpected_ids,
            missing_laws,
            unexpected_laws,
            missing_owners,
            unexpected_owners,
            missing_verification,
            unexpected_verification,
            contradictions,
        )
    ) and all(
        (
            validation_present,
            proof_present,
            context_tokens <= fixture.approved_budget,
        )
    )
    return ScenarioResult(
        scenario_id=fixture.scenario_id,
        title=fixture.title,
        context_characters=context_characters,
        context_tokens=context_tokens,
        approved_budget_class=fixture.approved_budget_class,
        approved_budget=fixture.approved_budget,
        required_ids_recalled=len(expected_requirements) - len(missing_ids),
        required_ids_total=len(expected_requirements),
        approved_ids_present=len(actual_requirements) - len(unexpected_ids),
        present_ids_total=len(actual_requirements),
        shared_laws_recalled=len(expected_laws) - len(missing_laws),
        shared_laws_total=len(expected_laws),
        missing_required_ids=missing_ids,
        unexpected_requirement_ids=unexpected_ids,
        missing_shared_laws=missing_laws,
        unexpected_shared_laws=unexpected_laws,
        contradictory_active_requirement_count=len(contradictions),
        unrelated_root_surface_laws=unrelated_root_laws,
        source_owner_mapping_count=len(expected_owners) - len(missing_owners),
        required_source_owner_count=len(expected_owners),
        approved_source_owner_count=len(actual_owners) - len(unexpected_owners),
        present_source_owner_count=len(actual_owners),
        missing_source_owners=missing_owners,
        unexpected_source_owners=unexpected_owners,
        missing_verification_ids=missing_verification,
        unexpected_verification_ids=unexpected_verification,
        validation_present=validation_present,
        proof_present=proof_present,
        passed=passed,
        pack=pack.to_dict(),
        included_ids=tuple(sorted(present_ids)),
        pack_markdown=markdown,
    )


def _active_contradictions(
    registry: CanonRegistry,
    selected_ids: frozenset[str],
    open_conflicts: tuple[str, ...],
) -> tuple[str, ...]:
    """Return selected unresolved dockets or incompatible active modalities."""

    contradictions = set(open_conflicts)
    grouped: dict[tuple[str, str], dict[str, list[str]]] = {}
    for requirement in registry.requirements:
        if requirement.requirement_id not in selected_ids or requirement.status != "normative":
            continue
        modalities = grouped.setdefault((requirement.concept, requirement.scope), {})
        modalities.setdefault(requirement.modality.value, []).append(
            requirement.requirement_id
        )
    for modalities in grouped.values():
        if "MUST" in modalities and "MUST NOT" in modalities:
            contradictions.update(modalities["MUST"])
            contradictions.update(modalities["MUST NOT"])
    return tuple(sorted(contradictions))


def require_pack_authorization_current(
    stored: Mapping[str, object],
    current: Mapping[str, object],
) -> None:
    """Expose the task-pack fail-closed authorization guard to benchmark probes."""

    _require_pack_authorization_current(stored, current)


def render_benchmark_report(result: BenchmarkResult) -> str:
    """Render deterministic tracked benchmark evidence with a bounded proof ceiling."""

    lines = [
        "# Codex Canon Consumption Benchmark",
        "",
        "> Deterministic offline benchmark evidence; not product, runtime, visual, accessibility, privacy, device, TestFlight, App Store, or release proof.",
        "",
        f"- Canon revision: `{result.canon_revision}`",
        f"- Canon SHA: `{result.canon_sha}`",
        f"- Authority state: `{result.authority_state}`",
        "- Token estimate: deterministic four-characters-per-token ceiling",
        "",
        "## Deterministic scenario measures",
        "",
        "| Scenario | Characters (informational) | Estimated tokens | Budget class | Token ceiling | Requirement recall | Requirement precision | Shared laws | Contradictions | Owner recall | Owner precision | Verification | Validation | Proof | Result |",
        "| --- | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- | --- |",
    ]
    for scenario in result.scenarios:
        lines.append(
            "| "
            + " | ".join(
                (
                    f"`{scenario.scenario_id}`",
                    str(scenario.context_characters),
                    str(scenario.context_tokens),
                    f"`{scenario.approved_budget_class}`",
                    str(scenario.approved_budget),
                    f"{scenario.required_ids_recalled}/{scenario.required_ids_total}",
                    f"{scenario.approved_ids_present}/{scenario.present_ids_total}",
                    f"{scenario.shared_laws_recalled}/{scenario.shared_laws_total}",
                    str(scenario.contradictory_active_requirement_count),
                    f"{scenario.source_owner_mapping_count}/{scenario.required_source_owner_count}",
                    f"{scenario.approved_source_owner_count}/{scenario.present_source_owner_count}",
                    "exact" if not scenario.missing_verification_ids and not scenario.unexpected_verification_ids else "mismatch",
                    "present" if scenario.validation_present else "missing",
                    "present" if scenario.proof_present else "missing",
                    "PASS" if scenario.passed else "FAIL",
                )
            )
            + " |"
        )
    lines.extend(
        (
            "",
            "## Resume-safe authorization checks",
            "",
            "A stored pack fails closed after canon revision or content, Git HEAD or diff, intake or issue identity, source ownership, conflicts or known issues, and validation/proof posture changes.",
            "",
            "## Semantic quality comparison",
            "",
            "Semantic quality comparison is separate evidence and never a CI, network, or LLM dependency.",
            "",
            f"- Reviewer: `{result.semantic_comparison.reviewer}`",
            f"- Model: `{result.semantic_comparison.model}`",
            f"- Prompt SHA: `{result.semantic_comparison.prompt_sha256}`",
            f"- Compiler input SHA: `{result.semantic_comparison.compiler_input_sha256}`",
            "- Compiler input verification: independently recomputed from the current 16 framed pack files",
            f"- Canon SHA: `{result.semantic_comparison.canon_sha256}`",
            f"- Git base: `{result.semantic_comparison.git_base_sha}`",
            f"- Old evidence SHA: `{result.semantic_comparison.old_evidence_sha256}`",
            f"- New evidence SHA: `{result.semantic_comparison.new_evidence_sha256}`",
            f"- Score evidence SHA: `{result.semantic_comparison.score_evidence_sha256}`",
            "- Tracked evidence directory: `tests/canon/fixtures/benchmark-semantic-evidence/`",
            "",
            "| Response path | Score |",
            "| --- | ---: |",
            f"| Old truth-file path | {result.semantic_comparison.old_score}/{result.semantic_comparison.score_max} |",
            f"| New task pack | {result.semantic_comparison.new_score}/{result.semantic_comparison.score_max} |",
            "",
            f"- Final semantic-ID recall: `{result.semantic_comparison.semantic_recall_numerator}/{result.semantic_comparison.semantic_recall_denominator}`",
            f"- Final semantic-ID precision: `{result.semantic_comparison.semantic_precision_numerator}/{result.semantic_comparison.semantic_precision_denominator}`",
            f"- Final missing/unexpected IDs: `{result.semantic_comparison.missing_identifier_count}/{result.semantic_comparison.unexpected_identifier_count}`",
            f"- Final owner false negatives/false positives: `{result.semantic_comparison.owner_false_negative_count}/{result.semantic_comparison.owner_false_positive_count}`",
            "",
            "| Dimension | Old | New |",
            "| --- | ---: | ---: |",
        )
    )
    for dimension in result.semantic_comparison.dimensions:
        lines.append(
            f"| `{dimension.dimension}` | {dimension.old_score}/{result.semantic_comparison.dimension_score_max} | {dimension.new_score}/{result.semantic_comparison.dimension_score_max} |"
        )
    lines.extend(
        (
            "",
            "| Scenario | Old | New |",
            "| --- | ---: | ---: |",
        )
    )
    for scenario in result.semantic_comparison.scenarios:
        lines.append(
            f"| `{scenario.scenario_id}` | {scenario.old_score}/{result.semantic_comparison.scenario_score_max} | {scenario.new_score}/{result.semantic_comparison.scenario_score_max} |"
        )
    lines.extend(("", "Protocol deviations:", ""))
    lines.extend(
        f"- {deviation}"
        for deviation in result.semantic_comparison.protocol_deviations
    )
    lines.extend(
        (
            "",
            result.semantic_comparison.conclusion,
            "",
            "## Proof ceiling",
            "",
            result.semantic_comparison.proof_ceiling,
            "The deterministic benchmark separately proves only pack construction and the measured fixture assertions at the recorded shadow canon; it does not authorize implementation.",
        )
    )
    return "\n".join(lines).rstrip() + "\n"


def write_benchmark_report(path: Path, result: BenchmarkResult) -> None:
    """Atomically replace the benchmark report with newline-terminated bytes."""

    content = render_benchmark_report(result).encode("utf-8")
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(
        prefix=f".{path.name}.", suffix=".tmp", dir=path.parent
    )
    temporary_path = Path(temporary)
    try:
        with os.fdopen(descriptor, "wb") as handle:
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary_path, path)
    except BaseException:
        temporary_path.unlink(missing_ok=True)
        raise


def check_benchmark_report(path: Path, result: BenchmarkResult) -> None:
    """Reject missing or stale tracked benchmark bytes."""

    expected = render_benchmark_report(result).encode("utf-8")
    try:
        actual = path.read_bytes()
    except OSError as exc:
        raise CanonError(
            "BENCHMARK_OUTPUT_STALE", "benchmark report is missing or unreadable", path
        ) from exc
    if actual != expected:
        raise CanonError(
            "BENCHMARK_OUTPUT_STALE",
            "benchmark report differs from deterministic output",
            path,
        )


def write_representative_packs(
    root: Path,
    fixture_directory: Path,
    repository_sha: str,
) -> tuple[Path, ...]:
    """Write ignored closed intakes and representative pack pairs for review."""

    registry = _load_registry(root)
    known_issues = _known_issues(root, registry)
    outputs: list[Path] = []
    intake_root = root / ".codex" / "canon-benchmark-intakes"
    intake_root.mkdir(parents=True, exist_ok=True)
    for fixture in load_benchmark_fixtures(fixture_directory):
        intake_path = intake_root / f"{fixture.scenario_id}.json"
        payload = {
            "schema_version": fixture.intake.schema_version,
            "issue_id": fixture.intake.issue_id,
            "task_type": fixture.intake.task_type,
            "scope": list(fixture.intake.scope),
            "changed_files": list(fixture.intake.changed_files),
            "claim_type": fixture.intake.claim_type,
            "known_issue_ids": list(fixture.intake.known_issue_ids),
        }
        _write_json_atomic(intake_path, payload)
        intake = TaskIntake.from_json(payload).with_source_path(
            intake_path.relative_to(root).as_posix()
        )
        pack = build_task_pack(registry, intake, repository_sha, known_issues)
        markdown_path, json_path = write_task_pack(root, pack)
        outputs.extend((markdown_path, json_path))
    return tuple(outputs)


def write_semantic_review_packs(
    root: Path,
    fixture_directory: Path,
) -> tuple[Path, ...]:
    """Write stable ignored pack bytes for independent semantic evaluation."""

    registry = _load_registry(root)
    known_issues = _known_issues(root, registry)
    outputs: dict[Path, bytes] = {}
    for fixture in load_benchmark_fixtures(fixture_directory):
        intake = replace(
            fixture.intake,
            source_path=(BENCHMARK_FIXTURE_DIR / fixture.source_path.name).as_posix(),
        )
        pack = build_task_pack(
            registry,
            intake,
            BENCHMARK_REPOSITORY_STATE,
            known_issues,
        )
        outputs[Path(f"{fixture.scenario_id}.md")] = pack.to_markdown().encode(
            "utf-8"
        )
        outputs[Path(f"{fixture.scenario_id}.json")] = pack.to_json_bytes()
    output_root = root / SEMANTIC_REVIEW_PACK_DIR
    write_outputs_atomic(output_root, outputs)
    return tuple(output_root / path for path in sorted(outputs))


def _write_json_atomic(path: Path, payload: Mapping[str, object]) -> None:
    content = (
        json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    ).encode("utf-8")
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(
        prefix=f".{path.name}.", suffix=".tmp", dir=path.parent
    )
    temporary_path = Path(temporary)
    try:
        with os.fdopen(descriptor, "wb") as handle:
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary_path, path)
    except BaseException:
        temporary_path.unlink(missing_ok=True)
        raise


def _load_registry(root: Path) -> CanonRegistry:
    manifest = load_manifest(root)
    registry = build_registry(manifest, load_documents(root, manifest))
    findings = audit_registry(registry)
    if findings:
        finding = findings[0]
        raise CanonError(finding.code, finding.message, finding.path, finding.line)
    return registry


def _known_issues(
    root: Path, registry: CanonRegistry
) -> tuple[dict[str, object], ...]:
    dockets = load_conflict_dockets(root)
    validate_conflict_repository(
        root,
        dockets,
        (item.requirement_id for item in registry.requirements),
        registry.supersession_entries,
    )
    return docket_known_issues(dockets)


def _integer(value: object, field: str, path: Path) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value < 0:
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            f"{field} must be a non-negative integer",
            path,
        )
    return value


def _score_rows(
    value: object,
    *,
    key: str,
    expected: tuple[str, ...],
    maximum: int,
    path: Path,
    row_type: type[SemanticDimensionScore] | type[SemanticScenarioScore],
) -> tuple[SemanticDimensionScore, ...] | tuple[SemanticScenarioScore, ...]:
    if not isinstance(value, list):
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID", "score rows must be an array", path
        )
    rows: list[SemanticDimensionScore | SemanticScenarioScore] = []
    for raw in value:
        if not isinstance(raw, dict) or set(raw) != {key, "old_score", "new_score"}:
            raise CanonError(
                "BENCHMARK_SEMANTIC_INVALID",
                "score row fields do not match the closed contract",
                path,
            )
        identifier = _semantic_string(raw[key], key, path)
        old_score = _integer(raw["old_score"], "old_score", path)
        new_score = _integer(raw["new_score"], "new_score", path)
        if old_score > maximum or new_score > maximum:
            raise CanonError(
                "BENCHMARK_SEMANTIC_INVALID",
                "score row exceeds its closed range",
                path,
            )
        rows.append(row_type(identifier, old_score, new_score))
    if tuple(getattr(row, key) for row in rows) != expected:
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            "score rows do not match the exact ordered comparison contract",
            path,
        )
    return tuple(rows)


def _semantic_string(value: object, field: str, path: Path) -> str:
    if not isinstance(value, str) or not value.strip():
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            f"{field} must be a non-empty string",
            path,
        )
    return value


def _semantic_strings(
    value: object,
    field: str,
    path: Path,
    *,
    allow_empty: bool = False,
) -> tuple[str, ...]:
    if not isinstance(value, list) or (not allow_empty and not value):
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID", f"{field} must be a JSON array", path
        )
    result = tuple(_semantic_string(item, field, path) for item in value)
    if len(result) != len(set(result)):
        raise CanonError(
            "BENCHMARK_SEMANTIC_INVALID",
            f"{field} must contain unique values",
            path,
        )
    return result


def _string(value: object, field: str, path: Path) -> str:
    if not isinstance(value, str) or not value.strip():
        raise CanonError(
            "BENCHMARK_FIXTURE_INVALID", f"{field} must be a non-empty string", path
        )
    return value


def _strings(
    value: object,
    field: str,
    path: Path,
    *,
    allow_empty: bool = False,
) -> tuple[str, ...]:
    if not isinstance(value, list) or (not value and not allow_empty):
        raise CanonError(
            "BENCHMARK_FIXTURE_INVALID", f"{field} must be a JSON array", path
        )
    result = tuple(_string(item, field, path) for item in value)
    if len(result) != len(set(result)):
        raise CanonError(
            "BENCHMARK_FIXTURE_INVALID", f"{field} must contain unique values", path
        )
    return result
