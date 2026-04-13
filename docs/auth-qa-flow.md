# Auth QA Flow

Use this flow when testing Ambitions auth against the live Supabase project.

## Why this exists

Supabase Auth email testing is easy to poison with repeated sign-up attempts.

As of April 12, 2026, the current Supabase docs say:

- the default SMTP service is limited to 2 emails per hour for the whole project
- signup confirmation requests have a per-user cooldown of 60 seconds

Sources:

- [Supabase Auth rate limits](https://supabase.com/docs/guides/auth/rate-limits)
- [Supabase custom SMTP guide](https://supabase.com/docs/guides/auth/auth-smtp)
- [Supabase password auth guide](https://supabase.com/docs/guides/auth/passwords)

## Rule of thumb

Treat email-sending auth tests as scarce.

Do not use the live `Create account` path as the default way to test generic auth UI behavior.

## Split the matrix

### Email-send required

Use one fresh plus-address alias for:

- brand-new signup
- confirmation-required signup path
- inbox confirmation completion

Example:

- `devanwarner+auth-20260412-a@gmail.com`

### No email send required

Use existing accounts or purely local validation for:

- already-registered signup behavior
- sign in with an existing account
- invalid credentials
- weak password handling
- invalid email handling
- stale error clearing after edit
- mode switch clearing wrong-state messaging
- CTA disabled and cooldown behavior

## Safe live test sequence

1. Generate two fresh aliases for the current hour.
2. Use alias A for the single brand-new signup test.
3. Open the confirmation email and complete the link flow.
4. Use that confirmed account for sign-in and existing-account behavior.
5. Run all non-email tests without sending another signup email.
6. If Supabase returns rate-limited on the first signup tap, stop retrying. The project budget is already spent for that time window.

## Repo helper

Run:

```bash
npm run auth:qa
```

This prints a lightweight QA plan and suggested aliases for the current hour.

## When to move past default SMTP

If auth QA is a recurring part of development, configure custom SMTP and raise the auth email limit in Supabase. Default SMTP is fine for light exploration, but it is not stable enough for repeated product QA.
