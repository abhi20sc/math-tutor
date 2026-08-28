-- ===========================================================================
-- client_errors — somewhere for a crash to go
-- Run AFTER student_safeguarding.sql (it uses note_rate_limit and is_admin).
-- Safe to re-run.
-- ===========================================================================
--
-- WHY THIS RATHER THAN SENTRY
--
-- _reportError in lib/main.dart catches every Flutter and every uncaught
-- async error and writes it to the browser console, where nobody is
-- looking. Today, if a student hits a crash, you find out because they tell
-- you — and a fourteen-year-old who hits a white screen closes the tab.
--
-- The obvious fix is Sentry, and it was the wrong one here for three
-- reasons that all point the same way. It costs money. It is a third-party
-- processor, so it has to be named in the privacy policy. And what it would
-- process is diagnostic data about children, sent to a company in another
-- country, to solve a problem that a table solves.
--
-- This is that table. Same database, same operator, same privacy policy,
-- nothing new to disclose and nothing new to pay for.
--
-- THE FOUR THINGS THAT MAKE AN ERROR SINK SAFE
--
-- An error reporter has failure modes an ordinary feature does not, because
-- it runs exactly when things are already going wrong.
--
--   1. It must not amplify. An exception thrown in build() fires on every
--      frame. Unthrottled, one broken widget is thousands of inserts a
--      minute from one tab. note_rate_limit caps it, and the same error
--      inside one window increments a counter instead of adding a row.
--   2. It must not leak. An exception message can contain anything the code
--      was holding. BOTH ends redact, independently — the app before
--      sending and scrub_for_log on arrival — because the app is the thing
--      that is broken when this runs, and "the client will have sanitised
--      it" is a poor assumption to build a ninety-day log table on.
--   3. It must be write-only from the client. A student may add to this
--      table and may not read it — otherwise the crash log becomes a way to
--      read other students' crash logs.
--   4. It must never raise. An error thrown while reporting an error is a
--      loop. Every failure path here returns quietly.
-- ===========================================================================

create table if not exists client_errors (
  id           bigserial primary key,
  student_id   uuid references auth.users(id) on delete set null,
  context      text        not null,
  message      text        not null,
  stack        text,
  fingerprint  text        not null,
  app_version  text,
  first_seen   timestamptz not null default now(),
  last_seen    timestamptz not null default now(),
  seen_count   int         not null default 1
);

-- The dedupe key. One row per (student, fingerprint) — a student hitting the
-- same crash forty times is one row with seen_count 40, which is both less
-- data and a more useful thing to read than forty identical rows.
--
-- student_id is nullable (errors happen on the sign-in screen, before there
-- is a student), and null is distinct from null in a unique index by
-- default, so `nulls not distinct` is required or every signed-out error
-- inserts a new row.
create unique index if not exists client_errors_dedupe
  on client_errors (student_id, fingerprint) nulls not distinct;

create index if not exists client_errors_last_seen
  on client_errors (last_seen desc);

alter table client_errors enable row level security;

-- No policies, deliberately. RLS with no policy is fail-closed: the table is
-- unreachable through PostgREST entirely, and the only ways in are the two
-- security-definer functions below. That is the same shape as questions and
-- rate_limit_hits — see section 8 of the launch checklist before "fixing"
-- the advisor warning this produces.

-- ---------------------------------------------------------------------------
-- The scrubber
-- ---------------------------------------------------------------------------
--
-- The same three patterns lib/main.dart strips, applied again here. Not
-- belt-and-braces for its own sake: the app-side redaction is one edit away
-- from being bypassed by a new caller that forgets it, and this is the end
-- that actually writes to disk.
create or replace function scrub_for_log(p_text text)
returns text
language sql
immutable
set search_path = public
as $$
  select regexp_replace(
           regexp_replace(
             regexp_replace(p_text,
               '[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}', '[email]', 'g'),
             '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
             '[uuid]', 'g'),
           'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+', '[jwt]', 'g');
$$;

revoke all on function scrub_for_log(text) from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- The write
-- ---------------------------------------------------------------------------
--
-- Returns nothing and raises nothing. A caller cannot tell whether it was
-- stored, throttled or dropped, and that is correct: there is no useful
-- thing an app can do with a failed error report except carry on.
create or replace function note_client_error(
  p_context     text,
  p_message     text,
  p_stack       text default null,
  p_fingerprint text default null,
  p_version     text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_who    uuid := auth.uid();
  v_bucket text;
  v_fp     text;
  v_msg    text;
begin
  if p_message is null or length(trim(p_message)) = 0 then
    return;
  end if;

  -- Per-student, or per-nobody for the signed-out screens. Twenty an hour
  -- is generous for a real fault and useless for a loop.
  v_bucket := 'client-error:' || coalesce(v_who::text, 'anon');
  if not note_rate_limit(v_bucket, 20, '1 hour') then
    return;
  end if;

  -- Scrub FIRST, then truncate. The other order can cut a uuid in half and
  -- leave the front of it in the table, matching no pattern afterwards.
  v_msg := left(scrub_for_log(p_message), 500);

  -- Never trust the client's fingerprint to be present or sane. Falling
  -- back to a hash of the scrubbed message means a caller that sends
  -- nothing still dedupes.
  v_fp := coalesce(nullif(left(scrub_for_log(p_fingerprint), 64), ''),
                   md5(left(v_msg, 200)));

  insert into client_errors
    (student_id, context, message, stack, fingerprint, app_version)
  values
    (v_who,
     left(coalesce(p_context, 'unknown'), 40),
     v_msg,
     left(scrub_for_log(p_stack), 4000),
     v_fp,
     left(p_version, 40))
  on conflict (student_id, fingerprint) do update
    set last_seen   = now(),
        seen_count  = client_errors.seen_count + 1,
        -- Keep the LATEST stack rather than the first. When a crash changes
        -- shape under the same fingerprint, the recent one is the one that
        -- matches the build you are looking at.
        stack       = excluded.stack,
        app_version = excluded.app_version;
exception
  -- Belt and braces. Anything unforeseen here must not propagate into an
  -- app that is already handling a crash.
  when others then
    return;
end;
$$;

revoke all on function note_client_error(text, text, text, text, text)
  from public;
-- anon as well as authenticated: the sign-in screen is exactly where a
-- first-run crash happens, and that is the one you most want to hear about.
grant execute on function note_client_error(text, text, text, text, text)
  to anon, authenticated;

-- ---------------------------------------------------------------------------
-- The read
-- ---------------------------------------------------------------------------
--
-- Admin only, and it re-checks is_admin() in its own body rather than
-- relying on the grant, which is the pattern every other admin_* function
-- here follows.
create or replace function admin_recent_errors(p_days int default 7)
returns table (
  id          bigint,
  student_id  uuid,
  context     text,
  message     text,
  stack       text,
  app_version text,
  first_seen  timestamptz,
  last_seen   timestamptz,
  seen_count  int
)
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if not is_admin() then
    raise exception 'Not permitted.';
  end if;

  return query
    select e.id, e.student_id, e.context, e.message, e.stack, e.app_version,
           e.first_seen, e.last_seen, e.seen_count
    from client_errors e
    where e.last_seen > now() - make_interval(days => greatest(p_days, 1))
    order by e.last_seen desc
    limit 500;
end;
$$;

revoke all on function admin_recent_errors(int) from public, anon;
grant execute on function admin_recent_errors(int) to authenticated;

-- Housekeeping, unscheduled like purge_rate_limits. A crash table nobody
-- prunes is a crash table that eventually costs money.
create or replace function purge_client_errors(p_older_than interval default '90 days')
returns int
language plpgsql
security definer
set search_path = public
as $$
declare v_gone int;
begin
  if not is_admin() then
    raise exception 'Not permitted.';
  end if;
  delete from client_errors where last_seen < now() - p_older_than;
  get diagnostics v_gone = row_count;
  return v_gone;
end;
$$;

revoke all on function purge_client_errors(interval) from public, anon;
grant execute on function purge_client_errors(interval) to authenticated;

-- ===========================================================================
-- Verify
-- ===========================================================================
--
--   select note_client_error('test', 'a made-up error', 'no stack');
--   select context, message, seen_count from client_errors;   -- admin only
--
-- Call it twice and seen_count goes to 2 rather than a second row
-- appearing. Call it twenty-one times in an hour and the twenty-first is
-- dropped without complaint.
--
-- Checked on the live database when this was applied, 29 August 2026:
--
--   * two calls with the same message and different stacks -> one row,
--     seen_count 2, the LATER stack kept
--   * a 900-character message -> stored at 500
--   * 40 distinct errors in one window -> 20 stored, 20 dropped, no error
--     raised to the caller
--   * the exact five parameters lib/main.dart sends, posted over HTTP with
--     the publishable key -> 204, row written, student_id null
--   * the same key reading /rest/v1/client_errors -> 200 and an empty
--     array, which is RLS-with-no-policy doing its job
--   * an UNREDACTED payload with an address, a uuid and a JWT in it ->
--     stored as "[email] and [uuid] and [jwt]"
--
-- All test rows were deleted afterwards.
