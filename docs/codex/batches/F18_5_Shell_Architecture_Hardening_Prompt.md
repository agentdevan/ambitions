# F18.5 Shell Architecture Hardening Prompt

Status: Conditional
Train: F17-F30 FAANG Handoff Completion Train

Run only if F18 triggers shell state ownership ambiguity, routing coupling, feature flag instability, fallback risk, accessibility route ambiguity, or a new architecture warning caused by touched shell files.

Scope:

- behavior-preserving shell architecture hardening
- no new product behavior
- no route removal
- no fallback removal

Validate build, focused shell tests, architecture scan, copy guard for touched files, and `git diff --check`.
