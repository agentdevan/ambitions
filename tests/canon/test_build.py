import errno
import hashlib
import json
import os
import re
import shutil
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from io import StringIO
from pathlib import Path
from unittest import mock

from tools.ambitions_canon.build import (
    build_canon,
    canon_content_sha,
    check_outputs,
    write_outputs_atomic,
)
from tools.ambitions_canon.cli import main
from tools.ambitions_canon.identifiers import CANONICAL_ID_GRAMMAR
from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.model import CanonError, CanonRegistry
from tools.ambitions_canon.registry import build_registry
from tools.ambitions_canon.render import _unresolved_conflicts, render_outputs
from tests.canon.canon_test_support import write_required_governance_artifacts


ROOT = Path(__file__).resolve().parents[2]
GENERATED_FILES = (
    "CODEX_START_HERE.md",
    "INDEX.md",
    "canon-index.json",
    "concept-ownership.json",
    "requirement-graph.json",
    "specification-coverage.md",
    "unresolved-conflicts.md",
    "law-source-map.json",
    "law-test-map.json",
    "law-proof-map.json",
    "visual-authority-manifest.json",
    "external-reference-impact.md",
    "supersession-manifest.json",
    "object-boundary-matrix.md",
)


def manifest_text(
    normative_files: tuple[str, ...] = (),
    *,
    canon_revision: int = 0,
) -> str:
    normative = ", ".join(f'"{path}"' for path in normative_files)
    generated = ",\n".join(
        f'  "generated/{path}"' for path in GENERATED_FILES
    )
    return (
        "schema_version = 1\n"
        f"canon_revision = {canon_revision}\n"
        'authority_state = "shadow"\n'
        'compiler_version = "0.1.0"\n'
        f"normative_files = [{normative}]\n\n"
        "generated_files = [\n"
        f"{generated},\n"
        "]\n"
    )


def document_text(
    spec_id: str,
    concept: str,
    requirement_id: str,
    *,
    title: str | None = None,
    verification: str = "none",
    profile: str | None = None,
) -> str:
    title = title or spec_id
    profile_line = f'profile = "{profile}"\n' if profile is not None else ""
    return (
        "+++\n"
        f'spec_id = "{spec_id}"\n'
        f'title = "{title}"\n'
        'kind = "surface"\n'
        'status = "normative"\n'
        'owner_domain = "product"\n'
        "canon_revision = 0\n"
        f"{profile_line}"
        f'owns_concepts = ["{concept}"]\n'
        "inherits = []\n"
        "depends_on = []\n"
        "source_owners = []\n"
        "+++\n\n"
        f"## {requirement_id} — Deterministic law\n\n"
        f"- **Concept:** `{concept}`\n"
        "- **Modality:** `MUST`\n"
        "- **Scope:** Test scope\n"
        "- **Status:** `normative`\n"
        f"- **Verification:** {verification}\n"
        "- **Supersedes:** none\n\n"
        "Deterministic body.\n"
    )


class BuildTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary_directory.cleanup)
        self.root = Path(self.temporary_directory.name)
        self.canon_root = self.root / "docs" / "canon"
        self.generated_root = self.canon_root / "generated"
        self.canon_root.mkdir(parents=True)

    def test_conflict_renderer_distinguishes_absent_model_from_resolved_empty_model(self):
        metadata = {
            "authority_state": "shadow",
            "canon_content_sha": "a" * 64,
            "canon_revision": 7,
            "compiler_version": "0.1.0",
            "schema_version": 1,
        }

        unrepresented = _unresolved_conflicts(metadata, (), None).decode("utf-8")
        represented = _unresolved_conflicts(metadata, (), ()).decode("utf-8")

        self.assertIn("**Representation status:** Unrepresented", unrepresented)
        self.assertNotIn("**Representation status:** Unrepresented", represented)
        self.assertIn("- Open dockets: `0`", represented)

    def test_build_canon_preserves_absent_conflict_model_as_unrepresented(self):
        self.write_canon()

        self.assertEqual(build_canon(self.root), ())

        rendered = self.generated_root.joinpath("unresolved-conflicts.md").read_text(
            encoding="utf-8"
        )
        self.assertIn("**Representation status:** Unrepresented", rendered)
        self.assertNotIn("- Open dockets: `0`", rendered)

    def test_build_canon_renders_validated_empty_conflict_model_as_resolved(self):
        self.assertEqual(build_canon(ROOT, check=True), ())

        rendered = ROOT.joinpath(
            "docs/canon/generated/unresolved-conflicts.md"
        ).read_text(encoding="utf-8")
        self.assertNotIn("**Representation status:** Unrepresented", rendered)
        self.assertIn("- Open dockets: `0`", rendered)

    def test_build_canon_binds_linear_reconciliation_into_external_impact(self):
        self.assertEqual(build_canon(ROOT, check=True), ())

        rendered = ROOT.joinpath(
            "docs/canon/generated/external-reference-impact.md"
        ).read_text(encoding="utf-8")
        self.assertIn("- Reconciliation entities: `285`", rendered)
        self.assertIn(
            "- Reconciliation disposition: `initiative_applied_verified_broader_withheld`",
            rendered,
        )
        self.assertIn("- External mutations applied: `true`", rendered)
        self.assertIn("- Owner gate required: `true`", rendered)
        self.assertIn("- Reconciliation status `applied_verified`: `1`", rendered)
        self.assertIn("- Reconciliation status `proposed_not_applied`: `284`", rendered)
        self.assertRegex(rendered, r"- Linear reconciliation SHA: `[0-9a-f]{64}`")

    def test_live_linear_reconciliation_records_exact_initiative_only_receipt(self):
        data = json.loads(
            ROOT.joinpath(
                "docs/canon/migration/linear-reconciliation.json"
            ).read_text(encoding="utf-8")
        )
        self.assertEqual(
            data["disposition_state"],
            "initiative_applied_verified_broader_withheld",
        )
        self.assertIs(data["external_mutations_applied"], True)
        applied = [
            entity
            for entity in data["entities"]
            if entity["action_status"] == "applied_verified"
        ]
        self.assertEqual(
            [entity["entity_id"] for entity in applied],
            ["1df52f0d-da30-4bcc-8f21-5761596cac19"],
        )
        self.assertEqual(applied[0]["entity_type"], "initiative")
        project = next(
            entity
            for entity in data["entities"]
            if entity["entity_id"] == "0affb0e0-87cf-4417-b0c2-fbf7490c9975"
        )
        self.assertEqual(project["action_status"], "proposed_not_applied")
        receipt = data["initiative_execution"]
        self.assertEqual(
            receipt,
            {
                "approved_option": "initiative-only",
                "approval_authority": "controller_on_owner_behalf_under_tasks_22_29_delegation",
                "approval_review": "INITIATIVE_GATE_CLEAN",
                "broader_actions": "withheld_not_authorized",
                "destructive_actions": "withheld_gate_c",
                "entity_id": "1df52f0d-da30-4bcc-8f21-5761596cac19",
                "status": "applied_verified",
                "validation": "dedicated_full_read_exact",
                "before_bytes": 428,
                "before_raw_sha256": "234f459c9fb0f0f0f58aae2382753a9bbc6ebc672f87b64f89bda303f9884a90",
                "before_canonical_sha256": "d76d80d58de54c1f2224c6b41903498873f0b448dbb1ae347b24b366e624cd09",
                "before_updated_at": "2026-07-13T18:09:43.544Z",
                "after_bytes": 2431,
                "after_raw_sha256": "4e1a19a1919e7aa4957dddd45f6e25654bd04791cf221542af5f8877f7e2a133",
                "after_canonical_sha256": "3a7b802cc30a75075621785e00d61da18c587eba5a98dcc4aaf1900754279a46",
                "after_updated_at": "2026-07-13T18:27:59.441Z",
                "after_terminal_lf": False,
            },
        )
        self.assertEqual(receipt["entity_id"], applied[0]["entity_id"])
        self.assertEqual(receipt["status"], applied[0]["action_status"])
        self.assertEqual(
            receipt["after_canonical_sha256"], applied[0]["content_sha256"]
        )
        self.assertEqual(
            receipt["after_updated_at"], applied[0]["live_metadata"]["updated_at"]
        )
        batches = {batch["batch_id"]: batch for batch in data["batches"]}
        self.assertEqual(
            batches["pilot-owner-gate"]["status"], "withheld_not_authorized"
        )
        self.assertEqual(
            batches["initiative-only-owner-gate"]["status"], "applied_verified"
        )
        for batch_id, batch in batches.items():
            if batch_id in {"pilot-owner-gate", "initiative-only-owner-gate"}:
                continue
            self.assertEqual(
                batch["status"],
                "withheld_gate_c"
                if batch["action"] in {"delete_after_extraction", "archive_after_extraction"}
                else "withheld_not_authorized",
            )

    def write_canon(self, documents: dict[str, str] | None = None) -> None:
        documents = documents or {}
        (self.canon_root / "MANIFEST.toml").write_text(
            manifest_text(tuple(sorted(documents))),
            encoding="utf-8",
        )
        for relative_path, text in documents.items():
            destination = self.canon_root / relative_path
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_text(text, encoding="utf-8")
        requirement_ids = tuple(
            match.group(1)
            for text in documents.values()
            for match in re.finditer(
                rf"^## ({CANONICAL_ID_GRAMMAR}) —",
                text,
                re.MULTILINE,
            )
        )
        write_required_governance_artifacts(
            self.canon_root,
            canon_revision=0,
            requirement_ids=requirement_ids,
        )

    def registry(self) -> CanonRegistry:
        manifest = load_manifest(self.root)
        return build_registry(manifest, load_documents(self.root, manifest))

    def clear_local_proof_references(self, canon_root: Path) -> None:
        canon_root.joinpath("references/proof-sources.toml").write_text(
            'schema_version = 1\nkind = "proof"\nreferences = []\n',
            encoding="utf-8",
        )

    def render_in_repository(self, registry: CanonRegistry):
        previous = Path.cwd()
        try:
            os.chdir(self.root)
            return render_outputs(registry)
        finally:
            os.chdir(previous)

    def test_content_sha_is_byte_based_and_source_order_independent(self):
        self.write_canon(
            {
                "specifications/a.md": "alpha\n",
                "specifications/b.md": "beta\n",
            }
        )
        manifest = self.canon_root / "MANIFEST.toml"
        a = self.canon_root / "specifications" / "a.md"
        b = self.canon_root / "specifications" / "b.md"

        forward = canon_content_sha(manifest, (a, b))
        reverse = canon_content_sha(manifest, (b, a))

        self.assertEqual(forward, reverse)
        self.assertRegex(forward, r"^[0-9a-f]{64}$")
        b.write_text("changed\n", encoding="utf-8")
        self.assertNotEqual(forward, canon_content_sha(manifest, (a, b)))

    def test_same_input_produces_byte_identical_output(self):
        self.write_canon()
        registry = self.registry()

        first = self.render_in_repository(registry)
        second = self.render_in_repository(registry)

        self.assertEqual(first, second)
        self.assertEqual(
            tuple(first),
            tuple(sorted((Path(path) for path in GENERATED_FILES), key=lambda path: path.as_posix())),
        )

    def test_shadow_goldens_match_the_live_manifest_render(self):
        repository_root = Path(__file__).resolve().parents[2]
        manifest = load_manifest(repository_root)
        registry = build_registry(
            manifest,
            load_documents(repository_root, manifest),
        )
        previous = Path.cwd()
        try:
            os.chdir(repository_root)
            outputs = render_outputs(registry)
        finally:
            os.chdir(previous)
        golden_root = Path(__file__).parent / "golden" / "shadow"

        self.assertEqual(
            outputs,
            {path: (golden_root / path).read_bytes() for path in outputs},
        )

    def test_shadow_workflow_runs_the_offline_dual_audit_matrix(self):
        repository_root = Path(__file__).resolve().parents[2]
        workflow = (
            repository_root
            / ".github"
            / "workflows"
            / "ambitions-canon-shadow-audit.yml"
        ).read_text(encoding="utf-8")

        trigger_contract = workflow.split("permissions:", 1)[0]
        self.assertIn("pull_request:\n", trigger_contract)
        self.assertIn("push:\n", trigger_contract)
        self.assertNotIn("paths:", trigger_contract)
        self.assertNotIn("paths-ignore:", trigger_contract)
        self.assertNotIn("branches:", trigger_contract)
        self.assertIn("actions/setup-python@v5", workflow)
        self.assertIn('python-version: "3.12"', workflow)
        for command in (
            "python3 scripts/ambitions-authority-freeze-check.py",
            "python3 -m unittest discover -s tests/canon -p 'test_*.py' -v",
            "python3 -m unittest scripts/tests/test_ambitions_authority_freeze_check.py -v",
            "python3 -m compileall -q tools/ambitions_canon scripts/ambitions-canon.py",
            "python3 scripts/ambitions-canon.py audit",
            "python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap",
            "python3 scripts/ambitions-canon.py build --check",
            "python3 scripts/ambitions-constitution-audit.py",
            "git diff --check",
        ):
            self.assertIn(command, workflow)

        self.assertLess(
            workflow.index("python3 scripts/ambitions-canon.py audit"),
            workflow.index(
                "python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap"
            ),
        )
        self.assertLess(
            workflow.index(
                "python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap"
            ),
            workflow.index("python3 scripts/ambitions-canon.py build --check"),
        )

    def test_shadow_workflow_runs_for_external_authority_only_changes(self):
        workflow = (
            Path(__file__).resolve().parents[2]
            / ".github/workflows/ambitions-canon-shadow-audit.yml"
        ).read_text(encoding="utf-8")
        trigger_contract = workflow.split("permissions:", 1)[0]
        external_authority_only_change = "docs/product/NEW_PRODUCT_TRUTH.md"

        self.assertEqual(external_authority_only_change.split("/", 1)[0], "docs")
        self.assertIn("pull_request:\n", trigger_contract)
        self.assertIn("push:\n", trigger_contract)
        self.assertNotIn("paths:", trigger_contract)
        self.assertNotIn("paths-ignore:", trigger_contract)
        self.assertNotIn("branches:", trigger_contract)

    def test_document_insertion_order_does_not_alter_output(self):
        self.write_canon(
            {
                "specifications/a.md": document_text(
                    "SURFACE-A", "surface.a", "A-001"
                ),
                "specifications/b.md": document_text(
                    "SURFACE-B", "surface.b", "B-001"
                ),
            }
        )
        registry = self.registry()
        reversed_registry = CanonRegistry(
            manifest=registry.manifest,
            documents=tuple(reversed(registry.documents)),
            requirements=tuple(reversed(registry.requirements)),
            concept_owners=tuple(reversed(registry.concept_owners)),
            superseded_ids=registry.superseded_ids,
            supersession_entries=registry.supersession_entries,
            supersession_ledger_complete=registry.supersession_ledger_complete,
            supersession_ledger_bytes=registry.supersession_ledger_bytes,
            reference_index=registry.reference_index,
        )

        expected = self.render_in_repository(registry)
        actual = self.render_in_repository(reversed_registry)

        self.assertEqual(expected, actual)

    def test_outputs_have_no_timestamp_and_every_text_file_ends_in_newline(self):
        self.write_canon()

        outputs = self.render_in_repository(self.registry())

        timestamp = re.compile(
            rb"\b\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}"
        )
        self.assertTrue(outputs)
        for path, content in outputs.items():
            with self.subTest(path=path):
                self.assertTrue(content.endswith(b"\n"))
                self.assertIsNone(timestamp.search(content))
                content.decode("utf-8")

    def test_failed_render_leaves_existing_generated_directory_untouched(self):
        self.write_canon()
        self.generated_root.mkdir()
        sentinel = self.generated_root / "sentinel.txt"
        sentinel.write_bytes(b"original\n")

        with mock.patch(
            "tools.ambitions_canon.build._render_outputs",
            side_effect=CanonError("CANON_RENDER_FAILED", "forced failure"),
        ):
            with self.assertRaises(CanonError) as raised:
                build_canon(self.root)

        self.assertEqual(raised.exception.code, "CANON_RENDER_FAILED")
        self.assertEqual(sentinel.read_bytes(), b"original\n")
        self.assertEqual(tuple(self.generated_root.iterdir()), (sentinel,))

    def test_failed_staging_write_leaves_existing_directory_untouched(self):
        self.generated_root.mkdir()
        sentinel = self.generated_root / "sentinel.txt"
        sentinel.write_bytes(b"original\n")

        with mock.patch(
            "tools.ambitions_canon.build._write_output_file",
            side_effect=OSError("forced write failure"),
        ):
            with self.assertRaises(CanonError) as raised:
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertEqual(raised.exception.code, "CANON_GENERATED_WRITE")
        self.assertEqual(sentinel.read_bytes(), b"original\n")
        self.assertEqual(tuple(self.generated_root.iterdir()), (sentinel,))

    def test_failed_directory_swap_rolls_back_without_partial_mutation(self):
        from tools.ambitions_canon import build as canon_build

        self.generated_root.mkdir()
        sentinel = self.generated_root / "sentinel.txt"
        sentinel.write_bytes(b"original\n")

        def fail_new_directory(source, destination, **kwargs):
            if Path(source).name == "next":
                raise OSError("forced swap failure")
            return canon_build._rename_noreplace(source, destination, **kwargs)

        with mock.patch(
            "tools.ambitions_canon.build._rename_noreplace",
            side_effect=fail_new_directory,
        ):
            with self.assertRaises(CanonError) as raised:
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertEqual(raised.exception.code, "CANON_GENERATED_WRITE")
        self.assertEqual(sentinel.read_bytes(), b"original\n")
        self.assertEqual(tuple(self.generated_root.iterdir()), (sentinel,))

    def test_double_swap_failure_preserves_the_only_prior_tree_for_recovery(self):
        from tools.ambitions_canon import build as canon_build

        self.generated_root.mkdir()
        sentinel = self.generated_root / "sentinel.txt"
        sentinel.write_bytes(b"original\n")
        real_replace = os.replace

        def fail_commit_and_restore(source, destination, *args, **kwargs):
            source_name = Path(source).name
            destination_name = Path(destination).name
            if source_name == "next" and destination_name == "generated":
                raise OSError("forced commit failure")
            if source_name.startswith(".ambitions-canon-previous-"):
                raise OSError("forced restore failure")
            if source_name == "previous" and destination_name == "generated":
                raise OSError("forced restore failure")
            return real_replace(source, destination, *args, **kwargs)

        def fail_commit(source, destination, **kwargs):
            if Path(source).name == "next":
                raise OSError("forced commit failure")
            return canon_build._rename_noreplace(source, destination, **kwargs)

        with mock.patch(
            "tools.ambitions_canon.build._rename_noreplace",
            side_effect=fail_commit,
        ):
            with mock.patch(
                "tools.ambitions_canon.build.os.replace",
                side_effect=fail_commit_and_restore,
            ):
                with self.assertRaises(CanonError) as raised:
                    write_outputs_atomic(
                        self.generated_root,
                        {Path("INDEX.md"): b"replacement\n"},
                    )

        self.assertEqual(
            raised.exception.code,
            "CANON_GENERATED_RECOVERY_REQUIRED",
        )
        self.assertIsNotNone(raised.exception.path)
        recovery_root = Path(raised.exception.path)
        self.assertEqual(
            (recovery_root / "sentinel.txt").read_bytes(),
            b"original\n",
        )

    def test_cleanup_failure_after_commit_does_not_report_transaction_failure(self):
        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")

        diagnostics = StringIO()
        with redirect_stderr(diagnostics):
            with mock.patch(
                "tools.ambitions_canon.build._remove_tree_at",
                side_effect=OSError("forced cleanup failure"),
            ):
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertEqual(
            tuple(path.name for path in self.generated_root.iterdir()),
            ("INDEX.md",),
        )
        self.assertEqual(
            (self.generated_root / "INDEX.md").read_bytes(),
            b"replacement\n",
        )
        self.assertIn(
            "WARNING CANON_GENERATED_CLEANUP_REQUIRED",
            diagnostics.getvalue(),
        )
        self.assertNotIn(".ambitions-canon-build-", diagnostics.getvalue())
        self.assertNotIn(".ambitions-canon-previous-", diagnostics.getvalue())

    def test_cleanup_name_exhaustion_warns_without_reversing_success(self):
        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")

        def occupy_cleanup_name():
            (self.canon_root / ".ambitions-canon-cleanup-fixed").mkdir()

        diagnostics = StringIO()
        with redirect_stderr(diagnostics):
            with mock.patch(
                "tools.ambitions_canon.build.secrets.token_hex",
                return_value="fixed",
            ):
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                    postcondition=occupy_cleanup_name,
                )

        self.assertEqual(
            (self.generated_root / "INDEX.md").read_bytes(),
            b"replacement\n",
        )
        self.assertIn(
            "WARNING CANON_GENERATED_CLEANUP_REQUIRED",
            diagnostics.getvalue(),
        )

    def test_staging_open_failure_is_cleaned_and_reported_stably(self):
        from tools.ambitions_canon import build as canon_build

        real_open_directory = canon_build._open_directory_at

        def fail_staging_open(parent_descriptor, name):
            if name.startswith(".ambitions-canon-build-"):
                raise OSError(errno.EIO, "forced staging open failure")
            return real_open_directory(parent_descriptor, name)

        with mock.patch(
            "tools.ambitions_canon.build._open_directory_at",
            side_effect=fail_staging_open,
        ):
            with self.assertRaises(CanonError) as raised:
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertEqual(raised.exception.code, "CANON_GENERATED_WRITE")
        self.assertFalse(
            tuple(self.canon_root.glob(".ambitions-canon-build-*"))
        )
        self.assertFalse(self.generated_root.exists())

    def test_staging_parent_fsync_failure_cleans_created_directory(self):
        from tools.ambitions_canon import build as canon_build

        real_fsync_directory = canon_build._fsync_directory
        failed = False

        def fail_after_staging_mkdir(descriptor):
            nonlocal failed
            if (
                not failed
                and tuple(self.canon_root.glob(".ambitions-canon-build-*"))
            ):
                failed = True
                raise OSError(errno.EIO, "forced staging parent fsync failure")
            return real_fsync_directory(descriptor)

        with mock.patch(
            "tools.ambitions_canon.build._fsync_directory",
            side_effect=fail_after_staging_mkdir,
        ):
            with self.assertRaises(CanonError) as raised:
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertTrue(failed)
        self.assertEqual(raised.exception.code, "CANON_GENERATED_WRITE")
        self.assertFalse(
            tuple(self.canon_root.glob(".ambitions-canon-build-*"))
        )

    def test_staging_identity_failure_does_not_leak_descriptors(self):
        fd_root = Path("/proc/self/fd")
        if not fd_root.exists():
            fd_root = Path("/dev/fd")
        before = len(tuple(fd_root.iterdir()))

        for _ in range(16):
            with mock.patch(
                "tools.ambitions_canon.build._descriptor_identity",
                side_effect=CanonError(
                    "FORCED_STAGING_IDENTITY",
                    "forced staging identity failure",
                ),
            ):
                with self.assertRaises(CanonError):
                    write_outputs_atomic(
                        self.generated_root,
                        {Path("INDEX.md"): b"replacement\n"},
                    )

        after = len(tuple(fd_root.iterdir()))
        self.assertLessEqual(after, before + 1)

    def test_check_root_identity_failure_does_not_leak_descriptors(self):
        self.generated_root.mkdir()
        (self.generated_root / "INDEX.md").write_bytes(b"expected\n")
        fd_root = Path("/proc/self/fd")
        if not fd_root.exists():
            fd_root = Path("/dev/fd")
        before = len(tuple(fd_root.iterdir()))

        for _ in range(16):
            with mock.patch(
                "tools.ambitions_canon.build._descriptor_identity",
                side_effect=CanonError(
                    "FORCED_ROOT_IDENTITY",
                    "forced root identity failure",
                ),
            ):
                with self.assertRaises(CanonError):
                    check_outputs(
                        self.generated_root,
                        {Path("INDEX.md"): b"expected\n"},
                    )

        after = len(tuple(fd_root.iterdir()))
        self.assertLessEqual(after, before + 1)

    def test_replaced_root_before_hide_never_becomes_successful_prior(self):
        from tools.ambitions_canon import build as canon_build

        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")
        displaced = self.canon_root / "externally-displaced-original"
        real_unique_name = canon_build._unique_unused_name
        replaced = False

        def replace_before_prior_name(parent_descriptor, prefix):
            nonlocal replaced
            if prefix == ".ambitions-canon-previous-" and not replaced:
                self.generated_root.rename(displaced)
                self.generated_root.mkdir()
                (self.generated_root / "intruder.md").write_bytes(b"intruder\n")
                replaced = True
            return real_unique_name(parent_descriptor, prefix)

        with mock.patch(
            "tools.ambitions_canon.build._unique_unused_name",
            side_effect=replace_before_prior_name,
        ):
            with self.assertRaises(CanonError) as raised:
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertTrue(replaced)
        self.assertEqual(
            raised.exception.code,
            "CANON_GENERATED_ENTRY_CHANGED",
        )
        self.assertEqual((displaced / "old.md").read_bytes(), b"old\n")
        self.assertEqual(
            (self.generated_root / "intruder.md").read_bytes(),
            b"intruder\n",
        )
        self.assertFalse((self.generated_root / "INDEX.md").exists())
        self.assertFalse(
            tuple(self.canon_root.glob(".ambitions-canon-quarantine-*"))
        )
        self.assertFalse(
            tuple(self.canon_root.glob(".ambitions-canon-build-*"))
        )

    def test_existing_root_replaced_during_staging_is_not_accepted_as_prior(self):
        from tools.ambitions_canon import build as canon_build

        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")
        displaced = self.canon_root / "externally-displaced-during-staging"
        real_stage_outputs = canon_build._stage_outputs
        replaced = False

        def stage_then_replace(staging_descriptor, outputs):
            nonlocal replaced
            real_stage_outputs(staging_descriptor, outputs)
            self.generated_root.rename(displaced)
            self.generated_root.mkdir()
            (self.generated_root / "intruder.md").write_bytes(b"intruder\n")
            replaced = True

        with mock.patch(
            "tools.ambitions_canon.build._stage_outputs",
            side_effect=stage_then_replace,
        ):
            with self.assertRaises(CanonError) as raised:
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertTrue(replaced)
        self.assertEqual(
            raised.exception.code,
            "CANON_GENERATED_ENTRY_CHANGED",
        )
        self.assertEqual((displaced / "old.md").read_bytes(), b"old\n")
        self.assertEqual(
            (self.generated_root / "intruder.md").read_bytes(),
            b"intruder\n",
        )
        self.assertFalse((self.generated_root / "INDEX.md").exists())
        self.assertFalse(
            tuple(self.canon_root.glob(".ambitions-canon-build-*"))
        )

    def test_first_install_never_overwrites_raced_destination(self):
        from tools.ambitions_canon import build as canon_build

        real_open_directory = canon_build._open_directory_at
        inserted_identity = None

        def insert_destination_before_commit(parent_descriptor, name):
            nonlocal inserted_identity
            descriptor = real_open_directory(parent_descriptor, name)
            if name == "next" and inserted_identity is None:
                self.generated_root.mkdir()
                info = self.generated_root.stat()
                inserted_identity = (info.st_dev, info.st_ino)
            return descriptor

        with mock.patch(
            "tools.ambitions_canon.build._open_directory_at",
            side_effect=insert_destination_before_commit,
        ):
            with self.assertRaises(CanonError) as raised:
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertIsNotNone(inserted_identity)
        self.assertEqual(raised.exception.code, "CANON_GENERATED_WRITE")
        self.assertFalse((self.generated_root / "INDEX.md").exists())
        quarantine_identities = {
            (path.stat().st_dev, path.stat().st_ino)
            for path in self.canon_root.glob(".ambitions-canon-quarantine-*")
        }
        self.assertIn(inserted_identity, quarantine_identities)

    def test_platform_noreplace_rename_rejects_existing_destination(self):
        from tools.ambitions_canon import build as canon_build

        source = self.canon_root / "source"
        destination = self.canon_root / "destination"
        source.mkdir()
        destination.mkdir()
        parent_descriptor = os.open(self.canon_root, os.O_RDONLY | os.O_DIRECTORY)
        try:
            with self.assertRaises(OSError) as raised:
                canon_build._rename_noreplace(
                    "source",
                    "destination",
                    source_directory=parent_descriptor,
                    destination_directory=parent_descriptor,
                )
        finally:
            os.close(parent_descriptor)

        self.assertIn(raised.exception.errno, (errno.EEXIST, errno.ENOTEMPTY))
        self.assertTrue(source.is_dir())
        self.assertTrue(destination.is_dir())

    def test_noreplace_rename_fails_closed_on_unsupported_platform(self):
        from tools.ambitions_canon import build as canon_build

        with mock.patch("tools.ambitions_canon.build.sys.platform", "win32"):
            with self.assertRaises(CanonError) as raised:
                canon_build._rename_noreplace(
                    "source",
                    "destination",
                    source_directory=1,
                    destination_directory=1,
                )

        self.assertEqual(raised.exception.code, "CANON_GENERATED_PLATFORM")

    def test_postcommit_recursion_error_in_cleanup_warns_and_succeeds(self):
        from tools.ambitions_canon import build as canon_build

        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")
        real_remove_tree = canon_build._remove_tree_at

        def fail_cleanup_recursion(parent_descriptor, name, expected_identity=None):
            if name.startswith(".ambitions-canon-cleanup-"):
                raise RecursionError("forced deeply nested cleanup failure")
            return real_remove_tree(parent_descriptor, name, expected_identity)

        diagnostics = StringIO()
        with redirect_stderr(diagnostics):
            with mock.patch(
                "tools.ambitions_canon.build._remove_tree_at",
                side_effect=fail_cleanup_recursion,
            ):
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertEqual(
            (self.generated_root / "INDEX.md").read_bytes(),
            b"replacement\n",
        )
        self.assertIn(
            "WARNING CANON_GENERATED_CLEANUP_REQUIRED",
            diagnostics.getvalue(),
        )

    def test_broken_cleanup_warning_cannot_reverse_successful_commit(self):
        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")

        with mock.patch(
            "tools.ambitions_canon.build._remove_tree_at",
            side_effect=RecursionError("forced deeply nested cleanup failure"),
        ):
            with mock.patch(
                "builtins.print",
                side_effect=OSError(errno.EPIPE, "forced broken stderr"),
            ):
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertEqual(
            (self.generated_root / "INDEX.md").read_bytes(),
            b"replacement\n",
        )

    def test_broken_recovery_warning_preserves_restored_error_and_prior(self):
        from tools.ambitions_canon import build as canon_build

        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")
        real_fsync_directory = canon_build._fsync_directory
        postcondition_failed = False

        def fail_only_after_prior_restore(descriptor):
            if postcondition_failed and (self.generated_root / "old.md").exists():
                raise OSError(errno.EIO, "forced recovery fsync failure")
            return real_fsync_directory(descriptor)

        def fail_postcondition():
            nonlocal postcondition_failed
            postcondition_failed = True
            raise CanonError("FORCED_POSTCONDITION", "forced failure")

        with mock.patch(
            "tools.ambitions_canon.build._fsync_directory",
            side_effect=fail_only_after_prior_restore,
        ):
            with mock.patch(
                "builtins.print",
                side_effect=OSError(errno.EPIPE, "forced broken stderr"),
            ):
                with self.assertRaises(CanonError) as raised:
                    write_outputs_atomic(
                        self.generated_root,
                        {Path("INDEX.md"): b"replacement\n"},
                        postcondition=fail_postcondition,
                    )

        self.assertEqual(raised.exception.code, "FORCED_POSTCONDITION")
        self.assertEqual((self.generated_root / "old.md").read_bytes(), b"old\n")

    def test_root_entry_swap_after_install_is_quarantined_and_prior_restored(self):
        from tools.ambitions_canon import build as canon_build

        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")
        external = self.root / "external-root"
        external.mkdir()
        (external / "marker.txt").write_bytes(b"external\n")
        displaced = self.canon_root / "displaced-installed"
        real_rename_noreplace = canon_build._rename_noreplace
        swapped = False

        def replace_then_swap_entry(source, destination, **kwargs):
            nonlocal swapped
            result = real_rename_noreplace(source, destination, **kwargs)
            if (
                Path(source).name == "next"
                and Path(destination).name == "generated"
                and not swapped
            ):
                self.generated_root.rename(displaced)
                self.generated_root.symlink_to(external, target_is_directory=True)
                swapped = True
            return result

        with mock.patch(
            "tools.ambitions_canon.build._rename_noreplace",
            side_effect=replace_then_swap_entry,
        ):
            with self.assertRaises(CanonError) as raised:
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertTrue(swapped)
        self.assertEqual(
            raised.exception.code,
            "CANON_GENERATED_ENTRY_CHANGED",
        )
        self.assertEqual(
            (self.generated_root / "old.md").read_bytes(),
            b"old\n",
        )
        self.assertEqual((external / "marker.txt").read_bytes(), b"external\n")
        quarantines = tuple(
            self.canon_root.glob(".ambitions-canon-quarantine-*")
        )
        self.assertEqual(len(quarantines), 1)
        self.assertTrue(quarantines[0].is_symlink())

    def test_recovery_refuses_replaced_previous_symlink(self):
        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")
        external = self.root / "external-prior"
        external.mkdir()
        (external / "marker.txt").write_bytes(b"external\n")
        displaced = self.canon_root / "displaced-previous"

        def replace_previous_then_fail():
            previous = next(
                self.canon_root.glob(".ambitions-canon-previous-*")
            )
            previous.rename(displaced)
            previous.symlink_to(external, target_is_directory=True)
            raise CanonError("FORCED_POSTCONDITION", "forced failure")

        with self.assertRaises(CanonError) as raised:
            write_outputs_atomic(
                self.generated_root,
                {Path("INDEX.md"): b"replacement\n"},
                postcondition=replace_previous_then_fail,
            )

        self.assertEqual(
            raised.exception.code,
            "CANON_GENERATED_RECOVERY_REQUIRED",
        )
        self.assertNotIn("preserved", raised.exception.message)
        self.assertIn("cannot be verified", raised.exception.message)
        self.assertFalse(self.generated_root.is_symlink())
        self.assertFalse(self.generated_root.exists())
        self.assertEqual((external / "marker.txt").read_bytes(), b"external\n")
        replaced = tuple(
            self.canon_root.glob(".ambitions-canon-previous-*")
        )
        self.assertEqual(len(replaced), 1)
        self.assertTrue(replaced[0].is_symlink())

    def test_recovery_wording_does_not_claim_deleted_prior_is_preserved(self):
        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")

        def delete_previous_then_fail():
            previous = next(
                self.canon_root.glob(".ambitions-canon-previous-*")
            )
            shutil.rmtree(previous)
            raise CanonError("FORCED_POSTCONDITION", "forced failure")

        with self.assertRaises(CanonError) as raised:
            write_outputs_atomic(
                self.generated_root,
                {Path("INDEX.md"): b"replacement\n"},
                postcondition=delete_previous_then_fail,
            )

        self.assertEqual(
            raised.exception.code,
            "CANON_GENERATED_RECOVERY_REQUIRED",
        )
        self.assertIsNone(raised.exception.path)
        self.assertNotIn("preserved", raised.exception.message)
        self.assertIn("cannot be verified", raised.exception.message)

    def test_recovery_wording_distinguishes_no_prior_tree(self):
        real_replace = os.replace

        def fail_new_tree_removal(source, destination, *args, **kwargs):
            if (
                Path(source).name == "generated"
                and Path(destination).name.startswith("invalid-")
            ):
                raise OSError("forced rollback failure")
            return real_replace(source, destination, *args, **kwargs)

        def fail_postcondition():
            raise CanonError("FORCED_POSTCONDITION", "forced failure")

        with mock.patch(
            "tools.ambitions_canon.build.os.replace",
            side_effect=fail_new_tree_removal,
        ):
            with self.assertRaises(CanonError) as raised:
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                    postcondition=fail_postcondition,
                )

        self.assertEqual(
            raised.exception.code,
            "CANON_GENERATED_RECOVERY_REQUIRED",
        )
        self.assertIsNone(raised.exception.path)
        self.assertIn("no prior generated tree existed", raised.exception.message)
        self.assertNotIn("prior generated tree preserved", raised.exception.message)

    def test_success_cleanup_does_not_delete_replaced_previous_artifact(self):
        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")
        valuable = self.root / "valuable-previous"
        valuable.mkdir()
        (valuable / "keep.txt").write_bytes(b"keep\n")
        displaced = self.canon_root / "displaced-previous"
        from tools.ambitions_canon import build as canon_build

        real_cleanup = canon_build._cleanup_tree_best_effort
        replaced = False

        def replace_then_cleanup(parent_descriptor, name, *args, **kwargs):
            nonlocal replaced
            if name.startswith(".ambitions-canon-previous-") and not replaced:
                previous = next(
                    self.canon_root.glob(".ambitions-canon-previous-*")
                )
                previous.rename(displaced)
                valuable.rename(previous)
                replaced = True
            return real_cleanup(parent_descriptor, name, *args, **kwargs)

        diagnostics = StringIO()
        with redirect_stderr(diagnostics):
            with mock.patch(
                "tools.ambitions_canon.build._cleanup_tree_best_effort",
                side_effect=replace_then_cleanup,
            ):
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertTrue(replaced)
        retained = tuple(
            self.canon_root.glob(".ambitions-canon-previous-*/keep.txt")
        )
        self.assertEqual(len(retained), 1)
        self.assertEqual(retained[0].read_bytes(), b"keep\n")
        self.assertIn(
            "WARNING CANON_GENERATED_CLEANUP_REQUIRED",
            diagnostics.getvalue(),
        )

    def test_success_cleanup_does_not_delete_replaced_staging_artifact(self):
        valuable = self.root / "valuable-staging"
        valuable.mkdir()
        (valuable / "keep.txt").write_bytes(b"keep\n")
        displaced = self.canon_root / "displaced-staging"
        from tools.ambitions_canon import build as canon_build

        real_cleanup = canon_build._cleanup_tree_best_effort
        replaced = False

        def replace_then_cleanup(parent_descriptor, name, *args, **kwargs):
            nonlocal replaced
            if name.startswith(".ambitions-canon-build-") and not replaced:
                staging = next(
                    self.canon_root.glob(".ambitions-canon-build-*")
                )
                staging.rename(displaced)
                valuable.rename(staging)
                replaced = True
            return real_cleanup(parent_descriptor, name, *args, **kwargs)

        diagnostics = StringIO()
        with redirect_stderr(diagnostics):
            with mock.patch(
                "tools.ambitions_canon.build._cleanup_tree_best_effort",
                side_effect=replace_then_cleanup,
            ):
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertTrue(replaced)
        retained = tuple(
            self.canon_root.glob(".ambitions-canon-build-*/keep.txt")
        )
        self.assertEqual(len(retained), 1)
        self.assertEqual(retained[0].read_bytes(), b"keep\n")
        self.assertIn(
            "WARNING CANON_GENERATED_CLEANUP_REQUIRED",
            diagnostics.getvalue(),
        )

    def test_fsync_failure_after_prior_hide_restores_prior_visibility(self):
        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")
        real_fsync = os.fsync
        failed = False

        def fail_after_prior_hide(descriptor):
            nonlocal failed
            hidden = tuple(
                self.canon_root.glob(".ambitions-canon-previous-*")
            )
            if not failed and hidden and not self.generated_root.exists():
                failed = True
                raise OSError(errno.EIO, "forced prior durability failure")
            return real_fsync(descriptor)

        with mock.patch(
            "tools.ambitions_canon.build.os.fsync",
            side_effect=fail_after_prior_hide,
        ):
            with self.assertRaises(CanonError) as raised:
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertTrue(failed)
        self.assertEqual(raised.exception.code, "CANON_GENERATED_WRITE")
        self.assertEqual((self.generated_root / "old.md").read_bytes(), b"old\n")
        self.assertFalse(tuple(self.canon_root.glob(".ambitions-canon-previous-*")))

    def test_first_rename_failure_leaves_prior_tree_visible(self):
        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")
        real_replace = os.replace

        def fail_first_rename(source, destination, *args, **kwargs):
            if (
                Path(source).name == "generated"
                and Path(destination).name.startswith(
                    ".ambitions-canon-previous-"
                )
            ):
                raise OSError("forced first rename failure")
            return real_replace(source, destination, *args, **kwargs)

        with mock.patch(
            "tools.ambitions_canon.build.os.replace",
            side_effect=fail_first_rename,
        ):
            with self.assertRaises(CanonError) as raised:
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertEqual(raised.exception.code, "CANON_GENERATED_WRITE")
        self.assertEqual((self.generated_root / "old.md").read_bytes(), b"old\n")
        self.assertFalse(tuple(self.canon_root.glob(".ambitions-canon-quarantine-*")))

    def test_fsync_failure_after_install_restores_prior_tree(self):
        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")
        real_fsync = os.fsync
        failed = False

        def fail_after_install(descriptor):
            nonlocal failed
            hidden = tuple(
                self.canon_root.glob(".ambitions-canon-previous-*")
            )
            if (
                not failed
                and hidden
                and (self.generated_root / "INDEX.md").exists()
            ):
                failed = True
                raise OSError(errno.EIO, "forced installed durability failure")
            return real_fsync(descriptor)

        with mock.patch(
            "tools.ambitions_canon.build.os.fsync",
            side_effect=fail_after_install,
        ):
            with self.assertRaises(CanonError) as raised:
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertTrue(failed)
        self.assertEqual(raised.exception.code, "CANON_GENERATED_WRITE")
        self.assertEqual((self.generated_root / "old.md").read_bytes(), b"old\n")
        self.assertFalse((self.generated_root / "INDEX.md").exists())

    def test_fsync_failure_after_first_install_removes_new_tree(self):
        real_fsync = os.fsync
        failed = False

        def fail_after_install(descriptor):
            nonlocal failed
            if not failed and (self.generated_root / "INDEX.md").exists():
                failed = True
                raise OSError(errno.EIO, "forced installed durability failure")
            return real_fsync(descriptor)

        with mock.patch(
            "tools.ambitions_canon.build.os.fsync",
            side_effect=fail_after_install,
        ):
            with self.assertRaises(CanonError) as raised:
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertTrue(failed)
        self.assertEqual(raised.exception.code, "CANON_GENERATED_WRITE")
        self.assertFalse(self.generated_root.exists())

    def test_successful_commit_fsyncs_file_staging_and_rename_directories(self):
        real_fsync = os.fsync
        with mock.patch(
            "tools.ambitions_canon.build.os.fsync",
            wraps=real_fsync,
        ) as fsync:
            write_outputs_atomic(
                self.generated_root,
                {Path("INDEX.md"): b"replacement\n"},
            )

        self.assertGreaterEqual(fsync.call_count, 4)

    def test_check_reports_changed_missing_and_extra_without_mutation(self):
        self.generated_root.mkdir()
        changed = self.generated_root / "changed.md"
        extra = self.generated_root / "extra.md"
        changed.write_bytes(b"old\n")
        extra.write_bytes(b"extra\n")
        before = {
            path.relative_to(self.generated_root): path.read_bytes()
            for path in self.generated_root.rglob("*")
            if path.is_file()
        }

        findings = check_outputs(
            self.generated_root,
            {
                Path("changed.md"): b"new\n",
                Path("missing.md"): b"missing\n",
            },
        )

        self.assertEqual(
            tuple(finding.code for finding in findings),
            (
                "CANON_GENERATED_CHANGED",
                "CANON_GENERATED_EXTRA",
                "CANON_GENERATED_MISSING",
            ),
        )
        self.assertEqual(
            before,
            {
                path.relative_to(self.generated_root): path.read_bytes()
                for path in self.generated_root.rglob("*")
                if path.is_file()
            },
        )

    def test_check_rejects_symlinked_expected_output_without_following_it(self):
        self.generated_root.mkdir()
        outside = self.root / "outside.md"
        outside.write_bytes(b"expected\n")
        (self.generated_root / "INDEX.md").symlink_to(outside)

        with mock.patch(
            "pathlib.Path.read_bytes",
            side_effect=AssertionError("check followed a path instead of using no-follow reads"),
        ):
            findings = check_outputs(
                self.generated_root,
                {Path("INDEX.md"): b"expected\n"},
            )

        self.assertEqual(
            tuple(finding.code for finding in findings),
            ("CANON_GENERATED_CHANGED",),
        )

    def test_write_and_check_reject_a_static_symlinked_ancestor(self):
        external = self.root / "external"
        external.mkdir()
        alias = self.root / "alias"
        alias.symlink_to(external, target_is_directory=True)
        escaped_root = alias / "generated"

        with self.assertRaises(CanonError) as write_error:
            write_outputs_atomic(
                escaped_root,
                {Path("INDEX.md"): b"expected\n"},
            )
        self.assertEqual(
            write_error.exception.code,
            "CANON_GENERATED_PATH_ESCAPE",
        )
        self.assertFalse((external / "generated").exists())

        (external / "generated").mkdir()
        (external / "generated" / "INDEX.md").write_bytes(b"expected\n")
        with self.assertRaises(CanonError) as check_error:
            check_outputs(
                escaped_root,
                {Path("INDEX.md"): b"expected\n"},
            )
        self.assertEqual(
            check_error.exception.code,
            "CANON_GENERATED_PATH_ESCAPE",
        )

    def test_build_rejects_docs_canon_swapped_to_symlink_before_write(self):
        self.write_canon()
        safe_canon = self.root / "safe-canon"
        external_canon = self.root / "external-canon"
        external_canon.mkdir()
        real_write_outputs = write_outputs_atomic
        swapped = False

        def swap_then_write(root, outputs, **kwargs):
            nonlocal swapped
            self.canon_root.rename(safe_canon)
            self.canon_root.symlink_to(external_canon, target_is_directory=True)
            swapped = True
            return real_write_outputs(root, outputs, **kwargs)

        with mock.patch(
            "tools.ambitions_canon.build.write_outputs_atomic",
            side_effect=swap_then_write,
        ):
            with self.assertRaises(CanonError) as raised:
                build_canon(self.root)

        self.assertTrue(swapped)
        self.assertEqual(
            raised.exception.code,
            "CANON_GENERATED_PATH_ESCAPE",
        )
        self.assertFalse((external_canon / "generated").exists())

    def test_write_rejects_ancestor_swapped_after_descriptor_open(self):
        from tools.ambitions_canon import build as canon_build

        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")
        safe_canon = self.root / "safe-canon"
        external_canon = self.root / "external-canon"
        external_canon.mkdir()
        real_rename_noreplace = canon_build._rename_noreplace
        swapped = False

        def swap_after_install(source, destination, **kwargs):
            nonlocal swapped
            result = real_rename_noreplace(source, destination, **kwargs)
            if (
                Path(source).name == "next"
                and Path(destination).name == "generated"
                and not swapped
            ):
                self.canon_root.rename(safe_canon)
                self.canon_root.symlink_to(external_canon, target_is_directory=True)
                swapped = True
            return result

        with mock.patch(
            "tools.ambitions_canon.build._rename_noreplace",
            side_effect=swap_after_install,
        ):
            with self.assertRaises(CanonError) as raised:
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertTrue(swapped)
        self.assertEqual(
            raised.exception.code,
            "CANON_GENERATED_PATH_ESCAPE",
        )
        self.assertEqual((safe_canon / "generated" / "old.md").read_bytes(), b"old\n")
        self.assertFalse((external_canon / "generated").exists())

    def test_check_rejects_docs_canon_swapped_to_symlink_at_boundary(self):
        self.write_canon()
        build_canon(self.root)
        safe_canon = self.root / "safe-canon"
        external_canon = self.root / "external-canon"
        shutil.copytree(self.canon_root, external_canon)
        real_check_outputs = check_outputs

        def swap_then_check(root, outputs):
            self.canon_root.rename(safe_canon)
            self.canon_root.symlink_to(external_canon, target_is_directory=True)
            return real_check_outputs(root, outputs)

        with mock.patch(
            "tools.ambitions_canon.build.check_outputs",
            side_effect=swap_then_check,
        ):
            with self.assertRaises(CanonError) as raised:
                build_canon(self.root, check=True)

        self.assertEqual(
            raised.exception.code,
            "CANON_GENERATED_PATH_ESCAPE",
        )

    def test_check_rejects_ancestor_swapped_after_descriptor_open(self):
        self.write_canon()
        build_canon(self.root)
        safe_canon = self.root / "safe-canon"
        external_canon = self.root / "external-canon"
        shutil.copytree(self.canon_root, external_canon)
        from tools.ambitions_canon import build as canon_build

        real_read = canon_build._read_file_at
        swapped = False

        def read_then_swap(descriptor, path):
            nonlocal swapped
            content = real_read(descriptor, path)
            if not swapped:
                self.canon_root.rename(safe_canon)
                self.canon_root.symlink_to(external_canon, target_is_directory=True)
                swapped = True
            return content

        with mock.patch(
            "tools.ambitions_canon.build._read_file_at",
            side_effect=read_then_swap,
        ):
            with self.assertRaises(CanonError) as raised:
                check_outputs(
                    self.generated_root,
                    {
                        path.relative_to(self.generated_root): path.read_bytes()
                        for path in self.generated_root.rglob("*")
                        if path.is_file()
                    },
                )

        self.assertTrue(swapped)
        self.assertEqual(
            raised.exception.code,
            "CANON_GENERATED_PATH_ESCAPE",
        )

    def test_check_rejects_visible_root_replaced_after_pinned_read(self):
        self.write_canon()
        build_canon(self.root)
        replacement = self.canon_root / "replacement-generated"
        shutil.copytree(self.generated_root, replacement)
        displaced = self.canon_root / "displaced-generated"
        from tools.ambitions_canon import build as canon_build

        real_read = canon_build._read_file_at
        swapped = False

        def read_then_replace(descriptor, path):
            nonlocal swapped
            content = real_read(descriptor, path)
            if not swapped:
                self.generated_root.rename(displaced)
                replacement.rename(self.generated_root)
                swapped = True
            return content

        expected = {
            path.relative_to(self.generated_root): path.read_bytes()
            for path in self.generated_root.rglob("*")
            if path.is_file()
        }
        with mock.patch(
            "tools.ambitions_canon.build._read_file_at",
            side_effect=read_then_replace,
        ):
            with self.assertRaises(CanonError) as raised:
                check_outputs(self.generated_root, expected)

        self.assertTrue(swapped)
        self.assertEqual(
            raised.exception.code,
            "CANON_GENERATED_ENTRY_CHANGED",
        )

    def test_recovery_error_omits_stale_path_after_parent_identity_changes(self):
        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")
        safe_canon = self.root / "safe-canon"
        external_canon = self.root / "external-canon"
        external_canon.mkdir()
        real_replace = os.replace
        parent_swapped = False

        def swap_parent_then_fail_commit_and_restore(
            source,
            destination,
            *args,
            **kwargs,
        ):
            nonlocal parent_swapped
            source_name = Path(source).name
            destination_name = Path(destination).name
            if source_name == "generated" and destination_name.startswith(
                ".ambitions-canon-previous-"
            ):
                result = real_replace(source, destination, *args, **kwargs)
                self.canon_root.rename(safe_canon)
                self.canon_root.symlink_to(external_canon, target_is_directory=True)
                parent_swapped = True
                return result
            if source_name == "next" and destination_name == "generated":
                raise OSError("forced commit failure")
            if source_name.startswith(".ambitions-canon-previous-"):
                raise OSError("forced restore failure")
            return real_replace(source, destination, *args, **kwargs)

        with mock.patch(
            "tools.ambitions_canon.build.os.replace",
            side_effect=swap_parent_then_fail_commit_and_restore,
        ):
            with self.assertRaises(CanonError) as raised:
                write_outputs_atomic(
                    self.generated_root,
                    {Path("INDEX.md"): b"replacement\n"},
                )

        self.assertTrue(parent_swapped)
        self.assertEqual(
            raised.exception.code,
            "CANON_GENERATED_RECOVERY_REQUIRED",
        )
        self.assertIsNone(raised.exception.path)
        self.assertIn("identity is preserved in pinned parent", raised.exception.message)
        preserved = tuple(
            safe_canon.glob(".ambitions-canon-previous-*/old.md")
        )
        self.assertEqual(len(preserved), 1)
        self.assertEqual(preserved[0].read_bytes(), b"old\n")

    def test_final_parent_then_root_check_catches_swap_after_cleanup(self):
        self.generated_root.mkdir()
        (self.generated_root / "old.md").write_bytes(b"old\n")
        replacement = self.canon_root / "late-replacement"
        replacement.mkdir()
        (replacement / "marker.txt").write_bytes(b"replacement\n")
        displaced = self.canon_root / "late-displaced"
        from tools.ambitions_canon import build as canon_build

        real_cleanup = canon_build._cleanup_tree_best_effort
        real_parent_check = canon_build._assert_parent_path_identity
        cleanup_seen = False
        swapped = False

        def observe_cleanup(*args, **kwargs):
            nonlocal cleanup_seen
            cleanup_seen = True
            return real_cleanup(*args, **kwargs)

        def swap_after_final_parent_check(path, descriptor):
            nonlocal swapped
            result = real_parent_check(path, descriptor)
            if cleanup_seen and not swapped:
                self.generated_root.rename(displaced)
                replacement.rename(self.generated_root)
                swapped = True
            return result

        with mock.patch(
            "tools.ambitions_canon.build._cleanup_tree_best_effort",
            side_effect=observe_cleanup,
        ):
            with mock.patch(
                "tools.ambitions_canon.build._assert_parent_path_identity",
                side_effect=swap_after_final_parent_check,
            ):
                with self.assertRaises(CanonError) as raised:
                    write_outputs_atomic(
                        self.generated_root,
                        {Path("INDEX.md"): b"replacement\n"},
                    )

        self.assertTrue(cleanup_seen)
        self.assertTrue(swapped)
        self.assertEqual(
            raised.exception.code,
            "CANON_GENERATED_ENTRY_CHANGED",
        )
        self.assertFalse(self.generated_root.exists())
        quarantines = tuple(
            self.canon_root.glob(".ambitions-canon-quarantine-*/marker.txt")
        )
        self.assertEqual(len(quarantines), 1)
        self.assertEqual(quarantines[0].read_bytes(), b"replacement\n")

    def test_invalid_output_paths_are_rejected_before_mutation(self):
        self.generated_root.mkdir()
        sentinel = self.generated_root / "sentinel.txt"
        sentinel.write_bytes(b"original\n")

        for invalid in (Path("../escape.md"), Path("/absolute.md"), Path(".")):
            with self.subTest(path=invalid):
                with self.assertRaises(CanonError) as raised:
                    write_outputs_atomic(
                        self.generated_root,
                        {invalid: b"invalid\n"},
                    )
                self.assertEqual(raised.exception.code, "CANON_GENERATED_PATH")
                self.assertEqual(sentinel.read_bytes(), b"original\n")

    def test_build_and_check_cli_contract(self):
        self.write_canon()
        previous = Path.cwd()
        output = StringIO()
        try:
            os.chdir(self.root)
            with redirect_stdout(output):
                build_result = main(["build"])
                check_result = main(["build", "--check"])
        finally:
            os.chdir(previous)

        self.assertEqual((build_result, check_result), (0, 0))
        self.assertEqual(
            tuple(output.getvalue().splitlines()),
            (
                "GREEN ambitions canon generated outputs",
                "GREEN ambitions canon generated outputs",
            ),
        )
        self.assertEqual(
            tuple(
                path.relative_to(self.generated_root).as_posix()
                for path in sorted(self.generated_root.rglob("*"))
                if path.is_file()
            ),
            tuple(sorted(GENERATED_FILES)),
        )

    def test_build_hashes_and_renders_declared_nested_normative_sources(self):
        self.write_canon(
            {
                "specifications/today.md": document_text(
                    "SURFACE-TODAY", "surface.today", "TODAY-001"
                )
            }
        )

        findings = build_canon(self.root)

        self.assertEqual(findings, ())
        index = (self.generated_root / "canon-index.json").read_text(
            encoding="utf-8"
        )
        self.assertIn('"spec_id": "SURFACE-TODAY"', index)
        self.assertIn('"requirement_id": "TODAY-001"', index)

    def test_object_boundary_matrix_reports_distinct_step_event_reminder_note_laws(self):
        shutil.rmtree(self.canon_root)
        shutil.copytree(ROOT / "docs/canon", self.canon_root)
        self.clear_local_proof_references(self.canon_root)

        findings = build_canon(self.root)

        self.assertEqual(findings, ())
        report = (self.generated_root / "object-boundary-matrix.md").read_text(
            encoding="utf-8"
        )
        self.assertFalse(report.endswith("\n\n"))
        expected_rows = (
            "| Executable / completable | Yes | No | No, unless linked to Step | No |",
            "| Occupies duration | Optional | Required for timed event | No | No |",
            "| Consumes capacity | When scheduled | Yes according to blocking state | No | No |",
            "| Due date | Yes | End time is not a due date | Optional reminder date | No until promoted |",
            "| Recurrence | Repeatable Step series | Event series + exceptions | Reminder repetition | No |",
            "| Substeps | Yes | No | No | No |",
            "| Goal Path node | Yes | May be contextual | May support a Step | No until promoted |",
            "| Proof requirement | Optional/suggested/required | Normally no | No | No |",
            "| Attendees / RSVP | No | Yes | No | No |",
            "| Alerts | Optional | Optional | Core capability | Optional only after promotion |",
            "| Type conversion | Explicit, receipt-backed | Explicit, receipt-backed | Explicit, receipt-backed | Promote explicitly |",
        )
        for row in expected_rows:
            self.assertIn(row, report)
        for law_id in (
            "OBJ-SCHEDULE-PLACEMENT-IDENTITY-001",
            "OBJECT-FUTURE-STEP-IDENTITY-001",
            "OBJECT-REMINDER-COMPLETION-001",
            "OBJECT-PROOF-REQUIREMENT-001",
        ):
            self.assertIn(law_id, report)

    def test_object_boundary_matrix_fails_closed_on_law_mismatch_and_unknown_id(self):
        for name, old, new in (
            (
                "mismatch",
                'future_step_singularity = "OBJECT-FUTURE-STEP-IDENTITY-001"',
                'future_step_singularity = "OBJECT-REMINDER-COMPLETION-001"',
            ),
            (
                "unknown",
                'future_step_singularity = "OBJECT-FUTURE-STEP-IDENTITY-001"',
                'future_step_singularity = "OBJECT-UNKNOWN-001"',
            ),
        ):
            with self.subTest(name=name), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                shutil.copytree(ROOT / "docs/canon", root / "docs/canon")
                self.clear_local_proof_references(root / "docs/canon")
                step = root / "docs/canon/specifications/objects/step.md"
                step.write_text(step.read_text(encoding="utf-8").replace(old, new, 1), encoding="utf-8")

                with self.assertRaises(CanonError) as raised:
                    build_canon(root)
                self.assertEqual(raised.exception.code, "CANON_OBJECT_BOUNDARY_LAW_INVALID")

    def test_object_boundary_spec_drift_is_detected_by_build_check(self):
        shutil.rmtree(self.canon_root)
        shutil.copytree(ROOT / "docs/canon", self.canon_root)
        self.clear_local_proof_references(self.canon_root)
        self.assertEqual(build_canon(self.root), ())
        step = self.canon_root / "specifications/objects/step.md"
        step.write_text(
            step.read_text(encoding="utf-8").replace(
                'occupies_duration = "Optional"',
                'occupies_duration = "Changed by source"',
                1,
            ),
            encoding="utf-8",
        )

        findings = build_canon(self.root, check=True)

        self.assertTrue(findings)
        self.assertIn("object-boundary-matrix.md", {item.path.name for item in findings})

    def test_manifest_change_between_load_and_hash_blocks_generation(self):
        self.write_canon()
        manifest_path = self.canon_root / "MANIFEST.toml"
        real_load_manifest = load_manifest

        def load_then_change(root):
            manifest = real_load_manifest(root)
            text = manifest_path.read_text(encoding="utf-8")
            manifest_path.write_text(
                text.replace("canon_revision = 0", "canon_revision = 1"),
                encoding="utf-8",
            )
            return manifest

        with mock.patch(
            "tools.ambitions_canon.build.load_manifest",
            side_effect=load_then_change,
        ):
            with self.assertRaises(CanonError) as raised:
                build_canon(self.root)

        self.assertEqual(raised.exception.code, "CANON_CONTENT_CHANGED")
        self.assertFalse(self.generated_root.exists())

    def test_source_change_during_output_commit_restores_prior_generated_tree(self):
        from tools.ambitions_canon import build as canon_build

        documents = {
            "specifications/today.md": document_text(
                "SURFACE-TODAY", "surface.today", "TODAY-001"
            )
        }
        self.write_canon(documents)
        build_canon(self.root)
        before = {
            path.relative_to(self.generated_root): path.read_bytes()
            for path in self.generated_root.rglob("*")
            if path.is_file()
        }
        source = self.canon_root / "specifications" / "today.md"
        real_rename_noreplace = canon_build._rename_noreplace
        mutated = False

        def mutate_after_commit(source_path, destination_path, **kwargs):
            nonlocal mutated
            result = real_rename_noreplace(
                source_path,
                destination_path,
                **kwargs,
            )
            if (
                Path(source_path).name == "next"
                and Path(destination_path).name == "generated"
                and not mutated
            ):
                source.write_text(
                    source.read_text(encoding="utf-8").replace(
                        "Deterministic body.",
                        "Changed at commit boundary.",
                    ),
                    encoding="utf-8",
                )
                mutated = True
            return result

        with mock.patch(
            "tools.ambitions_canon.build._rename_noreplace",
            side_effect=mutate_after_commit,
        ):
            with self.assertRaises(CanonError) as raised:
                build_canon(self.root)

        self.assertTrue(mutated)
        self.assertEqual(raised.exception.code, "CANON_CONTENT_CHANGED")
        self.assertEqual(
            before,
            {
                path.relative_to(self.generated_root): path.read_bytes()
                for path in self.generated_root.rglob("*")
                if path.is_file()
            },
        )

    def test_public_render_uses_loaded_corpus_provenance_not_current_directory(self):
        self.write_canon()
        manifest_path = self.canon_root / "MANIFEST.toml"
        manifest_path.write_text(
            manifest_text(canon_revision=7),
            encoding="utf-8",
        )
        write_required_governance_artifacts(
            self.canon_root,
            canon_revision=7,
        )
        registry = self.registry()
        expected_sha = canon_content_sha(manifest_path, ())
        unrelated = self.root / "unrelated"
        unrelated.mkdir()
        unrelated_canon = unrelated / "docs" / "canon"
        unrelated_canon.mkdir(parents=True)
        (unrelated_canon / "MANIFEST.toml").write_text(
            manifest_text(canon_revision=99),
            encoding="utf-8",
        )
        write_required_governance_artifacts(
            unrelated_canon,
            canon_revision=99,
        )
        previous = Path.cwd()
        try:
            os.chdir(unrelated)
            outputs = render_outputs(registry)
        finally:
            os.chdir(previous)

        index = json.loads(outputs[Path("canon-index.json")])
        self.assertEqual(index["canon_revision"], 7)
        self.assertEqual(index["canon_content_sha"], expected_sha)
        for content in outputs.values():
            self.assertNotIn(str(self.root).encode("utf-8"), content)

    def test_traceability_and_external_inputs_are_explicitly_represented(self):
        self.write_canon(
            {
                "specifications/today.md": document_text(
                    "SURFACE-TODAY",
                    "surface.today",
                    "TODAY-001",
                    verification="`SCENARIO-001`, `PROOF-001`",
                )
            }
        )
        outputs = self.render_in_repository(self.registry())

        for filename in ("law-test-map.json", "law-proof-map.json"):
            payload = json.loads(outputs[Path(filename)])
            self.assertEqual(payload["mappings"][0]["mapping_status"], "mapped")
            self.assertTrue(payload["mappings"][0]["verification_ids"])
        visual = json.loads(outputs[Path("visual-authority-manifest.json")])
        self.assertEqual(visual["authorities"], [])
        self.assertFalse(visual["ui_readiness"])
        self.assertIn(
            "Unrepresented",
            outputs[Path("unresolved-conflicts.md")].decode("utf-8"),
        )
        external = outputs[Path("external-reference-impact.md")].decode("utf-8")
        self.assertIn("**Representation status:** Represented", external)
        self.assertIn("- Stable references: `0`", external)

    def test_markdown_tables_escape_cell_delimiters(self):
        self.write_canon(
            {
                "specifications/today.md": document_text(
                    "SURFACE-TODAY",
                    "surface.today",
                    "TODAY-001",
                    title="Today | Reality",
                )
            }
        )

        index = self.render_in_repository(self.registry())[Path("INDEX.md")].decode(
            "utf-8"
        )

        self.assertIn("Today &#124; Reality", index)
        self.assertNotIn("Today | Reality", index)

    def test_coverage_table_escapes_profile_delimiters(self):
        self.write_canon(
            {
                "specifications/today.md": document_text(
                    "SURFACE-TODAY",
                    "surface.today",
                    "TODAY-001",
                    profile="surface|custom",
                )
            }
        )

        coverage = self.render_in_repository(self.registry())[
            Path("specification-coverage.md")
        ].decode("utf-8")

        self.assertIn("surface&#124;custom", coverage)
        self.assertNotIn("surface|custom", coverage)

    def test_check_cli_fails_closed_for_changed_missing_and_extra(self):
        self.write_canon()
        build_canon(self.root)
        (self.generated_root / "INDEX.md").write_bytes(b"changed\n")
        (self.generated_root / "canon-index.json").unlink()
        (self.generated_root / "extra.txt").write_bytes(b"extra\n")
        before = hashlib.sha256(
            b"".join(
                path.relative_to(self.generated_root).as_posix().encode() + path.read_bytes()
                for path in sorted(self.generated_root.rglob("*"))
                if path.is_file()
            )
        ).hexdigest()
        output = StringIO()
        previous = Path.cwd()
        try:
            os.chdir(self.root)
            with redirect_stdout(output):
                result = main(["build", "--check"])
        finally:
            os.chdir(previous)

        self.assertEqual(result, 1)
        self.assertIn("CANON_GENERATED_CHANGED", output.getvalue())
        self.assertIn("CANON_GENERATED_MISSING", output.getvalue())
        self.assertIn("CANON_GENERATED_EXTRA", output.getvalue())
        after = hashlib.sha256(
            b"".join(
                path.relative_to(self.generated_root).as_posix().encode() + path.read_bytes()
                for path in sorted(self.generated_root.rglob("*"))
                if path.is_file()
            )
        ).hexdigest()
        self.assertEqual(before, after)


if __name__ == "__main__":
    unittest.main()
