# Source Atlas Public R2 Gateway Train 82 Closeout

Status: Source Green for public gateway allowlist compiler and deployed gateway verification / Yellow overall Source Atlas

Source Atlas status ceiling: Yellow overall Source Atlas; this train proves the gateway allowlist compiler and deployed public gateway behavior only.

## Scope Completed

- Added deterministic Foundry compiler for public Worker gateway allowlist generation from validated production/stable remote R2 publisher reports.
- Moved Worker allowed object keys from hand-maintained inline source to `allowed-object-keys.generated.js`.
- Generated 65 public object keys from 13 production/stable remote R2 publisher reports.
- Deployed Worker version `22a5b2fb-edaf-4672-bb95-d390810e0fba`.
- Verified all 65 generated keys with live `HEAD` requests.
- Verified 39 current/manifest/pack `GET` responses against publisher SHA-256 evidence.
- Verified private/query-shaped requests remain blocked with 404.

## Files Changed

- `tools/source-atlas/foundry/r2_public_gateway_allowlist.py`
- `tools/source-atlas/foundry/tests/test_r2_public_gateway_allowlist_train_82.py`
- `tools/source-atlas/foundry/cli.py`
- `tools/source-atlas/r2-public-gateway/src/worker.js`
- `tools/source-atlas/r2-public-gateway/src/allowed-object-keys.generated.js`
- `tools/source-atlas/generated/r2-public-gateway/train-82-allowlist/`
- `docs/qa/source-atlas/r2/source-atlas-public-gateway-allowlist-train-82.*`
- `docs/qa/source-atlas/r2/source-atlas-public-gateway-live-verification-train-82.json`
- `docs/qa/source-atlas/r2/source-atlas-public-gateway-train-82-closeout.*`

Dirty worktree caveat: `tools/source-atlas/foundry/cli.py` and many Source Atlas/native paths were already dirty from prior trains. Train 82 additions inside `cli.py` are limited to `r2-public-gateway-allowlist` imports, parser registration, and command dispatch.

## Product Law Preserved

- R2 remains public/reference/freshness infrastructure only.
- The generated gateway allowlist contains public Source Atlas object keys only.
- No private user context, goal text, captures, schedules, proof, receipts, account IDs, device IDs, or private graph data is introduced.
- Source Atlas/R2 does not generate final user plans, schedules, Steps, or personalized paths.

## Validation Run

- `python3 -m pytest tools/source-atlas/foundry/tests/test_r2_public_gateway_allowlist_train_82.py` -> 4 passed.
- `python3 -m py_compile tools/source-atlas/foundry/r2_public_gateway_allowlist.py tools/source-atlas/foundry/cli.py` -> passed.
- `python3 tools/source-atlas/source-atlas-foundry.py r2-public-gateway-allowlist ...` -> valid true; 13 publisher reports; 65 allowed object keys.
- `node --check tools/source-atlas/r2-public-gateway/src/worker.js` -> passed.
- `node --check tools/source-atlas/r2-public-gateway/src/allowed-object-keys.generated.js` -> passed.
- JSON validation for generated allowlist and QA evidence -> passed.
- `wrangler deploy --config tools/source-atlas/r2-public-gateway/wrangler.jsonc` -> deployed Worker version `22a5b2fb-edaf-4672-bb95-d390810e0fba`.
- Live gateway verifier -> 65/65 `HEAD` checks passed; 39/39 `GET` SHA-256 checks passed; blocked requests returned 404.
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests` -> 329 passed.
- `python3 scripts/source-atlas-boundary-audit.py` -> PASS (40 targets).
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py` -> PASS.
- `python3 scripts/ambitions-green-standard-audit.py` -> GREEN.
- `python3 scripts/ambitions-local-first-boundary-scan.py` -> GREEN.
- `git diff --check` -> passed.

## Validation Not Run

- Swift/Xcode build-for-testing was not run for Train 82 because this train changed Source Atlas Python tooling, Worker JavaScript, generated R2 gateway artifacts, and QA evidence only; no Train 82 Swift/native source was edited.

## Proof Artifacts

- `tools/source-atlas/generated/r2-public-gateway/train-82-allowlist/public-gateway-allowlist.json`
- `tools/source-atlas/generated/r2-public-gateway/train-82-allowlist/public-gateway-allowlist-report.json`
- `tools/source-atlas/generated/r2-public-gateway/train-82-allowlist/closeout.md`
- `tools/source-atlas/r2-public-gateway/src/allowed-object-keys.generated.js`
- `docs/qa/source-atlas/r2/source-atlas-public-gateway-allowlist-train-82.json`
- `docs/qa/source-atlas/r2/source-atlas-public-gateway-allowlist-train-82.md`
- `docs/qa/source-atlas/r2/source-atlas-public-gateway-live-verification-train-82.json`

## Additional Proof

R2 request privacy proof: Generated keys are derived only from production/stable remote R2 publisher reports that passed public-reference request/privacy gates; the compiler re-runs object-key and artifact scans.

No private graph egress proof: Private object-key segments block generation; live query/private path checks returned 404.

License/terms proof: Inherited from validated production publisher reports; no legal approval is upgraded by this train.

Restricted-source exclusion proof: Inherited from publisher reports; the allowlist compiler does not add source or claim data.

Provenance completeness proof: Inherited from upstream pack manifests and publisher reports.

Freshness/revocation proof: Generated allowlist includes current, LKG, revocations, manifest, and pack keys only after readback evidence passes.

LKG/rollback proof: Inherited from production publisher reports; this compiler does not publish or roll back R2 objects.

Native offline/no-account proof: Not claimed by this tooling train.

## Production Non-Claims

- Not full Source Atlas Green.
- Not literal universal coverage.
- Not outside legal approval.
- Not App Store/TestFlight readiness.
- Not physical-device proof.
- Not final personalized paths, schedules, Steps, or plans from Source Atlas/R2.
- Not a claim that all future domain packs are automatically production-ready.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: none in app source; tooling/evidence only under `tools/source-atlas`.
- Non-canonical owners touched: none.
- Files moved or created: Foundry allowlist compiler, generated Worker allowlist module, focused tests, generated gateway evidence artifacts.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt remaining: overall Source Atlas still needs broader autonomous domain publishing/runtime/release proof beyond this gateway compiler.
- Next repair train if debt remains: expand autonomous production pack publication to direct-source-approved domains and keep native live refresh proof current.
- No equivalent folder/path interpretation was used.

## Known Risks

- Overall Source Atlas remains broader than this gateway automation proof.
- The repo worktree contains many pre-existing untracked/dirty Source Atlas and native files from earlier trains.
- Generated allowlist must be regenerated after each future production/stable publisher report before Worker deployment.

## Rollback Plan

- Revert the `r2_public_gateway_allowlist` module, focused tests, CLI command additions, generated allowlist module, Worker import, generated artifacts, and QA evidence.
- Redeploy the previous Worker version or restore the prior static allowlist source if needed.
- R2 objects are not modified by this train; no R2 object rollback is required.
