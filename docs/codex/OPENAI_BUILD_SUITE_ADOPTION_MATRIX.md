# OpenAI Build Suite Adoption Matrix

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-81554362, AMB28-stale_or_unknown_active_status-45753994

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, status-expedite
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

| Capability | OpenAI surface | Ambitions use | repo path | runtime allowed? | risk | status |
|---|---|---|---|---|---|---|
| Codex multi-agent build system | Codex/Agents SDK orchestration, prompt tools | bounded batch execution coordination | docs/codex/CODEX_MULTI_AGENT_BUILD_SYSTEM.md, tools/openai/config/codex_agent_roles.json | No | Low | Planned |
| Repo intelligence / File Search | File Search concepts for local manifest + vector-ready package design | local manifest generation and repo query stubs | tools/openai/repo_brain | No | Medium | Planned |
| Eval / QA | Evals API simulation scaffolding | deterministic local validation packet checks before any real provider wiring | tools/openai/evals | No | Low | Planned |
| Prompt repair | Prompt repair layer and queue consistency helpers | clean prompt audit consistency, stale state checks, local repair utility | tools/openai/prompt_repair, scripts/ambitions-prompt-queue-consistency.py | No | Low | Planned |
| Batch report generation | Local JSON summaries and status extraction | report parsing and local classification for closeout packets | tools/openai/batch_report | No | Low | Planned |
| Visual critique | local image check + rubric validator | local snapshot checklist validator for launch-ready visual packets | tools/openai/visual_critique | No | Medium | Planned |
| Launch documentation drafting | report synthesizer + draft packet emitter | local synthesis from audit/proof docs | tools/openai/launch_docs | No | Medium | Planned |
| Optional future user-controlled cloud assist | optional Agents tools integration | manual opt-in review mode outside core runtime | future docs only | Opt-in only | High | Not started |
| Forbidden core runtime intelligence | OpenAI runtime in app domain | forbidden for this batch | Native/Ambitions/** | No | Red | Blocked by policy |

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
