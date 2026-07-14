import json
import os
import shutil
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.model import AuthorityState, CanonError


REPO_ROOT = Path(__file__).resolve().parents[2]
SCHEMAS = (
    "manifest.schema.json",
    "specification.schema.json",
    "requirement.schema.json",
    "authority-reference.schema.json",
    "task-pack.schema.json",
)
GENERATED_FILES = (
    "generated/CODEX_START_HERE.md",
    "generated/INDEX.md",
    "generated/canon-index.json",
    "generated/concept-ownership.json",
    "generated/requirement-graph.json",
    "generated/specification-coverage.md",
    "generated/unresolved-conflicts.md",
    "generated/law-source-map.json",
    "generated/law-test-map.json",
    "generated/law-proof-map.json",
    "generated/visual-authority-manifest.json",
    "generated/external-reference-impact.md",
    "generated/supersession-manifest.json",
    "generated/object-boundary-matrix.md",
)


def manifest_text(
    *,
    authority_state: str = "shadow",
    normative_files: tuple[str, ...] = (),
    generated_files: tuple[str, ...] = GENERATED_FILES,
) -> str:
    normative = ", ".join(json.dumps(path) for path in normative_files)
    generated = ",\n  ".join(json.dumps(path) for path in generated_files)
    return (
        "schema_version = 1\n"
        "canon_revision = 0\n"
        f'authority_state = "{authority_state}"\n'
        'compiler_version = "0.1.0"\n'
        f"normative_files = [{normative}]\n\n"
        "generated_files = [\n"
        f"  {generated},\n"
        "]\n"
    )


def canonical_document(spec_id: str, kind: str = "surface") -> str:
    return (
        "+++\n"
        f'spec_id = "{spec_id}"\n'
        f'title = "{spec_id}"\n'
        f'kind = "{kind}"\n'
        'status = "normative"\n'
        'owner_domain = "product"\n'
        "canon_revision = 1\n"
        'owns_concepts = ["test.concept"]\n'
        "inherits = []\n"
        "depends_on = []\n"
        "source_owners = []\n"
        "+++\n"
    )


class ManifestTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary_directory.cleanup)
        self.root = Path(self.temporary_directory.name)
        self.canon_root = self.root / "docs" / "canon"
        self.canon_root.mkdir(parents=True)

    def write_manifest(self, text: str) -> None:
        (self.canon_root / "MANIFEST.toml").write_text(text, encoding="utf-8")

    def assert_error_code(self, code: str, operation) -> CanonError:
        with self.assertRaises(CanonError) as raised:
            operation()
        self.assertEqual(raised.exception.code, code)
        return raised.exception

    def test_shadow_manifest_with_no_normative_documents_is_valid(self):
        self.write_manifest(manifest_text())

        manifest = load_manifest(self.root)

        self.assertIs(manifest.authority_state, AuthorityState.SHADOW)
        self.assertEqual(manifest.normative_files, ())
        self.assertEqual(load_documents(self.root, manifest), ())

    def test_active_manifest_with_no_constitution_fails(self):
        self.write_manifest(manifest_text(authority_state="active"))
        manifest = load_manifest(self.root)

        self.assert_error_code(
            "CANON_MANIFEST_CONSTITUTION_REQUIRED",
            lambda: load_documents(self.root, manifest),
        )

    def test_active_manifest_with_more_than_one_constitution_fails(self):
        paths = ("CONSTITUTION.md", "SECOND-CONSTITUTION.md")
        self.write_manifest(
            manifest_text(authority_state="active", normative_files=paths)
        )
        for index, path in enumerate(paths):
            (self.canon_root / path).write_text(
                canonical_document(f"CONSTITUTION-{index}", "constitution"),
                encoding="utf-8",
            )
        manifest = load_manifest(self.root)

        self.assert_error_code(
            "CANON_MANIFEST_CONSTITUTION_REQUIRED",
            lambda: load_documents(self.root, manifest),
        )

    def test_unknown_authority_state_fails(self):
        self.write_manifest(manifest_text(authority_state="preview"))

        self.assert_error_code(
            "CANON_MANIFEST_AUTHORITY_STATE",
            lambda: load_manifest(self.root),
        )

    def test_duplicate_normative_manifest_path_fails(self):
        self.write_manifest(
            manifest_text(normative_files=("CONSTITUTION.md", "CONSTITUTION.md"))
        )

        self.assert_error_code(
            "CANON_MANIFEST_PATH_DUPLICATE",
            lambda: load_manifest(self.root),
        )

    def test_noncanonical_or_escaping_manifest_paths_fail_before_reads(self):
        cases = (
            "../outside.md",
            "/tmp/outside.md",
            "specifications/../CONSTITUTION.md",
            "./CONSTITUTION.md",
        )
        for path in cases:
            with self.subTest(path=path):
                self.write_manifest(manifest_text(normative_files=(path,)))
                self.assert_error_code(
                    "CANON_MANIFEST_PATH_INVALID",
                    lambda: load_manifest(self.root),
                )

    def test_symlink_escape_is_rejected_before_document_read(self):
        outside = self.root / "outside.md"
        outside.write_text(canonical_document("OUTSIDE"), encoding="utf-8")
        (self.canon_root / "linked.md").symlink_to(outside)
        self.write_manifest(manifest_text(normative_files=("linked.md",)))
        manifest = load_manifest(self.root)

        self.assert_error_code(
            "CANON_MANIFEST_PATH_ESCAPE",
            lambda: load_documents(self.root, manifest),
        )

    def test_manifest_symlink_escape_is_rejected_before_read(self):
        outside = self.root / "outside-manifest.toml"
        outside.write_text(manifest_text(), encoding="utf-8")
        (self.canon_root / "MANIFEST.toml").symlink_to(outside)

        self.assert_error_code(
            "CANON_MANIFEST_PATH_ESCAPE",
            lambda: load_manifest(self.root),
        )

    def test_manifest_swap_to_external_symlink_at_open_is_rejected(self):
        self.write_manifest(manifest_text())
        outside = self.root / "outside-manifest.toml"
        outside.write_text(manifest_text(authority_state="active"), encoding="utf-8")
        manifest_path = self.canon_root / "MANIFEST.toml"
        real_open = os.open
        swapped = False

        def racing_open(path, flags, mode=0o777, *, dir_fd=None):
            nonlocal swapped
            if path == "MANIFEST.toml" and not swapped:
                swapped = True
                manifest_path.unlink()
                manifest_path.symlink_to(outside)
            return real_open(path, flags, mode, dir_fd=dir_fd)

        with mock.patch("os.open", side_effect=racing_open):
            self.assert_error_code(
                "CANON_MANIFEST_PATH_ESCAPE",
                lambda: load_manifest(self.root),
            )
        self.assertTrue(swapped)

    def test_intermediate_docs_swap_before_manifest_open_is_rejected(self):
        self.write_manifest(manifest_text())
        external_temporary_directory = tempfile.TemporaryDirectory()
        self.addCleanup(external_temporary_directory.cleanup)
        external_docs = Path(external_temporary_directory.name) / "docs"
        external_canon = external_docs / "canon"
        external_canon.mkdir(parents=True)
        (external_canon / "MANIFEST.toml").write_text(
            manifest_text(authority_state="active"),
            encoding="utf-8",
        )
        docs = self.root / "docs"
        safe_docs = self.root / "safe-docs"
        resolved_canon_root = self.canon_root.resolve()
        real_open = os.open
        swapped = False

        def racing_open(path, flags, mode=0o777, *, dir_fd=None):
            nonlocal swapped
            if not swapped and (
                path == "docs" or Path(path) == resolved_canon_root
            ):
                swapped = True
                docs.rename(safe_docs)
                docs.symlink_to(external_docs, target_is_directory=True)
            return real_open(path, flags, mode, dir_fd=dir_fd)

        with mock.patch("os.open", side_effect=racing_open):
            self.assert_error_code(
                "CANON_MANIFEST_PATH_ESCAPE",
                lambda: load_manifest(self.root),
            )
        self.assertTrue(swapped)

    def test_nested_document_swap_to_external_symlink_at_open_is_rejected(self):
        nested = self.canon_root / "specifications"
        nested.mkdir()
        document_path = nested / "today.md"
        document_path.write_text(canonical_document("SURFACE-TODAY"), encoding="utf-8")
        outside = self.root / "outside.md"
        outside.write_text(canonical_document("EXTERNAL"), encoding="utf-8")
        self.write_manifest(
            manifest_text(normative_files=("specifications/today.md",))
        )
        manifest = load_manifest(self.root)
        real_open = os.open
        swapped = False

        def racing_open(path, flags, mode=0o777, *, dir_fd=None):
            nonlocal swapped
            if path == "today.md" and not swapped:
                swapped = True
                document_path.unlink()
                document_path.symlink_to(outside)
            return real_open(path, flags, mode, dir_fd=dir_fd)

        with mock.patch("os.open", side_effect=racing_open):
            self.assert_error_code(
                "CANON_MANIFEST_PATH_ESCAPE",
                lambda: load_documents(self.root, manifest),
            )
        self.assertTrue(swapped)

    def test_intermediate_docs_swap_before_document_open_is_rejected(self):
        nested = self.canon_root / "specifications"
        nested.mkdir()
        (nested / "today.md").write_text(
            canonical_document("SURFACE-TODAY"),
            encoding="utf-8",
        )
        self.write_manifest(
            manifest_text(normative_files=("specifications/today.md",))
        )
        manifest = load_manifest(self.root)

        external_temporary_directory = tempfile.TemporaryDirectory()
        self.addCleanup(external_temporary_directory.cleanup)
        external_docs = Path(external_temporary_directory.name) / "docs"
        external_canon = external_docs / "canon"
        external_nested = external_canon / "specifications"
        external_nested.mkdir(parents=True)
        (external_nested / "today.md").write_text(
            canonical_document("EXTERNAL"),
            encoding="utf-8",
        )
        docs = self.root / "docs"
        safe_docs = self.root / "safe-docs"
        resolved_canon_root = self.canon_root.resolve()
        real_open = os.open
        swapped = False

        def racing_open(path, flags, mode=0o777, *, dir_fd=None):
            nonlocal swapped
            if not swapped and (
                path == "docs" or Path(path) == resolved_canon_root
            ):
                swapped = True
                docs.rename(safe_docs)
                docs.symlink_to(external_docs, target_is_directory=True)
            return real_open(path, flags, mode, dir_fd=dir_fd)

        with mock.patch("os.open", side_effect=racing_open):
            self.assert_error_code(
                "CANON_MANIFEST_PATH_ESCAPE",
                lambda: load_documents(self.root, manifest),
            )
        self.assertTrue(swapped)

    def test_nested_directory_swap_to_external_symlink_at_open_is_rejected(self):
        nested = self.canon_root / "specifications"
        nested.mkdir()
        (nested / "today.md").write_text(
            canonical_document("SURFACE-TODAY"),
            encoding="utf-8",
        )
        outside = self.root / "external-specifications"
        outside.mkdir()
        (outside / "today.md").write_text(
            canonical_document("EXTERNAL"),
            encoding="utf-8",
        )
        self.write_manifest(
            manifest_text(normative_files=("specifications/today.md",))
        )
        manifest = load_manifest(self.root)
        real_open = os.open
        swapped = False

        def racing_open(path, flags, mode=0o777, *, dir_fd=None):
            nonlocal swapped
            if path == "specifications" and not swapped:
                swapped = True
                shutil.rmtree(nested)
                nested.symlink_to(outside, target_is_directory=True)
            return real_open(path, flags, mode, dir_fd=dir_fd)

        with mock.patch("os.open", side_effect=racing_open):
            self.assert_error_code(
                "CANON_MANIFEST_PATH_ESCAPE",
                lambda: load_documents(self.root, manifest),
            )
        self.assertTrue(swapped)

    def test_invalid_utf8_manifest_is_a_stable_canon_error(self):
        (self.canon_root / "MANIFEST.toml").write_bytes(b"\xff")

        try:
            load_manifest(self.root)
        except UnicodeDecodeError:
            self.fail("UnicodeDecodeError escaped the manifest boundary")
        except CanonError as error:
            self.assertEqual(error.code, "CANON_MANIFEST_READ")
            self.assertEqual(error.path, Path("docs/canon/MANIFEST.toml"))
        else:
            self.fail("invalid UTF-8 manifest was accepted")

    def test_invalid_utf8_normative_document_is_a_stable_canon_error(self):
        self.write_manifest(manifest_text(normative_files=("invalid.md",)))
        (self.canon_root / "invalid.md").write_bytes(b"\xff")
        manifest = load_manifest(self.root)

        try:
            load_documents(self.root, manifest)
        except UnicodeDecodeError:
            self.fail("UnicodeDecodeError escaped the document boundary")
        except CanonError as error:
            self.assertEqual(error.code, "CANON_MANIFEST_DOCUMENT_READ")
            self.assertEqual(error.path, Path("docs/canon/invalid.md"))
        else:
            self.fail("invalid UTF-8 normative document was accepted")

    def test_generated_and_normative_roles_are_distinct(self):
        cases = (
            manifest_text(normative_files=("generated/INDEX.md",)),
            manifest_text(generated_files=("specifications/today.md",)),
            manifest_text(
                normative_files=("CONSTITUTION.md",),
                generated_files=("CONSTITUTION.md",),
            ),
        )
        for text in cases:
            with self.subTest(text=text):
                self.write_manifest(text)
                self.assert_error_code(
                    "CANON_MANIFEST_PATH_ROLE",
                    lambda: load_manifest(self.root),
                )

    def test_repository_manifest_matches_the_shadow_constitution_contract(self):
        manifest = load_manifest(REPO_ROOT)

        self.assertEqual(manifest.schema_version, 1)
        self.assertEqual(manifest.canon_revision, 1)
        self.assertIs(manifest.authority_state, AuthorityState.SHADOW)
        self.assertEqual(manifest.compiler_version, "0.2.0")
        self.assertEqual(
            tuple(item.path for item in manifest.normative_files),
            (
                Path("CONSTITUTION.md"),
                Path("specifications/app/deep-linking.md"),
                Path("specifications/app/degraded-states.md"),
                Path("specifications/app/launch-and-setup.md"),
                Path("specifications/app/navigation.md"),
                Path("specifications/app/permissions.md"),
                Path("specifications/app/shell.md"),
                Path("specifications/global/capture.md"),
                Path("specifications/global/motion.md"),
                Path("specifications/global/search.md"),
                Path("specifications/global/trust-inspection.md"),
                Path("specifications/journeys/backup-restore-reset.md"),
                Path("specifications/journeys/capture-to-placement.md"),
                Path("specifications/journeys/closure-and-proof.md"),
                Path("specifications/journeys/external-calendar-import.md"),
                Path("specifications/journeys/goal-creation-and-activation.md"),
                Path("specifications/journeys/missed-work-recovery.md"),
                Path("specifications/journeys/schedule-reflow.md"),
                Path("specifications/journeys/search-find-act-inspect.md"),
                Path("specifications/journeys/start-and-complete-step.md"),
                Path("specifications/objects/attachment.md"),
                Path("specifications/objects/closure.md"),
                Path("specifications/objects/event.md"),
                Path("specifications/objects/goal-path.md"),
                Path("specifications/objects/goal.md"),
                Path("specifications/objects/history-event.md"),
                Path("specifications/objects/import-diff-record.md"),
                Path("specifications/objects/life-area.md"),
                Path("specifications/objects/note.md"),
                Path("specifications/objects/notification-rule.md"),
                Path("specifications/objects/proof.md"),
                Path("specifications/objects/receipt.md"),
                Path("specifications/objects/recovery-segment.md"),
                Path("specifications/objects/reminder.md"),
                Path("specifications/objects/saved-for-later-draft.md"),
                Path("specifications/objects/schedule-placement.md"),
                Path("specifications/objects/source-reference.md"),
                Path("specifications/objects/step.md"),
                Path("specifications/surfaces/goals.md"),
                Path("specifications/surfaces/time.md"),
                Path("specifications/surfaces/today.md"),
                Path("specifications/surfaces/you.md"),
                Path("specifications/systems/apple-ecosystem.md"),
                Path("specifications/systems/diagnostics.md"),
                Path("specifications/systems/import-export-repair.md"),
                Path("specifications/systems/local-learning.md"),
                Path("specifications/systems/notifications.md"),
                Path("specifications/systems/persistence-and-replay.md"),
                Path("specifications/systems/privacy-and-data-classification.md"),
                Path("specifications/systems/private-life-runtime.md"),
                Path("specifications/systems/scheduling-and-capacity.md"),
                Path("specifications/systems/source-atlas.md"),
                Path("specifications/systems/sync-and-continuity.md"),
                Path("standards/accessibility.md"),
                Path("standards/copy-and-state-language.md"),
                Path("standards/native-ios-engineering.md"),
                Path("standards/performance-and-energy.md"),
                Path("standards/security-and-privacy.md"),
                Path("standards/swiftui-and-design-system.md"),
                Path("standards/testing-and-fixtures.md"),
                Path("standards/validation-and-release.md"),
            ),
        )
        self.assertEqual(
            manifest.generated_files,
            tuple(Path(path) for path in GENERATED_FILES),
        )

        systems_root = REPO_ROOT / "docs/canon/specifications/systems"
        with self.subTest(task18_finding="I1-reviewed-egress-boundary"):
            privacy = (systems_root / "privacy-and-data-classification.md").read_text(
                encoding="utf-8"
            )
            egress = privacy.split("## SYSTEM-PRIVACY-EGRESS-001", 1)[1].split(
                "## Completeness contract", 1
            )[0]
            self.assertNotIn("every network/external boundary", egress)
            for hard_banned_destination in (
                "Ambitions backend",
                "Account service",
                "R2",
                "Source Atlas",
                "hosted AI/cloud model",
                "server profiler",
            ):
                self.assertIn(hard_banned_destination, egress)
            self.assertIn("user-controlled reviewed export", egress)
            self.assertIn("minimum fields", egress)
            self.assertIn("destination preview", egress)
            self.assertIn("Receipt/History", egress)
            self.assertIn("durable outbox/result", egress)

        with self.subTest(task18_finding="I2-widget-owner"):
            apple = (systems_root / "apple-ecosystem.md").read_text(encoding="utf-8")
            self.assertIn("Native/AmbitionsWidgetExtension/", apple)
            self.assertNotIn("Native/AmbitionsWidget/", apple)

        with self.subTest(task18_finding="I3-external-writes-owner"):
            runtime = (systems_root / "private-life-runtime.md").read_text(
                encoding="utf-8"
            )
            front_matter = runtime.split("+++", 2)[1]
            source_ownership = runtime.split(
                "<!-- canon-section: source-ownership -->", 1
            )[1].split("<!-- canon-section: tests-proof -->", 1)[0]
            self.assertIn(
                '"Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/"',
                front_matter,
            )
            self.assertIn("`ExternalWrites/`", source_ownership)

    def test_all_schema_documents_are_valid_closed_json_objects(self):
        schema_root = Path("docs/canon/schemas")
        for name in SCHEMAS:
            with self.subTest(name=name):
                schema = json.loads((schema_root / name).read_text(encoding="utf-8"))
                self.assertEqual(schema["type"], "object")
                self._assert_owned_objects_are_closed(schema)

    def test_specification_and_requirement_schemas_document_concept_grammar(self):
        expected = "^[a-z0-9]+(?:[.-][a-z0-9]+)*$"
        schema_root = REPO_ROOT / "docs/canon/schemas"
        specification = json.loads(
            (schema_root / "specification.schema.json").read_text(encoding="utf-8")
        )
        requirement = json.loads(
            (schema_root / "requirement.schema.json").read_text(encoding="utf-8")
        )

        self.assertEqual(
            specification["properties"]["owns_concepts"]["items"].get("pattern"),
            expected,
        )
        self.assertEqual(
            requirement["properties"]["concept"].get("pattern"),
            expected,
        )

    def _assert_owned_objects_are_closed(self, value) -> None:
        if isinstance(value, dict):
            if value.get("type") == "object" or "properties" in value:
                self.assertIs(value.get("additionalProperties"), False)
            for child in value.values():
                self._assert_owned_objects_are_closed(child)
        elif isinstance(value, list):
            for child in value:
                self._assert_owned_objects_are_closed(child)


if __name__ == "__main__":
    unittest.main()
