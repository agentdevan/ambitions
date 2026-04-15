-- Historical reference only.
-- This SQL file belongs to an earlier Supabase sync path and is not part of the currently shipped native local-only app.

create table if not exists public.sync_records (
  account_id text not null,
  entity_kind text not null,
  entity_id text not null,
  remote_id text not null,
  payload_json text not null,
  version integer not null default 1,
  last_writer_device_id text not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  primary key (account_id, entity_kind, remote_id)
);

alter table public.sync_records enable row level security;

create policy "users can read their sync records"
on public.sync_records
for select
using (auth.uid()::text = replace(account_id, 'account:', ''));

create policy "users can upsert their sync records"
on public.sync_records
for insert
with check (auth.uid()::text = replace(account_id, 'account:', ''));

create policy "users can update their sync records"
on public.sync_records
for update
using (auth.uid()::text = replace(account_id, 'account:', ''))
with check (auth.uid()::text = replace(account_id, 'account:', ''));
