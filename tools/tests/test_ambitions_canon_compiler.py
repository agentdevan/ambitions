from __future__ import annotations

import hashlib
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
    Path("docs/canon/design/VC_WAVE_1_FOUNDATION_CLOSURE.md"),
    Path("docs/canon/design/vc-wave-1-foundation-closure.json"),
    Path("docs/canon/design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md"),
    Path("docs/canon/design/vc-wave-2-surface-journey-closure.json"),
    Path("docs/canon/design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md"),
    Path("docs/canon/design/vc-wave-3-accessibility-stress-closure.json"),
    Path("docs/canon/migration/UX_BLUEPRINT.md"),
    Path("docs/canon/migration/ux-blueprint.json"),
    Path("docs/canon/migration/ux-blueprint-state-inventory.json"),
    Path("docs/canon/migration/ux-blueprint-requirement-dispositions.json"),
    Path("docs/canon/generated/visual-authority-manifest.json"),
    Path("docs/canon/design/VISUAL_SYSTEM_R1.md"),
    Path(
        "docs/audits/rp-01-08-evidence-audit/"
        "13-owner-reconciliation-decisions.md"
    ),
    Path(
        "docs/adr/"
        "ADR-2026-07-22-shell-navigation-restoration-reconciliation.md"
    ),
    Path(
        "docs/adr/"
        "ADR-2026-07-22-canonical-identity-ownership-projection.md"
    ),
    Path(
        "docs/adr/"
        "ADR-2026-07-22-truth-mutation-and-global-authority.md"
    ),
    Path(
        "docs/adr/"
        "ADR-2026-07-22-local-first-recovery-accessibility-platform.md"
    ),
    Path(
        "docs/qa/frontend-flagship-shippability-remediation/"
        "RECONCILED_FLAGSHIP_RECONSTRUCTION_PLAN.md"
    ),
    Path(
        "docs/qa/frontend-flagship-shippability-remediation/"
        "RP_RECONCILIATION_TRACEABILITY.md"
    ),
    Path(
        "docs/qa/frontend-flagship-shippability-remediation/"
        "RP_RECONCILIATION_SUPERSESSION_REGISTER.md"
    ),
    Path(
        "docs/qa/frontend-flagship-shippability-remediation/"
        "rp-reconciliation-index.json"
    ),
)

EXPECTED_ACTIVE_VISUAL_DIRECTIONS = [
    "AVF-DNA-S07-R00",
    "AVF-SHELL-S07-R01",
    "AVF-CAPTURE-S07-R01",
    "AVF-GOALS-S08-R00",
    "AVF-TIME-S07-R01",
    "AVF-TODAY-S10-R00",
    "AVF-SEARCH-D07-R01",
    "AVF-YOU-D07-R02",
    "AVF-RECOVERY-S07-R01",
    "AVF-A11Y-S07-R00",
    "AVF-COHERENCE-S07-R00",
]

EXPECTED_EFFECTIVE_PACKAGE_STATUSES = {
    **{f"VC-{number:02d}": "CLOSED" for number in range(1, 14)},
    "VC-14": "NOT_STARTED",
}

EXPECTED_WAVE_2_SUMMARIES = {
    "capture": {
        "package_id": "VC-10",
        "selected_name": "Full-Screen Adaptive Meaning Passage",
    },
    "goals": {
        "package_id": "VC-08",
        "selected_name": "Singular Living Pursuit Passage",
    },
    "resilience": {
        "package_id": "VC-12",
        "selected_name": "Contextual Combined-State Passage",
    },
    "search": {
        "package_id": "VC-10",
        "selected_name": "Full-Screen Semantic Command Passage",
    },
    "time": {
        "package_id": "VC-09",
        "selected_name": "Adaptive Dual-Truth Period Passage",
    },
    "today": {
        "package_id": "VC-07",
        "selected_name": "Balanced Semantic Execution Day",
    },
    "you": {
        "package_id": "VC-11",
        "selected_name": "Personal Control Passage",
    },
}


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


def refresh_visual_system_source_sha(
    root: Path,
    relative_path: Path,
) -> None:
    source_sha = hashlib.sha256((root / relative_path).read_bytes()).hexdigest()
    visual_system_path = root / "docs/canon/design/VISUAL_SYSTEM_R1.md"
    visual_system = visual_system_path.read_text(encoding="utf-8")
    pattern = (
        rf"(?m)(SHA-256 for `{re.escape(relative_path.as_posix())}`: `)"
        r"[0-9a-f]{64}(`;)$"
    )
    refreshed, count = re.subn(
        pattern,
        rf"\g<1>{source_sha}\2",
        visual_system,
        count=1,
    )
    assert count == 1
    visual_system_path.write_text(refreshed, encoding="utf-8")


class Wave3VisualClosureLoaderTests(unittest.TestCase):
    def test_visual_closure_loader_includes_wave_3_in_order(self) -> None:
        records = canon_compiler.load_visual_closure_records(REPOSITORY_ROOT)
        self.assertEqual(
            [
                records[0]["contract_id"],
                records[1]["package_id"],
                records[2]["package_id"],
                records[3]["package_id"],
            ],
            [
                "AMB-VISUAL-CLOSURE-INPUT-VC-01-14",
                "AMB-VC-WAVE-1-FOUNDATION-CLOSURE",
                "AMB-VC-WAVE-2-SURFACE-JOURNEY-CLOSURE",
                "AMB-VC-WAVE-3-ACCESSIBILITY-STRESS-CLOSURE",
            ],
        )


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
            contract["active_baseline"]["typography"]["core_family"],
            "San Francisco",
        )
        self.assertEqual(
            contract["active_baseline"]["typography"]["interface_roles"],
            "SF Pro",
        )
        self.assertEqual(
            contract["active_baseline"]["appearance"]["choices"],
            ["System", "Light", "Dark"],
        )
        self.assertEqual(
            contract["active_baseline"]["appearance"]["selected_synthesis"],
            "Mineral Relief Continuum",
        )
        self.assertEqual(
            contract["active_baseline"]["accent"]["exact_values_status"],
            "deferred_calibration",
        )
        self.assertEqual(
            contract["active_baseline"]["dock"]["expanded"],
            "one_compact_articulated_edge_tray_overlay",
        )
        self.assertEqual(
            contract["active_baseline"]["dock"]["adaptive_equivalent"],
            "VC04-DOCK-D06 — Adaptive Navigation Passage",
        )
        self.assertEqual(
            contract["active_baseline"]["state_grammar"]["primary_study"],
            "VC05-STATE-D04 — Semantic State Covenant",
        )
        self.assertEqual(
            contract["active_baseline"]["foundational_grammar"]["primary_study"],
            "VC06-GRAMMAR-D04 — Articulated Native Grammar",
        )
        self.assertEqual(
            contract["active_baseline"]["foundational_grammar"]
            ["minimum_interaction_target_points"],
            {"height": 44, "width": 44},
        )
        self.assertEqual(
            contract["closure_packages"]["package_statuses"],
            canon_compiler.WAVE_1_PACKAGE_STATUSES,
        )
        self.assertEqual(
            manifest["wave_1_foundation_closure"]["package_statuses"],
            canon_compiler.WAVE_1_PACKAGE_STATUSES,
        )
        self.assertEqual(
            manifest["wave_1_foundation_closure"]["source_contract"],
            "docs/canon/design/vc-wave-1-foundation-closure.json",
        )

    def test_wave_1_foundation_closure_is_complete_and_bounded(self) -> None:
        closure = json.loads(
            (
                REPOSITORY_ROOT
                / "docs/canon/design/vc-wave-1-foundation-closure.json"
            ).read_text(encoding="utf-8")
        )
        self.assertEqual(closure["status"], "CLOSED")
        self.assertEqual(
            closure["active_direction_ids"],
            list(canon_compiler.ACTIVE_VISUAL_DIRECTIONS),
        )
        self.assertEqual(
            closure["package_statuses"],
            canon_compiler.WAVE_1_PACKAGE_STATUSES,
        )
        self.assertEqual(
            closure["wave_status"],
            {
                "wave_1_shared_visual_foundation": "CLOSED",
                "wave_2_surfaces_and_journeys": "OPEN",
                "wave_3_stress_and_matched_baseline": "OPEN",
            },
        )
        self.assertEqual(
            closure["authorization_state"],
            {"figma": False, "implementation": False, "swiftui": False},
        )

        required_fields = {
            "package_id",
            "status",
            "selected_study_or_synthesis",
            "required_transformation",
            "applies_to_avf_ids",
            "locked_decisions",
            "rejected_alternatives",
            "deferred_calibration",
            "validation_requirements",
            "architecture_dependencies",
            "authorization_state",
            "source_paths",
        }
        packages = closure["packages"]
        self.assertEqual(
            [package["package_id"] for package in packages],
            [f"VC-{number:02d}" for number in range(1, 7)],
        )
        self.assertTrue(
            all(
                package["status"] == "CLOSED"
                and required_fields.issubset(package)
                and package["authorization_state"]
                == {"figma": False, "implementation": False, "swiftui": False}
                for package in packages
            )
        )
        self.assertEqual(
            [
                (
                    package["selected_study_or_synthesis"].get("id"),
                    package["selected_study_or_synthesis"]["name"],
                )
                for package in packages
            ],
            list(canon_compiler.WAVE_1_SELECTED_RECORDS.values()),
        )
        self.assertEqual(
            packages[3]["selected_study_or_synthesis"]["name"],
            "Articulated Edge Tray",
        )
        self.assertEqual(
            packages[3]["required_transformation"]["name"],
            "Adaptive Navigation Passage",
        )
        self.assertEqual(
            packages[4]["selected_study_or_synthesis"]["name"],
            "Semantic State Covenant",
        )
        self.assertEqual(
            packages[5]["selected_study_or_synthesis"]["name"],
            "Articulated Native Grammar",
        )
        self.assertEqual(
            packages[5]["locked_decisions"]["interaction_target_points"],
            {"height_minimum": 44, "width_minimum": 44},
        )

    def test_visual_closure_loader_preserves_order_and_rejects_bad_records(
        self,
    ) -> None:
        records = canon_compiler.load_visual_closure_records(REPOSITORY_ROOT)
        self.assertEqual(
            [
                records[0]["contract_id"],
                records[1]["package_id"],
                records[2]["package_id"],
            ],
            [
                "AMB-VISUAL-CLOSURE-INPUT-VC-01-14",
                "AMB-VC-WAVE-1-FOUNDATION-CLOSURE",
                "AMB-VC-WAVE-2-SURFACE-JOURNEY-CLOSURE",
            ],
        )

        wave_2_path = Path(
            "docs/canon/design/vc-wave-2-surface-journey-closure.json"
        )
        cases = (
            ("missing", None, "unable to load visual closure record"),
            ("invalid", "{not json}\n", "invalid JSON"),
            ("non_object", "[]\n", "root must be an object"),
        )
        for label, replacement, expected_error in cases:
            with self.subTest(label=label):
                with tempfile.TemporaryDirectory() as directory:
                    isolated_root = Path(directory)
                    for relative_path in (
                        canon_compiler.VISUAL_CLOSURE_MACHINE_PATHS
                    ):
                        if label == "missing" and relative_path == wave_2_path:
                            continue
                        target = isolated_root / relative_path
                        target.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copy2(REPOSITORY_ROOT / relative_path, target)
                    if replacement is not None:
                        (isolated_root / wave_2_path).write_text(
                            replacement,
                            encoding="utf-8",
                        )
                    with self.assertRaisesRegex(
                        canon_compiler.CanonError,
                        expected_error,
                    ):
                        canon_compiler.load_visual_closure_records(
                            isolated_root
                        )

    def test_wave_2_closure_projects_effective_package_and_wave_state(
        self,
    ) -> None:
        manifest = json.loads(
            self.outputs["generated/visual-authority-manifest.json"]
        )
        closure_packages = manifest["closure_packages"]
        self.assertEqual(
            closure_packages["package_statuses"],
            EXPECTED_EFFECTIVE_PACKAGE_STATUSES,
        )
        self.assertEqual(
            closure_packages["wave_1_record"]["package_statuses"],
            canon_compiler.WAVE_1_PACKAGE_STATUSES,
        )
        self.assertEqual(closure_packages["wave_1_record"]["status"], "CLOSED")
        contract = json.loads(
            (
                REPOSITORY_ROOT
                / "docs/canon/design/visual-closure-input-contract.json"
            ).read_text(encoding="utf-8")
        )
        self.assertEqual(
            closure_packages["wave_1"],
            contract["closure_packages"]["wave_1"],
        )
        self.assertEqual(
            closure_packages["wave_2_surfaces_and_journeys"],
            "CLOSED",
        )
        self.assertEqual(
            [
                package["package_id"]
                for package in closure_packages["wave_2"]["packages"]
            ],
            [f"VC-{number:02d}" for number in range(7, 13)],
        )
        self.assertEqual(
            closure_packages["wave_2"]["status"],
            "CLOSED",
        )
        self.assertEqual(
            closure_packages["wave_3_stress_and_matched_baseline"],
            "OPEN_PENDING_VC_14",
        )
        self.assertEqual(
            manifest["wave_2_surface_journey_closure"]["source_contract"],
            "docs/canon/design/vc-wave-2-surface-journey-closure.json",
        )

    def test_wave_2_closure_projects_exact_active_directions(self) -> None:
        manifest = json.loads(
            self.outputs["generated/visual-authority-manifest.json"]
        )
        self.assertEqual(
            manifest["active_baseline"]["directions"],
            EXPECTED_ACTIVE_VISUAL_DIRECTIONS,
        )
        self.assertEqual(
            [item["visual_authority_id"] for item in manifest["authorities"]],
            EXPECTED_ACTIVE_VISUAL_DIRECTIONS,
        )

    def test_wave_2_closure_keeps_all_implementation_authorization_false(
        self,
    ) -> None:
        manifest = json.loads(
            self.outputs["generated/visual-authority-manifest.json"]
        )
        expected = {"figma": False, "implementation": False, "swiftui": False}
        self.assertEqual(
            {
                key: manifest["authority_state"][key]
                for key in expected
            },
            expected,
        )
        for wave_key in ("wave_1_record", "wave_2"):
            wave = manifest["closure_packages"][wave_key]
            self.assertEqual(wave["authorization_state"], expected)
            self.assertTrue(
                all(
                    package["authorization_state"] == expected
                    for package in wave["packages"]
                )
            )

    def test_wave_2_closure_projects_structured_surface_summaries(self) -> None:
        manifest = json.loads(
            self.outputs["generated/visual-authority-manifest.json"]
        )
        summaries = manifest["active_baseline"]["wave_2_summaries"]
        self.assertEqual(summaries, EXPECTED_WAVE_2_SUMMARIES)
        self.assertTrue(all(isinstance(value, dict) for value in summaries.values()))
        self.assertEqual(
            manifest["closure_packages"]["wave_2"]["packages"][0]
            ["locked_decisions"]["ownership"]["mutation"],
            "owner_routed",
        )
        self.assertEqual(
            manifest["closure_packages"]["wave_2"]["packages"][0]
            ["locked_decisions"]["density_law"],
            "normal_readable_type_and_natural_scroll",
        )
        self.assertIn(
            "accepted",
            manifest["closure_packages"]["wave_2"]["packages"][2]
            ["locked_decisions"]["truth_statuses"],
        )
        self.assertIn(
            "direct_mutation",
            manifest["closure_packages"]["wave_2"]["packages"][3]
            ["locked_decisions"]["capability_gates"],
        )
        self.assertTrue(
            all(
                "AVF-A11Y-S07-R00" in package["applies_to_avf_ids"]
                for package in manifest["closure_packages"]["wave_2"]
                ["packages"]
            )
        )

    def test_visual_manifest_closes_vc_13_and_leaves_vc_14_unstarted(
        self,
    ) -> None:
        manifest = json.loads(
            self.outputs["generated/visual-authority-manifest.json"]
        )
        statuses = manifest["closure_packages"]["package_statuses"]
        self.assertTrue(
            all(statuses[f"VC-{number:02d}"] == "CLOSED" for number in range(1, 14))
        )
        self.assertEqual(statuses["VC-14"], "NOT_STARTED")

    def test_wave_3_projects_stress_closure_without_authorizing_implementation(
        self,
    ) -> None:
        manifest = json.loads(
            self.outputs["generated/visual-authority-manifest.json"]
        )
        wave_3 = manifest["closure_packages"]["wave_3"]
        self.assertEqual(
            wave_3["selected_record"],
            "VC13-A11Y-S01 — Stress-Proven Adaptive Semantic Continuity",
        )
        self.assertFalse(manifest["authority_state"]["figma"])
        self.assertFalse(manifest["authority_state"]["swiftui"])
        self.assertFalse(manifest["authority_state"]["implementation"])

    def test_wave_3_closure_projects_exact_active_directions(self) -> None:
        manifest = json.loads(
            self.outputs["generated/visual-authority-manifest.json"]
        )
        self.assertEqual(
            manifest["active_baseline"]["directions"],
            EXPECTED_ACTIVE_VISUAL_DIRECTIONS,
        )
        self.assertEqual(
            manifest["closure_packages"]["wave_3"]["active_direction_ids"],
            EXPECTED_ACTIVE_VISUAL_DIRECTIONS,
        )

    def test_wave_3_projects_structured_accessibility_stress_baseline(self) -> None:
        manifest = json.loads(
            self.outputs["generated/visual-authority-manifest.json"]
        )
        stress = manifest["active_baseline"]["wave_3_accessibility_stress"]
        for field in (
            "shared_first_viewport_doctrine",
            "compression_order",
            "never_compress",
            "surface_results",
            "shell_results",
            "keyboard_safe_action_boundary",
            "reduced_effects_contract",
            "rtl_semantic_invariants",
            "focus_entry",
            "focus_return_priority",
            "hidden_sensitive_value_contract",
            "combined_state_order",
            "combined_state_precedence",
            "architecture_dependency_register",
            "direct_device_proof_register",
            "vc_14_entry_criteria",
        ):
            self.assertIn(field, stress)
            self.assertTrue(stress[field])

    def test_wave_3_direct_device_proof_register_is_explicit_and_incomplete(
        self,
    ) -> None:
        manifest = json.loads(
            self.outputs["generated/visual-authority-manifest.json"]
        )
        proof_register = manifest["active_baseline"][
            "wave_3_accessibility_stress"
        ]["direct_device_proof_register"]
        self.assertTrue(proof_register)
        for obligation in (
            "left_handed_and_lower_reach_dock_usability",
            "voiceover_reading_order_and_focus_restoration",
            "rtl_on_device_inspection",
            "reduced_effects_appearance_specimen",
            "sensitive_value_accessibility_exclusion",
        ):
            self.assertIn(obligation, proof_register)
        self.assertTrue(
            manifest["closure_packages"]["wave_3"]["package"]
            ["overall_result"]["direct_device_proof_required"]
        )

    def test_wave_3_closure_rejects_authority_regressions(self) -> None:
        wave_3_path = Path(
            "docs/canon/design/vc-wave-3-accessibility-stress-closure.json"
        )
        cases = (
            (
                "changed_active_direction",
                lambda payload: {
                    **payload,
                    "active_direction_ids": [
                        "AVF-UNAUTHORIZED-S01-R00",
                        *payload["active_direction_ids"][1:],
                    ],
                },
            ),
            (
                "vc_13_open",
                lambda payload: {
                    **payload,
                    "package_statuses": {
                        **payload["package_statuses"],
                        "VC-13": "OPEN",
                    },
                },
            ),
            (
                "vc_14_closed",
                lambda payload: {
                    **payload,
                    "package_statuses": {
                        **payload["package_statuses"],
                        "VC-14": "CLOSED",
                    },
                },
            ),
            (
                "reordered_active_directions",
                lambda payload: {
                    **payload,
                    "active_direction_ids": [
                        payload["active_direction_ids"][1],
                        payload["active_direction_ids"][0],
                        *payload["active_direction_ids"][2:],
                    ],
                },
            ),
            *(
                (
                    f"{authorization_key}_authorization_true",
                    lambda payload, key=authorization_key: {
                        **payload,
                        "authorization_state": {
                            **payload["authorization_state"],
                            key: True,
                        },
                    },
                )
                for authorization_key in ("figma", "swiftui", "implementation")
            ),
            (
                "human_peer_missing",
                lambda payload: {**payload, "human_peer": None},
            ),
            (
                "wave_2_inheritance_missing",
                lambda payload: {
                    **payload,
                    "inherits": {
                        key: value
                        for key, value in payload["inherits"].items()
                        if key not in {"wave_2_human", "wave_2_machine"}
                    },
                },
            ),
            (
                "structural_branch_required",
                lambda payload: {
                    **payload,
                    "package": {
                        **payload["package"],
                        "failure_classification": {
                            **payload["package"]["failure_classification"],
                            "structural_branch_required": True,
                        },
                    },
                },
            ),
            (
                "proof_register_missing",
                lambda payload: {
                    key: value
                    for key, value in payload.items()
                    if key != "direct_device_proof_register"
                },
            ),
            (
                "wave_1_status_regression",
                lambda payload: {
                    **payload,
                    "package_statuses": {
                        **payload["package_statuses"],
                        "VC-01": "OPEN",
                    },
                },
            ),
            (
                "wave_2_status_regression",
                lambda payload: {
                    **payload,
                    "package_statuses": {
                        **payload["package_statuses"],
                        "VC-07": "OPEN",
                    },
                },
            ),
            (
                "new_active_avf_through_selected_closure",
                lambda payload: {
                    **payload,
                    "package": {
                        **payload["package"],
                        "applies_to_avf_ids": [
                            *payload["package"]["applies_to_avf_ids"],
                            "AVF-UNAUTHORIZED-S01-R00",
                        ],
                    },
                },
            ),
        )

        for label, mutate in cases:
            with self.subTest(label=label):
                with tempfile.TemporaryDirectory() as directory:
                    isolated_root = Path(directory)
                    for design_path in ACTIVE_DESIGN_PATHS:
                        target = isolated_root / design_path
                        target.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copy2(REPOSITORY_ROOT / design_path, target)
                    target = isolated_root / wave_3_path
                    payload = json.loads(target.read_text(encoding="utf-8"))
                    target.write_text(
                        json.dumps(
                            mutate(payload),
                            indent=2,
                            sort_keys=True,
                            ensure_ascii=False,
                        )
                        + "\n",
                        encoding="utf-8",
                    )
                    isolated = replace(self.compilation, root=isolated_root)
                    with self.assertRaisesRegex(
                        canon_compiler.CanonError,
                        "Wave 3 closure",
                    ):
                        canon_compiler.validate_design_artifacts(isolated)

    def test_wave_3_closure_rejects_human_machine_peer_mismatch(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            isolated_root = Path(directory)
            for design_path in ACTIVE_DESIGN_PATHS:
                target = isolated_root / design_path
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(REPOSITORY_ROOT / design_path, target)
            human_path = (
                isolated_root
                / "docs/canon/design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md"
            )
            source = human_path.read_text(encoding="utf-8")
            human_path.write_text(
                source.replace(
                    "Implementation authorization: `false`.",
                    "Implementation authorization: `true`.",
                    1,
                ),
                encoding="utf-8",
            )
            isolated = replace(self.compilation, root=isolated_root)
            with self.assertRaisesRegex(
                canon_compiler.CanonError,
                "Wave 3 closure human/machine mismatch",
            ):
                canon_compiler.validate_design_artifacts(isolated)

    def test_visual_closure_manifest_rendering_is_deterministic(self) -> None:
        first = canon_compiler.render_visual_authority_manifest(
            self.compilation
        )
        second = canon_compiler.render_visual_authority_manifest(
            self.compilation
        )
        self.assertEqual(first, second)

    def test_generated_outputs_are_current_and_deterministic(self) -> None:
        self.assertEqual(output_drift(self.compilation, self.outputs), ())
        self.assertEqual(render_outputs(self.compilation), self.outputs)

    def test_generated_router_lists_both_visual_closure_waves_adjacent(self) -> None:
        router = self.outputs["generated/CODEX_START_HERE.md"].decode("utf-8")
        wave_1 = (
            "- [Wave 1 Foundation Closure]"
            "(../design/VC_WAVE_1_FOUNDATION_CLOSURE.md)"
        )
        wave_2 = (
            "- [Wave 2 Surface and Journey Closure]"
            "(../design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md)"
        )
        self.assertEqual(router.count(wave_1), 1)
        self.assertEqual(router.count(wave_2), 1)
        self.assertIn(wave_1 + "\n" + wave_2, router)

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
            (
                Path("docs/canon/design/vc-wave-1-foundation-closure.json"),
                lambda payload: {
                    **payload,
                    "package_statuses": {
                        **payload["package_statuses"],
                        "VC-01": "OPEN",
                    },
                },
                "Wave 1 closure package statuses",
            ),
            (
                Path("docs/canon/design/vc-wave-1-foundation-closure.json"),
                lambda payload: {
                    **payload,
                    "active_direction_ids": [
                        *payload["active_direction_ids"],
                        "AVF-UNAUTHORIZED-S01-R00",
                    ],
                },
                "Wave 1 closure active direction IDs",
            ),
            (
                Path(
                    "docs/canon/design/"
                    "vc-wave-2-surface-journey-closure.json"
                ),
                lambda payload: {
                    **payload,
                    "active_direction_ids": [
                        "AVF-UNAUTHORIZED-S01-R00",
                        *payload["active_direction_ids"][1:],
                    ],
                },
                "Wave 2 closure active direction IDs",
            ),
            (
                Path(
                    "docs/canon/design/"
                    "vc-wave-2-surface-journey-closure.json"
                ),
                lambda payload: {
                    **payload,
                    "active_direction_ids": [
                        payload["active_direction_ids"][1],
                        payload["active_direction_ids"][0],
                        *payload["active_direction_ids"][2:],
                    ],
                },
                "Wave 2 closure active direction IDs",
            ),
            (
                Path(
                    "docs/canon/design/"
                    "vc-wave-2-surface-journey-closure.json"
                ),
                lambda payload: {
                    **payload,
                    "package_statuses": {
                        **payload["package_statuses"],
                        "VC-07": "OPEN",
                    },
                },
                "Wave 2 closure package statuses",
            ),
            (
                Path(
                    "docs/canon/design/"
                    "vc-wave-2-surface-journey-closure.json"
                ),
                lambda payload: {
                    **payload,
                    "package_statuses": {
                        **payload["package_statuses"],
                        "VC-13": "CLOSED",
                    },
                },
                "Wave 2 closure package statuses",
            ),
            (
                Path(
                    "docs/canon/design/"
                    "vc-wave-2-surface-journey-closure.json"
                ),
                lambda payload: {
                    **payload,
                    "package_statuses": {
                        **payload["package_statuses"],
                        "VC-14": "CLOSED",
                    },
                },
                "Wave 2 closure package statuses",
            ),
            *(
                (
                    Path(
                        "docs/canon/design/"
                        "vc-wave-2-surface-journey-closure.json"
                    ),
                    lambda payload, authorization_key=authorization_key: {
                        **payload,
                        "authorization_state": {
                            **payload["authorization_state"],
                            authorization_key: True,
                        },
                    },
                    "Wave 2 closure authorization",
                )
                for authorization_key in ("figma", "swiftui", "implementation")
            ),
            (
                Path(
                    "docs/canon/design/"
                    "vc-wave-2-surface-journey-closure.json"
                ),
                lambda payload: {
                    **payload,
                    "packages": [
                        {
                            **payload["packages"][0],
                            "authorization_state": {
                                **payload["packages"][0]["authorization_state"],
                                "implementation": True,
                            },
                        },
                        *payload["packages"][1:],
                    ],
                },
                "Wave 2 closure package authorization",
            ),
            (
                Path(
                    "docs/canon/design/"
                    "vc-wave-2-surface-journey-closure.json"
                ),
                lambda payload: {
                    **payload,
                    "packages": [
                        payload["packages"][0],
                        {**payload["packages"][1], "package_id": "VC-07"},
                        *payload["packages"][2:],
                    ],
                },
                "Wave 2 closure package identities",
            ),
            (
                Path(
                    "docs/canon/design/"
                    "vc-wave-2-surface-journey-closure.json"
                ),
                lambda payload: {
                    **payload,
                    "packages": [
                        {**payload["packages"][0], "package_id": "VC-06"},
                        *payload["packages"][1:],
                    ],
                },
                "Wave 2 closure package identities",
            ),
            (
                Path(
                    "docs/canon/design/"
                    "vc-wave-2-surface-journey-closure.json"
                ),
                lambda payload: {
                    key: value
                    for key, value in payload.items()
                    if key != "human_peer"
                },
                "Wave 2 closure human peer",
            ),
            (
                Path(
                    "docs/canon/design/"
                    "vc-wave-2-surface-journey-closure.json"
                ),
                lambda payload: {
                    **payload,
                    "human_peer": (
                        "docs/canon/design/VC_WAVE_1_FOUNDATION_CLOSURE.md"
                    ),
                },
                "Wave 2 closure human peer",
            ),
            (
                Path(
                    "docs/canon/design/"
                    "vc-wave-2-surface-journey-closure.json"
                ),
                lambda payload: {
                    **payload,
                    "inherits": {"human": payload["inherits"]["human"]},
                },
                "Wave 2 closure Wave 1 inheritance",
            ),
            (
                Path(
                    "docs/canon/design/"
                    "vc-wave-2-surface-journey-closure.json"
                ),
                lambda payload: {
                    **payload,
                    "packages": [
                        {
                            **payload["packages"][0],
                            "applies_to_avf_ids": [
                                *payload["packages"][0]["applies_to_avf_ids"],
                                "AVF-NEW-S01-R00",
                            ],
                        },
                        *payload["packages"][1:],
                    ],
                },
                "Wave 2 closure AVF mapping",
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

    def test_wave_2_closure_rejects_human_machine_mismatch(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            isolated_root = Path(directory)
            for design_path in ACTIVE_DESIGN_PATHS:
                target = isolated_root / design_path
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(REPOSITORY_ROOT / design_path, target)

            markdown_path = (
                isolated_root
                / "docs/canon/design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md"
            )
            markdown = markdown_path.read_text(encoding="utf-8")
            markdown_path.write_text(
                markdown.replace("- Wave 2: `CLOSED`.", "- Wave 2: `OPEN`.", 1),
                encoding="utf-8",
            )

            isolated = replace(self.compilation, root=isolated_root)
            with self.assertRaisesRegex(
                canon_compiler.CanonError,
                "Wave 2 closure human/machine mismatch",
            ):
                canon_compiler.validate_design_artifacts(isolated)

    def test_wave_2_closure_rejects_human_direction_package_and_selection_drift(
        self,
    ) -> None:
        cases = (
            (
                "changed_active_direction",
                lambda markdown: markdown.replace(
                    "1. `AVF-DNA-S07-R00`",
                    "1. `AVF-UNAUTHORIZED-S01-R00`",
                    1,
                ),
            ),
            (
                "reordered_active_directions",
                lambda markdown: markdown.replace(
                    "1. `AVF-DNA-S07-R00`\n2. `AVF-SHELL-S07-R01`",
                    "1. `AVF-SHELL-S07-R01`\n2. `AVF-DNA-S07-R00`",
                    1,
                ),
            ),
            (
                "package_status_row",
                lambda markdown: markdown.replace(
                    "| `VC-07` | `CLOSED` | Today |",
                    "| `VC-07` | `OPEN` | Today |",
                    1,
                ),
            ),
            (
                "selected_direction_identifier",
                lambda markdown: markdown.replace(
                    "`AVF-GOALS-S08-R00 — Life Area Linked Goal Lens`",
                    "`AVF-GOALS-S99-R99 — Life Area Linked Goal Lens`",
                    1,
                ),
            ),
            (
                "selected_identifier",
                lambda markdown: markdown.replace(
                    "`VC08-GOALS-S07-R00 — Singular Living Pursuit Passage`",
                    "`VC08-GOALS-S99-R99 — Singular Living Pursuit Passage`",
                    1,
                ),
            ),
        )

        for label, mutate in cases:
            with self.subTest(label=label):
                with tempfile.TemporaryDirectory() as directory:
                    isolated_root = Path(directory)
                    for design_path in ACTIVE_DESIGN_PATHS:
                        target = isolated_root / design_path
                        target.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copy2(REPOSITORY_ROOT / design_path, target)

                    markdown_path = (
                        isolated_root
                        / "docs/canon/design/"
                        "VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md"
                    )
                    markdown = markdown_path.read_text(encoding="utf-8")
                    mutated = mutate(markdown)
                    self.assertNotEqual(mutated, markdown)
                    markdown_path.write_text(mutated, encoding="utf-8")

                    isolated = replace(self.compilation, root=isolated_root)
                    with self.assertRaisesRegex(
                        canon_compiler.CanonError,
                        "Wave 2 closure human/machine mismatch",
                    ):
                        canon_compiler.validate_design_artifacts(isolated)

    def test_wave_2_closure_rejects_masked_human_duplicates_extras_and_misplacement(
        self,
    ) -> None:
        vc_07_closed_row = "| `VC-07` | `CLOSED` | Today |"
        vc_08_selection = (
            "`VC08-GOALS-S07-R00 — Singular Living Pursuit Passage`"
        )
        cases = (
            (
                "contradictory_duplicate_status",
                lambda markdown: markdown.replace(
                    vc_07_closed_row,
                    vc_07_closed_row
                    + "\n| `VC-07` | `OPEN` | Contradictory duplicate |",
                    1,
                ),
            ),
            (
                "extra_package_avf",
                lambda markdown: markdown.replace(
                    "`AVF-GOALS-S08-R00 — Life Area Linked Goal Lens`",
                    "`AVF-GOALS-S08-R00 — Life Area Linked Goal Lens`"
                    "\n\n`AVF-NEW-S01-R00 — Unauthorized extra direction`",
                    1,
                ),
            ),
            (
                "changed_shared_package_avf",
                lambda markdown: markdown.replace(
                    "`AVF-A11Y-S07-R00 — Adaptive Semantic Continuity`",
                    "`AVF-A11Y-S99-R99 — Adaptive Semantic Continuity`",
                    1,
                ),
            ),
            (
                "misplaced_selected_identifier",
                lambda markdown: markdown.replace(
                    vc_08_selection,
                    "`VC08-GOALS-S99-R99 — Singular Living Pursuit Passage`",
                    1,
                )
                + "\n\nRetained outside the owning package: "
                + vc_08_selection
                + "\n",
            ),
            (
                "duplicate_selected_declaration",
                lambda markdown: markdown.replace(
                    vc_08_selection,
                    vc_08_selection + "\n\n" + vc_08_selection,
                    1,
                ),
            ),
            (
                "extra_selected_declaration",
                lambda markdown: markdown.replace(
                    vc_08_selection,
                    vc_08_selection
                    + "\n\n`VC08-GOALS-S99-R99 — Unauthorized extra selection`",
                    1,
                ),
            ),
        )

        for label, mutate in cases:
            with self.subTest(label=label):
                with tempfile.TemporaryDirectory() as directory:
                    isolated_root = Path(directory)
                    for design_path in ACTIVE_DESIGN_PATHS:
                        target = isolated_root / design_path
                        target.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copy2(REPOSITORY_ROOT / design_path, target)

                    markdown_path = (
                        isolated_root
                        / "docs/canon/design/"
                        "VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md"
                    )
                    markdown = markdown_path.read_text(encoding="utf-8")
                    mutated = mutate(markdown)
                    self.assertNotEqual(mutated, markdown)
                    markdown_path.write_text(mutated, encoding="utf-8")

                    isolated = replace(self.compilation, root=isolated_root)
                    with self.assertRaisesRegex(
                        canon_compiler.CanonError,
                        "Wave 2 closure human/machine mismatch",
                    ):
                        canon_compiler.validate_design_artifacts(isolated)

    def test_wave_2_closure_rejects_duplicate_human_authority_sections(
        self,
    ) -> None:
        duplicate_status_section = """

## 3. Package status

| Package | Status | Wave |
| --- | --- | --- |
| `VC-07` | `OPEN` | Contradictory duplicate |
| `VC-08` | `OPEN` | Contradictory duplicate |
| `VC-09` | `OPEN` | Contradictory duplicate |
| `VC-10` | `OPEN` | Contradictory duplicate |
| `VC-11` | `OPEN` | Contradictory duplicate |
| `VC-12` | `OPEN` | Contradictory duplicate |
"""
        duplicate_vc_08_section = """

## 60. VC-08 — Unauthorized Duplicate Authority

Locked closure:

`VC08-GOALS-S99-R99 — Unauthorized Duplicate Selection`

Applies within:

`AVF-NEW-S01-R00 — Unauthorized Duplicate Direction`
"""
        cases = (
            ("duplicate_package_status_section", duplicate_status_section),
            ("duplicate_vc_08_section", duplicate_vc_08_section),
        )

        for label, duplicate_section in cases:
            with self.subTest(label=label):
                with tempfile.TemporaryDirectory() as directory:
                    isolated_root = Path(directory)
                    for design_path in ACTIVE_DESIGN_PATHS:
                        target = isolated_root / design_path
                        target.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copy2(REPOSITORY_ROOT / design_path, target)

                    markdown_path = (
                        isolated_root
                        / "docs/canon/design/"
                        "VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md"
                    )
                    markdown = markdown_path.read_text(encoding="utf-8")
                    markdown_path.write_text(
                        markdown + duplicate_section,
                        encoding="utf-8",
                    )

                    isolated = replace(self.compilation, root=isolated_root)
                    with self.assertRaisesRegex(
                        canon_compiler.CanonError,
                        "Wave 2 closure human/machine mismatch",
                    ):
                        canon_compiler.validate_design_artifacts(isolated)

    def test_wave_2_closure_rejects_human_transformation_name_drift(
        self,
    ) -> None:
        human_path = Path(
            "docs/canon/design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md"
        )
        with tempfile.TemporaryDirectory() as directory:
            isolated_root = Path(directory)
            for design_path in ACTIVE_DESIGN_PATHS:
                target = isolated_root / design_path
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(REPOSITORY_ROOT / design_path, target)
            human_target = isolated_root / human_path
            source = human_target.read_text(encoding="utf-8")
            mutated = source.replace(
                "`VC11-YOU-D06 — Explicit Adaptive Control Passage`",
                "`VC11-YOU-D06 — Contradictory Control Passage`",
                1,
            )
            self.assertNotEqual(mutated, source)
            human_target.write_text(mutated, encoding="utf-8")
            refresh_visual_system_source_sha(isolated_root, human_path)

            isolated = replace(self.compilation, root=isolated_root)
            with self.assertRaisesRegex(
                canon_compiler.CanonError,
                "Wave 2 closure human/machine mismatch",
            ):
                canon_compiler.validate_design_artifacts(isolated)

    def test_wave_2_closure_rejects_contradictory_section_16_prose(
        self,
    ) -> None:
        human_path = Path(
            "docs/canon/design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md"
        )
        with tempfile.TemporaryDirectory() as directory:
            isolated_root = Path(directory)
            for design_path in ACTIVE_DESIGN_PATHS:
                target = isolated_root / design_path
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(REPOSITORY_ROOT / design_path, target)
            human_target = isolated_root / human_path
            source = human_target.read_text(encoding="utf-8")
            mutated = source.replace(
                "- Implementation authorization: `false`.\n"
                "- Wave 1: `CLOSED`.",
                "- Implementation authorization: `false`.\n\n"
                "Implementation authorization is also `true`.\n\n"
                "- Wave 1: `CLOSED`.",
                1,
            )
            self.assertNotEqual(mutated, source)
            human_target.write_text(mutated, encoding="utf-8")
            refresh_visual_system_source_sha(isolated_root, human_path)

            isolated = replace(self.compilation, root=isolated_root)
            with self.assertRaisesRegex(
                canon_compiler.CanonError,
                "Wave 2 closure human/machine mismatch",
            ):
                canon_compiler.validate_design_artifacts(isolated)

    def test_wave_2_machine_semantics_are_independently_locked(self) -> None:
        wave_2_json = Path(
            "docs/canon/design/vc-wave-2-surface-journey-closure.json"
        )
        wave_2_markdown = Path(
            "docs/canon/design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md"
        )
        cases = (
            (
                "coordinated_vc08_selection_change",
                lambda payload: {
                    **payload,
                    "packages": [
                        payload["packages"][0],
                        {
                            **payload["packages"][1],
                            "selected_study_or_synthesis": {
                                **payload["packages"][1][
                                    "selected_study_or_synthesis"
                                ],
                                "id": "VC08-GOALS-S99-R99",
                            },
                        },
                        *payload["packages"][2:],
                    ],
                },
                lambda markdown: markdown.replace(
                    "VC08-GOALS-S07-R00",
                    "VC08-GOALS-S99-R99",
                ),
            ),
            (
                "machine_only_transformation_change",
                lambda payload: {
                    **payload,
                    "packages": [
                        payload["packages"][0],
                        {
                            **payload["packages"][1],
                            "required_transformation": {
                                **payload["packages"][1][
                                    "required_transformation"
                                ],
                                "id": "VC08-GOALS-D99",
                            },
                        },
                        *payload["packages"][2:],
                    ],
                },
                lambda markdown: markdown,
            ),
            (
                "changed_wave_1_inheritance",
                lambda payload: {
                    **payload,
                    "inherits": {
                        **payload["inherits"],
                        "machine": (
                            "docs/canon/design/"
                            "visual-closure-input-contract.json"
                        ),
                    },
                },
                lambda markdown: markdown,
            ),
        )

        for label, mutate_json, mutate_markdown in cases:
            with self.subTest(label=label):
                with tempfile.TemporaryDirectory() as directory:
                    isolated_root = Path(directory)
                    for design_path in ACTIVE_DESIGN_PATHS:
                        target = isolated_root / design_path
                        target.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copy2(REPOSITORY_ROOT / design_path, target)
                    json_target = isolated_root / wave_2_json
                    payload = json.loads(json_target.read_text(encoding="utf-8"))
                    json_target.write_text(
                        json.dumps(mutate_json(payload), indent=2, sort_keys=True)
                        + "\n",
                        encoding="utf-8",
                    )
                    markdown_target = isolated_root / wave_2_markdown
                    markdown = markdown_target.read_text(encoding="utf-8")
                    markdown_target.write_text(
                        mutate_markdown(markdown),
                        encoding="utf-8",
                    )
                    isolated = replace(self.compilation, root=isolated_root)
                    with self.assertRaisesRegex(
                        canon_compiler.CanonError,
                        "Wave 2 closure",
                    ):
                        canon_compiler.validate_design_artifacts(isolated)

    def test_wave_2_human_global_authority_is_exact(self) -> None:
        cases = (
            (
                "appended_global_active_direction",
                lambda markdown: markdown
                + "\n12. `AVF-UNAUTHORIZED-S01-R00`\n",
            ),
            (
                "extra_active_direction",
                lambda markdown: markdown.replace(
                    "11. `AVF-COHERENCE-S07-R00`",
                    "11. `AVF-COHERENCE-S07-R00`\n"
                    "12. `AVF-UNAUTHORIZED-S01-R00`",
                    1,
                ),
            ),
            (
                "contradictory_vc01_status",
                lambda markdown: markdown.replace(
                    "| `VC-01`–`VC-06` | `CLOSED` | Wave 1 shared foundation |",
                    "| `VC-01`–`VC-06` | `CLOSED` | Wave 1 shared foundation |\n"
                    "| `VC-01` | `OPEN` | Contradictory duplicate |",
                    1,
                ),
            ),
            (
                "contradictory_vc13_status",
                lambda markdown: markdown.replace(
                    "| `VC-13` | `OPEN` | Extreme accessibility and content validation |",
                    "| `VC-13` | `OPEN` | Extreme accessibility and content validation |\n"
                    "| `VC-13` | `CLOSED` | Contradictory duplicate |",
                    1,
                ),
            ),
            (
                "misplaced_contradictory_vc13_status",
                lambda markdown: markdown
                + "\n| `VC-13` | `CLOSED` | Misplaced contradiction |\n",
            ),
            (
                "extra_shared_law",
                lambda markdown: markdown.replace(
                    "12. No Wave 2 package authorizes Figma, SwiftUI, "
                    "implementation, or final tokens.",
                    "12. No Wave 2 package authorizes Figma, SwiftUI, "
                    "implementation, or final tokens.\n"
                    "13. Unauthorized additive shared law.",
                    1,
                ),
            ),
            *(
                (
                    f"additive_true_{label}",
                    lambda markdown, false_line=false_line, true_line=true_line: (
                        markdown.replace(
                            false_line,
                            false_line + "\n" + true_line,
                            1,
                        )
                    ),
                )
                for label, false_line, true_line in (
                    (
                        "figma",
                        "- Figma authorization: `false`.",
                        "- Figma authorization: `true`.",
                    ),
                    (
                        "swiftui",
                        "- SwiftUI approval: `false`.",
                        "- SwiftUI approval: `true`.",
                    ),
                    (
                        "implementation",
                        "- Implementation authorization: `false`.",
                        "- Implementation authorization: `true`.",
                    ),
                )
            ),
            (
                "appended_true_implementation",
                lambda markdown: markdown
                + "\n- Implementation authorization: `true`.\n",
            ),
            (
                "duplicate_shared_law_heading",
                lambda markdown: markdown + "\n## 4. Shared Wave 2 law\n\nDuplicate.\n",
            ),
            (
                "duplicate_authorization_heading",
                lambda markdown: markdown + "\n## 16. Authorization state\n\n"
                "- Figma authorization: `true`.\n",
            ),
        )

        for label, mutate in cases:
            with self.subTest(label=label):
                with tempfile.TemporaryDirectory() as directory:
                    isolated_root = Path(directory)
                    for design_path in ACTIVE_DESIGN_PATHS:
                        target = isolated_root / design_path
                        target.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copy2(REPOSITORY_ROOT / design_path, target)
                    markdown_path = (
                        isolated_root
                        / "docs/canon/design/"
                        "VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md"
                    )
                    markdown = markdown_path.read_text(encoding="utf-8")
                    mutated = mutate(markdown)
                    self.assertNotEqual(mutated, markdown)
                    markdown_path.write_text(mutated, encoding="utf-8")
                    isolated = replace(self.compilation, root=isolated_root)
                    with self.assertRaisesRegex(
                        canon_compiler.CanonError,
                        "Wave 2 closure human/machine mismatch",
                    ):
                        canon_compiler.validate_design_artifacts(isolated)

    def test_wave_2_machine_json_rejects_duplicate_keys(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            isolated_root = Path(directory)
            for design_path in ACTIVE_DESIGN_PATHS:
                target = isolated_root / design_path
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(REPOSITORY_ROOT / design_path, target)
            json_path = (
                isolated_root
                / "docs/canon/design/"
                "vc-wave-2-surface-journey-closure.json"
            )
            source = json_path.read_text(encoding="utf-8")
            mutated = source.replace(
                '  "status": "CLOSED",',
                '  "status": "CLOSED",\n  "status": "CLOSED",',
                1,
            )
            self.assertNotEqual(mutated, source)
            json_path.write_text(mutated, encoding="utf-8")
            isolated = replace(self.compilation, root=isolated_root)
            with self.assertRaisesRegex(
                canon_compiler.CanonError,
                "duplicate JSON key",
            ):
                canon_compiler.validate_design_artifacts(isolated)

    def test_wave_2_machine_json_rejects_unknown_and_malformed_records(
        self,
    ) -> None:
        cases = (
            (
                "unknown_top_level",
                lambda payload: {**payload, "implementation_authorized": True},
            ),
            (
                "unknown_package",
                lambda payload: {
                    **payload,
                    "packages": [
                        {
                            **payload["packages"][0],
                            "implementation_authorized": True,
                        },
                        *payload["packages"][1:],
                    ],
                },
            ),
            (
                "unknown_nested_selection",
                lambda payload: {
                    **payload,
                    "packages": [
                        payload["packages"][0],
                        {
                            **payload["packages"][1],
                            "selected_study_or_synthesis": {
                                **payload["packages"][1][
                                    "selected_study_or_synthesis"
                                ],
                                "implementation_authorized": True,
                            },
                        },
                        *payload["packages"][2:],
                    ],
                },
            ),
            (
                "traversal_source_path",
                lambda payload: {
                    **payload,
                    "source_paths": ["../outside.md", *payload["source_paths"][1:]],
                },
            ),
            (
                "extra_vc10_record",
                lambda payload: {
                    **payload,
                    "packages": [
                        *payload["packages"][:3],
                        {
                            **payload["packages"][3],
                            "selected_study_or_synthesis": {
                                **payload["packages"][3][
                                    "selected_study_or_synthesis"
                                ],
                                "records": [
                                    *payload["packages"][3][
                                        "selected_study_or_synthesis"
                                    ]["records"],
                                    {"id": "EXTRA", "name": "Extra"},
                                ],
                            },
                        },
                        *payload["packages"][4:],
                    ],
                },
            ),
            (
                "missing_vc08_selection_id",
                lambda payload: {
                    **payload,
                    "packages": [
                        payload["packages"][0],
                        {
                            **payload["packages"][1],
                            "selected_study_or_synthesis": {
                                key: value
                                for key, value in payload["packages"][1][
                                    "selected_study_or_synthesis"
                                ].items()
                                if key != "id"
                            },
                        },
                        *payload["packages"][2:],
                    ],
                },
            ),
            (
                "wrong_packages_type",
                lambda payload: {**payload, "packages": "invalid"},
            ),
        )

        for label, mutate in cases:
            with self.subTest(label=label):
                with tempfile.TemporaryDirectory() as directory:
                    isolated_root = Path(directory)
                    for design_path in ACTIVE_DESIGN_PATHS:
                        target = isolated_root / design_path
                        target.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copy2(REPOSITORY_ROOT / design_path, target)
                    json_path = (
                        isolated_root
                        / "docs/canon/design/"
                        "vc-wave-2-surface-journey-closure.json"
                    )
                    payload = json.loads(json_path.read_text(encoding="utf-8"))
                    json_path.write_text(
                        json.dumps(mutate(payload), indent=2, sort_keys=True) + "\n",
                        encoding="utf-8",
                    )
                    isolated = replace(self.compilation, root=isolated_root)
                    with self.assertRaises(canon_compiler.CanonError):
                        canon_compiler.validate_design_artifacts(isolated)

    def test_visual_system_provenance_rejects_stale_current_source_sha(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            isolated_root = Path(directory)
            for design_path in ACTIVE_DESIGN_PATHS:
                target = isolated_root / design_path
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(REPOSITORY_ROOT / design_path, target)
            visual_system_path = (
                isolated_root / "docs/canon/design/VISUAL_SYSTEM_R1.md"
            )
            source = visual_system_path.read_text(encoding="utf-8")
            mutated = re.sub(
                r"(?m)(^- Wave 2 closure JSON SHA-256 for `[^`]+`: `)"
                r"[0-9a-f]{64}(`;)$",
                r"\g<1>" + "0" * 64 + r"\2",
                source,
                count=1,
            )
            self.assertNotEqual(mutated, source)
            visual_system_path.write_text(mutated, encoding="utf-8")
            isolated = replace(self.compilation, root=isolated_root)
            with self.assertRaisesRegex(
                canon_compiler.CanonError,
                "Visual System provenance",
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
