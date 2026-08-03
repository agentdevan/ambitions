"""Small, validated Git reads for lifecycle package and document verification."""

from __future__ import annotations

from pathlib import Path, PurePosixPath
import re
import subprocess

from .errors import Diagnostic, ProductDocsError


COMMIT_ID = re.compile(r"[0-9a-f]{40}\Z")
GIT_PATHSPEC_METACHARACTERS = frozenset("*?[")


def validate_commit_id(commit: str) -> str:
    if not isinstance(commit, str) or not COMMIT_ID.fullmatch(commit):
        raise ProductDocsError(
            Diagnostic(
                "invalid-commit-id",
                "Commit IDs must be 40 lowercase hexadecimal characters",
            )
        )
    return commit


def validate_repository_path(path: str) -> str:
    if (
        not isinstance(path, str)
        or not path
        or "\\" in path
        or "\x00" in path
        or any(ord(character) < 32 or ord(character) == 127 for character in path)
        or path.startswith(":")
        or any(character in GIT_PATHSPEC_METACHARACTERS for character in path)
    ):
        raise ProductDocsError(
            Diagnostic(
                "noncanonical-path",
                "Repository paths must be nonempty canonical relative POSIX paths",
            )
        )
    parsed = PurePosixPath(path)
    if parsed.is_absolute():
        raise ProductDocsError(
            Diagnostic("absolute-path", "Repository paths must be relative")
        )
    if any(part in {".", ".."} for part in parsed.parts):
        raise ProductDocsError(
            Diagnostic(
                "path-traversal", "Repository paths must not contain traversal segments"
            )
        )
    canonical = parsed.as_posix()
    if canonical in {"", "."} or canonical != path:
        raise ProductDocsError(
            Diagnostic(
                "noncanonical-path",
                "Repository paths must use canonical POSIX spelling",
            )
        )
    return canonical


def _literal_pathspec(path: str) -> str:
    """Prevent Git from interpreting a validated declared path as a glob."""
    return f":(literal){path}"


class GitRepository:
    """Read-only access to one repository, without shell command construction."""

    def __init__(self, root: Path | str) -> None:
        self.root = Path(root).resolve()
        if not self.root.is_dir():
            raise ProductDocsError(
                Diagnostic("repository-unavailable", "Repository root does not exist")
            )

    def _run(
        self, arguments: list[str], *, check: bool = True
    ) -> subprocess.CompletedProcess[bytes]:
        result = subprocess.run(
            ["git", "-C", str(self.root), *arguments],
            check=False,
            capture_output=True,
            shell=False,
        )
        if check and result.returncode != 0:
            detail = result.stderr.decode("utf-8", errors="replace").strip()
            raise ProductDocsError(
                Diagnostic("git-read-failed", detail or "Git read failed")
            )
        return result

    def head(self) -> str:
        result = self._run(["rev-parse", "HEAD"])
        return validate_commit_id(result.stdout.decode("ascii").strip())

    def is_commit_reachable(self, commit: str) -> bool:
        commit = validate_commit_id(commit)
        result = self._run(["merge-base", "--is-ancestor", commit, "HEAD"], check=False)
        return result.returncode == 0

    def read_bytes_at(self, commit: str, path: str) -> bytes:
        commit = validate_commit_id(commit)
        path = validate_repository_path(path)
        result = self._run(["show", f"{commit}:{path}"], check=False)
        if result.returncode != 0:
            raise ProductDocsError(
                Diagnostic(
                    "historical-path-missing",
                    "Path does not exist at the requested commit",
                    path=path,
                )
            )
        return result.stdout

    def changed_paths(
        self, baseline_commit: str, head_commit: str | None = None
    ) -> tuple[str, ...]:
        baseline_commit = validate_commit_id(baseline_commit)
        head_commit = (
            self.head() if head_commit is None else validate_commit_id(head_commit)
        )
        result = self._run(
            ["diff", "--name-only", "--no-renames", baseline_commit, head_commit]
        )
        return tuple(
            sorted(
                validate_repository_path(path)
                for path in result.stdout.decode("utf-8").splitlines()
                if path
            )
        )

    def latest_commit_touching(self, path: str) -> str:
        """Return the reachable HEAD-history commit that last changed ``path``."""
        path = validate_repository_path(path)
        result = self._run(
            ["log", "-1", "--format=%H", "HEAD", "--", _literal_pathspec(path)],
            check=False,
        )
        commit = result.stdout.decode("ascii", errors="replace").strip()
        if result.returncode != 0 or not commit:
            raise ProductDocsError(
                Diagnostic(
                    "historical-path-missing",
                    "Path has no reachable committed history",
                    path=path,
                )
            )
        return validate_commit_id(commit)

    def commits_touching(self, path: str) -> tuple[str, ...]:
        """Return HEAD-reachable commits that changed ``path``, newest first."""
        path = validate_repository_path(path)
        result = self._run(
            ["log", "--format=%H", "HEAD", "--", _literal_pathspec(path)]
        )
        return tuple(
            validate_commit_id(commit)
            for commit in result.stdout.decode("ascii").splitlines()
            if commit
        )

    def parent_of(self, commit: str) -> str:
        """Return the sole first parent needed for a lifecycle transition check."""
        commit = validate_commit_id(commit)
        result = self._run(["rev-parse", f"{commit}^"], check=False)
        parent = result.stdout.decode("ascii", errors="replace").strip()
        if result.returncode != 0 or not parent:
            raise ProductDocsError(
                Diagnostic(
                    "transition-parent-missing",
                    "Lifecycle transition commit requires a reachable parent",
                    identifier=commit,
                )
            )
        return validate_commit_id(parent)

    def path_exists_at(self, commit: str, path: str) -> bool:
        commit = validate_commit_id(commit)
        path = validate_repository_path(path)
        result = self._run(["cat-file", "-e", f"{commit}:{path}"], check=False)
        return result.returncode == 0

    def is_tracked_at_head(self, path: str) -> bool:
        path = validate_repository_path(path)
        result = self._run(
            ["ls-tree", "-r", "--name-only", "HEAD", "--", _literal_pathspec(path)],
            check=False,
        )
        return result.returncode == 0 and bool(result.stdout.strip())

    def has_worktree_change(self, path: str) -> bool:
        path = validate_repository_path(path)
        result = self._run(
            [
                "status",
                "--porcelain",
                "--untracked-files=all",
                "--",
                _literal_pathspec(path),
            ]
        )
        return bool(result.stdout.strip())

    def is_committed_exact(self, path: str) -> bool:
        """Return whether a regular worktree file has its exact ``HEAD`` bytes."""
        path = validate_repository_path(path)
        target = self.root / path
        if (
            not self.is_tracked_at_head(path)
            or not target.is_file()
            or target.is_symlink()
        ):
            return False
        try:
            return target.read_bytes() == self.read_bytes_at(self.head(), path)
        except (OSError, ProductDocsError):
            return False
