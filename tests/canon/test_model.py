import runpy
import subprocess
import sys
import unittest
from collections import namedtuple
from contextlib import redirect_stderr, redirect_stdout
from io import StringIO
from pathlib import Path
from unittest import mock

import tools.ambitions_canon.model as canon_model
from tools.ambitions_canon.model import (
    AuthorityClass,
    AuthorityState,
    CanonDocument,
    CanonError,
    CanonManifest,
    CanonRegistry,
    DocumentKind,
    Finding,
    GapSeverity,
    ManifestEntry,
    Modality,
    NotApplicable,
    Requirement,
    normalize_visible_attribution,
)


UNICODE_16_ASSIGNED_RANGES = (
    (0x0897, 0x0897),
    (0x1B4E, 0x1B4F),
    (0x1B7F, 0x1B7F),
    (0x1C89, 0x1C8A),
    (0x2427, 0x2429),
    (0x31E4, 0x31E5),
    (0xA7CB, 0xA7CD),
    (0xA7DA, 0xA7DC),
    (0x105C0, 0x105F3),
    (0x10D40, 0x10D65),
    (0x10D69, 0x10D85),
    (0x10D8E, 0x10D8F),
    (0x10EC2, 0x10EC4),
    (0x10EFC, 0x10EFC),
    (0x11380, 0x11389),
    (0x1138B, 0x1138B),
    (0x1138E, 0x1138E),
    (0x11390, 0x113B5),
    (0x113B7, 0x113C0),
    (0x113C2, 0x113C2),
    (0x113C5, 0x113C5),
    (0x113C7, 0x113CA),
    (0x113CC, 0x113D5),
    (0x113D7, 0x113D8),
    (0x113E1, 0x113E2),
    (0x116D0, 0x116E3),
    (0x11BC0, 0x11BE1),
    (0x11BF0, 0x11BF9),
    (0x11F5A, 0x11F5A),
    (0x13460, 0x143FA),
    (0x16100, 0x16139),
    (0x16D40, 0x16D79),
    (0x18CFF, 0x18CFF),
    (0x1CC00, 0x1CCF9),
    (0x1CD00, 0x1CEB3),
    (0x1E5D0, 0x1E5FA),
    (0x1E5FF, 0x1E5FF),
    (0x1F8B2, 0x1F8BB),
    (0x1F8C0, 0x1F8C1),
    (0x1FA89, 0x1FA89),
    (0x1FA8F, 0x1FA8F),
    (0x1FABE, 0x1FABE),
    (0x1FAC6, 0x1FAC6),
    (0x1FADC, 0x1FADC),
    (0x1FADF, 0x1FADF),
    (0x1FAE9, 0x1FAE9),
    (0x1FBCB, 0x1FBEF),
)

UNICODE_15_1_ASSIGNED_RANGES = (
    (0x2FFC, 0x2FFF),
    (0x31EF, 0x31EF),
    (0x2EBF0, 0x2EE5D),
)


class ModelTests(unittest.TestCase):
    def test_visible_attribution_policy_is_pinned_to_unicode_15(self):
        self.assertEqual(
            getattr(canon_model, "ATTRIBUTION_UNICODE_POLICY_VERSION", None),
            "15.0.0",
        )
        unicode_15_1_ranges = getattr(
            canon_model,
            "_UNICODE_15_1_ASSIGNED_RANGES",
            (),
        )
        unicode_16_ranges = getattr(
            canon_model,
            "_UNICODE_16_ASSIGNED_RANGES",
            (),
        )
        self.assertEqual(unicode_15_1_ranges, UNICODE_15_1_ASSIGNED_RANGES)
        self.assertEqual(unicode_16_ranges, UNICODE_16_ASSIGNED_RANGES)
        self.assertEqual(len(unicode_15_1_ranges), 3)
        self.assertEqual(
            sum(upper - lower + 1 for lower, upper in unicode_15_1_ranges),
            627,
        )
        self.assertEqual(len(unicode_16_ranges), 47)
        self.assertEqual(
            sum(upper - lower + 1 for lower, upper in unicode_16_ranges),
            5_185,
        )
        for ranges in (unicode_15_1_ranges, unicode_16_ranges):
            self.assertTrue(
                all(
                    left_upper < right_lower
                    for (_, left_upper), (right_lower, _) in zip(
                        ranges,
                        ranges[1:],
                    )
                )
            )

    def test_visible_attribution_rejects_every_post_unicode_15_0_range_boundary(self):
        for ranges in (UNICODE_15_1_ASSIGNED_RANGES, UNICODE_16_ASSIGNED_RANGES):
            for lower, upper in ranges:
                for code_point in dict.fromkeys((lower, upper)):
                    with self.subTest(code_point=f"U+{code_point:04X}"):
                        with self.assertRaises(ValueError):
                            normalize_visible_attribution(
                                f"Owner{chr(code_point)}"
                            )

    def test_visible_attribution_rejects_post_policy_scalars_before_host_properties(self):
        for code_point in (0x2FFC, 0x105C0):
            post_policy_scalar = chr(code_point)
            with self.subTest(code_point=f"U+{code_point:04X}"):
                with (
                    mock.patch.object(
                        canon_model.unicodedata,
                        "unidata_version",
                        "99.0.0",
                    ),
                    mock.patch.object(
                        canon_model.unicodedata,
                        "category",
                        return_value="Lo",
                    ) as category,
                ):
                    with self.assertRaises(ValueError):
                        normalize_visible_attribution(
                            f"Owner{post_policy_scalar}"
                        )
                self.assertNotIn(
                    post_policy_scalar,
                    (call.args[0] for call in category.call_args_list),
                )

    def test_visible_attribution_preserves_unicode_15_0_letters(self):
        self.assertEqual(
            normalize_visible_attribution("Reviewer \U00011f04"),
            "Reviewer \U00011f04",
        )

    def test_visible_attribution_rejects_every_unicode_15_default_ignorable_range(self):
        range_boundaries = (
            0x00AD,
            0x034F,
            0x061C,
            0x115F, 0x1160,
            0x17B4, 0x17B5,
            0x180B, 0x180D,
            0x180E,
            0x180F,
            0x200B, 0x200F,
            0x202A, 0x202E,
            0x2060, 0x2064,
            0x2065,
            0x2066, 0x206F,
            0x3164,
            0xFE00, 0xFE0F,
            0xFEFF,
            0xFFA0,
            0xFFF0, 0xFFF8,
            0x1BCA0, 0x1BCA3,
            0x1D173, 0x1D17A,
            0xE0000,
            0xE0001,
            0xE0002, 0xE001F,
            0xE0020, 0xE007F,
            0xE0080, 0xE00FF,
            0xE0100, 0xE01EF,
            0xE01F0, 0xE0FFF,
        )

        for code_point in range_boundaries:
            with self.subTest(code_point=f"U+{code_point:04X}"):
                with self.assertRaises(ValueError):
                    normalize_visible_attribution(f"Owner{chr(code_point)}")

    def test_visible_attribution_requires_base_and_preserves_international_names(self):
        for mark_only in ("\u0301", "\u093c", "\ufe0f", "\u034f", "\u180b"):
            with self.subTest(mark_only=repr(mark_only)):
                with self.assertRaises(ValueError):
                    normalize_visible_attribution(mark_only)

        valid = {
            "  E\u0301lodie   山田  ": "Élodie 山田",
            "مُحَمَّد": "مُحَمَّد",
            "अनन्या": "अनन्या",
            "山田 太郎": "山田 太郎",
        }
        for source, expected in valid.items():
            with self.subTest(source=source):
                self.assertEqual(normalize_visible_attribution(source), expected)

    def test_requirement_is_immutable(self):
        requirement = Requirement(
            requirement_id="TODAY-IDENTITY-001",
            title="Primary identity",
            concept="surface.today.primary-identity",
            modality=Modality.MUST,
            scope="Today root at rest",
            status="normative",
            verification=("SCENARIO-TODAY-001",),
            supersedes=(),
            body="Today presents actionable reality around now.",
            source_path=Path("today.md"),
            line=10,
        )
        with self.assertRaises(AttributeError):
            requirement.title = "Changed"

    def test_rejects_unsupported_python(self):
        from tools.ambitions_canon.cli import ensure_supported_python

        for version in ((3, 10), (3, 11), (3, 15)):
            with self.subTest(version=version):
                with self.assertRaisesRegex(
                    CanonError,
                    "PYTHON_VERSION_UNSUPPORTED.*requires Python 3.12-3.14",
                ):
                    ensure_supported_python(version)

        for version in ((3, 12), (3, 13), (3, 14)):
            with self.subTest(version=version):
                ensure_supported_python(version)

    def test_launcher_enforces_the_same_supported_python_range(self):
        version_info = namedtuple(
            "version_info",
            ("major", "minor", "micro", "releaselevel", "serial"),
        )
        launcher = Path(__file__).resolve().parents[2] / "scripts/ambitions-canon.py"

        for minor in (11, 15):
            stderr = StringIO()
            with self.subTest(minor=minor):
                with (
                    mock.patch.object(
                        sys,
                        "version_info",
                        version_info(3, minor, 0, "final", 0),
                    ),
                    redirect_stderr(stderr),
                    self.assertRaises(SystemExit) as raised,
                ):
                    runpy.run_path(str(launcher), run_name="__main__")
                self.assertEqual(raised.exception.code, 2)
                self.assertIn(
                    "PYTHON_VERSION_UNSUPPORTED requires Python 3.12-3.14",
                    stderr.getvalue(),
                )

    def test_canon_error_formats_stable_code_path_and_line(self):
        error = CanonError(
            "CANON_PARSE_FRONT_MATTER",
            "missing closing delimiter",
            Path("today.md"),
            3,
        )
        self.assertEqual(
            str(error),
            "CANON_PARSE_FRONT_MATTER today.md:3 missing closing delimiter",
        )

    def test_canon_error_omits_only_absent_location_parts(self):
        cases = (
            (
                CanonError("CANON_PATH", "path only", Path("today.md")),
                "CANON_PATH today.md path only",
            ),
            (
                CanonError("CANON_LINE", "line only", line=7),
                "CANON_LINE line:7 line only",
            ),
            (
                CanonError("CANON_GENERAL", "no location"),
                "CANON_GENERAL no location",
            ),
        )
        for error, expected in cases:
            with self.subTest(expected=expected):
                self.assertEqual(str(error), expected)

    def test_requirement_normalizes_mutable_collection_inputs(self):
        verification = ["SCENARIO-TODAY-001"]
        supersedes = ["DECISION-044"]
        requirement = Requirement(
            requirement_id="TODAY-IDENTITY-001",
            title="Primary identity",
            concept="surface.today.primary-identity",
            modality=Modality.MUST,
            scope="Today root at rest",
            status="normative",
            verification=verification,
            supersedes=supersedes,
            body="Today presents actionable reality around now.",
            source_path=Path("today.md"),
            line=10,
        )

        verification.append("SCENARIO-TODAY-002")
        supersedes.clear()

        self.assertEqual(requirement.verification, ("SCENARIO-TODAY-001",))
        self.assertIsInstance(requirement.verification, tuple)
        self.assertEqual(requirement.supersedes, ("DECISION-044",))
        self.assertIsInstance(requirement.supersedes, tuple)

    def test_document_normalizes_every_mutable_collection_input(self):
        requirement = Requirement(
            requirement_id="TODAY-IDENTITY-001",
            title="Primary identity",
            concept="surface.today.primary-identity",
            modality=Modality.MUST,
            scope="Today root at rest",
            status="normative",
            verification=(),
            supersedes=(),
            body="Today presents actionable reality around now.",
            source_path=Path("today.md"),
            line=10,
        )
        not_applicable = NotApplicable(
            section="performance",
            rationale="No continuous work.",
            owner="engineering",
        )
        owns_concepts = ["surface.today.primary-identity"]
        inherits = ["MISSION-001"]
        depends_on = ["OBJECT-STEP"]
        source_owners = ["Native/Ambitions/Surfaces/Today"]
        sections = {"purpose"}
        not_applicable_entries = [not_applicable]
        requirements = [requirement]
        document = CanonDocument(
            spec_id="SURFACE-TODAY",
            title="Today",
            kind=DocumentKind.SURFACE,
            status="normative",
            owner_domain="product",
            canon_revision=1,
            profile="surface-v1",
            owns_concepts=owns_concepts,
            inherits=inherits,
            depends_on=depends_on,
            source_owners=source_owners,
            sections=sections,
            not_applicable=not_applicable_entries,
            requirements=requirements,
            source_path=Path("today.md"),
        )

        owns_concepts.append("surface.today.changed")
        inherits.clear()
        depends_on.append("OBJECT-EVENT")
        source_owners.append("Native/Ambitions/Features/Today")
        sections.add("changed")
        not_applicable_entries.clear()
        requirements.clear()

        self.assertEqual(
            document.owns_concepts,
            ("surface.today.primary-identity",),
        )
        self.assertEqual(document.inherits, ("MISSION-001",))
        self.assertEqual(document.depends_on, ("OBJECT-STEP",))
        self.assertEqual(
            document.source_owners,
            ("Native/Ambitions/Surfaces/Today",),
        )
        self.assertEqual(document.sections, frozenset({"purpose"}))
        self.assertEqual(document.not_applicable, (not_applicable,))
        self.assertEqual(document.requirements, (requirement,))
        for value in (
            document.owns_concepts,
            document.inherits,
            document.depends_on,
            document.source_owners,
            document.not_applicable,
            document.requirements,
        ):
            self.assertIsInstance(value, tuple)
        self.assertIsInstance(document.sections, frozenset)

    def test_manifest_normalizes_every_mutable_collection_input(self):
        entry = ManifestEntry(path=Path("specifications/surfaces/today.md"))
        normative_files = [entry]
        generated_files = [Path("generated/INDEX.md")]
        manifest = CanonManifest(
            schema_version=1,
            canon_revision=0,
            authority_state=AuthorityState.SHADOW,
            compiler_version="0.1.0",
            normative_files=normative_files,
            generated_files=generated_files,
            source_path=Path("docs/canon/MANIFEST.toml"),
        )

        normative_files.clear()
        generated_files.append(Path("generated/changed.json"))

        self.assertEqual(manifest.normative_files, (entry,))
        self.assertIsInstance(manifest.normative_files, tuple)
        self.assertEqual(manifest.generated_files, (Path("generated/INDEX.md"),))
        self.assertIsInstance(manifest.generated_files, tuple)

    def test_loaded_provenance_is_copied_into_immutable_value_types(self):
        manifest_bytes = bytearray(b"manifest\n")
        document_bytes = bytearray(b"document\n")
        document = CanonDocument(
            spec_id="SURFACE-TODAY",
            title="Today",
            kind=DocumentKind.SURFACE,
            status="normative",
            owner_domain="product",
            canon_revision=1,
            profile=None,
            owns_concepts=(),
            inherits=(),
            depends_on=(),
            source_owners=(),
            sections=frozenset(),
            not_applicable=(),
            requirements=(),
            source_path=Path("docs/canon/today.md"),
            source_bytes=document_bytes,
        )
        manifest = CanonManifest(
            schema_version=1,
            canon_revision=1,
            authority_state=AuthorityState.SHADOW,
            compiler_version="0.1.0",
            normative_files=(),
            generated_files=(),
            source_path=Path("docs/canon/MANIFEST.toml"),
            repository_root="/tmp/repository",
            source_bytes=manifest_bytes,
        )

        manifest_bytes[:] = b"changed\n"
        document_bytes[:] = b"changed\n"

        self.assertEqual(manifest.repository_root, Path("/tmp/repository"))
        self.assertEqual(manifest.source_bytes, b"manifest\n")
        self.assertEqual(document.source_bytes, b"document\n")
        self.assertIsInstance(manifest.source_bytes, bytes)
        self.assertIsInstance(document.source_bytes, bytes)

    def test_registry_normalizes_mutable_inputs_and_nested_concept_owner_pairs(self):
        requirement = Requirement(
            requirement_id="TODAY-IDENTITY-001",
            title="Primary identity",
            concept="surface.today.primary-identity",
            modality=Modality.MUST,
            scope="Today root at rest",
            status="normative",
            verification=(),
            supersedes=(),
            body="Today presents actionable reality around now.",
            source_path=Path("today.md"),
            line=10,
        )
        document = CanonDocument(
            spec_id="SURFACE-TODAY",
            title="Today",
            kind=DocumentKind.SURFACE,
            status="normative",
            owner_domain="product",
            canon_revision=1,
            profile="surface-v1",
            owns_concepts=("surface.today.primary-identity",),
            inherits=(),
            depends_on=(),
            source_owners=(),
            sections=frozenset(),
            not_applicable=(),
            requirements=(requirement,),
            source_path=Path("today.md"),
        )
        manifest = CanonManifest(
            schema_version=1,
            canon_revision=0,
            authority_state=AuthorityState.SHADOW,
            compiler_version="0.1.0",
            normative_files=(),
            generated_files=(),
            source_path=Path("docs/canon/MANIFEST.toml"),
        )
        documents = [document]
        requirements = [requirement]
        concept_owners = [["surface.today.primary-identity", "SURFACE-TODAY"]]
        superseded_ids = {"DECISION-044"}
        registry = CanonRegistry(
            manifest=manifest,
            documents=documents,
            requirements=requirements,
            concept_owners=concept_owners,
            superseded_ids=superseded_ids,
        )

        documents.clear()
        requirements.clear()
        concept_owners[0][0] = "surface.today.changed"
        concept_owners.append(["surface.today.other", "SURFACE-OTHER"])
        superseded_ids.add("DECISION-045")

        self.assertEqual(registry.documents, (document,))
        self.assertIsInstance(registry.documents, tuple)
        self.assertEqual(registry.requirements, (requirement,))
        self.assertIsInstance(registry.requirements, tuple)
        self.assertEqual(
            registry.concept_owners,
            (("surface.today.primary-identity", "SURFACE-TODAY"),),
        )
        self.assertIsInstance(registry.concept_owners, tuple)
        self.assertIsInstance(registry.concept_owners[0], tuple)
        self.assertEqual(registry.superseded_ids, frozenset({"DECISION-044"}))
        self.assertIsInstance(registry.superseded_ids, frozenset)

    def test_enum_values_are_stable(self):
        self.assertEqual(
            tuple(AuthorityState),
            (AuthorityState.SHADOW, AuthorityState.ACTIVE),
        )
        self.assertEqual(
            tuple(member.value for member in AuthorityClass),
            (
                "constitution",
                "specification",
                "standard",
                "decision_docket",
                "generated_projection",
                "source_and_tests",
                "linear",
                "figma",
            ),
        )
        self.assertEqual(
            tuple(member.value for member in DocumentKind),
            (
                "constitution",
                "app",
                "surface",
                "global",
                "object",
                "journey",
                "system",
                "standard",
            ),
        )
        self.assertEqual(
            tuple(member.value for member in Modality),
            ("MUST", "MUST NOT", "SHOULD", "SHOULD NOT", "MAY", "INFORMATIONAL"),
        )
        self.assertEqual(
            tuple(member.value for member in GapSeverity),
            ("P0_BLOCKER", "P1_REQUIRED", "P2_IMPROVEMENT", "INFORMATIONAL"),
        )

    def test_all_record_types_are_immutable_and_store_stable_collections(self):
        requirement = Requirement(
            requirement_id="TODAY-IDENTITY-001",
            title="Primary identity",
            concept="surface.today.primary-identity",
            modality=Modality.MUST,
            scope="Today root at rest",
            status="normative",
            verification=("SCENARIO-TODAY-001",),
            supersedes=(),
            body="Today presents actionable reality around now.",
            source_path=Path("today.md"),
            line=10,
        )
        not_applicable = NotApplicable(
            section="performance",
            rationale="No continuous work.",
            owner="engineering",
        )
        document = CanonDocument(
            spec_id="SURFACE-TODAY",
            title="Today",
            kind=DocumentKind.SURFACE,
            status="normative",
            owner_domain="product",
            canon_revision=1,
            profile="surface-v1",
            owns_concepts=("surface.today.primary-identity",),
            inherits=("MISSION-001",),
            depends_on=("OBJECT-STEP",),
            source_owners=("Native/Ambitions/Surfaces/Today",),
            sections=frozenset({"purpose"}),
            not_applicable=(not_applicable,),
            requirements=(requirement,),
            source_path=Path("today.md"),
        )
        entry = ManifestEntry(path=Path("specifications/surfaces/today.md"))
        manifest = CanonManifest(
            schema_version=1,
            canon_revision=0,
            authority_state=AuthorityState.SHADOW,
            compiler_version="0.1.0",
            normative_files=(entry,),
            generated_files=(Path("generated/INDEX.md"),),
            source_path=Path("docs/canon/MANIFEST.toml"),
        )
        finding = Finding(
            code="CANON_PROFILE_SECTION_MISSING",
            severity=GapSeverity.P0_BLOCKER,
            message="missing purpose",
            path=Path("today.md"),
            line=4,
        )
        registry = CanonRegistry(
            manifest=manifest,
            documents=(document,),
            requirements=(requirement,),
            concept_owners=(("surface.today.primary-identity", "SURFACE-TODAY"),),
            superseded_ids=frozenset({"DECISION-044"}),
        )

        for record, field_name in (
            (requirement, "title"),
            (not_applicable, "owner"),
            (document, "title"),
            (entry, "path"),
            (manifest, "canon_revision"),
            (finding, "message"),
            (registry, "documents"),
        ):
            with self.subTest(record=type(record).__name__):
                with self.assertRaises(AttributeError):
                    setattr(record, field_name, None)
                self.assertTrue(hasattr(type(record), "__slots__"))

    def test_version_command_prints_exact_version(self):
        from tools.ambitions_canon.cli import main

        output = StringIO()
        with redirect_stdout(output):
            result = main(("version",))

        self.assertEqual(result, 0)
        self.assertEqual(output.getvalue(), "ambitions-canon 0.2.0\n")

    def test_thin_script_loads_package_from_repository_root(self):
        root = Path(__file__).parents[2]
        result = subprocess.run(
            [sys.executable, str(root / "scripts/ambitions-canon.py"), "version"],
            cwd=root,
            text=True,
            capture_output=True,
            check=False,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "ambitions-canon 0.2.0\n")
        self.assertEqual(result.stderr, "")


if __name__ == "__main__":
    unittest.main()
