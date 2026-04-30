# Doc QA Pack

## Purpose

Validate Ambitions 3.0 documentation changes with stale-guidance, deprecated-language, Markdown lint, and advisory link checks.

## Commands

```bash
scripts/run-doc-qa.sh || true
DOC_QA_STRICT=1 scripts/run-doc-qa.sh || true
```

## Expected Evidence

- Stale-guidance scan result.
- Deprecated-language scan result.
- `markdownlint-cli2` result.
- `lychee` result and strict/advisory mode.
- Log directory under `docs/audits/doc-qa/`.

## Failure Interpretation

- Stale active read-order guidance is a blocking governance issue.
- Deprecated language may be historical/supporting or active debt; classify it before editing.
- Markdown lint is advisory until the docs backlog is clean.
- Link failures are advisory by default because external links and networks are flaky.

## Escalation Rules

Use `DOC_QA_STRICT=1` only for deliberate docs gates. Do not broaden into product rewrite to silence historical lint.

## Focused Vs Full Validation

Focused validation is enough for docs-only changes. Full native build/test is required only when docs changes alter project/build scripts or release claims depend on native evidence.
