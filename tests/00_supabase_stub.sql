-- Minimal stand-in for what Supabase provides out of the box, so the four
-- migration files can be executed unchanged.

create extension if not exists pgcrypto;

create schema if not exists auth;

create table if not exists auth.users (
  id    uuid primary key default gen_random_uuid(),
  -- varchar, not text, because that is what Supabase actually uses.
  -- A stub that is more forgiving than production hides real bugs.
  email character varying(255) unique
);

-- Supabase sets this from the JWT. Here it reads a session variable so tests
-- can switch identity with set_config.
create or replace function auth.uid()
returns uuid
language sql
stable
as $$
  select nullif(current_setting('test.uid', true), '')::uuid;
$$;

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then
    create role service_role nologin;
  end if;
end
$$;

grant usage on schema public to anon, authenticated, service_role;
grant usage on schema auth to anon, authenticated, service_role;
grant select on auth.users to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Storage, enough of it to be real
-- ---------------------------------------------------------------------------
-- avatars.sql creates a bucket and four policies on storage.objects, and it
-- does so through EXECUTE — which means on a database with no storage schema
-- the whole block is skipped and the policy SQL is never even parsed. A
-- syntax error in it would surface for the first time on the live project.
--
-- So the schema is stubbed here: the two tables the migration touches, and
-- foldername(), which is the function the whole path-based rule rests on.
-- Not a reimplementation of Storage — no bytes, no HTTP, no signed URLs —
-- just enough for the policies to be created and then reasoned about.

create schema if not exists storage;

create table if not exists storage.buckets (
  id                 text primary key,
  name               text not null,
  public             boolean not null default false,
  file_size_limit    bigint,
  allowed_mime_types text[]
);

create table if not exists storage.objects (
  id        uuid primary key default gen_random_uuid(),
  bucket_id text references storage.buckets (id),
  name      text not null,
  owner     uuid,
  unique (bucket_id, name)
);

alter table storage.objects enable row level security;

-- Supabase's own: split the object name on / and return the directory parts.
-- 'abc/avatar.jpg' -> {abc}. The real one drops the filename, which is what
-- makes (storage.foldername(name))[1] the owning folder.
create or replace function storage.foldername(name text)
returns text[]
language sql
immutable
as $$
  select (string_to_array(name, '/'))[1:array_length(string_to_array(name, '/'), 1) - 1];
$$;

grant usage on schema storage to anon, authenticated, service_role;
grant all on storage.objects to authenticated, service_role;
grant all on storage.buckets to authenticated, service_role;
-- anon HAS the grant on real Supabase; what stops a signed-out browser is
-- RLS, not a missing privilege. Matching that here matters, because a test
-- that fails on 'permission denied' would pass for the wrong reason and stop
-- proving the policy does anything.
grant select on storage.objects to anon;
grant select on storage.buckets to anon;
