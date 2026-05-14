# Repo Authority Cleanup Install Report

## Status

INSTALLED_WITH_REMOTE_GITHUB_WRITES

The repo-authority cleanup prompt train has been installed on `main` as prompt and control-document artifacts.

This report does **not** claim the cleanup train has executed. The actual cleanup must run through the Ambitions runner using `AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL`.

Local runner validation was not executed by ChatGPT during this installation. Validation must be performed by Codex/the local runner in the repository.

## Installed prompt suite

```text
prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-INSTALL-00.md
prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL.md
prompts/batches/AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT.md
prompts/batches/AMB-REPO-AUTHORITY-01-FRONT-DOOR-PORTALS.md
prompts/batches/AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA.md
prompts/batches/AMB-REPO-AUTHORITY-03-BACKEND-HONESTY.md
prompts/batches/AMB-REPO-AUTHORITY-04-CODEX-OS-CONSOLIDATION.md
prompts/batches/AMB-REPO-AUTHORITY-05-HISTORICAL-ARCHIVE-MIGRATION.md
prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md
prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md
```

## Installed control documents

```text
docs/codex/batch-trains/AMB-REPO-AUTHORITY-CLEANUP-SEQUENCE.md
docs/status/repo-authority-cleanup-green-gate-spec.md
docs/status/repo-authority-cleanup-install-report.md
```

## Queue manifest

No `.codex/queue` manifest was installed. A GitHub repository search for `.codex/queue` returned no results during installation. The installed conductor prompt is therefore the primary execution mechanism.

## Runner commands

Bootstrap verification:

```bash
make batch BATCH=AMB-REPO-AUTHORITY-CLEANUP-INSTALL-00 PROMPT=prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-INSTALL-00.md
```

Primary cleanup execution:

```bash
make batch BATCH=AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL PROMPT=prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL.md
```

## Hard-green operating model

The installed train requires:

- GREEN before any phase may proceed.
- YELLOW is report-only and may not permit continuation.
- RED stops immediately.
- Source changes require build/test proof.
- Deletion requires pre-delete validation, dependency analysis, and rollback.
- Historical material must be visibly non-authoritative.
- Release/TestFlight/App Store/device/accessibility/performance/privacy/legal claims require repo proof.

## Scope proof

This install pass only created prompt/control artifacts under:

```text
prompts/batches/
docs/codex/batch-trains/
docs/status/
```

It did not:

- rewrite `README.md`
- move or delete active/historical files
- change the Visual Encyclopedia
- change app source
- change runner scripts
- execute cleanup
- claim release/build/device proof

## Commit / push proof

The artifacts were installed directly on `main` using GitHub file commits:

```text
9f9bc96cf760c15188c8acc4f702573d7d153bdf  prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-INSTALL-00.md
edf5a0d2d75bdcf3708eaf37773e448e0174dbb4  prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL.md
6e48f69c5b562fbe1f44d564be8bc3d5cfe45552  prompts/batches/AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT.md
6219d17d62f79f607765e7c03628c7f0bf0cb9fd  prompts/batches/AMB-REPO-AUTHORITY-01-FRONT-DOOR-PORTALS.md
81a56253100902f436e16468cc92efd39df87520  prompts/batches/AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA.md
05797190068449da5d9877697786c254cd287863  prompts/batches/AMB-REPO-AUTHORITY-03-BACKEND-HONESTY.md
4c808cfd233de39eadc3ac3b368fb2de3392f115  prompts/batches/AMB-REPO-AUTHORITY-04-CODEX-OS-CONSOLIDATION.md
21f8f956aa1fb09942483b26ddadc1ed2cddbc03  prompts/batches/AMB-REPO-AUTHORITY-05-HISTORICAL-ARCHIVE-MIGRATION.md
d4f2eee91043c6a3e459d74be05b82c01da10b88  prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md
cb143d52d907c17ef265bcccc8b2c3d3ee2aced2  prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md
8a269cf690c4fd6906f45afcbc43944631dcf08e  docs/codex/batch-trains/AMB-REPO-AUTHORITY-CLEANUP-SEQUENCE.md
00fd7e11346d184c70f55c5e73ba8d4b4ac796e7  docs/status/repo-authority-cleanup-green-gate-spec.md
```

This report was added in the final install commit.

## Validation still required

Run the bootstrap verification prompt first if you want Codex to verify install integrity from inside the repo:

```bash
make batch BATCH=AMB-REPO-AUTHORITY-CLEANUP-INSTALL-00 PROMPT=prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-INSTALL-00.md
```

Then run the conductor:

```bash
make batch BATCH=AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL PROMPT=prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL.md
```

## Rollback

Because this installation was split across direct GitHub file commits, rollback can be performed with reverse-order reverts:

```bash
git revert 00fd7e11346d184c70f55c5e73ba8d4b4ac796e7 8a269cf690c4fd6906f45afcbc43944631dcf08e cb143d52d907c17ef265bcccc8b2c3d3ee2aced2 d4f2eee91043c6a3e459d74be05b82c01da10b88 21f8f956aa1fb09942483b26ddadc1ed2cddbc03 4c808cfd233de39eadc3ac3b368fb2de3392f115 05797190068449da5d9877697786c254cd287863 81a56253100902f436e16468cc92efd39df87520 6219d17d62f79f607765e7c03628c7f0bf0cb9fd 6e48f69c5b562fbe1f44d564be8bc3d5cfe45552 edf5a0d2d75bdcf3708eaf37773e448e0174dbb4 9f9bc96cf760c15188c8acc4f702573d7d153bdf
```

After this report commit, include this report commit SHA first if rolling back the full installation.

## Next command

```bash
make batch BATCH=AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL PROMPT=prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL.md
```
