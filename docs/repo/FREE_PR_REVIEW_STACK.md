# Free PR Review Stack

Status: repo-governance documentation. This stack uses GitHub Actions plus local/open-source tools only. It does not introduce paid AI review, paid SaaS quality gates, GitHub-hosted macOS dependency, or private GitHub Code Security dependency.

## What Runs

- `repo-hygiene`: runs whitespace/status checks and `scripts/ci/ambitions-pr-hygiene.sh` for conflict markers, accidental generated artifacts, simulator logs outside approved proof paths, and committed dependency folders.
- `ambitions-law-audit`: runs existing Ambitions product-law and claim-boundary scripts plus `scripts/ci/ambitions-no-weak-implementation-scan.py`.
- `remediation-governance-check`: runs the AMB-1658/AMB-1680 guard, including Source Atlas new-file allowlist enforcement and the guard self-test.
- `source-atlas-boundary-audit`: runs Source Atlas privacy-boundary and no-private-egress audits.
- `swiftlint`: runs SwiftLint in a local container on Ubuntu with the repo-local `.swiftlint.yml`.
- `semgrep-local`: runs repo-local Semgrep rules from `.semgrep/ambitions-source-atlas.yml`.
- `shellcheck`: runs ShellCheck over `scripts/**/*.sh`.
- `workflow-lint`: runs actionlint over `.github/workflows/**`.
- `docs-lint`: runs markdownlint-cli2 and yamllint with repo-local configs.
- `secrets-scan`: runs repo-local Gitleaks through `scripts/ci/ambitions-gitleaks-scan.sh` with `.gitleaks.toml`.
- `python-tests`: runs Source Atlas Python tests.
- `xcode-build-for-testing`: runs `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard` on the self-hosted `Ambitions-XCode26` runner for Native/project/package changes and manual dispatch.

## Free And Local

These checks run locally inside GitHub Actions runners or on a developer machine:

- SwiftLint
- Semgrep local CLI with repo-local rules
- ShellCheck
- actionlint
- markdownlint-cli2
- yamllint
- Gitleaks, scoped to current repo material and PR-introduced commits
- Python stdlib and pytest
- Existing Ambitions scripts
- New repo-local Ambitions CI scripts

No findings are uploaded to Semgrep Cloud, SonarCloud, Qodo, Copilot Code Review, or any paid hosted review service by this stack.

## GitHub Actions Usage

The non-Xcode workflow jobs run on Ubuntu GitHub-hosted runners. The Xcode build-for-testing job uses the repo owner's self-hosted macOS/Xcode runner label, `Ambitions-XCode26`; it does not use GitHub-hosted macOS runners. The Xcode job skips itself for docs/tooling-only PRs unless manually dispatched.

The secrets scan does not run an unbounded full-history scan on every local run. It scans:

- current tracked and nonignored new repo material from a temporary copy
- commits introduced after the PR/base merge-base

This keeps local validation practical while still blocking current or newly introduced secrets. Ignored local caches, generated build output, and historical artifacts are not treated as PR material by this gate.

## Intentionally Excluded

- GitHub Copilot Code Review
- Qodo
- SonarQube Cloud paid gates
- GitHub CodeQL/code scanning as a private-repo dependency
- GitHub-hosted macOS runners
- Any new paid account, hosted token, subscription, or SaaS quality service

## Run Local Review

Run the local subset from the repo root:

```bash
bash scripts/ci/ambitions-pr-review-local.sh
```

Collect all failures instead of failing fast:

```bash
bash scripts/ci/ambitions-pr-review-local.sh --continue
```

The local script never uploads results externally.

## Interpreting Failures

- Hygiene failures usually mean the PR contains whitespace, conflict markers, generated files, large build output, simulator logs in the wrong place, or accidental dependency folders.
- Ambitions law failures mean the change may violate product law, proof honesty, or weak-implementation rules.
- Remediation governance failures mean the change may violate architecture simplification rules, including new Source Atlas files without exact ADR allowlist coverage.
- Source Atlas failures mean public/reference/freshness infrastructure appears to contain private runtime context or private egress fields.
- Linter failures should be fixed narrowly in the touched files unless a legacy repo-wide issue is explicitly accepted as Yellow.
- Secrets findings must be treated as Red until proven synthetic and allowlisted narrowly. Gitleaks timeouts also fail the check.
- Xcode failures block source confidence for Native/project/package changes but do not create a release claim either way.

## What Blocks Merge

On Path A branch protection, the required status checks block merge directly. On Path B, maintain the same standard manually: do not squash merge unless the visible check suite passes or the PR records an explicit Yellow/Red closeout with exact not-run or failed validation.

## Current Local Repair Evidence

Local working-tree repair validation on 2026-06-26:

- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests -vv`: 22 passed.
- `bash scripts/ci/ambitions-gitleaks-scan.sh`: passed; scanned current repo material and introduced commit range with no leaks.
- `actionlint`: passed.
- `find scripts -name '*.sh' -print0 | xargs -0 shellcheck`: passed.
- `bash scripts/ci/ambitions-pr-review-local.sh --continue`: passed 16 checks, failed 0.

Xcode build-for-testing was not executed in this local repair pass. The workflow constrains that job to `[self-hosted, Ambitions-XCode26]` and gates it to Native/project/package changes or `workflow_dispatch`; it does not use GitHub-hosted macOS runners.

## Ambitions Status Meaning

- Green: the scoped governance stack exists, relevant local checks passed, no paid services were introduced, and the PR can block weak changes within the covered scope.
- Yellow: the stack exists but some local tools, macOS/Xcode validation, or legacy repo-wide lint cleanup remains unverified or capped.
- Red: an added check is inert, depends on paid SaaS, weakens existing Ambitions validation, leaks private Source Atlas data, or hides validation failures.
