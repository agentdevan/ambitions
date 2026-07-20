import json
import io
import hashlib
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
from tools.ambitions_canon.cli import _check_pack_path, _pack
from tools.ambitions_canon.model import (
    AuthorityClass,
    AuthorityReference,
    AuthorityReferenceKind,
    AuthorityState,
    CanonDocument,
    CanonError,
    CanonManifest,
    DocumentKind,
    Modality,
    Requirement,
    FigmaAuthorityRole,
    StateCommand,
    StateCommandActivationPosture,
    StateCommandContract,
    StateCommandResolutionPosture,
)
from tools.ambitions_canon.manifest import load_documents, load_manifest
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
from tools.ambitions_canon.traceability import build_traceability
from tests.canon.test_audit import markdown_document, requirement_block
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
    profile: str | None = None,
    source_bytes: bytes | None = None,
) -> CanonDocument:
    return CanonDocument(
        spec_id=spec_id,
        title=spec_id,
        kind=kind,
        status="normative",
        owner_domain="product",
        canon_revision=1,
        profile=profile,
        owns_concepts=concepts,
        inherits=inherits,
        depends_on=depends_on,
        source_owners=source_owners,
        sections=frozenset(),
        not_applicable=(),
        requirements=requirements,
        source_path=Path(f"docs/canon/{spec_id.lower()}.md"),
        source_bytes=source_bytes or f"source:{spec_id}\n".encode(),
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


STANDARD_PROFILE_SECTIONS = (
    "purpose",
    "scope",
    "requirements",
    "exceptions",
    "verification",
    "source-ownership",
    "proof",
    "amendment-impact",
)


def standard_profile_source(section_lines: tuple[str, ...]) -> bytes:
    front_matter = (
        "+++\n"
        'spec_id = "STANDARD-NATIVE"\n'
        'title = "STANDARD-NATIVE"\n'
        'kind = "standard"\n'
        'status = "normative"\n'
        'owner_domain = "product"\n'
        "canon_revision = 1\n"
        'profile = "standard-v1"\n'
        'owns_concepts = ["standard.native-ios"]\n'
        'inherits = ["MISSION-001"]\n'
        "depends_on = []\n"
        "source_owners = []\n"
        "+++\n\n# Standard\n\n"
    )
    return (front_matter + "\n".join(section_lines) + "\n").encode()


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
    # This synthetic conflict fixture intentionally omits the complete external
    # UX-blueprint source corpus and therefore must not install its visual gate.
    (root / "docs/canon/migration/visual-authority-rebaseline.json").unlink()
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


def remove_first_supersession_entry(root: Path) -> None:
    ledger = root / "docs/canon/decisions/SUPERSESSION_LEDGER.toml"
    text = ledger.read_text(encoding="utf-8")
    first = text.index("[[entries]]")
    second = text.index("[[entries]]", first + 1)
    ledger.write_text(text[:first] + text[second:], encoding="utf-8")


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

    def test_authorization_path_roots_become_bounded_pack_scope(self):
        data = {
            "schema_version": 1,
            "intake_id": "INTAKE-REPAIR",
            "task_id": "CODEX-AUTONOMOUS-REPAIR-DELEGATION",
            "issue_reference": "CODEX-AUTONOMOUS-REPAIR-DELEGATION",
            "requested_task_type": "mechanical",
            "requested_scope": ["ordinary-repair"],
            "requested_requirement_ids": ["CONST-PROOF-EVIDENCE-001"],
            "requested_changed_files": [],
            "requested_validation": ["canon-unit"],
            "requested_proof": ["offline-determinism"],
            "requested_rollback": ["git-revert"],
            "requested_claim_ceiling": "Ordinary repair only",
            "requested_skill_adapters": [],
            "requested_authorization_mode": "path-roots",
            "requested_path_roots": ["Native", "tests"],
            "requested_max_changed_files": 32,
            "requested_max_changed_bytes": 1048576,
        }
        value = TaskIntake.from_authorization_intake(data)
        self.assertEqual(value.changed_files, ("Native", "tests"))


class TaskPackTests(unittest.TestCase):
    def test_optional_visual_manifest_absence_skips_full_ux_inputs(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            intake_path = initialize_empty_cli_root(root)

            self.assertEqual(_pack(root, intake_path, check=False), 0)

    def test_pack_check_reparses_authorization_intake_schema(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            intake_path = initialize_empty_cli_root(root)
            intake_path.write_text(
                json.dumps(
                    {
                        "schema_version": 1,
                        "intake_id": "INTAKE-CEBR-01",
                        "task_id": "CEBR-01-CANON-INTEGRATION",
                        "issue_reference": "CEBR-01-CANON-INTEGRATION",
                        "requested_task_type": "release",
                        "requested_scope": ["MISSION-REFLOW-001"],
                        "requested_requirement_ids": ["MISSION-REFLOW-001"],
                        "requested_changed_files": ["docs/canon/MANIFEST.toml"],
                        "requested_validation": ["canon-audit"],
                        "requested_proof": ["canon-compiler-green"],
                        "requested_rollback": ["git-revert"],
                        "requested_claim_ceiling": "Canon design intent only",
                        "requested_skill_adapters": [
                            "ambitions-source-truth-authority"
                        ],
                    },
                    indent=2,
                    sort_keys=True,
                )
                + "\n",
                encoding="utf-8",
            )

            self.assertEqual(_pack(root, intake_path, check=False), 0)
            pack_path = next((root / ".codex/canon-packs").glob("*/*.json"))
            self.assertEqual(_check_pack_path(root, pack_path), 0)

    def test_optional_visual_manifest_detects_absent_to_present_mutation(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            initialize_empty_cli_root(root)
            manifest = (
                root
                / "docs/canon/migration/visual-authority-rebaseline.json"
            )

            with self.assertRaises(CanonError) as raised:
                with task_pack_module._optional_visual_authority_manifest(
                    root
                ) as present:
                    self.assertFalse(present)
                    manifest.write_text("{}\n", encoding="utf-8")

            self.assertEqual(
                raised.exception.code,
                "PACK_VISUAL_AUTHORITY_STALE",
            )

    def test_scope_contract_excludes_unmatched_direct_dependency_semantics(self):
        pack = build_task_pack(sample_registry(), intake(), "repo-sha", ())

        self.assertEqual(pack.constitutional_laws, ("MISSION-001",))
        self.assertEqual(pack.specifications, ("SURFACE-TODAY",))
        self.assertEqual(pack.object_lifecycles, ())
        self.assertEqual(pack.journeys, ())
        self.assertEqual(pack.standards, ())
        self.assertNotIn("SURFACE-TIME", pack.to_markdown())
        self.assertNotIn("SYSTEM-RUNTIME", pack.to_markdown())
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

    def test_inherited_constitutional_laws_embed_complete_bodies(self):
        pack = build_task_pack(sample_registry(), intake(), "repo-sha", ())

        self.assertIn("Required law for MISSION-001.", pack.to_markdown())
        self.assertNotIn(
            "Complete inherited-law bodies are bound by the Canon SHA and referenced",
            pack.to_markdown(),
        )

    def test_future_gated_commands_are_non_authorizing_task_pack_metadata(self):
        registry = sample_registry()
        today = next(
            item for item in registry.documents if item.spec_id == "SURFACE-TODAY"
        )
        gated_requirement = replace(
            today.requirements[0],
            body=(
                "The implementation control is `Purchase`. Purchase is authorized only "
                "after the separately registered and owner-approved product gate passes."
            ),
        )
        future_command = StateCommand(
            command_id="CMD-TODAY-PURCHASE-001",
            label="Purchase",
            canonical_owner=gated_requirement.concept,
            destination_id="DEST-TODAY-PURCHASE-001",
            destination_posture=StateCommandResolutionPosture.CURRENT,
            success_focus_id="FOCUS-TODAY-PURCHASE-001-SUCCESS",
            success_focus_posture=StateCommandResolutionPosture.CURRENT,
            failure_focus_id="FOCUS-TODAY-PURCHASE-001-FAILURE",
            failure_focus_posture=StateCommandResolutionPosture.CURRENT,
            recovery_id="RECOVERY-TODAY-PURCHASE-001",
            recovery_posture=StateCommandResolutionPosture.CURRENT,
            recovery_owner=gated_requirement.concept,
            preconditions=(
                "A separately registered and owner-approved StoreKit product registry exists",
            ),
            destination="the Apple-owned purchase sheet for the registered product",
            effect=(
                "The Purchase external result causes no local canonical mutation; "
                "verified entitlement observation remains separate"
            ),
            success_focus="the verified entitlement status",
            failure_focus="the Purchase control and exact product-registry reason",
            commit_boundary=(
                "External-result: StoreKit result is revalidated before any separately "
                "authorized local command."
            ),
            rollback_undo=(
                "No Undo is required; cancellation preserves the prior verified state."
            ),
            privacy_egress="Only minimum registered product fields reach StoreKit.",
            verification_ids=("SCENARIO-TODAY-001",),
            activation_posture=StateCommandActivationPosture.FUTURE_GATED,
            gate_requirement_ids=("TODAY-002",),
            rollback_posture=None,
        )
        contract = StateCommandContract(
            state_id="UX-STATE-VARIANT-TODAY-PURCHASE",
            requirement_id=gated_requirement.requirement_id,
            activation_posture=StateCommandActivationPosture.ACTIVE,
            gate_requirement_ids=(),
            transition_exit=(
                "Purchase => destination: the Apple-owned purchase sheet for the registered "
                "product; effect: The Purchase external result causes no local canonical "
                "mutation; verified entitlement observation remains separate; focus: the "
                "verified entitlement status."
            ),
            durable_effect="No product or entitlement mutation occurs from this state.",
            recovery_rollback="Cancellation returns to the unchanged entitlement status.",
            offline_behavior="The future purchase command remains unavailable offline.",
            accessibility_focus="VoiceOver remains on the exact unavailable control reason.",
            commands=(future_command,),
        )
        future_today = replace(
            today,
            requirements=(gated_requirement, today.requirements[1]),
            state_command_contracts=(contract,),
        )
        active = replace(
            registry,
            manifest=replace(registry.manifest, authority_state=AuthorityState.ACTIVE),
            documents=tuple(
                future_today if item.spec_id == today.spec_id else item
                for item in registry.documents
            ),
        )

        with self.assertRaisesRegex(
            CanonError,
            "command resolution requires the manifest repository root",
        ):
            build_task_pack(
                active,
                replace(intake("docs"), scope=("surface.today",)),
                "repo-sha",
                (),
            )

    def test_live_mixed_labels_preserve_active_authorization_by_command_identity(self):
        manifest = load_manifest(ROOT)
        current = build_registry(manifest, load_documents(ROOT, manifest))
        active = replace(
            current,
            manifest=replace(current.manifest, authority_state=AuthorityState.ACTIVE),
        )
        cases = (
            (
                "account.command-contract",
                "APP-ACCOUNT-COMMAND-CONTRACT-001",
                "Done",
                5,
                (
                    "UX-STATE-VARIANT-ACCOUNT-BOUNDARY-CONTINUITY-CONFLICTED",
                ),
            ),
            (
                "system.continuity.command-contract",
                "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001",
                "Review Continuity Status",
                1,
                (
                    "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-BLOCKED",
                    "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-INELIGIBLE",
                    "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-SIGNED-OUT",
                ),
            ),
        )
        requirements = {
            item.requirement_id: item for item in current.requirements
        }
        for scope, requirement_id, label, active_count, future_state_ids in cases:
            current_intake = TaskIntake.from_json(
                {
                    "schema_version": 1,
                    "issue_id": "VISUAL-R1-COMMAND-AUTHORIZATION",
                    "task_type": "release",
                    "scope": [scope],
                    "changed_files": ["docs/canon/specifications"],
                    "claim_type": "governance",
                    "known_issue_ids": [],
                }
            )
            pack = build_task_pack(active, current_intake, "repo-sha", ())
            records = tuple(
                record
                for record in pack.command_authorizations
                if record["requirement_id"] == requirement_id
                and record["label"] == label
            )
            with self.subTest(scope=scope):
                self.assertEqual(
                    sum(
                        record["activation_posture"] == "active"
                        and record["activation_authorized"] is True
                        for record in records
                    ),
                    active_count,
                )
                self.assertEqual(
                    sum(
                        record["activation_posture"] == "future_gated"
                        and record["activation_authorized"] is False
                        for record in records
                    ),
                    len(future_state_ids),
                )
                self.assertEqual(
                    {
                        record["state_id"]
                        for record in records
                        if record["activation_posture"] == "future_gated"
                    },
                    set(future_state_ids),
                )
                self.assertEqual(len(records), active_count + len(future_state_ids))
                self.assertTrue(
                    all(
                        set(record)
                        == {
                            "activation_authorized",
                            "activation_posture",
                            "command_id",
                            "gate_dependencies",
                            "gate_requirement_ids",
                            "label",
                            "machine_contract",
                            "requirement_id",
                            "state_id",
                        }
                        for record in records
                    )
                )
                exact_body = "\n".join(
                    f"  > {line}"
                    for line in requirements[requirement_id].body.strip().splitlines()
                )
                self.assertIn(exact_body, pack.to_markdown())

            shadow_pack = build_task_pack(
                replace(
                    current,
                    manifest=replace(
                        current.manifest,
                        authority_state=AuthorityState.SHADOW,
                    ),
                ),
                current_intake,
                "repo-sha",
                (),
            )
            shadow_records = tuple(
                record
                for record in shadow_pack.command_authorizations
                if record["requirement_id"] == requirement_id
                and record["label"] == label
            )
            self.assertTrue(shadow_records)
            self.assertTrue(
                all(
                    record["activation_authorized"] is False
                    for record in shadow_records
                )
            )

    def test_profile_section_bodies_are_rendered_for_selected_semantic_documents(self):
        registry = sample_registry()
        lines = tuple(
            value
            for section in STANDARD_PROFILE_SECTIONS
            for value in (
                f"<!-- canon-section: {section} -->",
                {
                    "purpose": "Own the exact local mutation boundary.",
                    "verification": "Execute the runtime scenario matrix.",
                    "proof": "Retain exact-commit runtime receipts.",
                }.get(section, f"Body for {section}."),
            )
        )
        profiled = tuple(
            replace(
                item,
                profile="standard-v1",
                sections=frozenset(STANDARD_PROFILE_SECTIONS),
                source_bytes=standard_profile_source(lines),
            )
            if item.spec_id == "STANDARD-NATIVE"
            else item
            for item in registry.documents
        )
        pack = build_task_pack(
            replace(registry, documents=profiled),
            replace(intake(), scope=("STANDARD-NATIVE", "surface.today")),
            "repo-sha",
            (),
        )

        markdown = pack.to_markdown()
        self.assertIn("Own the exact local mutation boundary.", markdown)
        self.assertIn("Execute the runtime scenario matrix.", markdown)
        self.assertIn("Retain exact-commit runtime receipts.", markdown)

    def test_changed_file_boundary_is_distinct_from_coupled_canonical_owners(self):
        pack = build_task_pack(sample_registry(), intake(), "repo-sha", ())

        markdown = pack.to_markdown()
        self.assertIn("Declared changed-file boundary", markdown)
        self.assertIn("Native/Ambitions/Surfaces/Today", markdown)
        self.assertIn("Coupled canonical owners", markdown)

    def test_validation_and_proof_are_exact_for_selected_claim_contract(self):
        pack = build_task_pack(sample_registry(), intake(), "repo-sha", ())

        self.assertIn(
            "Execute selected verification contracts: SCENARIO-MISSION-001, "
            "SCENARIO-TODAY-001, SCENARIO-TODAY-002.",
            pack.required_validation,
        )
        self.assertIn(
            "Claim-specific proof for claim_type=source must cover changed-file "
            "boundary Native/Ambitions/Surfaces/Today and applicable requirements "
            "SURFACE-TODAY, TODAY-001, TODAY-002.",
            pack.required_proof,
        )

    def test_direct_scoped_dependencies_are_kind_neutral_and_missing_owner_fails(self):
        base = sample_registry()
        root = next(item for item in base.documents if item.spec_id == "SURFACE-TODAY")
        dependencies = tuple(
            document(
                f"DEPENDENCY-{kind.value.upper()}",
                kind=kind,
                concepts=(f"dependency.{kind.value}",),
                requirements=(
                    requirement(
                        f"DEPENDENCY-{kind.value.upper()}-001",
                        "surface.today.coupled-contract",
                    ),
                ),
            )
            for kind in (
                DocumentKind.OBJECT,
                DocumentKind.APP,
                DocumentKind.SURFACE,
                DocumentKind.GLOBAL,
            )
        )
        rooted = replace(root, depends_on=tuple(item.spec_id for item in dependencies))
        closure = (rooted, *dependencies)

        graph = task_pack_module._requirement_inclusion_graph(
            (rooted,), closure, ("surface.today",)
        )

        self.assertEqual(
            set(graph),
            {rooted.spec_id, *(item.spec_id for item in dependencies)},
        )
        for dependency in dependencies:
            self.assertEqual(
                graph[dependency.spec_id],
                (dependency.requirements[0].requirement_id,),
            )
        with self.assertRaises(CanonError) as raised:
            task_pack_module._requirement_inclusion_graph(
                (rooted,), closure[:-1], ("surface.today",)
            )
        self.assertEqual(raised.exception.code, "PACK_DEPENDENCY_OWNER_MISSING")

        unrelated = document(
            "DEPENDENCY-UNRELATED",
            kind=DocumentKind.APP,
            concepts=("dependency.unrelated",),
            requirements=(requirement("DEPENDENCY-UNRELATED-001", "app.unrelated"),),
        )
        unrelated_root = replace(rooted, depends_on=(unrelated.spec_id,))
        self.assertNotIn(
            unrelated.spec_id,
            task_pack_module._requirement_inclusion_graph(
                (unrelated_root,), (unrelated_root, unrelated), ("surface.today",)
            ),
        )
        with self.assertRaises(CanonError) as unrelated_error:
            task_pack_module._requirement_inclusion_graph(
                (unrelated_root,), (unrelated_root,), ("surface.today",)
            )
        self.assertEqual(
            unrelated_error.exception.code, "PACK_DEPENDENCY_OWNER_MISSING"
        )

    def test_object_root_uses_same_scoped_direct_dependency_contract(self):
        parent = document(
            "OBJECT-PARENT",
            kind=DocumentKind.OBJECT,
            concepts=("object.parent",),
            requirements=(requirement("OBJECT-PARENT-001", "object.parent"),),
            depends_on=("APP-COUPLED",),
        )
        dependency = document(
            "APP-COUPLED",
            kind=DocumentKind.APP,
            concepts=("app.coupled",),
            requirements=(
                requirement("APP-COUPLED-001", "object.parent.coupled-contract"),
            ),
        )

        graph = task_pack_module._requirement_inclusion_graph(
            (parent,), (parent, dependency), ("object.parent",)
        )

        self.assertIn("APP-COUPLED", graph)

    def test_explicit_spec_scope_selects_the_complete_contract(self):
        contract = document(
            "STANDARD-COMPLETE",
            kind=DocumentKind.STANDARD,
            concepts=("standard.complete",),
            requirements=(
                requirement("STANDARD-COMPLETE-001", "standard.complete.first"),
                requirement("STANDARD-COMPLETE-002", "standard.complete.second"),
            ),
        )

        graph = task_pack_module._requirement_inclusion_graph(
            (contract,), (contract,), ("STANDARD-COMPLETE",)
        )

        self.assertEqual(
            graph[contract.spec_id],
            ("STANDARD-COMPLETE-001", "STANDARD-COMPLETE-002"),
        )

    def test_profile_marker_parser_ignores_fenced_markers_and_rejects_open_sets(self):
        standard = next(
            item for item in sample_registry().documents if item.spec_id == "STANDARD-NATIVE"
        )
        lines: list[str] = []
        for section in STANDARD_PROFILE_SECTIONS:
            lines.append(f"<!-- canon-section: {section} -->")
            if section == "purpose":
                lines.extend(
                    (
                        "Purpose before fence.",
                        "```markdown",
                        "<!-- canon-section: proof -->",
                        "not a real marker",
                        "```",
                        "Purpose after fence.",
                    )
                )
            else:
                lines.append(f"Body for {section}.")
        profiled = replace(
            standard,
            profile="standard-v1",
            sections=frozenset(STANDARD_PROFILE_SECTIONS),
            source_bytes=standard_profile_source(tuple(lines)),
        )

        bodies = task_pack_module.profile_section_bodies(profiled)

        self.assertEqual(tuple(section for section, _ in bodies), STANDARD_PROFILE_SECTIONS)
        self.assertIn("<!-- canon-section: proof -->", bodies[0][1])
        self.assertIn("Purpose after fence.", bodies[0][1])

        duplicate_lines = (*lines, "<!-- canon-section: proof -->", "Duplicate proof.")
        duplicate = replace(profiled, source_bytes=standard_profile_source(duplicate_lines))
        with self.assertRaises(CanonError) as duplicate_error:
            task_pack_module.profile_section_bodies(duplicate)
        self.assertEqual(duplicate_error.exception.code, "PACK_PROFILE_CONTRACT_INVALID")

        extra_lines = (*lines, "<!-- canon-section: unapproved -->", "Extra body.")
        extra = replace(profiled, source_bytes=standard_profile_source(extra_lines))
        with self.assertRaises(CanonError) as extra_error:
            task_pack_module.profile_section_bodies(extra)
        self.assertEqual(extra_error.exception.code, "PACK_PROFILE_CONTRACT_INVALID")

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
            "applicable_requirement_ids",
            "specifications",
            "object_lifecycles",
            "journeys",
            "standards",
            "source_owners",
            "implementation_posture",
            "known_risks",
            "command_authorizations",
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

    def test_pack_consumes_current_traceability_and_visual_authority(self):
        current = sample_registry()
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            source = root / "Native/Ambitions/Surfaces/Today/TodayView.swift"
            source.parent.mkdir(parents=True)
            source.write_text("struct TodayView {}\n", encoding="utf-8")
            test_path = root / "tests/TodayTests.swift"
            test_path.parent.mkdir(parents=True)
            test_path.write_text("final class TodayTests {}\n", encoding="utf-8")
            proof_path = root / "docs/proof/today.json"
            proof_path.parent.mkdir(parents=True)
            proof_path.write_text("{}\n", encoding="utf-8")
            test_revision = hashlib.sha256(test_path.read_bytes()).hexdigest()
            proof_revision = hashlib.sha256(proof_path.read_bytes()).hexdigest()
            references = (
                AuthorityReference(
                    schema_version=1,
                    reference_id="TEST-TODAY-001",
                    authority_class=AuthorityClass.SOURCE_AND_TESTS,
                    reference_kind=AuthorityReferenceKind.TEST,
                    source="tests/TodayTests.swift",
                    revision=test_revision,
                    requirement_ids=("TODAY-001",),
                    approval_state="approved",
                    approved_by="Fixture test owner",
                    implementation_status="focused test reference; execution not claimed",
                ),
                AuthorityReference(
                    schema_version=1,
                    reference_id="PROOF-TODAY-001",
                    authority_class=AuthorityClass.SOURCE_AND_TESTS,
                    reference_kind=AuthorityReferenceKind.PROOF,
                    source="docs/proof/today.json",
                    revision=proof_revision,
                    requirement_ids=("TODAY-001",),
                    approval_state="approved",
                    approved_by="Fixture owner",
                    implementation_status="fixture evidence with a Yellow ceiling",
                ),
                AuthorityReference(
                    schema_version=1,
                    reference_id="FIGMA:fixture:160:93",
                    authority_class=AuthorityClass.FIGMA,
                    reference_kind=AuthorityReferenceKind.FIGMA,
                    source="figma:fixture:160:93",
                    revision="160:93",
                    requirement_ids=("TODAY-001",),
                    approval_state="approved",
                    approved_by="Fixture owner",
                    implementation_status="approved target; not implementation proof",
                    authority_role=FigmaAuthorityRole.APPROVED_TARGET,
                    visual_authority_id="VSP-02",
                    canon_revision=7,
                    frame_version="R1",
                    swiftui_plausibility="plausible_unverified",
                    accessibility_variants=("Dynamic Type", "VoiceOver"),
                    reconciliation_status="applied_verified",
                ),
            )
            traceability = build_traceability(current, root, references)

            pack = build_task_pack(
                current,
                intake(),
                "repo-sha",
                (),
                traceability=traceability,
            )

        posture = json.loads(pack.implementation_posture)
        self.assertIn("source_files_present", posture["source_status_counts"])
        self.assertNotIn("TEST-TODAY-001", pack.required_tests)
        self.assertIn("SCENARIO-TODAY-001", pack.required_tests)
        self.assertEqual(
            posture["current_test_references"],
            [
                {
                    "approval_state": "approved",
                    "approved_by": "Fixture test owner",
                    "implementation_status": "focused test reference; execution not claimed",
                    "reference_id": "TEST-TODAY-001",
                    "revision": test_revision,
                    "source": "tests/TodayTests.swift",
                }
            ],
        )
        proof_line = next(
            item for item in pack.required_proof if "PROOF-TODAY-001" in item
        )
        for exact_value in (
            "reference_id=PROOF-TODAY-001",
            "source=docs/proof/today.json",
            f"revision={proof_revision}",
            "approval=approved",
            "approved_by=Fixture owner",
            "posture=fixture evidence with a Yellow ceiling",
        ):
            self.assertIn(exact_value, proof_line)
        markdown = pack.to_markdown()
        self.assertIn("approved_by=Fixture test owner", markdown)
        self.assertIn("approved_by=Fixture owner", markdown)
        self.assertTrue(any("VSP-02" in item for item in pack.visual_authority))
        self.assertTrue(any("FIGMA:fixture:160:93" in item for item in pack.visual_authority))
        self.assertNotIn("No task-scoped visual authority", pack.to_markdown())

    def test_swiftui_pack_without_applicable_visual_authority_carries_stop(self):
        current = sample_registry()
        with tempfile.TemporaryDirectory() as temporary_directory:
            traceability = build_traceability(
                current,
                Path(temporary_directory),
                (),
            )
            pack = build_task_pack(
                current,
                intake(),
                "repo-sha",
                (),
                traceability=traceability,
            )

        self.assertTrue(any("UI-readiness stop" in item for item in pack.visual_authority))
        self.assertTrue(any("visual authority" in item for item in pack.known_risks))
        self.assertIn("visual-authority gap", pack.claim_ceiling)

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
                "release": "complex",
                "swiftui": "complex",
                "runtime": "complex",
                "privacy": "complex",
                "constitutional-audit": "constitutional-audit",
            },
        )
        for task_type, budget_class in (
            ("mechanical", "mechanical"),
            ("docs", "normal"),
            ("release", "complex"),
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

    def test_task_pack_schema_closes_exact_task_type_budget_mapping(self):
        schema = json.loads(
            (ROOT / "docs/canon/schemas/task-pack.schema.json").read_text(
                encoding="utf-8"
            )
        )
        self.assertEqual(
            schema["properties"]["task_type"]["enum"],
            [
                "mechanical",
                "docs",
                "release",
                "swiftui",
                "runtime",
                "privacy",
                "constitutional-audit",
            ],
        )
        self.assertNotIn("governance", schema["properties"]["task_type"]["enum"])
        conditionals = schema["allOf"]
        self.assertEqual(len(conditionals), 4)
        mapped = {}
        for conditional in conditionals:
            selector = conditional["if"]["properties"]["task_type"]
            task_types = selector.get("enum", [selector.get("const")])
            outcome = conditional["then"]["properties"]
            for task_type in task_types:
                mapped[task_type] = (
                    outcome["budget_class"]["const"],
                    outcome["token_budget"]["const"],
                )
        self.assertEqual(
            mapped,
            {
                task_type: (budget_class, PACK_BUDGETS[budget_class])
                for task_type, budget_class in TASK_TYPE_BUDGET_CLASS.items()
            },
        )

    def test_task_pack_parser_rejects_governance_and_budget_mutations(self):
        pack = build_task_pack(sample_registry(), intake("release"), "repo-sha", ())
        current = {
            "canon_sha": pack.canon_sha,
            "repository_sha": pack.repository_sha,
            "intake_sha": pack.intake_sha,
        }
        cases = (
            ({**pack.to_dict(), "task_type": "governance"}, "PACK_TASK_TYPE_UNKNOWN"),
            ({**pack.to_dict(), "budget_class": "normal"}, "PACK_BUDGET_CONTRACT"),
            ({**pack.to_dict(), "token_budget": 16_000}, "PACK_BUDGET_CONTRACT"),
        )
        for candidate, code in cases:
            with self.subTest(code=code):
                with self.assertRaises(CanonError) as raised:
                    validate_task_pack(candidate, **current)
                self.assertEqual(raised.exception.code, code)

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

    def test_cli_pack_generate_fails_closed_when_supersession_entry_is_deleted(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            intake_path = initialize_live_conflict_cli_root(
                root,
                scope="surface.today",
            )
            remove_first_supersession_entry(root)
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
                scope="surface.today",
            )
            self.assertEqual(_pack(root, intake_path, check=False), 0)
            remove_first_supersession_entry(root)
            output = io.StringIO()
            with redirect_stdout(output):
                self.assertEqual(_pack(root, intake_path, check=True), 1)
            self.assertIn("CONFLICT_DOCKET_REMOVAL_BLOCKED", output.getvalue())

    def test_cli_pack_resume_revalidates_dockets_after_pinned_pack_read(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            intake_path = initialize_live_conflict_cli_root(
                root,
                scope="surface.today",
            )
            self.assertEqual(_pack(root, intake_path, check=False), 0)
            original_require = canon_cli._require_source_snapshot
            mutated = False

            def delete_supersession_before_resume(*arguments):
                nonlocal mutated
                if not mutated:
                    mutated = True
                    remove_first_supersession_entry(root)
                return original_require(*arguments)

            output = io.StringIO()
            with mock.patch.object(
                canon_cli,
                "_require_source_snapshot",
                side_effect=delete_supersession_before_resume,
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
                    requirement_blocks=(
                        requirement_block("A-001", "system.a"),
                    ),
                ),
                encoding="utf-8",
            )
            (canon / "b.md").write_text(
                markdown_document(
                    "SPEC-B",
                    "system.b",
                    depends_on=("SPEC-A",),
                    requirement_blocks=(
                        requirement_block("B-001", "system.b"),
                    ),
                ),
                encoding="utf-8",
            )
            write_required_governance_artifacts(
                canon,
                canon_revision=1,
                requirement_ids=("A-001", "B-001"),
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
