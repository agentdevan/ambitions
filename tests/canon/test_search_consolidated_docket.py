from __future__ import annotations

import hashlib
import inspect
import json
import os
import shutil
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from tests.canon.canon_test_support import copy_figma_reconciliation_evidence
from tools.ambitions_canon.model import CanonError
import tools.ambitions_canon.command_gate_dependencies as command_gates
import tools.ambitions_canon.ux_blueprint as ux_blueprint
import tools.ambitions_canon.visual_authority as visual_authority


ROOT = Path(__file__).resolve().parents[2]
BLUEPRINT_PATH = Path("docs/canon/migration/ux-blueprint.json")
MARKDOWN_PATH = Path("docs/canon/migration/UX_BLUEPRINT.md")
DISPOSITIONS_PATH = Path(
    "docs/canon/migration/ux-blueprint-requirement-dispositions.json"
)
COMMAND_RESOLUTION_PATH = Path(
    "docs/canon/registries/command-resolution-registry.json"
)
VISUAL_R1_PATH = Path(
    "docs/canon/migration/visual-authority-r1-node-snapshot.json"
)


class SearchConsolidatedDocketTests(unittest.TestCase):
    def _blueprint(self, root: Path = ROOT) -> dict[str, object]:
        return json.loads((root / BLUEPRINT_PATH).read_text(encoding="utf-8"))

    def _copy_complete_repository_inputs(self, destination: Path) -> None:
        shutil.copytree(ROOT / "docs/canon", destination / "docs/canon")
        copy_figma_reconciliation_evidence(ROOT, destination)

    def _projection_preimages(self, root: Path) -> dict[Path, bytes]:
        preimages = {
            MARKDOWN_PATH: b"prior markdown projection\n",
            DISPOSITIONS_PATH: b"prior disposition projection\n",
        }
        for relative, content in preimages.items():
            (root / relative).write_bytes(content)
        return preimages

    def _assert_projection_preimages(
        self, root: Path, preimages: dict[Path, bytes]
    ) -> None:
        for relative, expected in preimages.items():
            self.assertEqual((root / relative).read_bytes(), expected, relative)
        migration = root / "docs/canon/migration"
        leftovers = tuple(
            path.name
            for path in migration.iterdir()
            if "ux-blueprint" in path.name.casefold()
            and ("tmp" in path.name or "backup" in path.name)
        )
        self.assertEqual(leftovers, ())

    def test_active_truth_hierarchy_owns_find_ask_act_inspect_without_overclaim(self):
        design = (ROOT / "docs/truth/PRODUCT_DESIGN_TRUTH.md").read_text()
        moat = (ROOT / "docs/truth/PRODUCT_MOAT_TRUTH.md").read_text()
        experience = (ROOT / "docs/truth/PRODUCT_EXPERIENCE_CANON.md").read_text()
        decisions = (
            ROOT
            / "docs/truth/2026-06-22-runtime-remediation-decision-register.md"
        ).read_text()
        implementation = (ROOT / "docs/truth/IMPLEMENTATION_TRUTH.md").read_text()

        for source in (design, moat, experience, decisions):
            self.assertIn("Find / Ask / Act / Inspect", source)
        self.assertIn("optional on-device grounded Ask", design)
        self.assertIn("session-local", design)
        self.assertIn("Capture handoff", design)
        self.assertIn("object-led", design)
        self.assertIn("proposed-only", design)
        self.assertIn("deterministic", design)
        self.assertIn("offline", design)
        self.assertIn("future-gated", implementation)
        self.assertIn("eight visual gaps", implementation)
        self.assertIn("not production implementation proof", implementation)
        self.assertNotIn("Search is local Find / Act / Inspect", moat)
        self.assertNotIn("Search is local Find / Act / Inspect", experience)

    def test_public_apis_expose_no_constructible_context_or_raw_canon_sha(self):
        self.assertFalse(hasattr(ux_blueprint, "CanonSourceSnapshot"))
        self.assertFalse(hasattr(ux_blueprint, "capture_canon_source_snapshot"))
        self.assertFalse(hasattr(ux_blueprint, "verify_canon_source_snapshot"))
        for function in (
            ux_blueprint.load_requirement_source_records,
            ux_blueprint.load_state_command_contracts,
            ux_blueprint.build_requirement_dispositions,
            ux_blueprint.render_requirement_dispositions,
            ux_blueprint.validate_ux_blueprint,
            ux_blueprint.render_ux_blueprint_markdown,
            ux_blueprint.authority_eligible_state_variant_ids,
            visual_authority.validate_visual_authority_payload,
        ):
            self.assertNotIn("source_snapshot", inspect.signature(function).parameters)
        for function in (
            command_gates.load_command_gate_dependency_registry,
            command_gates.validate_command_gate_dependency_bindings,
        ):
            self.assertNotIn(
                "expected_canon_content_sha256",
                inspect.signature(function).parameters,
            )
        with self.assertRaises(TypeError):
            command_gates.load_command_gate_dependency_registry(
                ROOT,
                expected_canon_content_sha256="0" * 64,
            )

    def test_source_documents_reject_symlink_file_and_symlinked_ancestor(self):
        with tempfile.TemporaryDirectory() as temporary:
            base = Path(temporary)
            root = base / "repo"
            outside = base / "outside"
            root.mkdir()
            outside.mkdir()
            outside_file = outside / "source.md"
            outside_file.write_text("outside authority\n", encoding="utf-8")
            digest = hashlib.sha256(outside_file.read_bytes()).hexdigest()

            (root / "source.md").symlink_to(outside_file)
            with self.assertRaisesRegex(
                ux_blueprint.UXBlueprintError, "source document path is unsafe"
            ):
                ux_blueprint.validate_source_documents(
                    root, [{"path": "source.md", "sha256": digest}]
                )

            (root / "linked").symlink_to(outside, target_is_directory=True)
            with self.assertRaisesRegex(
                ux_blueprint.UXBlueprintError, "source document path is unsafe"
            ):
                ux_blueprint.validate_source_documents(
                    root, [{"path": "linked/source.md", "sha256": digest}]
                )

    def test_source_document_change_during_descriptor_read_fails_closed(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "source.md"
            original = b"approved source bytes\n"
            source.write_bytes(original)
            record = {
                "path": "source.md",
                "sha256": hashlib.sha256(original).hexdigest(),
            }
            original_read = os.read
            mutated = False

            def mutate_after_first_read(descriptor: int, count: int) -> bytes:
                nonlocal mutated
                result = original_read(descriptor, count)
                if not mutated:
                    source.write_bytes(b"changed during descriptor read\n")
                    mutated = True
                return result

            with mock.patch.object(ux_blueprint.os, "read", mutate_after_first_read):
                with self.assertRaisesRegex(
                    ux_blueprint.UXBlueprintError,
                    "source document changed during validation",
                ):
                    ux_blueprint.validate_source_documents(root, [record])
            self.assertTrue(mutated)

    def test_command_registry_change_during_validation_fails_closed(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_repository_inputs(root)
            registry_path = root / COMMAND_RESOLUTION_PATH
            payload = self._blueprint(root)
            mutated = False

            class RegistryMutatingBlueprint(dict):
                def __iter__(self):
                    nonlocal mutated
                    if not mutated:
                        registry_path.write_bytes(registry_path.read_bytes() + b"\n")
                        mutated = True
                    return super().__iter__()

            with self.assertRaisesRegex(
                (CanonError, ux_blueprint.UXBlueprintError),
                "changed during",
            ):
                ux_blueprint.validate_ux_blueprint(
                    root, RegistryMutatingBlueprint(payload)
                )
            self.assertTrue(mutated)

    def test_visual_r1_change_during_load_fails_closed(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_repository_inputs(root)
            r1_path = root / VISUAL_R1_PATH
            original_validator = visual_authority._validate_r1_node_snapshot
            mutated = False

            def mutate_after_validation(repo_root: Path, payload: dict[str, object]):
                nonlocal mutated
                result = original_validator(repo_root, payload)
                r1_path.write_bytes(r1_path.read_bytes() + b"\n")
                mutated = True
                return result

            with mock.patch.object(
                visual_authority,
                "_validate_r1_node_snapshot",
                mutate_after_validation,
            ):
                with self.assertRaisesRegex(CanonError, "changed during"):
                    visual_authority.load_visual_authority_rebaseline(root)
            self.assertTrue(mutated)

    def test_second_projection_replace_failure_restores_both_preimages(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_repository_inputs(root)
            preimages = self._projection_preimages(root)
            original_replace = os.replace
            installs = 0

            def fail_second_install(source, destination, *args, **kwargs):
                nonlocal installs
                source_name = Path(os.fspath(source)).name
                destination_name = Path(os.fspath(destination)).name
                if (
                    destination_name in {path.name for path in preimages}
                    and source_name.endswith(".tmp")
                ):
                    installs += 1
                    if installs == 2:
                        raise OSError("deterministic second replace failure")
                return original_replace(source, destination, *args, **kwargs)

            with mock.patch.object(ux_blueprint.os, "replace", fail_second_install):
                with self.assertRaises((CanonError, OSError)):
                    ux_blueprint.write_ux_blueprint_projection(root)
            self.assertEqual(installs, 2)
            self._assert_projection_preimages(root, preimages)

    def test_projection_fsync_failure_restores_both_preimages(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_repository_inputs(root)
            preimages = self._projection_preimages(root)
            original_fsync = os.fsync
            injected = False

            def fail_after_install(descriptor: int) -> None:
                nonlocal injected
                current = {}
                for relative in preimages:
                    try:
                        current[relative] = (root / relative).read_bytes()
                    except FileNotFoundError:
                        current[relative] = None
                if not injected and current != preimages:
                    injected = True
                    raise OSError("deterministic projection fsync failure")
                original_fsync(descriptor)

            with mock.patch.object(ux_blueprint.os, "fsync", fail_after_install):
                with self.assertRaises((CanonError, OSError)):
                    ux_blueprint.write_ux_blueprint_projection(root)
            self.assertTrue(injected)
            self._assert_projection_preimages(root, preimages)

    def test_final_freshness_failure_rolls_back_both_projections(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_repository_inputs(root)
            preimages = self._projection_preimages(root)
            original_replace = os.replace
            installs = 0
            source = root / "docs/canon/specifications/global/search.md"

            def mutate_after_second_install(source_path, destination, *args, **kwargs):
                nonlocal installs
                result = original_replace(source_path, destination, *args, **kwargs)
                source_name = Path(os.fspath(source_path)).name
                destination_name = Path(os.fspath(destination)).name
                if (
                    destination_name in {path.name for path in preimages}
                    and source_name.endswith(".tmp")
                ):
                    installs += 1
                    if installs == 2:
                        source.write_bytes(source.read_bytes() + b"\n")
                return result

            with mock.patch.object(
                ux_blueprint.os, "replace", mutate_after_second_install
            ):
                with self.assertRaises((CanonError, ux_blueprint.UXBlueprintError)):
                    ux_blueprint.write_ux_blueprint_projection(root)
            self.assertEqual(installs, 2)
            self._assert_projection_preimages(root, preimages)

    def test_eligibility_returns_false_and_empty_on_canon_error(self):
        blueprint = self._blueprint()
        variant_id = "UX-STATE-VARIANT-TODAY-ROOT-LOW-DENSITY"
        with tempfile.TemporaryDirectory() as temporary:
            missing_repo = Path(temporary)
            self.assertEqual(
                ux_blueprint.authority_eligible_state_variant_ids(
                    blueprint, missing_repo
                ),
                frozenset(),
            )
            self.assertFalse(
                ux_blueprint.state_variant_is_authority_eligible(
                    blueprint, variant_id, missing_repo
                )
            )

    def test_visual_hand_record_reports_mapped_and_gap_blocked_counts_honestly(self):
        hand_record = (
            ROOT / "docs/canon/migration/VISUAL_AUTHORITY_REBASELINE.md"
        ).read_text(encoding="utf-8")
        self.assertIn(
            "Visual requirements: `335` mapped + `11` gap-blocked = `346` classified",
            hand_record,
        )
        self.assertIn(
            "State variants: `433` mapped + `8` gap-blocked = `441` classified",
            hand_record,
        )
        self.assertNotIn("Visual requirements mapped: `346/346`", hand_record)
        self.assertNotIn("State mappings: `441/441`", hand_record)


if __name__ == "__main__":
    unittest.main()
