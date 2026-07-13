"""Deterministic, offline benchmark for bounded Codex canon consumption."""

from __future__ import annotations

import hashlib
import json
import os
import re
import tempfile
from collections.abc import Mapping, Sequence
from dataclasses import dataclass
from pathlib import Path

from tools.ambitions_canon.audit import audit_registry
from tools.ambitions_canon.build import write_outputs_atomic
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
    load_task_pack_traceability,
    require_pack_authorization_current as _require_pack_authorization_current,
    write_task_pack,
)


BENCHMARK_FIXTURE_DIR = Path("tests/canon/fixtures/benchmarks")
BENCHMARK_REPORT = Path("docs/canon/generated/codex-consumption-benchmark.md")
BENCHMARK_REPOSITORY_STATE = "benchmark-repository-state-v1"
SEMANTIC_REVIEW_PACK_DIR = Path(".codex/canon-semantic-review")
SEMANTIC_REVIEW_TRUTH_PATHS = (
    Path("docs/truth/README.md"),
    Path("docs/truth/CODEX_START_HERE.md"),
    Path("docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md"),
    Path("docs/truth/PRODUCT_DESIGN_TRUTH.md"),
    Path("docs/truth/PRODUCT_EXPERIENCE_CANON.md"),
    Path("docs/truth/IMPLEMENTATION_TRUTH.md"),
    Path("docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md"),
    Path("docs/truth/RELEASE_TRUTH.md"),
    Path("docs/truth/CODEX_PROCESS_TRUTH.md"),
)
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
SEMANTIC_COMPARISON_DIMENSIONS = (
    "semantic_equivalence",
    "relevant_law_recall",
    "contradiction_control",
    "unauthorized_assumptions",
    "source_ownership",
    "validation_completeness",
    "proof_discipline",
)
_SEMANTIC_COMPARISON_FIELDS = frozenset(
    {
        "schema_version",
        "comparison_reviewer",
        "comparison_model",
        "canon_sha256",
        "old_prompt_sha256",
        "new_prompt_sha256",
        "old_response_sha256",
        "new_response_sha256",
        "dimensions",
        "overall_verdict",
        "old_total_score",
        "new_total_score",
    }
)
_SEMANTIC_DIMENSION_FIELDS = frozenset(
    {"dimension", "verdict", "old_score", "new_score", "rationale"}
)
_SEMANTIC_VERDICTS = frozenset(
    {"old_better", "new_better", "equivalent", "insufficient_evidence"}
)


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
class BenchmarkResult:
    canon_revision: int
    canon_sha: str
    authority_state: str
    scenarios: tuple[ScenarioResult, ...]


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



def run_benchmark(root: Path, fixture_directory: Path) -> BenchmarkResult:
    """Build and measure every representative task pack without network/model use."""

    registry = _load_registry(root)
    known_issues = _known_issues(root, registry)
    traceability = load_task_pack_traceability(root, registry)
    fixtures = load_benchmark_fixtures(fixture_directory)
    scenarios = tuple(
        _measure_scenario(registry, known_issues, fixture, traceability)
        for fixture in fixtures
    )
    first_pack = scenarios[0].pack
    return BenchmarkResult(
        canon_revision=registry.manifest.canon_revision,
        canon_sha=str(first_pack["canon_sha"]),
        authority_state=registry.manifest.authority_state.value,
        scenarios=scenarios,
    )


def _measure_scenario(
    registry: CanonRegistry,
    known_issues: Sequence[Mapping[str, object]],
    fixture: BenchmarkFixture,
    traceability: object | None = None,
) -> ScenarioResult:
    pack = build_task_pack(
        registry,
        fixture.intake,
        BENCHMARK_REPOSITORY_STATE,
        known_issues,
        traceability=traceability,
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
    proof_present = set(fixture.expected_proof).issubset(pack.required_proof)
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


def render_semantic_review_prompt(
    fixtures: Sequence[BenchmarkFixture],
    *,
    context_label: str,
    context_entries: Sequence[str],
) -> str:
    """Render one fixture-blind prompt from the shared semantic-review protocol."""

    lines = [
        "# Ambitions Canon Semantic Review",
        "",
        f"- Comparison path: `{context_label}`",
        "- Lane: explicit non-CI independent semantic review",
        "",
        "## Symmetric task instructions",
        "",
        "Evaluate only the supplied context for each scenario. Do not infer an expected answer from benchmark fixtures or another response path. Return one independent response per scenario with the laws and source owners you believe apply, required validation and proof, assumptions, contradictions, and claim ceiling.",
        "",
        "Compare semantic equivalence, relevant-law recall, contradiction control, unauthorized assumptions, source ownership, validation completeness, and proof discipline. A separate reviewer may score the two blinded response sets only after both are complete.",
        "",
        "Scenario tasks:",
        "",
    ]
    for fixture in fixtures:
        lines.append(
            "- "
            f"`{fixture.scenario_id}` — {fixture.title}; "
            f"task type `{fixture.intake.task_type}`; "
            f"scope {', '.join(fixture.intake.scope)}; "
            f"changed files {', '.join(fixture.intake.changed_files)}; "
            f"claim type `{fixture.intake.claim_type}`."
        )
    lines.extend(("", "## Supplied context", ""))
    lines.extend(f"- `{entry}`" for entry in context_entries)
    lines.extend(
        (
            "",
            "## Evidence boundary",
            "",
            "This prompt contains no expected answer arrays or scoring fixture. Record the reviewer, model, prompt hash, canon hash, context or pack hashes, and response evidence hash before any comparison claim.",
        )
    )
    return "\n".join(lines).rstrip() + "\n"


def build_semantic_review_bundle(
    root: Path,
    fixture_directory: Path,
    *,
    reviewer: str,
    model: str,
    old_response: bytes | None = None,
    new_response: bytes | None = None,
    comparison: bytes | None = None,
) -> dict[Path, bytes]:
    """Build an ignored, explicit, non-CI semantic-review evidence bundle."""

    reviewer = _semantic_string(reviewer, "reviewer", root)
    model = _semantic_string(model, "model", root)
    if (old_response is None) != (new_response is None):
        raise CanonError(
            "BENCHMARK_SEMANTIC_RESPONSE_PAIR_REQUIRED",
            "old and new semantic responses must be supplied together",
        )
    if comparison is not None and old_response is None:
        raise CanonError(
            "BENCHMARK_SEMANTIC_COMPARISON_RESPONSE_REQUIRED",
            "comparison evidence requires both blinded response artifacts",
            root,
        )

    registry = _load_registry(root)
    known_issues = _known_issues(root, registry)
    traceability = load_task_pack_traceability(root, registry)
    fixtures = load_benchmark_fixtures(fixture_directory)
    outputs: dict[Path, bytes] = {}
    pack_hashes: list[dict[str, str]] = []
    new_context_entries: list[str] = []
    for fixture in fixtures:
        pack = build_task_pack(
            registry,
            fixture.intake,
            BENCHMARK_REPOSITORY_STATE,
            known_issues,
            traceability=traceability,
        )
        markdown_path = Path("new-task-packs") / f"{fixture.scenario_id}.md"
        json_path = Path("new-task-packs") / f"{fixture.scenario_id}.json"
        markdown_bytes = pack.to_markdown().encode("utf-8")
        json_bytes = pack.to_json_bytes()
        outputs[markdown_path] = markdown_bytes
        outputs[json_path] = json_bytes
        markdown_sha = hashlib.sha256(markdown_bytes).hexdigest()
        json_sha = hashlib.sha256(json_bytes).hexdigest()
        pack_hashes.append(
            {
                "scenario_id": fixture.scenario_id,
                "markdown_sha256": markdown_sha,
                "json_sha256": json_sha,
            }
        )
        new_context_entries.append(
            f"{markdown_path.as_posix()} sha256={markdown_sha}; "
            f"{json_path.as_posix()} sha256={json_sha}"
        )

    old_context_entries: list[str] = []
    for relative in SEMANTIC_REVIEW_TRUTH_PATHS:
        content = (root / relative).read_bytes()
        old_context_entries.append(
            f"{relative.as_posix()} sha256={hashlib.sha256(content).hexdigest()}"
        )
    old_prompt = render_semantic_review_prompt(
        fixtures,
        context_label="old-truth-path",
        context_entries=old_context_entries,
    ).encode("utf-8")
    new_prompt = render_semantic_review_prompt(
        fixtures,
        context_label="new-task-packs",
        context_entries=new_context_entries,
    ).encode("utf-8")
    outputs[Path("old-path-prompt.md")] = old_prompt
    outputs[Path("new-pack-prompt.md")] = new_prompt

    if old_response is not None and new_response is not None:
        outputs[Path("responses/old-response.json")] = old_response
        outputs[Path("responses/new-response.json")] = new_response
    record: dict[str, object] = {
        "schema_version": 1,
        "lane": "explicit_non_ci_semantic_review",
        "reviewer": reviewer,
        "model": model,
        "canon_revision": registry.manifest.canon_revision,
        "canon_sha256": _registry_canon_sha_for_review(registry),
        "old_prompt_sha256": hashlib.sha256(old_prompt).hexdigest(),
        "new_prompt_sha256": hashlib.sha256(new_prompt).hexdigest(),
        "pack_hashes": pack_hashes,
        "old_response_sha256": (
            hashlib.sha256(old_response).hexdigest()
            if old_response is not None
            else None
        ),
        "new_response_sha256": (
            hashlib.sha256(new_response).hexdigest()
            if new_response is not None
            else None
        ),
        "status": (
            "responses_recorded_pending_blinded_comparison"
            if old_response is not None
            else "awaiting_independent_responses"
        ),
        "comparison_dimensions": list(SEMANTIC_COMPARISON_DIMENSIONS),
        "claim_posture": "No winner or semantic-quality score is claimed by bundle generation.",
    }
    if comparison is not None:
        comparison_record = _validate_semantic_comparison(comparison, record, root)
        outputs[Path("comparison/comparison.json")] = comparison
        record.update(
            {
                "status": "comparison_recorded",
                "comparison_sha256": hashlib.sha256(comparison).hexdigest(),
                "comparison_reviewer": comparison_record["comparison_reviewer"],
                "comparison_model": comparison_record["comparison_model"],
                "comparison_overall_verdict": comparison_record["overall_verdict"],
                "comparison_old_total_score": comparison_record["old_total_score"],
                "comparison_new_total_score": comparison_record["new_total_score"],
                "claim_posture": (
                    "Independent comparison evidence is recorded as supplied; bundle "
                    "generation does not invent or independently endorse its result."
                ),
            }
        )
    outputs[Path("semantic-review-record.json")] = stable_json(record)
    return outputs


def write_semantic_review_bundle(
    root: Path,
    fixture_directory: Path,
    *,
    reviewer: str,
    model: str,
    old_response: bytes | None = None,
    new_response: bytes | None = None,
    comparison: bytes | None = None,
) -> tuple[Path, ...]:
    outputs = build_semantic_review_bundle(
        root,
        fixture_directory,
        reviewer=reviewer,
        model=model,
        old_response=old_response,
        new_response=new_response,
        comparison=comparison,
    )
    output_root = root / SEMANTIC_REVIEW_PACK_DIR
    write_outputs_atomic(output_root, outputs)
    return tuple(output_root / path for path in sorted(outputs))


def _validate_semantic_comparison(
    source_bytes: bytes,
    binding: Mapping[str, object],
    path: Path,
) -> Mapping[str, object]:
    """Validate an independently produced comparison without scoring it."""

    try:
        data = json.loads(source_bytes.decode("utf-8"))
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise CanonError(
            "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
            "comparison evidence must be valid UTF-8 JSON",
            path,
        ) from exc
    if not isinstance(data, dict) or set(data) != _SEMANTIC_COMPARISON_FIELDS:
        raise CanonError(
            "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
            "comparison evidence fields do not match schema version 1",
            path,
        )
    if type(data["schema_version"]) is not int or data["schema_version"] != 1:
        raise CanonError(
            "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
            "comparison schema_version must be integer 1",
            path,
        )
    for field in ("comparison_reviewer", "comparison_model"):
        if not isinstance(data[field], str) or not data[field].strip():
            raise CanonError(
                "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
                f"{field} must be a non-empty string",
                path,
            )
    bindings = {
        "canon_sha256": binding["canon_sha256"],
        "old_prompt_sha256": binding["old_prompt_sha256"],
        "new_prompt_sha256": binding["new_prompt_sha256"],
        "old_response_sha256": binding["old_response_sha256"],
        "new_response_sha256": binding["new_response_sha256"],
    }
    if any(data[field] != expected for field, expected in bindings.items()):
        raise CanonError(
            "BENCHMARK_SEMANTIC_COMPARISON_STALE",
            "comparison evidence hashes do not bind the current canon, prompts, and responses",
            path,
        )
    dimensions = data["dimensions"]
    if not isinstance(dimensions, list) or len(dimensions) != len(
        SEMANTIC_COMPARISON_DIMENSIONS
    ):
        raise CanonError(
            "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
            "comparison must contain all seven dimensions exactly once",
            path,
        )
    parsed_dimensions: list[str] = []
    old_total = 0
    new_total = 0
    for row in dimensions:
        if not isinstance(row, dict) or set(row) != _SEMANTIC_DIMENSION_FIELDS:
            raise CanonError(
                "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
                "comparison dimension fields are closed",
                path,
            )
        dimension = row["dimension"]
        if not isinstance(dimension, str):
            raise CanonError(
                "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
                "comparison dimension identifier must be a string",
                path,
            )
        parsed_dimensions.append(dimension)
        if row["verdict"] not in _SEMANTIC_VERDICTS:
            raise CanonError(
                "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
                "comparison verdict is outside the bounded vocabulary",
                path,
            )
        if not isinstance(row["rationale"], str) or not row["rationale"].strip():
            raise CanonError(
                "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
                "comparison rationale must be a non-empty string",
                path,
            )
        for field in ("old_score", "new_score"):
            score = row[field]
            if type(score) is not int or not 0 <= score <= 4:
                raise CanonError(
                    "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
                    "comparison dimension scores must be integers from 0 through 4",
                    path,
                )
        old_total += row["old_score"]
        new_total += row["new_score"]
    if tuple(parsed_dimensions) != SEMANTIC_COMPARISON_DIMENSIONS:
        raise CanonError(
            "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
            "comparison dimensions must be the exact ordered seven-dimension contract",
            path,
        )
    if data["overall_verdict"] not in _SEMANTIC_VERDICTS:
        raise CanonError(
            "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
            "overall verdict is outside the bounded vocabulary",
            path,
        )
    if (
        type(data["old_total_score"]) is not int
        or type(data["new_total_score"]) is not int
        or data["old_total_score"] != old_total
        or data["new_total_score"] != new_total
    ):
        raise CanonError(
            "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
            "comparison total scores must equal the seven bounded dimension scores",
            path,
        )
    return data


def _registry_canon_sha_for_review(registry: CanonRegistry) -> str:
    from tools.ambitions_canon.task_pack import _registry_canon_sha

    return _registry_canon_sha(registry)


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
            "## Semantic review posture",
            "",
            "Semantic review is not run by this deterministic benchmark. It belongs to the explicit non-CI semantic-review lane, where both paths receive symmetric fixture-blind instructions and independent evidence hashes.",
            "",
            "No semantic quality winner is claimed. The earlier asymmetric comparison is not retained because it did not use the required symmetric protocol.",
            "",
            "## Proof ceiling",
            "",
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
    traceability = load_task_pack_traceability(root, registry)
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
        pack = build_task_pack(
            registry,
            intake,
            repository_sha,
            known_issues,
            traceability=traceability,
        )
        markdown_path, json_path = write_task_pack(root, pack)
        outputs.extend((markdown_path, json_path))
    return tuple(outputs)


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
