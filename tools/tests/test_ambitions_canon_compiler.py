from __future__ import annotations

import json
import re
import shutil
import tempfile
import unittest
from dataclasses import replace
from pathlib import Path

from tools.ambitions_canon import compiler as canon_compiler
from tools.ambitions_canon.cli import SUPPORTED_COMMANDS
from tools.ambitions_canon.compiler import (
    GENERATED_PATHS,
    Requirement,
    compile_repository,
    output_drift,
    query,
    render_outputs,
)


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
ACTIVE_DESIGN_PATHS = (
    Path("docs/canon/design/VISUAL_CLOSURE_INPUT_CONTRACT.md"),
    Path("docs/canon/design/visual-closure-input-contract.json"),
    Path("docs/canon/migration/UX_BLUEPRINT.md"),
    Path("docs/canon/migration/ux-blueprint.json"),
    Path("docs/canon/migration/ux-blueprint-requirement-dispositions.json"),
    Path("docs/canon/design/VISUAL_SYSTEM_R1.md"),
)


def mutate_first_taxonomy(
    payload: dict[str, object],
    **changes: object,
) -> dict[str, object]:
    state_models = payload["state_models"]
    assert isinstance(state_models, list)
    first_model = state_models[0]
    assert isinstance(first_model, dict)
    taxonomy = first_model["taxonomy"]
    assert isinstance(taxonomy, list)
    first_taxonomy = taxonomy[0]
    assert isinstance(first_taxonomy, dict)
    return {
        **payload,
        "state_models": [
            {
                **first_model,
                "taxonomy": [
                    {**first_taxonomy, **changes},
                    *taxonomy[1:],
                ],
            },
            *state_models[1:],
        ],
    }


class AmbitionsCanonCompilerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.compilation = compile_repository(REPOSITORY_ROOT)
        cls.outputs = render_outputs(cls.compilation)

    def test_repository_compiles_as_complete_product_canon(self) -> None:
        self.assertEqual(len(self.compilation.documents), 66)
        self.assertGreaterEqual(len(self.compilation.requirements), 450)
        self.assertGreaterEqual(self.compilation.ux_screen_count, 30)
        self.assertGreaterEqual(self.compilation.visual_contract_count, 25)

    def test_canon_source_owner_paths_exist(self) -> None:
        missing = sorted(
            {
                owner
                for document in self.compilation.documents
                for owner in document.source_owners
                if not (REPOSITORY_ROOT / owner).exists()
            }
        )
        self.assertEqual(missing, [])

    def test_repository_binding_validation_rejects_missing_owners_and_unknown_supersedes(
        self,
    ) -> None:
        validator = getattr(
            canon_compiler,
            "validate_repository_bindings",
            None,
        )
        self.assertTrue(callable(validator))

        first_document = self.compilation.documents[0]
        missing_owner_document = replace(
            first_document,
            source_owners=("Native/Ambitions/MissingOwner/",),
        )
        with self.assertRaisesRegex(
            canon_compiler.CanonError,
            "missing source owner",
        ):
            validator(
                REPOSITORY_ROOT,
                (missing_owner_document, *self.compilation.documents[1:]),
            )

        first_requirement = first_document.requirements[0]
        unknown_supersedes_requirement = replace(
            first_requirement,
            supersedes=("SPEC-UNKNOWN-RETIRED-001",),
        )
        unknown_supersedes_document = replace(
            first_document,
            requirements=(
                unknown_supersedes_requirement,
                *first_document.requirements[1:],
            ),
        )
        with self.assertRaisesRegex(
            canon_compiler.CanonError,
            "unknown superseded requirement",
        ):
            validator(
                REPOSITORY_ROOT,
                (unknown_supersedes_document, *self.compilation.documents[1:]),
            )

    def test_design_schemas_match_active_coverage_counts(self) -> None:
        requirement_count = len(self.compilation.requirements)
        blueprint_schema = json.loads(
            (
                REPOSITORY_ROOT
                / "docs/canon/schemas/ux-blueprint.schema.json"
            ).read_text(encoding="utf-8")
        )
        visual_schema = json.loads(
            (
                REPOSITORY_ROOT
                / "docs/canon/schemas/visual-authority-rebaseline.schema.json"
            ).read_text(encoding="utf-8")
        )
        dispositions = blueprint_schema["properties"][
            "requirement_dispositions"
        ]
        self.assertEqual(dispositions["minItems"], requirement_count)
        self.assertEqual(dispositions["maxItems"], requirement_count)
        self.assertEqual(
            visual_schema["properties"]["coverage"]["properties"][
                "visual_requirement_count"
            ]["const"],
            343,
        )

    def test_active_ux_taxonomy_matches_named_variants(self) -> None:
        blueprint = json.loads(
            (
                REPOSITORY_ROOT
                / "docs/canon/migration/ux-blueprint.json"
            ).read_text(encoding="utf-8")
        )
        generic_kinds = (
            "degraded",
            "empty",
            "failure",
            "interruption",
            "loading",
            "recovery",
            "resting",
            "rollback",
            "transitional",
        )

        for state_model in blueprint["state_models"]:
            variants_by_kind = {
                generic_kind: sorted(
                    variant["blueprint_id"]
                    for variant in state_model["variants"]
                    if variant["generic_kind"] == generic_kind
                )
                for generic_kind in generic_kinds
            }
            screen_title = state_model["title"].removesuffix(
                " explicit state contract"
            )
            for taxonomy in state_model["taxonomy"]:
                generic_kind = taxonomy["generic_kind"]
                variant_ids = variants_by_kind[generic_kind]
                if variant_ids:
                    expected_applicability = "applicable"
                    expected_rationale = (
                        f"{screen_title} maps {generic_kind} only through the "
                        "listed exact named variants; no anonymous or inferred "
                        f"{generic_kind} presentation is authorized."
                    )
                else:
                    expected_applicability = "not_applicable"
                    expected_rationale = (
                        f"{screen_title} declares no canonical named "
                        f"{generic_kind} state in this blueprint; no synthetic "
                        f"{generic_kind} screen is authorized."
                    )

                with self.subTest(
                    state_model=state_model["blueprint_id"],
                    generic_kind=generic_kind,
                ):
                    self.assertEqual(taxonomy["variant_ids"], variant_ids)
                    self.assertEqual(
                        taxonomy["applicability"],
                        expected_applicability,
                    )
                    self.assertEqual(
                        taxonomy["rationale"],
                        expected_rationale,
                    )

    def test_active_visual_authority_has_no_process_gate_vocabulary(self) -> None:
        visual_manifest = json.loads(
            (
                REPOSITORY_ROOT
                / "docs/canon/generated/visual-authority-manifest.json"
            ).read_text(encoding="utf-8")
        )
        visual_system = (
            REPOSITORY_ROOT / "docs/canon/design/VISUAL_SYSTEM_R1.md"
        ).read_text(encoding="utf-8")
        visual_contract = json.loads(
            (
                REPOSITORY_ROOT
                / "docs/canon/design/visual-closure-input-contract.json"
            ).read_text(encoding="utf-8")
        )

        forbidden_keys = {
            "approval_state",
            "approved_by",
            "owner_approval_complete",
            "reconciliation_action",
            "reconciliation_status",
            "ui_readiness",
            "ui_readiness_reason",
        }
        found_keys: set[str] = set()

        def collect_keys(value: object) -> None:
            if isinstance(value, dict):
                found_keys.update(value)
                for child in value.values():
                    collect_keys(child)
            elif isinstance(value, list):
                for child in value:
                    collect_keys(child)

        collect_keys(visual_manifest)
        collect_keys(visual_contract)
        self.assertEqual(found_keys & forbidden_keys, set())
        serialized_manifest = json.dumps(visual_manifest).casefold()
        self.assertNotIn("gate b", serialized_manifest)
        self.assertNotIn("task pack", serialized_manifest)
        self.assertNotIn("separately authorized", visual_system.casefold())

    def test_visual_closure_contract_renders_exact_active_baseline(self) -> None:
        contract = json.loads(
            (
                REPOSITORY_ROOT
                / "docs/canon/design/visual-closure-input-contract.json"
            ).read_text(encoding="utf-8")
        )
        manifest = json.loads(
            self.outputs["generated/visual-authority-manifest.json"]
        )
        self.assertEqual(
            contract["active_baseline"]["directions"],
            list(canon_compiler.ACTIVE_VISUAL_DIRECTIONS),
        )
        self.assertEqual(
            [item["visual_authority_id"] for item in manifest["authorities"]],
            list(canon_compiler.ACTIVE_VISUAL_DIRECTIONS),
        )
        self.assertEqual(
            manifest["authority_state"],
            {
                "figma": False,
                "implementation": False,
                "swiftui": False,
                "visual_closure_planning": True,
            },
        )
        self.assertFalse(contract["active_baseline"]["typography"]["serif_active"])
        self.assertEqual(
            contract["active_baseline"]["appearance"]["choices"],
            ["System", "Light", "Dark"],
        )

    def test_generated_outputs_are_current_and_deterministic(self) -> None:
        self.assertEqual(output_drift(self.compilation, self.outputs), ())
        self.assertEqual(render_outputs(self.compilation), self.outputs)

    def test_generated_traceability_is_structural_and_non_proof(self) -> None:
        self.assertEqual(set(self.outputs), set(GENERATED_PATHS))
        self.assertIn(
            "generated/requirement-traceability.json",
            self.outputs,
        )
        payload = json.loads(
            self.outputs["generated/requirement-traceability.json"]
        )
        self.assertEqual(payload["canon_digest"], self.compilation.canon_digest)
        self.assertEqual(len(payload["requirements"]), 466)
        self.assertEqual(
            {
                item["requirement_id"]
                for item in payload["requirements"]
            },
            {
                requirement.requirement_id
                for requirement in self.compilation.requirements
            },
        )
        self.assertEqual(
            payload["executable_resolution_policy"]["required_phase"],
            8,
        )
        self.assertTrue(
            all(
                item["executable_bindings"] == []
                and item["executable_resolution"]
                == "not_evaluated_by_canon_compiler"
                for item in payload["requirements"]
            )
        )

    def test_active_design_artifacts_match_current_canon_identity(self) -> None:
        canon_revision = self.compilation.manifest.canon_revision
        requirement_ids = {
            requirement.requirement_id
            for requirement in self.compilation.requirements
        }
        blueprint = json.loads(
            (
                REPOSITORY_ROOT
                / "docs/canon/migration/ux-blueprint.json"
            ).read_text(encoding="utf-8")
        )
        dispositions = json.loads(
            (
                REPOSITORY_ROOT
                / "docs/canon/migration/ux-blueprint-requirement-dispositions.json"
            ).read_text(encoding="utf-8")
        )
        visual_manifest = json.loads(
            (
                REPOSITORY_ROOT
                / "docs/canon/generated/visual-authority-manifest.json"
            ).read_text(encoding="utf-8")
        )

        self.assertEqual(blueprint["canon_revision"], canon_revision)
        self.assertEqual(dispositions["canon_revision"], canon_revision)
        self.assertEqual(visual_manifest["canon_revision"], canon_revision)
        self.assertEqual(
            {
                item["requirement_id"]
                for item in dispositions["dispositions"]
            },
            requirement_ids,
        )
        self.assertEqual(
            {
                item["requirement_id"]
                for item in blueprint["requirement_dispositions"]
            },
            requirement_ids,
        )
        self.assertEqual(
            {
                requirement_id
                for authority in visual_manifest["authorities"]
                for requirement_id in authority["requirement_ids"]
            }
            - requirement_ids,
            set(),
        )

    def test_active_design_artifacts_bind_current_canon_digest(self) -> None:
        canon_digest = self.compilation.canon_digest
        canon_revision = self.compilation.manifest.canon_revision
        blueprint = json.loads(
            (
                REPOSITORY_ROOT
                / "docs/canon/migration/ux-blueprint.json"
            ).read_text(encoding="utf-8")
        )
        dispositions = json.loads(
            (
                REPOSITORY_ROOT
                / "docs/canon/migration/ux-blueprint-requirement-dispositions.json"
            ).read_text(encoding="utf-8")
        )
        visual_manifest = json.loads(
            (
                REPOSITORY_ROOT
                / "docs/canon/generated/visual-authority-manifest.json"
            ).read_text(encoding="utf-8")
        )
        blueprint_markdown = (
            REPOSITORY_ROOT / "docs/canon/migration/UX_BLUEPRINT.md"
        ).read_text(encoding="utf-8")
        visual_system = (
            REPOSITORY_ROOT / "docs/canon/design/VISUAL_SYSTEM_R1.md"
        ).read_text(encoding="utf-8")

        self.assertEqual(blueprint["canon_content_sha"], canon_digest)
        self.assertEqual(dispositions["canon_content_sha"], canon_digest)
        self.assertEqual(visual_manifest["canon_content_sha"], canon_digest)
        self.assertRegex(
            blueprint_markdown,
            rf"(?m)^- Canon revision: `{canon_revision}`$",
        )
        self.assertRegex(
            blueprint_markdown,
            rf"(?m)^- Canon content SHA: `{re.escape(canon_digest)}`$",
        )
        self.assertRegex(
            visual_system,
            rf"(?m)^- canon revision: `{canon_revision}`;$",
        )
        self.assertRegex(
            visual_system,
            rf"(?m)^- canon content SHA: `{re.escape(canon_digest)}`;$",
        )

    def test_compiler_exposes_active_design_artifact_validation(self) -> None:
        self.assertTrue(
            callable(
                getattr(canon_compiler, "validate_design_artifacts", None)
            )
        )

    def test_design_artifact_validation_rejects_identity_drift(self) -> None:
        cases = (
            (
                Path("docs/canon/migration/ux-blueprint.json"),
                lambda payload: {**payload, "canon_revision": 1},
                "UX Blueprint canon_revision",
            ),
            (
                Path("docs/canon/migration/ux-blueprint.json"),
                lambda payload: mutate_first_taxonomy(
                    payload,
                    rationale="Contradictory taxonomy rationale.",
                ),
                "UX Blueprint taxonomy rationale",
            ),
            (
                Path("docs/canon/migration/ux-blueprint.json"),
                lambda payload: mutate_first_taxonomy(
                    payload,
                    variant_ids=[],
                ),
                "UX Blueprint taxonomy variant_ids",
            ),
            (
                Path("docs/canon/migration/ux-blueprint.json"),
                lambda payload: mutate_first_taxonomy(
                    payload,
                    applicability="not_applicable",
                ),
                "UX Blueprint taxonomy applicability",
            ),
            (
                Path(
                    "docs/canon/migration/"
                    "ux-blueprint-requirement-dispositions.json"
                ),
                lambda payload: {
                    **payload,
                    "dispositions": payload["dispositions"][:-1],
                },
                "requirement dispositions do not match active canon",
            ),
            (
                Path("docs/canon/design/visual-closure-input-contract.json"),
                lambda payload: {
                    **payload,
                    "visual_requirement_mappings": [
                        {
                            **payload["visual_requirement_mappings"][0],
                            "requirement_ids": ["RETIRED-REQUIREMENT-001"],
                        },
                        *payload["visual_requirement_mappings"][1:],
                    ],
                },
                "visual authority references inactive requirement",
            ),
        )

        for relative_path, mutate, expected_error in cases:
            with self.subTest(relative_path=relative_path):
                with tempfile.TemporaryDirectory() as directory:
                    isolated_root = Path(directory)
                    for design_path in ACTIVE_DESIGN_PATHS:
                        target = isolated_root / design_path
                        target.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copy2(REPOSITORY_ROOT / design_path, target)
                    target = isolated_root / relative_path
                    payload = json.loads(target.read_text(encoding="utf-8"))
                    target.write_text(
                        json.dumps(
                            mutate(payload),
                            indent=2,
                            sort_keys=True,
                        )
                        + "\n",
                        encoding="utf-8",
                    )
                    isolated = replace(
                        self.compilation,
                        root=isolated_root,
                    )
                    with self.assertRaisesRegex(
                        canon_compiler.CanonError,
                        expected_error,
                    ):
                        canon_compiler.validate_design_artifacts(isolated)

    def test_design_artifact_validation_rejects_taxonomy_markdown_drift(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory() as directory:
            isolated_root = Path(directory)
            for design_path in ACTIVE_DESIGN_PATHS:
                target = isolated_root / design_path
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(REPOSITORY_ROOT / design_path, target)

            markdown_path = (
                isolated_root / "docs/canon/migration/UX_BLUEPRINT.md"
            )
            markdown = markdown_path.read_text(encoding="utf-8")
            expected = (
                "Account and continuity boundary maps degraded only through "
                "the listed exact named variants; no anonymous or inferred "
                "degraded presentation is authorized."
            )
            markdown_path.write_text(
                markdown.replace(
                    expected,
                    "Contradictory taxonomy rationale.",
                    1,
                ),
                encoding="utf-8",
            )

            isolated = replace(self.compilation, root=isolated_root)
            with self.assertRaisesRegex(
                canon_compiler.CanonError,
                "UX Blueprint Markdown/JSON taxonomy rows disagree",
            ):
                canon_compiler.validate_design_artifacts(isolated)

    def test_query_resolves_exact_requirement_and_multiword_text(self) -> None:
        exact = query(self.compilation, "LAW-LOCAL-AUTHORITY-001", mode="id")
        self.assertEqual(len(exact), 1)
        self.assertIsInstance(exact[0], Requirement)
        routed = query(
            self.compilation,
            "SPEC-SURFACE-TODAY-FIRST-VIEWPORT-001",
            mode="id",
        )
        self.assertEqual(len(routed), 1)
        self.assertTrue(routed[0].source_owners)

        text_matches = query(self.compilation, "Today first viewport")
        requirement_ids = {
            item.requirement_id
            for item in text_matches
            if isinstance(item, Requirement)
        }
        self.assertIn("SPEC-SURFACE-TODAY-FIRST-VIEWPORT-001", requirement_ids)

    def test_cli_exposes_only_product_compiler_commands(self) -> None:
        self.assertEqual(
            SUPPORTED_COMMANDS,
            {"version", "build", "check", "query"},
        )


if __name__ == "__main__":
    unittest.main()
