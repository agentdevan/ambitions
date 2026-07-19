# Fake Seniority Anti-Gaming Rules

Status: Active SCG review authority  
Scope: Rules that prevent superficial senior-code claims and false Green closeouts  
Issue: AMB-1284 / SCG-001  

These rules exist because Ambitions quality depends on proof, not senior-sounding artifacts.

## 1. Forbidden Green Patterns

Do not claim Green from:

- file existence
- type names matching canon
- comments that describe future behavior
- source string scans alone
- old screenshots or old proof packets
- generated reports without current command output
- tests that only assert forbidden strings are absent
- scripts that do not fail on real violations
- screenshots that were not visually evaluated
- paths that are merely "equivalent" to canonical owners
- Codex self-certification of Visual Green or Release Green

## 2. Required Evidence Alignment

The claim must match the evidence:

| Evidence | Maximum honest claim |
| --- | --- |
| Required files exist and parse | Infrastructure Source Green |
| Source compiles and focused tests pass | Source Green for scoped behavior |
| Local mutation tests pass | Runtime Green for tested mutation only |
| UI test with hierarchy/frame assertions passes | Interaction Green for tested path |
| Simulator screenshot reviewed | Ready for Visual Review or Yellow proof |
| Physical device proof plus independent review | Candidate Visual Green |
| Build, device, accessibility, privacy, owner, and release proof complete | Candidate Release Green |

## 3. Anti-Gaming Checks

Every SCG closeout must answer:

- What exact claim is being made?
- What current evidence supports it?
- What evidence is missing?
- What readiness is explicitly not claimed?
- Did any test become weaker?
- Did any production path change outside scope?
- Did any issue status move ahead of proof?
- Did any known issue get hidden by wording instead of fixed?

## 4. Audit Script Requirements

Starter scripts are not placeholders if they:

- parse real files
- fail on missing required infrastructure
- fail on malformed schemas
- fail on missing baseline SHA
- fail on forbidden production diffs for infrastructure-only issues
- emit machine-readable output
- return non-zero on Red

Scripts are placeholder-only if they only print instructions, always return success, or ignore the repo state.

## 5. Review Integrity

SCG findings must not be downgraded because:

- the failure is old
- the file was already touched by another train
- the fix is inconvenient
- the issue would otherwise close
- the product looks better than before
- a screenshot path exists
- a Linear comment claims completion

If a finding is out of scope, record it as Yellow with owner and next repair train. Do not erase it.
