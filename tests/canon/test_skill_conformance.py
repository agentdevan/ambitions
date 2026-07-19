from __future__ import annotations

import hashlib
import json
import tempfile
import unittest
from pathlib import Path

from tools.ambitions_canon.skill_conformance import (
    SkillConformanceError,
    check_skill_conformance,
    dependency_registry_digest,
)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write(root: Path, path: str, content: str) -> Path:
    target = root / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content, encoding="utf-8")
    return target


def registry(root: Path) -> dict[str, object]:
    skill = root / ".agents/skills/adapter/SKILL.md"
    law = root / "docs/canon/constitution/law.md"
    schema = root / "docs/canon/schemas/requirement.schema.json"
    requirement_index = root / "docs/canon/generated/canon-index.json"
    return {
        "schema_version": 1,
        "registry_revision": "skill-dependencies-v1",
        "compiler_compatibility": ["0.1.0"],
        "requirement_index_path": "docs/canon/generated/canon-index.json",
        "requirement_index_sha256": sha(requirement_index),
        "skills": [
            {
                "skill_id": "adapter",
                "path": ".agents/skills/adapter/SKILL.md",
                "skill_sha256": sha(skill),
                "allowed_adapter_purpose": "Route an agent to canonical law.",
                "may_authorize": False,
                "requirement_ids": ["AUTH-001"],
                "schema_compatibility": [1],
                "compiler_compatibility": ["0.1.0"],
                "depends_on_skills": [],
                "dependencies": [
                    {
                        "path": "docs/canon/constitution/law.md",
                        "sha256": sha(law),
                        "authority_role": "canonical",
                    },
                    {
                        "path": "docs/canon/schemas/requirement.schema.json",
                        "sha256": sha(schema),
                        "authority_role": "schema",
                    },
                ],
            }
        ],
    }


class SkillConformanceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        write(
            self.root,
            ".agents/skills/adapter/SKILL.md",
            "---\nname: adapter\n---\n\nProcedural adapter only. It cannot authorize.\n",
        )
        write(self.root, "docs/canon/constitution/law.md", "# AUTH-001\n")
        write(self.root, "docs/canon/schemas/requirement.schema.json", "{}\n")
        write(
            self.root,
            "docs/canon/generated/canon-index.json",
            '{"requirements":[{"requirement_id":"AUTH-001"}]}\n',
        )

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def test_complete_procedural_registry_is_deterministic_and_green(self) -> None:
        payload = registry(self.root)
        first = check_skill_conformance(self.root, payload, compiler_version="0.1.0")
        second = check_skill_conformance(self.root, payload, compiler_version="0.1.0")
        self.assertEqual(first, second)
        self.assertEqual(first["status"], "green")
        self.assertEqual(first["skill_ids"], ["adapter"])
        self.assertEqual(dependency_registry_digest(payload), first["registry_digest"])

    def test_missing_and_stale_dependencies_fail_closed(self) -> None:
        payload = registry(self.root)
        (self.root / "docs/canon/constitution/law.md").unlink()
        with self.assertRaisesRegex(SkillConformanceError, "SKILL_DEPENDENCY_MISSING"):
            check_skill_conformance(self.root, payload, compiler_version="0.1.0")

        write(self.root, "docs/canon/constitution/law.md", "# changed\n")
        with self.assertRaisesRegex(SkillConformanceError, "SKILL_DEPENDENCY_STALE"):
            check_skill_conformance(self.root, payload, compiler_version="0.1.0")

    def test_stale_skill_and_undeclared_skill_file_fail_closed(self) -> None:
        payload = registry(self.root)
        write(
            self.root,
            ".agents/skills/adapter/SKILL.md",
            "---\nname: adapter\n---\n\nChanged.\n",
        )
        with self.assertRaisesRegex(SkillConformanceError, "SKILL_BYTES_STALE"):
            check_skill_conformance(self.root, payload, compiler_version="0.1.0")

        payload = registry(self.root)
        write(self.root, ".agents/skills/undeclared/SKILL.md", "---\nname: undeclared\n---\n")
        with self.assertRaisesRegex(SkillConformanceError, "SKILL_UNDECLARED"):
            check_skill_conformance(self.root, payload, compiler_version="0.1.0")

    def test_circular_skill_dependencies_fail_closed(self) -> None:
        payload = registry(self.root)
        skill_b = write(
            self.root,
            ".agents/skills/adapter-b/SKILL.md",
            "---\nname: adapter-b\n---\n\nProcedural adapter only.\n",
        )
        first = payload["skills"][0]
        first["depends_on_skills"] = ["adapter-b"]
        payload["skills"].append(
            {
                **first,
                "skill_id": "adapter-b",
                "path": ".agents/skills/adapter-b/SKILL.md",
                "skill_sha256": sha(skill_b),
                "depends_on_skills": ["adapter"],
            }
        )
        with self.assertRaisesRegex(SkillConformanceError, "SKILL_DEPENDENCY_CYCLE"):
            check_skill_conformance(self.root, payload, compiler_version="0.1.0")

    def test_authority_bearing_skill_metadata_and_dependency_are_rejected(self) -> None:
        payload = registry(self.root)
        payload["skills"][0]["may_authorize"] = True
        with self.assertRaisesRegex(SkillConformanceError, "SKILL_AUTHORITY_FORBIDDEN"):
            check_skill_conformance(self.root, payload, compiler_version="0.1.0")

        payload = registry(self.root)
        payload["skills"][0]["dependencies"][0]["authority_role"] = "skill-authority"
        with self.assertRaisesRegex(SkillConformanceError, "SKILL_DEPENDENCY_AUTHORITY"):
            check_skill_conformance(self.root, payload, compiler_version="0.1.0")

    def test_unknown_fields_and_compiler_mismatch_fail_closed(self) -> None:
        payload = registry(self.root)
        payload["extra"] = True
        with self.assertRaisesRegex(SkillConformanceError, "SKILL_REGISTRY_FIELDS"):
            check_skill_conformance(self.root, payload, compiler_version="0.1.0")

        payload = registry(self.root)
        with self.assertRaisesRegex(SkillConformanceError, "SKILL_COMPILER_INCOMPATIBLE"):
            check_skill_conformance(self.root, payload, compiler_version="9.9.9")

    def test_unknown_requirement_and_stale_requirement_index_fail_closed(self) -> None:
        payload = registry(self.root)
        payload["skills"][0]["requirement_ids"] = ["AUTH-UNKNOWN"]
        with self.assertRaisesRegex(SkillConformanceError, "SKILL_REQUIREMENT_UNKNOWN"):
            check_skill_conformance(self.root, payload, compiler_version="0.1.0")

        payload = registry(self.root)
        write(
            self.root,
            "docs/canon/generated/canon-index.json",
            '{"requirements":[]}\n',
        )
        with self.assertRaisesRegex(
            SkillConformanceError, "SKILL_REQUIREMENT_INDEX_STALE"
        ):
            check_skill_conformance(self.root, payload, compiler_version="0.1.0")

    def test_registry_digest_is_sorted_newline_terminated_sha256(self) -> None:
        payload = registry(self.root)
        expected_bytes = (
            json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
            + "\n"
        ).encode("utf-8")
        self.assertEqual(
            dependency_registry_digest(payload),
            hashlib.sha256(expected_bytes).hexdigest(),
        )


class RepositorySkillConformanceTests(unittest.TestCase):
    def test_committed_requirement_index_digest_matches_registry(self) -> None:
        root = Path(__file__).resolve().parents[2]
        registry_path = root / "docs/canon/references/skill-dependencies.json"
        registry_data = json.loads(registry_path.read_text(encoding="utf-8"))
        requirement_index_path = root / registry_data["requirement_index_path"]

        self.assertEqual(
            registry_data["requirement_index_sha256"],
            sha(requirement_index_path),
            "retained skill registry must be rebound whenever canon-index.json changes",
        )


if __name__ == "__main__":
    unittest.main()
