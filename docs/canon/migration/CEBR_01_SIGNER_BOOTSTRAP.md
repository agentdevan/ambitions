# CEBR-01 signed-platform bootstrap record

Status: frozen candidate pending exact external owner binding and high-risk
review

Decision ID: `OWNER-CEBR-SIGNER-BOOTSTRAP-2026-07-19T141500Z`

Approval docket: <https://github.com/agentdevan/ambitions/issues/33>

## Problem

The active authorization verifier contains public RSA anchors but no
corresponding private signer exists in repository, GitHub, or expected local
custody. Approval-required tasks therefore stop at `AUTH_APPROVAL_MISSING` even
when owner intent is explicit. The ordinary gate cannot authorize its own key
rotation, so this transition must be one-use, externally bound, and narrower
than the later CEBR canon amendment.

## Installed boundary

The candidate installs:

- `platform-approval-v2`, an approval-only RSA-3072 public anchor;
- `trusted-ci-validation-v2`, an RSA-3072 event/validation public anchor;
- GitHub environment `Ambitions Canon Authorization`, restricted to `main` and
  requiring reviewer `agentdevan` (`529921`);
- environment secrets `AMBITIONS_CANON_APPROVAL_PRIVATE_KEY` and
  `AMBITIONS_CANON_ATTESTATION_PRIVATE_KEY`;
- a manually dispatched, base-owned workflow that never exposes either key to
  candidate code;
- verifier-compatible signing helpers, exact command runner, full task-start
  and finalization artifact construction, and negative/positive tests;
- the pre-existing skill-conformance and task-pack recovery repairs; and
- an exact CEBR task rule which remains non-authorizing until the signed
  workflow produces a matching event and approval for a real pull request.

Unprivileged matrix jobs execute exact commands from the base-owned validation
manifest against the candidate checkout. Secret-bearing jobs check out only
the trusted base, bind immutable GitHub PR/run/job metadata, hash successful
GitHub job logs, and sign only the closed event, approval, and validation
contracts. Candidate code is never executed in a signer-bearing job.

## External bootstrap condition

Before direct integration, an authenticated owner comment in issue `#33` must
name the exact candidate commit, tree, patch SHA-256, and sorted path-manifest
SHA-256. One exact high-risk review must report zero Critical and Important
findings for that same candidate. The comment and review are external inputs;
this record does not manufacture or imply them.

## Validation floor

The frozen candidate must keep all of these Green:

```text
actionlint .github/workflows/ambitions-canon-authorization.yml
python3 -m unittest -v tests.canon.test_platform_signing
python3 scripts/ambitions-canon.py skill-conformance --check
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py build --check
python3 scripts/ambitions-canon.py authority-sprawl --check
git diff --check
```

The signer test must prove, with fresh non-test RSA keys in a synthetic exact PR
range: signed event, signed approval, `task start`, per-command signed Green
validations, and `task finalize` with exact-range merge authorization. Mutation,
wrong-key, and wrong-purpose cases must fail closed.

## Rollback and claim ceiling

Rollback is `git revert` of the single bootstrap commit plus removal of the
`Ambitions Canon Authorization` environment secrets. The retained Keychain
copies are recovery custody only and never confer repository authority.

Allowed claim after exact integration: protected owner-reviewed platform
signing capability installed for the frozen contracts. Branch protection,
required-check enforcement, CEBR canon integration, product/runtime behavior,
visual/accessibility/device proof, patentability, TestFlight/App Store, and
release readiness remain unproven.
