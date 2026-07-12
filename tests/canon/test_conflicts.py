from __future__ import annotations

import hashlib
import json
import tempfile
import unittest
from contextlib import redirect_stdout
from dataclasses import replace
from io import StringIO
from pathlib import Path
from types import SimpleNamespace
from unittest import mock

import tools.ambitions_canon.build as canon_build

from tests.canon.canon_test_support import write_required_governance_artifacts

from tools.ambitions_canon.conflicts import (
    _validate_removed_baseline_record,
    ConflictClaim,
    ConflictDocket,
    ConflictRecommendation,
    ConflictResolution,
    conflict_candidates,
    load_conflict_dockets,
    render_conflict_docket,
    render_unresolved_report,
    report_conflicts,
    render_conflict_baseline,
    validate_conflict_coverage,
    validate_docket_removals,
    validate_conflict_repository,
)
from tools.ambitions_canon.supersession import integration_evidence_digest
from tools.ambitions_canon.model import (
    AtomicClaim,
    CanonError,
    ClaimDisposition,
    ClaimTargetClass,
    Modality,
    SupersessionEntry,
)
from tools.ambitions_canon.cli import main


def supersession_entry(
    *,
    conflict_id: str,
    old_ids: tuple[str, ...],
    resulting_id: str | None,
    decision_date: str,
    owner: str,
    decision_source: str,
    decision_base_commit: str,
    superseded_artifacts: tuple[str, ...],
    resolution: str = "compose",
) -> SupersessionEntry:
    digest = integration_evidence_digest(
        conflict_id=conflict_id,
        old_ids=old_ids,
        resulting_id=resulting_id,
        decision_date=decision_date,
        owner=owner,
        decision_source=decision_source,
        resolution=resolution,
        decision_base_commit=decision_base_commit,
        superseded_artifacts=superseded_artifacts,
    )
    return SupersessionEntry(
        conflict_id=conflict_id,
        old_ids=old_ids,
        resulting_id=resulting_id,
        decision_date=decision_date,
        owner=owner,
        decision_source=decision_source,
        resolution=resolution,
        decision_base_commit=decision_base_commit,
        integration_evidence_sha256=digest,
        superseded_artifacts=superseded_artifacts,
    )


def claim(
    claim_id: str,
    *,
    concept: str = "surface.today.primary_identity",
    value: str = "Reality Window",
    modality: Modality = Modality.MUST,
    scope: str = "Today root at rest",
    source_id: str = "SOURCE-A",
    source_location: str = "line:1",
    owner_approval: str | None = None,
    conditions: tuple[str, ...] = (),
) -> AtomicClaim:
    return AtomicClaim(
        claim_id=claim_id,
        source_id=source_id,
        source_location=source_location,
        concept=concept,
        subject="Today",
        predicate="presents",
        value=value,
        modality=modality,
        scope=scope,
        conditions=conditions,
        exceptions=(),
        authority_claim=True,
        owner_approval=owner_approval,
        disposition=ClaimDisposition.CONFLICT,
        target_id=None,
        original_text=value,
        target_class=ClaimTargetClass.DECISION_DOCKET,
        rationale="Material conceptual conflict requires owner review.",
    )


def evidence(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def docket(**changes: object) -> ConflictDocket:
    claims = (
        ConflictClaim.from_atomic(claim("CLAIM-A", value="Reality Window")),
        ConflictClaim.from_atomic(
            claim(
                "CLAIM-B",
                value="rolling execution rail",
                source_id="SOURCE-B",
                source_location="line:2",
            )
        ),
    )
    values: dict[str, object] = {
        "conflict_id": "CONFLICT-TODAY-PRIMARY-IDENTITY",
        "status": "unresolved",
        "severity": "P0_BLOCKER",
        "priority": "P0",
        "concepts": ("surface.today.primary_identity",),
        "scopes": ("Today root at rest",),
        "claims": claims,
        "user_consequences": "The user needs one stable mental model for Today.",
        "compatibility_analysis": "The rail can support, but cannot replace, the primary identity.",
        "recommendation": ConflictRecommendation.COMPOSE,
        "recommendation_rationale": "Preserve object-led identity and scope the rail as temporal anatomy.",
        "stronger_composition": "One identity with an explicitly subordinate rail.",
        "proposed_canonical_law": "Today MUST remain the Reality Window; its rail MUST NOT become the primary identity.",
        "impacts": (
            ("repo", "Replace competing active wording after approval."),
            ("linear", "Rewrite affected decision references after approval."),
            ("figma", "Relabel affected visual authority after approval."),
            ("production_source", "No Task 12 source behavior change."),
            ("tests", "Add identity and rail-scope acceptance tests later."),
            ("proof", "Require current visual and interaction proof later."),
            ("privacy", "No private-data boundary change."),
            ("accessibility", "Preserve a single accessible root identity."),
            ("migration_rollback", "Task 13 integrates only after owner approval; revert by Git SHA."),
        ),
        "artifacts_to_supersede": ("SOURCE-B:line:2",),
        "target_requirement_status": "planned_uncreated",
        "target_requirement_id": None,
        "owner_decision": None,
        "allowed_resolutions": tuple(item.value for item in ConflictResolution),
        "affected_task_scopes": ("surface.today",),
        "nonclaims": "No product, runtime, visual, accessibility, privacy, device, or release claim.",
        "claim_ceiling": "Shadow conflict evidence only; no implementation authorization.",
    }
    values.update(changes)
    return ConflictDocket(**values)


def catalog_bytes(value: ConflictDocket) -> bytes:
    source_ids = sorted({item.source_id for item in value.claims})
    sources = [
        {
            "authority_claim": "Synthetic accepted source for conflict contract tests.",
            "kind": "figma",
            "locator": f"figma:{source_id}:1:1",
            "owner": "Canon Tests",
            "raw_byte_length": 1,
            "raw_path": f".codex/canon-migration/sources/{source_id.lower()}.json",
            "raw_sha256": hashlib.sha256(source_id.encode()).hexdigest(),
            "source_id": source_id,
            "title": source_id,
            "updated_at": "2026-07-11",
        }
        for source_id in source_ids
    ]
    return (json.dumps({"schema_version": 1, "sources": sources}, sort_keys=True) + "\n").encode()


def disposition_bytes(value: ConflictDocket) -> bytes:
    catalog = catalog_bytes(value)
    claims = []
    for item in value.claims:
        claims.append(
            {
                "authority_claim": True,
                "claim_id": item.claim_id,
                "source_id": item.source_id,
                "source_location": item.source_location,
                "concept": item.concept,
                "disposition": "conflict",
                "decision_mapping_status": None,
                "owner_approval_sha256": (
                    hashlib.sha256(item.owner_approval.encode("utf-8")).hexdigest()
                    if item.owner_approval is not None
                    else None
                ),
                "owner_evidence_text_sha256": None,
                "owner_evidence_rationale_sha256": None,
                "rationale_sha256": hashlib.sha256(item.claim_id.encode()).hexdigest(),
                "target_class": "decision_docket",
                "target_id": None,
            }
        )
    coverage = [
        {
            "claim_ids": [item.claim_id],
            "disposition": "claims",
            "rationale_sha256": None,
            "source_id": item.source_id,
            "source_location": item.source_location,
        }
        for item in value.claims
    ]
    coverage.sort(key=lambda item: (item["source_id"], item["source_location"]))
    semantic_groups = sorted(
        (
            {
                "claim_ids": [item.claim_id],
                "semantic_sha256": hashlib.sha256(item.claim_id.encode()).hexdigest(),
            }
            for item in value.claims
        ),
        key=lambda item: item["semantic_sha256"],
    )
    payload = {
        "catalog_sha256": hashlib.sha256(catalog).hexdigest(),
        "claims": sorted(claims, key=lambda item: item["claim_id"]),
        "coverage": coverage,
        "decision_evidence_sha256": None,
        "decision_mapping_counts": {
            "independently_reviewed": 0,
            "unreviewed": 0,
        },
        "linear_decision_count": 0,
        "schema_version": 1,
        "section_count": len(coverage),
        "semantic_groups": semantic_groups,
        "source_count": len({item.source_id for item in value.claims}),
        "uncovered": [],
    }
    return (json.dumps(payload, sort_keys=True) + "\n").encode()


def write_conflict_repository(root: Path, value: ConflictDocket) -> None:
    canon_root = root / "docs/canon"
    canon_root.mkdir(parents=True, exist_ok=True)
    canon_root.joinpath("MANIFEST.toml").write_text(
        "schema_version = 1\n"
        "canon_revision = 0\n"
        'authority_state = "shadow"\n'
        'compiler_version = "0.1.0"\n'
        "normative_files = []\n"
        "generated_files = []\n",
        encoding="utf-8",
    )
    write_required_governance_artifacts(canon_root, canon_revision=0)
    open_dir = root / "docs/canon/decisions/open"
    open_dir.mkdir(parents=True)
    (open_dir / f"{value.conflict_id.lower()}.md").write_text(
        render_conflict_docket(value), encoding="utf-8"
    )
    migration = root / "docs/canon/migration"
    migration.mkdir(parents=True, exist_ok=True)
    migration.joinpath("source-catalog.json").write_bytes(catalog_bytes(value))
    dispositions = disposition_bytes(value)
    migration.joinpath("claim-dispositions.json").write_bytes(dispositions)
    migration.joinpath("conflict-docket-baseline.json").write_bytes(
        render_conflict_baseline((value,), dispositions)
    )


class CandidateDetectionTests(unittest.TestCase):
    def test_semantic_equivalence_is_not_a_conflict(self):
        claims = (
            claim("CLAIM-A", value="Reality   Window"),
            claim("CLAIM-B", value="reality window", source_id="SOURCE-B"),
        )
        self.assertEqual(conflict_candidates(claims), ())

    def test_incompatible_values_in_overlapping_scope_are_a_conflict(self):
        candidates = conflict_candidates(
            (
                claim("CLAIM-A", value="Reality Window"),
                claim(
                    "CLAIM-B",
                    value="rolling execution rail",
                    source_id="SOURCE-B",
                ),
            )
        )
        self.assertEqual(len(candidates), 1)
        self.assertEqual(
            tuple(item.claim_id for item in candidates[0].claims),
            ("CLAIM-A", "CLAIM-B"),
        )

    def test_must_and_must_not_overlap_is_p0(self):
        candidates = conflict_candidates(
            (
                claim("CLAIM-A", value="private graph egress", modality=Modality.MUST),
                claim(
                    "CLAIM-B",
                    value="private graph egress",
                    modality=Modality.MUST_NOT,
                    source_id="SOURCE-B",
                ),
            )
        )
        self.assertEqual(candidates[0].severity, "P0_BLOCKER")

    def test_should_and_should_not_overlap_is_p1_conflict(self):
        candidates = conflict_candidates(
            (
                claim("CLAIM-A", value="broad stats", modality=Modality.SHOULD),
                claim(
                    "CLAIM-B",
                    value="broad stats",
                    modality=Modality.SHOULD_NOT,
                    source_id="SOURCE-B",
                ),
            )
        )
        self.assertEqual(len(candidates), 1)
        self.assertEqual(candidates[0].severity, "P1_REQUIRED")

    def test_disjoint_scopes_coexist(self):
        self.assertEqual(
            conflict_candidates(
                (
                    claim("CLAIM-A", value="local", scope="account.offline"),
                    claim(
                        "CLAIM-B",
                        value="CloudKit",
                        scope="sync.cloudkit",
                        source_id="SOURCE-B",
                    ),
                )
            ),
            (),
        )

    def test_structured_ancestor_scope_overlaps_descendant_as_p0(self):
        candidates = conflict_candidates(
            (
                claim("CLAIM-A", value="rail", scope="surface.today"),
                claim(
                    "CLAIM-B",
                    value="rail",
                    modality=Modality.MUST_NOT,
                    scope="surface.today.root",
                    source_id="SOURCE-B",
                ),
            )
        )
        self.assertEqual(len(candidates), 1)
        self.assertEqual(candidates[0].severity, "P0_BLOCKER")

    def test_unequal_free_text_scopes_overlap_unless_reciprocally_disjoint(self):
        first = claim("CLAIM-A", value="one", scope="Today at rest")
        second = claim(
            "CLAIM-B",
            value="two",
            scope="Today while editing",
            source_id="SOURCE-B",
        )
        self.assertEqual(len(conflict_candidates((first, second))), 1)
        first = replace(
            first,
            conditions=("conflict-disjoint:today while editing",),
        )
        second = replace(
            second,
            conditions=("conflict-disjoint:today at rest",),
        )
        self.assertEqual(conflict_candidates((first, second)), ())

    def test_later_owner_correction_is_presented_not_auto_selected(self):
        candidates = conflict_candidates(
            (
                claim("CLAIM-A", value="earlier"),
                claim(
                    "CLAIM-B",
                    value="later correction",
                    source_id="SOURCE-B",
                    owner_approval="linear-comment:decision:3",
                ),
            )
        )
        self.assertEqual(len(candidates), 1)
        self.assertIsNone(candidates[0].recommendation)
        self.assertEqual(
            {item.owner_approval for item in candidates[0].claims},
            {None, "linear-comment:decision:3"},
        )

    def test_candidate_detection_is_order_independent_and_deduplicated(self):
        first = claim("CLAIM-A", value="Reality Window")
        second = claim("CLAIM-B", value="rail", source_id="SOURCE-B")
        self.assertEqual(
            conflict_candidates((first, second, first)),
            conflict_candidates((second, first)),
        )

    def test_missing_claim_identity_scope_or_provenance_fails_closed(self):
        base = claim("CLAIM-A")
        invalid = (
            replace(base, claim_id=""),
            replace(base, source_id=""),
            replace(base, source_location=""),
            replace(base, concept=""),
            replace(base, scope=""),
            replace(base, original_text=""),
        )
        for item in invalid:
            with self.subTest(item=item):
                with self.assertRaises(CanonError):
                    conflict_candidates((item,))


class DocketContractTests(unittest.TestCase):
    def test_rendered_docket_has_gate_a_fields_and_all_impact_dimensions(self):
        rendered = render_conflict_docket(docket())
        for required in (
            "status = \"unresolved\"",
            "owner_decision = \"\"",
            "target_requirement_status = \"planned_uncreated\"",
            "## Competing conceptual claims",
            "## User consequences",
            "## Compatibility analysis",
            "## Recommendation",
            "## Stronger composition option",
            "## Proposed canonical law",
            "## Impact analysis",
            "## Artifacts to supersede",
            "## Explicit nonclaims and claim ceiling",
            "repo",
            "Linear",
            "Figma",
            "production source",
            "tests",
            "proof",
            "privacy",
            "accessibility",
            "migration / rollback",
        ):
            self.assertIn(required, rendered)
        self.assertTrue(rendered.endswith("\n"))

    def test_owner_field_cannot_be_spoofed_by_recommendation_text(self):
        rendered = render_conflict_docket(
            docket(
                recommendation_rationale="Owner decision: keep_a. This is recommendation text only."
            )
        )
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            open_dir = root / "docs/canon/decisions/open"
            open_dir.mkdir(parents=True)
            (open_dir / "conflict-today-primary-identity.md").write_text(
                rendered, encoding="utf-8"
            )
            loaded = load_conflict_dockets(root)
        self.assertIsNone(loaded[0].owner_decision)
        self.assertEqual(loaded[0].status, "unresolved")

    def test_invalid_resolution_or_incomplete_resolved_docket_fails_closed(self):
        with self.assertRaises(CanonError):
            render_conflict_docket(docket(status="resolved", owner_decision="accept"))
        with self.assertRaises(CanonError):
            render_conflict_docket(
                docket(
                    status="resolved",
                    owner_decision=ConflictResolution.COMPOSE.value,
                    target_requirement_id=None,
                )
            )

    def test_valid_resolved_docket_round_trips_exact_decision_and_target(self):
        resolved = docket(
            status="resolved",
            owner_decision=ConflictResolution.COMPOSE.value,
            target_requirement_status="created",
            target_requirement_id="TODAY-IDENTITY-001",
        )
        rendered = render_conflict_docket(resolved)
        self.assertIn('status = "resolved"', rendered)
        self.assertIn('owner_decision = "compose"', rendered)
        self.assertIn('target_requirement_id = "TODAY-IDENTITY-001"', rendered)
        self.assertIn("- Status: `created`", rendered)
        self.assertIn("- Requirement ID: `TODAY-IDENTITY-001`", rendered)
        self.assertIn("- Status: resolved", rendered)
        self.assertIn("- Decision: `compose`", rendered)
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            open_dir = root / "docs/canon/decisions/open"
            open_dir.mkdir(parents=True)
            (open_dir / "conflict-today-primary-identity.md").write_text(
                rendered, encoding="utf-8"
            )
            loaded = load_conflict_dockets(root)
        self.assertEqual(loaded, (resolved,))

    def test_unresolved_target_is_only_a_planned_uncreated_placeholder(self):
        with self.assertRaises(CanonError):
            render_conflict_docket(
                docket(target_requirement_id="TODAY-IDENTITY-001")
            )

    def test_load_rejects_symlink_and_unknown_markdown_shape(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            open_dir = root / "docs/canon/decisions/open"
            open_dir.mkdir(parents=True)
            outside = root / "outside.md"
            outside.write_text(render_conflict_docket(docket()), encoding="utf-8")
            (open_dir / "conflict-today-primary-identity.md").symlink_to(outside)
            with self.assertRaises(CanonError):
                load_conflict_dockets(root)

    def test_load_rejects_noncanonical_docket_filename(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            open_dir = root / "docs/canon/decisions/open"
            open_dir.mkdir(parents=True)
            (open_dir / "renamed.md").write_text(
                render_conflict_docket(docket()), encoding="utf-8"
            )
            with self.assertRaises(CanonError):
                load_conflict_dockets(root)

    def test_report_is_sorted_deterministic_newline_terminated_and_timestamp_free(self):
        first = docket()
        second = docket(
            conflict_id="CONFLICT-CLOUDKIT-CONTINUITY",
            scopes=("private graph continuity",),
            affected_task_scopes=("system.sync",),
        )
        report_a = render_unresolved_report((first, second), canon_revision=0)
        report_b = render_unresolved_report((second, first), canon_revision=0)
        self.assertEqual(report_a, report_b)
        self.assertLess(
            report_a.index(b"CONFLICT-CLOUDKIT-CONTINUITY"),
            report_a.index(b"CONFLICT-TODAY-PRIMARY-IDENTITY"),
        )
        self.assertTrue(report_a.endswith(b"\n"))
        self.assertNotIn(b"generated_at", report_a)

    def test_all_conflict_claims_must_be_docketed_exactly_once(self):
        expected = {"CLAIM-A", "CLAIM-B"}
        validate_conflict_coverage((docket(),), expected)
        with self.assertRaises(CanonError):
            validate_conflict_coverage((docket(),), expected | {"CLAIM-ORPHAN"})
        duplicate = docket(conflict_id="CONFLICT-DUPLICATE")
        with self.assertRaises(CanonError):
            validate_conflict_coverage((docket(), duplicate), expected)

    def test_report_validates_tracked_provenance_and_require_resolved_blocks(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            write_conflict_repository(root, docket())
            migration = root / "docs/canon/migration"
            code, report = report_conflicts(root, require_resolved=False)
            blocked, blocked_report = report_conflicts(root, require_resolved=True)
            self.assertEqual(code, 0)
            self.assertEqual(blocked, 1)
            self.assertEqual(report, blocked_report)

            data = json.loads(
                migration.joinpath("claim-dispositions.json").read_text(
                    encoding="utf-8"
                )
            )
            data["claims"][0]["source_id"] = "UNKNOWN"
            migration.joinpath("claim-dispositions.json").write_text(
                json.dumps(data, sort_keys=True) + "\n", encoding="utf-8"
            )
            with self.assertRaises(CanonError):
                report_conflicts(root, require_resolved=False)

    def test_cli_exposes_report_and_require_resolved_exit(self):
        report = b"# report\n"
        with mock.patch(
            "tools.ambitions_canon.cli.report_conflicts",
            return_value=(1, report),
            create=True,
        ) as command:
            output = StringIO()
            with redirect_stdout(output):
                code = main(("conflicts", "report", "--require-resolved"))
        self.assertEqual(code, 1)
        self.assertEqual(
            output.getvalue(),
            "# report\nP0_BLOCKER CANON_CONFLICTS_UNRESOLVED owner decision required\n",
        )
        command.assert_called_once()
        self.assertTrue(command.call_args.kwargs["require_resolved"])

    def test_resolved_docket_cannot_disappear_without_target_and_ledger(self):
        previous = (docket(),)
        with self.assertRaises(CanonError):
            validate_docket_removals(previous, (), (), ())
        entry = supersession_entry(
            conflict_id="CONFLICT-TODAY-PRIMARY-IDENTITY",
            old_ids=("CLAIM-A", "CLAIM-B"),
            resulting_id="TODAY-IDENTITY-001",
            decision_date="2026-07-11",
            owner="Devan Warner",
            decision_source="Owner approval",
            decision_base_commit="a" * 40,
            superseded_artifacts=("SOURCE-B:line:2",),
        )
        with self.assertRaises(CanonError):
            validate_docket_removals(previous, (), (), (entry,))
        with self.assertRaises(CanonError):
            validate_docket_removals(
                previous, (), ("TODAY-IDENTITY-001",), (entry,)
            )
        resolved = docket(
            status="resolved",
            owner_decision="compose",
            target_requirement_status="created",
            target_requirement_id="TODAY-IDENTITY-001",
        )
        validate_docket_removals(
            (resolved,), (), ("TODAY-IDENTITY-001",), (entry,)
        )
        mismatched = replace(entry, old_ids=("CLAIM-A",))
        with self.assertRaises(CanonError):
            validate_docket_removals(
                (resolved,), (), ("TODAY-IDENTITY-001",), (mismatched,)
            )

    def test_repository_multiple_removals_reuse_one_shot_requirement_ids(self):
        disposition = b"claims"
        baseline = {
            "claim_dispositions_sha256": hashlib.sha256(disposition).hexdigest(),
            "decision_evidence_fingerprint_sha256": None,
            "resolution_provenance": None,
            "dockets": [
                {"conflict_id": "CONFLICT-A"},
                {"conflict_id": "CONFLICT-B"},
            ],
        }
        seen_requirement_sets: list[set[str]] = []

        def record_requirements(
            record, requirement_ids, entries, resolution_provenance, path
        ):
            seen_requirement_sets.append(requirement_ids)

        with (
            mock.patch(
                "tools.ambitions_canon.migration.validate_tracked_canon_evidence",
                return_value=SimpleNamespace(
                    source_catalog_bytes=b"catalog",
                    claim_dispositions_bytes=disposition,
                    conflict_baseline_bytes=b"baseline",
                ),
            ),
            mock.patch(
                "tools.ambitions_canon.conflicts._parse_tracked_claims",
                return_value={},
            ),
            mock.patch(
                "tools.ambitions_canon.conflicts._parse_conflict_baseline",
                return_value=baseline,
            ),
            mock.patch(
                "tools.ambitions_canon.conflicts._validate_removed_baseline_record",
                side_effect=record_requirements,
            ),
            mock.patch(
                "tools.ambitions_canon.conflicts._validate_baseline_claim_coverage"
            ),
            mock.patch(
                "tools.ambitions_canon.conflicts._validate_docket_claim_graph"
            ),
        ):
            validate_conflict_repository(
                Path("."),
                (),
                (item for item in ("LAW-A", "LAW-B")),
                (),
            )

        self.assertEqual(
            seen_requirement_sets,
            [{"LAW-A", "LAW-B"}, {"LAW-A", "LAW-B"}],
        )

    def test_removed_docket_rejects_arbitrary_or_mismatched_provenance(self):
        value = docket(
            status="resolved",
            owner_decision="compose",
            target_requirement_status="created",
            target_requirement_id="TODAY-IDENTITY-001",
        )
        old_ids = tuple(item.claim_id for item in value.claims)
        provenance = {
            "owner": "Devan Warner",
            "decision_date": "2026-07-12",
            "decision_source_sha256": hashlib.sha256(
                b"Exact owner approval"
            ).hexdigest(),
            "decision_base_commit": "a" * 40,
        }
        entry = supersession_entry(
            conflict_id=value.conflict_id,
            old_ids=old_ids,
            resulting_id="TODAY-IDENTITY-001",
            decision_date="2026-07-12",
            owner="Devan Warner",
            decision_source="Exact owner approval",
            resolution="compose",
            decision_base_commit="a" * 40,
            superseded_artifacts=value.artifacts_to_supersede,
        )
        record = {
            "conflict_id": value.conflict_id,
            "status": "resolved",
            "owner_decision": "compose",
            "target_requirement_status": "created",
            "target_requirement_id": "TODAY-IDENTITY-001",
            "claims": [{"claim_id": item} for item in old_ids],
            "artifacts_to_supersede": list(value.artifacts_to_supersede),
        }

        _validate_removed_baseline_record(
            record,
            {"TODAY-IDENTITY-001"},
            (entry,),
            provenance,
            Path("baseline.json"),
        )
        for changed in (
            {"decision_source": "arbitrary"},
            {"owner": "Someone Else"},
            {"decision_date": "2026-07-11"},
            {"decision_base_commit": "b" * 40},
            {"resolution": "keep_a"},
        ):
            with self.subTest(changed=changed), self.assertRaises(CanonError):
                _validate_removed_baseline_record(
                    record,
                    {"TODAY-IDENTITY-001"},
                    (replace(entry, **changed),),
                    provenance,
                    Path("baseline.json"),
                )

    def test_repository_validation_compares_every_docket_claim_field(self):
        value = docket()
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            write_conflict_repository(root, value)
            validate_conflict_repository(root, (value,), (), ())
            original = value.claims[0]
            changes = (
                {"source_id": "SOURCE-Z"},
                {"source_location": "line:99"},
                {"concept": "surface.today.other"},
                {"scope": "today root changed"},
                {"modality": Modality.MUST_NOT},
                {"normalized_value": "changed"},
                {"evidence_sha256": "f" * 64},
                {"owner_approval": "different-owner-evidence"},
                {"owner_evidence_text_sha256": "a" * 64},
                {"owner_evidence_rationale_sha256": "b" * 64},
            )
            for changed in changes:
                claims = (replace(original, **changed), value.claims[1])
                concepts = tuple(sorted({item.concept for item in claims}))
                candidate = replace(value, claims=claims, concepts=concepts)
                with self.subTest(changed=changed):
                    with self.assertRaises(CanonError):
                        validate_conflict_repository(root, (candidate,), (), ())

    def test_conflict_baseline_is_compact_and_contains_no_doctrine_or_owner_prose(self):
        value = docket()
        raw = render_conflict_baseline((value,), disposition_bytes(value))
        baseline = json.loads(raw)
        self.assertEqual(
            set(baseline),
            {
                "schema_version",
                "claim_dispositions_sha256",
                "decision_evidence_fingerprint_sha256",
                "resolution_provenance",
                "dockets",
            },
        )
        record = baseline["dockets"][0]
        self.assertEqual(
            set(record),
            {
                "artifacts_to_supersede",
                "conflict_id",
                "docket_sha256",
                "owner_decision",
                "removal_state_sha256",
                "status",
                "target_requirement_id",
                "target_requirement_status",
                "claims",
            },
        )
        self.assertEqual(
            set(record["claims"][0]),
            {"claim_id", "source_id", "source_location", "fingerprint_sha256"},
        )
        forbidden_keys = {
            "concept",
            "scope",
            "modality",
            "normalized_value",
            "owner_approval",
            "owner_approval_sha256",
            "owner_evidence_text_sha256",
            "owner_evidence_rationale_sha256",
            "recommendation",
            "proposed_canonical_law",
        }

        def keys(item: object) -> set[str]:
            if isinstance(item, dict):
                return set(item).union(*(keys(value) for value in item.values()))
            if isinstance(item, list):
                return set().union(*(keys(value) for value in item))
            return set()

        self.assertFalse(keys(baseline) & forbidden_keys)
        self.assertNotIn("Reality Window", raw.decode("utf-8"))
        self.assertNotIn("Today root at rest", raw.decode("utf-8"))

    def test_compact_baseline_still_authorizes_only_exact_resolved_removal(self):
        value = docket(
            status="resolved",
            owner_decision="compose",
            target_requirement_status="created",
            target_requirement_id="TODAY-IDENTITY-001",
        )
        entry = supersession_entry(
            conflict_id=value.conflict_id,
            old_ids=tuple(item.claim_id for item in value.claims),
            resulting_id="TODAY-IDENTITY-001",
            decision_date="2026-07-11",
            owner="Devan Warner",
            decision_source="Owner approval",
            decision_base_commit="a" * 40,
            superseded_artifacts=value.artifacts_to_supersede,
        )
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            write_conflict_repository(root, value)
            baseline_path = (
                root / "docs/canon/migration/conflict-docket-baseline.json"
            )
            baseline = json.loads(baseline_path.read_text(encoding="utf-8"))
            baseline["resolution_provenance"] = {
                "owner": "Devan Warner",
                "decision_date": "2026-07-11",
                "decision_source_sha256": hashlib.sha256(
                    b"Owner approval"
                ).hexdigest(),
                "decision_base_commit": "a" * 40,
            }
            baseline_path.write_text(
                json.dumps(baseline, indent=2, sort_keys=True) + "\n",
                encoding="utf-8",
            )
            validate_conflict_repository(
                root,
                (),
                ("TODAY-IDENTITY-001",),
                (entry,),
            )
            baseline = json.loads(baseline_path.read_text(encoding="utf-8"))
            baseline["dockets"][0]["removal_state_sha256"] = "0" * 64
            baseline_path.write_text(
                json.dumps(baseline, indent=2, sort_keys=True) + "\n",
                encoding="utf-8",
            )
            with self.assertRaises(CanonError) as raised:
                validate_conflict_repository(
                    root,
                    (),
                    ("TODAY-IDENTITY-001",),
                    (entry,),
                )
            self.assertEqual(raised.exception.code, "CONFLICT_BASELINE_INVALID")

    def test_repository_validation_rejects_orphan_or_missing_unresolved_docket(self):
        value = docket()
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            write_conflict_repository(root, value)
            with self.assertRaises(CanonError):
                validate_conflict_repository(root, (), (), ())

    def test_repository_validation_fails_when_baseline_is_unavailable(self):
        value = docket()
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            write_conflict_repository(root, value)
            (root / "docs/canon/migration/conflict-docket-baseline.json").unlink()
            with self.assertRaises(CanonError):
                validate_conflict_repository(root, (value,), (), ())

    def test_build_invokes_accepted_claim_and_baseline_validation(self):
        registry = SimpleNamespace(requirements=(), supersession_entries=())
        validator_error = CanonError("CONFLICT_BUILD_GATE", "blocked")
        with (
            mock.patch.object(canon_build, "_load_audited_registry", return_value=registry),
            mock.patch(
                "tools.ambitions_canon.conflicts.load_conflict_dockets",
                return_value=(),
            ),
            mock.patch(
                "tools.ambitions_canon.conflicts.validate_conflict_repository",
                side_effect=validator_error,
                create=True,
            ) as validator,
            self.assertRaises(CanonError) as caught,
        ):
            canon_build.build_canon(Path("/tmp/repository"))
        self.assertEqual(caught.exception.code, "CONFLICT_BUILD_GATE")
        validator.assert_called_once()


if __name__ == "__main__":
    unittest.main()
