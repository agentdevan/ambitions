# Ambitions 3.0 — Definition Of Ready And Done

Status: Historical supporting canon; subordinate to `docs/truth/*`

## Definition Of Ready

A task is ready only when it names:

- owning primitive,
- owning surface,
- product problem,
- acceptance criteria,
- allowed files,
- forbidden files,
- validation pack,
- copy impact,
- accessibility impact,
- privacy/trust impact,
- test impact,
- release claim impact,
- task width classification.

Missing readiness fields must be filled from repo docs or the task must be
split/paused before implementation.

## Definition Of Done

A task is done only when:

- implementation matches active canon,
- tests ran or reason is documented,
- copy guard ran where relevant,
- accessibility evidence exists where UI changed,
- privacy evidence exists where sensitive data changed,
- previews exist or are consciously deferred where user-facing UI changed,
- no active stale-doc guidance was introduced,
- batch registry/status docs are updated when status changed,
- closeout report lists files, validation, risks, and next prompt,
- release claims remain blocked unless evidence supports them.

Done is not the same as release-ready, device-verified, App Store-ready, or
FAANG handoff-ready.
