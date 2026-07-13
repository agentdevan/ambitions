import importlib
import importlib.util
import hashlib
import json
import io
import tempfile
import unittest
from copy import deepcopy
from contextlib import redirect_stdout
from dataclasses import replace
from pathlib import Path
from unittest import mock

from tools.ambitions_canon import cli as canon_cli
from tools.ambitions_canon import build as canon_build
from tools.ambitions_canon.model import CanonError
from tools.ambitions_canon.model import Modality


ROOT = Path(__file__).resolve().parents[2]
FIXTURES = Path(__file__).with_name("fixtures") / "benchmarks"
SCENARIO_IDS = (
    "today-swiftui",
    "time-recurrence",
    "capture-proposal",
    "local-runtime-mutation",
    "cloudkit-continuity",
    "source-atlas-boundary",
    "accessibility-repair",
    "release-proof-claim",
)


def semantic_response(reviewer: str, model: str, response: str) -> bytes:
    return (
        json.dumps(
            {
                "schema_version": 1,
                "reviewer": reviewer,
                "model": model,
                "response": response,
            },
            sort_keys=True,
        )
        + "\n"
    ).encode()


class BenchmarkTest(unittest.TestCase):
    def benchmark_module(self):
        spec = importlib.util.find_spec("tools.ambitions_canon.benchmark")
        self.assertIsNotNone(
            spec,
            "Task 21 benchmark module must implement the eight-scenario contract",
        )
        return importlib.import_module("tools.ambitions_canon.benchmark")

    def test_exact_eight_fixture_contracts_are_closed_and_sorted(self):
        benchmark = self.benchmark_module()

        fixtures = benchmark.load_benchmark_fixtures(FIXTURES)

        self.assertEqual(tuple(item.scenario_id for item in fixtures), SCENARIO_IDS)
        self.assertEqual(len(fixtures), 8)
        for fixture in fixtures:
            self.assertEqual(fixture.schema_version, 2)
            self.assertTrue(fixture.applicable_requirement_ids)
            self.assertTrue(fixture.shared_law_allowlist)
            self.assertTrue(fixture.expected_source_owners)
            self.assertTrue(fixture.expected_validation)
            self.assertTrue(fixture.expected_verification_ids)
            self.assertTrue(fixture.expected_proof)
            self.assertTrue(hasattr(fixture, "approved_budget_class"))

    def test_owner_approved_release_budget_class_is_the_only_mapping_change(self):
        from tools.ambitions_canon import task_pack as task_pack_module

        self.assertEqual(
            task_pack_module.TASK_TYPE_BUDGET_CLASS,
            {
                "mechanical": "mechanical",
                "docs": "normal",
                "release": "complex",
                "swiftui": "complex",
                "runtime": "complex",
                "privacy": "complex",
                "constitutional-audit": "constitutional-audit",
            },
        )
        self.assertEqual(task_pack_module.PACK_BUDGETS["complex"], 30_000)

    def test_fixture_contracts_define_exact_semantic_and_owner_expectations(self):
        benchmark = self.benchmark_module()
        fixtures = benchmark.load_benchmark_fixtures(FIXTURES)

        for fixture in fixtures:
            with self.subTest(scenario=fixture.scenario_id):
                self.assertTrue(hasattr(fixture, "applicable_requirement_ids"))
                self.assertTrue(hasattr(fixture, "shared_law_allowlist"))
                self.assertTrue(hasattr(fixture, "expected_source_owners"))
                self.assertTrue(hasattr(fixture, "expected_verification_ids"))
                self.assertTrue(hasattr(fixture, "expected_proof"))

    def test_fixture_semantics_equal_independent_registry_transitive_closure(self):
        benchmark = self.benchmark_module()
        from tools.ambitions_canon import task_pack as task_pack_module

        registry = benchmark._load_registry(ROOT)
        requirements = {
            requirement.requirement_id: requirement
            for requirement in registry.requirements
        }
        for fixture in benchmark.load_benchmark_fixtures(FIXTURES):
            with self.subTest(scenario=fixture.scenario_id):
                roots = task_pack_module._scope_documents(
                    registry, fixture.intake.scope
                )
                root_spec_ids = {root.spec_id for root in roots}
                root_requirement_ids = {
                    requirement.requirement_id
                    for root in roots
                    for requirement in root.requirements
                    if requirement.requirement_id
                    in fixture.applicable_requirement_ids
                }
                semantic_documents = tuple(
                    document
                    for document in task_pack_module._dependency_closure(
                        registry, roots
                    )
                    if document.kind.value != "constitution"
                )
                dependency_documents = tuple(
                    document
                    for document in semantic_documents
                    if document.spec_id not in root_spec_ids
                )
                expected_requirement_ids = {
                    document.spec_id for document in semantic_documents
                } | root_requirement_ids | {
                    requirement.requirement_id
                    for document in dependency_documents
                    for requirement in document.requirements
                }
                expected_owners = {
                    owner
                    for document in semantic_documents
                    for owner in document.source_owners
                }
                expected_verification = {
                    verification
                    for identifier in expected_requirement_ids
                    | set(fixture.shared_law_allowlist)
                    if identifier in requirements
                    for verification in requirements[identifier].verification
                }

                self.assertEqual(
                    fixture.applicable_requirement_ids,
                    tuple(sorted(expected_requirement_ids)),
                )
                self.assertEqual(
                    fixture.expected_source_owners,
                    tuple(sorted(expected_owners)),
                )
                self.assertEqual(
                    fixture.expected_verification_ids,
                    tuple(sorted(expected_verification)),
                )

    def test_each_scenario_recalls_exact_ids_and_has_no_unrelated_root_law(self):
        benchmark = self.benchmark_module()

        result = benchmark.run_benchmark(ROOT, FIXTURES)

        self.assertEqual(tuple(item.scenario_id for item in result.scenarios), SCENARIO_IDS)
        for scenario in result.scenarios:
            with self.subTest(scenario=scenario.scenario_id):
                self.assertEqual(scenario.required_ids_recalled, scenario.required_ids_total)
                self.assertEqual(scenario.missing_required_ids, ())
                self.assertEqual(scenario.unexpected_requirement_ids, ())
                self.assertEqual(scenario.missing_shared_laws, ())
                self.assertEqual(scenario.unexpected_shared_laws, ())
                self.assertEqual(scenario.contradictory_active_requirement_count, 0)
                self.assertEqual(scenario.unrelated_root_surface_laws, ())

    def test_machine_pack_exposes_complete_exact_applicable_semantic_id_set(self):
        benchmark = self.benchmark_module()
        fixtures = {
            fixture.scenario_id: fixture
            for fixture in benchmark.load_benchmark_fixtures(FIXTURES)
        }
        result = benchmark.run_benchmark(ROOT, FIXTURES)

        for scenario in result.scenarios:
            with self.subTest(scenario=scenario.scenario_id):
                self.assertIn("applicable_requirement_ids", scenario.pack)
                expected = set(
                    fixtures[scenario.scenario_id].applicable_requirement_ids
                ) | set(fixtures[scenario.scenario_id].shared_law_allowlist)
                actual_requirements = set(
                    scenario.pack["applicable_requirement_ids"]
                )
                actual_laws = set(scenario.pack["constitutional_laws"])
                self.assertEqual(actual_requirements | actual_laws, expected)
                self.assertEqual(actual_requirements & actual_laws, set())

    def test_dependency_graph_retains_inherited_laws_and_dependency_semantics(self):
        benchmark = self.benchmark_module()
        result = benchmark.run_benchmark(ROOT, FIXTURES)
        scenarios = {item.scenario_id: item for item in result.scenarios}

        today = scenarios["today-swiftui"].pack
        self.assertIn("LAW-SHELL-STAGE-001", today["constitutional_laws"])
        self.assertIn("LAW-IA-NONROOT-001", today["constitutional_laws"])
        self.assertIn("IA-PLAIN-BRANDED-NAMING-001", today["constitutional_laws"])
        self.assertIn("PLATFORM-NATIVE-IPHONE-001", today["constitutional_laws"])
        self.assertIn("SPEC-APP-SHELL-ROOT-NAVIGATION-001", scenarios["today-swiftui"].included_ids)
        self.assertIn("SPEC-APP-NAVIGATION-IA-MAP-001", scenarios["today-swiftui"].included_ids)

        release = scenarios["release-proof-claim"]
        for identifier in (
            "TEST-001",
            "TEST-002",
            "TEST-003",
            "TEST-004",
            "TEST-005",
            "TEST-006",
            "TEST-007",
            "RELIABILITY-001",
            "RELIABILITY-006",
            "TEST-SCOPE-MATRIX-001",
            "TEST-RUNTIME-CONTRACT-001",
            "TEST-SCENARIO-EXECUTABILITY-001",
        ):
            with self.subTest(identifier=identifier):
                self.assertIn(identifier, release.included_ids)

        cloudkit = scenarios["cloudkit-continuity"].pack
        for identifier in (
            "LAW-RUNTIME-NO-DIRECT-WRITE-001",
            "RUNTIME-MUTATION-SEQUENCE-001",
            "LAW-LOCAL-AUTHORITY-001",
            "LAW-OFFLINE-NO-ACCOUNT-001",
            "PRIVACY-VISIBILITY-001",
        ):
            with self.subTest(identifier=identifier):
                self.assertIn(identifier, cloudkit["constitutional_laws"])

        for scenario in result.scenarios:
            markdown = scenario.pack_markdown
            self.assertNotRegex(markdown, r"(?m)^- \*\*[A-Z0-9-]+ — .+\*\* \(`[^`]+`\)\n(?=- \*\*|## )")

    def test_requirement_graph_traverses_two_edge_app_dependency_chain(self):
        benchmark = self.benchmark_module()
        from tools.ambitions_canon import task_pack as task_pack_module

        registry = benchmark._load_registry(ROOT)
        fixture = next(
            item
            for item in benchmark.load_benchmark_fixtures(FIXTURES)
            if item.scenario_id == "time-recurrence"
        )
        roots = task_pack_module._scope_documents(registry, fixture.intake.scope)
        closure = task_pack_module._dependency_closure(registry, roots)

        graph = task_pack_module._requirement_inclusion_graph(
            roots, closure, fixture.intake.scope
        )
        reversed_graph = task_pack_module._requirement_inclusion_graph(
            roots, tuple(reversed(closure)), fixture.intake.scope
        )

        self.assertEqual(graph, reversed_graph)
        self.assertIn("APP-LAUNCH-SETUP", graph)
        self.assertIn("APP-DEGRADED-STATES", graph)
        self.assertIn("APP-LAUNCH-READINESS-001", graph["APP-LAUNCH-SETUP"])
        self.assertIn(
            "APP-DEGRADED-FAILURE-TAXONOMY-001",
            graph["APP-DEGRADED-STATES"],
        )

    def test_requirement_graph_traverses_runtime_trust_app_chain(self):
        benchmark = self.benchmark_module()
        from tools.ambitions_canon import task_pack as task_pack_module

        registry = benchmark._load_registry(ROOT)
        fixture = next(
            item
            for item in benchmark.load_benchmark_fixtures(FIXTURES)
            if item.scenario_id == "local-runtime-mutation"
        )
        roots = task_pack_module._scope_documents(registry, fixture.intake.scope)
        closure = task_pack_module._dependency_closure(registry, roots)
        graph = task_pack_module._requirement_inclusion_graph(
            roots, closure, fixture.intake.scope
        )

        self.assertIn("GLOBAL-TRUST-INSPECTION", graph)
        self.assertIn("APP-SHELL", graph)
        self.assertIn("APP-NAVIGATION", graph)
        self.assertIn("SPEC-APP-SHELL-ROOT-NAVIGATION-001", graph["APP-SHELL"])
        self.assertIn("SPEC-APP-NAVIGATION-IA-MAP-001", graph["APP-NAVIGATION"])

    def test_requirement_graph_traverses_testing_release_chain(self):
        benchmark = self.benchmark_module()
        from tools.ambitions_canon import task_pack as task_pack_module

        registry = benchmark._load_registry(ROOT)
        fixture = next(
            item
            for item in benchmark.load_benchmark_fixtures(FIXTURES)
            if item.scenario_id == "release-proof-claim"
        )
        roots = task_pack_module._scope_documents(registry, fixture.intake.scope)
        closure = task_pack_module._dependency_closure(registry, roots)
        graph = task_pack_module._requirement_inclusion_graph(
            roots, closure, fixture.intake.scope
        )

        self.assertIn("STANDARD-TESTING-FIXTURES", graph)
        self.assertIn("SYSTEM-DIAGNOSTICS", graph)
        self.assertIn("SYSTEM-IMPORT-EXPORT-REPAIR", graph)
        self.assertIn(
            "SYSTEM-DIAGNOSTICS-HEALTH-001", graph["SYSTEM-DIAGNOSTICS"]
        )
        self.assertIn("SYSTEM-REPAIR-001", graph["SYSTEM-IMPORT-EXPORT-REPAIR"])

    def test_requirement_graph_fails_when_transitive_semantic_owner_is_missing(self):
        benchmark = self.benchmark_module()
        from tools.ambitions_canon import task_pack as task_pack_module

        registry = benchmark._load_registry(ROOT)
        fixture = next(
            item
            for item in benchmark.load_benchmark_fixtures(FIXTURES)
            if item.scenario_id == "time-recurrence"
        )
        roots = task_pack_module._scope_documents(registry, fixture.intake.scope)
        closure = tuple(
            document
            for document in task_pack_module._dependency_closure(registry, roots)
            if document.spec_id != "APP-LAUNCH-SETUP"
        )

        with self.assertRaises(CanonError) as raised:
            task_pack_module._requirement_inclusion_graph(
                roots, closure, fixture.intake.scope
            )
        self.assertEqual(raised.exception.code, "PACK_DEPENDENCY_OWNER_MISSING")

    def test_transitive_requirement_and_verification_removal_fail_closed(self):
        benchmark = self.benchmark_module()
        fixtures = {
            item.scenario_id: item
            for item in benchmark.load_benchmark_fixtures(FIXTURES)
        }
        fixture = fixtures["time-recurrence"]
        transitive_requirement = "APP-LAUNCH-READINESS-001"
        transitive_verification = "SCENARIO-APP-LAUNCH-READY-001"
        self.assertIn(transitive_requirement, fixture.applicable_requirement_ids)
        self.assertIn(transitive_verification, fixture.expected_verification_ids)

        registry = benchmark._load_registry(ROOT)
        known_issues = benchmark._known_issues(ROOT, registry)
        without_requirement = replace(
            fixture,
            applicable_requirement_ids=tuple(
                identifier
                for identifier in fixture.applicable_requirement_ids
                if identifier != transitive_requirement
            ),
        )
        requirement_result = benchmark._measure_scenario(
            registry, known_issues, without_requirement
        )
        self.assertFalse(requirement_result.passed)
        self.assertEqual(
            requirement_result.unexpected_requirement_ids,
            (transitive_requirement,),
        )

        without_verification = replace(
            fixture,
            expected_verification_ids=tuple(
                identifier
                for identifier in fixture.expected_verification_ids
                if identifier != transitive_verification
            ),
        )
        verification_result = benchmark._measure_scenario(
            registry, known_issues, without_verification
        )
        self.assertFalse(verification_result.passed)
        self.assertEqual(
            verification_result.unexpected_verification_ids,
            (transitive_verification,),
        )

    def test_dependency_graph_fails_closed_for_semantically_empty_dependency(self):
        benchmark = self.benchmark_module()
        from tools.ambitions_canon import task_pack as task_pack_module

        registry = benchmark._load_registry(ROOT)
        fixture = benchmark.load_benchmark_fixtures(FIXTURES)[0]
        roots = task_pack_module._scope_documents(registry, fixture.intake.scope)
        closure = task_pack_module._dependency_closure(registry, roots)
        emptied = tuple(
            replace(document, requirements=())
            if document.spec_id == "APP-SHELL"
            else document
            for document in closure
        )

        with self.assertRaises(CanonError) as raised:
            task_pack_module._requirement_inclusion_graph(
                roots, emptied, fixture.intake.scope
            )
        self.assertEqual(raised.exception.code, "PACK_DEPENDENCY_SEMANTICS_EMPTY")

    def test_each_scenario_has_owner_validation_proof_and_approved_budget(self):
        benchmark = self.benchmark_module()

        result = benchmark.run_benchmark(ROOT, FIXTURES)

        for scenario in result.scenarios:
            with self.subTest(scenario=scenario.scenario_id):
                self.assertGreater(scenario.context_characters, 0)
                self.assertEqual(
                    scenario.context_tokens,
                    (scenario.context_characters + 3) // 4,
                )
                self.assertLessEqual(
                    scenario.context_tokens,
                    scenario.approved_budget,
                )
                self.assertEqual(
                    scenario.approved_budget_class,
                    scenario.pack["budget_class"],
                )
                self.assertEqual(
                    scenario.approved_budget,
                    scenario.pack["token_budget"],
                )
                self.assertEqual(
                    scenario.source_owner_mapping_count,
                    scenario.required_source_owner_count,
                )
                self.assertEqual(scenario.missing_source_owners, ())
                self.assertEqual(scenario.unexpected_source_owners, ())
                self.assertEqual(scenario.missing_verification_ids, ())
                self.assertEqual(scenario.unexpected_verification_ids, ())
                self.assertTrue(scenario.validation_present)
                self.assertTrue(scenario.proof_present)
                self.assertTrue(scenario.passed)

    def test_visually_governed_benchmark_packs_include_scope_authority(self):
        benchmark = self.benchmark_module()
        result = benchmark.run_benchmark(ROOT, FIXTURES)
        packs = {scenario.scenario_id: scenario.pack for scenario in result.scenarios}

        today = packs["today-swiftui"]
        capture = packs["capture-proposal"]
        self.assertIn(
            "SPEC-SURFACE-TODAY-VISUAL-AUTHORITY-001",
            today["applicable_requirement_ids"],
        )
        self.assertTrue(any("VSP-02" in item for item in today["visual_authority"]))
        self.assertIn(
            "SPEC-GLOBAL-CAPTURE-VISUAL-AUTHORITY-001",
            capture["applicable_requirement_ids"],
        )
        self.assertTrue(any("VSP-05" in item for item in capture["visual_authority"]))

    def test_benchmark_budget_enforcement_uses_estimated_tokens_not_characters(self):
        benchmark = self.benchmark_module()
        fixture = next(
            item
            for item in benchmark.load_benchmark_fixtures(FIXTURES)
            if item.scenario_id == "release-proof-claim"
        )
        registry = benchmark._load_registry(ROOT)
        known_issues = benchmark._known_issues(ROOT, registry)

        result = benchmark._measure_scenario(
            registry,
            known_issues,
            fixture,
        )

        self.assertGreater(result.context_characters, result.approved_budget)
        self.assertLessEqual(result.context_tokens, result.approved_budget)
        self.assertTrue(result.passed)

    def test_fixture_budget_class_and_ceiling_must_match_generated_pack(self):
        benchmark = self.benchmark_module()
        fixture = benchmark.load_benchmark_fixtures(FIXTURES)[0]
        registry = benchmark._load_registry(ROOT)
        known_issues = benchmark._known_issues(ROOT, registry)

        for changed_fixture in (
            replace(fixture, approved_budget_class="normal"),
            replace(fixture, approved_budget=29_999),
        ):
            with self.subTest(fixture=changed_fixture):
                with self.assertRaises(CanonError) as raised:
                    benchmark._measure_scenario(
                        registry,
                        known_issues,
                        changed_fixture,
                    )
                self.assertEqual(
                    raised.exception.code,
                    "BENCHMARK_BUDGET_CONTRACT_MISMATCH",
                )

    def test_precision_fails_for_unapproved_requirement_or_owner_expansion(self):
        benchmark = self.benchmark_module()
        fixture = benchmark.load_benchmark_fixtures(FIXTURES)[0]
        registry = benchmark._load_registry(ROOT)
        known_issues = benchmark._known_issues(ROOT, registry)

        narrower_ids = replace(
            fixture,
            applicable_requirement_ids=fixture.applicable_requirement_ids[:-1],
        )
        requirement_result = benchmark._measure_scenario(
            registry, known_issues, narrower_ids
        )
        self.assertTrue(requirement_result.unexpected_requirement_ids)
        self.assertFalse(requirement_result.passed)

        narrower_owners = replace(
            fixture,
            expected_source_owners=fixture.expected_source_owners[:-1],
        )
        owner_result = benchmark._measure_scenario(
            registry, known_issues, narrower_owners
        )
        self.assertTrue(owner_result.unexpected_source_owners)
        self.assertFalse(owner_result.passed)

    def test_active_modality_conflict_is_counted_from_selected_requirements(self):
        benchmark = self.benchmark_module()
        registry = benchmark._load_registry(ROOT)
        first, second = registry.requirements[:2]
        conflicting = replace(
            second,
            concept=first.concept,
            scope=first.scope,
            modality=Modality.MUST_NOT,
        )
        conflicted_registry = replace(
            registry,
            requirements=(first, conflicting, *registry.requirements[2:]),
        )

        contradictions = benchmark._active_contradictions(
            conflicted_registry,
            frozenset((first.requirement_id, conflicting.requirement_id)),
            (),
        )

        self.assertEqual(
            contradictions,
            tuple(sorted((first.requirement_id, conflicting.requirement_id))),
        )

    def test_stale_pack_guard_covers_every_authorization_input(self):
        benchmark = self.benchmark_module()
        result = benchmark.run_benchmark(ROOT, FIXTURES)
        stored = result.scenarios[0].pack
        cases = (
            ("canon revision", "canon_revision", 999, "PACK_CANON_STALE"),
            ("canon content", "canon_sha", "0" * 64, "PACK_CANON_STALE"),
            ("Git SHA", "repository_sha", "other-head", "PACK_REPOSITORY_STALE"),
            ("Git diff", "repository_sha", "head-dirty-other", "PACK_REPOSITORY_STALE"),
            ("intake", "intake_sha", "1" * 64, "PACK_INTAKE_STALE"),
            ("issue", "issue_id", "CANON-BENCH-OTHER", "PACK_ISSUE_STALE"),
            (
                "source ownership",
                "source_owners",
                ["Native/Ambitions/Features/WrongOwner/"],
                "PACK_SOURCE_STALE",
            ),
            ("conflicts", "open_conflicts", ["CONFLICT-NEW"], "PACK_CONFLICT_STALE"),
            (
                "known issues",
                "known_risks",
                ["RISK-NEW: proof changed"],
                "PACK_KNOWN_ISSUES_STALE",
            ),
            (
                "proof posture",
                "required_proof",
                ["weaker proof"],
                "PACK_PROOF_POSTURE_STALE",
            ),
        )
        for label, field, value, code in cases:
            with self.subTest(label=label):
                current = deepcopy(stored)
                current[field] = value
                with self.assertRaises(CanonError) as raised:
                    benchmark.require_pack_authorization_current(stored, current)
                self.assertEqual(raised.exception.code, code)

    def test_report_is_deterministic_sorted_and_newline_terminated(self):
        benchmark = self.benchmark_module()
        result = benchmark.run_benchmark(ROOT, FIXTURES)

        first = benchmark.render_benchmark_report(result)
        second = benchmark.render_benchmark_report(result)

        self.assertEqual(first, second)
        self.assertTrue(first.endswith("\n"))
        positions = [first.index(scenario_id) for scenario_id in SCENARIO_IDS]
        self.assertEqual(positions, sorted(positions))
        self.assertIn("Semantic review posture", first)
        self.assertIn("not run by this deterministic benchmark", first)
        self.assertIn("explicit non-CI", first)
        self.assertNotIn("| Response path | Score |", first)
        self.assertNotIn("Final semantic-ID recall", first)
        self.assertIn(
            "| Scenario | Characters (informational) | Estimated tokens | Budget class | Token ceiling |",
            first,
        )
        self.assertIn("No semantic quality winner is claimed", first)

    def test_deterministic_benchmark_does_not_load_model_semantic_evidence(self):
        benchmark = self.benchmark_module()

        self.assertFalse(hasattr(benchmark, "load_semantic_comparison"))
        result = benchmark.run_benchmark(ROOT, FIXTURES)

        self.assertFalse(hasattr(result, "semantic_comparison"))

    def test_accessibility_and_release_packs_count_every_mixed_owner_gap(self):
        benchmark = self.benchmark_module()
        scenarios = {
            item.scenario_id: item.pack
            for item in benchmark.run_benchmark(ROOT, FIXTURES).scenarios
        }

        accessibility = json.loads(
            scenarios["accessibility-repair"]["implementation_posture"]
        )
        release = json.loads(scenarios["release-proof-claim"]["implementation_posture"])
        self.assertEqual(accessibility["source_gap_requirement_count"], 3)
        self.assertEqual(accessibility["applicable_requirement_count"], 3)
        self.assertEqual(release["source_gap_requirement_count"], 48)
        self.assertEqual(release["applicable_requirement_count"], 235)
        a11y = next(
            item
            for item in release["source_gap_records"]
            if item["requirement_id"] == "A11Y-002"
        )
        self.assertEqual(
            a11y["source_owners"],
            [
                "Native/Ambitions/DesignSystem/",
                "Native/Ambitions/Interaction/Accessibility/",
                "Native/Ambitions/Quality/Accessibility/",
            ],
        )
        self.assertTrue(a11y["mappings"][0]["implementation_files"])
        self.assertEqual(a11y["mappings"][1]["status"], "owner_path_absent")
        self.assertEqual(a11y["mappings"][1]["implementation_files"], [])
        self.assertTrue(
            any(
                "gap_class=canon_to_code affected_ids=A11Y-002" in gap
                for gap in a11y["gaps"]
            )
        )

    def test_semantic_review_prompts_are_symmetric_and_fixture_blind(self):
        benchmark = self.benchmark_module()
        fixtures = benchmark.load_benchmark_fixtures(FIXTURES)

        old_prompt = benchmark.render_semantic_review_prompt(
            fixtures,
            context_label="old-truth-path",
            context_entries=("docs/truth/README.md",),
        )
        new_prompt = benchmark.render_semantic_review_prompt(
            fixtures,
            context_label="new-task-packs",
            context_entries=("today-swiftui.md",),
        )

        old_instructions = old_prompt.split("## Symmetric task instructions", 1)[1]
        new_instructions = new_prompt.split("## Symmetric task instructions", 1)[1]
        old_instructions = old_instructions.split("## Supplied context", 1)[0]
        new_instructions = new_instructions.split("## Supplied context", 1)[0]
        self.assertEqual(old_instructions, new_instructions)
        for prompt in (old_prompt, new_prompt):
            self.assertNotIn("expected_requirement", prompt)
            self.assertNotIn("expected_source", prompt)
            self.assertNotIn("shared_law_allowlist", prompt)
            self.assertNotIn("Response path | Score", prompt)
            self.assertIn("semantic equivalence", prompt)
            self.assertIn("relevant-law recall", prompt)
            self.assertIn("unauthorized assumptions", prompt)
            self.assertIn("source ownership", prompt)
            self.assertIn("validation", prompt)
            self.assertIn("proof discipline", prompt)

    def test_semantic_review_bundle_records_honest_hash_posture(self):
        benchmark = self.benchmark_module()

        outputs = benchmark.build_semantic_review_bundle(
            ROOT,
            FIXTURES,
            reviewer="Independent reviewer",
            model="review-model",
        )
        record = json.loads(outputs[Path("semantic-review-record.json")])

        self.assertEqual(record["reviewer"], "Independent reviewer")
        self.assertEqual(record["model"], "review-model")
        self.assertEqual(record["status"], "awaiting_independent_responses")
        self.assertIsNone(record["old_response_sha256"])
        self.assertIsNone(record["new_response_sha256"])
        self.assertRegex(record["old_prompt_sha256"], r"^[0-9a-f]{64}$")
        self.assertRegex(record["new_prompt_sha256"], r"^[0-9a-f]{64}$")
        self.assertRegex(record["canon_sha256"], r"^[0-9a-f]{64}$")
        self.assertEqual(len(record["pack_hashes"]), 8)
        self.assertNotIn("winner", record)
        self.assertNotIn("score", record)

    def test_semantic_review_ingests_strict_hash_bound_comparison_after_responses(self):
        benchmark = self.benchmark_module()
        old_response = semantic_response("Élodie 山田", "modèle α", "old")
        new_response = semantic_response("Мария", "модель β", "new")
        pending = benchmark.build_semantic_review_bundle(
            ROOT,
            FIXTURES,
            reviewer="Response reviewer",
            model="response-model",
            old_response=old_response,
            new_response=new_response,
        )
        record = json.loads(pending[Path("semantic-review-record.json")])
        dimensions = []
        for index, dimension in enumerate(record["comparison_dimensions"]):
            old_score, new_score = (
                (4, 3) if index == 0 else (3, 4) if index == 1 else (3, 3)
            )
            verdict = (
                "old_better"
                if old_score > new_score
                else "new_better"
                if new_score > old_score
                else "equivalent"
            )
            dimensions.append(
                {
                    "dimension": dimension,
                    "verdict": verdict,
                    "old_score": old_score,
                    "new_score": new_score,
                    "rationale": "Independently reviewed supplied evidence.",
                }
            )
        comparison = {
            "schema_version": 1,
            "comparison_reviewer": "محمد",
            "comparison_model": "比較モデル",
            "canon_sha256": record["canon_sha256"],
            "old_prompt_sha256": record["old_prompt_sha256"],
            "new_prompt_sha256": record["new_prompt_sha256"],
            "old_response_sha256": record["old_response_sha256"],
            "new_response_sha256": record["new_response_sha256"],
            "dimensions": dimensions,
            "overall_verdict": "equivalent",
            "old_total_score": 22,
            "new_total_score": 22,
        }
        comparison_bytes = (json.dumps(comparison, sort_keys=True) + "\n").encode()

        outputs = benchmark.build_semantic_review_bundle(
            ROOT,
            FIXTURES,
            reviewer="Response reviewer",
            model="response-model",
            old_response=old_response,
            new_response=new_response,
            comparison=comparison_bytes,
        )
        recorded = json.loads(outputs[Path("semantic-review-record.json")])

        self.assertEqual(
            outputs[Path("comparison/comparison.json")], comparison_bytes
        )
        self.assertEqual(recorded["status"], "comparison_recorded")
        self.assertEqual(
            recorded["comparison_sha256"],
            hashlib.sha256(comparison_bytes).hexdigest(),
        )
        self.assertEqual(
            recorded["comparison_reviewer"],
            "محمد",
        )
        self.assertEqual(recorded["comparison_model"], "比較モデル")
        self.assertEqual(recorded["old_response_reviewer"], "Élodie 山田")
        self.assertEqual(recorded["new_response_reviewer"], "Мария")

    def test_semantic_review_responses_require_closed_attributable_json(self):
        benchmark = self.benchmark_module()
        valid = semantic_response("Response reviewer", "response-model", "response")
        invalid = [
            b'{"response":"missing metadata"}\n',
            semantic_response("   ", "response-model", "response"),
            semantic_response("\u200b", "response-model", "response"),
            semantic_response("Response reviewer", "   ", "response"),
            b'{"model":"response-model","response":"response","reviewer":"Response reviewer","schema_version":1,"unexpected":true}\n',
            b'not json\n',
        ]
        control_values = (
            "Reviewer\x00",
            "Reviewer\u202e",
            "Reviewer\ue000",
            "Reviewer\ud800",
            "Reviewer\u0378",
        )
        invalid.extend(
            semantic_response(value, "response-model", "response")
            for value in control_values
        )
        invalid.extend(
            semantic_response("Response reviewer", value, "response")
            for value in control_values
        )

        for response in invalid:
            with self.subTest(response=response):
                with self.assertRaises(CanonError) as raised:
                    benchmark.build_semantic_review_bundle(
                        ROOT,
                        FIXTURES,
                        reviewer="Bundle operator",
                        model="bundle-model",
                        old_response=response,
                        new_response=valid,
                    )
                self.assertEqual(
                    raised.exception.code,
                    "BENCHMARK_SEMANTIC_RESPONSE_INVALID",
                )

    def test_semantic_comparison_requires_independent_reviewer_and_consistent_verdicts(self):
        benchmark = self.benchmark_module()
        old_response = semantic_response("Old Reviewer", "old-model", "old")
        new_response = semantic_response("New Reviewer", "new-model", "new")
        pending = benchmark.build_semantic_review_bundle(
            ROOT,
            FIXTURES,
            reviewer="Bundle operator",
            model="bundle-model",
            old_response=old_response,
            new_response=new_response,
        )
        record = json.loads(pending[Path("semantic-review-record.json")])
        base = {
            "schema_version": 1,
            "comparison_reviewer": "Independent comparison reviewer",
            "comparison_model": "comparison-model",
            "canon_sha256": record["canon_sha256"],
            "old_prompt_sha256": record["old_prompt_sha256"],
            "new_prompt_sha256": record["new_prompt_sha256"],
            "old_response_sha256": record["old_response_sha256"],
            "new_response_sha256": record["new_response_sha256"],
            "dimensions": [
                {
                    "dimension": dimension,
                    "verdict": "equivalent",
                    "old_score": 3,
                    "new_score": 3,
                    "rationale": "Independent comparison.",
                }
                for dimension in record["comparison_dimensions"]
            ],
            "overall_verdict": "equivalent",
            "old_total_score": 21,
            "new_total_score": 21,
        }
        contradictory_dimension = deepcopy(base)
        contradictory_dimension["dimensions"][0].update(
            {"verdict": "equivalent", "old_score": 4, "new_score": 3}
        )
        contradictory_dimension["old_total_score"] = 22
        contradictory_overall = deepcopy(base)
        contradictory_overall["overall_verdict"] = "old_better"
        insufficient = deepcopy(base)
        insufficient["dimensions"][0]["verdict"] = "insufficient_evidence"
        cases = (
            (
                {**base, "comparison_reviewer": "  old   REVIEWER  "},
                "BENCHMARK_SEMANTIC_COMPARISON_INDEPENDENCE",
            ),
            (
                {**base, "comparison_reviewer": "Ｎｅｗ reviewer"},
                "BENCHMARK_SEMANTIC_COMPARISON_INDEPENDENCE",
            ),
            (
                {**base, "comparison_reviewer": "Old Reviewer\x00"},
                "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
            ),
            (
                {**base, "comparison_reviewer": "Old\u200b Reviewer"},
                "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
            ),
            (contradictory_dimension, "BENCHMARK_SEMANTIC_COMPARISON_INVALID"),
            (contradictory_overall, "BENCHMARK_SEMANTIC_COMPARISON_INVALID"),
            (insufficient, "BENCHMARK_SEMANTIC_COMPARISON_INVALID"),
        )
        for payload, code in cases:
            with self.subTest(code=code):
                with self.assertRaises(CanonError) as raised:
                    benchmark.build_semantic_review_bundle(
                        ROOT,
                        FIXTURES,
                        reviewer="Bundle operator",
                        model="bundle-model",
                        old_response=old_response,
                        new_response=new_response,
                        comparison=(json.dumps(payload, sort_keys=True) + "\n").encode(),
                    )
                self.assertEqual(raised.exception.code, code)

        controls = ("\x00", "\u202e", "\ue000", "\ud800", "\u0378")
        for field in ("comparison_reviewer", "comparison_model"):
            for control in controls:
                with self.subTest(field=field, control=repr(control)):
                    payload = {**base, field: f"Independent{control} reviewer"}
                    with self.assertRaises(CanonError) as raised:
                        benchmark.build_semantic_review_bundle(
                            ROOT,
                            FIXTURES,
                            reviewer="Bundle operator",
                            model="bundle-model",
                            old_response=old_response,
                            new_response=new_response,
                            comparison=(
                                json.dumps(payload, sort_keys=True) + "\n"
                            ).encode(),
                        )
                    self.assertEqual(
                        raised.exception.code,
                        "BENCHMARK_SEMANTIC_COMPARISON_INVALID",
                    )

    def test_semantic_review_comparison_omission_mismatch_and_scores_fail_closed(self):
        benchmark = self.benchmark_module()
        old_response = semantic_response("Old response reviewer", "old-model", "old")
        new_response = semantic_response("New response reviewer", "new-model", "new")
        pending = benchmark.build_semantic_review_bundle(
            ROOT,
            FIXTURES,
            reviewer="Response reviewer",
            model="response-model",
            old_response=old_response,
            new_response=new_response,
        )
        record = json.loads(pending[Path("semantic-review-record.json")])
        base = {
            "schema_version": 1,
            "comparison_reviewer": "Independent comparison reviewer",
            "comparison_model": "comparison-model",
            "canon_sha256": record["canon_sha256"],
            "old_prompt_sha256": record["old_prompt_sha256"],
            "new_prompt_sha256": record["new_prompt_sha256"],
            "old_response_sha256": record["old_response_sha256"],
            "new_response_sha256": record["new_response_sha256"],
            "dimensions": [
                {
                    "dimension": dimension,
                    "verdict": "equivalent",
                    "old_score": 3,
                    "new_score": 3,
                    "rationale": "Independent comparison.",
                }
                for dimension in record["comparison_dimensions"]
            ],
            "overall_verdict": "equivalent",
            "old_total_score": 21,
            "new_total_score": 21,
        }
        cases = (
            ({key: value for key, value in base.items() if key != "comparison_model"}, "BENCHMARK_SEMANTIC_COMPARISON_INVALID"),
            ({**base, "old_prompt_sha256": "0" * 64}, "BENCHMARK_SEMANTIC_COMPARISON_STALE"),
            ({**base, "dimensions": base["dimensions"][:-1]}, "BENCHMARK_SEMANTIC_COMPARISON_INVALID"),
            ({**base, "dimensions": [{**base["dimensions"][0], "old_score": 5}, *base["dimensions"][1:]]}, "BENCHMARK_SEMANTIC_COMPARISON_INVALID"),
            ({**base, "old_total_score": 20}, "BENCHMARK_SEMANTIC_COMPARISON_INVALID"),
        )
        for payload, code in cases:
            with self.subTest(code=code, payload=payload):
                with self.assertRaises(CanonError) as raised:
                    benchmark.build_semantic_review_bundle(
                        ROOT,
                        FIXTURES,
                        reviewer="Response reviewer",
                        model="response-model",
                        old_response=old_response,
                        new_response=new_response,
                        comparison=(json.dumps(payload, sort_keys=True) + "\n").encode(),
                    )
                self.assertEqual(raised.exception.code, code)

        with self.assertRaises(CanonError) as raised:
            benchmark.build_semantic_review_bundle(
                ROOT,
                FIXTURES,
                reviewer="Response reviewer",
                model="response-model",
                comparison=(json.dumps(base, sort_keys=True) + "\n").encode(),
            )
        self.assertEqual(
            raised.exception.code,
            "BENCHMARK_SEMANTIC_COMPARISON_RESPONSE_REQUIRED",
        )


    def test_report_write_is_atomic_and_check_detects_stale_bytes(self):
        benchmark = self.benchmark_module()
        result = benchmark.run_benchmark(ROOT, FIXTURES)
        with tempfile.TemporaryDirectory() as temporary_directory:
            output = Path(temporary_directory) / "benchmark.md"

            benchmark.write_benchmark_report(output, result)
            self.assertEqual(output.read_text(), benchmark.render_benchmark_report(result))
            benchmark.check_benchmark_report(output, result)
            output.write_text("stale\n", encoding="utf-8")

            with self.assertRaises(CanonError) as raised:
                benchmark.check_benchmark_report(output, result)
            self.assertEqual(raised.exception.code, "BENCHMARK_OUTPUT_STALE")

    def test_canon_build_rerenders_benchmark_instead_of_preserving_report_bytes(self):
        self.assertFalse(hasattr(canon_build, "_preserved_generated_evidence"))
        self.assertTrue(hasattr(canon_build, "_deterministic_benchmark_evidence"))

        outputs = canon_build._deterministic_benchmark_evidence(ROOT)
        report_path = Path("codex-consumption-benchmark.md")
        self.assertEqual(set(outputs), {report_path})
        benchmark = self.benchmark_module()
        expected = benchmark.render_benchmark_report(
            benchmark.run_benchmark(ROOT, FIXTURES)
        ).encode("utf-8")
        self.assertEqual(outputs[report_path], expected)
        self.assertNotEqual(outputs[report_path], b"benchmark evidence\n")

        with tempfile.TemporaryDirectory() as temporary_directory:
            generated = Path(temporary_directory) / "generated"
            generated.mkdir()
            (generated / report_path).write_bytes(b"benchmark evidence\n")
            findings = canon_build.check_outputs(generated, outputs)
        self.assertEqual(
            tuple(finding.code for finding in findings),
            ("CANON_GENERATED_CHANGED",),
        )

    def test_cli_supports_exact_pack_check_path_and_benchmark_interfaces(self):
        self.benchmark_module()
        pack_path = ROOT / ".codex/canon-packs/example/pack.json"
        with mock.patch.object(canon_cli, "_check_pack_path", return_value=0) as check:
            self.assertEqual(canon_cli.main(["pack", "--check", str(pack_path)]), 0)
        check.assert_called_once_with(ROOT, pack_path)

        with mock.patch.object(canon_cli, "_benchmark", return_value=0) as run:
            self.assertEqual(canon_cli.main(["benchmark"]), 0)
        run.assert_called_once_with(ROOT)

        with mock.patch.object(canon_cli, "_semantic_review", return_value=0) as review:
            self.assertEqual(
                canon_cli.main(
                    [
                        "semantic-review",
                        "--reviewer",
                        "Independent reviewer",
                        "--model",
                        "review-model",
                    ]
                ),
                0,
            )
        review.assert_called_once_with(
            ROOT,
            reviewer="Independent reviewer",
            model="review-model",
            old_response=None,
            new_response=None,
            comparison=None,
        )

        comparison_path = ROOT / ".codex/input/comparison.json"
        with mock.patch.object(canon_cli, "_semantic_review", return_value=0) as review:
            self.assertEqual(
                canon_cli.main(
                    [
                        "semantic-review",
                        "--reviewer",
                        "Response reviewer",
                        "--model",
                        "response-model",
                        "--old-response",
                        "old.json",
                        "--new-response",
                        "new.json",
                        "--comparison",
                        str(comparison_path),
                    ]
                ),
                0,
            )
        review.assert_called_once_with(
            ROOT,
            reviewer="Response reviewer",
            model="response-model",
            old_response=Path("old.json"),
            new_response=Path("new.json"),
            comparison=comparison_path,
        )

    def test_semantic_review_help_documents_comparison_ingestion(self):
        output = io.StringIO()
        with redirect_stdout(output), self.assertRaises(SystemExit) as raised:
            canon_cli.main(["semantic-review", "--help"])
        self.assertEqual(raised.exception.code, 0)
        self.assertIn("schema_version/reviewer/model/response", output.getvalue())
        self.assertIn("--comparison", output.getvalue())
        self.assertIn("independent comparison", output.getvalue())

    def test_fixture_json_is_canonical_newline_terminated_input(self):
        for path in sorted(FIXTURES.glob("*.json")):
            with self.subTest(path=path.name):
                raw = path.read_bytes()
                self.assertTrue(raw.endswith(b"\n"))
                payload = json.loads(raw)
                canonical = json.dumps(payload, indent=2, sort_keys=True) + "\n"
                self.assertEqual(raw.decode("utf-8"), canonical)


if __name__ == "__main__":
    unittest.main()
