import copy
import hashlib
import tempfile
import unittest
import json
from dataclasses import replace
from pathlib import Path

from tests.canon.test_impact import document, registry, requirement
from tests.canon.canon_test_support import copy_figma_reconciliation_evidence
from tools.ambitions_canon.external_authority import (
    external_reference_findings,
    load_external_references,
    render_external_reference_impact,
    render_visual_authority_manifest,
)
from tools.ambitions_canon.model import (
    AuthorityClass,
    AuthorityReference,
    AuthorityReferenceKind,
    FigmaAuthorityRole,
)


def external_reference(
    reference_id: str,
    kind: AuthorityReferenceKind,
    requirement_ids: tuple[str, ...],
    *,
    source: str,
    approval_state: str = "approved",
    approved_by: str | None = "Devan Warner",
) -> AuthorityReference:
    authority_class = {
        AuthorityReferenceKind.FIGMA: AuthorityClass.FIGMA,
        AuthorityReferenceKind.LINEAR: AuthorityClass.LINEAR,
    }.get(kind, AuthorityClass.SOURCE_AND_TESTS)
    return AuthorityReference(
        schema_version=1,
        reference_id=reference_id,
        authority_class=authority_class,
        reference_kind=kind,
        source=source,
        revision="fixture-v1",
        requirement_ids=requirement_ids,
        approval_state=approval_state,
        approved_by=approved_by,
        implementation_status="Yellow evidence ceiling; not implementation proof",
        authority_role=(
            FigmaAuthorityRole.APPROVED_TARGET
            if kind is AuthorityReferenceKind.FIGMA
            else None
        ),
    )


class ExternalAuthorityTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary_directory.cleanup)
        self.root = Path(self.temporary_directory.name)
        self.item = requirement("TODAY-001")
        self.current = registry((document("SURFACE-TODAY", (self.item,)),))

    def rooted_registry(self):
        return replace(
            self.current,
            manifest=replace(self.current.manifest, repository_root=self.root),
        )

    def write_reference_files(self) -> Path:
        references_root = self.root / "docs/canon/references"
        references_root.mkdir(parents=True, exist_ok=True)
        (references_root / "linear.toml").write_text(
            '''schema_version = 1
kind = "linear"

[[references]]
reference_id = "LINEAR:96b93346-271d-46fc-beab-43ff7e286b5d"
source = "linear:96b93346-271d-46fc-beab-43ff7e286b5d"
revision = "2026-07-10T00:44:25.448Z"
requirement_ids = ["TODAY-001"]
approval_state = "approved"
approved_by = "Devan Warner"
implementation_status = "migration corpus; not implementation proof"
''',
            encoding="utf-8",
        )
        (references_root / "figma.toml").write_text(
            'schema_version = 1\nkind = "figma"\nreferences = []\n',
            encoding="utf-8",
        )
        (references_root / "proof-sources.toml").write_text(
            'schema_version = 1\nkind = "proof"\nreferences = []\n',
            encoding="utf-8",
        )
        return references_root

    def test_unknown_figma_and_linear_requirements_have_distinct_gap_classes(self):
        references = (
            external_reference(
                "FIGMA:FILE:1:2",
                AuthorityReferenceKind.FIGMA,
                ("UNKNOWN-FIGMA-001",),
                source="figma:FILE:1:2",
            ),
            external_reference(
                "LINEAR:DOC",
                AuthorityReferenceKind.LINEAR,
                ("UNKNOWN-LINEAR-001",),
                source="linear:96b93346-271d-46fc-beab-43ff7e286b5d",
            ),
        )

        findings = external_reference_findings(self.current, references, self.root)

        self.assertTrue(any("gap_class=figma_to_canon" in item.message for item in findings))
        self.assertTrue(any("gap_class=linear_to_canon" in item.message for item in findings))
        self.assertFalse(any("gap_class=missing" in item.message for item in findings))

    def test_superseded_requirement_reference_fails(self):
        current = replace(self.current, superseded_ids=frozenset({"OLD-TODAY-001"}))
        reference = external_reference(
            "LINEAR:DOC",
            AuthorityReferenceKind.LINEAR,
            ("OLD-TODAY-001",),
            source="linear:96b93346-271d-46fc-beab-43ff7e286b5d",
        )

        findings = external_reference_findings(current, (reference,), self.root)

        self.assertIn(
            "CANON_EXTERNAL_REQUIREMENT_SUPERSEDED",
            {finding.code for finding in findings},
        )

    def test_visual_authority_without_explicit_owner_approval_blocks_ui_readiness(self):
        unapproved = external_reference(
            "FIGMA:FILE:1:2",
            AuthorityReferenceKind.FIGMA,
            ("TODAY-001",),
            source="figma:FILE:1:2",
            approval_state="unreviewed",
            approved_by=None,
        )

        findings = external_reference_findings(self.current, (unapproved,), self.root)
        manifest = render_visual_authority_manifest(self.current, (unapproved,))

        self.assertIn("CANON_FIGMA_OWNER_APPROVAL_REQUIRED", {item.code for item in findings})
        self.assertFalse(manifest["ui_readiness"])
        self.assertEqual(manifest["authorities"][0]["authority_status"], "non_authoritative")

    def test_candidate_figma_reference_never_becomes_authoritative(self):
        candidate = replace(
            external_reference(
                "FIGMA-CANDIDATE:FILE:1:2",
                AuthorityReferenceKind.FIGMA,
                ("TODAY-001",),
                source="figma:FILE:1:2",
                approval_state="unreviewed",
                approved_by=None,
            ),
            authority_role=FigmaAuthorityRole.CANDIDATE,
        )

        manifest = render_visual_authority_manifest(self.current, (candidate,))

        self.assertEqual(manifest["authorities"][0]["authority_status"], "non_authoritative")
        self.assertFalse(manifest["ui_readiness"])

    def test_figma_reference_contract_carries_governed_visual_authority_fields(self):
        references_root = self.write_reference_files()
        (references_root / "figma.toml").write_text(
            '''schema_version = 1
kind = "figma"

[[references]]
reference_id = "FIGMA:SWtHm9ouHTPbEFfNrrtZwv:1:2"
source = "figma:SWtHm9ouHTPbEFfNrrtZwv:1:2"
revision = "1:2"
visual_authority_id = "VSP-01"
canon_revision = 1
frame_version = "R1"
requirement_ids = ["TODAY-001"]
authority_role = "approved_target"
approval_state = "approved"
approved_by = "Devan Warner"
swiftui_plausibility = "plausible_unverified"
accessibility_variants = ["Dynamic Type", "Reduce Motion", "VoiceOver"]
implementation_status = "Yellow; not implementation proof"
''',
            encoding="utf-8",
        )

        loaded = load_external_references(self.root)[0]
        manifest = render_visual_authority_manifest(self.current, (loaded,))
        authority = manifest["authorities"][0]

        self.assertEqual(authority["visual_authority_id"], "VSP-01")
        self.assertEqual(authority["canon_revision"], 1)
        self.assertEqual(authority["frame_version"], "R1")
        self.assertEqual(authority["swiftui_plausibility"], "plausible_unverified")
        self.assertEqual(
            authority["accessibility_variants"],
            ["Dynamic Type", "Reduce Motion", "VoiceOver"],
        )

    def test_figma_reference_contract_rejects_missing_governance_fields(self):
        references_root = self.write_reference_files()
        (references_root / "figma.toml").write_text(
            '''schema_version = 1
kind = "figma"

[[references]]
reference_id = "FIGMA:SWtHm9ouHTPbEFfNrrtZwv:1:2"
source = "figma:SWtHm9ouHTPbEFfNrrtZwv:1:2"
revision = "1:2"
visual_authority_id = "VSP-01"
requirement_ids = ["TODAY-001"]
authority_role = "approved_target"
approval_state = "approved"
approved_by = "Devan Warner"
implementation_status = "Yellow; not implementation proof"
''',
            encoding="utf-8",
        )

        with self.assertRaises(Exception) as raised:
            load_external_references(self.root)

        self.assertEqual(raised.exception.code, "CANON_EXTERNAL_REFERENCE_SCHEMA")

    def test_figma_reconciliation_binds_retained_authority_to_reference(self):
        from tools.ambitions_canon.external_authority import (
            validate_figma_reconciliation,
        )

        references_root = self.write_reference_files()
        (references_root / "figma.toml").write_text(
            '''schema_version = 1
kind = "figma"

[[references]]
reference_id = "FIGMA:SWtHm9ouHTPbEFfNrrtZwv:1:2"
source = "figma:SWtHm9ouHTPbEFfNrrtZwv:1:2"
revision = "1:2"
visual_authority_id = "VSP-01"
canon_revision = 1
frame_version = "R1"
requirement_ids = ["TODAY-001"]
authority_role = "approved_target"
approval_state = "approved"
approved_by = "Devan Warner"
swiftui_plausibility = "plausible_unverified"
accessibility_variants = ["Dynamic Type"]
implementation_status = "Yellow; not implementation proof"
''',
            encoding="utf-8",
        )
        migration = self.root / "docs/canon/migration"
        migration.mkdir(parents=True)
        approval = self.root / "docs/approval.md"
        approval.write_text("approved\n", encoding="utf-8")
        approval_digest = hashlib.sha256(approval.read_bytes()).hexdigest()
        expected_file_keys = sorted(
            [
                "SWtHm9ouHTPbEFfNrrtZwv",
                "XSpaP7NkB2efoTgSy0KpFq",
                "hnVi8KV2SAuWP3V5hV160W",
                "9FhOWjt1KGmDg31rq2XP9e",
                "lDslntJK8Xtmap7paJz7f5",
                "tJzwkJCg7piFbb3LGy91vD",
                "syAY6U5srUCifJgKq0wSSH",
                "TgKZkoanB1hLaSYbthAIr3",
            ]
        )
        payload = {
            "schema_version": 1,
            "canon_revision": 1,
            "authority_state": "shadow",
            "disposition_state": "proposed_not_applied_owner_gate",
            "external_mutations_applied": False,
            "allowed_actions": [
                "retain_authority",
                "merge_unique_visual_content",
                "downgrade_candidate",
                "delete_duplicate_node",
                "delete_duplicate_file",
                "retain_failure_evidence",
                "owner_review",
            ],
            "generated_from": {
                "figma_file_key": "SWtHm9ouHTPbEFfNrrtZwv",
                "inventory_date": "2026-07-13",
                "linear_issue_ids": ["AMB-1480"],
                "page_id": "0:1",
                "repo_provenance": "docs/design/provenance/vsp-provenance.json",
            },
            "inventory_counts": {
                "files": 8,
                "nodes": 1,
                "pages": 8,
                "retained_authorities": 1,
            },
            "expected_live_file_keys": expected_file_keys,
            "file_inventory": [
                {
                    "file_key": file_key,
                    "linear_issue_ids": ["AMB-1480"],
                    "pages": [
                        {
                            "page_id": "0:1",
                            "page_name": "Fixture page",
                            "root_node_ids": ["1:2"],
                            "metadata_request_id": "metadata-request",
                            "screenshot_request_id": "screenshot-request",
                            "screenshot_sha256": "b" * 64,
                            "original_width": 430,
                            "original_height": 932,
                            "repository_screenshots": [],
                        }
                    ],
                    "authority_claims": ["fixture live label"],
                    "governed_approved_requirement_ids": (
                        ["TODAY-001"]
                        if file_key == "SWtHm9ouHTPbEFfNrrtZwv"
                        else []
                    ),
                    "unique_visual_content": "fixture content",
                    "duplicate_or_competing_authority": "fixture comparison",
                    "inbound_links": [],
                    "recommended_action": (
                        "retain_authority"
                        if file_key == "SWtHm9ouHTPbEFfNrrtZwv"
                        else "owner_review"
                    ),
                    "action_status": "proposed_not_applied",
                }
                for file_key in expected_file_keys
            ],
            "manual_file_deletions": [],
            "text_repairs": [
                {
                    "root_node_id": "177:93",
                    "text_node_id": "177:926",
                    "before": "Before owner-approval claim.",
                    "after": "After owner-approval non-claim.",
                    "rollback": "Restore exact before string.",
                    "action_status": "proposed_not_applied",
                }
            ],
            "nodes": [
                {
                    "visual_authority_id": "VSP-01",
                    "file_key": "SWtHm9ouHTPbEFfNrrtZwv",
                    "page_id": "0:1",
                    "page_name": "Candidate page",
                    "node_id": "1:2",
                    "frame_label": "AUTHORITY - VSP-01 - fixture - R1",
                    "frame_version": "R1",
                    "owner_approval": {
                        "state": "approved",
                        "approved_by": "Devan Warner",
                        "evidence": [
                            {
                                "path": "docs/approval.md",
                                "sha256": approval_digest,
                            }
                        ],
                    },
                    "requirement_ids": ["TODAY-001"],
                    "duplicate_or_competing_authority": "none",
                    "unique_visual_content": "fixture shell",
                    "accessibility_variants": ["Dynamic Type"],
                    "swiftui_plausibility": "plausible_unverified",
                    "recommended_action": "retain_authority",
                    "action_status": "proposed_not_applied",
                    "replacement_node_ids": [],
                    "evidence": {
                        "metadata_request_id": "metadata-request",
                        "screenshot_request_id": "screenshot-request",
                        "screenshot_sha256": "a" * 64,
                        "original_width": 430,
                        "original_height": 932,
                        "repository_paths": [],
                    },
                    "rollback": "No mutation; tracked proposal may be reverted.",
                    "claim_ceiling": "Yellow; Figma is visual authority only.",
                }
            ],
        }
        (migration / "figma-reconciliation.json").write_text(
            json.dumps(payload, sort_keys=True) + "\n", encoding="utf-8"
        )

        # An inventoried live page can be empty; the page itself and its
        # screenshot still prove that the Linear-linked page was inspected.
        payload["file_inventory"][0]["pages"][0]["root_node_ids"] = []
        (migration / "figma-reconciliation.json").write_text(
            json.dumps(payload, sort_keys=True) + "\n", encoding="utf-8"
        )

        snapshot = validate_figma_reconciliation(
            self.root,
            self.rooted_registry(),
            load_external_references(self.root),
        )

        self.assertEqual(snapshot.node_count, 1)
        self.assertEqual(snapshot.action_counts, {"retain_authority": 1})
        self.assertFalse(snapshot.external_mutations_applied)
        self.assertTrue(snapshot.owner_gate_required)

        valid_evidence = payload["nodes"][0]["owner_approval"]["evidence"]
        approval_link = self.root / "docs/approval-link.md"
        approval_link.symlink_to("approval.md")
        for name, evidence in (
            (
                "stale_digest",
                [{"path": "docs/approval.md", "sha256": "0" * 64}],
            ),
            (
                "missing",
                [{"path": "docs/missing.md", "sha256": approval_digest}],
            ),
            (
                "duplicate",
                [valid_evidence[0], valid_evidence[0]],
            ),
            (
                "path_escape",
                [{"path": "../approval.md", "sha256": approval_digest}],
            ),
            (
                "symlink",
                [{"path": "docs/approval-link.md", "sha256": approval_digest}],
            ),
        ):
            with self.subTest(name=name):
                payload["nodes"][0]["owner_approval"]["evidence"] = evidence
                (migration / "figma-reconciliation.json").write_text(
                    json.dumps(payload, sort_keys=True) + "\n", encoding="utf-8"
                )
                with self.assertRaises(Exception) as raised:
                    validate_figma_reconciliation(
                        self.root,
                        self.rooted_registry(),
                        load_external_references(self.root),
                    )
                self.assertEqual(
                    raised.exception.code,
                    "CANON_FIGMA_RECONCILIATION_STATE",
                )
        payload["nodes"][0]["owner_approval"]["evidence"] = valid_evidence

        payload["file_inventory"][0]["governed_approved_requirement_ids"] = [
            "TODAY-001"
        ]
        (migration / "figma-reconciliation.json").write_text(
            json.dumps(payload, sort_keys=True) + "\n", encoding="utf-8"
        )
        with self.assertRaises(Exception) as raised:
            validate_figma_reconciliation(
                self.root,
                self.rooted_registry(),
                load_external_references(self.root),
            )
        self.assertEqual(
            raised.exception.code,
            "CANON_FIGMA_MULTIPLE_APPROVED_TARGETS",
        )
        payload["file_inventory"][0]["governed_approved_requirement_ids"] = []

        payload["file_inventory"].pop()
        payload["inventory_counts"]["files"] = 7
        payload["inventory_counts"]["pages"] = 7
        (migration / "figma-reconciliation.json").write_text(
            json.dumps(payload, sort_keys=True) + "\n", encoding="utf-8"
        )
        with self.assertRaises(Exception) as raised:
            validate_figma_reconciliation(
                self.root,
                self.rooted_registry(),
                load_external_references(self.root),
            )
        self.assertEqual(
            raised.exception.code,
            "CANON_FIGMA_RECONCILIATION_STATE",
        )

    def test_live_figma_retained_approval_evidence_is_digest_bound(self):
        from tools.ambitions_canon.external_authority import (
            validate_figma_reconciliation,
        )
        from tools.ambitions_canon.manifest import load_documents, load_manifest
        from tools.ambitions_canon.registry import build_registry

        root = Path(__file__).resolve().parents[2]
        manifest = load_manifest(root)
        current = build_registry(manifest, load_documents(root, manifest))
        snapshot = validate_figma_reconciliation(
            root,
            current,
            load_external_references(root),
        )
        payload = json.loads(snapshot.source_bytes)
        retained = [
            node for node in payload["nodes"]
            if node["recommended_action"] == "retain_authority"
        ]

        self.assertEqual(len(retained), 9)
        for node in retained:
            evidence = node["owner_approval"]["evidence"]
            self.assertTrue(evidence, node["node_id"])
            for binding in evidence:
                evidence_path = root / binding["path"]
                self.assertEqual(
                    hashlib.sha256(evidence_path.read_bytes()).hexdigest(),
                    binding["sha256"],
                )

    def test_live_figma_reconciliation_records_exact_applied_authority_receipts(self):
        root = Path(__file__).resolve().parents[2]
        data = json.loads(
            root.joinpath(
                "docs/canon/migration/figma-reconciliation.json"
            ).read_text(encoding="utf-8")
        )
        self.assertEqual(
            data["disposition_state"],
            "authority_metadata_and_text_applied_verified",
        )
        self.assertIs(data["external_mutations_applied"], True)

        applied_nodes = [
            node["node_id"]
            for node in data["nodes"]
            if node["action_status"] == "applied_verified"
        ]
        self.assertEqual(
            applied_nodes,
            [
                "87:2",
                "160:93",
                "177:93",
                "202:93",
                "217:93",
                "240:93",
                "257:93",
                "272:93",
                "92:2",
            ],
        )
        self.assertTrue(
            all(
                repair["action_status"] == "applied_verified"
                for repair in data["text_repairs"]
            )
        )

        receipt = data["execution_receipt"]
        self.assertEqual(receipt["status"], "applied_verified")
        self.assertEqual(receipt["file_key"], "SWtHm9ouHTPbEFfNrrtZwv")
        self.assertEqual(receipt["page_id"], "0:1")
        self.assertEqual(receipt["shared_plugin_namespace"], "ambitions.canon")
        self.assertEqual(receipt["deleted_node_ids"], [])
        self.assertEqual(receipt["created_node_ids"], [])
        self.assertEqual(
            [item["node_id"] for item in receipt["metadata_writes"]],
            applied_nodes,
        )
        self.assertEqual(
            [item["text_node_id"] for item in receipt["text_writes"]],
            ["177:783", "177:926", "240:948", "272:652", "272:97"],
        )
        for item in receipt["metadata_writes"]:
            self.assertEqual(item["deleted_node_ids"], [])
            self.assertEqual(item["created_node_ids"], [])
            self.assertEqual(item["mutated_node_ids"], [item["node_id"]])
            self.assertTrue(all(value == "" for value in item["before"].values()))
            self.assertEqual(len(item["after"]), 10)
            self.assertEqual(
                item["before_screenshot"]["sha256"],
                item["after_screenshot"]["sha256"],
            )
        for item in receipt["text_writes"]:
            self.assertEqual(item["deleted_node_ids"], [])
            self.assertEqual(item["created_node_ids"], [])
            self.assertEqual(item["mutated_node_ids"], [item["text_node_id"]])
            repair = next(
                repair
                for repair in data["text_repairs"]
                if repair["text_node_id"] == item["text_node_id"]
            )
            self.assertEqual(item["before"], repair["before"])
            self.assertEqual(item["after"], repair["after"])

        references = load_external_references(root)
        approved = [
            reference
            for reference in references
            if reference.reference_kind is AuthorityReferenceKind.FIGMA
            and reference.authority_role is FigmaAuthorityRole.APPROVED_TARGET
        ]
        self.assertEqual(len(approved), 9)
        self.assertTrue(
            all(
                reference.reconciliation_status == "applied_verified"
                for reference in approved
            )
        )

        manifest = json.loads(
            root.joinpath(
                "docs/canon/generated/visual-authority-manifest.json"
            ).read_text(encoding="utf-8")
        )
        self.assertEqual(
            manifest["reconciliation"]["disposition_state"],
            "authority_metadata_and_text_applied_verified",
        )
        self.assertEqual(
            len(manifest["reconciliation"]["execution_receipt"]["metadata_writes"]),
            9,
        )
        self.assertTrue(
            all(
                authority["reconciliation_status"] == "applied_verified"
                for authority in manifest["authorities"]
                if authority["authority_role"] == "approved_target"
            )
        )

    def test_applied_figma_metadata_receipts_are_exactly_cross_bound(self):
        from tools.ambitions_canon.external_authority import (
            validate_figma_reconciliation,
        )
        from tools.ambitions_canon.manifest import load_documents, load_manifest
        from tools.ambitions_canon.registry import build_registry

        root = Path(__file__).resolve().parents[2]
        manifest = load_manifest(root)
        current = build_registry(manifest, load_documents(root, manifest))
        references = load_external_references(root)
        data = json.loads(
            root.joinpath("docs/canon/migration/figma-reconciliation.json").read_text(
                encoding="utf-8"
            )
        )
        reference_by_source = {
            reference.source: reference
            for reference in references
            if reference.reference_kind is AuthorityReferenceKind.FIGMA
        }
        nodes_by_id = {node["node_id"]: node for node in data["nodes"]}

        for receipt in data["execution_receipt"]["metadata_writes"]:
            node = nodes_by_id[receipt["node_id"]]
            reference = reference_by_source[
                f"figma:{node['file_key']}:{node['node_id']}"
            ]
            expected = {
                "accessibility_variants": json.dumps(
                    list(reference.accessibility_variants), separators=(",", ":")
                ),
                "approved_by": node["owner_approval"]["approved_by"],
                "authority_boundary": "visual_only_canon_and_source_own_product_law",
                "canon_revision": str(manifest.canon_revision),
                "frame_version": reference.frame_version,
                "implementation_status": reference.implementation_status,
                "owner_approval_state": node["owner_approval"]["state"],
                "requirement_ids": json.dumps(
                    sorted(reference.requirement_ids), separators=(",", ":")
                ),
                "swiftui_plausibility": reference.swiftui_plausibility,
                "visual_authority_id": reference.visual_authority_id,
            }
            self.assertEqual(receipt["after"], expected)

        with tempfile.TemporaryDirectory() as temp:
            temp_root = Path(temp)
            reconciliation_path = (
                temp_root / "docs/canon/migration/figma-reconciliation.json"
            )
            reconciliation_path.parent.mkdir(parents=True)
            copy_figma_reconciliation_evidence(root, temp_root)

            def rejects(
                mutated: dict[str, object],
                checked_references: tuple[AuthorityReference, ...] = references,
                expected_code: str = "CANON_FIGMA_RECONCILIATION_STATE",
            ) -> None:
                reconciliation_path.write_text(
                    json.dumps(mutated, sort_keys=True) + "\n", encoding="utf-8"
                )
                with self.assertRaises(Exception) as raised:
                    validate_figma_reconciliation(
                        temp_root, current, checked_references
                    )
                self.assertEqual(
                    raised.exception.code, expected_code
                )

            for field in sorted(data["execution_receipt"]["metadata_writes"][0]["after"]):
                with self.subTest(metadata_field=field):
                    mutated = copy.deepcopy(data)
                    mutated["execution_receipt"]["metadata_writes"][0]["after"][field] += "-tampered"
                    rejects(mutated)

            envelope_tampers = {
                "file_key": "wrong-file",
                "page_id": "9:9",
                "approval_authority": "wrong-authority",
                "approval_review": "wrong-review",
                "status": "proposed_not_applied",
                "shared_plugin_namespace": "wrong.namespace",
                "created_node_ids": ["1:1"],
                "deleted_node_ids": ["1:2"],
            }
            for field, value in envelope_tampers.items():
                with self.subTest(envelope_field=field):
                    mutated = copy.deepcopy(data)
                    mutated["execution_receipt"][field] = value
                    rejects(mutated)

            for field, value in (
                ("mutated_node_ids", ["160:93"]),
                ("created_node_ids", ["1:1"]),
                ("deleted_node_ids", ["1:2"]),
            ):
                with self.subTest(metadata_identity_field=field):
                    mutated = copy.deepcopy(data)
                    mutated["execution_receipt"]["metadata_writes"][0][field] = value
                    rejects(mutated)

            for field in ("before", "after"):
                with self.subTest(text_field=field):
                    mutated = copy.deepcopy(data)
                    mutated["execution_receipt"]["text_writes"][0][field] += "-tampered"
                    rejects(mutated)

            first_applied_source = (
                f"figma:{data['execution_receipt']['file_key']}:"
                f"{data['execution_receipt']['metadata_writes'][0]['node_id']}"
            )
            status_tampered_references = tuple(
                replace(reference, reconciliation_status="proposed_not_applied")
                if reference.source == first_applied_source
                else reference
                for reference in references
            )
            rejects(data, status_tampered_references)

            coordinated_approval_tamper = copy.deepcopy(data)
            first_node_id = coordinated_approval_tamper["execution_receipt"][
                "metadata_writes"
            ][0]["node_id"]
            first_node = next(
                node
                for node in coordinated_approval_tamper["nodes"]
                if node["node_id"] == first_node_id
            )
            first_node["owner_approval"]["state"] = "direction_approved"
            coordinated_approval_tamper["execution_receipt"]["metadata_writes"][0][
                "after"
            ]["owner_approval_state"] = "direction_approved"
            rejects(
                coordinated_approval_tamper,
                expected_code="CANON_FIGMA_RECONCILIATION_STALE",
            )

    def test_legacy_figma_reference_without_governance_fields_loads(self):
        references_root = self.write_reference_files()
        (references_root / "figma.toml").write_text(
            '''schema_version = 1
kind = "figma"

[[references]]
reference_id = "FIGMA-CANDIDATE:FILE:1:2"
source = "figma:FILE:1:2"
revision = "1:2"
requirement_ids = ["TODAY-001"]
authority_role = "candidate"
approval_state = "unreviewed"
implementation_status = "legacy candidate; not implementation proof"
''',
            encoding="utf-8",
        )

        loaded = [
            reference
            for reference in load_external_references(self.root)
            if reference.reference_kind is AuthorityReferenceKind.FIGMA
        ]

        self.assertEqual(len(loaded), 1)
        self.assertIsNone(loaded[0].visual_authority_id)
        self.assertIsNone(loaded[0].canon_revision)
        self.assertEqual(loaded[0].accessibility_variants, ())

    def test_typed_figma_role_ignores_adversarial_reference_id_spelling(self):
        from tools.ambitions_canon.model import FigmaAuthorityRole

        approved = replace(
            external_reference(
                "FIGMA-CANDIDATE-WORD:FILE:1:2",
                AuthorityReferenceKind.FIGMA,
                ("TODAY-001",),
                source="figma:FILE:1:2",
            ),
            authority_role=FigmaAuthorityRole.APPROVED_TARGET,
        )
        candidate = replace(
            external_reference(
                "FIGMA:ORDINARY-ID:3:4",
                AuthorityReferenceKind.FIGMA,
                ("TODAY-001",),
                source="figma:FILE:3:4",
                approval_state="unreviewed",
                approved_by=None,
            ),
            authority_role=FigmaAuthorityRole.CANDIDATE,
        )

        manifest = render_visual_authority_manifest(
            self.current, (approved, candidate)
        )
        by_id = {item["reference_id"]: item for item in manifest["authorities"]}

        self.assertEqual(
            by_id[approved.reference_id]["authority_status"], "approved"
        )
        self.assertEqual(
            by_id[candidate.reference_id]["authority_status"], "non_authoritative"
        )
        self.assertEqual(
            by_id[candidate.reference_id]["authority_role"], "candidate"
        )
        self.assertTrue(manifest["owner_approval_complete"])

    def test_multiple_approved_figma_targets_for_one_requirement_fail(self):
        from tools.ambitions_canon.model import FigmaAuthorityRole

        first = replace(
            external_reference(
                "FIGMA:FILE:1:2",
                AuthorityReferenceKind.FIGMA,
                ("TODAY-001",),
                source="figma:FILE:1:2",
            ),
            authority_role=FigmaAuthorityRole.APPROVED_TARGET,
        )
        second = replace(
            external_reference(
                "FIGMA:FILE:3:4",
                AuthorityReferenceKind.FIGMA,
                ("TODAY-001",),
                source="figma:FILE:3:4",
            ),
            authority_role=FigmaAuthorityRole.APPROVED_TARGET,
        )

        findings = external_reference_findings(self.rooted_registry(), (first, second))

        self.assertIn(
            "CANON_FIGMA_MULTIPLE_APPROVED_TARGETS",
            {item.code for item in findings},
        )

    def test_figma_role_and_approval_combinations_are_closed(self):
        references_root = self.write_reference_files()
        invalid_rows = (
            (
                "approved_target_without_approval",
                '''authority_role = "approved_target"
approval_state = "unreviewed"''',
            ),
            (
                "candidate_with_approval",
                '''authority_role = "candidate"
approval_state = "approved"
approved_by = "Fixture owner"''',
            ),
        )
        for label, state_lines in invalid_rows:
            with self.subTest(label=label):
                (references_root / "figma.toml").write_text(
                    f'''schema_version = 1
kind = "figma"

[[references]]
reference_id = "FIGMA:FILE:1:2"
source = "figma:FILE:1:2"
revision = "1:2"
requirement_ids = ["TODAY-001"]
{state_lines}
implementation_status = "fixture; not implementation proof"
''',
                    encoding="utf-8",
                )

                with self.assertRaises(Exception) as raised:
                    load_external_references(self.root)
                self.assertEqual(
                    raised.exception.code,
                    "CANON_EXTERNAL_REFERENCE_SCHEMA",
                )

    def test_public_validator_rejects_illegal_typed_figma_state(self):
        invalid_candidate = replace(
            external_reference(
                "FIGMA:FILE:1:2",
                AuthorityReferenceKind.FIGMA,
                ("TODAY-001",),
                source="figma:FILE:1:2",
            ),
            authority_role=FigmaAuthorityRole.CANDIDATE,
        )

        findings = external_reference_findings(
            self.rooted_registry(),
            (invalid_candidate,),
        )

        self.assertIn(
            "CANON_FIGMA_AUTHORITY_STATE_INVALID",
            {item.code for item in findings},
        )

    def test_external_impact_projection_truthfully_summarizes_loaded_references(self):
        figma = replace(
            external_reference(
                "FIGMA:FILE:1:2",
                AuthorityReferenceKind.FIGMA,
                ("TODAY-001",),
                source="figma:FILE:1:2",
            ),
            authority_role=FigmaAuthorityRole.APPROVED_TARGET,
        )
        linear = external_reference(
            "LINEAR:DOC",
            AuthorityReferenceKind.LINEAR,
            ("TODAY-001",),
            source="linear:doc",
        )

        rendered = render_external_reference_impact(
            self.current,
            (linear, figma),
            (),
            {"traceability_input_sha": "a" * 64},
            linear_reconciliation={
                "action_counts": {
                    "owner_review": 2,
                    "retain_provenance_only": 3,
                },
                "disposition_state": "proposed_not_applied_owner_gate",
                "entity_count": 5,
                "external_mutations_applied": False,
                "input_sha": "b" * 64,
                "owner_gate_required": True,
                "status_counts": {
                    "applied_verified": 2,
                    "proposed_not_applied": 3,
                },
            },
        ).decode("utf-8")

        self.assertIn("**Representation status:** Represented", rendered)
        self.assertIn("- Stable references: `2`", rendered)
        self.assertIn("- Invalid external findings: `0`", rendered)
        self.assertIn("`FIGMA:FILE:1:2`", rendered)
        self.assertIn("`LINEAR:DOC`", rendered)
        self.assertIn(f"- Linear reconciliation SHA: `{'b' * 64}`", rendered)
        self.assertIn("- Reconciliation entities: `5`", rendered)
        self.assertIn("- Reconciliation action `owner_review`: `2`", rendered)
        self.assertIn("- Reconciliation action `retain_provenance_only`: `3`", rendered)
        self.assertIn("- External mutations applied: `false`", rendered)
        self.assertIn("- Owner gate required: `true`", rendered)
        self.assertIn("- Reconciliation status `applied_verified`: `2`", rendered)
        self.assertIn("- Reconciliation status `proposed_not_applied`: `3`", rendered)
        self.assertIn("does not prove implementation or readiness", rendered)
        self.assertTrue(rendered.endswith("\n"))

    def test_proof_source_must_be_repo_confined_or_an_allowed_external_locator(self):
        outside = external_reference(
            "PROOF-OUTSIDE",
            AuthorityReferenceKind.PROOF,
            ("TODAY-001",),
            source="../outside.json",
        )
        unsupported = external_reference(
            "PROOF-UNSUPPORTED",
            AuthorityReferenceKind.PROOF,
            ("TODAY-001",),
            source="ftp://example.invalid/proof.json",
        )
        allowed = external_reference(
            "PROOF-LINEAR",
            AuthorityReferenceKind.PROOF,
            ("TODAY-001",),
            source="linear-comment:11111111-1111-1111-1111-111111111111:decision:1",
        )

        findings = external_reference_findings(
            self.current, (outside, unsupported, allowed), self.root
        )

        invalid_ids = {
            finding.message.rsplit("reference_id=", 1)[-1]
            for finding in findings
            if finding.code == "CANON_PROOF_SOURCE_INVALID"
        }
        self.assertEqual(invalid_ids, {"PROOF-OUTSIDE", "PROOF-UNSUPPORTED"})

    def test_current_test_and_proof_require_nonempty_attributable_approver(self):
        test_path = self.root / "tests/TodayTests.swift"
        test_path.parent.mkdir(parents=True)
        test_path.write_text("final class TodayTests {}\n", encoding="utf-8")
        proof_path = self.root / "docs/proof/today.json"
        proof_path.parent.mkdir(parents=True)
        proof_path.write_text("{}\n", encoding="utf-8")
        fixtures = (
            replace(
                external_reference(
                    "TEST-TODAY",
                    AuthorityReferenceKind.TEST,
                    ("TODAY-001",),
                    source="tests/TodayTests.swift",
                ),
                revision=hashlib.sha256(test_path.read_bytes()).hexdigest(),
            ),
            replace(
                external_reference(
                    "PROOF-TODAY",
                    AuthorityReferenceKind.PROOF,
                    ("TODAY-001",),
                    source="docs/proof/today.json",
                ),
                revision=hashlib.sha256(proof_path.read_bytes()).hexdigest(),
            ),
        )

        for reference in fixtures:
            with self.subTest(kind=reference.reference_kind.value, approved_by="valid"):
                codes = {
                    finding.code
                    for finding in external_reference_findings(
                        self.current, (reference,), self.root
                    )
                }
                self.assertNotIn("CANON_EVIDENCE_APPROVER_REQUIRED", codes)
            for approved_by in (None, "   "):
                with self.subTest(
                    kind=reference.reference_kind.value, approved_by=approved_by
                ):
                    codes = {
                        finding.code
                        for finding in external_reference_findings(
                            self.current,
                            (replace(reference, approved_by=approved_by),),
                            self.root,
                        )
                    }
                    self.assertIn("CANON_EVIDENCE_APPROVER_REQUIRED", codes)

    def test_two_argument_validator_fails_closed_for_local_proof_without_repository_root(self):
        local = external_reference(
            "PROOF-LOCAL",
            AuthorityReferenceKind.PROOF,
            ("TODAY-001",),
            source="docs/proof/today.json",
        )

        findings = external_reference_findings(self.current, (local,))

        self.assertIn("CANON_PROOF_SOURCE_INVALID", {item.code for item in findings})

    def test_two_argument_validator_allows_stable_external_proof_without_repository_root(self):
        external = external_reference(
            "PROOF-LINEAR",
            AuthorityReferenceKind.PROOF,
            ("TODAY-001",),
            source="linear-comment:11111111-1111-1111-1111-111111111111:decision:1",
        )

        self.assertEqual(external_reference_findings(self.current, (external,)), ())

    def test_local_proof_rejects_leaf_ancestor_and_dangling_symlinks(self):
        outside = self.root.parent / f"{self.root.name}-outside-proof.json"
        outside.write_text("{}\n", encoding="utf-8")
        self.addCleanup(outside.unlink, missing_ok=True)
        proof_root = self.root / "docs/proof"
        proof_root.mkdir(parents=True)
        (proof_root / "leaf.json").symlink_to(outside)
        (self.root / "linked-proof").symlink_to(outside.parent, target_is_directory=True)
        (proof_root / "dangling.json").symlink_to(self.root / "missing.json")
        references = (
            external_reference(
                "PROOF-LEAF",
                AuthorityReferenceKind.PROOF,
                ("TODAY-001",),
                source="docs/proof/leaf.json",
            ),
            external_reference(
                "PROOF-ANCESTOR",
                AuthorityReferenceKind.PROOF,
                ("TODAY-001",),
                source=f"linked-proof/{outside.name}",
            ),
            external_reference(
                "PROOF-DANGLING",
                AuthorityReferenceKind.PROOF,
                ("TODAY-001",),
                source="docs/proof/dangling.json",
            ),
        )

        findings = external_reference_findings(self.rooted_registry(), references)

        invalid_ids = {
            finding.message.rsplit("reference_id=", 1)[-1]
            for finding in findings
            if finding.code == "CANON_PROOF_SOURCE_INVALID"
        }
        self.assertEqual(
            invalid_ids,
            {"PROOF-ANCESTOR", "PROOF-DANGLING", "PROOF-LEAF"},
        )

    def test_local_proof_requires_existing_regular_file(self):
        proof = self.root / "docs/proof/today.json"
        proof.parent.mkdir(parents=True)
        proof.write_text("{}\n", encoding="utf-8")
        valid = replace(
            external_reference(
                "PROOF-LOCAL",
                AuthorityReferenceKind.PROOF,
                ("TODAY-001",),
                source="docs/proof/today.json",
            ),
            revision=hashlib.sha256(proof.read_bytes()).hexdigest(),
        )

        self.assertEqual(
            external_reference_findings(self.rooted_registry(), (valid,)),
            (),
        )

    def test_all_three_fixed_reference_inputs_are_required(self):
        references_root = self.write_reference_files()
        (references_root / "figma.toml").unlink()

        with self.assertRaises(Exception) as raised:
            load_external_references(self.root)

        self.assertEqual(raised.exception.code, "CANON_EXTERNAL_REFERENCE_MISSING")

    def test_fixed_reference_input_rejects_leaf_symlink(self):
        references_root = self.write_reference_files()
        real = references_root / "figma-real.toml"
        (references_root / "figma.toml").replace(real)
        (references_root / "figma.toml").symlink_to(real)

        with self.assertRaises(Exception) as raised:
            load_external_references(self.root)

        self.assertEqual(raised.exception.code, "CANON_EXTERNAL_REFERENCE_READ")

    def test_reference_snapshot_hash_changes_and_revalidation_detects_mutation(self):
        from tools.ambitions_canon.external_authority import (
            load_external_reference_snapshot,
            validate_external_reference_snapshot,
        )

        references_root = self.write_reference_files()
        before = load_external_reference_snapshot(self.root)
        (references_root / "linear.toml").write_text(
            (references_root / "linear.toml").read_text(encoding="utf-8")
            .replace("migration corpus", "changed migration corpus"),
            encoding="utf-8",
        )
        after = load_external_reference_snapshot(self.root)

        self.assertNotEqual(before.input_sha, after.input_sha)
        with self.assertRaises(Exception) as raised:
            validate_external_reference_snapshot(self.root, before)
        self.assertEqual(raised.exception.code, "CANON_TRACEABILITY_INPUT_CHANGED")

    def test_reference_toml_loader_is_sorted_and_preserves_stable_ids(self):
        self.write_reference_files()

        references = load_external_references(self.root)

        self.assertEqual(
            tuple(item.reference_id for item in references),
            ("LINEAR:96b93346-271d-46fc-beab-43ff7e286b5d",),
        )
        self.assertEqual(references[0].reference_kind, AuthorityReferenceKind.LINEAR)


if __name__ == "__main__":
    unittest.main()
