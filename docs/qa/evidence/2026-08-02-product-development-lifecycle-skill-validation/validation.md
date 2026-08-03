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
| Active package hash | `sha256:b810179fdc59fb037091b03502b226d996d9ea128cde7118d60eee46e7e178cf` (25 operational files) |
| Research template hash | `sha256:ea95f88f1bcfc75898f5cb32e7a7151a8c094b9791439f7fa4a0cf1466afb39a` |
| Scope template hash | `sha256:94840a4ce88a5be28f9ba2154a5aa025d1f3923618389fd2648bfeb4ce41bb6e` |
| Design template hash | `sha256:bc7725fcd84c2b52391b3cee4c196f05a8c5c4155fbf8140c82621f3025bb4da` |
| Fixture IDs | `PD-2026-08-LIFECYCLE-FIXTURE-{RESEARCH,SCOPE,DESIGN}` |
| Active fixture contracts | Research r3 `sha256:850dea049c234d05bc54493ee5c6adde18c15f438a27d1c1cfba7bbc953042c1`; Scope r1 `sha256:c36b663f358c3b23170b2a455274d70c2035afa79eb0f860c6cf628b27afef58`; Design r2 `sha256:30b689731623644dc2a19873418f25fa425b56c28930e3a67af52661a8257224` |

## Exact command evidence

The following commands were run from the repository root at commit
`7585fa37091951e07c41634956b1efa8309d0338`. The pre-evidence complete suite
ran 105 tests in 87.774 seconds; the post-evidence read-only rerun ran all
105 tests in 83.352 seconds.

| Command | Exit | Result |
| --- | ---: | --- |
| `python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_*.py' -v` | 0 | post-evidence: `Ran 105 tests in 83.352s` / `OK` |
| `python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py package --check` | 0 | `package: success`; package ready |
| `python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check --initiative docs/product-development/lifecycle-fixture` | 0 | `check: success`; documents valid |
| `python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py consume docs/product-development/lifecycle-fixture/design.md --json` | 1 | Expected fresh-drift result; exact JSON below |
| `python3 scripts/ambitions-canon.py check` | 0 | 65 documents, 460 requirements, 47 UX screens, 39 visual contracts, 16 local links, 68 JSON files |
| `git diff --check` | 0 | no output |

The current standalone Design consume result is intentionally not a pass:

```json
{"command":"consume","status":"failure","document":{"path":"docs/product-development/lifecycle-fixture/design.md","document_id":"PD-2026-08-LIFECYCLE-FIXTURE-DESIGN","revision":2,"contract_hash":"sha256:30b689731623644dc2a19873418f25fa425b56c28930e3a67af52661a8257224","verdict":"needs-revision","relevant_paths":["docs/product-development/lifecycle-fixture/scope.md"]},"changes":[],"diagnostics":[{"code":"semantic-review-required","message":"Relevant repository drift requires one assessment per path","path":null,"section":null,"identifier":null,"remediation":null}],"next_action":"revision"}
```

It detects current Scope drift and does not replay the committed Consumer
event. That event accepted the exact nonmaterial Scope assessment before it
transitioned Design r2 to `passed`; therefore the prior acceptance proves the
state transition, but does not make a later fresh `consume` invocation pass.
No fixture state was changed to suppress this result.

## Read-only stability

After this evidence was written, all regular files under the package,
fixture, and this evidence directory were SHA-256 hashed in sorted path order
and `git status --porcelain` was captured. The full command set above was
rerun, including the expected nonzero standalone consume. The package,
fixture, and evidence hashes were identical before and after the rerun, and
the porcelain status was identical: only this untracked validation evidence
was present. The test suite itself includes
`CliTests.test_read_only_commands_preserve_all_files_and_status_on_success_and_failure`.

## Specification coverage

| Specification area | Implementation / evidence | Focused coverage |
| --- | --- | --- |
| Package identity | `package-manifest.json`, `package_identity.py` | `PackageIdentityTests.test_manifest_bytes_are_canonical_and_package_hash_is_prefixed_sha256` |
| ChatGPT deployment | `fixture-provenance.md`, tracked r2 raw review JSON | `LifecycleAcceptanceTests.test_complete_research_scope_design_chain_and_drift_contract` |
| Producer | `references/producer-contract.md`, `transitions.py` | `TransitionTests.test_new_scope_and_design_require_committed_passed_upstream` |
| Content review | `references/*-review-rubric.md`, `transitions.py` | `TransitionTests.test_review_lanes_advance_only_with_exact_committed_revision_and_hash` |
| Consumer | `references/consumer-contract.md`, `cli.py` | `ConsumptionTests.test_consumer_pass_requires_exact_nonmaterial_drift_assessments` |
| Canonical persistence | `documents.py`, `repository.py` | `DocumentIOTests.test_atomic_write_preserves_target_when_candidate_is_invalid` |
| Typed inputs | `models.py`, `documents.py` | `DocumentIOTests.test_rejects_boolean_integer_fields` |
| State machine | `transitions.py` | `StructureAndFreshnessTests.test_state_review_matrix_accepts_only_reachable_lane_pairs` |
| Contract hash | `hashing.py` | `ContractHashTests.test_contract_hash_matches_literal_golden_projection` |
| Handoff summary | template profiles, `validation.py` | `StructureAndFreshnessTests.test_rejects_handoff_summary_over_1200_words` |
| Freshness | `validation.py`, `models.py` | `StructureAndFreshnessTests.test_derives_exact_sorted_freshness_union_and_rejects_weakening` |
| Research | `assets/templates/v1/research.md`, fixture `research.md` | `SourceAndTraceabilityTests.test_research_findings_resolve_to_source_ledger` |
| Scope | `assets/templates/v1/scope.md`, fixture `scope.md` | `SourceAndTraceabilityTests.test_scope_requirements_map_to_authority_acceptance_and_detailed_canon_delta` |
| Design | `assets/templates/v1/design.md`, fixture `design.md` | `SourceAndTraceabilityTests.test_design_covers_requirements_acceptance_decisions_seams_and_verification` |
| `consume` | `cli.py`, `transitions.py`, `repository.py` | `ConsumptionTests.test_consume_revalidates_committed_current_upstream_body` |
| CLI | `scripts/ambitions_product_docs.py`, `cli.py` | `CliTests.test_parser_accepts_every_exact_command_shape` |
| Canon reconciliation | `cli.py`, `transitions.py` | `CliTests.test_reconcile_rejects_empty_supplied_options_from_the_other_mode` |
| Evolution / historical verification | `package_identity.py`, `repository.py` | `PackageIdentityTests.test_historical_verification_accepts_a_baseline_package_after_active_package_changes` |
| Pressure tests | `post-skill.md`, `cross-product.md` | `LifecycleAcceptanceTests.test_complete_research_scope_design_chain_and_drift_contract` |
| Security and privacy | `repository.py`, `documents.py`, package manifest | `PackageIdentityTests.test_package_identity_rejects_dangling_operational_root_symlink`; `DocumentIOTests.test_rejects_absolute_and_traversal_binding_paths` |
| Acceptance | installed package plus fixture | `LifecycleAcceptanceTests.test_complete_research_scope_design_chain_and_drift_contract`; `LifecycleAcceptanceTests.test_installed_loader_rejects_corrupted_transition_module` |

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
