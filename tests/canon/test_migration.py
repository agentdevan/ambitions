import contextlib
import errno
import hashlib
import io
import json
import os
import socket
import stat
import subprocess
import sys
import tempfile
import unittest
from dataclasses import replace
from pathlib import Path
from unittest import mock

import tools.ambitions_canon.migration as migration
from tools.ambitions_canon.cli import main
from tools.ambitions_canon.migration import (
    SourceRecord,
    load_source_catalog,
    register_repo_sources,
    register_source,
    verify_catalog,
    verify_source,
)
from tools.ambitions_canon.model import CanonError


LINEAR_METADATA = {
    "source_id": "LINEAR-CANON-V3",
    "kind": "linear",
    "title": "Canonical Linear v3",
    "locator": "linear:96b93346-271d-46fc-beab-43ff7e286b5d",
    "updated_at": "2026-07-10T00:44:25.448Z",
    "owner": "Devan Warner",
    "authority_claim": "primary migration corpus; not final authority",
}


class MigrationTestCase(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.git("init", "-q")
        self.git("config", "user.name", "Canon Tests")
        self.git("config", "user.email", "canon@example.invalid")
        (self.root / ".gitignore").write_text(".codex/\n", encoding="utf-8")
        (self.root / "README.md").write_text("# Test\n", encoding="utf-8")
        self.git("add", ".gitignore", "README.md")
        self.git("commit", "-qm", "baseline")
        self.catalog = self.root / "docs/canon/migration/source-catalog.json"
        self.raw = self.root / ".codex/canon-migration/sources/linear-v3.md"
        self.raw.parent.mkdir(parents=True)
        self.raw.write_bytes("Exact UTF-8 corpus — unchanged\n".encode())

    def tearDown(self):
        self.temporary.cleanup()

    def git(self, *arguments: str, check: bool = True) -> subprocess.CompletedProcess:
        return subprocess.run(
            ("git", *arguments),
            cwd=self.root,
            check=check,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

    def register(self, **overrides: object) -> SourceRecord:
        metadata = {**LINEAR_METADATA, **overrides}
        return register_source(self.catalog, self.raw, metadata)

    @staticmethod
    def is_transaction_artifact(path: Path) -> bool:
        return ".txn-" in path.name or path.name.startswith(".canon-txn-")

    def catalog_transaction_artifacts(self) -> tuple[Path, ...]:
        return tuple(
            sorted(
                path
                for path in self.catalog.parent.glob(".*")
                if self.is_transaction_artifact(path)
            )
        )

    def force_rollback_failure_with_primary_recovery_race(
        self,
        *,
        fallback_bytes: bytes | None,
    ) -> tuple[CanonError, bytes, bytes, Path, Path]:
        self.register()
        concurrent = b'{"concurrent":"deterministic recovery bytes"}\n'
        intruder = b'{"intruder":"primary recovery collision"}\n'
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")
        primary = self.catalog.parent / ".source-catalog.json.recovery-prior"
        digest = hashlib.sha256(concurrent).hexdigest()
        fallback = self.catalog.parent / f".source-catalog.json.recovery-prior-{digest}"
        original_read = migration._read_catalog_at
        original_exchange = migration._rename_exchange
        original_noreplace = migration._rename_noreplace
        read_calls = 0
        exchange_calls = 0
        raced = False

        def edit_after_revalidation(*args: object, **kwargs: object):
            nonlocal read_calls
            result = original_read(*args, **kwargs)
            if len(args) > 1 and args[1] == self.catalog.name:
                read_calls += 1
            if read_calls == 2 and len(args) > 1 and args[1] == self.catalog.name:
                with self.catalog.open("r+b") as handle:
                    handle.seek(0)
                    handle.write(concurrent)
                    handle.truncate()
                    handle.flush()
                    os.fsync(handle.fileno())
            return result

        def fail_exchange_back(*args: object, **kwargs: object) -> None:
            nonlocal exchange_calls
            exchange_calls += 1
            if exchange_calls == 2:
                raise OSError("forced rollback failure")
            original_exchange(*args, **kwargs)

        def race_primary_recovery(
            source: str,
            destination: str,
            **kwargs: object,
        ) -> None:
            nonlocal raced
            if destination == primary.name and not raced:
                raced = True
                primary.write_bytes(intruder)
                if fallback_bytes is not None:
                    fallback.write_bytes(fallback_bytes)
            original_noreplace(source, destination, **kwargs)

        with (
            mock.patch.object(
                migration,
                "_read_catalog_at",
                side_effect=edit_after_revalidation,
            ),
            mock.patch.object(
                migration,
                "_rename_exchange",
                side_effect=fail_exchange_back,
            ),
            mock.patch.object(
                migration,
                "_rename_noreplace",
                side_effect=race_primary_recovery,
            ),
            self.assertRaises(CanonError) as caught,
        ):
            register_source(
                self.catalog,
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )
        return caught.exception, concurrent, intruder, primary, fallback

    def force_rollback_failure_with_recovery_move_error(
        self,
        error_number: int,
    ) -> tuple[CanonError, bytes, tuple[Path, ...]]:
        self.register()
        concurrent = b'{"concurrent":"must remain at transaction locator"}\n'
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")
        original_read = migration._read_catalog_at
        original_exchange = migration._rename_exchange
        original_noreplace = migration._rename_noreplace
        read_calls = 0
        exchange_calls = 0

        def edit_after_revalidation(*args: object, **kwargs: object):
            nonlocal read_calls
            result = original_read(*args, **kwargs)
            if len(args) > 1 and args[1] == self.catalog.name:
                read_calls += 1
            if read_calls == 2 and len(args) > 1 and args[1] == self.catalog.name:
                with self.catalog.open("r+b") as handle:
                    handle.seek(0)
                    handle.write(concurrent)
                    handle.truncate()
                    handle.flush()
                    os.fsync(handle.fileno())
            return result

        def fail_exchange_back(*args: object, **kwargs: object) -> None:
            nonlocal exchange_calls
            exchange_calls += 1
            if exchange_calls == 2:
                raise OSError("forced rollback failure")
            original_exchange(*args, **kwargs)

        def fail_recovery_move(
            source: str,
            destination: str,
            **kwargs: object,
        ) -> None:
            if ".recovery-prior" in destination:
                raise OSError(error_number, os.strerror(error_number), destination)
            original_noreplace(source, destination, **kwargs)

        with (
            mock.patch.object(
                migration,
                "_read_catalog_at",
                side_effect=edit_after_revalidation,
            ),
            mock.patch.object(
                migration,
                "_rename_exchange",
                side_effect=fail_exchange_back,
            ),
            mock.patch.object(
                migration,
                "_rename_noreplace",
                side_effect=fail_recovery_move,
            ),
            self.assertRaises(CanonError) as caught,
        ):
            register_source(
                self.catalog,
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )
        return (
            caught.exception,
            concurrent,
            tuple(sorted(self.catalog.parent.glob(".*"))),
        )

    def assert_unresolved_transaction_blocks_next_registration(
        self,
        error_number: int,
    ) -> None:
        _error, prior, artifacts = self.force_rollback_failure_with_recovery_move_error(
            error_number
        )
        transactions = tuple(
            path for path in artifacts if self.is_transaction_artifact(path)
        )
        self.assertEqual(len(transactions), 1)
        transaction = transactions[0]
        catalog_before = self.catalog.read_bytes()
        third = self.raw.with_name("third.md")
        third.write_text("third\n", encoding="utf-8")

        with self.assertRaises(CanonError) as caught:
            register_source(
                self.catalog,
                third,
                {
                    **LINEAR_METADATA,
                    "source_id": "THIRD",
                    "locator": "linear:third",
                },
            )

        self.assertEqual(caught.exception.code, "MIGRATION_CATALOG_RECOVERY_REQUIRED")
        self.assertIn(transaction.name, str(caught.exception))
        self.assertEqual(self.catalog.read_bytes(), catalog_before)
        self.assertEqual(transaction.read_bytes(), prior)

    def run_registration_subprocess(
        self,
        source: Path,
        metadata: dict[str, str],
        *,
        timeout: float = 2.0,
    ) -> subprocess.CompletedProcess[str]:
        script = """
import json
import sys
from pathlib import Path
from tools.ambitions_canon.migration import register_source
from tools.ambitions_canon.model import CanonError

try:
    register_source(Path(sys.argv[1]), Path(sys.argv[2]), json.loads(sys.argv[3]))
except CanonError as error:
    print(error.code)
    print(error)
    raise SystemExit(0)
raise SystemExit(3)
"""
        return subprocess.run(
            (
                sys.executable,
                "-c",
                script,
                str(self.catalog),
                str(source),
                json.dumps(metadata, sort_keys=True),
            ),
            cwd=Path(__file__).resolve().parents[2],
            check=False,
            capture_output=True,
            text=True,
            timeout=timeout,
        )

    def assert_reserved_alias_blocks(self, alias: str) -> None:
        self.register()
        catalog_before = self.catalog.read_bytes()
        artifact = self.catalog.with_name(alias)
        artifact.write_bytes(b"reserved malformed transaction namespace\n")
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")

        with self.assertRaises(CanonError) as caught:
            register_source(
                self.catalog,
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )

        self.assertEqual(caught.exception.code, "MIGRATION_CATALOG_RECOVERY_REQUIRED")
        self.assertIn(artifact.name, str(caught.exception))
        self.assertEqual(self.catalog.read_bytes(), catalog_before)
        self.assertEqual(
            artifact.read_bytes(), b"reserved malformed transaction namespace\n"
        )

    def create_prefix_sharing_sibling_transaction(
        self,
        sibling_name: str,
        *,
        staged_bytes: bytes | None = None,
    ) -> tuple[Path, Path, bytes, bytes]:
        sibling = self.catalog.with_name(sibling_name)
        preimage = b'{"schema_version":1,"sources":[]}\n'
        staged = staged_bytes or (b'{\n  "schema_version": 1,\n  "sources": []\n}\n')
        sibling.write_bytes(preimage)
        transaction = sibling.with_name(
            f".{sibling.name}.txn-{hashlib.sha256(preimage).hexdigest()}-"
            f"{hashlib.sha256(staged).hexdigest()}"
        )
        transaction.write_bytes(staged)
        return sibling, transaction, preimage, staged

    def test_exact_checksum_registration_and_byte_preserving_verification(self):
        record = self.register()

        self.assertEqual(
            record.raw_sha256, hashlib.sha256(self.raw.read_bytes()).hexdigest()
        )
        self.assertEqual(record.raw_byte_length, len(self.raw.read_bytes()))
        self.assertEqual(record.raw_path, ".codex/canon-migration/sources/linear-v3.md")
        self.assertEqual(verify_source(record, self.raw), ())
        self.assertTrue(self.catalog.read_bytes().endswith(b"\n"))

    def test_catalog_sources_and_object_keys_are_deterministically_sorted(self):
        second = self.root / ".codex/canon-migration/sources/figma.json"
        second.write_text('{"node":"250:104"}\n', encoding="utf-8")
        register_source(
            self.catalog,
            second,
            {
                "source_id": "FIGMA-VSP07",
                "kind": "figma",
                "title": "VSP-07 evidence",
                "locator": "figma:SWtHm9ouHTPbEFfNrrtZwv:250:104",
                "updated_at": "2026-07-01",
                "owner": "Devan Warner",
                "authority_claim": "Yellow visual evidence; not product law",
            },
        )
        self.register()

        payload = json.loads(self.catalog.read_text(encoding="utf-8"))
        self.assertEqual(
            [source["source_id"] for source in payload["sources"]],
            ["FIGMA-VSP07", "LINEAR-CANON-V3"],
        )
        self.assertEqual(
            self.catalog.read_text(encoding="utf-8"),
            json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        )

    def test_checksum_mismatch_after_raw_edit_is_p0(self):
        record = self.register()
        self.raw.write_text("changed\n", encoding="utf-8")

        findings = verify_source(record, self.raw)

        self.assertEqual(
            [finding.code for finding in findings], ["MIGRATION_RAW_CHECKSUM_MISMATCH"]
        )

    def test_duplicate_source_id_locator_and_raw_path_are_rejected(self):
        self.register()
        other = self.root / ".codex/canon-migration/sources/other.md"
        other.write_text("other\n", encoding="utf-8")
        cases = (
            (
                {**LINEAR_METADATA, "locator": "linear:other"},
                "MIGRATION_SOURCE_ID_DUPLICATE",
            ),
            ({**LINEAR_METADATA, "source_id": "OTHER"}, "MIGRATION_LOCATOR_DUPLICATE"),
            (
                {**LINEAR_METADATA, "source_id": "OTHER", "locator": "linear:other"},
                "MIGRATION_PATH_DUPLICATE",
            ),
        )
        for metadata, code in cases:
            with self.subTest(code=code), self.assertRaisesRegex(CanonError, code):
                register_source(self.catalog, self.raw, metadata)

    def test_raw_path_must_be_ignored_and_below_migration_root(self):
        outside = self.root / "outside.md"
        outside.write_text("tracked-shaped\n", encoding="utf-8")
        ignored_elsewhere = self.root / ".codex/not-migration.md"
        ignored_elsewhere.parent.mkdir(exist_ok=True)
        ignored_elsewhere.write_text("ignored elsewhere\n", encoding="utf-8")

        for path in (outside, ignored_elsewhere):
            with (
                self.subTest(path=path),
                self.assertRaisesRegex(CanonError, "MIGRATION_RAW_PATH_UNSAFE"),
            ):
                register_source(self.catalog, path, LINEAR_METADATA)

    def test_raw_path_rejects_symlink_leaf_or_ancestry(self):
        real = self.root / ".codex/real"
        real.mkdir(parents=True)
        (real / "raw.md").write_text("data\n", encoding="utf-8")
        linked_parent = self.root / ".codex/canon-migration/linked"
        linked_parent.symlink_to(real, target_is_directory=True)
        linked_leaf = self.root / ".codex/canon-migration/sources/linked.md"
        linked_leaf.symlink_to(real / "raw.md")

        for path in (linked_parent / "raw.md", linked_leaf):
            with (
                self.subTest(path=path),
                self.assertRaisesRegex(CanonError, "MIGRATION_RAW_PATH_UNSAFE"),
            ):
                register_source(self.catalog, path, LINEAR_METADATA)

    def test_required_metadata_is_nonblank_and_metadata_shape_is_closed(self):
        required = (
            "source_id",
            "kind",
            "title",
            "locator",
            "updated_at",
            "owner",
            "authority_claim",
        )
        for key in required:
            with (
                self.subTest(key=key),
                self.assertRaisesRegex(CanonError, "MIGRATION_METADATA_INVALID"),
            ):
                self.register(**{key: "  "})
        with self.assertRaisesRegex(CanonError, "MIGRATION_METADATA_INVALID"):
            self.register(unexpected="not allowed")

    def test_source_kind_is_closed_and_raw_must_be_utf8(self):
        with self.assertRaisesRegex(CanonError, "MIGRATION_METADATA_INVALID"):
            self.register(kind="not-a-kind")
        self.raw.write_bytes(b"\xff\xfe")
        with self.assertRaisesRegex(CanonError, "MIGRATION_RAW_UTF8_INVALID"):
            self.register()

    def test_existing_catalog_rejects_unknown_fields_and_symlink_replacement(self):
        record = self.register()
        payload = json.loads(self.catalog.read_text(encoding="utf-8"))
        payload["sources"][0]["unknown"] = "field"
        self.catalog.write_text(json.dumps(payload), encoding="utf-8")
        with self.assertRaisesRegex(CanonError, "MIGRATION_CATALOG_INVALID"):
            load_source_catalog(self.catalog)

        self.catalog.unlink()
        target = self.root / "target.json"
        target.write_text("do not replace\n", encoding="utf-8")
        self.catalog.symlink_to(target)
        with self.assertRaisesRegex(CanonError, "MIGRATION_CATALOG_PATH_UNSAFE"):
            register_source(
                self.catalog,
                self.raw,
                {**LINEAR_METADATA, "source_id": "OTHER", "locator": "linear:other"},
            )
        self.assertEqual(target.read_text(encoding="utf-8"), "do not replace\n")
        self.assertIsInstance(record, SourceRecord)

    def test_verify_fails_closed_for_missing_catalog_or_symlink_ancestry(self):
        missing = verify_catalog(self.catalog, self.root)
        self.assertEqual(
            [finding.code for finding in missing],
            ["MIGRATION_CATALOG_MISSING"],
        )

        real = self.root / "real-catalog-parent"
        real.mkdir()
        linked = self.root / "linked-catalog-parent"
        linked.symlink_to(real, target_is_directory=True)
        unsafe = verify_catalog(linked / "catalog.json", self.root)
        self.assertEqual(
            [finding.code for finding in unsafe],
            ["MIGRATION_CATALOG_PATH_UNSAFE"],
        )

    def test_repo_registration_uses_tracked_files_and_records_content_sha(self):
        records = register_repo_sources(
            self.catalog, self.root, ("README.md", "docs/truth/**")
        )

        self.assertEqual(len(records), 1)
        record = records[0]
        self.assertEqual(record.kind, "repo")
        self.assertEqual(record.repo_path, "README.md")
        self.assertEqual(
            record.content_sha256,
            hashlib.sha256((self.root / "README.md").read_bytes()).hexdigest(),
        )
        self.assertEqual(record.locator, "repo:README.md")
        self.assertIsNone(record.raw_path)
        self.assertEqual(verify_catalog(self.catalog, self.root), ())

    def test_repo_registration_is_deterministic_and_never_copies_content(self):
        secret = "UNIQUE-REPO-CONTENT-DO-NOT-COPY"
        (self.root / "README.md").write_text(secret + "\n", encoding="utf-8")
        self.git("add", "README.md")
        self.git("commit", "-qm", "update")

        register_repo_sources(self.catalog, self.root, ("README.md",))

        catalog_text = self.catalog.read_text(encoding="utf-8")
        self.assertNotIn(secret, catalog_text)
        self.assertIn(
            hashlib.sha256((secret + "\n").encode()).hexdigest(), catalog_text
        )

    def test_repo_registration_fails_when_no_tracked_source_matches(self):
        with self.assertRaisesRegex(CanonError, "MIGRATION_REPO_NO_MATCH"):
            register_repo_sources(
                self.catalog,
                self.root,
                ("docs/does-not-exist/**",),
            )

    def test_repo_registration_rejects_deleted_renamed_and_untracked_pathspec_state_before_catalog_mutation(
        self,
    ):
        docs = self.root / "docs"
        docs.mkdir()
        tracked = docs / "authority.md"
        tracked.write_text("authority\n", encoding="utf-8")
        self.git("add", "docs/authority.md")
        self.git("commit", "-qm", "add authority")

        cases = ("deleted", "renamed", "untracked")
        for case in cases:
            with self.subTest(case=case):
                self.git("reset", "--hard", "HEAD")
                untracked = docs / "untracked.md"
                untracked.unlink(missing_ok=True)
                moved = self.root / "moved-authority.md"
                moved.unlink(missing_ok=True)
                if case == "deleted":
                    self.git("rm", "-q", "docs/authority.md")
                elif case == "renamed":
                    self.git("mv", "docs/authority.md", "moved-authority.md")
                else:
                    untracked.write_text("untracked authority\n", encoding="utf-8")

                with self.assertRaisesRegex(CanonError, "MIGRATION_REPO_DIRTY"):
                    register_repo_sources(self.catalog, self.root, ("docs/**",))
                self.assertFalse(self.catalog.exists())

    def test_repo_registration_revalidates_snapshot_after_hashing(self):
        original_read = migration._read_regular_nofollow
        mutated = False

        def mutate_after_read(path: Path, code: str) -> bytes:
            nonlocal mutated
            content = original_read(path, code)
            if Path(path).name == "README.md" and not mutated:
                mutated = True
                (self.root / "README.md").write_text(
                    "changed during registration\n", encoding="utf-8"
                )
            return content

        with (
            mock.patch.object(
                migration,
                "_read_regular_nofollow",
                side_effect=mutate_after_read,
            ),
            self.assertRaisesRegex(CanonError, "MIGRATION_REPO_CHANGED"),
        ):
            register_repo_sources(self.catalog, self.root, ("README.md",))
        self.assertFalse(self.catalog.exists())

    def test_catalog_creation_rejects_symlink_parent_without_external_mutation(self):
        external = self.root / "real-parent"
        external.mkdir()
        linked = self.root / "docs"
        linked.symlink_to(external, target_is_directory=True)
        catalog = linked / "sub/source-catalog.json"

        with self.assertRaisesRegex(CanonError, "MIGRATION_CATALOG_PATH_UNSAFE"):
            register_source(catalog, self.raw, LINEAR_METADATA)

        self.assertFalse((external / "sub").exists())
        self.assertEqual(tuple(external.iterdir()), ())

    def test_catalog_creation_rejects_intermediate_swap_without_external_mutation(self):
        external = self.root / "external"
        external.mkdir()
        displaced = self.root / "displaced-docs"
        original_mkdir = migration.os.mkdir
        swapped = False

        def swap_after_create(
            path: str,
            mode: int = 0o777,
            *,
            dir_fd: int | None = None,
        ) -> None:
            nonlocal swapped
            original_mkdir(path, mode=mode, dir_fd=dir_fd)
            if path == "docs" and dir_fd is not None and not swapped:
                swapped = True
                (self.root / "docs").rename(displaced)
                (self.root / "docs").symlink_to(external, target_is_directory=True)

        with (
            mock.patch.object(migration.os, "mkdir", side_effect=swap_after_create),
            self.assertRaisesRegex(CanonError, "MIGRATION_CATALOG_PATH_UNSAFE"),
        ):
            register_source(self.catalog, self.raw, LINEAR_METADATA)

        self.assertTrue(swapped)
        self.assertFalse((external / "canon").exists())

    def test_catalog_compare_and_swap_preserves_same_inode_concurrent_edit(self):
        self.register()
        concurrent = b'{"concurrent":"same-inode edit"}\n'
        second = self.root / ".codex/canon-migration/sources/second.md"
        second.write_text("second\n", encoding="utf-8")
        original_read = migration._read_catalog_at
        calls = 0

        def edit_after_revalidation(*args: object, **kwargs: object):
            nonlocal calls
            result = original_read(*args, **kwargs)
            if len(args) > 1 and args[1] == self.catalog.name:
                calls += 1
            if calls == 2 and len(args) > 1 and args[1] == self.catalog.name:
                with self.catalog.open("r+b") as handle:
                    handle.seek(0)
                    handle.write(concurrent)
                    handle.truncate()
                    handle.flush()
                    os.fsync(handle.fileno())
            return result

        with (
            mock.patch.object(
                migration,
                "_read_catalog_at",
                side_effect=edit_after_revalidation,
            ),
            self.assertRaisesRegex(
                CanonError,
                "MIGRATION_CATALOG_CHANGED",
            ),
        ):
            register_source(
                self.catalog,
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )

        self.assertEqual(self.catalog.read_bytes(), concurrent)
        self.assertEqual(list(self.catalog.parent.glob(".*source-catalog*")), [])

    def test_catalog_first_install_uses_no_replace_and_preserves_interleaved_writer(
        self,
    ):
        concurrent = b'{"concurrent":"first writer"}\n'
        original_read = migration._read_catalog_at
        calls = 0

        def create_after_revalidation(*args: object, **kwargs: object):
            nonlocal calls
            result = original_read(*args, **kwargs)
            calls += 1
            if calls == 2:
                self.catalog.write_bytes(concurrent)
            return result

        with (
            mock.patch.object(
                migration,
                "_read_catalog_at",
                side_effect=create_after_revalidation,
            ),
            self.assertRaisesRegex(
                CanonError,
                "MIGRATION_CATALOG_RECOVERY_REQUIRED",
            ),
        ):
            self.register()

        self.assertEqual(self.catalog.read_bytes(), concurrent)
        self.assertEqual(list(self.catalog.parent.glob(".*source-catalog*")), [])

    def test_visible_catalog_ancestry_swap_before_install_aborts_without_touching_intruder(
        self,
    ):
        self.register()
        prior = self.catalog.read_bytes()
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")
        docs = self.root / "docs"
        displaced = self.root / "displaced-docs"
        original_check = getattr(migration, "_require_visible_ancestry", None)
        calls = 0

        def swap_then_check(*args: object, **kwargs: object) -> None:
            nonlocal calls
            calls += 1
            if calls == 1:
                docs.rename(displaced)
                docs.mkdir()
                (docs / "intruder.txt").write_text("preserve me\n", encoding="utf-8")
            assert original_check is not None
            original_check(*args, **kwargs)

        with (
            mock.patch.object(
                migration,
                "_require_visible_ancestry",
                side_effect=swap_then_check,
                create=True,
            ),
            self.assertRaisesRegex(CanonError, "MIGRATION_CATALOG_PATH_CHANGED"),
        ):
            register_source(
                self.catalog,
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )

        self.assertEqual(
            (displaced / "canon/migration/source-catalog.json").read_bytes(),
            prior,
        )
        self.assertEqual((docs / "intruder.txt").read_text(), "preserve me\n")

    def test_visible_catalog_ancestry_swap_after_install_rolls_back_pinned_catalog(
        self,
    ):
        self.register()
        prior = self.catalog.read_bytes()
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")
        docs = self.root / "docs"
        displaced = self.root / "displaced-docs"
        original_check = getattr(migration, "_require_visible_ancestry", None)
        calls = 0

        def swap_on_postcondition(*args: object, **kwargs: object) -> None:
            nonlocal calls
            calls += 1
            if calls == 2:
                docs.rename(displaced)
                docs.mkdir()
                (docs / "intruder.txt").write_text("preserve me\n", encoding="utf-8")
            assert original_check is not None
            original_check(*args, **kwargs)

        with (
            mock.patch.object(
                migration,
                "_require_visible_ancestry",
                side_effect=swap_on_postcondition,
                create=True,
            ),
            self.assertRaisesRegex(CanonError, "MIGRATION_CATALOG_PATH_CHANGED"),
        ):
            register_source(
                self.catalog,
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )

        self.assertEqual(
            (displaced / "canon/migration/source-catalog.json").read_bytes(),
            prior,
        )
        self.assertEqual((docs / "intruder.txt").read_text(), "preserve me\n")

    def test_exchange_rollback_failure_retains_exact_prior_recovery_artifact(self):
        self.register()
        concurrent = b'{"concurrent":"retain exact preimage"}\n'
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")
        original_read = migration._read_catalog_at
        original_exchange = migration._rename_exchange
        read_calls = 0
        exchange_calls = 0

        def edit_after_revalidation(*args: object, **kwargs: object):
            nonlocal read_calls
            result = original_read(*args, **kwargs)
            if len(args) > 1 and args[1] == self.catalog.name:
                read_calls += 1
            if read_calls == 2 and len(args) > 1 and args[1] == self.catalog.name:
                with self.catalog.open("r+b") as handle:
                    handle.seek(0)
                    handle.write(concurrent)
                    handle.truncate()
                    handle.flush()
                    os.fsync(handle.fileno())
            return result

        def fail_exchange_back(*args: object, **kwargs: object) -> None:
            nonlocal exchange_calls
            exchange_calls += 1
            if exchange_calls == 2:
                raise OSError("forced rollback failure")
            original_exchange(*args, **kwargs)

        with (
            mock.patch.object(
                migration,
                "_read_catalog_at",
                side_effect=edit_after_revalidation,
            ),
            mock.patch.object(
                migration,
                "_rename_exchange",
                side_effect=fail_exchange_back,
            ),
            self.assertRaisesRegex(
                CanonError,
                r"MIGRATION_CATALOG_RECOVERY_REQUIRED.*\.source-catalog\.json\.recovery-prior",
            ),
        ):
            register_source(
                self.catalog,
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )

        recovery = self.catalog.parent / ".source-catalog.json.recovery-prior"
        self.assertEqual(recovery.read_bytes(), concurrent)
        self.assertNotEqual(self.catalog.read_bytes(), concurrent)
        self.assertEqual(list(self.catalog.parent.glob(".*.tmp-*")), [])
        self.assertFalse((self.catalog.parent / ".source-catalog.json.lock").exists())

    def test_created_ancestry_is_removed_from_displaced_preexisting_tree_on_abort(self):
        docs = self.root / "docs"
        docs.mkdir()
        sentinel = docs / "preexisting.txt"
        sentinel.write_bytes(b"preexisting tree bytes\n")
        external = self.root / "external-target"
        external.mkdir()
        (external / "intruder.txt").write_bytes(b"visible target untouched\n")
        displaced = self.root / "displaced-docs"
        original_check = migration._require_visible_ancestry
        calls = 0

        def displace_before_install(*args: object, **kwargs: object) -> None:
            nonlocal calls
            calls += 1
            if calls == 1:
                docs.rename(displaced)
                docs.symlink_to(external, target_is_directory=True)
            original_check(*args, **kwargs)

        with (
            mock.patch.object(
                migration,
                "_require_visible_ancestry",
                side_effect=displace_before_install,
            ),
            self.assertRaisesRegex(CanonError, "MIGRATION_CATALOG_PATH_CHANGED"),
        ):
            self.register()

        self.assertEqual(
            sorted(
                path.relative_to(displaced).as_posix() for path in displaced.rglob("*")
            ),
            ["preexisting.txt"],
        )
        self.assertEqual(
            (displaced / "preexisting.txt").read_bytes(),
            b"preexisting tree bytes\n",
        )
        self.assertEqual(
            (external / "intruder.txt").read_bytes(), b"visible target untouched\n"
        )
        self.assertFalse((external / "canon").exists())

    def test_abort_removes_only_created_ancestry_and_preserves_preexisting_directories(
        self,
    ):
        canon = self.root / "docs/canon"
        canon.mkdir(parents=True)
        (canon / "preexisting.txt").write_text("preserve\n", encoding="utf-8")

        with (
            mock.patch.object(
                migration,
                "_install_catalog_cas",
                side_effect=CanonError("FORCED_ABORT", "forced before commit"),
            ),
            self.assertRaisesRegex(CanonError, "FORCED_ABORT"),
        ):
            self.register()

        self.assertTrue(canon.is_dir())
        self.assertEqual((canon / "preexisting.txt").read_text(), "preserve\n")
        self.assertFalse((canon / "migration").exists())

    def test_raced_content_in_created_ancestry_is_retained_and_requires_recovery(self):
        def add_intruder_then_abort(*args: object, **kwargs: object) -> None:
            (self.catalog.parent / "intruder.txt").write_text(
                "do not delete\n",
                encoding="utf-8",
            )
            raise CanonError("FORCED_ABORT", "forced after raced content")

        with (
            mock.patch.object(
                migration,
                "_install_catalog_cas",
                side_effect=add_intruder_then_abort,
            ),
            self.assertRaisesRegex(
                CanonError,
                "MIGRATION_CATALOG_RECOVERY_REQUIRED",
            ),
        ):
            self.register()

        self.assertEqual(
            (self.catalog.parent / "intruder.txt").read_text(),
            "do not delete\n",
        )

    def test_primary_recovery_race_uses_content_addressed_fallback(self):
        error, prior, intruder, primary, fallback = (
            self.force_rollback_failure_with_primary_recovery_race(
                fallback_bytes=None,
            )
        )

        self.assertEqual(error.code, "MIGRATION_CATALOG_RECOVERY_REQUIRED")
        self.assertIn(fallback.name, str(error))
        self.assertEqual(primary.read_bytes(), intruder)
        self.assertEqual(fallback.read_bytes(), prior)
        self.assertEqual(list(self.catalog.parent.glob(".*.tmp-*")), [])

    def test_identical_content_addressed_recovery_is_reused_idempotently(self):
        prior = b'{"concurrent":"deterministic recovery bytes"}\n'
        error, actual_prior, intruder, primary, fallback = (
            self.force_rollback_failure_with_primary_recovery_race(
                fallback_bytes=prior,
            )
        )

        self.assertEqual(actual_prior, prior)
        self.assertEqual(error.code, "MIGRATION_CATALOG_RECOVERY_REQUIRED")
        self.assertIn(fallback.name, str(error))
        self.assertEqual(primary.read_bytes(), intruder)
        self.assertEqual(fallback.read_bytes(), prior)
        self.assertEqual(list(self.catalog.parent.glob(".*.tmp-*")), [])

    def test_conflicting_content_addressed_recovery_uses_deterministic_collision_path(
        self,
    ):
        conflict = b'{"conflict":"preserve too"}\n'
        error, prior, intruder, primary, fallback = (
            self.force_rollback_failure_with_primary_recovery_race(
                fallback_bytes=conflict,
            )
        )
        collision = fallback.with_name(
            fallback.name + "-collision-" + hashlib.sha256(conflict).hexdigest()
        )

        self.assertEqual(error.code, "MIGRATION_CATALOG_RECOVERY_REQUIRED")
        self.assertIn(collision.name, str(error))
        self.assertEqual(primary.read_bytes(), intruder)
        self.assertEqual(fallback.read_bytes(), conflict)
        self.assertEqual(collision.read_bytes(), prior)
        self.assertEqual(list(self.catalog.parent.glob(".*.tmp-*")), [])

    def test_recovery_move_eio_reports_existing_deterministic_transaction_locator(self):
        error, prior, artifacts = self.force_rollback_failure_with_recovery_move_error(
            errno.EIO
        )
        transactions = tuple(
            path for path in artifacts if self.is_transaction_artifact(path)
        )

        self.assertEqual(error.code, "MIGRATION_CATALOG_RECOVERY_REQUIRED")
        self.assertEqual(len(transactions), 1)
        transaction = transactions[0]
        self.assertRegex(
            transaction.name,
            r"^\.canon-txn-[0-9a-f]{64}-[0-9a-f]{64}-[0-9a-f]{64}$",
        )
        self.assertIn(transaction.name, str(error))
        self.assertEqual(transaction.read_bytes(), prior)
        self.assertNotIn(".tmp-", str(error))

    def test_recovery_name_limit_failure_reports_existing_transaction_locator(self):
        error, prior, artifacts = self.force_rollback_failure_with_recovery_move_error(
            errno.ENAMETOOLONG
        )
        transactions = tuple(
            path for path in artifacts if self.is_transaction_artifact(path)
        )

        self.assertEqual(error.code, "MIGRATION_CATALOG_RECOVERY_REQUIRED")
        self.assertEqual(len(transactions), 1)
        self.assertIn(transactions[0].name, str(error))
        self.assertEqual(transactions[0].read_bytes(), prior)

    def test_eio_transaction_recovery_blocks_subsequent_catalog_mutation(self):
        self.assert_unresolved_transaction_blocks_next_registration(errno.EIO)

    def test_name_limit_transaction_recovery_blocks_subsequent_catalog_mutation(self):
        self.assert_unresolved_transaction_blocks_next_registration(errno.ENAMETOOLONG)

    def test_transaction_namespace_without_separator_is_reserved(self):
        self.assert_reserved_alias_blocks(".source-catalog.json.txn")

    def test_transaction_namespace_adjacent_alias_is_reserved(self):
        self.assert_reserved_alias_blocks(".source-catalog.json.txnX")

    def test_hashed_transaction_namespace_without_separator_is_reserved(self):
        catalog_sha = hashlib.sha256(self.catalog.name.encode("utf-8")).hexdigest()
        self.assert_reserved_alias_blocks(f".canon-txn-{catalog_sha}")

    def test_recovery_namespace_adjacent_alias_is_reserved(self):
        self.assert_reserved_alias_blocks(".source-catalog.json.recovery-priorX")

    def test_valid_prefix_sharing_sibling_transaction_is_ignored_and_preserved(self):
        self.register()
        sibling, transaction, preimage, staged = (
            self.create_prefix_sharing_sibling_transaction(
                "source-catalog.json.txn-other"
            )
        )
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")

        register_source(
            self.catalog,
            second,
            {
                **LINEAR_METADATA,
                "source_id": "SECOND",
                "locator": "linear:second",
            },
        )

        self.assertEqual(len(load_source_catalog(self.catalog)), 2)
        self.assertEqual(sibling.read_bytes(), preimage)
        self.assertEqual(transaction.read_bytes(), staged)

    def test_multiple_prefix_sharing_sibling_transactions_are_unambiguous(self):
        self.register()
        siblings = (
            self.create_prefix_sharing_sibling_transaction("source-catalog.json.txn-a"),
            self.create_prefix_sharing_sibling_transaction(
                "source-catalog.json.txn-a.txn-b",
                staged_bytes=b'{ "schema_version": 1, "sources": [] }\n',
            ),
        )
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")

        register_source(
            self.catalog,
            second,
            {
                **LINEAR_METADATA,
                "source_id": "SECOND",
                "locator": "linear:second",
            },
        )

        self.assertEqual(len(load_source_catalog(self.catalog)), 2)
        for sibling, transaction, preimage, staged in siblings:
            self.assertEqual(sibling.read_bytes(), preimage)
            self.assertEqual(transaction.read_bytes(), staged)

    def test_hashed_sibling_transaction_namespace_is_ignored(self):
        self.register()
        sibling = self.catalog.with_name("source-catalog.json.txn-other")
        preimage = b'{"schema_version":1,"sources":[]}\n'
        staged = b'{"hashed":"sibling staged"}\n'
        sibling.write_bytes(preimage)
        sibling_sha = hashlib.sha256(sibling.name.encode("utf-8")).hexdigest()
        transaction = sibling.with_name(
            f".canon-txn-{sibling_sha}-{hashlib.sha256(preimage).hexdigest()}-"
            f"{hashlib.sha256(staged).hexdigest()}"
        )
        transaction.write_bytes(staged)
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")

        register_source(
            self.catalog,
            second,
            {
                **LINEAR_METADATA,
                "source_id": "SECOND",
                "locator": "linear:second",
            },
        )

        self.assertEqual(len(load_source_catalog(self.catalog)), 2)
        self.assertEqual(sibling.read_bytes(), preimage)
        self.assertEqual(transaction.read_bytes(), staged)

    def test_well_formed_ambiguous_sibling_alias_without_owner_blocks(self):
        self.register()
        staged = b'{"ambiguous":"no sibling owner"}\n'
        transaction = self.catalog.with_name(
            f".source-catalog.json.txn-ghost.txn-{'0' * 64}-"
            f"{hashlib.sha256(staged).hexdigest()}"
        )
        transaction.write_bytes(staged)
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")

        with self.assertRaises(CanonError) as caught:
            register_source(
                self.catalog,
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )

        self.assertEqual(caught.exception.code, "MIGRATION_CATALOG_RECOVERY_REQUIRED")
        self.assertIn(transaction.name, str(caught.exception))
        self.assertEqual(transaction.read_bytes(), staged)

    def test_unsafe_prefix_sharing_sibling_owner_fails_closed(self):
        self.register()
        sibling_name = "source-catalog.json.txn-other"
        sibling = self.catalog.with_name(sibling_name)
        sibling.symlink_to(self.raw)
        staged = b'{"unsafe":"sibling staged"}\n'
        transaction = sibling.with_name(
            f".{sibling.name}.txn-{'0' * 64}-{hashlib.sha256(staged).hexdigest()}"
        )
        transaction.write_bytes(staged)
        catalog_before = self.catalog.read_bytes()
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")

        with self.assertRaises(CanonError) as caught:
            register_source(
                self.catalog,
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )

        self.assertEqual(caught.exception.code, "MIGRATION_CATALOG_RECOVERY_REQUIRED")
        self.assertIn(transaction.name, str(caught.exception))
        self.assertTrue(sibling.is_symlink())
        self.assertEqual(self.catalog.read_bytes(), catalog_before)

    def test_prefix_sharing_sibling_identity_is_revalidated_before_current_cas(self):
        self.register()
        sibling, transaction, _preimage, staged = (
            self.create_prefix_sharing_sibling_transaction(
                "source-catalog.json.txn-other"
            )
        )
        original_prepare = migration._prepare_catalog_staging

        def replace_sibling_after_current_staging(*args: object, **kwargs: object):
            result = original_prepare(*args, **kwargs)
            replacement = sibling.with_name("sibling-replacement")
            replacement.write_bytes(sibling.read_bytes())
            replacement.replace(sibling)
            return result

        catalog_before = self.catalog.read_bytes()
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")
        with (
            mock.patch.object(
                migration,
                "_prepare_catalog_staging",
                side_effect=replace_sibling_after_current_staging,
            ),
            self.assertRaises(CanonError) as caught,
        ):
            register_source(
                self.catalog,
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )

        self.assertEqual(caught.exception.code, "MIGRATION_CATALOG_CHANGED")
        self.assertEqual(self.catalog.read_bytes(), catalog_before)
        self.assertEqual(transaction.read_bytes(), staged)

    def test_other_catalog_transaction_names_and_ordinary_dotfiles_are_ignored(self):
        self.register()
        other_sha = hashlib.sha256(b"other-catalog.json").hexdigest()
        unrelated = (
            ".ordinary-dotfile",
            ".other-catalog.json.txnX",
            f".canon-txn-{other_sha}",
        )
        for name in unrelated:
            self.catalog.with_name(name).write_bytes(b"unrelated bytes\n")
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")

        register_source(
            self.catalog,
            second,
            {
                **LINEAR_METADATA,
                "source_id": "SECOND",
                "locator": "linear:second",
            },
        )

        self.assertEqual(len(load_source_catalog(self.catalog)), 2)
        for name in unrelated:
            self.assertEqual(
                self.catalog.with_name(name).read_bytes(), b"unrelated bytes\n"
            )

    def test_fifo_transaction_artifact_fails_promptly_without_hanging(self):
        self.register()
        catalog_before = self.catalog.read_bytes()
        preimage_sha = hashlib.sha256(catalog_before).hexdigest()
        content_sha = hashlib.sha256(b"staged-new bytes\n").hexdigest()
        fifo = self.catalog.with_name(
            f".source-catalog.json.txn-{preimage_sha}-{content_sha}"
        )
        os.mkfifo(fifo)
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")

        result = self.run_registration_subprocess(
            second,
            {
                **LINEAR_METADATA,
                "source_id": "SECOND",
                "locator": "linear:second",
            },
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("MIGRATION_CATALOG_RECOVERY_REQUIRED", result.stdout)
        self.assertIn(fifo.name, result.stdout)
        self.assertEqual(self.catalog.read_bytes(), catalog_before)
        self.assertTrue(stat.S_ISFIFO(fifo.lstat().st_mode))

    def test_socket_transaction_artifact_fails_promptly_without_hanging(self):
        self.register()
        catalog_before = self.catalog.read_bytes()
        socket_path = self.catalog.with_name(".source-catalog.json.txnX")
        listener = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        try:
            with contextlib.chdir(self.catalog.parent):
                listener.bind(socket_path.name)
            second = self.raw.with_name("second.md")
            second.write_text("second\n", encoding="utf-8")
            result = self.run_registration_subprocess(
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )
        finally:
            listener.close()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("MIGRATION_CATALOG_RECOVERY_REQUIRED", result.stdout)
        self.assertIn(socket_path.name, result.stdout)
        self.assertEqual(self.catalog.read_bytes(), catalog_before)
        self.assertTrue(stat.S_ISSOCK(socket_path.lstat().st_mode))

    def test_nonregular_transaction_candidates_fail_without_fd_leaks(self):
        self.register()
        catalog_before = self.catalog.read_bytes()
        preimage_sha = hashlib.sha256(catalog_before).hexdigest()
        content_sha = hashlib.sha256(b"staged-new bytes\n").hexdigest()
        base_name = f".source-catalog.json.txn-{preimage_sha}-{content_sha}"
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")
        before_fds = len(os.listdir("/dev/fd"))

        for suffix, create in (
            ("", lambda path: path.mkdir()),
            ("X", lambda path: path.symlink_to(self.raw)),
        ):
            artifact = self.catalog.with_name(base_name + suffix)
            create(artifact)
            with self.assertRaises(CanonError) as caught:
                register_source(
                    self.catalog,
                    second,
                    {
                        **LINEAR_METADATA,
                        "source_id": "SECOND",
                        "locator": "linear:second",
                    },
                )
            self.assertEqual(
                caught.exception.code, "MIGRATION_CATALOG_RECOVERY_REQUIRED"
            )
            self.assertIn(artifact.name, str(caught.exception))
            if artifact.is_dir():
                artifact.rmdir()
            else:
                artifact.unlink()

        self.assertEqual(self.catalog.read_bytes(), catalog_before)
        self.assertEqual(len(os.listdir("/dev/fd")), before_fds)

    def test_device_mode_transaction_candidate_is_rejected_before_open(self):
        self.register()
        catalog_before = self.catalog.read_bytes()
        preimage_sha = hashlib.sha256(catalog_before).hexdigest()
        staged = b"staged-new bytes\n"
        content_sha = hashlib.sha256(staged).hexdigest()
        artifact = self.catalog.with_name(
            f".source-catalog.json.txn-{preimage_sha}-{content_sha}"
        )
        artifact.write_bytes(staged)
        original_stat = migration.os.stat
        original_open = migration.os.open
        actual_stat = artifact.stat()
        fake_values = list(actual_stat)
        fake_values[0] = stat.S_IFCHR | 0o600
        fake_device = os.stat_result(fake_values)
        artifact_opens = 0

        def report_device(path: object, *args: object, **kwargs: object):
            if path == artifact.name and kwargs.get("dir_fd") is not None:
                return fake_device
            return original_stat(path, *args, **kwargs)

        def count_artifact_open(path: object, *args: object, **kwargs: object):
            nonlocal artifact_opens
            if path == artifact.name and kwargs.get("dir_fd") is not None:
                artifact_opens += 1
            return original_open(path, *args, **kwargs)

        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")
        with (
            mock.patch.object(migration.os, "stat", side_effect=report_device),
            mock.patch.object(migration.os, "open", side_effect=count_artifact_open),
            self.assertRaises(CanonError) as caught,
        ):
            register_source(
                self.catalog,
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )

        self.assertEqual(caught.exception.code, "MIGRATION_CATALOG_RECOVERY_REQUIRED")
        self.assertIn(artifact.name, str(caught.exception))
        self.assertEqual(artifact_opens, 0)
        self.assertEqual(self.catalog.read_bytes(), catalog_before)

    def test_stat_open_replacement_race_fails_promptly_without_hanging(self):
        self.register()
        catalog_before = self.catalog.read_bytes()
        preimage_sha = hashlib.sha256(catalog_before).hexdigest()
        staged = b"staged-new bytes\n"
        content_sha = hashlib.sha256(staged).hexdigest()
        artifact = self.catalog.with_name(
            f".source-catalog.json.txn-{preimage_sha}-{content_sha}"
        )
        artifact.write_bytes(staged)
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")
        script = """
import json
import os
import sys
from pathlib import Path
import tools.ambitions_canon.migration as migration
from tools.ambitions_canon.migration import register_source
from tools.ambitions_canon.model import CanonError

catalog = Path(sys.argv[1])
artifact_name = sys.argv[4]
original_stat = migration.os.stat
raced = False
def race_after_stat(path, *args, **kwargs):
    global raced
    result = original_stat(path, *args, **kwargs)
    if path == artifact_name and kwargs.get("dir_fd") is not None and not raced:
        raced = True
        os.unlink(path, dir_fd=kwargs["dir_fd"])
        os.mkfifo(path, dir_fd=kwargs["dir_fd"])
    return result
migration.os.stat = race_after_stat
try:
    register_source(catalog, Path(sys.argv[2]), json.loads(sys.argv[3]))
except CanonError as error:
    print(error.code)
    print(error)
    raise SystemExit(0)
raise SystemExit(3)
"""

        result = subprocess.run(
            (
                sys.executable,
                "-c",
                script,
                str(self.catalog),
                str(second),
                json.dumps(
                    {
                        **LINEAR_METADATA,
                        "source_id": "SECOND",
                        "locator": "linear:second",
                    },
                    sort_keys=True,
                ),
                artifact.name,
            ),
            cwd=Path(__file__).resolve().parents[2],
            check=False,
            capture_output=True,
            text=True,
            timeout=2.0,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertRegex(
            result.stdout,
            r"MIGRATION_CATALOG_(RECOVERY_REQUIRED|CHANGED)",
        )
        self.assertEqual(self.catalog.read_bytes(), catalog_before)
        self.assertTrue(stat.S_ISFIFO(artifact.lstat().st_mode))

    def test_preimage_hash_transaction_recovery_blocks_subsequent_catalog_mutation(
        self,
    ):
        self.register()
        prior = self.catalog.read_bytes()
        preimage_sha = hashlib.sha256(prior).hexdigest()
        staged_sha = hashlib.sha256(b"different staged-new bytes\n").hexdigest()
        transaction = self.catalog.with_name(
            f".source-catalog.json.txn-{preimage_sha}-{staged_sha}"
        )
        transaction.write_bytes(prior)
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")

        with self.assertRaises(CanonError) as caught:
            register_source(
                self.catalog,
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )

        self.assertEqual(caught.exception.code, "MIGRATION_CATALOG_RECOVERY_REQUIRED")
        self.assertIn(transaction.name, str(caught.exception))
        self.assertEqual(self.catalog.read_bytes(), prior)
        self.assertEqual(transaction.read_bytes(), prior)

    def test_unsafe_transaction_alias_blocks_subsequent_catalog_mutation(self):
        _error, _prior, artifacts = (
            self.force_rollback_failure_with_recovery_move_error(errno.EIO)
        )
        transaction = next(
            path for path in artifacts if self.is_transaction_artifact(path)
        )
        external = self.root / "external-recovery-evidence"
        external.write_bytes(b"external exact bytes\n")
        transaction.unlink()
        transaction.symlink_to(external)
        catalog_before = self.catalog.read_bytes()
        third = self.raw.with_name("third.md")
        third.write_text("third\n", encoding="utf-8")

        with self.assertRaises(CanonError) as caught:
            register_source(
                self.catalog,
                third,
                {
                    **LINEAR_METADATA,
                    "source_id": "THIRD",
                    "locator": "linear:third",
                },
            )

        self.assertEqual(caught.exception.code, "MIGRATION_CATALOG_RECOVERY_REQUIRED")
        self.assertIn(transaction.name, str(caught.exception))
        self.assertEqual(self.catalog.read_bytes(), catalog_before)
        self.assertTrue(transaction.is_symlink())
        self.assertEqual(external.read_bytes(), b"external exact bytes\n")

    def test_recovery_collision_exhaustion_reports_existing_transaction_locator(self):
        self.register()
        concurrent = b'{"concurrent":"collision exhaustion prior"}\n'
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")
        original_read = migration._read_catalog_at
        original_exchange = migration._rename_exchange
        original_noreplace = migration._rename_noreplace
        read_calls = 0
        exchange_calls = 0

        def edit_after_revalidation(*args: object, **kwargs: object):
            nonlocal read_calls
            result = original_read(*args, **kwargs)
            if len(args) > 1 and args[1] == self.catalog.name:
                read_calls += 1
            if read_calls == 2 and len(args) > 1 and args[1] == self.catalog.name:
                self.catalog.write_bytes(concurrent)
            return result

        def fail_exchange_back(*args: object, **kwargs: object) -> None:
            nonlocal exchange_calls
            exchange_calls += 1
            if exchange_calls == 2:
                raise OSError("forced rollback failure")
            original_exchange(*args, **kwargs)

        def collide_every_recovery_name(
            source: str,
            destination: str,
            **kwargs: object,
        ) -> None:
            if ".recovery-prior" in destination:
                if len(destination.encode("utf-8")) > 240:
                    raise OSError(errno.ENAMETOOLONG, "forced name limit", destination)
                candidate = self.catalog.parent / destination
                if not candidate.exists():
                    candidate.write_bytes(destination.encode("utf-8") + b"\n")
                raise FileExistsError(errno.EEXIST, "forced collision", destination)
            original_noreplace(source, destination, **kwargs)

        with (
            mock.patch.object(
                migration,
                "_read_catalog_at",
                side_effect=edit_after_revalidation,
            ),
            mock.patch.object(
                migration,
                "_rename_exchange",
                side_effect=fail_exchange_back,
            ),
            mock.patch.object(
                migration,
                "_rename_noreplace",
                side_effect=collide_every_recovery_name,
            ),
            self.assertRaises(CanonError) as caught,
        ):
            register_source(
                self.catalog,
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )

        transactions = self.catalog_transaction_artifacts()
        self.assertEqual(caught.exception.code, "MIGRATION_CATALOG_RECOVERY_REQUIRED")
        self.assertEqual(len(transactions), 1)
        self.assertIn(transactions[0].name, str(caught.exception))
        self.assertEqual(transactions[0].read_bytes(), concurrent)

        for recovery in self.catalog.parent.glob(
            ".source-catalog.json.recovery-prior*"
        ):
            recovery.unlink()
        catalog_before = self.catalog.read_bytes()
        third = self.raw.with_name("third.md")
        third.write_text("third\n", encoding="utf-8")
        with self.assertRaises(CanonError) as retry:
            register_source(
                self.catalog,
                third,
                {
                    **LINEAR_METADATA,
                    "source_id": "THIRD",
                    "locator": "linear:third",
                },
            )
        self.assertEqual(retry.exception.code, "MIGRATION_CATALOG_RECOVERY_REQUIRED")
        self.assertIn(transactions[0].name, str(retry.exception))
        self.assertEqual(self.catalog.read_bytes(), catalog_before)
        self.assertEqual(transactions[0].read_bytes(), concurrent)

    def test_identical_deterministic_transaction_name_collision_is_idempotent_and_fd_clean(
        self,
    ):
        self.register()
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")
        original_prepare = getattr(migration, "_prepare_catalog_staging", None)
        calls = 0
        before_fds = len(os.listdir("/dev/fd"))

        def precreate_identical(
            parent_descriptor: int,
            transaction_name: str,
            content: bytes,
            absolute: Path,
        ):
            nonlocal calls
            calls += 1
            descriptor = os.open(
                transaction_name,
                os.O_WRONLY | os.O_CREAT | os.O_EXCL,
                0o600,
                dir_fd=parent_descriptor,
            )
            try:
                os.write(descriptor, content)
                os.fsync(descriptor)
            finally:
                os.close(descriptor)
            assert original_prepare is not None
            return original_prepare(
                parent_descriptor,
                transaction_name,
                content,
                absolute,
            )

        with mock.patch.object(
            migration,
            "_prepare_catalog_staging",
            side_effect=precreate_identical,
            create=True,
        ):
            register_source(
                self.catalog,
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )

        self.assertEqual(calls, 1)
        self.assertEqual(len(load_source_catalog(self.catalog)), 2)
        self.assertEqual(self.catalog_transaction_artifacts(), ())
        self.assertEqual(len(os.listdir("/dev/fd")), before_fds)

    def test_preexisting_staged_new_transaction_is_reused_and_cleaned_on_retry(self):
        self.register()
        second = self.raw.with_name("second.md")
        second.write_text("second\n", encoding="utf-8")

        def persist_staged_new_then_abort(
            parent_descriptor: int,
            transaction_name: str,
            content: bytes,
            _absolute: Path,
        ) -> None:
            descriptor = os.open(
                transaction_name,
                os.O_WRONLY | os.O_CREAT | os.O_EXCL,
                0o600,
                dir_fd=parent_descriptor,
            )
            try:
                os.write(descriptor, content)
                os.fsync(descriptor)
            finally:
                os.close(descriptor)
            os.fsync(parent_descriptor)
            raise CanonError("FORCED_STAGING_CRASH", "retain staged-new evidence")

        with (
            mock.patch.object(
                migration,
                "_prepare_catalog_staging",
                side_effect=persist_staged_new_then_abort,
            ),
            self.assertRaisesRegex(CanonError, "FORCED_STAGING_CRASH"),
        ):
            register_source(
                self.catalog,
                second,
                {
                    **LINEAR_METADATA,
                    "source_id": "SECOND",
                    "locator": "linear:second",
                },
            )

        staged = self.catalog_transaction_artifacts()
        self.assertEqual(len(staged), 1)
        staged_bytes = staged[0].read_bytes()
        content_sha = staged[0].name.rsplit("-", 1)[1]
        self.assertEqual(hashlib.sha256(staged_bytes).hexdigest(), content_sha)

        register_source(
            self.catalog,
            second,
            {
                **LINEAR_METADATA,
                "source_id": "SECOND",
                "locator": "linear:second",
            },
        )

        self.assertEqual(len(load_source_catalog(self.catalog)), 2)
        self.assertEqual(self.catalog_transaction_artifacts(), ())

    def test_metadata_and_catalog_strings_must_be_strict_utf8(self):
        with self.assertRaisesRegex(CanonError, "MIGRATION_METADATA_INVALID"):
            self.register(title="invalid-surrogate-\ud800")
        self.assertFalse(self.catalog.exists())

        self.register()
        payload = json.loads(self.catalog.read_text(encoding="utf-8"))
        payload["sources"][0]["title"] = "invalid-surrogate-\ud800"
        self.catalog.write_text(
            json.dumps(payload, ensure_ascii=True),
            encoding="utf-8",
        )
        with self.assertRaisesRegex(CanonError, "MIGRATION_CATALOG_INVALID"):
            load_source_catalog(self.catalog)

    def test_public_verify_source_rejects_path_substitution_and_symlink(self):
        record = self.register()
        substituted = self.raw.with_name("copy.md")
        substituted.write_bytes(self.raw.read_bytes())
        self.assertEqual(
            [finding.code for finding in verify_source(record, substituted)],
            ["MIGRATION_SOURCE_PATH_MISMATCH"],
        )

        with tempfile.TemporaryDirectory() as external_directory:
            external_root = Path(external_directory)
            subprocess.run(
                ("git", "init", "-q"),
                cwd=external_root,
                check=True,
            )
            (external_root / ".gitignore").write_text(
                ".codex/\n",
                encoding="utf-8",
            )
            external_copy = external_root / record.raw_path
            external_copy.parent.mkdir(parents=True)
            external_copy.write_bytes(self.raw.read_bytes())
            self.assertEqual(
                [finding.code for finding in verify_source(record, external_copy)],
                ["MIGRATION_SOURCE_PATH_MISMATCH"],
            )

        original = self.raw.with_name("original.md")
        self.raw.rename(original)
        self.raw.symlink_to(original)
        self.assertEqual(
            [finding.code for finding in verify_source(record, self.raw)],
            ["MIGRATION_RAW_UNREADABLE"],
        )

    def test_public_verify_source_binds_repo_record_to_exact_tracked_path(self):
        other = self.root / "OTHER.md"
        other.write_text("# Test\n", encoding="utf-8")
        self.git("add", "OTHER.md")
        self.git("commit", "-qm", "add same-content alternate")
        record = register_repo_sources(self.catalog, self.root, ("README.md",))[0]

        self.assertEqual(verify_source(record, self.root / "README.md"), ())
        self.assertEqual(
            [finding.code for finding in verify_source(record, other)],
            ["MIGRATION_SOURCE_PATH_MISMATCH"],
        )

    def test_public_verify_source_rejects_invalid_kind_and_kind_shape(self):
        raw_record = self.register()
        invalid_records = (
            object(),
            replace(raw_record, kind="bogus"),
            replace(raw_record, kind="repo"),
            replace(raw_record, kind="source"),
        )
        for record in invalid_records:
            with self.subTest(record=record):
                self.assertEqual(
                    [finding.code for finding in verify_source(record, self.raw)],
                    ["MIGRATION_SOURCE_INVALID"],
                )

        self.catalog.unlink()
        repo_record = register_repo_sources(
            self.catalog,
            self.root,
            ("README.md",),
        )[0]
        self.assertEqual(
            [
                finding.code
                for finding in verify_source(
                    replace(repo_record, kind="linear"),
                    self.root / "README.md",
                )
            ],
            ["MIGRATION_SOURCE_INVALID"],
        )
        for kind in ("repo", "source", "test", "proof"):
            with self.subTest(kind=kind):
                self.assertEqual(
                    verify_source(
                        replace(repo_record, kind=kind),
                        self.root / "README.md",
                    ),
                    (),
                )

    def test_repo_registration_rejects_index_flags_and_non_index_worktree_state(self):
        cases = ("assume-unchanged", "skip-worktree", "chmod", "staged-blob")
        for case in cases:
            with self.subTest(case=case):
                self.git("reset", "--hard", "HEAD")
                self.git("update-index", "--no-assume-unchanged", "README.md")
                self.git("update-index", "--no-skip-worktree", "README.md")
                os.chmod(self.root / "README.md", 0o644)
                if case == "assume-unchanged":
                    self.git("update-index", "--assume-unchanged", "README.md")
                    (self.root / "README.md").write_text(
                        "hidden worktree edit\n",
                        encoding="utf-8",
                    )
                elif case == "skip-worktree":
                    self.git("update-index", "--skip-worktree", "README.md")
                elif case == "chmod":
                    os.chmod(self.root / "README.md", 0o755)
                else:
                    (self.root / "README.md").write_text(
                        "staged replacement\n",
                        encoding="utf-8",
                    )
                    self.git("add", "README.md")

                with self.assertRaisesRegex(CanonError, "MIGRATION_REPO_DIRTY"):
                    register_repo_sources(self.catalog, self.root, ("README.md",))
                self.assertFalse(self.catalog.exists())

    def test_repo_registration_revalidates_mid_run_index_mutation(self):
        original_read = migration._read_regular_nofollow
        mutated = False

        def mutate_index_after_read(path: Path, code: str) -> bytes:
            nonlocal mutated
            content = original_read(path, code)
            if Path(path).name == "README.md" and not mutated:
                mutated = True
                self.git("update-index", "--chmod=+x", "README.md")
            return content

        with (
            mock.patch.object(
                migration,
                "_read_regular_nofollow",
                side_effect=mutate_index_after_read,
            ),
            self.assertRaisesRegex(CanonError, "MIGRATION_REPO_CHANGED"),
        ):
            register_repo_sources(self.catalog, self.root, ("README.md",))
        self.assertFalse(self.catalog.exists())

    def test_repo_registration_and_verify_reject_dirty_missing_or_untracked_source(
        self,
    ):
        (self.root / "README.md").write_text("dirty\n", encoding="utf-8")
        with self.assertRaisesRegex(CanonError, "MIGRATION_REPO_DIRTY"):
            register_repo_sources(self.catalog, self.root, ("README.md",))

        self.git("checkout", "--", "README.md")
        record = register_repo_sources(self.catalog, self.root, ("README.md",))[0]
        (self.root / "README.md").write_text("dirty later\n", encoding="utf-8")
        self.assertEqual(
            [item.code for item in verify_catalog(self.catalog, self.root)],
            ["MIGRATION_REPO_DIRTY"],
        )

        self.git("checkout", "--", "README.md")
        self.git("rm", "-q", "README.md")
        self.assertEqual(
            [item.code for item in verify_catalog(self.catalog, self.root)],
            ["MIGRATION_REPO_NOT_TRACKED"],
        )
        self.assertIsInstance(record, SourceRecord)

    def test_cli_register_verify_and_verify_failure_exit_codes(self):
        previous = Path.cwd()
        stdout = io.StringIO()
        try:
            os.chdir(self.root)
            with contextlib.redirect_stdout(stdout):
                result = main(
                    (
                        "migration",
                        "register",
                        "--catalog",
                        "docs/canon/migration/source-catalog.json",
                        "--raw",
                        ".codex/canon-migration/sources/linear-v3.md",
                        "--source-id",
                        "LINEAR-CANON-V3",
                        "--kind",
                        "linear",
                        "--title",
                        "Canonical Linear v3",
                        "--locator",
                        LINEAR_METADATA["locator"],
                        "--updated-at",
                        LINEAR_METADATA["updated_at"],
                        "--owner",
                        LINEAR_METADATA["owner"],
                        "--authority-claim",
                        LINEAR_METADATA["authority_claim"],
                    )
                )
                verified = main(
                    (
                        "migration",
                        "verify",
                        "--catalog",
                        "docs/canon/migration/source-catalog.json",
                    )
                )
            self.raw.write_text("changed\n", encoding="utf-8")
            with contextlib.redirect_stdout(stdout):
                failed = main(
                    (
                        "migration",
                        "verify",
                        "--catalog",
                        "docs/canon/migration/source-catalog.json",
                    )
                )
        finally:
            os.chdir(previous)

        self.assertEqual((result, verified, failed), (0, 0, 1))
        self.assertIn("MIGRATION_RAW_CHECKSUM_MISMATCH", stdout.getvalue())


if __name__ == "__main__":
    unittest.main()
