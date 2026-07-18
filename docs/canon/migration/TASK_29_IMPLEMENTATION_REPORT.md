# Task 29 migration foundation

Status: non-destructive foundation only. This record does not authorize or
perform a legacy-source deletion.

## Approved topology

The owner approved a two-step Task 29 topology on 2026-07-18 after the
one-commit topology was shown to be structurally unable to bind a new purge
plan as trusted base input:

1. commit the exact non-destructive migration, routing, and purge-plan
   foundation;
2. derive the destructive Gate C candidate from that trusted foundation and
   require a separate exact owner approval before deleting any artifact.

## Foundation contents

- A digest-bound semantic ledger preserves each legacy `docs/truth/**` and
  `docs/constitution/**` source as exact UTF-8 bytes with its registered
  provenance digest.
- Only requirement IDs present in the active canon are labelled active;
  otherwise the historical supersession owner preserves the source claim
  without overstating a live semantic replacement.
- Live consumers route to active canon. Historical evidence and migration
  provenance retain references only as non-authoritative records.
- The Task 29 policy no longer statically allowlists legacy deletion paths.
  The future deletion can be authorized only by the trusted, exact Task 29
  purge manifest.

## Verified foundation scope

Focused Task 29 migration, authorization, and purge tests passed with Python
3.12 before this commit. `git diff --check` passed. No production Swift change,
legacy source deletion, Figma mutation, Linear mutation, protected-CI claim, or
Gate C approval is included in this foundation.

## Direct-receipt verification foundation

The standard platform attestation verifier cannot authenticate the expressly
approved Tasks 24–29 owner-direct exception. The Task 29 verifier therefore
accepts one closed, local receipt only when it binds all of the following:

- the exact Task 29 decision identifier and an owner text digest containing
  the immutable candidate commit and purge-operation digest;
- the pre-delete, candidate, and rollback commit/tree identities;
- the complete sorted artifact-ID scope;
- an exact-review package digest with zero Critical and Important findings;
- a plan whose claim, inbound-link, external-reference, and unique-content
  gates are already true, but whose owner and review gates remain false until
  the direct receipt is supplied.

This does not permit a generic local bypass, a different task, an unbound
candidate, a self-approved plan, or a protected-CI claim.

## Next step and rollback

The next step is to freeze a Gate C candidate from this commit, run its exact
review and dry run, and obtain owner approval bound to that candidate.

Rollback for this foundation is `git revert` of its integration commit. The
later destructive candidate must name this foundation commit as its rollback
reference.
