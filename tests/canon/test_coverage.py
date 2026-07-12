import json
import os
import tempfile
import unittest
from contextlib import redirect_stdout
from dataclasses import replace
from io import StringIO
from pathlib import Path

from tools.ambitions_canon.cli import main
from tools.ambitions_canon.coverage import (
    GAP_SEVERITY,
    GapClass,
    GapDescriptor,
    coverage_findings,
    load_profiles,
)
from tools.ambitions_canon.model import (
    AuthorityState,
    CanonDocument,
    CanonError,
    CanonManifest,
    CanonRegistry,
    DocumentKind,
    GapSeverity,
    NotApplicable,
)
from tools.ambitions_canon.parser import parse_canon_document
from tests.canon.canon_test_support import write_required_governance_artifacts


ROOT = Path(__file__).resolve().parents[2]
PROFILE_PATH = ROOT / "docs/canon/schemas/completeness-profiles.toml"
FIXTURES = Path(__file__).parent / "fixtures"
SECTION_KEY_PATTERN = r"^[a-z0-9]+(?:-[a-z0-9]+)*$"

EXPECTED_PROFILES = {
    "surface-v1": (
        "purpose-user-question",
        "entry-exit",
        "routes-presentation",
        "displayed-objects",
        "resting-states",
        "loading-transitional",
        "empty-degraded",
        "commands-actions",
        "durable-effects",
        "failure-rollback",
        "offline",
        "privacy-data-classification",
        "accessibility-reading-order",
        "dynamic-type",
        "reduce-motion",
        "reduce-transparency",
        "copy-state-language",
        "visual-authority",
        "source-ownership",
        "tests",
        "proof",
        "performance",
    ),
    "object-v1": (
        "stable-identity",
        "user-meaning",
        "relationships",
        "lifecycle",
        "valid-transitions",
        "invalid-transitions",
        "commands",
        "recurrence-scheduling",
        "deletion-trash-restore-archive",
        "history-receipts",
        "privacy-sync-classification",
        "import-export",
        "projection-surfaces",
        "accessibility",
        "source-test-ownership",
    ),
    "journey-v1": (
        "trigger-starting-state",
        "preconditions",
        "happy-path",
        "branches",
        "cancellation",
        "interruption-resume",
        "commit-boundary",
        "failure",
        "recovery",
        "undo-rollback",
        "receipts-proof",
        "accessibility",
        "offline",
        "scenario-tests",
    ),
    "system-v1": (
        "responsibility-non-responsibility",
        "inputs-outputs",
        "authority-boundary",
        "data-classification",
        "state-model",
        "failure-recovery",
        "local-network-boundary",
        "determinism",
        "observability",
        "source-ownership",
        "tests-proof",
        "performance-resource-constraints",
    ),
    "standard-v1": (
        "purpose",
        "scope",
        "requirements",
        "exceptions",
        "verification",
        "source-ownership",
        "proof",
        "amendment-impact",
    ),
}


def fixture_document(name: str) -> CanonDocument:
    path = FIXTURES / name
    text = path.read_text(encoding="utf-8")
    return replace(
        parse_canon_document(path, text),
        source_bytes=text.encode("utf-8"),
    )


def registry(*documents: CanonDocument) -> CanonRegistry:
    manifest = CanonManifest(
        schema_version=1,
        canon_revision=1,
        authority_state=AuthorityState.SHADOW,
        compiler_version="0.1.0",
        normative_files=(),
        generated_files=(),
        source_path=Path("docs/canon/MANIFEST.toml"),
    )
    return CanonRegistry(
        manifest=manifest,
        documents=documents,
        requirements=tuple(
            requirement
            for document in documents
            for requirement in document.requirements
        ),
        concept_owners=tuple(
            (concept, document.spec_id)
            for document in documents
            for concept in document.owns_concepts
        ),
        superseded_ids=frozenset(),
    )


def document_from_text(text: str) -> CanonDocument:
    path = Path("docs/canon/specifications/test.md")
    return replace(
        parse_canon_document(path, text),
        source_bytes=text.encode("utf-8"),
    )


def minimal_document(
    *,
    profile: str,
    marker: str,
    content: str,
    kind: str = "standard",
) -> CanonDocument:
    return document_from_text(
        "+++\n"
        'spec_id = "STANDARD-TEST"\n'
        'title = "Test"\n'
        f'kind = "{kind}"\n'
        'status = "normative"\n'
        'owner_domain = "product"\n'
        "canon_revision = 1\n"
        f'profile = "{profile}"\n'
        'owns_concepts = ["standard.test"]\n'
        "inherits = []\n"
        "depends_on = []\n"
        "source_owners = []\n"
        "+++\n\n"
        f"<!-- canon-section: {marker} -->\n"
        f"{content}"
    )


class ProfileTests(unittest.TestCase):
    def test_exact_profiles_match_the_approved_design(self):
        profiles = load_profiles(PROFILE_PATH)

        self.assertEqual(dict(profiles), EXPECTED_PROFILES)
        self.assertEqual(
            profiles["surface-v1"][13:16],
            ("dynamic-type", "reduce-motion", "reduce-transparency"),
        )

    def test_malformed_or_noncanonical_profile_fails_closed(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            path = Path(temporary_directory) / "profiles.toml"
            path.write_text(
                "schema_version = 1\n"
                "[profiles]\n"
                'standard-v1 = ["Purpose"]\n',
                encoding="utf-8",
            )

            with self.assertRaises(CanonError) as raised:
                load_profiles(path)
            self.assertEqual(raised.exception.code, "CANON_PROFILE_SCHEMA")

    def test_not_applicable_schema_matches_the_closed_runtime_shape(self):
        schema = json.loads(
            (ROOT / "docs/canon/schemas/specification.schema.json").read_text(
                encoding="utf-8"
            )
        )

        not_applicable = schema["properties"]["not_applicable"]
        self.assertEqual(not_applicable["type"], "object")
        self.assertEqual(not_applicable["propertyNames"]["pattern"], SECTION_KEY_PATTERN)
        self.assertFalse(not_applicable["additionalProperties"])
        self.assertEqual(set(not_applicable["patternProperties"]), {SECTION_KEY_PATTERN})
        entry = not_applicable["patternProperties"][SECTION_KEY_PATTERN]
        self.assertEqual(entry["type"], "object")
        self.assertFalse(entry["additionalProperties"])
        self.assertEqual(entry["required"], ["rationale", "owner"])
        self.assertEqual(set(entry["properties"]), {"rationale", "owner"})
        self.assertTrue(
            all(
                value == {"type": "string", "minLength": 1}
                for value in entry["properties"].values()
            )
        )

    def test_approved_profile_cells_cannot_be_weakened_in_toml(self):
        weakened = PROFILE_PATH.read_text(encoding="utf-8").replace(
            'surface-v1 = [\n  "purpose-user-question",',
            'surface-v1 = [\n  "purpose-user-question-only",',
        )
        with tempfile.TemporaryDirectory() as temporary_directory:
            path = Path(temporary_directory) / "profiles.toml"
            path.write_text(weakened, encoding="utf-8")

            with self.assertRaises(CanonError) as raised:
                load_profiles(path)
            self.assertEqual(raised.exception.code, "CANON_PROFILE_SCHEMA")

    def test_app_kind_uses_the_system_completeness_profile(self):
        sections = "\n".join(
            f"<!-- canon-section: {section} -->\nDefined {section}."
            for section in EXPECTED_PROFILES["system-v1"]
        )
        document = document_from_text(
            "+++\n"
            'spec_id = "APP-TEST"\n'
            'title = "App Test"\n'
            'kind = "app"\n'
            'status = "normative"\n'
            'owner_domain = "app"\n'
            "canon_revision = 1\n"
            'profile = "system-v1"\n'
            'owns_concepts = ["app.test"]\n'
            "inherits = []\n"
            "depends_on = []\n"
            "source_owners = []\n"
            "+++\n\n"
            f"{sections}\n"
        )

        self.assertEqual(
            coverage_findings(registry(document), load_profiles(PROFILE_PATH)),
            (),
        )

    def test_global_kind_allows_presented_surface_or_cross_surface_system_profile(self):
        profiles = load_profiles(PROFILE_PATH)
        for profile in ("surface-v1", "system-v1"):
            sections = "\n".join(
                f"<!-- canon-section: {section} -->\nDefined {section}."
                for section in EXPECTED_PROFILES[profile]
            )
            document = document_from_text(
                "+++\n"
                f'spec_id = "GLOBAL-{profile.upper()}"\n'
                f'title = "Global {profile}"\n'
                'kind = "global"\n'
                'status = "normative"\n'
                'owner_domain = "global"\n'
                "canon_revision = 1\n"
                f'profile = "{profile}"\n'
                f'owns_concepts = ["global.{profile}"]\n'
                "inherits = []\n"
                "depends_on = []\n"
                "source_owners = []\n"
                "+++\n\n"
                f"{sections}\n"
            )

            self.assertEqual(coverage_findings(registry(document), profiles), ())

    def test_global_kind_rejects_non_global_completeness_profiles(self):
        profiles = load_profiles(PROFILE_PATH)
        for profile in ("object-v1", "journey-v1", "standard-v1"):
            with self.subTest(profile=profile):
                sections = "\n".join(
                    f"<!-- canon-section: {section} -->\nDefined {section}."
                    for section in EXPECTED_PROFILES[profile]
                )
                document = document_from_text(
                    "+++\n"
                    f'spec_id = "GLOBAL-REJECT-{profile.upper()}"\n'
                    f'title = "Global reject {profile}"\n'
                    'kind = "global"\n'
                    'status = "normative"\n'
                    'owner_domain = "global"\n'
                    "canon_revision = 1\n"
                    f'profile = "{profile}"\n'
                    f'owns_concepts = ["global.reject-{profile}"]\n'
                    "inherits = []\n"
                    "depends_on = []\n"
                    "source_owners = []\n"
                    "+++\n\n"
                    f"{sections}\n"
                )

                findings = coverage_findings(registry(document), profiles)
                self.assertEqual(len(findings), 1)
                self.assertEqual(findings[0].code, "CANON_PROFILE_KIND_MISMATCH")
                self.assertIn(
                    "expected=surface-v1,system-v1",
                    findings[0].message,
                )


class CoverageTests(unittest.TestCase):
    def setUp(self):
        self.profiles = load_profiles(PROFILE_PATH)

    def test_missing_failure_rollback_is_a_p0_internal_specification_gap(self):
        value = registry(fixture_document("incomplete-surface.md"))

        findings = coverage_findings(value, self.profiles)

        self.assertEqual(len(findings), 1)
        self.assertEqual(findings[0].code, "CANON_PROFILE_SECTION_MISSING")
        self.assertIs(findings[0].severity, GapSeverity.P0_BLOCKER)
        self.assertIn("gap_class=internal_specification", findings[0].message)
        self.assertIn("affected_ids=SURFACE-INCOMPLETE", findings[0].message)
        self.assertIn("section=failure-rollback", findings[0].message)

    def test_nonempty_explicit_marker_satisfies_a_cell(self):
        value = registry(
            minimal_document(
                profile="one-cell",
                marker="purpose",
                content="Explicit purpose evidence.\n",
            )
        )

        findings = coverage_findings(value, {"one-cell": ("purpose",)})

        self.assertEqual(findings, ())

    def test_marker_followed_only_by_whitespace_does_not_satisfy_a_cell(self):
        value = registry(
            minimal_document(
                profile="one-cell",
                marker="purpose",
                content="  \n\t\n",
            )
        )

        findings = coverage_findings(value, {"one-cell": ("purpose",)})

        self.assertEqual(
            tuple(item.code for item in findings),
            ("CANON_PROFILE_SECTION_MISSING",),
        )

    def test_marker_followed_only_by_heading_and_placeholder_fails(self):
        for placeholder in (
            "TBD",
            "- TBD",
            "> TODO",
            "TODO: fill this",
            "implement later",
            "will implement later",
            "---",
            "-",
            ">",
            "<br>",
            "T.B.D.",
            "T.B.D.: fill this",
            "to be determined",
            "N/A",
            "N/A: fill this",
            "Status: TBD",
            "Evidence will be TODO",
            "We will implement later",
            "to be determined later",
            "Reason: N/A",
            "Owner N/A",
            "not applicable yet",
            "placeholder",
            "&nbsp;",
            "&#160;",
            "The status is TBD",
            "Status remains TBD",
            "TBD status",
            "TODO: add details",
            "We plan to implement later",
            "This will be implemented later",
            "pending specification",
            "This work is pending specification",
            "placeholder text",
            "The status is T&#66;D",
            "The\u00a0status\u00a0is\u00a0TBD",
            "ＴＢＤ",
            "implementation pending",
            "Pending implementation",
            "Implementation is pending",
            "details forthcoming",
            "Forthcoming details",
            "Details are forthcoming",
            "coming soon",
            "Coming shortly",
            "not yet specified",
            "Not specified yet",
            "Yet to be specified",
            "unspecified",
            "Details deferred",
            "Awaiting specification",
            "future work",
            "Details will be provided later",
            "Details to follow",
            "WIP",
            "W.I.P.",
            "work in progress",
            "Work remains in progress",
            "to be added",
            "will be added",
            "to be supplied",
            "will be supplied",
            "to be provided",
            "will be provided",
            "to be documented",
            "will be documented",
            "to be defined",
            "will be defined",
            "not specified",
            "missing specification",
            "Specification missing",
            "Missing details",
            "T\u200bBD",
            "T&ZeroWidthSpace;BD",
            "T\u00adBD",
            "T\u2060BD",
            "T\ufeffBD",
            "T\ufe0fBD",
            "T\u034fBD",
            "TBC",
            "T.B.C.",
            "in progress",
            "under development",
            "under construction",
            "will be written",
            "will follow",
            "documentation follows",
            "not implemented",
            "not documented",
            "not defined",
            "not described",
            "details next revision",
            "Details in a subsequent revision",
            "Documentation in a later release",
            "Specification in the next version",
            "awaiting documentation",
            "T\u0301BD",
            "ТBD",
            "TΒD",
            "TBС",
            "T&NotARealEntity;BD",
            "TBD may be added later",
            "TBD must be supplied",
            "later",
            "soon",
            "to follow",
            "draft",
            "stub",
            "work ongoing",
            "incomplete",
            "needs specification",
            "forthcoming",
            "upcoming",
            "eventually",
            "unfinished",
            "partial",
            "needs documentation",
            "needs definition",
            "needs details",
            "awaiting review",
            "pending decision",
            "pending approval",
            "review forthcoming",
            "decision eventually",
            "undecided by owner",
            "TBD should be added later",
            "TBD shall be supplied",
        ):
            with self.subTest(placeholder=placeholder):
                value = registry(
                    minimal_document(
                        profile="one-cell",
                        marker="purpose",
                        content=f"## Purpose\n{placeholder}\n",
                    )
                )

                findings = coverage_findings(value, {"one-cell": ("purpose",)})

                self.assertEqual(
                    tuple(item.code for item in findings),
                    ("CANON_PROFILE_SECTION_MISSING",),
                )

    def test_substantive_laws_that_discuss_placeholders_are_evidence(self):
        laws = (
            "TBD labels are forbidden in normative specifications.",
            "TODO must never appear as accepted section evidence.",
            "N/A is permitted only through an owned rationale.",
            "Current status is not TBD.",
            "The value is not TODO.",
            "Not applicable requires an owned rationale.",
            "TBD is not allowed.",
            "N/A requires an owned rationale.",
            "TBD cannot be used.",
            "TBD must not be used.",
            "TBD may not be used.",
            "TBD is invalid.",
            "Not applicable must include a rationale.",
            "ТBD is forbidden in source evidence.",
            "The localized label Ελληνικά remains documented.",
            "Literal &NotARealEntity; syntax is rejected by the parser.",
            "TBD shall not be used.",
            "TBD should never appear.",
            "The status MUST NOT remain TBD.",
        )
        for law in laws:
            with self.subTest(law=law):
                value = registry(
                    minimal_document(
                        profile="one-cell",
                        marker="purpose",
                        content=f"{law}\n",
                    )
                )

                findings = coverage_findings(value, {"one-cell": ("purpose",)})

                self.assertEqual(findings, ())

    def test_marker_inside_fenced_code_example_is_not_body_evidence(self):
        document = document_from_text(
            "+++\n"
            'spec_id = "STANDARD-TEST"\n'
            'title = "Test"\n'
            'kind = "standard"\n'
            'status = "normative"\n'
            'owner_domain = "product"\n'
            "canon_revision = 1\n"
            'profile = "one-cell"\n'
            'owns_concepts = ["standard.test"]\n'
            "inherits = []\n"
            "depends_on = []\n"
            "source_owners = []\n"
            "+++\n\n"
            "```markdown\n"
            "<!-- canon-section: purpose -->\n"
            "Example text that is not normative section evidence.\n"
            "```\n"
        )

        findings = coverage_findings(
            registry(document),
            {"one-cell": ("purpose",)},
        )

        self.assertEqual(findings[0].code, "CANON_PROFILE_SECTION_MISSING")

    def test_marker_cannot_be_smuggled_through_unknown_front_matter(self):
        with self.assertRaises(CanonError) as raised:
            document_from_text(
                "+++\n"
                'spec_id = "STANDARD-TEST"\n'
                'title = "Test"\n'
                'kind = "standard"\n'
                'status = "normative"\n'
                'owner_domain = "product"\n'
                "canon_revision = 1\n"
                'profile = "one-cell"\n'
                'owns_concepts = ["standard.test"]\n'
                "inherits = []\n"
                "depends_on = []\n"
                "source_owners = []\n"
                "example = '''\n"
                "<!-- canon-section: purpose -->\n"
                "Front-matter example text is not normative body evidence.\n"
                "'''\n"
                "+++\n"
            )

        self.assertEqual(raised.exception.code, "CANON_PARSE_FRONT_MATTER")
        self.assertEqual(raised.exception.message, "unknown field: example")

    def test_comment_only_content_after_real_marker_is_not_body_evidence(self):
        value = registry(
            minimal_document(
                profile="one-cell",
                marker="purpose",
                content="<!--\nComment text is not normative body evidence.\n-->\n",
            )
        )

        findings = coverage_findings(value, {"one-cell": ("purpose",)})

        self.assertEqual(findings[0].code, "CANON_PROFILE_SECTION_MISSING")

    def test_marker_inside_multiline_html_comment_is_not_body_evidence(self):
        document = document_from_text(
            "+++\n"
            'spec_id = "STANDARD-TEST"\n'
            'title = "Test"\n'
            'kind = "standard"\n'
            'status = "normative"\n'
            'owner_domain = "product"\n'
            "canon_revision = 1\n"
            'profile = "one-cell"\n'
            'owns_concepts = ["standard.test"]\n'
            "inherits = []\n"
            "depends_on = []\n"
            "source_owners = []\n"
            "+++\n\n"
            "<!--\n"
            "<!-- canon-section: purpose -->\n"
            "Comment example text is not normative body evidence.\n"
            "-->\n"
        )

        findings = coverage_findings(
            registry(document),
            {"one-cell": ("purpose",)},
        )

        self.assertEqual(findings[0].code, "CANON_PROFILE_SECTION_MISSING")

    def test_real_marker_with_only_fenced_content_is_not_body_evidence(self):
        value = registry(
            minimal_document(
                profile="one-cell",
                marker="purpose",
                content=(
                    "```markdown\n"
                    "Example text is illustrative, not normative body evidence.\n"
                    "```\n"
                ),
            )
        )

        findings = coverage_findings(value, {"one-cell": ("purpose",)})

        self.assertEqual(findings[0].code, "CANON_PROFILE_SECTION_MISSING")

    def test_heading_wording_without_marker_does_not_satisfy_a_cell(self):
        document = minimal_document(
            profile="one-cell",
            marker="unrelated",
            content="## Purpose\nA purpose heading is not a marker.\n",
        )

        findings = coverage_findings(
            registry(document),
            {"one-cell": ("purpose",)},
        )

        self.assertEqual(findings[0].code, "CANON_PROFILE_SECTION_MISSING")

    def test_not_applicable_with_rationale_and_owner_satisfies_cell(self):
        value = registry(fixture_document("not-applicable-with-rationale.md"))

        findings = coverage_findings(value, self.profiles)

        self.assertEqual(findings, ())

    def test_not_applicable_without_owner_fails_at_parser_boundary(self):
        path = FIXTURES / "not-applicable-without-owner.md"

        with self.assertRaises(CanonError) as raised:
            parse_canon_document(path, path.read_text(encoding="utf-8"))

        self.assertEqual(raised.exception.code, "CANON_PARSE_FRONT_MATTER")
        self.assertIn("exactly rationale and owner", raised.exception.message)

    def test_not_applicable_placeholder_rationale_fails(self):
        valid = fixture_document("not-applicable-with-rationale.md")
        assert valid.source_bytes is not None
        original = valid.source_bytes.decode("utf-8")
        replacements = (
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "implement later"',
            ),
            ('owner = "Devan Warner"', 'owner = "TODO"'),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "N/A"',
            ),
            ('owner = "Devan Warner"', 'owner = "N/A"'),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Reason: N/A"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "We will implement later"',
            ),
            ('owner = "Devan Warner"', 'owner = "Owner N/A"'),
            ('owner = "Devan Warner"', 'owner = "Name TBD"'),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Reason remains N/A"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "The rationale is TBD"',
            ),
            ('owner = "Devan Warner"', 'owner = "Current owner N/A"'),
            ('owner = "Devan Warner"', 'owner = "Unassigned"'),
            ('owner = "Devan Warner"', 'owner = "No owner"'),
            ('owner = "Devan Warner"', 'owner = "No current owner"'),
            ('owner = "Devan Warner"', 'owner = "No accountable owner"'),
            ('owner = "Devan Warner"', 'owner = "Owner to be assigned"'),
            ('owner = "Devan Warner"', 'owner = "To be assigned"'),
            ('owner = "Devan Warner"', 'owner = "Owner not assigned"'),
            ('owner = "Devan Warner"', 'owner = "Pending assignment"'),
            ('owner = "Devan Warner"', 'owner = "Owner assignment pending"'),
            ('owner = "Devan Warner"', 'owner = "Unknown owner"'),
            ('owner = "Devan Warner"', 'owner = "Owner unknown"'),
            ('owner = "Devan Warner"', 'owner = "No&nbsp;owner"'),
            ('owner = "Devan Warner"', 'owner = "Ｎ／Ａ"'),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Because"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Reason"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "No reason"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Not applicable because not applicable"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Since"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Due to"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "No rationale"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Does not apply because it does not apply"',
            ),
            ('owner = "Devan Warner"', 'owner = "Owner pending"'),
            ('owner = "Devan Warner"', 'owner = "Pending"'),
            ('owner = "Devan Warner"', 'owner = "Vacant"'),
            ('owner = "Devan Warner"', 'owner = "Nobody"'),
            ('owner = "Devan Warner"', 'owner = "No accountable party"'),
            ('owner = "Devan Warner"', 'owner = "Owner undecided"'),
            ('owner = "Devan Warner"', 'owner = "To assign"'),
            ('owner = "Devan Warner"', 'owner = "Unowned"'),
            ('owner = "Devan Warner"', 'owner = "Pending owner"'),
            ('owner = "Devan Warner"', 'owner = "Assignment undecided"'),
            ('owner = "Devan Warner"', 'owner = "Accountable party pending"'),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Work in progress"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Will be added"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Missing specification"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "To be provided"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Will be documented"',
            ),
            ('owner = "Devan Warner"', 'owner = "To be named"'),
            ('owner = "Devan Warner"', 'owner = "Name forthcoming"'),
            ('owner = "Devan Warner"', 'owner = "Assignee pending"'),
            ('owner = "Devan Warner"', 'owner = "No one"'),
            ('owner = "Devan Warner"', 'owner = "Ownerless"'),
            ('owner = "Devan Warner"', 'owner = "Vacancy"'),
            ('owner = "Devan Warner"', 'owner = "TBA"'),
            ('owner = "Devan Warner"', 'owner = "T.B.A."'),
            ('owner = "Devan Warner"', 'owner = "To be confirmed"'),
            ('owner = "Devan Warner"', 'owner = "Not determined"'),
            ('owner = "Devan Warner"', 'owner = "T\u200bBD"'),
            ('owner = "Devan Warner"', 'owner = "T\u00adBD"'),
            ('owner = "Devan Warner"', 'owner = "T\u2060BD"'),
            ('owner = "Devan Warner"', 'owner = "T\ufeffBD"'),
            ('owner = "Devan Warner"', 'owner = "Unnamed"'),
            ('owner = "Devan Warner"', 'owner = "Assignee unknown"'),
            ('owner = "Devan Warner"', 'owner = "Owner to be supplied"'),
            ('owner = "Devan Warner"', 'owner = "Assignee to be named"'),
            ('owner = "Devan Warner"', 'owner = "Naming pending"'),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Will be written"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Details next revision"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Future revision"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Because reasons exist"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Because a reason exists"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Reasons exist"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "See subsequent revision"',
            ),
            ('owner = "Devan Warner"', 'owner = "TBC"'),
            ('owner = "Devan Warner"', 'owner = "No responsible person"'),
            ('owner = "Devan Warner"', 'owner = "No maintainer"'),
            ('owner = "Devan Warner"', 'owner = "Not owned"'),
            ('owner = "Devan Warner"', 'owner = "Ownership pending"'),
            ('owner = "Devan Warner"', 'owner = "Maintainer to follow"'),
            ('owner = "Devan Warner"', 'owner = "No steward"'),
            ('owner = "Devan Warner"', 'owner = "No assignee"'),
            ('owner = "Devan Warner"', 'owner = "No accountable team"'),
            ('owner = "Devan Warner"', 'owner = "Custodian pending"'),
            ('owner = "Devan Warner"', 'owner = "Responsible role pending"'),
            ('owner = "Devan Warner"', 'owner = "Maintainer forthcoming"'),
            ('owner = "Devan Warner"', 'owner = "Steward to be named"'),
            ('owner = "Devan Warner"', 'owner = "Unmaintained"'),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Reason unavailable now"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Owner will decide"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Awaiting review outcome"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Not applicable because it is inapplicable"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Approval forthcoming"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Owner undecided"',
            ),
            ('owner = "Devan Warner"', 'owner = "Owner will decide"'),
            ('owner = "Devan Warner"', 'owner = "Unassigned until launch"'),
            ('owner = "Devan Warner"', 'owner = "Vacant pending hire"'),
            ('owner = "Devan Warner"', 'owner = "Not Devan Warner"'),
            ('owner = "Devan Warner"', 'owner = "Someone"'),
            ('owner = "Devan Warner"', 'owner = "Somebody"'),
            ('owner = "Devan Warner"', 'owner = "Anyone"'),
            ('owner = "Devan Warner"', 'owner = "To be decided by owner"'),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Cannot determine applicability"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Owner decision required"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Explanation forthcoming"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Applicability undetermined"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Decision needed"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Rationale to follow"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Awaiting owner determination"',
            ),
            ('owner = "Devan Warner"', 'owner = "Whoever owns this"'),
            ('owner = "Devan Warner"', 'owner = "Default owner"'),
            ('owner = "Devan Warner"', 'owner = "Will assign Alex"'),
            ('owner = "Devan Warner"', 'owner = "Someone responsible"'),
            ('owner = "Devan Warner"', 'owner = "Any maintainer"'),
            ('owner = "Devan Warner"', 'owner = "Owner TBD despite name"'),
            ('owner = "Devan Warner"', 'owner = "Alex will be assigned"'),
            ('owner = "Devan Warner"', 'owner = "Fallback maintainer"'),
            ('owner = "Devan Warner"', 'owner = "Default team"'),
            ('owner = "Devan Warner"', 'owner = "Whoever is accountable"'),
            ('owner = "Devan Warner"', 'owner = "Alice to be assigned"'),
            ('owner = "Devan Warner"', 'owner = "Will name Product Team"'),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Owner approval required"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Review required"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Applicability unclear"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Applicability uncertain"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Not sure whether applicable"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Unsure whether this applies"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Applicability ambiguous"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Applicability unknown"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Applicability cannot be established"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Approval needed"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Review needed"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Decision required"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Approval will happen later"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Review will resolve applicability"',
            ),
            ('owner = "Devan Warner"', 'owner = "Assigned later"'),
            ('owner = "Devan Warner"', 'owner = "Alex assigned later"'),
            ('owner = "Devan Warner"', 'owner = "Proposed owner Alex"'),
            ('owner = "Devan Warner"', 'owner = "Owner candidate Alex"'),
            ('owner = "Devan Warner"', 'owner = "Alex if approved"'),
            ('owner = "Devan Warner"', 'owner = "Owner nominee Alex"'),
            ('owner = "Devan Warner"', 'owner = "Prospective owner Alex"'),
            ('owner = "Devan Warner"', 'owner = "Suggested owner Alex"'),
            ('owner = "Devan Warner"', 'owner = "Tentative owner Alex"'),
            ('owner = "Devan Warner"', 'owner = "Conditional owner Alex"'),
            ('owner = "Devan Warner"', 'owner = "Alex subject to approval"'),
            ('owner = "Devan Warner"', 'owner = "Alex awaiting approval"'),
            ('owner = "Devan Warner"', 'owner = "Alex after review"'),
            ('owner = "Devan Warner"', 'owner = "Alex eventually"'),
            ('owner = "Devan Warner"', 'owner = "Alex will become owner"'),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Applicability unresolved"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Applicability indeterminate"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Decision has not been made"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Approval to be obtained"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Review is outstanding"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Approval remains unresolved"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Signoff pending"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Conclusion has not been reached"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Determination remains outstanding"',
            ),
            (
                'rationale = "This standard admits no exceptions."',
                'rationale = "Confirmation needed"',
            ),
            ('owner = "Devan Warner"', 'owner = "Alex pending confirmation"'),
            ('owner = "Devan Warner"', 'owner = "Alex awaiting confirmation"'),
            ('owner = "Devan Warner"', 'owner = "Alex will be owner"'),
            ('owner = "Devan Warner"', 'owner = "Alex will own this"'),
            ('owner = "Devan Warner"', 'owner = "Alex expected to own this"'),
            ('owner = "Devan Warner"', 'owner = "Owner upon approval Alex"'),
            ('owner = "Devan Warner"', 'owner = "Alex once approved"'),
            ('owner = "Devan Warner"', 'owner = "Alex pending signoff"'),
            ('owner = "Devan Warner"', 'owner = "Alex after confirmation"'),
            ('owner = "Devan Warner"', 'owner = "Alex subject to signoff"'),
            ('owner = "Devan Warner"', 'owner = "Alex once confirmed"'),
        )
        for old, new in replacements:
            with self.subTest(field=old.split(" =", 1)[0]):
                source = original.replace(old, new)
                document = replace(valid, source_bytes=source.encode("utf-8"))

                findings = coverage_findings(registry(document), self.profiles)

                self.assertEqual(
                    tuple(item.code for item in findings),
                    ("CANON_PROFILE_NOT_APPLICABLE_INVALID",),
                )

    def test_substantive_not_applicable_rationale_is_allowed(self):
        valid = fixture_document("not-applicable-with-rationale.md")
        assert valid.source_bytes is not None
        source = valid.source_bytes.decode("utf-8").replace(
            'rationale = "This standard admits no exceptions."',
            (
                'rationale = "Not applicable because this provenance-only '
                'standard performs no runtime work."'
            ),
        )
        document = replace(valid, source_bytes=source.encode("utf-8"))

        findings = coverage_findings(registry(document), self.profiles)

        self.assertEqual(findings, ())

    def test_current_person_role_and_team_owners_are_allowed(self):
        valid = fixture_document("not-applicable-with-rationale.md")
        assert valid.source_bytes is not None
        original = valid.source_bytes.decode("utf-8")
        for owner in (
            "Alex Morgan",
            "Current owner Alex Morgan",
            "Will Smith",
            "Will Turner",
            "Product Team",
            "Approval Governance Team",
            "Confirmation Review Board",
            "Review Operations Team",
            "Privacy Steward",
            "Approval Steward",
            "Runtime Maintainer",
        ):
            with self.subTest(owner=owner):
                source = original.replace(
                    'owner = "Devan Warner"', f'owner = "{owner}"'
                )
                document = replace(valid, source_bytes=source.encode("utf-8"))

                findings = coverage_findings(registry(document), self.profiles)

                self.assertEqual(findings, ())

    def test_substantive_rationale_may_explain_approval_or_review_boundaries(self):
        valid = fixture_document("not-applicable-with-rationale.md")
        assert valid.source_bytes is not None
        original = valid.source_bytes.decode("utf-8")
        rationales = (
            "This standard does not apply because approval belongs to entitlement governance.",
            "This standard does not apply because review is performed by the proof system.",
        )
        for rationale in rationales:
            with self.subTest(rationale=rationale):
                source = original.replace(
                    'rationale = "This standard admits no exceptions."',
                    f'rationale = "{rationale}"',
                )
                document = replace(valid, source_bytes=source.encode("utf-8"))

                findings = coverage_findings(registry(document), self.profiles)

                self.assertEqual(findings, ())

    def test_not_applicable_rejects_fields_outside_exact_shape(self):
        valid = fixture_document("not-applicable-with-rationale.md")
        assert valid.source_bytes is not None
        source = valid.source_bytes.decode("utf-8").replace(
            'owner = "Devan Warner"',
            'owner = "Devan Warner"\nreviewer = "Someone else"',
        )
        document = replace(valid, source_bytes=source.encode("utf-8"))

        findings = coverage_findings(registry(document), self.profiles)

        self.assertEqual(
            tuple(item.code for item in findings),
            ("CANON_PROFILE_NOT_APPLICABLE_INVALID",),
        )

    def test_model_not_applicable_cannot_override_missing_raw_authority(self):
        parsed = minimal_document(
            profile="one-cell",
            marker="unrelated",
            content="Unrelated body evidence.\n",
        )
        normalized = replace(
            parsed,
            not_applicable=(
                NotApplicable(
                    section="purpose",
                    rationale="A model-only rationale.",
                    owner="Devan Warner",
                ),
            ),
        )

        findings = coverage_findings(
            registry(normalized),
            {"one-cell": ("purpose",)},
        )

        self.assertEqual(
            tuple(item.code for item in findings),
            ("CANON_PROFILE_SECTION_MISSING",),
        )

    def test_source_less_model_not_applicable_fails_closed(self):
        parsed = minimal_document(
            profile="one-cell",
            marker="unrelated",
            content="Unrelated body evidence.\n",
        )
        source_less = replace(
            parsed,
            source_bytes=None,
            not_applicable=(
                NotApplicable(
                    section="purpose",
                    rationale="A model-only rationale.",
                    owner="Devan Warner",
                ),
            ),
        )

        findings = coverage_findings(
            registry(source_less),
            {"one-cell": ("purpose",)},
        )

        self.assertEqual(
            tuple(item.code for item in findings),
            ("CANON_PROFILE_SECTION_MISSING",),
        )

    def test_unparseable_source_cannot_authorize_model_not_applicable(self):
        parsed = minimal_document(
            profile="one-cell",
            marker="unrelated",
            content="Unrelated body evidence.\n",
        )
        unparseable = replace(
            parsed,
            source_bytes=b"\xff",
            not_applicable=(
                NotApplicable(
                    section="purpose",
                    rationale="A model-only rationale.",
                    owner="Devan Warner",
                ),
            ),
        )

        findings = coverage_findings(
            registry(unparseable),
            {"one-cell": ("purpose",)},
        )

        self.assertEqual(
            tuple(item.code for item in findings),
            ("CANON_PROFILE_SECTION_MISSING",),
        )

    def test_unknown_profile_fails_closed(self):
        value = registry(
            minimal_document(
                profile="unknown-v9",
                marker="purpose",
                content="Evidence.\n",
            )
        )

        findings = coverage_findings(value, self.profiles)

        self.assertEqual(tuple(item.code for item in findings), ("CANON_PROFILE_UNKNOWN",))
        self.assertIs(findings[0].severity, GapSeverity.P0_BLOCKER)

    def test_document_kind_cannot_select_a_weaker_mismatched_profile(self):
        surface = replace(
            fixture_document("not-applicable-with-rationale.md"),
            spec_id="SURFACE-WEAK",
            kind=DocumentKind.SURFACE,
        )

        findings = coverage_findings(registry(surface), self.profiles)

        self.assertEqual(
            tuple(item.code for item in findings),
            ("CANON_PROFILE_KIND_MISMATCH",),
        )

    def test_supported_kind_without_profile_cannot_bypass_coverage(self):
        document = replace(
            minimal_document(
                profile="standard-v1",
                marker="purpose",
                content="Evidence.\n",
            ),
            profile=None,
        )

        findings = coverage_findings(registry(document), self.profiles)

        self.assertEqual(tuple(item.code for item in findings), ("CANON_PROFILE_REQUIRED",))

    def test_findings_are_sorted_independent_of_document_order(self):
        first = replace(
            fixture_document("incomplete-surface.md"),
            spec_id="SURFACE-Z",
            source_path=Path("z.md"),
        )
        second = replace(
            fixture_document("incomplete-surface.md"),
            spec_id="SURFACE-A",
            source_path=Path("a.md"),
        )

        forward = coverage_findings(registry(first, second), self.profiles)
        reverse = coverage_findings(registry(second, first), self.profiles)

        self.assertEqual(forward, reverse)
        self.assertEqual(tuple(item.path for item in forward), (Path("a.md"), Path("z.md")))


class GapDescriptorTests(unittest.TestCase):
    def test_five_gap_classes_serialize_with_stable_severity_and_affected_ids(self):
        expected = {
            GapClass.CANON_TO_CODE: GapSeverity.P0_BLOCKER,
            GapClass.CODE_TO_CANON: GapSeverity.P0_BLOCKER,
            GapClass.FIGMA_TO_CANON: GapSeverity.P1_REQUIRED,
            GapClass.LINEAR_TO_CANON: GapSeverity.P1_REQUIRED,
            GapClass.INTERNAL_SPECIFICATION: GapSeverity.P0_BLOCKER,
        }

        self.assertEqual(GAP_SEVERITY, expected)
        for gap_class, severity in expected.items():
            descriptor = GapDescriptor(
                gap_class=gap_class,
                affected_ids=("TODAY-002", "SURFACE-TODAY", "TODAY-002"),
            )
            self.assertIs(descriptor.severity, severity)
            self.assertEqual(
                descriptor.serialize(),
                f"gap_class={gap_class.value} "
                "affected_ids=SURFACE-TODAY,TODAY-002",
            )


class CoverageCliTests(unittest.TestCase):
    def test_live_shadow_coverage_is_green(self):
        output = StringIO()

        with redirect_stdout(output):
            result = main(["coverage", "--fail-on-p0-gap"])

        self.assertEqual(result, 0)
        self.assertEqual(
            output.getvalue(),
            "GREEN ambitions canon coverage documents=61 profiles=5 "
            "authority_state=shadow\n",
        )

    def test_fail_on_p0_gap_controls_exit_without_hiding_findings(self):
        fixture = (FIXTURES / "incomplete-surface.md").read_text(encoding="utf-8")
        profiles = PROFILE_PATH.read_text(encoding="utf-8")
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            canon = root / "docs/canon"
            (canon / "schemas").mkdir(parents=True)
            (canon / "specifications").mkdir()
            (canon / "schemas/completeness-profiles.toml").write_text(
                profiles,
                encoding="utf-8",
            )
            (canon / "specifications/incomplete.md").write_text(
                fixture,
                encoding="utf-8",
            )
            (canon / "MANIFEST.toml").write_text(
                "schema_version = 1\n"
                "canon_revision = 1\n"
                'authority_state = "shadow"\n'
                'compiler_version = "0.1.0"\n'
                'normative_files = ["specifications/incomplete.md"]\n'
                "generated_files = []\n",
                encoding="utf-8",
            )
            write_required_governance_artifacts(
                canon,
                canon_revision=1,
                requirement_ids=tuple(
                    requirement.requirement_id
                    for requirement in fixture_document(
                        "incomplete-surface.md"
                    ).requirements
                ),
            )
            previous = Path.cwd()
            try:
                os.chdir(root)
                without_gate = StringIO()
                with redirect_stdout(without_gate):
                    advisory_result = main(["coverage"])
                with_gate = StringIO()
                with redirect_stdout(with_gate):
                    gated_result = main(["coverage", "--fail-on-p0-gap"])
            finally:
                os.chdir(previous)

        self.assertEqual(advisory_result, 0)
        self.assertEqual(gated_result, 1)
        self.assertEqual(without_gate.getvalue(), with_gate.getvalue())
        self.assertTrue(
            with_gate.getvalue().startswith(
                "P0_BLOCKER CANON_PROFILE_SECTION_MISSING "
                "docs/canon/specifications/incomplete.md:0 "
                "gap_class=internal_specification "
                "affected_ids=SURFACE-INCOMPLETE "
            ),
            with_gate.getvalue(),
        )


if __name__ == "__main__":
    unittest.main()
