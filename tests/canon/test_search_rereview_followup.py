from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import threading
import unittest
from contextlib import contextmanager
from pathlib import Path
from unittest import mock

from tests.canon.canon_test_support import copy_figma_reconciliation_evidence
from tools.ambitions_canon.model import CanonError
import tools.ambitions_canon.build as canon_build
import tools.ambitions_canon.command_gate_dependencies as command_gates
import tools.ambitions_canon.ux_blueprint as ux_blueprint
import tools.ambitions_canon.visual_authority as visual_authority


ROOT = Path(__file__).resolve().parents[2]
BLUEPRINT_PATH = Path("docs/canon/migration/ux-blueprint.json")
PLATFORM_ATLAS_PATH = Path("docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md")
MARKDOWN_PATH = Path("docs/canon/migration/UX_BLUEPRINT.md")
DISPOSITIONS_PATH = Path(
    "docs/canon/migration/ux-blueprint-requirement-dispositions.json"
)


class SearchRereviewFollowupTests(unittest.TestCase):
    def _copy_complete_inputs(self, destination: Path) -> None:
        shutil.copytree(ROOT / "docs/canon", destination / "docs/canon")
        (destination / "docs/platform").mkdir(parents=True)
        shutil.copy2(
            ROOT / PLATFORM_ATLAS_PATH,
            destination / PLATFORM_ATLAS_PATH,
        )
        shutil.copytree(
            ROOT / "tests/canon/fixtures",
            destination / "tests/canon/fixtures",
        )
        copy_figma_reconciliation_evidence(ROOT, destination)

    def _preimages(self, root: Path) -> dict[Path, bytes]:
        result = {
            MARKDOWN_PATH: b"coherent old markdown\n",
            DISPOSITIONS_PATH: b"coherent old dispositions\n",
        }
        for path, content in result.items():
            (root / path).write_bytes(content)
        return result

    def _projection_preimages_with_identity(
        self, root: Path
    ) -> dict[Path, tuple[bytes, tuple[int, int]]]:
        return {
            path: (
                content,
                ((info := os.stat(root / path)).st_dev, info.st_ino),
            )
            for path, content in self._preimages(root).items()
        }

    def _assert_projection_preimages_restored(
        self,
        root: Path,
        preimages: dict[Path, tuple[bytes, tuple[int, int]]],
    ) -> None:
        for path, (content, identity) in preimages.items():
            info = os.stat(root / path)
            self.assertEqual((root / path).read_bytes(), content)
            self.assertEqual((info.st_dev, info.st_ino), identity)

    def _projection_state_with_identity(
        self, root: Path
    ) -> dict[Path, tuple[bytes, tuple[int, int]]]:
        return {
            path: (
                (root / path).read_bytes(),
                ((info := os.stat(root / path)).st_dev, info.st_ino),
            )
            for path in (MARKDOWN_PATH, DISPOSITIONS_PATH)
        }

    def _transaction_artifacts(self, root: Path) -> tuple[Path, ...]:
        migration = root / MARKDOWN_PATH.parent
        suffixes = (
            ".tmp",
            ".backup",
            ".recovery",
            ".prepared-cleanup.json",
            ".committed-cleanup.json",
        )
        return tuple(
            sorted(
                (
                    path
                    for path in migration.iterdir()
                    if path.name.startswith(".")
                    and path.name.endswith(suffixes)
                ),
                key=lambda path: path.name,
            )
        )

    def _leave_committed_cleanup_evidence(self, root: Path) -> tuple[Path, ...]:
        original_unlink = ux_blueprint.os.unlink
        failed = False

        def fail_one_recovery_cleanup(path, *args, **kwargs):
            nonlocal failed
            if not failed and os.fspath(path).endswith(".recovery"):
                failed = True
                raise OSError("postcommit recovery cleanup failed")
            return original_unlink(path, *args, **kwargs)

        with mock.patch.object(
            ux_blueprint.os,
            "unlink",
            side_effect=fail_one_recovery_cleanup,
        ):
            summary = ux_blueprint.write_ux_blueprint_projection(root)
        self.assertTrue(failed)
        self.assertEqual(summary.state_variant_count, 441)
        retained = self._transaction_artifacts(root)
        self.assertTrue(
            any(
                path.name.endswith(".committed-cleanup.json")
                for path in retained
            )
        )
        self.assertFalse(
            any(
                path.name.endswith(".prepared-cleanup.json")
                for path in retained
            )
        )
        self.assertTrue(any(path.name.endswith(".recovery") for path in retained))
        return retained

    def test_operation_context_captures_external_sources_and_downstream_uses_bytes(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_inputs(root)
            with ux_blueprint._ux_operation(
                root, include_visual_evidence=True
            ) as context:
                captured = {item.path: item for item in context.inputs}
                self.assertIn(PLATFORM_ATLAS_PATH, captured)
                self.assertEqual(
                    captured[PLATFORM_ATLAS_PATH].content,
                    (root / PLATFORM_ATLAS_PATH).read_bytes(),
                )
                self.assertEqual(len(captured[PLATFORM_ATLAS_PATH].identity), 5)
                with (
                    mock.patch.object(
                        Path,
                        "read_bytes",
                        side_effect=AssertionError("downstream path reopen"),
                    ),
                    mock.patch.object(
                        Path,
                        "read_text",
                        side_effect=AssertionError("downstream path reopen"),
                    ),
                ):
                    self.assertEqual(
                        ux_blueprint.load_ux_blueprint(root)["schema_version"], 1
                    )
                    self.assertEqual(
                        ux_blueprint.load_state_inventory(root)["schema_version"],
                        1,
                    )
                    self.assertEqual(
                        ux_blueprint.validate_ux_blueprint(
                            root, ux_blueprint.load_ux_blueprint(root)
                        ).state_variant_count,
                        441,
                    )
                    self.assertTrue(context.command_resolution_registry.records)
                    self.assertEqual(
                        visual_authority._read_regular_nofollow(
                            root,
                            visual_authority.R1_NODE_SNAPSHOT_PATH,
                        ),
                        captured[
                            visual_authority.R1_NODE_SNAPSHOT_PATH
                        ].content,
                    )

    def test_public_command_gate_rejects_stale_and_mid_operation_live_bytes(self):
        for mutation_phase in ("before", "during"):
            with self.subTest(mutation_phase=mutation_phase):
                with tempfile.TemporaryDirectory() as temporary:
                    root = Path(temporary)
                    self._copy_complete_inputs(root)
                    registry = command_gates.load_command_gate_dependency_registry(
                        root, expected_canon_revision=1
                    )
                    contracts = ux_blueprint.load_state_command_contracts(root)
                    owner_path = (
                        root / command_gates.OWNER_APPROVAL_REGISTRY_PATH
                    )
                    original_validator = (
                        command_gates._validate_command_gate_dependency_bindings_for_audited_canon
                    )

                    if mutation_phase == "before":
                        owner_path.write_bytes(owner_path.read_bytes() + b"\n")
                        patcher = mock.patch.object(
                            command_gates,
                            "_validate_command_gate_dependency_bindings_for_audited_canon",
                            wraps=original_validator,
                        )
                    else:
                        def mutate_during(*args, **kwargs):
                            result = original_validator(*args, **kwargs)
                            owner_path.write_bytes(owner_path.read_bytes() + b"\n")
                            return result

                        patcher = mock.patch.object(
                            command_gates,
                            "_validate_command_gate_dependency_bindings_for_audited_canon",
                            side_effect=mutate_during,
                        )
                    with patcher:
                        with self.assertRaisesRegex(
                            CanonError, "live command-gate|changed during"
                        ):
                            command_gates.validate_command_gate_dependency_bindings(
                                registry,
                                contracts,
                                canon_revision=1,
                            )

    def test_projection_readers_block_until_one_generation_is_committed(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_inputs(root)
            self._preimages(root)
            first_install = threading.Event()
            release_writer = threading.Event()
            pair_finished = threading.Event()
            disposition_finished = threading.Event()
            operation_finished = threading.Event()
            readers_waiting = threading.Event()
            reader_lock_attempts = 0
            reader_lock_guard = threading.Lock()
            results: dict[str, object] = {}
            original_replace = os.replace
            original_flock = ux_blueprint.fcntl.flock
            installs = 0

            def pausing_replace(source, destination, *args, **kwargs):
                nonlocal installs
                result = original_replace(source, destination, *args, **kwargs)
                if (
                    Path(os.fspath(source)).name.endswith(".tmp")
                    and Path(os.fspath(destination)).name
                    in {MARKDOWN_PATH.name, DISPOSITIONS_PATH.name}
                ):
                    installs += 1
                    if installs == 1:
                        first_install.set()
                        if not release_writer.wait(5):
                            raise TimeoutError("reader coordination test timed out")
                return result

            def tracking_flock(descriptor, operation):
                nonlocal reader_lock_attempts
                if operation == ux_blueprint.fcntl.LOCK_SH:
                    with reader_lock_guard:
                        reader_lock_attempts += 1
                        if reader_lock_attempts == 3:
                            readers_waiting.set()
                return original_flock(descriptor, operation)

            def write() -> None:
                try:
                    ux_blueprint.write_ux_blueprint_projection(root)
                except BaseException as error:
                    results["writer_error"] = error

            def read_pair() -> None:
                try:
                    results["pair"] = ux_blueprint._read_projection_pair(root)
                except BaseException as error:
                    results["pair_error"] = error
                finally:
                    pair_finished.set()

            def read_disposition() -> None:
                try:
                    results["disposition"] = (
                        visual_authority._read_regular_nofollow(
                            root, DISPOSITIONS_PATH
                        )
                    )
                except BaseException as error:
                    results["disposition_error"] = error
                finally:
                    disposition_finished.set()

            def read_operation_context() -> None:
                try:
                    with ux_blueprint._ux_operation(root) as context:
                        results["operation_disposition"] = {
                            item.path: item.content for item in context.inputs
                        }[DISPOSITIONS_PATH]
                except BaseException as error:
                    results["operation_error"] = error
                finally:
                    operation_finished.set()

            with (
                mock.patch.object(
                    ux_blueprint.os, "replace", pausing_replace
                ),
                mock.patch.object(
                    ux_blueprint.fcntl, "flock", tracking_flock
                ),
            ):
                writer = threading.Thread(target=write)
                writer.start()
                self.assertTrue(first_install.wait(5))
                pair_reader = threading.Thread(target=read_pair)
                disposition_reader = threading.Thread(target=read_disposition)
                operation_reader = threading.Thread(target=read_operation_context)
                pair_reader.start()
                disposition_reader.start()
                operation_reader.start()
                self.assertTrue(readers_waiting.wait(5))
                self.assertFalse(pair_finished.is_set())
                self.assertFalse(disposition_finished.is_set())
                self.assertFalse(operation_finished.is_set())
                release_writer.set()
                writer.join(10)
                pair_reader.join(10)
                disposition_reader.join(10)
                operation_reader.join(10)

            self.assertNotIn("writer_error", results)
            self.assertNotIn("pair_error", results)
            self.assertNotIn("disposition_error", results)
            self.assertNotIn("operation_error", results)
            markdown = (root / MARKDOWN_PATH).read_bytes()
            dispositions = (root / DISPOSITIONS_PATH).read_bytes()
            self.assertEqual(results["pair"], (markdown, dispositions))
            self.assertEqual(results["disposition"], dispositions)
            self.assertEqual(results["operation_disposition"], dispositions)

    def test_projection_backup_collision_preserves_targets_and_collision(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_inputs(root)
            preimages = self._preimages(root)
            collision = (
                root
                / MARKDOWN_PATH.parent
                / f".{MARKDOWN_PATH.name}.collision.backup"
            )
            collision.write_bytes(b"unowned collision evidence\n")
            with mock.patch.object(
                ux_blueprint.secrets, "token_hex", return_value="collision"
            ):
                with self.assertRaises((CanonError, ux_blueprint.UXBlueprintError)):
                    ux_blueprint.write_ux_blueprint_projection(root)
            for path, content in preimages.items():
                self.assertEqual((root / path).read_bytes(), content)
            self.assertEqual(collision.read_bytes(), b"unowned collision evidence\n")

    def test_projection_final_marker_collision_is_preserved_and_rolls_back(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_inputs(root)
            preimages = self._projection_preimages_with_identity(root)
            token = "a1" * 8
            collision = (
                root
                / MARKDOWN_PATH.parent
                / f".{token}.committed-cleanup.json"
            )
            collision.write_bytes(b"unowned final-marker collision\n")
            collision_identity = (
                (info := collision.stat()).st_dev,
                info.st_ino,
            )

            with mock.patch.object(
                ux_blueprint.secrets, "token_hex", return_value=token
            ):
                with self.assertRaises(
                    (CanonError, ux_blueprint.UXBlueprintError, OSError)
                ):
                    ux_blueprint.write_ux_blueprint_projection(root)

            self._assert_projection_preimages_restored(root, preimages)
            self.assertEqual(
                collision.read_bytes(), b"unowned final-marker collision\n"
            )
            info = collision.stat()
            self.assertEqual((info.st_dev, info.st_ino), collision_identity)
            self.assertEqual(self._transaction_artifacts(root), (collision,))

    def test_projection_final_marker_publication_failures_roll_back(self):
        for failure in ("create", "fsync"):
            with self.subTest(failure=failure):
                with tempfile.TemporaryDirectory() as temporary:
                    root = Path(temporary)
                    self._copy_complete_inputs(root)
                    preimages = self._projection_preimages_with_identity(root)
                    token = ("b2" if failure == "create" else "c3") * 8
                    final_name = f".{token}.committed-cleanup.json"
                    original_open = ux_blueprint.os.open
                    original_fsync = ux_blueprint.os.fsync
                    marker_descriptors: set[int] = set()
                    failed = False

                    def controlled_open(path, *args, **kwargs):
                        nonlocal failed
                        if os.fspath(path) == final_name and failure == "create":
                            failed = True
                            raise OSError("final marker creation failed")
                        descriptor = original_open(path, *args, **kwargs)
                        if os.fspath(path) == final_name:
                            marker_descriptors.add(descriptor)
                        return descriptor

                    def controlled_fsync(descriptor):
                        nonlocal failed
                        if (
                            failure == "fsync"
                            and not failed
                            and descriptor in marker_descriptors
                        ):
                            failed = True
                            raise OSError("final marker fsync failed")
                        return original_fsync(descriptor)

                    with (
                        mock.patch.object(
                            ux_blueprint.secrets,
                            "token_hex",
                            return_value=token,
                        ),
                        mock.patch.object(
                            ux_blueprint.os,
                            "open",
                            side_effect=controlled_open,
                        ),
                        mock.patch.object(
                            ux_blueprint.os,
                            "fsync",
                            side_effect=controlled_fsync,
                        ),
                    ):
                        with self.assertRaises(
                            (CanonError, ux_blueprint.UXBlueprintError, OSError)
                        ):
                            ux_blueprint.write_ux_blueprint_projection(root)

                    self.assertTrue(failed)
                    self._assert_projection_preimages_restored(root, preimages)
                    artifacts = self._transaction_artifacts(root)
                    if failure == "create":
                        self.assertEqual(artifacts, ())
                    else:
                        self.assertEqual(len(artifacts), 1)
                        self.assertEqual(artifacts[0].name, final_name)

    def test_marker_failure_cleanup_preserves_path_without_live_unlink(self):
        with tempfile.TemporaryDirectory() as temporary:
            parent = Path(temporary)
            marker_name = f".{('e5' * 8)}.committed-cleanup.json"
            marker_path = parent / marker_name
            parent_descriptor = os.open(
                parent, os.O_RDONLY | os.O_DIRECTORY
            )
            original_open = ux_blueprint.os.open
            original_fsync = ux_blueprint.os.fsync
            original_entry_identity = ux_blueprint._entry_identity_at
            original_unlink = ux_blueprint.os.unlink
            marker_descriptor: int | None = None
            publication_failed = False
            entry_checks: list[str] = []
            unlinks: list[str] = []

            def tracking_open(path, *args, **kwargs):
                nonlocal marker_descriptor
                descriptor = original_open(path, *args, **kwargs)
                if os.fspath(path) == marker_name:
                    marker_descriptor = descriptor
                return descriptor

            def fail_publication_fsync(descriptor):
                nonlocal publication_failed
                if descriptor == marker_descriptor and not publication_failed:
                    publication_failed = True
                    raise OSError("original marker publication failure")
                return original_fsync(descriptor)

            def tracking_entry_identity(descriptor, name):
                if publication_failed and name == marker_name:
                    entry_checks.append(name)
                return original_entry_identity(descriptor, name)

            def tracking_unlink(path, *args, **kwargs):
                unlinks.append(os.fspath(path))
                return original_unlink(path, *args, **kwargs)

            try:
                with (
                    mock.patch.object(
                        ux_blueprint.os,
                        "open",
                        side_effect=tracking_open,
                    ),
                    mock.patch.object(
                        ux_blueprint.os,
                        "fsync",
                        side_effect=fail_publication_fsync,
                    ),
                    mock.patch.object(
                        ux_blueprint,
                        "_entry_identity_at",
                        side_effect=tracking_entry_identity,
                    ),
                    mock.patch.object(
                        ux_blueprint.os,
                        "unlink",
                        side_effect=tracking_unlink,
                    ),
                ):
                    with self.assertRaisesRegex(
                        OSError, "original marker publication failure"
                    ) as raised:
                        ux_blueprint._publish_committed_cleanup_record_at(
                            parent_descriptor,
                            marker_name,
                            b"owned marker bytes\n",
                        )
                self.assertTrue(marker_path.exists())
                self.assertEqual(entry_checks, [])
                self.assertEqual(unlinks, [])
                self.assertIn(
                    "pathname preserved",
                    "\n".join(getattr(raised.exception, "__notes__", ())),
                )
            finally:
                os.close(parent_descriptor)

    def test_marker_failure_cleanup_closes_without_pathname_unlink(self):
        with tempfile.TemporaryDirectory() as temporary:
            parent = Path(temporary)
            marker_name = f".{('f6' * 8)}.committed-cleanup.json"
            marker_path = parent / marker_name
            parent_descriptor = os.open(
                parent, os.O_RDONLY | os.O_DIRECTORY
            )
            original_open = ux_blueprint.os.open
            original_fsync = ux_blueprint.os.fsync
            original_close = ux_blueprint.os.close
            original_unlink = ux_blueprint.os.unlink
            marker_descriptor: int | None = None
            marker_descriptor_open = False
            publication_failed = False
            events: list[tuple[str, bool]] = []

            def tracking_open(path, *args, **kwargs):
                nonlocal marker_descriptor, marker_descriptor_open
                descriptor = original_open(path, *args, **kwargs)
                if os.fspath(path) == marker_name:
                    marker_descriptor = descriptor
                    marker_descriptor_open = True
                return descriptor

            def fail_publication_fsync(descriptor):
                nonlocal publication_failed
                if descriptor == marker_descriptor and not publication_failed:
                    publication_failed = True
                    raise OSError("original marker publication failure")
                return original_fsync(descriptor)

            def tracking_close(descriptor):
                nonlocal marker_descriptor_open
                if descriptor == marker_descriptor:
                    events.append(("close", marker_descriptor_open))
                    marker_descriptor_open = False
                return original_close(descriptor)

            def tracking_unlink(path, *args, **kwargs):
                if os.fspath(path) == marker_name:
                    events.append(("unlink", marker_descriptor_open))
                return original_unlink(path, *args, **kwargs)

            try:
                with (
                    mock.patch.object(
                        ux_blueprint.os,
                        "open",
                        side_effect=tracking_open,
                    ),
                    mock.patch.object(
                        ux_blueprint.os,
                        "fsync",
                        side_effect=fail_publication_fsync,
                    ),
                    mock.patch.object(
                        ux_blueprint.os,
                        "close",
                        side_effect=tracking_close,
                    ),
                    mock.patch.object(
                        ux_blueprint.os,
                        "unlink",
                        side_effect=tracking_unlink,
                    ),
                ):
                    with self.assertRaisesRegex(
                        OSError, "original marker publication failure"
                    ):
                        ux_blueprint._publish_committed_cleanup_record_at(
                            parent_descriptor,
                            marker_name,
                            b"owned marker bytes\n",
                        )
                self.assertTrue(marker_path.exists())
                self.assertEqual(
                    events,
                    [("close", True)],
                )
            finally:
                os.close(parent_descriptor)

    def test_marker_failure_cleanup_errors_preserve_original_failure(self):
        for cleanup_failure in ("fstat", "close"):
            with self.subTest(cleanup_failure=cleanup_failure):
                with tempfile.TemporaryDirectory() as temporary:
                    parent = Path(temporary)
                    marker_name = (
                        f".{('a7' if cleanup_failure == 'fstat' else 'b8') * 8}"
                        ".committed-cleanup.json"
                    )
                    marker_path = parent / marker_name
                    parent_descriptor = os.open(
                        parent, os.O_RDONLY | os.O_DIRECTORY
                    )
                    original_open = ux_blueprint.os.open
                    original_fsync = ux_blueprint.os.fsync
                    original_fstat = ux_blueprint.os.fstat
                    original_close = ux_blueprint.os.close
                    marker_descriptor: int | None = None
                    publication_failed = False
                    cleanup_failure_reached = False

                    def tracking_open(path, *args, **kwargs):
                        nonlocal marker_descriptor
                        descriptor = original_open(path, *args, **kwargs)
                        if os.fspath(path) == marker_name:
                            marker_descriptor = descriptor
                        return descriptor

                    def fail_publication_fsync(descriptor):
                        nonlocal publication_failed
                        if (
                            descriptor == marker_descriptor
                            and not publication_failed
                        ):
                            publication_failed = True
                            raise OSError(
                                "original marker publication failure"
                            )
                        return original_fsync(descriptor)

                    def controlled_fstat(descriptor):
                        nonlocal cleanup_failure_reached
                        if (
                            cleanup_failure == "fstat"
                            and publication_failed
                            and descriptor == marker_descriptor
                            and not cleanup_failure_reached
                        ):
                            cleanup_failure_reached = True
                            raise OSError("cleanup fstat failed")
                        return original_fstat(descriptor)

                    def controlled_close(descriptor):
                        nonlocal cleanup_failure_reached
                        if (
                            cleanup_failure == "close"
                            and publication_failed
                            and descriptor == marker_descriptor
                            and not cleanup_failure_reached
                        ):
                            cleanup_failure_reached = True
                            raise OSError("cleanup close failed")
                        return original_close(descriptor)

                    try:
                        with (
                            mock.patch.object(
                                ux_blueprint.os,
                                "open",
                                side_effect=tracking_open,
                            ),
                            mock.patch.object(
                                ux_blueprint.os,
                                "fsync",
                                side_effect=fail_publication_fsync,
                            ),
                            mock.patch.object(
                                ux_blueprint.os,
                                "fstat",
                                side_effect=controlled_fstat,
                            ),
                            mock.patch.object(
                                ux_blueprint.os,
                                "close",
                                side_effect=controlled_close,
                            ),
                        ):
                            with self.assertRaisesRegex(
                                OSError,
                                "original marker publication failure",
                            ) as raised:
                                ux_blueprint._publish_committed_cleanup_record_at(
                                    parent_descriptor,
                                    marker_name,
                                    b"owned marker bytes\n",
                                )
                        self.assertTrue(cleanup_failure_reached)
                        self.assertTrue(marker_path.exists())
                        self.assertIn(
                            "cleanup",
                            "\n".join(
                                getattr(raised.exception, "__notes__", ())
                            ),
                        )
                    finally:
                        if marker_descriptor is not None:
                            try:
                                original_close(marker_descriptor)
                            except OSError:
                                pass
                        os.close(parent_descriptor)

    def test_publication_error_never_authorizes_pathname_unlink(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_inputs(root)
            preimages = self._projection_preimages_with_identity(root)
            token = "c9" * 8
            marker_name = f".{token}.committed-cleanup.json"
            marker_path = root / MARKDOWN_PATH.parent / marker_name
            replacement = root / "replacement-marker-evidence"
            replacement.write_bytes(b"concurrent replacement evidence\n")
            original_open = ux_blueprint.os.open
            original_fsync = ux_blueprint.os.fsync
            original_unlink = ux_blueprint.os.unlink
            original_replace = ux_blueprint.os.replace
            original_unlink_regular = (
                ux_blueprint._unlink_regular_if_present
            )
            marker_descriptor: int | None = None
            publication_failed = False
            marker_unlink_helper_calls = 0
            substituted = False

            def tracking_open(path, *args, **kwargs):
                nonlocal marker_descriptor
                descriptor = original_open(path, *args, **kwargs)
                if os.fspath(path) == marker_name:
                    marker_descriptor = descriptor
                return descriptor

            def fail_publication_fsync(descriptor):
                nonlocal publication_failed
                if descriptor == marker_descriptor and not publication_failed:
                    publication_failed = True
                    raise OSError("original marker publication failure")
                return original_fsync(descriptor)

            def race_at_unlink(path, *args, **kwargs):
                nonlocal substituted
                if os.fspath(path) == marker_name and not substituted:
                    original_replace(replacement, marker_path)
                    substituted = True
                return original_unlink(path, *args, **kwargs)

            def instrument_unlink_helper(
                parent_descriptor,
                name,
                *,
                expected_identity=None,
            ):
                nonlocal marker_unlink_helper_calls
                if name != marker_name:
                    return original_unlink_regular(
                        parent_descriptor,
                        name,
                        expected_identity=expected_identity,
                    )
                marker_unlink_helper_calls += 1
                with mock.patch.object(
                    ux_blueprint.os,
                    "unlink",
                    side_effect=race_at_unlink,
                ):
                    return original_unlink_regular(
                        parent_descriptor,
                        name,
                        expected_identity=expected_identity,
                    )

            with (
                mock.patch.object(
                    ux_blueprint.secrets,
                    "token_hex",
                    return_value=token,
                ),
                mock.patch.object(
                    ux_blueprint.os,
                    "open",
                    side_effect=tracking_open,
                ),
                mock.patch.object(
                    ux_blueprint.os,
                    "fsync",
                    side_effect=fail_publication_fsync,
                ),
                mock.patch.object(
                    ux_blueprint,
                    "_unlink_regular_if_present",
                    side_effect=instrument_unlink_helper,
                ),
            ):
                with self.assertRaises(CanonError) as raised:
                    ux_blueprint.write_ux_blueprint_projection(root)

            self.assertTrue(publication_failed)
            self._assert_projection_preimages_restored(root, preimages)
            self.assertEqual(marker_unlink_helper_calls, 0)
            self.assertFalse(substituted)
            self.assertTrue(marker_path.exists())
            self.assertEqual(
                replacement.read_bytes(),
                b"concurrent replacement evidence\n",
            )
            causes: list[BaseException] = []
            cause: BaseException | None = raised.exception
            while cause is not None and cause not in causes:
                causes.append(cause)
                cause = cause.__cause__
            self.assertTrue(
                any(
                    "original marker publication failure" in str(item)
                    for item in causes
                )
            )
            self.assertTrue(
                any(
                    "pathname preserved"
                    in "\n".join(getattr(item, "__notes__", ()))
                    for item in causes
                )
            )
            marker_content = marker_path.read_bytes()
            marker_identity = (
                (info := marker_path.stat()).st_dev,
                info.st_ino,
            )

            summary = ux_blueprint.write_ux_blueprint_projection(root)
            self.assertEqual(summary.state_variant_count, 441)
            info = marker_path.stat()
            self.assertEqual(marker_path.read_bytes(), marker_content)
            self.assertEqual((info.st_dev, info.st_ino), marker_identity)
            self.assertEqual(
                replacement.read_bytes(),
                b"concurrent replacement evidence\n",
            )

    def test_projection_rollback_never_deletes_substituted_identity(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_inputs(root)
            self._preimages(root)
            migration = root / MARKDOWN_PATH.parent
            attacker = root / "attacker"
            attacker.write_bytes(b"attacker-owned inode\n")
            first_target: Path | None = None
            original_replace = os.replace
            installs = 0

            def substitute_then_fail(source, destination, *args, **kwargs):
                nonlocal installs, first_target
                source_name = Path(os.fspath(source)).name
                destination_name = Path(os.fspath(destination)).name
                if (
                    source_name.endswith(".tmp")
                    and destination_name
                    in {MARKDOWN_PATH.name, DISPOSITIONS_PATH.name}
                ):
                    installs += 1
                    if installs == 2:
                        assert first_target is not None
                        original_replace(attacker, first_target)
                        raise OSError("second install failed after substitution")
                    result = original_replace(source, destination, *args, **kwargs)
                    first_target = migration / destination_name
                    return result
                return original_replace(source, destination, *args, **kwargs)

            with mock.patch.object(
                ux_blueprint.os, "replace", substitute_then_fail
            ):
                with self.assertRaisesRegex(
                    CanonError, "rollback could not be verified"
                ):
                    ux_blueprint.write_ux_blueprint_projection(root)
            assert first_target is not None
            self.assertEqual(first_target.read_bytes(), b"attacker-owned inode\n")
            evidence = {
                path: (
                    path.read_bytes(),
                    ((info := path.stat()).st_dev, info.st_ino),
                )
                for path in self._transaction_artifacts(root)
            }
            self.assertTrue(
                any(path.name.endswith(".backup") for path in evidence)
            )
            ux_blueprint.write_ux_blueprint_projection(root)
            for path, (content, identity) in evidence.items():
                info = path.stat()
                self.assertEqual(path.read_bytes(), content)
                self.assertEqual((info.st_dev, info.st_ino), identity)

    def test_projection_precommit_context_failure_restores_exact_preimages(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_inputs(root)
            preimages = self._projection_preimages_with_identity(root)
            source = root / PLATFORM_ATLAS_PATH
            original_verify = ux_blueprint._verify_operation_context
            installed_checks = 0

            def mutate_before_final_commit_check(
                context, *, projection_locked=False
            ):
                nonlocal installed_checks
                if projection_locked:
                    installed_checks += 1
                    if installed_checks == 1:
                        source.write_bytes(
                            source.read_bytes() + b"\nprecommit mutation\n"
                        )
                return original_verify(
                    context, projection_locked=projection_locked
                )

            with mock.patch.object(
                ux_blueprint,
                "_verify_operation_context",
                side_effect=mutate_before_final_commit_check,
            ):
                with self.assertRaises((CanonError, ux_blueprint.UXBlueprintError)):
                    ux_blueprint.write_ux_blueprint_projection(root)
            self.assertEqual(installed_checks, 1)
            self._assert_projection_preimages_restored(root, preimages)

    def test_projection_ordinary_success_leaves_no_transaction_artifacts(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_inputs(root)
            self._preimages(root)
            summary = ux_blueprint.write_ux_blueprint_projection(root)
            self.assertEqual(summary.state_variant_count, 441)
            self.assertEqual(self._transaction_artifacts(root), ())

    def test_projection_postcommit_mutation_during_cleanup_remains_committed(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_inputs(root)
            preimages = self._preimages(root)
            source = root / PLATFORM_ATLAS_PATH
            original_unlink = ux_blueprint.os.unlink
            mutated = False

            def mutate_during_cleanup(path, *args, **kwargs):
                nonlocal mutated
                if not mutated and os.fspath(path).endswith(
                    (".backup", ".recovery")
                ):
                    mutated = True
                    source.write_bytes(
                        source.read_bytes() + b"\npostcommit mutation\n"
                    )
                return original_unlink(path, *args, **kwargs)

            with mock.patch.object(
                ux_blueprint.os,
                "unlink",
                side_effect=mutate_during_cleanup,
            ):
                summary = ux_blueprint.write_ux_blueprint_projection(root)
            self.assertTrue(mutated)
            self.assertEqual(summary.state_variant_count, 441)
            for path, old_content in preimages.items():
                self.assertNotEqual((root / path).read_bytes(), old_content)
            self.assertEqual(self._transaction_artifacts(root), ())

    def test_projection_postcommit_cleanup_failure_leaves_final_marker(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_inputs(root)
            self._preimages(root)
            retained = self._leave_committed_cleanup_evidence(root)
            self.assertEqual(
                len(
                    tuple(
                        path
                        for path in retained
                        if path.name.endswith(".committed-cleanup.json")
                    )
                ),
                1,
            )

    def test_projection_prior_cleanup_failure_blocks_before_target_mutation(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_inputs(root)
            self._preimages(root)
            retained = self._leave_committed_cleanup_evidence(root)
            committed = self._projection_state_with_identity(root)
            original_unlink = ux_blueprint.os.unlink
            failed = False

            def fail_prior_recovery_cleanup(path, *args, **kwargs):
                nonlocal failed
                if (
                    not failed
                    and os.fspath(path).endswith(".recovery")
                ):
                    failed = True
                    raise OSError("prior committed cleanup failed")
                return original_unlink(path, *args, **kwargs)

            with mock.patch.object(
                ux_blueprint.os,
                "unlink",
                side_effect=fail_prior_recovery_cleanup,
            ):
                with self.assertRaises(
                    (CanonError, ux_blueprint.UXBlueprintError, OSError)
                ):
                    ux_blueprint.write_ux_blueprint_projection(root)

            self.assertTrue(failed)
            self._assert_projection_preimages_restored(root, committed)
            self.assertTrue(
                any(
                    path.exists()
                    and path.name.endswith(".committed-cleanup.json")
                    for path in retained
                )
            )

    def test_projection_prior_cleanup_success_precedes_next_transaction(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_inputs(root)
            self._preimages(root)
            retained = self._leave_committed_cleanup_evidence(root)
            retained_identities = {
                path: ((info := path.stat()).st_dev, info.st_ino)
                for path in retained
            }
            unrelated = root / MARKDOWN_PATH.parent / ".unrelated.recovery"
            unrelated.write_bytes(b"unrelated collision evidence\n")

            second = ux_blueprint.write_ux_blueprint_projection(root)
            self.assertEqual(second.state_variant_count, 441)
            for path, identity in retained_identities.items():
                self.assertFalse(path.exists(), (path, identity))
            self.assertEqual(
                unrelated.read_bytes(), b"unrelated collision evidence\n"
            )
            self.assertEqual(self._transaction_artifacts(root), (unrelated,))

    def test_projection_malformed_unrelated_and_stale_evidence_is_preserved(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_inputs(root)
            self._preimages(root)
            retained = self._leave_committed_cleanup_evidence(root)
            migration = root / MARKDOWN_PATH.parent
            malformed = migration / f".{('d4' * 8)}.committed-cleanup.json"
            malformed.write_bytes(b"malformed marker evidence\n")
            unrelated = migration / ".unrelated.recovery"
            unrelated.write_bytes(b"unrelated collision evidence\n")

            (root / MARKDOWN_PATH).write_bytes(b"stale target identity\n")
            evidence = {
                path: (
                    path.read_bytes(),
                    ((info := path.stat()).st_dev, info.st_ino),
                )
                for path in (*retained, malformed, unrelated)
            }

            summary = ux_blueprint.write_ux_blueprint_projection(root)
            self.assertEqual(summary.state_variant_count, 441)
            for path, (content, identity) in evidence.items():
                info = path.stat()
                self.assertEqual(path.read_bytes(), content)
                self.assertEqual((info.st_dev, info.st_ino), identity)

    def test_visual_manifest_uses_captured_bytes_across_aba_replacement(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_inputs(root)
            manifest = root / visual_authority.MANIFEST_PATH
            original_bytes = manifest.read_bytes()
            original_slot = root / "manifest-original"
            alternate_slot = root / "manifest-alternate"
            alternate_slot.write_bytes(b"{}\n")
            original_operation = visual_authority._ux_operation
            original_validator = (
                visual_authority._validate_visual_authority_payload
            )
            swapped = False
            consumed: list[bytes] = []

            @contextmanager
            def aba_operation(*args, **kwargs):
                nonlocal swapped
                with original_operation(*args, **kwargs) as context:
                    if not swapped:
                        swapped = True
                        os.replace(manifest, original_slot)
                        os.replace(alternate_slot, manifest)
                        try:
                            yield context
                        finally:
                            os.replace(manifest, alternate_slot)
                            os.replace(original_slot, manifest)
                    else:
                        yield context

            def recording_validator(
                repo_root, payload, source_bytes, canon_snapshot
            ):
                consumed.append(source_bytes)
                return original_validator(
                    repo_root, payload, source_bytes, canon_snapshot
                )

            with (
                mock.patch.object(
                    visual_authority, "_ux_operation", aba_operation
                ),
                mock.patch.object(
                    visual_authority,
                    "_validate_visual_authority_payload",
                    side_effect=recording_validator,
                ),
            ):
                with self.assertRaises(CanonError):
                    visual_authority.load_visual_authority_rebaseline(root)
            self.assertTrue(swapped)
            self.assertEqual(consumed, [original_bytes])

    def test_visual_manifest_optional_presence_is_captured_and_mutations_fail(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._copy_complete_inputs(root)
            original_lstat = visual_authority.os.lstat

            def forbid_manifest_lstat(path, *args, **kwargs):
                if os.fspath(path).endswith(
                    visual_authority.MANIFEST_PATH.as_posix()
                ):
                    raise AssertionError("pre-operation manifest lstat")
                return original_lstat(path, *args, **kwargs)

            with mock.patch.object(
                visual_authority.os,
                "lstat",
                side_effect=forbid_manifest_lstat,
            ):
                self.assertIsNotNone(
                    visual_authority.load_visual_authority_rebaseline_if_present(
                        root
                    )
                )

        for initial_presence in (False, True):
            with self.subTest(initial_presence=initial_presence):
                with tempfile.TemporaryDirectory() as temporary:
                    root = Path(temporary)
                    self._copy_complete_inputs(root)
                    manifest = root / visual_authority.MANIFEST_PATH
                    source = manifest.read_bytes()
                    held = root / "held-visual-manifest"
                    if not initial_presence:
                        os.replace(manifest, held)
                    original_operation = visual_authority._ux_operation
                    mutated = False

                    @contextmanager
                    def mutating_operation(*args, **kwargs):
                        nonlocal mutated
                        with original_operation(*args, **kwargs) as context:
                            if not mutated:
                                mutated = True
                                if initial_presence:
                                    os.replace(manifest, held)
                                else:
                                    manifest.write_bytes(source)
                            yield context

                    with mock.patch.object(
                        visual_authority,
                        "_ux_operation",
                        mutating_operation,
                    ):
                        with self.assertRaises(CanonError):
                            visual_authority.load_visual_authority_rebaseline_if_present(
                                root
                            )
                    self.assertTrue(mutated)

    def _assert_nonblocking_fifo_rejection(self, expression: str) -> None:
        script = f"""
import os, tempfile
from pathlib import Path
from tools.ambitions_canon.model import CanonError
from tools.ambitions_canon.ux_blueprint import UXBlueprintError
{expression}
"""
        try:
            result = subprocess.run(
                [sys.executable, "-c", script],
                cwd=ROOT,
                capture_output=True,
                text=True,
                timeout=2,
            )
        except subprocess.TimeoutExpired as error:
            self.fail(f"FIFO read blocked instead of failing closed: {error}")
        self.assertEqual(result.returncode, 0, result.stderr or result.stdout)

    def test_shared_build_reader_rejects_fifo_without_blocking(self):
        self._assert_nonblocking_fifo_rejection(
            """
from tools.ambitions_canon.build import _read_confined_bytes
with tempfile.TemporaryDirectory() as temporary:
    root = Path(temporary)
    os.mkfifo(root / 'source')
    try:
        _read_confined_bytes(root, Path('source'))
    except CanonError:
        pass
    else:
        raise SystemExit('FIFO was accepted')
"""
        )

    def test_source_hasher_rejects_fifo_without_blocking(self):
        self._assert_nonblocking_fifo_rejection(
            """
from tools.ambitions_canon.ux_blueprint import validate_source_documents
with tempfile.TemporaryDirectory() as temporary:
    root = Path(temporary)
    os.mkfifo(root / 'source')
    try:
        validate_source_documents(root, [{'path': 'source', 'sha256': '0' * 64}])
    except UXBlueprintError:
        pass
    else:
        raise SystemExit('FIFO was accepted')
"""
        )

    def test_shared_and_source_readers_reject_identity_swap(self):
        for reader in ("shared", "source"):
            with self.subTest(reader=reader):
                with tempfile.TemporaryDirectory() as temporary:
                    root = Path(temporary)
                    source = root / "source.md"
                    alternate = root / "alternate.md"
                    content = b"same approved bytes\n"
                    source.write_bytes(content)
                    alternate.write_bytes(content)
                    original_open = os.open
                    swapped = False

                    def swapping_open(path, flags, *args, **kwargs):
                        nonlocal swapped
                        if (
                            not swapped
                            and os.fspath(path) == "source.md"
                            and not flags & os.O_DIRECTORY
                        ):
                            os.replace(alternate, source)
                            swapped = True
                        return original_open(path, flags, *args, **kwargs)

                    with mock.patch.object(
                        canon_build.os, "open", swapping_open
                    ):
                        if reader == "shared":
                            with self.assertRaises(CanonError) as raised:
                                canon_build._read_confined_bytes(
                                    root, Path("source.md")
                                )
                            self.assertEqual(raised.exception.code, "CANON_CONTENT_READ")
                        else:
                            with self.assertRaisesRegex(
                                ux_blueprint.UXBlueprintError,
                                "identity|changed|unsafe",
                            ):
                                ux_blueprint.validate_source_documents(
                                    root,
                                    [
                                        {
                                            "path": "source.md",
                                            "sha256": hashlib.sha256(
                                                content
                                            ).hexdigest(),
                                        }
                                    ],
                                )
                    self.assertTrue(swapped)


if __name__ == "__main__":
    unittest.main()
