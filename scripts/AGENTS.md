# Ambitions Scripts AGENTS

These rules apply to command-line, shell, and Python support scripts in `scripts/`.

- Use shell or Python standard library only unless an active source-truth file explicitly permits additional toolchains.
- No package installation, network access, or API-key retrieval in scripts under `scripts/`.
- Keep outputs deterministic and machine-readable where possible.
- Use explicit exit codes and avoid silent success.
- Validation scripts must fail closed when prohibited patterns are detected in command intent or control-plane diffs.
- No hidden cost-exposure paths: no remote model calls, no hosted CI entrypoints, no third-party paid service calls.
- Keep scripts idempotent and conservative for partial-failure recovery.
