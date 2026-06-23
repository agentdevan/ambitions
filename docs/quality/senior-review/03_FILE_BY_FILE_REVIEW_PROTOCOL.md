# File-by-File Review Protocol

Status: Active SCG review authority  
Scope: How SCG audits review Ambitions files without false senior-readiness claims  
Issue: AMB-1284 / SCG-001  

This protocol defines repeatable senior review mechanics. It is not an instruction to bulk-edit the repo.

## 1. Review Inputs

For each file or bounded file group, collect:

- path
- canonical owner from Final Architecture Tree
- current build inclusion
- product surface, runtime layer, or governance layer
- active Linear issue
- related tests, scripts, fixtures, and proof artifacts
- current known-issues rows
- current diff against baseline when relevant

## 2. Review Order

1. Confirm the file is in scope for the issue.
2. Confirm canonical owner and whether the current path is debt.
3. Classify the file: production source, test, script, docs, schema, resource, generated, or ignored local output.
4. Identify user-facing behavior, local data flow, mutation behavior, accessibility surface, and privacy boundary.
5. Check claims and tests against actual behavior.
6. Record findings using `senior-review-finding.schema.json`.
7. Record the file decision using `file-review.schema.json`.

## 3. Required Questions

### Ownership

- Does this file live under the canonical owner?
- If not, is it untouched compatibility debt or a scoped migration target?
- Does it create duplicate ownership for shell, Capture, Search, Motion, Proof, Source, Privacy, History, Receipts, or surface primary objects?

### Product Behavior

- Does it preserve Today / Goals / Time / You as the only persistent surfaces?
- Does it keep Capture global and Motion behavioral?
- Does it use locked language: Start here, Recommended step, Step, Start now, Open step?
- Does it avoid generic task, dashboard, calendar-clone-only, chatbot, AI wrapper, streak, score, or shame framing?

### Runtime

- Are mutations real, visible, accessible, and reversible where scoped?
- Are placeholders, fixtures, preview state, and unavailable states clearly separated from production behavior?
- Is low-context or unknown state represented honestly?

### Local-First And Privacy

- Does private life data stay local?
- Are network paths public/reference/account-only where scoped?
- Is R2 kept away from the private life graph?
- Are account paths optional for offline core value?

### Accessibility And Interaction

- Are labels, values, traits, actions, focus order, and state changes sufficient?
- Does Dynamic Type remain usable?
- Are Reduce Motion, Reduce Transparency, and High Contrast considered?
- Are safe areas, keyboard behavior, route depth, and dock visibility correct where visible behavior changes?

### Proof

- What exact command, screenshot, device proof, test, or source evidence supports the decision?
- What proof is missing?
- Is the status limited to the proof actually produced?

## 4. Decision Rules

Use these decisions:

- `accept`: no blocking findings and proof matches the claim
- `accept-with-followup`: no Red blocker, but Yellow debt is recorded with owner and next proof
- `request-changes`: blocks closeout
- `escalate`: needs product owner, architecture owner, privacy/legal owner, or release owner decision

Do not close a file as accepted because it was out of time, hard to inspect, previously accepted, or covered by stale reports.

## 5. Output Artifacts

A complete SCG review packet contains:

- audit report JSON matching `senior-audit-report.schema.json`
- one or more finding records matching `senior-review-finding.schema.json`
- file review records matching `file-review.schema.json`
- owner mapping references from `OWNERSHIP_MAP.yaml`
- exact validation commands and exit codes
- no-claim statement for unproven readiness
