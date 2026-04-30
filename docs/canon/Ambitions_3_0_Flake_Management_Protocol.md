# Ambitions 3.0 Flake Management Protocol

Status: Active QA governance

## Purpose

Flakes are managed as product risk, not ignored noise. Ambitions must distinguish unstable tooling from real broken user promises before changing implementation or tests.

## Flake Definition

A failure is a flake only when the same code and fixture passes on a narrower rerun or independent evidence shows simulator/tooling instability. A failing test is not a flake just because it is inconvenient.

## Classification Steps

1. Capture the exact command, simulator, destination, and error summary.
2. Identify the test class from `Ambitions_3_0_UI_Test_Contract.md`.
3. Rerun the smallest failing test once when the next attempt is informed.
4. Compare failure location, screenshot/log evidence, and fixture setup.
5. Classify as repo bug, outdated expectation, fixture drift, environment issue, or flake.
6. Record the result with `.codex/templates/flake-report-template.md` when instability remains.

## Quarantine Bar

Quarantine requires:

- Named owner.
- Protected user promise.
- Evidence of nondeterminism.
- Replacement guard or explicit release-risk note.
- Recheck trigger.

## Stop Conditions

Stop and escalate when privacy/trust behavior, shell navigation, destructive persistence, or release claims are implicated. Do not mark a release gate PASS while a relevant flake remains unclassified.
