# Phase 14.2 Live Auth + Sync Activation

## Status

As of April 12, 2026, this workspace does not have live Supabase credentials available at runtime:

- `EXPO_PUBLIC_SUPABASE_URL`: missing
- `EXPO_PUBLIC_SUPABASE_ANON_KEY`: missing

Because of that, connected auth and remote sync cannot be truthfully verified from this checkout alone. The app should remain in local-only mode until real values are supplied.

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

Fully verified here:

- Missing-env fallback stays local-only.
- Placeholder env values are rejected as unconfigured.
- Code paths for offline sign-out and reconnect retry compile.

Not live-verified here because backend credentials are missing:

- Account creation
- Sign-in against Supabase
- Remote session restore
- Remote sync round-trip
- Remote attach/import upload
- Cross-device continuity
- SQL/RLS behavior in the target Supabase project

## Remaining Blocker

The only blocker to full Phase 14.2 completion from this workspace is missing live Supabase project access:

- no runtime `EXPO_PUBLIC_SUPABASE_URL`
- no runtime `EXPO_PUBLIC_SUPABASE_ANON_KEY`
- no applied/confirmed target Supabase schema in this session

Once those are supplied, the checklist above can be run without any further secret changes in git.
