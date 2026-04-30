# Ambitions 3.0 Run State Protocol

Status: Active Codex run-control protocol

## Purpose

Long Codex runs must be resumable from repo files, not only from chat memory.
Run state records the active task, selected context, decisions, validation,
risks, and next checkpoint.

## Required Fields

- current task
- task size
- active mode
- active primitive
- active surface
- active context pack
- active skill
- active operation
- active validation pack
- docs read
- files allowed
- files forbidden
- files touched
- decisions made
- tests run
- failures
- open risks
- next phase
- stop conditions
- last checkpoint

## Rules

- At the start of every phase, re-read `.codex/reports/current-run-state.md`
  and the selected context pack.
- After every phase, update run state or write a run report when persistent
  state would create noise.
- For long prompts, checkpoint after each phase.
- If context seems compressed, stale, or uncertain, rebuild state from files
  before continuing.
- No XL batch may proceed without run-state updates after each checkpoint.

## Persistent State Policy

`.codex/reports/current-run-state.md` is committed as a default template. For
ordinary runs, prefer final reports or audit docs over constantly changing this
file. For XL runs, update it deliberately and reset it to default before final
closeout unless the user asks to preserve live state.
