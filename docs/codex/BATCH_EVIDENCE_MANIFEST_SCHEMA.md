# Batch Evidence Manifest Schema

Status: Active batch-report schema
Date: 2026-05-03

Every batch report should include this evidence manifest, either as a section
or equivalent table.

## Required Fields

| Field | Required value |
| --- | --- |
| Batch ID and global order | Exact batch ID and global order when available. |
| Starting HEAD | Commit hash before the batch. |
| Ending HEAD | Commit hash after commit, or `pending commit in current run`. |
| Source truth read | Files read before edits. |
| Files changed | Exact changed files. |
| App behavior changed | yes/no. |
| User-facing behavior changed | yes/no. |
| Privacy behavior changed | yes/no. |
| Routes/raw values changed | yes/no. |
| Persistence/schema changed | yes/no. |
| Release claim allowed | yes/no. |
| Commands run | Exact command strings. |
| Passed checks | Checks that passed. |
| Failed checks | Checks that failed and whether repaired. |
| Accepted Yellow checks | Advisory or deferred-proof checks with owner. |
| Not-run checks | Checks not run and why. |
| Red issues | Remaining or repaired Reds. |
| Next eligible batch | Repo-reported next batch, not a guess. |

## Claim Rule

If evidence is not in the manifest, do not claim it. Human/device/screenshot
proof must include concrete context such as device, OS, tool, scenario, output
path, reviewer, or command.

## DAV Backfill

DAV14 and DAV15 use this schema directly. Earlier DAV reports may reference
this schema in future evidence-refresh passes without rewriting their history.
