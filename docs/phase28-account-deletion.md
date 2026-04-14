# Phase 28.1 data-rights status

## Implemented now

- In-app account deletion is implemented from Profile settings.
- The mobile client reauthenticates with the user's password before deletion.
- The app calls the `delete-account` Supabase Edge Function to delete:
  - the user's `sync_records`
  - the Supabase auth user itself
- After a successful delete, the local app data is wiped and reseeded to a clean onboarding state so no stale synced content lingers on-device.

## Export status

- A user-facing export flow did not exist in the repo before Phase 28.1.
- There was no partial export scaffold close enough to complete without creating a new subsystem.
- Export is intentionally deferred instead of being faked or shipped as a weak placeholder.

## Deferred post-launch work

- Add a portable in-app export format and delivery surface.
- Decide whether export should be file-based, share-sheet based, or backend-generated for larger accounts.
- Document the final retention and legal-hold policy once production compliance text is locked.

## Manual pre-submission step

Deploy the Supabase Edge Function before relying on deletion in production:

```bash
supabase functions deploy delete-account
```

The function requires the standard hosted secrets already exposed by Supabase Edge Functions:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
