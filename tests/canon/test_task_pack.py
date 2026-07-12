import json
import io
import shutil
import subprocess
import tempfile
import unittest
from contextlib import redirect_stdout
from dataclasses import replace
from pathlib import Path
from unittest import mock

from tools.ambitions_canon import build as canon_build
from tools.ambitions_canon import cli as canon_cli
from tools.ambitions_canon import task_pack as task_pack_module
from tools.ambitions_canon.cli import _pack
from tools.ambitions_canon.model import (
    AuthorityState,
    CanonDocument,
    CanonError,
    CanonManifest,
    DocumentKind,
    Modality,
    Requirement,
)
from tools.ambitions_canon.registry import build_registry
from tools.ambitions_canon.reference_index import parse_reference_index_bytes
from tools.ambitions_canon.task_pack import (
    PACK_BUDGETS,
    PACK_SECTION_ORDER,
    TASK_TYPE_BUDGET_CLASS,
    TaskIntake,
    build_task_pack,
    estimate_tokens,
    read_task_pack_pair,
    task_pack_paths,
    validate_task_pack,
    write_task_pack,
)
from tests.canon.test_audit import markdown_document
from tests.canon.canon_test_support import write_required_governance_artifacts


ROOT = Path(__file__).resolve().parents[2]
FIXTURE = Path(__file__).with_name("fixtures") / "issue-intake.json"


def requirement(
    requirement_id: str,
    concept: str,
    *,
    body: str | None = None,
) -> Requirement:
    return Requirement(
        requirement_id=requirement_id,
        title=requirement_id,
        concept=concept,
        modality=Modality.MUST,
        scope="Test scope",
        status="normative",
        verification=(f"SCENARIO-{requirement_id}",),
        supersedes=(),
        body=body or f"Required law for {requirement_id}.",
        source_path=Path(f"docs/canon/{requirement_id.lower()}.md"),
        line=20,
    )


def document(
    spec_id: str,
    *,
    kind: DocumentKind,
    concepts: tuple[str, ...],
    requirements: tuple[Requirement, ...],
    inherits: tuple[str, ...] = (),
    depends_on: tuple[str, ...] = (),
    source_owners: tuple[str, ...] = (),
) -> CanonDocument:
    return CanonDocument(
        spec_id=spec_id,
        title=spec_id,
        kind=kind,
        status="normative",
        owner_domain="product",
        canon_revision=1,
        profile=None,
        owns_concepts=concepts,
        inherits=inherits,
        depends_on=depends_on,
        source_owners=source_owners,
        sections=frozenset(),
        not_applicable=(),
        requirements=requirements,
        source_path=Path(f"docs/canon/{spec_id.lower()}.md"),
        source_bytes=f"source:{spec_id}\n".encode(),
    )


def sample_registry(*, oversized_body: str | None = None, reverse: bool = False):
    mission = requirement("MISSION-001", "mission.private-life")
    step = requirement("STEP-001", "object.step.lifecycle")
    journey = requirement("JOURNEY-001", "journey.start-step")
    standard = requirement("STANDARD-001", "standard.native-ios")
    runtime = requirement("SYSTEM-001", "system.local-runtime")
    today_one = requirement(
        "TODAY-001",
        "surface.today.identity",
        body=oversized_body,
    )
    today_two = requirement("TODAY-002", "surface.today.identity")
    time = requirement("TIME-001", "surface.time.identity")
    documents = (
        document(
            "CONSTITUTION",
            kind=DocumentKind.CONSTITUTION,
            concepts=("mission.private-life",),
            requirements=(mission,),
        ),
        document(
            "OBJECT-STEP",
            kind=DocumentKind.OBJECT,
            concepts=("object.step.lifecycle",),
            requirements=(step,),
            inherits=("MISSION-001",),
            source_owners=("Native/Ambitions/Core/Domain/Step.swift",),
        ),
        document(
            "JOURNEY-START",
            kind=DocumentKind.JOURNEY,
            concepts=("journey.start-step",),
            requirements=(journey,),
            inherits=("MISSION-001",),
            depends_on=("OBJECT-STEP",),
        ),
        document(
            "STANDARD-NATIVE",
            kind=DocumentKind.STANDARD,
            concepts=("standard.native-ios",),
            requirements=(standard,),
            inherits=("MISSION-001",),
        ),
        document(
            "SYSTEM-RUNTIME",
            kind=DocumentKind.SYSTEM,
            concepts=("system.local-runtime",),
            requirements=(runtime,),
            inherits=("MISSION-001",),
            source_owners=("Native/Ambitions/Core/LocalRuntimeOS",),
        ),
        document(
            "SURFACE-TODAY",
            kind=DocumentKind.SURFACE,
            concepts=("surface.today.identity",),
            requirements=(today_one, today_two),
            inherits=("MISSION-001",),
            depends_on=(
                "OBJECT-STEP",
                "JOURNEY-START",
                "STANDARD-NATIVE",
                "SYSTEM-RUNTIME",
            ),
            source_owners=("Native/Ambitions/Surfaces/Today",),
        ),
        document(
            "SURFACE-TIME",
            kind=DocumentKind.SURFACE,
            concepts=("surface.time.identity",),
            requirements=(time,),
            inherits=("MISSION-001",),
            source_owners=("Native/Ambitions/Surfaces/Time",),
        ),
    )
    if reverse:
        documents = tuple(reversed(documents))
    manifest = CanonManifest(
        schema_version=1,
        canon_revision=7,
        authority_state=AuthorityState.SHADOW,
        compiler_version="0.1.0",
        normative_files=(),
        generated_files=(),
        source_path=Path("docs/canon/MANIFEST.toml"),
        repository_root=None,
        source_bytes=b"manifest\n",
    )
    built = build_registry(manifest, documents)
    indexed_ids = tuple(
        sorted(requirement.requirement_id for requirement in built.requirements)
    )
    reference_bytes = (
        json.dumps(
            {
                "authority_references": [],
                "canon_revision": 7,
                "indexed_requirement_ids": indexed_ids,
                "schema_version": 1,
                "specification_gaps": [],
                "task_packs": [],
            },
            indent=2,
            sort_keys=True,
        )
        + "\n"
    ).encode()
    return replace(
        built,
        supersession_ledger_complete=True,
        supersession_ledger_bytes=b"schema_version = 1\nentries = []\n",
        reference_index=parse_reference_index_bytes(
            reference_bytes,
            Path("docs/canon/migration/impact-reference-index.json"),
            canon_revision=7,
            requirement_ids=indexed_ids,
        ),
    )


def intake(task_type: str = "swiftui") -> TaskIntake:
    return TaskIntake.from_json(
        {
            "schema_version": 1,
            "issue_id": "AMB-1842",
            "task_type": task_type,
            "scope": ["surface.today"],
            "changed_files": ["Native/Ambitions/Surfaces/Today"],
            "claim_type": "source",
            "known_issue_ids": [],
        }
    )


def known_issue(
    issue_id: str = "CONFLICT-001",
    *,
    severity: str = "P0_BLOCKER",
    status: str = "unresolved",
    kind: str = "conflict",
) -> dict[str, object]:
    return {
        "schema_version": 1,
        "issue_id": issue_id,
        "severity": severity,
        "status": status,
        "kind": kind,
        "scope": ["surface.today"],
        "summary": "Primary identity conflict remains unresolved.",
    }


def initialize_empty_cli_root(root: Path) -> Path:
    canon = root / "docs" / "canon"
    canon.mkdir(parents=True)
    (canon / "MANIFEST.toml").write_text(
        "schema_version = 1\n"
        "canon_revision = 0\n"
        'authority_state = "shadow"\n'
        'compiler_version = "0.1.0"\n'
        "normative_files = []\n"
        "generated_files = []\n",
        encoding="utf-8",
    )
    write_required_governance_artifacts(canon, canon_revision=0)
    (root / ".gitignore").write_text(".codex/\n", encoding="utf-8")
    intake_path = root / ".codex" / "intake" / "AMB-1842.json"
    intake_path.parent.mkdir(parents=True)
    intake_path.write_text(FIXTURE.read_text(encoding="utf-8"), encoding="utf-8")
    subprocess.run(("git", "init", "-q"), cwd=root, check=True)
    subprocess.run(("git", "add", "."), cwd=root, check=True)
    subprocess.run(
        (
            "git",
            "-c",
            "user.name=Canon Tests",
            "-c",
            "user.email=canon@example.invalid",
            "commit",
            "-qm",
            "fixture",
        ),
        cwd=root,
        check=True,
    )
    return intake_path


def initialize_live_conflict_cli_root(
    root: Path,
    *,
    scope: str,
) -> Path:
    shutil.copytree(ROOT / "docs/canon", root / "docs/canon")
    (root / ".gitignore").write_text(".codex/\n", encoding="utf-8")
    intake_path = root / ".codex" / "intake" / "AMB-1842.json"
    intake_path.parent.mkdir(parents=True)
    intake_data = json.loads(FIXTURE.read_text(encoding="utf-8"))
    intake_data["scope"] = [scope]
    intake_path.write_text(
        json.dumps(intake_data, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    subprocess.run(("git", "init", "-q"), cwd=root, check=True)
    subprocess.run(("git", "add", "."), cwd=root, check=True)
    subprocess.run(
        (
            "git",
            "-c",
            "user.name=Canon Tests",
            "-c",
            "user.email=canon@example.invalid",
            "commit",
            "-qm",
            "fixture",
        ),
        cwd=root,
        check=True,
    )
    return intake_path


class TaskIntakeTests(unittest.TestCase):
    def test_fixture_parses_exact_closed_intake_contract(self):
        value = TaskIntake.from_json(json.loads(FIXTURE.read_text(encoding="utf-8")))

        self.assertEqual(value.issue_id, "AMB-1842")
        self.assertEqual(value.task_type, "swiftui")
        self.assertEqual(value.scope, ("surface.today",))
        self.assertEqual(
            value.changed_files,
            ("Native/Ambitions/Surfaces/Today",),
        )
        self.assertEqual(value.claim_type, "source")
        self.assertEqual(value.known_issue_ids, ())
        self.assertEqual(len(value.sha), 64)

    def test_unknown_or_malformed_intake_fields_fail_closed(self):
        base = json.loads(FIXTURE.read_text(encoding="utf-8"))
        cases = (
            {**base, "unknown": True},
            {**base, "schema_version": True},
            {**base, "scope": []},
            {**base, "changed_files": [1]},
            {**base, "issue_id": "AMB-1842\n## Injected"},
        )
        for data in cases:
            with self.subTest(data=data):
                with self.assertRaises(CanonError) as raised:
                    TaskIntake.from_json(data)
                self.assertEqual(raised.exception.code, "PACK_INTAKE_INVALID")


class TaskPackTests(unittest.TestCase):
    def test_dependency_closure_includes_inherited_law_objects_and_not_time(self):
        pack = build_task_pack(sample_registry(), intake(), "repo-sha", ())

        self.assertEqual(pack.constitutional_laws, ("MISSION-001",))
        self.assertEqual(
            pack.specifications,
            ("SURFACE-TODAY", "SYSTEM-RUNTIME"),
        )
        self.assertEqual(pack.object_lifecycles, ("OBJECT-STEP",))
        self.assertEqual(pack.journeys, ("JOURNEY-START",))
        self.assertEqual(pack.standards, ("STANDARD-NATIVE",))
        self.assertNotIn("SURFACE-TIME", pack.to_markdown())
        self.assertNotIn("Native/Ambitions/Surfaces/Time", pack.source_owners)

    def test_direct_constitution_scopes_include_law_bodies_without_unrelated_specs(
        self,
    ):
        for task_type in ("docs", "constitutional-audit"):
            for scope in ("mission.private-life", "MISSION-001", "CONSTITUTION"):
                with self.subTest(task_type=task_type, scope=scope):
                    scoped = replace(
                        intake(task_type),
                        scope=(scope,),
                    )
                    pack = build_task_pack(
                        sample_registry(),
                        scoped,
                        "repo-sha",
                        (),
                    )

                    self.assertEqual(pack.constitutional_laws, ("MISSION-001",))
                    self.assertIn("Required law for MISSION-001.", pack.to_markdown())
                    self.assertEqual(pack.specifications, ())
                    self.assertNotIn("SURFACE-TIME", pack.to_markdown())

    def test_output_is_deterministic_and_section_order_is_fixed(self):
        first = build_task_pack(sample_registry(), intake(), "repo-sha", ())
        second = build_task_pack(
            sample_registry(reverse=True),
            intake(),
            "repo-sha",
            (),
        )

        self.assertEqual(first.to_markdown(), second.to_markdown())
        self.assertEqual(first.to_json_bytes(), second.to_json_bytes())
        headings = tuple(
            line.removeprefix("## ")
            for line in first.to_markdown().splitlines()
            if line.startswith("## ")
        )
        self.assertEqual(headings, PACK_SECTION_ORDER)

    def test_requirement_body_cannot_inject_pack_sections(self):
        pack = build_task_pack(
            sample_registry(
                oversized_body="Required first line.\n## Injected\nRequired last line."
            ),
            intake(),
            "repo-sha",
            (),
        )

        headings = tuple(
            line.removeprefix("## ")
            for line in pack.to_markdown().splitlines()
            if line.startswith("## ")
        )
        self.assertEqual(headings, PACK_SECTION_ORDER)
        self.assertIn("Required last line.", pack.to_markdown())

    def test_active_pack_rejects_scope_without_an_owner(self):
        registry = sample_registry()
        manifest = replace(
            registry.manifest,
            authority_state=AuthorityState.ACTIVE,
        )
        active = replace(registry, manifest=manifest)
        unknown_scope = replace(intake(), scope=("surface.unknown",))

        with self.assertRaises(CanonError) as raised:
            build_task_pack(active, unknown_scope, "repo-sha", ())

        self.assertEqual(raised.exception.code, "PACK_SCOPE_UNOWNED")

    def test_pack_contains_every_approved_consumption_field(self):
        pack = build_task_pack(sample_registry(), intake(), "repo-sha", ())

        expected = {
            "schema_version",
            "canon_revision",
            "canon_sha",
            "repository_sha",
            "intake_sha",
            "compiler_version",
            "authority_state",
            "issue_id",
            "task_type",
            "budget_class",
            "token_budget",
            "estimated_tokens",
            "scope",
            "changed_files",
            "claim_type",
            "known_issue_ids",
            "intake_path",
            "constitutional_laws",
            "specifications",
            "object_lifecycles",
            "journeys",
            "standards",
            "source_owners",
            "implementation_posture",
            "known_risks",
            "visual_authority",
            "required_tests",
            "required_validation",
            "required_proof",
            "forbidden_changes",
            "open_conflicts",
            "claim_ceiling",
            "rollback_requirements",
        }
        self.assertEqual(set(pack.to_dict()), expected)

        schema = json.loads(
            (ROOT / "docs/canon/schemas/task-pack.schema.json").read_text(
                encoding="utf-8"
            )
        )
        self.assertEqual(set(schema["properties"]), expected)
        self.assertEqual(set(schema["required"]), expected)
        self.assertFalse(schema["additionalProperties"])

    def test_token_estimate_and_budget_contracts_are_exact(self):
        self.assertEqual(estimate_tokens(""), 0)
        self.assertEqual(estimate_tokens("a"), 1)
        self.assertEqual(estimate_tokens("abcd"), 1)
        self.assertEqual(estimate_tokens("abcde"), 2)
        self.assertEqual(
            PACK_BUDGETS,
            {
                "mechanical": 8_000,
                "normal": 16_000,
                "complex": 30_000,
                "constitutional-audit": None,
            },
        )
        self.assertEqual(
            TASK_TYPE_BUDGET_CLASS,
            {
                "mechanical": "mechanical",
                "docs": "normal",
                "release": "normal",
                "swiftui": "complex",
                "runtime": "complex",
                "privacy": "complex",
                "constitutional-audit": "constitutional-audit",
            },
        )
        for task_type, budget_class in (
            ("mechanical", "mechanical"),
            ("docs", "normal"),
            ("swiftui", "complex"),
            ("constitutional-audit", "constitutional-audit"),
        ):
            with self.subTest(task_type=task_type):
                pack = build_task_pack(
                    sample_registry(),
                    intake(task_type),
                    "repo-sha",
                    (),
                )
                self.assertEqual(pack.budget_class, budget_class)
                self.assertEqual(pack.token_budget, PACK_BUDGETS[budget_class])

    def test_unknown_task_type_fails_stably(self):
        with self.assertRaises(CanonError) as raised:
            build_task_pack(sample_registry(), intake("unknown"), "repo-sha", ())

        self.assertEqual(raised.exception.code, "PACK_TASK_TYPE_UNKNOWN")

    def test_over_budget_pack_fails_without_truncating_required_law(self):
        marker = "REQUIRED-LAW-END"
        registry = sample_registry(oversized_body=("x" * 121_000) + marker)

        with self.assertRaises(CanonError) as raised:
            build_task_pack(registry, intake(), "repo-sha", ())

        self.assertEqual(raised.exception.code, "PACK_BUDGET_EXCEEDED")
        self.assertIn("no required content was truncated", raised.exception.message)
        today = next(
            document
            for document in registry.documents
            if document.spec_id == "SURFACE-TODAY"
        )
        self.assertTrue(today.requirements[0].body.endswith(marker))

    def test_stale_canon_repository_and_intake_sha_fail_independently(self):
        pack = build_task_pack(sample_registry(), intake(), "repo-sha", ())
        cases = (
            ({"canon_sha": "changed"}, "PACK_CANON_STALE"),
            ({"repository_sha": "changed"}, "PACK_REPOSITORY_STALE"),
            ({"intake_sha": "changed"}, "PACK_INTAKE_STALE"),
        )
        for changes, code in cases:
            with self.subTest(code=code):
                current = {
                    "canon_sha": pack.canon_sha,
                    "repository_sha": pack.repository_sha,
                    "intake_sha": pack.intake_sha,
                    **changes,
                }
                with self.assertRaises(CanonError) as raised:
                    validate_task_pack(pack.to_dict(), **current)
                self.assertEqual(raised.exception.code, code)

    def test_unresolved_p0_conflict_blocks_pack(self):
        conflicts = (known_issue(),)

        with self.assertRaises(CanonError) as raised:
            build_task_pack(sample_registry(), intake(), "repo-sha", conflicts)

        self.assertEqual(raised.exception.code, "PACK_P0_CONFLICT")

    def test_unresolved_p0_risk_also_blocks_pack(self):
        with self.assertRaises(CanonError) as raised:
            build_task_pack(
                sample_registry(),
                intake(),
                "repo-sha",
                (known_issue("RISK-001", kind="risk"),),
            )

        self.assertEqual(raised.exception.code, "PACK_P0_CONFLICT")

    def test_known_issue_contract_is_closed_versioned_and_canonical(self):
        valid = known_issue()
        invalid = (
            {**valid, "severity": "p0_blocker"},
            {**valid, "severity": "BANANA"},
            {**valid, "status": "maybe"},
            {**valid, "kind": "incident"},
            {**valid, "schema_version": True},
            {**valid, "schema_version": 2},
            {**valid, "scope": ("surface.today",)},
            {**valid, "summary": 1},
            {key: value for key, value in valid.items() if key != "kind"},
            {**valid, "unknown": True},
        )
        for issue in invalid:
            with self.subTest(issue=issue):
                with self.assertRaises(CanonError) as raised:
                    build_task_pack(sample_registry(), intake(), "repo-sha", (issue,))
                self.assertEqual(raised.exception.code, "PACK_ISSUE_INVALID")

    def test_duplicate_known_issue_ids_reject_before_other_schema_errors(self):
        malformed_duplicate = {**known_issue(), "severity": "BANANA"}

        with self.assertRaises(CanonError) as raised:
            build_task_pack(
                sample_registry(),
                intake(),
                "repo-sha",
                (known_issue(), malformed_duplicate),
            )

        self.assertEqual(raised.exception.code, "PACK_ISSUE_DUPLICATE")

    def test_malformed_known_issue_fails_with_issue_contract_code(self):
        with self.assertRaises(CanonError) as raised:
            build_task_pack(
                sample_registry(),
                intake(),
                "repo-sha",
                ({"issue_id": None},),
            )

        self.assertEqual(raised.exception.code, "PACK_ISSUE_INVALID")

    def test_declared_known_issue_must_be_supplied_to_pack_builder(self):
        declared = replace(intake(), known_issue_ids=("AMB-1999",))

        with self.assertRaises(CanonError) as raised:
            build_task_pack(sample_registry(), declared, "repo-sha", ())

        self.assertEqual(raised.exception.code, "PACK_KNOWN_ISSUE_MISSING")

    def test_shadow_pack_is_explicitly_non_authorizing(self):
        pack = build_task_pack(sample_registry(), intake(), "repo-sha", ())

        self.assertIn("Shadow", pack.to_markdown())
        self.assertIn("cannot authorize implementation", pack.to_markdown())
        self.assertIn("cannot authorize implementation", pack.claim_ceiling)

    def test_write_task_pack_uses_ignored_shell_safe_atomic_paths(self):
        pack = build_task_pack(sample_registry(), intake(), "repo-sha", ())
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)

            markdown_path, json_path = write_task_pack(root, pack)

            expected_parent = root / ".codex" / "canon-packs" / pack.canon_sha
            self.assertEqual(markdown_path.parent, expected_parent)
            self.assertEqual(json_path.parent, expected_parent)
            self.assertEqual(markdown_path.name, "amb-1842-swiftui.md")
            self.assertEqual(json_path.name, "amb-1842-swiftui.json")
            self.assertEqual(markdown_path.read_text(), pack.to_markdown())
            self.assertEqual(json_path.read_bytes(), pack.to_json_bytes())
            self.assertFalse(
                any(path.suffix == ".tmp" for path in expected_parent.iterdir())
            )

    def test_pair_install_failure_restores_both_previous_files(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            old_pack = build_task_pack(sample_registry(), intake(), "old-repo", ())
            markdown_path, json_path = write_task_pack(root, old_pack)
            old_markdown = markdown_path.read_bytes()
            old_json = json_path.read_bytes()
            new_pack = build_task_pack(sample_registry(), intake(), "new-repo", ())

            with mock.patch.object(
                task_pack_module,
                "_verify_installed_pair",
                side_effect=CanonError(
                    "PACK_INSTALL_INJECTED",
                    "injected second-file verification failure",
                ),
            ):
                with self.assertRaises(CanonError) as raised:
                    write_task_pack(root, new_pack)

            self.assertEqual(raised.exception.code, "PACK_INSTALL_INJECTED")
            self.assertEqual(markdown_path.read_bytes(), old_markdown)
            self.assertEqual(json_path.read_bytes(), old_json)
            self.assertEqual(
                tuple(sorted(path.name for path in markdown_path.parent.iterdir())),
                tuple(sorted((markdown_path.name, json_path.name))),
            )

    def test_pair_install_failure_restores_first_install_and_partial_prior_states(self):
        pack = build_task_pack(sample_registry(), intake(), "repo-sha", ())
        for prior in ("none", "markdown-only"):
            with self.subTest(prior=prior):
                with tempfile.TemporaryDirectory() as temporary_directory:
                    root = Path(temporary_directory)
                    markdown_path, json_path = task_pack_paths(root, pack)
                    if prior == "markdown-only":
                        markdown_path.parent.mkdir(parents=True)
                        markdown_path.write_text("old markdown\n", encoding="utf-8")
                    with mock.patch.object(
                        task_pack_module,
                        "_verify_installed_pair",
                        side_effect=CanonError(
                            "PACK_INSTALL_INJECTED",
                            "injected pair verification failure",
                        ),
                    ):
                        with self.assertRaises(CanonError):
                            write_task_pack(root, pack)

                    self.assertEqual(
                        markdown_path.exists(),
                        prior == "markdown-only",
                    )
                    if prior == "markdown-only":
                        self.assertEqual(markdown_path.read_text(), "old markdown\n")
                    self.assertFalse(json_path.exists())

    def test_partial_prior_pair_is_replaced_together_on_success(self):
        pack = build_task_pack(sample_registry(), intake(), "repo-sha", ())
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            markdown_path, json_path = task_pack_paths(root, pack)
            markdown_path.parent.mkdir(parents=True)
            markdown_path.write_text("old markdown\n", encoding="utf-8")

            written_markdown, written_json = write_task_pack(root, pack)

            self.assertEqual(written_markdown.read_text(), pack.to_markdown())
            self.assertEqual(written_json.read_bytes(), pack.to_json_bytes())

    def test_atomic_update_preserves_sibling_pack_names_on_success_and_failure(self):
        other_intake = TaskIntake.from_json(
            {
                "schema_version": 1,
                "issue_id": "AMB-1999",
                "task_type": "swiftui",
                "scope": ["surface.today"],
                "changed_files": ["Native/Ambitions/Surfaces/Today"],
                "claim_type": "source",
                "known_issue_ids": [],
            }
        )
        first = build_task_pack(sample_registry(), intake(), "repo-sha", ())
        sibling = build_task_pack(sample_registry(), other_intake, "repo-sha", ())
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            first_paths = write_task_pack(root, first)
            sibling_paths = write_task_pack(root, sibling)
            before = {
                path.name: path.read_bytes() for path in first_paths + sibling_paths
            }

            updated_sibling = build_task_pack(
                sample_registry(),
                other_intake,
                "new-repo-sha",
                (),
            )
            with mock.patch.object(
                task_pack_module,
                "_verify_installed_pair",
                side_effect=CanonError(
                    "PACK_INSTALL_INJECTED",
                    "injected sibling update failure",
                ),
            ):
                with self.assertRaises(CanonError):
                    write_task_pack(root, updated_sibling)

            after = {
                path.name: path.read_bytes() for path in first_paths + sibling_paths
            }
            self.assertEqual(after, before)
            self.assertEqual(
                tuple(sorted(path.name for path in first_paths[0].parent.iterdir())),
                tuple(sorted(before)),
            )

    def test_compare_and_swap_aborts_lost_update_and_preserves_interleaved_sibling(
        self,
    ):
        other_intake = TaskIntake.from_json(
            {
                "schema_version": 1,
                "issue_id": "AMB-2000",
                "task_type": "swiftui",
                "scope": ["surface.today"],
                "changed_files": ["Native/Ambitions/Surfaces/Today"],
                "claim_type": "source",
                "known_issue_ids": [],
            }
        )
        writer_a = build_task_pack(sample_registry(), intake(), "writer-a", ())
        writer_b = build_task_pack(
            sample_registry(),
            other_intake,
            "writer-b",
            (),
        )
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            original_require = task_pack_module._require_pack_snapshot
            interleaved = False

            def commit_writer_b_then_compare(path, snapshot):
                nonlocal interleaved
                if not interleaved:
                    interleaved = True
                    write_task_pack(root, writer_b)
                return original_require(path, snapshot)

            with mock.patch.object(
                task_pack_module,
                "_require_pack_snapshot",
                side_effect=commit_writer_b_then_compare,
            ):
                with self.assertRaises(CanonError) as raised:
                    write_task_pack(root, writer_a)

            self.assertEqual(
                raised.exception.code,
                "PACK_CONCURRENT_MODIFICATION",
            )
            writer_b_paths = task_pack_paths(root, writer_b)
            self.assertEqual(writer_b_paths[0].read_text(), writer_b.to_markdown())
            self.assertEqual(writer_b_paths[1].read_bytes(), writer_b.to_json_bytes())
            writer_a_paths = task_pack_paths(root, writer_a)
            self.assertFalse(writer_a_paths[0].exists())
            self.assertFalse(writer_a_paths[1].exists())

    def test_cli_pack_check_rejects_each_stale_input(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            canon = root / "docs" / "canon"
            canon.mkdir(parents=True)
            manifest = canon / "MANIFEST.toml"
            manifest.write_text(
                "schema_version = 1\n"
                "canon_revision = 0\n"
                'authority_state = "shadow"\n'
                'compiler_version = "0.1.0"\n'
                "normative_files = []\n"
                "generated_files = []\n",
                encoding="utf-8",
            )
            write_required_governance_artifacts(canon, canon_revision=0)
            (root / ".gitignore").write_text(".codex/\n", encoding="utf-8")
            intake_path = root / ".codex" / "intake" / "AMB-1842.json"
            intake_path.parent.mkdir(parents=True)
            intake_data = json.loads(FIXTURE.read_text(encoding="utf-8"))
            intake_path.write_text(json.dumps(intake_data), encoding="utf-8")
            subprocess.run(("git", "init", "-q"), cwd=root, check=True)
            subprocess.run(("git", "add", "."), cwd=root, check=True)
            subprocess.run(
                (
                    "git",
                    "-c",
                    "user.name=Canon Tests",
                    "-c",
                    "user.email=canon@example.invalid",
                    "commit",
                    "-qm",
                    "fixture",
                ),
                cwd=root,
                check=True,
            )

            self.assertEqual(_pack(root, intake_path, check=False), 0)
            self.assertEqual(_pack(root, intake_path, check=True), 0)

            (root / ".gitignore").write_text(".codex/\n# changed\n", encoding="utf-8")
            output = io.StringIO()
            with redirect_stdout(output):
                self.assertEqual(_pack(root, intake_path, check=True), 1)
            self.assertIn("PACK_REPOSITORY_STALE", output.getvalue())
            subprocess.run(
                ("git", "checkout", "--", ".gitignore"), cwd=root, check=True
            )

            manifest.write_text(
                manifest.read_text(encoding="utf-8").replace(
                    "canon_revision = 0",
                    "canon_revision = 1",
                ),
                encoding="utf-8",
            )
            output = io.StringIO()
            with redirect_stdout(output):
                self.assertEqual(_pack(root, intake_path, check=True), 1)
            self.assertIn("PACK_CANON_STALE", output.getvalue())
            subprocess.run(
                ("git", "checkout", "--", "docs/canon/MANIFEST.toml"),
                cwd=root,
                check=True,
            )

            intake_data["claim_type"] = "proof"
            intake_path.write_text(json.dumps(intake_data), encoding="utf-8")
            output = io.StringIO()
            with redirect_stdout(output):
                self.assertEqual(_pack(root, intake_path, check=True), 1)
            self.assertIn("PACK_INTAKE_STALE", output.getvalue())

    def test_cli_pack_generate_fails_closed_when_today_docket_is_deleted(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            intake_path = initialize_live_conflict_cli_root(
                root,
                scope="surface.unrelated",
            )
            today = (
                root
                / "docs/canon/decisions/open/conflict-today-primary-identity.md"
            )
            today.unlink()
            output = io.StringIO()
            with redirect_stdout(output):
                self.assertEqual(_pack(root, intake_path, check=False), 1)
            self.assertIn("CONFLICT_DOCKET_REMOVAL_BLOCKED", output.getvalue())
            self.assertFalse((root / ".codex/canon-packs").exists())

    def test_cli_pack_check_revalidates_all_dockets_before_scope_filtering(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            intake_path = initialize_live_conflict_cli_root(
                root,
                scope="surface.unrelated",
            )
            self.assertEqual(_pack(root, intake_path, check=False), 0)
            today = (
                root
                / "docs/canon/decisions/open/conflict-today-primary-identity.md"
            )
            today.unlink()
            output = io.StringIO()
            with redirect_stdout(output):
                self.assertEqual(_pack(root, intake_path, check=True), 1)
            self.assertIn("CONFLICT_DOCKET_REMOVAL_BLOCKED", output.getvalue())

    def test_cli_pack_resume_revalidates_dockets_after_pinned_pack_read(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            intake_path = initialize_live_conflict_cli_root(
                root,
                scope="surface.unrelated",
            )
            self.assertEqual(_pack(root, intake_path, check=False), 0)
            original_require = canon_cli._require_source_snapshot
            mutated = False

            def delete_docket_before_resume(*arguments):
                nonlocal mutated
                if not mutated:
                    mutated = True
                    (
                        root
                        / "docs/canon/decisions/open/"
                        "conflict-today-primary-identity.md"
                    ).unlink()
                return original_require(*arguments)

            output = io.StringIO()
            with mock.patch.object(
                canon_cli,
                "_require_source_snapshot",
                side_effect=delete_docket_before_resume,
            ):
                with redirect_stdout(output):
                    self.assertEqual(_pack(root, intake_path, check=True), 1)
            self.assertIn("CONFLICT_DOCKET_REMOVAL_BLOCKED", output.getvalue())

    def test_cli_pack_check_reports_not_found_when_pack_root_is_absent(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            intake_path = initialize_empty_cli_root(root)
            output = io.StringIO()

            with redirect_stdout(output):
                self.assertEqual(_pack(root, intake_path, check=True), 1)

            self.assertIn("PACK_NOT_FOUND", output.getvalue())

    def test_cli_pack_refuses_dependency_cycle_before_generation(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            canon = root / "docs" / "canon"
            canon.mkdir(parents=True)
            (canon / "MANIFEST.toml").write_text(
                "schema_version = 1\n"
                "canon_revision = 1\n"
                'authority_state = "shadow"\n'
                'compiler_version = "0.1.0"\n'
                'normative_files = ["a.md", "b.md"]\n'
                "generated_files = []\n",
                encoding="utf-8",
            )
            (canon / "a.md").write_text(
                markdown_document(
                    "SPEC-A",
                    "system.a",
                    depends_on=("SPEC-B",),
                ),
                encoding="utf-8",
            )
            (canon / "b.md").write_text(
                markdown_document(
                    "SPEC-B",
                    "system.b",
                    depends_on=("SPEC-A",),
                ),
                encoding="utf-8",
            )
            write_required_governance_artifacts(
                canon,
                canon_revision=1,
            )
            (root / ".gitignore").write_text(".codex/\n", encoding="utf-8")
            intake_path = root / ".codex" / "intake" / "AMB-1842.json"
            intake_path.parent.mkdir(parents=True)
            intake_path.write_text(FIXTURE.read_text(encoding="utf-8"))
            subprocess.run(("git", "init", "-q"), cwd=root, check=True)
            subprocess.run(("git", "add", "."), cwd=root, check=True)
            subprocess.run(
                (
                    "git",
                    "-c",
                    "user.name=Canon Tests",
                    "-c",
                    "user.email=canon@example.invalid",
                    "commit",
                    "-qm",
                    "fixture",
                ),
                cwd=root,
                check=True,
            )

            output = io.StringIO()
            with redirect_stdout(output):
                self.assertEqual(_pack(root, intake_path, check=False), 1)

            self.assertIn("CANON_DEPENDENCY_CYCLE", output.getvalue())
            self.assertFalse((root / ".codex" / "canon-packs").exists())

    def test_public_pack_builder_refuses_audited_cycle_before_closure(self):
        cyclic = build_registry(
            sample_registry().manifest,
            (
                document(
                    "SYSTEM-A",
                    kind=DocumentKind.SYSTEM,
                    concepts=("system.a",),
                    requirements=(requirement("A-001", "system.a"),),
                    depends_on=("SYSTEM-B",),
                ),
                document(
                    "SYSTEM-B",
                    kind=DocumentKind.SYSTEM,
                    concepts=("system.b",),
                    requirements=(requirement("B-001", "system.b"),),
                    depends_on=("SYSTEM-A",),
                ),
                document(
                    "SURFACE-TIME",
                    kind=DocumentKind.SURFACE,
                    concepts=("surface.time",),
                    requirements=(requirement("TIME-001", "surface.time"),),
                ),
            ),
        )
        scoped = replace(intake(), scope=("system.a",))

        with self.assertRaises(CanonError) as raised:
            build_task_pack(cyclic, scoped, "repo-sha", ())

        self.assertEqual(raised.exception.code, "PACK_CANON_AUDIT_FAILED")
        self.assertIn("CANON_DEPENDENCY_CYCLE", raised.exception.message)
        self.assertNotIn("SURFACE-TIME", raised.exception.message)

    def test_cli_pack_check_rejects_symlinked_pack_ancestors_and_members(self):
        for attack in ("pack-root", "sha-directory", "markdown", "json"):
            with self.subTest(attack=attack):
                with tempfile.TemporaryDirectory() as temporary_directory:
                    with tempfile.TemporaryDirectory() as external_directory:
                        root = Path(temporary_directory)
                        external = Path(external_directory) / "intruder"
                        intake_path = initialize_empty_cli_root(root)
                        self.assertEqual(_pack(root, intake_path, check=False), 0)
                        json_path = next(
                            (root / ".codex" / "canon-packs").glob("*/*.json")
                        )
                        markdown_path = json_path.with_suffix(".md")
                        sha_directory = json_path.parent
                        pack_root = sha_directory.parent

                        if attack == "pack-root":
                            shutil.copytree(pack_root, external)
                            shutil.rmtree(pack_root)
                            pack_root.symlink_to(external, target_is_directory=True)
                        elif attack == "sha-directory":
                            shutil.copytree(sha_directory, external)
                            shutil.rmtree(sha_directory)
                            sha_directory.symlink_to(
                                external,
                                target_is_directory=True,
                            )
                        else:
                            attacked = (
                                markdown_path if attack == "markdown" else json_path
                            )
                            external.mkdir()
                            external_file = external / attacked.name
                            shutil.copyfile(attacked, external_file)
                            attacked.unlink()
                            attacked.symlink_to(external_file)

                        before = tuple(
                            (path.relative_to(external), path.read_bytes())
                            for path in sorted(external.rglob("*"))
                            if path.is_file()
                        )
                        output = io.StringIO()
                        with redirect_stdout(output):
                            self.assertEqual(_pack(root, intake_path, check=True), 1)

                        self.assertIn("PACK_PATH_ESCAPE", output.getvalue())
                        after = tuple(
                            (path.relative_to(external), path.read_bytes())
                            for path in sorted(external.rglob("*"))
                            if path.is_file()
                        )
                        self.assertEqual(after, before)

    def test_generation_revalidates_repository_canon_and_exact_intake_before_commit(
        self,
    ):
        cases = (
            ("repository", "PACK_REPOSITORY_STALE"),
            ("canon", "PACK_CANON_STALE"),
            ("canon-content", "PACK_CANON_STALE"),
            ("intake", "PACK_INTAKE_STALE"),
            ("intake-bytes", "PACK_INTAKE_STALE"),
        )
        for mutation, code in cases:
            with self.subTest(mutation=mutation):
                with tempfile.TemporaryDirectory() as temporary_directory:
                    root = Path(temporary_directory)
                    intake_path = initialize_empty_cli_root(root)
                    self.assertEqual(_pack(root, intake_path, check=False), 0)
                    old_json = next((root / ".codex" / "canon-packs").glob("*/*.json"))
                    old_markdown = old_json.with_suffix(".md")
                    prior = (old_markdown.read_bytes(), old_json.read_bytes())
                    original_require = canon_cli._require_source_snapshot
                    mutated = False

                    def mutate_then_revalidate(path_root, path_intake, snapshot):
                        nonlocal mutated
                        if not mutated:
                            mutated = True
                            if mutation == "repository":
                                (root / ".gitignore").write_text(
                                    ".codex/\n# tracked mutation\n",
                                    encoding="utf-8",
                                )
                            elif mutation in {"canon", "canon-content"}:
                                manifest = root / "docs/canon/MANIFEST.toml"
                                if mutation == "canon":
                                    changed = manifest.read_text().replace(
                                        "canon_revision = 0",
                                        "canon_revision = 1",
                                    )
                                else:
                                    changed = manifest.read_text() + "# byte mutation\n"
                                manifest.write_text(changed, encoding="utf-8")
                            elif mutation == "intake-bytes":
                                intake_path.write_text(
                                    intake_path.read_text() + "\n",
                                    encoding="utf-8",
                                )
                            else:
                                intake_data = json.loads(intake_path.read_text())
                                intake_data["claim_type"] = "proof"
                                intake_path.write_text(
                                    json.dumps(intake_data),
                                    encoding="utf-8",
                                )
                        return original_require(path_root, path_intake, snapshot)

                    output = io.StringIO()
                    with mock.patch.object(
                        canon_cli,
                        "_require_source_snapshot",
                        side_effect=mutate_then_revalidate,
                    ):
                        with redirect_stdout(output):
                            self.assertEqual(_pack(root, intake_path, check=False), 1)

                    self.assertIn(code, output.getvalue())
                    self.assertEqual(
                        (old_markdown.read_bytes(), old_json.read_bytes()),
                        prior,
                    )

    def test_generation_revalidates_repository_after_precondition_and_rolls_back(
        self,
    ):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            intake_path = initialize_empty_cli_root(root)
            self.assertEqual(_pack(root, intake_path, check=False), 0)
            pack_root = root / ".codex" / "canon-packs"
            prior = {
                path.relative_to(pack_root): path.read_bytes()
                for path in sorted(pack_root.rglob("*"))
                if path.is_file()
            }
            original_rename = canon_build._rename_noreplace
            mutated = False

            def mutate_after_precondition(*args, **kwargs):
                nonlocal mutated
                if not mutated:
                    mutated = True
                    (root / ".gitignore").write_text(
                        ".codex/\n# mutation after source precondition\n",
                        encoding="utf-8",
                    )
                return original_rename(*args, **kwargs)

            output = io.StringIO()
            with mock.patch.object(
                canon_build,
                "_rename_noreplace",
                side_effect=mutate_after_precondition,
            ):
                with redirect_stdout(output):
                    self.assertEqual(_pack(root, intake_path, check=False), 1)

            self.assertIn("PACK_REPOSITORY_STALE", output.getvalue())
            after = {
                path.relative_to(pack_root): path.read_bytes()
                for path in sorted(pack_root.rglob("*"))
                if path.is_file()
            }
            self.assertEqual(after, prior)
            self.assertFalse(
                any(
                    path.name.startswith(".ambitions-canon-")
                    for path in pack_root.iterdir()
                )
            )

    def test_source_postcondition_runs_after_pair_check_and_restores_prior_states(
        self,
    ):
        for stale_code in ("PACK_INTAKE_STALE", "PACK_CANON_STALE"):
            for prior_state in ("complete", "partial", "none"):
                with self.subTest(code=stale_code, prior=prior_state):
                    with tempfile.TemporaryDirectory() as temporary_directory:
                        root = Path(temporary_directory)
                        old_pack = build_task_pack(
                            sample_registry(),
                            intake(),
                            "old-repository",
                            (),
                        )
                        new_pack = build_task_pack(
                            sample_registry(),
                            intake(),
                            "new-repository",
                            (),
                        )
                        markdown_path, json_path = task_pack_paths(root, new_pack)
                        if prior_state == "complete":
                            write_task_pack(root, old_pack)
                        elif prior_state == "partial":
                            markdown_path.parent.mkdir(parents=True)
                            markdown_path.write_text(
                                "prior markdown\n",
                                encoding="utf-8",
                            )
                        pack_root = root / ".codex" / "canon-packs"
                        before = (
                            {
                                path.relative_to(pack_root): path.read_bytes()
                                for path in sorted(pack_root.rglob("*"))
                                if path.is_file()
                            }
                            if pack_root.exists()
                            else {}
                        )
                        events: list[str] = []
                        source_calls = 0
                        original_verify = task_pack_module._verify_installed_pair

                        def source_snapshot_check():
                            nonlocal source_calls
                            source_calls += 1
                            events.append("source")
                            if source_calls == 2:
                                raise CanonError(stale_code, "injected stale source")

                        def record_pair_check(path, expected):
                            events.append("pair")
                            return original_verify(path, expected)

                        with mock.patch.object(
                            task_pack_module,
                            "_verify_installed_pair",
                            side_effect=record_pair_check,
                        ):
                            with self.assertRaises(CanonError) as raised:
                                write_task_pack(
                                    root,
                                    new_pack,
                                    source_precondition=source_snapshot_check,
                                )

                        self.assertEqual(raised.exception.code, stale_code)
                        self.assertEqual(events, ["source", "pair", "source"])
                        after = (
                            {
                                path.relative_to(pack_root): path.read_bytes()
                                for path in sorted(pack_root.rglob("*"))
                                if path.is_file()
                            }
                            if pack_root.exists()
                            else {}
                        )
                        self.assertEqual(after, before)
                        if pack_root.exists():
                            self.assertFalse(
                                any(
                                    path.name.startswith(".ambitions-canon-")
                                    for path in pack_root.iterdir()
                                )
                            )

    def test_source_postcondition_preserves_intruder_and_restores_prior_pack(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            old_pack = build_task_pack(sample_registry(), intake(), "old-repo", ())
            new_pack = build_task_pack(sample_registry(), intake(), "new-repo", ())
            old_paths = write_task_pack(root, old_pack)
            prior = tuple(path.read_bytes() for path in old_paths)
            pack_directory = old_paths[0].parent
            pack_root = pack_directory.parent
            external = root / "external-intruder"
            external.mkdir()
            (external / "keep.txt").write_text("keep\n", encoding="utf-8")
            displaced = root / "displaced-installed-pack"
            source_calls = 0

            def swap_to_intruder_then_fail():
                nonlocal source_calls
                source_calls += 1
                if source_calls == 2:
                    pack_directory.rename(displaced)
                    pack_directory.symlink_to(external, target_is_directory=True)
                    raise CanonError(
                        "PACK_REPOSITORY_STALE",
                        "injected stale source after intruder swap",
                    )

            with self.assertRaises(CanonError) as raised:
                write_task_pack(
                    root,
                    new_pack,
                    source_precondition=swap_to_intruder_then_fail,
                )

            self.assertEqual(raised.exception.code, "PACK_REPOSITORY_STALE")
            self.assertEqual(tuple(path.read_bytes() for path in old_paths), prior)
            self.assertEqual((external / "keep.txt").read_text(), "keep\n")
            quarantines = tuple(pack_root.glob(".ambitions-canon-quarantine-*"))
            self.assertEqual(len(quarantines), 1)
            self.assertTrue(quarantines[0].is_symlink())
            self.assertFalse(
                any(
                    path.name.startswith(".ambitions-canon-build-")
                    or path.name.startswith(".ambitions-canon-previous-")
                    for path in pack_root.iterdir()
                )
            )

    def test_check_revalidates_source_snapshot_after_pinned_pack_read(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            intake_path = initialize_empty_cli_root(root)
            self.assertEqual(_pack(root, intake_path, check=False), 0)
            original_require = canon_cli._require_source_snapshot
            mutated = False

            def mutate_after_read(path_root, path_intake, snapshot):
                nonlocal mutated
                if not mutated:
                    mutated = True
                    (root / ".gitignore").write_text(
                        ".codex/\n# changed after pack read\n",
                        encoding="utf-8",
                    )
                return original_require(path_root, path_intake, snapshot)

            output = io.StringIO()
            with mock.patch.object(
                canon_cli,
                "_require_source_snapshot",
                side_effect=mutate_after_read,
            ):
                with redirect_stdout(output):
                    self.assertEqual(_pack(root, intake_path, check=True), 1)

            self.assertIn("PACK_REPOSITORY_STALE", output.getvalue())

    def test_repository_fingerprint_covers_staged_unstaged_untracked_and_ignores_codex(
        self,
    ):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            initialize_empty_cli_root(root)
            baseline = canon_cli._repository_state_sha(root)

            ignored = root / ".codex" / "canon-packs" / "ignored.txt"
            ignored.parent.mkdir(parents=True)
            ignored.write_text("ignored\n", encoding="utf-8")
            self.assertEqual(canon_cli._repository_state_sha(root), baseline)

            gitignore = root / ".gitignore"
            gitignore.write_text(".codex/\n# unstaged\n", encoding="utf-8")
            unstaged = canon_cli._repository_state_sha(root)
            self.assertNotEqual(unstaged, baseline)

            subprocess.run(("git", "add", ".gitignore"), cwd=root, check=True)
            staged = canon_cli._repository_state_sha(root)
            self.assertNotEqual(staged, baseline)
            self.assertNotEqual(staged, unstaged)

            subprocess.run(("git", "reset", "--hard", "-q"), cwd=root, check=True)
            (root / "untracked.txt").write_text("untracked\n", encoding="utf-8")
            untracked = canon_cli._repository_state_sha(root)
            self.assertNotEqual(untracked, baseline)

    def test_pack_reader_rejects_sha_and_member_swaps_during_pinned_read(self):
        for attack in ("sha-directory", "json"):
            with self.subTest(attack=attack):
                with tempfile.TemporaryDirectory() as temporary_directory:
                    with tempfile.TemporaryDirectory() as external_directory:
                        root = Path(temporary_directory)
                        external = Path(external_directory)
                        pack = build_task_pack(
                            sample_registry(),
                            intake(),
                            "repo-sha",
                            (),
                        )
                        markdown_path, json_path = write_task_pack(root, pack)
                        sha_directory = json_path.parent
                        original_read = task_pack_module._read_file_at
                        calls = 0

                        def swap_after_first_read(descriptor, path):
                            nonlocal calls
                            content = original_read(descriptor, path)
                            calls += 1
                            if calls == 1:
                                if attack == "sha-directory":
                                    intruder = external / "intruder"
                                    shutil.copytree(sha_directory, intruder)
                                    hidden = sha_directory.with_name("hidden-prior")
                                    sha_directory.rename(hidden)
                                    sha_directory.symlink_to(
                                        intruder,
                                        target_is_directory=True,
                                    )
                                else:
                                    intruder = external / json_path.name
                                    shutil.copyfile(json_path, intruder)
                                    json_path.unlink()
                                    json_path.symlink_to(intruder)
                            return content

                        with mock.patch.object(
                            task_pack_module,
                            "_read_file_at",
                            side_effect=swap_after_first_read,
                        ):
                            with self.assertRaises(CanonError) as raised:
                                read_task_pack_pair(root, pack)

                        self.assertEqual(raised.exception.code, "PACK_PATH_ESCAPE")
                        self.assertGreaterEqual(calls, 1)
                        self.assertTrue(markdown_path.name.endswith(".md"))


if __name__ == "__main__":
    unittest.main()
