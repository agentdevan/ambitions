"""Offline conformance checks for non-authoritative procedural skills."""

from __future__ import annotations

import hashlib
import json
from collections.abc import Mapping
from pathlib import Path, PurePosixPath


_REGISTRY_FIELDS = frozenset(
    {
        "schema_version",
        "registry_revision",
        "compiler_compatibility",
        "requirement_index_path",
        "requirement_index_sha256",
        "skills",
    }
)
_SKILL_FIELDS = frozenset(
    {
        "skill_id",
        "path",
        "skill_sha256",
        "allowed_adapter_purpose",
        "may_authorize",
        "requirement_ids",
        "schema_compatibility",
        "compiler_compatibility",
        "depends_on_skills",
        "dependencies",
    }
)
_DEPENDENCY_FIELDS = frozenset({"path", "sha256", "authority_role"})
_ALLOWED_DEPENDENCY_ROLES = frozenset({"canonical", "schema", "procedural-registry"})


class SkillConformanceError(ValueError):
    """Stable fail-closed skill registry error."""

    def __init__(self, code: str, message: str) -> None:
        super().__init__(f"{code}: {message}")
        self.code = code


def dependency_registry_digest(data: Mapping[str, object]) -> str:
    encoded = (
        json.dumps(data, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
        + "\n"
    ).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def check_skill_conformance(
    repo_root: Path,
    registry_data: Mapping[str, object],
    *,
    compiler_version: str,
) -> dict[str, object]:
    """Validate the complete retained-skill set and all declared dependencies."""

    if not isinstance(registry_data, Mapping) or set(registry_data) != _REGISTRY_FIELDS:
        raise SkillConformanceError("SKILL_REGISTRY_FIELDS", "registry fields do not match contract")
    if registry_data["schema_version"] != 1 or isinstance(
        registry_data["schema_version"], bool
    ):
        raise SkillConformanceError("SKILL_SCHEMA_VERSION", "unsupported registry schema")
    compatible = _string_list(registry_data["compiler_compatibility"], "compiler compatibility")
    if compiler_version not in compatible:
        raise SkillConformanceError("SKILL_COMPILER_INCOMPATIBLE", "compiler is not declared compatible")
    skills = registry_data["skills"]
    if not isinstance(skills, list) or not skills:
        raise SkillConformanceError("SKILL_REGISTRY_FIELDS", "skills must be a non-empty array")

    root = repo_root.resolve()
    requirement_index_path = _confined_path(
        root,
        _string(registry_data["requirement_index_path"], "requirement_index_path"),
    )
    _require_digest(
        requirement_index_path,
        registry_data["requirement_index_sha256"],
        "SKILL_REQUIREMENT_INDEX_STALE",
        "dependency",
    )
    requirement_ids = _load_requirement_ids(requirement_index_path)
    parsed: dict[str, Mapping[str, object]] = {}
    declared_paths: set[str] = set()
    for skill in skills:
        if not isinstance(skill, Mapping) or set(skill) != _SKILL_FIELDS:
            raise SkillConformanceError("SKILL_ENTRY_FIELDS", "skill fields do not match contract")
        skill_id = _string(skill["skill_id"], "skill_id")
        if skill_id in parsed:
            raise SkillConformanceError("SKILL_DUPLICATE", f"duplicate skill: {skill_id}")
        if skill["may_authorize"] is not False:
            raise SkillConformanceError("SKILL_AUTHORITY_FORBIDDEN", f"skill may authorize: {skill_id}")
        skill_path = _confined_path(root, _string(skill["path"], "path"))
        declared_paths.add(skill_path.relative_to(root).as_posix())
        _require_digest(skill_path, skill["skill_sha256"], "SKILL_BYTES_STALE", "skill")
        _string(skill["allowed_adapter_purpose"], "allowed_adapter_purpose")
        declared_requirement_ids = _string_list(
            skill["requirement_ids"], "requirement_ids"
        )
        missing_requirement_ids = sorted(
            set(declared_requirement_ids) - requirement_ids
        )
        if missing_requirement_ids:
            raise SkillConformanceError(
                "SKILL_REQUIREMENT_UNKNOWN",
                f"unknown requirement: {missing_requirement_ids[0]}",
            )
        schema_versions = skill["schema_compatibility"]
        if not isinstance(schema_versions, list) or 1 not in schema_versions:
            raise SkillConformanceError("SKILL_SCHEMA_INCOMPATIBLE", f"skill schema mismatch: {skill_id}")
        if compiler_version not in _string_list(
            skill["compiler_compatibility"], "skill compiler compatibility"
        ):
            raise SkillConformanceError("SKILL_COMPILER_INCOMPATIBLE", f"skill compiler mismatch: {skill_id}")
        _string_list(skill["depends_on_skills"], "depends_on_skills", allow_empty=True)
        dependencies = skill["dependencies"]
        if not isinstance(dependencies, list) or not dependencies:
            raise SkillConformanceError("SKILL_DEPENDENCY_MISSING", f"no dependencies: {skill_id}")
        dependency_paths: set[str] = set()
        for dependency in dependencies:
            if not isinstance(dependency, Mapping) or set(dependency) != _DEPENDENCY_FIELDS:
                raise SkillConformanceError(
                    "SKILL_DEPENDENCY_FIELDS", f"dependency fields invalid: {skill_id}"
                )
            dependency_path_text = _string(dependency["path"], "dependency path")
            if dependency_path_text in dependency_paths:
                raise SkillConformanceError(
                    "SKILL_DEPENDENCY_DUPLICATE", f"duplicate dependency: {dependency_path_text}"
                )
            dependency_paths.add(dependency_path_text)
            role = _string(dependency["authority_role"], "authority_role")
            if role not in _ALLOWED_DEPENDENCY_ROLES:
                raise SkillConformanceError(
                    "SKILL_DEPENDENCY_AUTHORITY", f"authority-bearing dependency: {dependency_path_text}"
                )
            dependency_path = _confined_path(root, dependency_path_text)
            if not dependency_path.exists():
                raise SkillConformanceError(
                    "SKILL_DEPENDENCY_MISSING", f"missing dependency: {dependency_path_text}"
                )
            _require_digest(
                dependency_path,
                dependency["sha256"],
                "SKILL_DEPENDENCY_STALE",
                "dependency",
            )
        parsed[skill_id] = skill

    actual_paths = {
        path.relative_to(root).as_posix()
        for path in (root / ".agents/skills").glob("*/SKILL.md")
        if path.is_file()
    }
    undeclared = sorted(actual_paths - declared_paths)
    if undeclared:
        raise SkillConformanceError("SKILL_UNDECLARED", f"undeclared skill: {undeclared[0]}")
    missing_declared = sorted(declared_paths - actual_paths)
    if missing_declared:
        raise SkillConformanceError("SKILL_MISSING", f"declared skill is absent: {missing_declared[0]}")

    _reject_cycles(parsed)
    return {
        "schema_version": 1,
        "status": "green",
        "registry_digest": dependency_registry_digest(registry_data),
        "skill_ids": sorted(parsed),
    }


def _load_requirement_ids(path: Path) -> set[str]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise SkillConformanceError(
            "SKILL_REQUIREMENT_INDEX_INVALID",
            "requirement index is not valid UTF-8 JSON",
        ) from exc
    if not isinstance(value, Mapping) or not isinstance(value.get("requirements"), list):
        raise SkillConformanceError(
            "SKILL_REQUIREMENT_INDEX_INVALID",
            "requirement index has no requirements array",
        )
    result: set[str] = set()
    for item in value["requirements"]:
        if not isinstance(item, Mapping):
            raise SkillConformanceError(
                "SKILL_REQUIREMENT_INDEX_INVALID",
                "requirement index entry is invalid",
            )
        requirement_id = item.get("requirement_id")
        if not isinstance(requirement_id, str) or not requirement_id.strip():
            raise SkillConformanceError(
                "SKILL_REQUIREMENT_INDEX_INVALID",
                "requirement index entry has no stable ID",
            )
        result.add(requirement_id)
    return result


def _reject_cycles(skills: Mapping[str, Mapping[str, object]]) -> None:
    state: dict[str, int] = {}

    def visit(skill_id: str) -> None:
        current = state.get(skill_id, 0)
        if current == 1:
            raise SkillConformanceError("SKILL_DEPENDENCY_CYCLE", f"cycle includes: {skill_id}")
        if current == 2:
            return
        if skill_id not in skills:
            raise SkillConformanceError("SKILL_DEPENDENCY_UNDECLARED", f"unknown skill dependency: {skill_id}")
        state[skill_id] = 1
        for dependency in skills[skill_id]["depends_on_skills"]:
            visit(dependency)
        state[skill_id] = 2

    for skill_id in sorted(skills):
        visit(skill_id)


def _confined_path(root: Path, text: str) -> Path:
    pure = PurePosixPath(text)
    if pure.is_absolute() or not pure.parts or any(part in {"", ".", ".."} for part in pure.parts):
        raise SkillConformanceError("SKILL_PATH_INVALID", f"invalid path: {text}")
    path = root.joinpath(*pure.parts)
    try:
        path.resolve(strict=False).relative_to(root)
    except ValueError as exc:
        raise SkillConformanceError("SKILL_PATH_INVALID", f"path escapes repository: {text}") from exc
    return path


def _require_digest(path: Path, expected: object, code: str, kind: str) -> None:
    if not path.is_file():
        if kind == "dependency":
            raise SkillConformanceError("SKILL_DEPENDENCY_MISSING", f"missing dependency: {path}")
        raise SkillConformanceError("SKILL_MISSING", f"missing skill: {path}")
    expected_text = _sha256(expected)
    actual = hashlib.sha256(path.read_bytes()).hexdigest()
    if actual != expected_text:
        raise SkillConformanceError(code, f"stale {kind}: {path}")


def _sha256(value: object) -> str:
    if not isinstance(value, str) or len(value) != 64 or any(
        character not in "0123456789abcdef" for character in value
    ):
        raise SkillConformanceError("SKILL_DIGEST_INVALID", "expected lowercase SHA-256")
    return value


def _string(value: object, field: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise SkillConformanceError("SKILL_FIELD_TYPE", f"{field} must be a non-empty string")
    return value


def _string_list(value: object, field: str, *, allow_empty: bool = False) -> list[str]:
    if not isinstance(value, list) or (not allow_empty and not value):
        raise SkillConformanceError("SKILL_FIELD_TYPE", f"{field} must be an array")
    if any(not isinstance(item, str) or not item.strip() for item in value):
        raise SkillConformanceError("SKILL_FIELD_TYPE", f"{field} must contain strings")
    if len(value) != len(set(value)):
        raise SkillConformanceError("SKILL_FIELD_TYPE", f"{field} must contain unique values")
    return list(value)
