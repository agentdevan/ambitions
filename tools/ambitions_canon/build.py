"""Deterministic, confined generation for Ambitions canon projections."""

from __future__ import annotations

import ctypes
import errno
import hashlib
import os
import secrets
import stat
import sys
from collections.abc import Callable, Iterable, Mapping, Sequence
from contextlib import contextmanager
from dataclasses import dataclass
from pathlib import Path, PurePosixPath

from tools.ambitions_canon.audit import audit_registry
from tools.ambitions_canon.command_resolution_registry import (
    validate_repository_command_resolutions,
)
from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.model import (
    CanonError,
    CanonRegistry,
    Finding,
    GapSeverity,
)
from tools.ambitions_canon.registry import build_registry
from tools.ambitions_canon.render import _render_outputs


DIRECTORY_FLAGS = (
    os.O_RDONLY
    | os.O_DIRECTORY
    | os.O_NOFOLLOW
    | getattr(os, "O_CLOEXEC", 0)
)
READ_FLAGS = (
    os.O_RDONLY
    | os.O_NONBLOCK
    | os.O_NOFOLLOW
    | getattr(os, "O_CLOEXEC", 0)
)
WRITE_FLAGS = (
    os.O_WRONLY
    | os.O_CREAT
    | os.O_EXCL
    | os.O_NOFOLLOW
    | getattr(os, "O_CLOEXEC", 0)
)
UNSUPPORTED_DIRECTORY_FSYNC = frozenset(
    value
    for value in (
        errno.EINVAL,
        getattr(errno, "ENOTSUP", None),
        getattr(errno, "EOPNOTSUPP", None),
        getattr(errno, "EROFS", None),
    )
    if value is not None
)
MACOS_ROOT_ALIASES = frozenset({"etc", "tmp", "var"})
DARWIN_RENAME_EXCL = 0x00000004
LINUX_RENAME_NOREPLACE = 0x00000001


def canon_content_sha(
    manifest_path: Path,
    source_paths: Iterable[Path],
) -> str:
    """Hash canonical source labels and bytes independent of caller ordering."""

    manifest_absolute = _normalized_absolute(manifest_path)
    canon_root = manifest_absolute.parent
    entries: list[tuple[str, bytes]] = [
        ("MANIFEST.toml", _read_confined_bytes(canon_root, Path("MANIFEST.toml")))
    ]
    ledger_path = Path("decisions/SUPERSESSION_LEDGER.toml")
    try:
        ledger_bytes = _read_confined_bytes(canon_root, ledger_path)
    except CanonError:
        ledger_bytes = None
    if ledger_bytes is not None:
        entries.append((ledger_path.as_posix(), ledger_bytes))
    index_path = Path("migration/impact-reference-index.json")
    try:
        index_bytes = _read_confined_bytes(canon_root, index_path)
    except CanonError:
        index_bytes = None
    if index_bytes is not None:
        entries.append((index_path.as_posix(), index_bytes))
    for source_path in source_paths:
        absolute = _normalized_absolute(source_path)
        try:
            relative = absolute.relative_to(canon_root)
        except ValueError as exc:
            raise CanonError(
                "CANON_CONTENT_PATH",
                "canonical source is outside the manifest directory",
                source_path,
            ) from exc
        if not _is_canonical_relative(relative):
            raise CanonError(
                "CANON_CONTENT_PATH",
                "canonical source path is invalid",
                source_path,
            )
        entries.append(
            (relative.as_posix(), _read_confined_bytes(canon_root, relative))
        )
    return _content_sha_entries(entries)


def _content_sha_entries(entries: Iterable[tuple[str, bytes]]) -> str:
    ordered = sorted(entries, key=lambda item: item[0])
    labels = tuple(label for label, _ in ordered)
    if len(labels) != len(set(labels)):
        raise CanonError(
            "CANON_CONTENT_PATH",
            "canonical source path is duplicated",
        )
    digest = hashlib.sha256()
    for label, content in ordered:
        if not isinstance(content, bytes):
            raise CanonError(
                "CANON_PROVENANCE_MISSING",
                f"canonical source bytes are unavailable: {label}",
            )
        encoded_label = label.encode("utf-8")
        digest.update(len(encoded_label).to_bytes(8, "big"))
        digest.update(encoded_label)
        digest.update(len(content).to_bytes(8, "big"))
        digest.update(content)
    return digest.hexdigest()


def write_outputs_atomic(
    root: Path,
    outputs: Mapping[Path, bytes],
    *,
    precondition: Callable[[], None] | None = None,
    postcondition: Callable[[], None] | None = None,
) -> None:
    """Commit a complete tree and retain recovery material until validation.

    Directory fsync is attempted for staged and rename parents. Filesystems that
    explicitly report directory fsync as unsupported are the only portability
    exception; file fsync and descriptor-relative rename still apply.
    """

    validated = _validated_outputs(outputs)
    with _open_parent_nofollow(root) as (
        parent_descriptor,
        root_name,
        absolute_root,
    ):
        root_kind, initial_root_identity = _entry_kind_and_identity(
            parent_descriptor,
            root_name,
        )
        if root_kind == "symlink":
            raise _path_escape(absolute_root)
        if root_kind not in (None, "directory"):
            raise CanonError(
                "CANON_GENERATED_PATH",
                "generated root must be a real directory",
                root,
            )

        staging_name: str | None = None
        staging_identity: tuple[int, int] | None = None
        staging_descriptor: int | None = None
        try:
            staging_name = _create_unique_directory(
                parent_descriptor,
                ".ambitions-canon-build-",
            )
            staging_identity = _entry_identity(parent_descriptor, staging_name)
            if staging_identity is None:
                raise OSError(errno.ESTALE, "staging entry disappeared")
            staging_descriptor = _open_directory_at(
                parent_descriptor,
                staging_name,
            )
            if _descriptor_identity(staging_descriptor) != staging_identity:
                raise OSError(errno.ESTALE, "staging identity changed at open")
            _fsync_directory(parent_descriptor)
        except (OSError, CanonError) as staging_error:
            if staging_descriptor is not None:
                try:
                    os.close(staging_descriptor)
                except OSError:
                    pass
            if staging_name is not None:
                _cleanup_tree_best_effort(
                    parent_descriptor,
                    staging_name,
                    staging_identity,
                )
            raise CanonError(
                "CANON_GENERATED_WRITE",
                "unable to open the pinned staging directory",
                absolute_root,
            ) from staging_error
        assert staging_name is not None
        assert staging_identity is not None
        assert staging_descriptor is not None
        previous_name: str | None = None
        try:
            _stage_outputs(staging_descriptor, validated)
            staged_descriptor = _open_directory_at(staging_descriptor, "next")
            try:
                staged_paths = _tree_files_descriptor(staged_descriptor)
                installed_identity = _descriptor_identity(staged_descriptor)
            finally:
                os.close(staged_descriptor)
            expected_paths = tuple(path for path, _ in validated)
            if staged_paths != expected_paths:
                raise CanonError(
                    "CANON_GENERATED_WRITE",
                    "staged generated tree does not match expected outputs",
                    root,
                )

            if precondition is not None:
                precondition()

            previous_identity: tuple[int, int] | None = None
            if root_kind == "directory":
                previous_identity = initial_root_identity
                assert previous_identity is not None
                previous_name = _unique_unused_name(
                    parent_descriptor,
                    ".ambitions-canon-previous-",
                )
                _assert_visible_entry_identity(
                    parent_descriptor,
                    root_name,
                    previous_identity,
                    absolute_root,
                )
                try:
                    os.replace(
                        root_name,
                        previous_name,
                        src_dir_fd=parent_descriptor,
                        dst_dir_fd=parent_descriptor,
                    )
                    hidden_identity = _entry_identity(
                        parent_descriptor,
                        previous_name,
                    )
                    if hidden_identity != previous_identity:
                        if hidden_identity is not None:
                            _quarantine_visible_entry(
                                parent_descriptor,
                                previous_name,
                                hidden_identity,
                            )
                        _cleanup_tree_best_effort(
                            parent_descriptor,
                            staging_name,
                            staging_identity,
                        )
                        raise _recovery_required_error(
                            absolute_root.parent,
                            parent_descriptor,
                            previous_name,
                            previous_identity,
                        )
                    _fsync_directory(parent_descriptor)
                except OSError as durability_error:
                    _recover_failed_transaction(
                        parent_descriptor,
                        root_name,
                        previous_name,
                        previous_identity,
                        installed_identity,
                        staging_descriptor,
                        staging_name,
                        staging_identity,
                        absolute_root,
                        durability_error,
                    )

            try:
                _rename_noreplace(
                    "next",
                    root_name,
                    source_directory=staging_descriptor,
                    destination_directory=parent_descriptor,
                )
            except (OSError, CanonError) as commit_error:
                _recover_failed_transaction(
                    parent_descriptor,
                    root_name,
                    previous_name,
                    previous_identity,
                    installed_identity,
                    staging_descriptor,
                    staging_name,
                    staging_identity,
                    absolute_root,
                    commit_error,
                )

            try:
                _fsync_directory(staging_descriptor)
                _fsync_directory(parent_descriptor)
                _assert_visible_entry_identity(
                    parent_descriptor,
                    root_name,
                    installed_identity,
                    absolute_root,
                )
                _assert_parent_path_identity(
                    absolute_root.parent,
                    parent_descriptor,
                )
                if postcondition is not None:
                    postcondition()
                _assert_visible_entry_identity(
                    parent_descriptor,
                    root_name,
                    installed_identity,
                    absolute_root,
                )
                _assert_parent_path_identity(
                    absolute_root.parent,
                    parent_descriptor,
                )
            except Exception as postcondition_error:
                _recover_failed_transaction(
                    parent_descriptor,
                    root_name,
                    previous_name,
                    previous_identity,
                    installed_identity,
                    staging_descriptor,
                    staging_name,
                    staging_identity,
                    absolute_root,
                    postcondition_error,
                )

            if previous_name is not None:
                _cleanup_tree_best_effort(
                    parent_descriptor,
                    previous_name,
                    previous_identity,
                )
            _cleanup_tree_best_effort(
                parent_descriptor,
                staging_name,
                staging_identity,
            )
            try:
                _assert_parent_path_identity(
                    absolute_root.parent,
                    parent_descriptor,
                )
                _assert_visible_entry_identity(
                    parent_descriptor,
                    root_name,
                    installed_identity,
                    absolute_root,
                )
            except CanonError as final_error:
                _fail_after_final_validation(
                    parent_descriptor,
                    root_name,
                    installed_identity,
                    absolute_root,
                    final_error,
                )
        except CanonError:
            if previous_name is None or _entry_kind(parent_descriptor, previous_name) is None:
                _cleanup_tree_best_effort(
                    parent_descriptor,
                    staging_name,
                    staging_identity,
                )
            raise
        except OSError as exc:
            _cleanup_tree_best_effort(
                parent_descriptor,
                staging_name,
                staging_identity,
            )
            raise CanonError(
                "CANON_GENERATED_WRITE",
                "unable to atomically replace generated outputs",
                root,
            ) from exc
        finally:
            os.close(staging_descriptor)


def check_outputs(
    root: Path,
    outputs: Mapping[Path, bytes],
    *,
    allowed_extra_paths: frozenset[Path] = frozenset(),
) -> tuple[Finding, ...]:
    """Compare generated bytes without following any path component."""

    validated = _validated_outputs(outputs)
    if any(not _is_canonical_relative(path) for path in allowed_extra_paths):
        raise CanonError(
            "CANON_GENERATED_PATH",
            "allowed generated extra path must be canonical and relative",
            root,
        )
    effective_allowed_extras = set(allowed_extra_paths)
    if (
        root.name == "generated"
        and root.parent.name == "canon"
        and root.parent.parent.name == "docs"
        and not (
            root.parent.parent.parent
            / "tests/canon/fixtures/benchmarks"
        ).exists()
    ):
        effective_allowed_extras.add(Path("codex-consumption-benchmark.md"))
    expected = {path: content for path, content in validated}
    findings: list[Finding] = []
    with _open_parent_nofollow(root) as (
        parent_descriptor,
        root_name,
        absolute_root,
    ):
        root_descriptor: int | None = None
        try:
            root_kind = _entry_kind(parent_descriptor, root_name)
            if root_kind == "symlink":
                raise _path_escape(absolute_root)
            if root_kind is None:
                actual_paths: set[Path] = set()
                pinned_root_identity = None
            elif root_kind != "directory":
                raise CanonError(
                    "CANON_GENERATED_PATH",
                    "generated root must be a real directory",
                    root,
                )
            else:
                root_descriptor = _open_directory_at(
                    parent_descriptor,
                    root_name,
                )
                pinned_root_identity = _descriptor_identity(root_descriptor)
                actual_paths = set(_tree_files_descriptor(root_descriptor))

            for path in sorted(expected, key=lambda item: item.as_posix()):
                if path not in actual_paths:
                    findings.append(
                        _generated_finding(
                            "CANON_GENERATED_MISSING",
                            "generated output is missing",
                            path,
                        )
                    )
                    continue
                assert root_descriptor is not None
                try:
                    actual = _read_file_at(root_descriptor, path)
                except CanonError:
                    actual = None
                if actual != expected[path]:
                    findings.append(
                        _generated_finding(
                            "CANON_GENERATED_CHANGED",
                            "generated output differs from canonical render",
                            path,
                        )
                    )
            for path in sorted(
                actual_paths - set(expected) - effective_allowed_extras,
                key=lambda item: item.as_posix(),
            ):
                findings.append(
                    _generated_finding(
                        "CANON_GENERATED_EXTRA",
                        "undeclared generated output is present",
                        path,
                    )
                )
        finally:
            if root_descriptor is not None:
                os.close(root_descriptor)

        _assert_parent_path_identity(
            absolute_root.parent,
            parent_descriptor,
        )
        _assert_visible_entry_identity(
            parent_descriptor,
            root_name,
            pinned_root_identity,
            absolute_root,
        )

    return tuple(
        sorted(
            findings,
            key=lambda item: (
                item.code,
                item.path.as_posix() if item.path else "",
                item.message,
            ),
        )
    )


def build_canon(root: Path, *, check: bool = False) -> tuple[Finding, ...]:
    """Render one loaded snapshot and verify it across output commit/check."""

    from tools.ambitions_canon.conflicts import (
        load_conflict_dockets,
        validate_conflict_repository,
    )

    registry = _load_audited_registry(root)
    from tools.ambitions_canon.external_authority import (
        load_external_reference_snapshot,
        load_figma_reconciliation_if_present,
        load_linear_reconciliation_if_present,
        validate_external_reference_snapshot,
        validate_figma_reconciliation_snapshot,
        validate_linear_reconciliation_snapshot,
    )
    from tools.ambitions_canon.traceability import (
        capture_traceability_input_snapshot,
        validate_traceability_input_snapshot,
    )

    reference_snapshot = load_external_reference_snapshot(root)
    traceability_snapshot = capture_traceability_input_snapshot(
        registry,
        root,
        reference_snapshot,
    )
    linear_reconciliation_snapshot = load_linear_reconciliation_if_present(
        root,
        registry,
        reference_snapshot.references,
    )
    figma_reconciliation_snapshot = load_figma_reconciliation_if_present(
        root,
        registry,
        reference_snapshot.references,
    )
    dockets = load_conflict_dockets(root)
    conflict_snapshot = validate_conflict_repository(
        root,
        dockets,
        (item.requirement_id for item in registry.requirements),
        registry.supersession_entries,
    )
    snapshot_sha = _registry_content_sha(registry, dockets, conflict_snapshot)
    outputs = dict(
        _render_outputs(
            registry,
            snapshot_sha,
            dockets if conflict_snapshot is not None else None,
            traceability_snapshot,
        )
    )
    benchmark_outputs = _deterministic_benchmark_evidence(root)
    outputs.update(benchmark_outputs)

    def assert_snapshot_current() -> None:
        current = _load_audited_registry(root)
        current_dockets = load_conflict_dockets(root)
        current_conflicts = validate_conflict_repository(
            root,
            current_dockets,
            (item.requirement_id for item in current.requirements),
            current.supersession_entries,
        )
        if (
            _registry_content_sha(current, current_dockets, current_conflicts)
            != snapshot_sha
        ):
            raise CanonError(
                "CANON_CONTENT_CHANGED",
                "canonical source changed during generation",
                registry.manifest.source_path,
            )
        validate_external_reference_snapshot(root, reference_snapshot)
        if linear_reconciliation_snapshot is not None:
            validate_linear_reconciliation_snapshot(
                root,
                linear_reconciliation_snapshot,
            )
        if figma_reconciliation_snapshot is not None:
            validate_figma_reconciliation_snapshot(
                root,
                figma_reconciliation_snapshot,
            )
        validate_traceability_input_snapshot(
            current,
            root,
            traceability_snapshot,
        )

    assert_snapshot_current()
    generated_root = root / "docs" / "canon" / "generated"
    if check:
        findings = check_outputs(generated_root, outputs)
        assert_snapshot_current()
        return findings
    write_outputs_atomic(
        generated_root,
        outputs,
        postcondition=assert_snapshot_current,
    )
    return ()


def _deterministic_benchmark_evidence(root: Path) -> dict[Path, bytes]:
    """Rerender benchmark evidence from confined, tracked inputs."""

    from tools.ambitions_canon.benchmark import (
        BENCHMARK_FIXTURE_DIR,
        render_benchmark_report,
        run_benchmark,
    )

    fixture_directory = root / BENCHMARK_FIXTURE_DIR
    try:
        fixture_info = fixture_directory.lstat()
    except FileNotFoundError:
        return {}
    except OSError as exc:
        raise CanonError(
            "BENCHMARK_FIXTURE_INVALID",
            "benchmark fixture directory is unreadable",
            fixture_directory,
        ) from exc
    if not stat.S_ISDIR(fixture_info.st_mode):
        raise CanonError(
            "BENCHMARK_FIXTURE_INVALID",
            "benchmark fixture directory must be a real directory",
            fixture_directory,
        )
    result = run_benchmark(root, fixture_directory)
    return {
        Path("codex-consumption-benchmark.md"): render_benchmark_report(result).encode(
            "utf-8"
        )
    }


def _load_audited_registry(root: Path) -> CanonRegistry:
    manifest = load_manifest(root)
    documents = load_documents(root, manifest)
    current_manifest = load_manifest(root)
    if current_manifest.source_bytes != manifest.source_bytes:
        raise CanonError(
            "CANON_CONTENT_CHANGED",
            "canonical source changed during generation",
            manifest.source_path,
        )
    registry = build_registry(manifest, documents)
    validate_repository_command_resolutions(root, registry)
    findings = audit_registry(registry)
    if findings:
        first = findings[0]
        raise CanonError(first.code, first.message, first.path, first.line)
    return registry


@dataclass(frozen=True, slots=True)
class _AuditedCanonSnapshot:
    """One loader-owned view of every input in the canonical content identity."""

    registry: CanonRegistry
    content_sha: str


def _load_audited_canon_snapshot(root: Path) -> _AuditedCanonSnapshot:
    """Load canon through the canonical audit path and bind conflict inputs too."""

    from tools.ambitions_canon.conflicts import (
        load_conflict_dockets,
        validate_conflict_repository,
    )

    registry = _load_audited_registry(root)
    dockets = load_conflict_dockets(root)
    conflicts = validate_conflict_repository(
        root,
        dockets,
        (item.requirement_id for item in registry.requirements),
        registry.supersession_entries,
    )
    return _AuditedCanonSnapshot(
        registry=registry,
        content_sha=_registry_content_sha(registry, dockets, conflicts),
    )


def _verify_audited_canon_snapshot(
    root: Path,
    expected: _AuditedCanonSnapshot,
) -> None:
    """Fail closed if any canon input changed after the operation began."""

    current = _load_audited_canon_snapshot(root)
    if (
        current.content_sha != expected.content_sha
        or current.registry.manifest.canon_revision
        != expected.registry.manifest.canon_revision
        or current.registry.manifest.authority_state
        is not expected.registry.manifest.authority_state
    ):
        raise CanonError(
            "CANON_CONTENT_CHANGED",
            "canonical source changed during audited operation",
            expected.registry.manifest.source_path,
        )


def _registry_content_sha(
    registry: CanonRegistry,
    dockets: Sequence[object] = (),
    conflict_snapshot: object | None = None,
) -> str:
    if registry.manifest.source_bytes is None:
        raise CanonError(
            "CANON_PROVENANCE_MISSING",
            "loaded manifest source bytes are unavailable",
            registry.manifest.source_path,
        )
    entries: list[tuple[str, bytes]] = [
        ("MANIFEST.toml", registry.manifest.source_bytes)
    ]
    if registry.supersession_ledger_bytes is None:
        raise CanonError(
            "CANON_PROVENANCE_MISSING",
            "loaded supersession ledger bytes are unavailable",
            registry.manifest.source_path,
        )
    entries.append(
        (
            "decisions/SUPERSESSION_LEDGER.toml",
            registry.supersession_ledger_bytes,
        )
    )
    if (
        registry.reference_index is None
        or registry.reference_index.source_bytes is None
    ):
        raise CanonError(
            "CANON_PROVENANCE_MISSING",
            "loaded impact reference index bytes are unavailable",
            registry.manifest.source_path,
        )
    entries.append(
        (
            "migration/impact-reference-index.json",
            registry.reference_index.source_bytes,
        )
    )
    prefix = Path("docs/canon")
    for document in registry.documents:
        if document.source_bytes is None:
            raise CanonError(
                "CANON_PROVENANCE_MISSING",
                "loaded document source bytes are unavailable",
                document.source_path,
            )
        try:
            relative = document.source_path.relative_to(prefix)
        except ValueError as exc:
            raise CanonError(
                "CANON_PROVENANCE_PATH",
                "document provenance is outside docs/canon",
                document.source_path,
            ) from exc
        entries.append((relative.as_posix(), document.source_bytes))
    if dockets:
        from tools.ambitions_canon.conflicts import (
            docket_filename,
            render_conflict_docket,
        )

        entries.extend(
            (
                f"decisions/open/{docket_filename(docket).as_posix()}",
                render_conflict_docket(docket).encode("utf-8"),
            )
            for docket in dockets
        )
    if conflict_snapshot is not None:
        entries.extend(
            (
                (
                    "migration/source-catalog.json",
                    conflict_snapshot.source_catalog_bytes,
                ),
                (
                    "migration/claim-dispositions.json",
                    conflict_snapshot.claim_dispositions_bytes,
                ),
                (
                    "migration/conflict-docket-baseline.json",
                    conflict_snapshot.baseline_bytes,
                ),
            )
        )
    return _content_sha_entries(entries)


def _stage_outputs(
    staging_descriptor: int,
    outputs: tuple[tuple[Path, bytes], ...],
) -> None:
    os.mkdir("next", mode=0o700, dir_fd=staging_descriptor)
    _fsync_directory(staging_descriptor)
    next_descriptor = _open_directory_at(staging_descriptor, "next")
    try:
        for relative_path, content in outputs:
            _create_staged_file(next_descriptor, relative_path, content)
        _fsync_directory(next_descriptor)
    finally:
        os.close(next_descriptor)


def _create_staged_file(root_descriptor: int, path: Path, content: bytes) -> None:
    descriptors = [os.dup(root_descriptor)]
    try:
        current = descriptors[0]
        for component in path.parts[:-1]:
            try:
                os.mkdir(component, mode=0o700, dir_fd=current)
                _fsync_directory(current)
            except FileExistsError:
                pass
            current = _open_directory_at(current, component)
            descriptors.append(current)
        _write_output_file(current, path.parts[-1], content)
        _fsync_directory(current)
    finally:
        for descriptor in reversed(descriptors):
            os.close(descriptor)


def _write_output_file(directory_descriptor: int, name: str, content: bytes) -> None:
    descriptor = os.open(
        name,
        WRITE_FLAGS,
        0o600,
        dir_fd=directory_descriptor,
    )
    try:
        view = memoryview(content)
        while view:
            written = os.write(descriptor, view)
            if written == 0:
                raise OSError(errno.EIO, "short generated output write")
            view = view[written:]
        os.fsync(descriptor)
    finally:
        os.close(descriptor)


def _recover_failed_transaction(
    parent_descriptor: int,
    root_name: str,
    previous_name: str | None,
    previous_identity: tuple[int, int] | None,
    installed_identity: tuple[int, int],
    staging_descriptor: int,
    staging_name: str,
    staging_identity: tuple[int, int],
    absolute_root: Path,
    failure: Exception,
) -> None:
    try:
        visible_identity = _entry_identity(parent_descriptor, root_name)
        previous_visible_identity = (
            _entry_identity(parent_descriptor, previous_name)
            if previous_name is not None
            else None
        )
        if (
            previous_name is not None
            and visible_identity == previous_identity
            and previous_visible_identity is None
        ):
            _cleanup_tree_best_effort(
                parent_descriptor,
                staging_name,
                staging_identity,
            )
            if isinstance(failure, CanonError):
                raise failure
            raise CanonError(
                "CANON_GENERATED_WRITE",
                "generated output transaction failed before prior state moved",
                absolute_root,
            ) from failure
        if visible_identity is not None:
            if visible_identity == installed_identity:
                invalid_name = _unique_unused_name(
                    staging_descriptor,
                    "invalid-",
                )
                os.replace(
                    root_name,
                    invalid_name,
                    src_dir_fd=parent_descriptor,
                    dst_dir_fd=staging_descriptor,
                )
            else:
                _quarantine_visible_entry(parent_descriptor, root_name)
            _recovery_fsync_best_effort(parent_descriptor)
            _recovery_fsync_best_effort(staging_descriptor)

        if previous_name is not None:
            if (
                previous_identity is None
                or _entry_identity(parent_descriptor, previous_name)
                != previous_identity
            ):
                _cleanup_tree_best_effort(
                    parent_descriptor,
                    staging_name,
                    staging_identity,
                )
                raise _recovery_required_error(
                    absolute_root.parent,
                    parent_descriptor,
                    previous_name,
                    previous_identity,
                )
            os.replace(
                previous_name,
                root_name,
                src_dir_fd=parent_descriptor,
                dst_dir_fd=parent_descriptor,
            )
            if (
                _entry_identity(parent_descriptor, root_name)
                != previous_identity
            ):
                _quarantine_visible_entry(parent_descriptor, root_name)
                _cleanup_tree_best_effort(
                    parent_descriptor,
                    staging_name,
                    staging_identity,
                )
                raise _recovery_required_error(
                    absolute_root.parent,
                    parent_descriptor,
                    previous_name,
                    previous_identity,
                )
            _recovery_fsync_best_effort(parent_descriptor)
    except OSError as rollback_error:
        raise _recovery_required_error(
            absolute_root.parent,
            parent_descriptor,
            previous_name,
            previous_identity,
        ) from rollback_error

    _cleanup_tree_best_effort(
        parent_descriptor,
        staging_name,
        staging_identity,
    )
    if isinstance(failure, CanonError):
        raise failure
    if previous_name is None:
        message = (
            "generated output transaction failed and no prior generated tree "
            "existed"
        )
    else:
        message = "generated output transaction failed and prior state was restored"
    raise CanonError(
        "CANON_GENERATED_WRITE",
        message,
        absolute_root,
    ) from failure


def _validated_outputs(
    outputs: Mapping[Path, bytes],
) -> tuple[tuple[Path, bytes], ...]:
    validated: list[tuple[Path, bytes]] = []
    for raw_path, content in outputs.items():
        path = Path(raw_path)
        if not _is_canonical_relative(path) or path == Path("."):
            raise CanonError(
                "CANON_GENERATED_PATH",
                f"invalid generated output path: {path}",
                path,
            )
        if not isinstance(content, bytes):
            raise CanonError(
                "CANON_GENERATED_CONTENT",
                "generated output must be bytes",
                path,
            )
        try:
            content.decode("utf-8")
        except UnicodeDecodeError as exc:
            raise CanonError(
                "CANON_GENERATED_CONTENT",
                "generated output must be UTF-8",
                path,
            ) from exc
        if not content.endswith(b"\n"):
            raise CanonError(
                "CANON_GENERATED_CONTENT",
                "generated text must end with a newline",
                path,
            )
        validated.append((path, content))
    return tuple(sorted(validated, key=lambda item: item[0].as_posix()))


def _is_canonical_relative(path: Path) -> bool:
    raw = path.as_posix()
    pure = PurePosixPath(raw)
    return (
        bool(raw)
        and not path.is_absolute()
        and "\\" not in raw
        and str(pure) == raw
        and all(part not in ("", ".", "..") for part in pure.parts)
    )


def _tree_files_descriptor(
    root_descriptor: int,
    prefix: tuple[str, ...] = (),
) -> tuple[Path, ...]:
    paths: list[Path] = []
    for name in sorted(os.listdir(root_descriptor)):
        info = os.stat(name, dir_fd=root_descriptor, follow_symlinks=False)
        relative = Path(*prefix, name)
        if stat.S_ISDIR(info.st_mode):
            child = _open_directory_at(root_descriptor, name)
            try:
                paths.extend(
                    _tree_files_descriptor(child, prefix + (name,))
                )
            finally:
                os.close(child)
        else:
            paths.append(relative)
    return tuple(sorted(paths, key=lambda item: item.as_posix()))


def _file_identity(info: os.stat_result) -> tuple[int, int, int, int, int]:
    return (
        info.st_dev,
        info.st_ino,
        info.st_size,
        info.st_mtime_ns,
        info.st_ctime_ns,
    )


def _read_file_at_with_identity(
    root_descriptor: int,
    path: Path,
) -> tuple[bytes, tuple[int, int, int, int, int]]:
    """Read one prechecked regular file without blocking or following links."""

    descriptors = [os.dup(root_descriptor)]
    try:
        current = descriptors[0]
        for component in path.parts[:-1]:
            current = _open_directory_at(current, component)
            descriptors.append(current)
        expected = os.stat(
            path.parts[-1], dir_fd=current, follow_symlinks=False
        )
        if not stat.S_ISREG(expected.st_mode):
            raise CanonError(
                "CANON_GENERATED_CONTENT",
                "canonical input is not a regular file",
                path,
            )
        descriptor = os.open(path.parts[-1], READ_FLAGS, dir_fd=current)
        descriptors.append(descriptor)
        opened = os.fstat(descriptor)
        if (
            not stat.S_ISREG(opened.st_mode)
            or (opened.st_dev, opened.st_ino)
            != (expected.st_dev, expected.st_ino)
        ):
            raise CanonError(
                "CANON_GENERATED_CONTENT",
                "canonical input identity changed before open",
                path,
            )
        content = _read_descriptor(descriptor)
        after = os.fstat(descriptor)
        live = os.stat(
            path.parts[-1], dir_fd=current, follow_symlinks=False
        )
        identity = _file_identity(opened)
        if _file_identity(after) != identity or _file_identity(live) != identity:
            raise CanonError(
                "CANON_CONTENT_CHANGED",
                "canonical input changed during descriptor read",
                path,
            )
        return content, identity
    except OSError as exc:
        raise CanonError(
            "CANON_GENERATED_CONTENT",
            "unable to read generated output without following links",
            path,
        ) from exc
    finally:
        for descriptor in reversed(descriptors):
            os.close(descriptor)


def _read_file_at(root_descriptor: int, path: Path) -> bytes:
    return _read_file_at_with_identity(root_descriptor, path)[0]


def _read_confined_bytes(root: Path, relative_path: Path) -> bytes:
    if not _is_canonical_relative(relative_path):
        raise CanonError(
            "CANON_CONTENT_PATH",
            "canonical source path is invalid",
            relative_path,
        )
    with _open_directory_absolute_nofollow(root) as root_descriptor:
        try:
            return _read_file_at(root_descriptor, relative_path)
        except CanonError as exc:
            raise CanonError(
                "CANON_CONTENT_READ",
                "unable to read canonical source bytes",
                root / relative_path,
            ) from exc


def _read_descriptor(descriptor: int) -> bytes:
    chunks: list[bytes] = []
    while chunk := os.read(descriptor, 64 * 1024):
        chunks.append(chunk)
    return b"".join(chunks)


def _entry_kind(parent_descriptor: int, name: str) -> str | None:
    return _entry_kind_and_identity(parent_descriptor, name)[0]


def _entry_kind_and_identity(
    parent_descriptor: int,
    name: str,
) -> tuple[str | None, tuple[int, int] | None]:
    try:
        info = os.stat(name, dir_fd=parent_descriptor, follow_symlinks=False)
    except FileNotFoundError:
        return (None, None)
    identity = (info.st_dev, info.st_ino)
    if stat.S_ISLNK(info.st_mode):
        return ("symlink", identity)
    if stat.S_ISDIR(info.st_mode):
        return ("directory", identity)
    if stat.S_ISREG(info.st_mode):
        return ("file", identity)
    return ("other", identity)


def _descriptor_identity(descriptor: int) -> tuple[int, int]:
    info = os.fstat(descriptor)
    return (info.st_dev, info.st_ino)


def _entry_identity(
    parent_descriptor: int,
    name: str,
) -> tuple[int, int] | None:
    try:
        info = os.stat(name, dir_fd=parent_descriptor, follow_symlinks=False)
    except FileNotFoundError:
        return None
    return (info.st_dev, info.st_ino)


def _assert_visible_entry_identity(
    parent_descriptor: int,
    name: str,
    expected: tuple[int, int] | None,
    absolute_path: Path,
) -> None:
    if _entry_identity(parent_descriptor, name) != expected:
        raise CanonError(
            "CANON_GENERATED_ENTRY_CHANGED",
            "visible generated root entry changed during the transaction",
            absolute_path,
        )


def _open_directory_at(parent_descriptor: int, name: str) -> int:
    return os.open(name, DIRECTORY_FLAGS, dir_fd=parent_descriptor)


def _assert_parent_path_identity(path: Path, descriptor: int) -> None:
    expected = os.fstat(descriptor)
    with _open_directory_absolute_nofollow(path) as current_descriptor:
        current = os.fstat(current_descriptor)
    if (current.st_dev, current.st_ino) != (expected.st_dev, expected.st_ino):
        raise _path_escape(path)


def _verified_recovery_path(
    parent_path: Path,
    parent_descriptor: int,
    name: str | None,
    expected_identity: tuple[int, int] | None,
) -> Path | None:
    if name is None or expected_identity is None:
        return None
    try:
        _assert_parent_path_identity(parent_path, parent_descriptor)
    except CanonError:
        return None
    if _entry_identity(parent_descriptor, name) != expected_identity:
        return None
    return parent_path / name


def _recovery_required_error(
    parent_path: Path,
    parent_descriptor: int,
    name: str | None,
    expected_identity: tuple[int, int] | None,
) -> CanonError:
    if name is None or expected_identity is None:
        recovery_path = None
        message = (
            "no prior generated tree existed; generated state could not be "
            "restored automatically"
        )
    elif _entry_identity(parent_descriptor, name) != expected_identity:
        recovery_path = None
        message = (
            "prior generated state cannot be verified because the expected "
            "recovery identity is missing or replaced"
        )
    else:
        recovery_path = _verified_recovery_path(
            parent_path,
            parent_descriptor,
            name,
            expected_identity,
        )
        if recovery_path is not None:
            message = (
                f"prior generated tree preserved for recovery at {recovery_path}"
            )
        else:
            message = (
                "prior generated tree identity is preserved in pinned parent; "
                "pathname unavailable because parent identity changed"
            )
    return CanonError(
        "CANON_GENERATED_RECOVERY_REQUIRED",
        message,
        recovery_path,
    )


def _quarantine_visible_entry(
    parent_descriptor: int,
    name: str,
    expected_identity: tuple[int, int] | None = None,
) -> str | None:
    identity = _entry_identity(parent_descriptor, name)
    if identity is None:
        return None
    if expected_identity is not None and identity != expected_identity:
        raise OSError(errno.ESTALE, "quarantine entry identity changed")
    quarantine_name = _unique_unused_name(
        parent_descriptor,
        ".ambitions-canon-quarantine-",
    )
    os.replace(
        name,
        quarantine_name,
        src_dir_fd=parent_descriptor,
        dst_dir_fd=parent_descriptor,
    )
    if _entry_identity(parent_descriptor, quarantine_name) != identity:
        raise OSError(errno.ESTALE, "quarantined entry identity changed")
    _recovery_fsync_best_effort(parent_descriptor)
    return quarantine_name


def _fail_after_final_validation(
    parent_descriptor: int,
    root_name: str,
    installed_identity: tuple[int, int],
    absolute_root: Path,
    failure: CanonError,
) -> None:
    try:
        _assert_parent_path_identity(absolute_root.parent, parent_descriptor)
    except CanonError:
        raise failure
    visible_identity = _entry_identity(parent_descriptor, root_name)
    if visible_identity is not None and visible_identity != installed_identity:
        try:
            _quarantine_visible_entry(parent_descriptor, root_name)
        except OSError as quarantine_error:
            raise CanonError(
                "CANON_GENERATED_RECOVERY_REQUIRED",
                "late generated entry changed and quarantine could not be verified",
            ) from quarantine_error
    raise failure


@contextmanager
def _open_parent_nofollow(path: Path):
    absolute = _normalized_absolute(path)
    if not absolute.name:
        raise CanonError(
            "CANON_GENERATED_PATH",
            "generated root must have a final path component",
            path,
        )
    try:
        with _open_directory_absolute_nofollow(absolute.parent) as descriptor:
            yield descriptor, absolute.name, absolute
    except CanonError:
        raise
    except OSError as exc:
        raise _path_error(absolute, exc) from exc


@contextmanager
def _open_directory_absolute_nofollow(path: Path):
    absolute = _normalized_absolute(path)
    descriptors: list[int] = []
    try:
        current = os.open(absolute.anchor, DIRECTORY_FLAGS)
        descriptors.append(current)
        for component in absolute.parts[1:]:
            current = os.open(component, DIRECTORY_FLAGS, dir_fd=current)
            descriptors.append(current)
        yield current
    except CanonError:
        raise
    except OSError as exc:
        raise _path_error(absolute, exc) from exc
    finally:
        for descriptor in reversed(descriptors):
            try:
                os.close(descriptor)
            except OSError:
                pass


def _normalized_absolute(path: Path) -> Path:
    absolute = Path(os.path.abspath(path))
    parts = absolute.parts
    if sys.platform == "darwin" and len(parts) > 1 and parts[1] in MACOS_ROOT_ALIASES:
        first = Path(absolute.anchor) / parts[1]
        try:
            if first.is_symlink():
                target = os.readlink(first)
                target_path = Path(target)
                if not target_path.is_absolute():
                    target_path = Path(absolute.anchor) / target_path
                absolute = target_path.joinpath(*parts[2:])
        except OSError:
            pass
    return absolute


def _create_unique_directory(parent_descriptor: int, prefix: str) -> str:
    for _ in range(128):
        name = f"{prefix}{secrets.token_hex(8)}"
        try:
            os.mkdir(name, mode=0o700, dir_fd=parent_descriptor)
            return name
        except FileExistsError:
            continue
    raise CanonError(
        "CANON_GENERATED_WRITE",
        "unable to allocate a unique staging directory",
    )


def _unique_unused_name(parent_descriptor: int, prefix: str) -> str:
    for _ in range(128):
        name = f"{prefix}{secrets.token_hex(8)}"
        if _entry_kind(parent_descriptor, name) is None:
            return name
    raise CanonError(
        "CANON_GENERATED_WRITE",
        "unable to allocate a unique recovery name",
    )


def _remove_tree_at(
    parent_descriptor: int,
    name: str,
    expected_identity: tuple[int, int] | None = None,
) -> None:
    identity = _entry_identity(parent_descriptor, name)
    if identity is None:
        return
    if expected_identity is not None and identity != expected_identity:
        raise OSError(errno.ESTALE, "cleanup artifact identity changed")
    kind = _entry_kind(parent_descriptor, name)
    if kind != "directory":
        if _entry_identity(parent_descriptor, name) != identity:
            raise OSError(errno.ESTALE, "cleanup entry changed before unlink")
        os.unlink(name, dir_fd=parent_descriptor)
        _fsync_directory(parent_descriptor)
        return
    descriptor = _open_directory_at(parent_descriptor, name)
    try:
        if _descriptor_identity(descriptor) != identity:
            raise OSError(errno.ESTALE, "cleanup directory identity changed")
        for child_name in sorted(os.listdir(descriptor)):
            _remove_tree_at(
                descriptor,
                child_name,
                _entry_identity(descriptor, child_name),
            )
        _fsync_directory(descriptor)
    finally:
        os.close(descriptor)
    if _entry_identity(parent_descriptor, name) != identity:
        raise OSError(errno.ESTALE, "cleanup directory changed before removal")
    os.rmdir(name, dir_fd=parent_descriptor)
    _fsync_directory(parent_descriptor)


def _cleanup_tree_best_effort(
    parent_descriptor: int,
    name: str,
    expected_identity: tuple[int, int] | None,
) -> None:
    try:
        current_identity = _entry_identity(parent_descriptor, name)
        if current_identity is None:
            return
        if expected_identity is None or current_identity != expected_identity:
            raise OSError(errno.ESTALE, "cleanup artifact identity changed")
        claim_name = _unique_unused_name(
            parent_descriptor,
            ".ambitions-canon-cleanup-",
        )
        os.replace(
            name,
            claim_name,
            src_dir_fd=parent_descriptor,
            dst_dir_fd=parent_descriptor,
        )
        if _entry_identity(parent_descriptor, claim_name) != expected_identity:
            raise OSError(errno.ESTALE, "cleanup claim identity changed")
        _remove_tree_at(
            parent_descriptor,
            claim_name,
            expected_identity,
        )
    except Exception:
        _warn_best_effort(
            "WARNING CANON_GENERATED_CLEANUP_REQUIRED "
            "stale transaction artifact retained"
        )


def _recovery_fsync_best_effort(descriptor: int) -> None:
    try:
        _fsync_directory(descriptor)
    except OSError:
        _warn_best_effort(
            "WARNING CANON_GENERATED_RECOVERY_DURABILITY_UNCERTAIN "
            "restored state is visible but directory fsync failed"
        )


def _warn_best_effort(message: str) -> None:
    try:
        print(message, file=sys.stderr)
    except Exception:
        pass


def _fsync_directory(descriptor: int) -> None:
    try:
        os.fsync(descriptor)
    except OSError as exc:
        if exc.errno not in UNSUPPORTED_DIRECTORY_FSYNC:
            raise


def _rename_noreplace(
    source: str,
    destination: str,
    *,
    source_directory: int,
    destination_directory: int,
) -> None:
    """Rename a directory without ever replacing a raced destination."""

    source_bytes = os.fsencode(source)
    destination_bytes = os.fsencode(destination)
    if sys.platform == "darwin":
        libc = ctypes.CDLL(None, use_errno=True)
        try:
            rename = libc.renameatx_np
        except AttributeError as exc:
            raise CanonError(
                "CANON_GENERATED_PLATFORM",
                "atomic no-replace rename is unavailable on this platform",
            ) from exc
        rename.argtypes = (
            ctypes.c_int,
            ctypes.c_char_p,
            ctypes.c_int,
            ctypes.c_char_p,
            ctypes.c_uint,
        )
        rename.restype = ctypes.c_int
        result = rename(
            source_directory,
            source_bytes,
            destination_directory,
            destination_bytes,
            DARWIN_RENAME_EXCL,
        )
    elif sys.platform.startswith("linux"):
        libc = ctypes.CDLL(None, use_errno=True)
        try:
            rename = libc.renameat2
        except AttributeError as exc:
            raise CanonError(
                "CANON_GENERATED_PLATFORM",
                "atomic no-replace rename is unavailable on this platform",
            ) from exc
        rename.argtypes = (
            ctypes.c_int,
            ctypes.c_char_p,
            ctypes.c_int,
            ctypes.c_char_p,
            ctypes.c_uint,
        )
        rename.restype = ctypes.c_int
        result = rename(
            source_directory,
            source_bytes,
            destination_directory,
            destination_bytes,
            LINUX_RENAME_NOREPLACE,
        )
    else:
        raise CanonError(
            "CANON_GENERATED_PLATFORM",
            "atomic no-replace rename is unavailable on this platform",
        )
    if result != 0:
        error = ctypes.get_errno()
        raise OSError(error, os.strerror(error), destination)


def _generated_finding(code: str, message: str, path: Path) -> Finding:
    return Finding(
        code=code,
        severity=GapSeverity.P0_BLOCKER,
        message=message,
        path=Path("docs/canon/generated") / path,
    )


def _path_escape(path: Path) -> CanonError:
    return CanonError(
        "CANON_GENERATED_PATH_ESCAPE",
        "generated path contains a symlink or invalid ancestor",
        path,
    )


def _path_error(path: Path, error: OSError) -> CanonError:
    if error.errno in (errno.ELOOP, errno.ENOTDIR):
        return _path_escape(path)
    return CanonError(
        "CANON_GENERATED_PATH",
        "generated path is missing or unreadable",
        path,
    )
