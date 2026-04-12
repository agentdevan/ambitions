# Phase 14.2 Live Auth + Sync Activation

## Status

As of April 12, 2026, this workspace now has live Supabase runtime config locally via an ignored `.env` file.

Live auth is verified against the real Supabase project.

The `public.sync_records` backend contract is now reachable from the anon client path.

Latest verification note:

- A live `select` against `public.sync_records` now succeeds for the signed-in anon client.
- A live `upsert` into `public.sync_records` now succeeds for the signed-in anon client and round-trips the inserted row.
- The next blocker is no longer the backend schema contract. The remaining blockers are rendered app-runtime verification and lack of a usable local native mobile toolchain in this workspace.

## Required Environment

Create a local ignored env file such as `.env.local` with:

```bash
EXPO_PUBLIC_SUPABASE_URL=https://<your-project-ref>.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=<your-supabase-anon-key>
```

Rules:

- Do not commit real values.
- Do not put real values into `.env.example`.
- `.env`, `.env.local`, and `.env.*` are ignored; `.env.example` remains committed as the template.
- Placeholder values are treated as "not configured" by the app.

## Backend SQL Contract

Apply [`docs/phase14-supabase.sql`](/C:/Users/Devan/Documents/GitHub/ambitions/docs/phase14-supabase.sql) to the target Supabase project SQL editor before testing live sync.

Current contract expectations:

- Table: `public.sync_records`
- Primary key: `(account_id, entity_kind, remote_id)`
- Authenticated users may read and upsert only records where `account_id` matches `account:<auth.uid()>`

Manual step:

1. Open the Supabase SQL editor for the project referenced by `EXPO_PUBLIC_SUPABASE_URL`.
2. Paste the contents of `docs/phase14-supabase.sql`.
3. Run the script.
4. Confirm the table and RLS policies exist before testing the app.

If sync still returns `Could not find the table 'public.sync_records' in the schema cache` after running the SQL:

1. Confirm the SQL was run in the correct Supabase project: `yeylmvlunqcnyfzyjmtj`.
2. Confirm the table was created in schema `public`.
3. Confirm the SQL completed successfully without partial failure.
4. If the table exists in the dashboard but the API still returns the same schema-cache error, refresh PostgREST/schema cache from Supabase or re-run the migration in the same project.
5. Re-test from the anon client after the refresh; Phase 14.2 sync cannot be considered live until a real read or upsert succeeds.

## What Was Implemented In Code

- Missing or placeholder Supabase env now keeps the app in truthful local-only mode.
- Auth unavailable copy now explains the exact required env variables.
- `.env` and `.env.*` are ignored so real credentials are less likely to be committed by mistake.
- Sign-out now uses local Supabase sign-out scope so the device can leave the session cleanly even without network.
- Session restore fallback now resets attachment and sync state back to local-only instead of leaving stale connected metadata behind.
- Backend-unavailable initialization now clears stale connected account/sync state consistently.
- Network reconnection now triggers a silent sync retry when the user is signed in, attached, and previously offline/pending/failed.

## Live Verification Checklist

After env and SQL are in place, verify in this order:

1. Create account with a brand-new email.
2. Sign out.
3. Sign in with the same credentials.
4. Relaunch the app and confirm the session restores.
5. Create or edit a goal, task, and preference while signed in.
6. Confirm sync moves from pending to synced.
7. Confirm data reappears after relaunch.
8. Start with meaningful local-only data, then sign in and choose `Attach data`.
9. Confirm local records are preserved and uploaded, not silently replaced.
10. Go offline, make changes, relaunch, then reconnect and confirm retry completes.

## Verified In This Workspace

Fully verified live:

- `EXPO_PUBLIC_SUPABASE_URL` and `EXPO_PUBLIC_SUPABASE_ANON_KEY` are loaded from local `.env`.
- Account creation reaches the real Supabase backend.
- Email confirmation gating works when email confirmation is ON.
- Email confirmation link completion works.
- Sign-in works after confirmation.
- Session restore works in a fresh Supabase client using persisted session state.
- Sign-out works.
- The app code now handles confirmation-required sign-up truthfully instead of treating it as a broken auth failure.
- `public.sync_records` is readable through the signed-in anon client.
- `public.sync_records` accepts a live signed-in anon-client upsert.

Verified locally but not in native mobile runtime:

- Typecheck passes.
- App-side auth/sync code compiles after the live-auth fixes.

Still blocked:

- attach local data
- sync pending -> synced
- offline change -> reconnect retry
- rendered signed-out / signed-in / synced UI verification in an actual native runtime

## Remaining Blockers

1. Native runtime verification is not possible from this machine right now because the workspace does not have a usable Android SDK/emulator, `adb`, Java, or iOS/Xcode runtime.

2. Expo web is not the primary blocker, but it is currently failing to render the app bundle in this workspace due to a Metro dependency-resolution error:
   `While trying to resolve module react-is from pretty-format/build/plugins/ReactElement.js ... index.js could not be resolved`

3. Because of those runtime limitations, Phase 14.2 still lacks truthful rendered-app verification for:
   - account-unavailable state disappearing in the real UI
   - attach local data
   - sync pending -> synced
   - offline change -> reconnect retry
   - signed-out / signed-in / synced surface transitions in the rendered app
