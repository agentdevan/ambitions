# Ambitions Transaction Model

Status: Active behavior canon

Core model: `Intent -> Preview -> Commit -> Receipt -> Undo / Recover`

## Applies To

- reflow step
- move protected time
- promote capture to goal
- close step as Still Counts
- change automation level
- forget learned behavior
- reset local data
- attach proof
- start step session
- place capture
- hold capture
- recover blocked step
- update schedule assumptions
- change planning default
- set vacation / away time

## Required Fields

- trigger
- preview content
- commit action
- receipt
- undo window
- recovery path
- VoiceOver announcement
- Reduce Motion behavior

## Destructive Actions

Destructive changes require explicit preview, a clear receipt, and a visible undo or recovery path when possible.

## Closure Grammar

The transaction model uses `CLOSURE_RECOVERY_INTERACTION_GRAMMAR.md` for interrupted, blocked, stale, and recoverable closeout states.
