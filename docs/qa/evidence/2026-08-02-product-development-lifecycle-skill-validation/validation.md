# Product-development lifecycle skill — final validation

## Result

The installed `ambitions-product-development-lifecycle` package is canonical
and the committed synthetic fixture is valid: Research revision 3, Scope
revision 1, and Design revision 2 are all in `passed` state. This Task 11
record is validation evidence only; it changes no package, fixture, workflow,
or canon source.

| Item | Value |
| --- | --- |
| Package identity | `ambitions-product-development-lifecycle` v`1.0.0` |
| Active package hash | `sha256:9c96c984a24886eeb60f06bb931926e38ae8fc2d30dbbb5cd480b4db8b0874dc` (25 operational files) |
| Research template hash | `sha256:ea95f88f1bcfc75898f5cb32e7a7151a8c094b9791439f7fa4a0cf1466afb39a` |
| Scope template hash | `sha256:94840a4ce88a5be28f9ba2154a5aa025d1f3923618389fd2648bfeb4ce41bb6e` |
| Design template hash | `sha256:bc7725fcd84c2b52391b3cee4c196f05a8c5c4155fbf8140c82621f3025bb4da` |
| Fixture IDs | `PD-2026-08-LIFECYCLE-FIXTURE-{RESEARCH,SCOPE,DESIGN}` |
| Active fixture contracts | Research r3 `sha256:850dea049c234d05bc54493ee5c6adde18c15f438a27d1c1cfba7bbc953042c1`; Scope r1 `sha256:c36b663f358c3b23170b2a455274d70c2035afa79eb0f860c6cf628b27afef58`; Design r2 `sha256:30b689731623644dc2a19873418f25fa425b56c28930e3a67af52661a8257224` |

## Exact command evidence

The following commands were run from the repository root at commit
`7c11a85b3cd499ffb2af08abc1939ce95e4fa21d`. The full discovery command uses
only temporary-directory and bytecode controls to prevent host Git background
maintenance from racing test-repository cleanup; it does not change test or
package behavior.

| Command | Exit | Result |
| --- | ---: | --- |
| `env TMPDIR=/tmp PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_*.py' -v` | 0 | `Ran 105 tests in 67.590s` / `OK` |
| `python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py package --check` | 0 | `package: success`; package ready |
| `python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check --initiative docs/product-development/lifecycle-fixture` | 0 | `check: success`; documents valid |
| `python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py consume docs/product-development/lifecycle-fixture/design.md --json` | 0 | `status: success`; `verdict: pass`; exact JSON below |
| `python3 scripts/ambitions-canon.py check` | 0 | 65 documents, 460 requirements, 47 UX screens, 39 visual contracts, 16 local links, 68 JSON files |
| `git diff --check` | 0 | no output |

The current standalone Design consume result passes. Its stored Consumer PASS
contains exactly the nonmaterial Scope assessment that matched drift at the
review commit; later fresh semantic owner drift is still rejected by the new
focused regression test.

```json
{"command":"consume","status":"success","document":{"path":"docs/product-development/lifecycle-fixture/design.md","document_id":"PD-2026-08-LIFECYCLE-FIXTURE-DESIGN","revision":2,"contract_hash":"sha256:30b689731623644dc2a19873418f25fa425b56c28930e3a67af52661a8257224","verdict":"pass","relevant_paths":[],"unrelated_paths":[".agents/skills/ambitions-product-development-lifecycle/package-manifest.json",".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py",".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py",".agents/skills/ambitions-product-development-lifecycle/tests/support.py",".agents/skills/ambitions-product-development-lifecycle/tests/test_consume.py","docs/product-development/lifecycle-fixture/design.md","docs/product-development/lifecycle-fixture/research.md","docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/cross-product.md","docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/fixture-provenance.md","docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/post-skill.md","docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/raw-content-review-replay-addendum.md","docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/raw-content-reviews/design-revision-2.json","docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/raw-content-reviews/design.json","docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/raw-content-reviews/research-revision-3.json","docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/raw-content-reviews/scope.json","docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/validation.md"]},"changes":[],"diagnostics":[],"next_action":"canon-reconciliation"}
```

The consumer checks the active revision/hash-bound review event at the commit
that recorded it. It accepts the event only when its nonmaterial assessments
exactly cover semantic owner drift through that commit, then checks for fresh
semantic owner drift afterward. Historical and active package identity continue
to be verified independently; package evolution is not misclassified as
product-owner drift. No fixture state was changed to suppress a diagnostic.

## Read-only stability

Before the final evidence update, lifecycle files were SHA-256 hashed in sorted
path order and `git status --porcelain` was captured. The full command set was
rerun after the implementation commits. The package, fixture, and evidence
hashes were unchanged by the read-only commands, and the porcelain status was
unchanged. The test suite itself includes
`CliTests.test_read_only_commands_preserve_all_files_and_status_on_success_and_failure`.

## Specification coverage

| Specification area | Implementation / evidence | Focused coverage |
| --- | --- | --- |
| Package identity | `.agents/skills/ambitions-product-development-lifecycle/package-manifest.json`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/package_identity.py` | `PackageIdentityTests.test_manifest_bytes_are_canonical_and_package_hash_is_prefixed_sha256` |
| ChatGPT deployment | `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/fixture-provenance.md`; `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/raw-content-reviews/design-revision-2.json` | `LifecycleAcceptanceTests.test_complete_research_scope_design_chain_and_drift_contract` |
| Producer | `.agents/skills/ambitions-product-development-lifecycle/references/producer-contract.md`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py` | `TransitionTests.test_new_scope_and_design_require_committed_passed_upstream` |
| Content review | `.agents/skills/ambitions-product-development-lifecycle/references/research-review-rubric.md`; `.agents/skills/ambitions-product-development-lifecycle/references/scope-review-rubric.md`; `.agents/skills/ambitions-product-development-lifecycle/references/design-review-rubric.md`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py` | `TransitionTests.test_review_lanes_advance_only_with_exact_committed_revision_and_hash` |
| Consumer | `.agents/skills/ambitions-product-development-lifecycle/references/consumer-contract.md`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py` | `ConsumptionTests.test_consumer_pass_requires_exact_nonmaterial_drift_assessments` |
| Canonical persistence | `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/documents.py`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py` | `DocumentIOTests.test_atomic_write_preserves_target_when_candidate_is_invalid` |
| Typed inputs | `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/models.py`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/documents.py` | `DocumentIOTests.test_rejects_boolean_integer_fields` |
| State machine | `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py` | `StructureAndFreshnessTests.test_state_review_matrix_accepts_only_reachable_lane_pairs` |
| Hash | `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/hashing.py`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py` | `ContractHashTests.test_contract_hash_matches_literal_golden_projection` |
| Handoff summary | `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/research.md`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py` | `StructureAndFreshnessTests.test_rejects_handoff_summary_over_1200_words` |
| Freshness | `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/models.py` | `StructureAndFreshnessTests.test_derives_exact_sorted_freshness_union_and_rejects_weakening` |
| Research | `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/research.md`; `docs/product-development/lifecycle-fixture/research.md` | `SourceAndTraceabilityTests.test_research_findings_resolve_to_source_ledger` |
| Scope | `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/scope.md`; `docs/product-development/lifecycle-fixture/scope.md` | `SourceAndTraceabilityTests.test_scope_requirements_map_to_authority_acceptance_and_detailed_canon_delta` |
| Design | `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/design.md`; `docs/product-development/lifecycle-fixture/design.md` | `SourceAndTraceabilityTests.test_design_covers_requirements_acceptance_decisions_seams_and_verification` |
| `consume` | `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/cli.py`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py` | `ConsumptionTests.test_consume_revalidates_committed_current_upstream_body` |
| CLI | `.agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/cli.py` | `CliTests.test_parser_accepts_every_exact_command_shape` |
| Canon reconciliation | `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/cli.py`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py` | `CliTests.test_reconcile_rejects_empty_supplied_options_from_the_other_mode` |
| Evolution | `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/package_identity.py`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py` | `PackageIdentityTests.test_historical_verification_accepts_a_baseline_package_after_active_package_changes` |
| Pressure tests | `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/post-skill.md`; `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/cross-product.md` | `LifecycleAcceptanceTests.test_complete_research_scope_design_chain_and_drift_contract` |
| Security/privacy | `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py`; `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/documents.py`; `.agents/skills/ambitions-product-development-lifecycle/package-manifest.json` | `PackageIdentityTests.test_package_identity_rejects_a_dangling_operational_root_symlink`; `DocumentIOTests.test_rejects_absolute_and_traversal_binding_paths` |
| Acceptance | `.agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py`; `docs/product-development/lifecycle-fixture/design.md` | `LifecycleAcceptanceTests.test_complete_research_scope_design_chain_and_drift_contract`; `LifecycleAcceptanceTests.test_installed_loader_rejects_corrupted_transition_module` |

## Draft-marker scan

The exact Task 11 marker command was run against the four required targets;
the command text is retained only in the ignored Task 11 report so the scan
does not manufacture a match in this user-facing evidence file.

Result: exit 1 with no output. No passed fixture/evidence or operational
instruction has an unresolved marker. Versioned blank templates are excluded
because their sentinels are intentional seal blockers; tests and validator
source are excluded because they contain rejection literals.

## Proof ceiling and handoff

Fixture proof covers package identity, creation, committed handoff, sealing,
reviews, traceability, drift, historical verification, and
ChatGPT-to-Codex consumption. It does not prove every future initiative or
replace product, code, runtime, accessibility, privacy, performance, or
release verification.

Follow-up adoption work is to apply the package to a real initiative and run
the separately appropriate product and engineering validation. This task did
not change the Code Quality workflow or branch-protection configuration.
