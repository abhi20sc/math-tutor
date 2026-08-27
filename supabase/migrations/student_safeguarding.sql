-- ===========================================================================
-- ASTRO STEM LABS — age, guardian consent, export, deletion, rate limiting
-- Run AFTER astro_math_assist_setup.sql and astro_sections.sql.
-- Safe to re-run.
-- ===========================================================================
--
-- Five things the pre-launch audit found missing, all of them the kind that
-- only matter once there are real students, and all of them the kind you
-- cannot retrofit quietly afterwards.
--
--   1. a minimum age, enforced in the database and not only in the form
--   2. guardian consent BEFORE a minor's work is recorded
--   3. a student can export everything held about them
--   4. a student can delete their account, and it actually deletes
--   5. rate limiting that exists, rather than being described in a policy
--
-- HOW CONSENT IS ENFORCED, AND WHY IT IS A TRIGGER
--
-- The obvious way is to add a check to every function that serves content.
-- That means re-declaring ten functions, each one copied out and pasted
-- back with two extra lines, and every one of them a chance to break
-- something that works. Worse, it protects only the paths that exist today:
-- the eleventh function, written next month, is unprotected by default.
--
-- So the check sits on the TABLES the data lands in. A minor without
-- consent cannot get a row into attempts or lesson_reads, whatever route
-- the write came from — an RPC, the SQL editor, a future feature, a bug.
-- Enforcement belongs where the data does.
--
-- What this deliberately does NOT do is block reading. A student waiting on
-- a guardian can look at lessons and questions. Nothing about them is
-- recorded until consent lands, which is the thing the law is about, and
-- locking a fourteen-year-old out of a maths lesson while an email sits
-- unread would be punishing them for their parent's inbox.
--
-- THE AGE FLOOR IS 13
--
-- Not a legal constant — PIPEDA names no age. It is the line below which
-- guidance is consistent that a child cannot meaningfully consent for
-- themselves, and it is what comparable services use. The courses here are
-- grades 9 to 12, so a student below it is in the wrong place anyway.
--
-- Everyone under 18 needs a guardian. That is stricter than it has to be
-- and it is the right side to err on for a product a parent is paying for.
-- ===========================================================================

\set ON_ERROR_STOP on


-- ---------------------------------------------------------------------------
-- 1. WHAT WE NOW KNOW ABOUT A STUDENT
-- ---------------------------------------------------------------------------
--
-- date_of_birth rather than an age: an age is wrong within a year of being
-- written, and a birthday that passes should not need anybody to do
-- anything. Nullable, because every existing account predates this column
-- and locking 8 live students out to backfill a field would be a worse
-- outcome than the one this prevents. See the note on consent_required.

alter table profiles add column if not exists date_of_birth date;
alter table profiles add column if not exists guardian_email text;
alter table profiles add column if not exists guardian_consent_at timestamptz;
alter table profiles add column if not exists guardian_consent_token uuid;

-- The token is the whole authentication on the guardian's link, so it has
-- to be unguessable and it has to be unique.
create unique index if not exists profiles_guardian_token_idx
  on profiles (guardian_consent_token)
  where guardian_consent_token is not null;

-- A birth date in the future, or implying an age over 120, is a typo rather
-- than a person. Rejecting it here means no function has to think about it.
do $$
begin
  if not exists (select 1 from pg_constraint
                 where conname = 'profiles_dob_sane') then
    alter table profiles add constraint profiles_dob_sane
      check (date_of_birth is null
             or (date_of_birth <= current_date
                 and date_of_birth > current_date - interval '120 years'));
  end if;
end $$;


-- ---------------------------------------------------------------------------
-- 2. THE RULES, AS FUNCTIONS
-- ---------------------------------------------------------------------------

-- Whole years. Postgres age() handles leap years and month lengths; doing
-- this with a subtraction of days gets February wrong once every four.
create or replace function age_years(p_dob date)
returns int
language sql
immutable
set search_path = public
as $$
  select case when p_dob is null then null
              else extract(year from age(current_date, p_dob))::int end;
$$;

-- The floor. Named so a single edit moves it everywhere.
create or replace function minimum_age()
returns int language sql immutable as $$ select 13 $$;

create or replace function guardian_required_below()
returns int language sql immutable as $$ select 18 $$;

-- Whether this student still needs a guardian to say yes.
--
-- Null date_of_birth returns FALSE, and that is a deliberate, documented
-- decision rather than an oversight. Every account that existed before this
-- migration has no birth date, and treating unknown as "minor, blocked"
-- would stop eight real students mid-course to collect a field the app has
-- never asked for. New accounts cannot be created without one — see
-- set_my_date_of_birth and the app's own signup — so this hole closes
-- itself as the existing accounts are updated, and it is a hole that only
-- ever applied to accounts created before the rule existed.
create or replace function consent_required(p_student uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select coalesce(
    (select age_years(p.date_of_birth) < guardian_required_below()
       and p.guardian_consent_at is null
     from profiles p where p.id = p_student),
    false);
$$;

-- What the app shows on the waiting screen.
create or replace function my_consent_status()
returns table (
  needs_guardian  boolean,
  guardian_email  text,
  consented_at    timestamptz,
  date_of_birth   date,
  age             int
)
language sql
security definer
stable
set search_path = public
as $$
  select consent_required(p.id),
         p.guardian_email,
         p.guardian_consent_at,
         p.date_of_birth,
         age_years(p.date_of_birth)
  from profiles p
  where p.id = auth.uid();
$$;


-- ---------------------------------------------------------------------------
-- 3. THE AGE GATE
-- ---------------------------------------------------------------------------
--
-- Set once, by the student, at signup. Not editable afterwards through this
-- function: a birth date that can be changed on demand is not a gate, it is
-- a preference. A genuine typo is an admin fix, which leaves a trace.

create or replace function set_my_date_of_birth(p_dob date)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_existing date;
  v_age      int;
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;
  if p_dob is null then
    raise exception 'A date of birth is required.';
  end if;

  select date_of_birth into v_existing from profiles where id = auth.uid();
  if v_existing is not null then
    raise exception 'Your date of birth is already set. Ask your tutor to correct it.';
  end if;

  v_age := age_years(p_dob);
  if v_age is null or v_age < minimum_age() then
    raise exception 'You must be at least % to use Astro STEM Labs.', minimum_age();
  end if;

  update profiles set date_of_birth = p_dob where id = auth.uid();
end;
$$;


-- ---------------------------------------------------------------------------
-- 4. GUARDIAN CONSENT
-- ---------------------------------------------------------------------------

-- The student names their guardian. Returns the token so the app can build
-- the link; the app is what sends it, because the database cannot send mail.
--
-- Re-requesting mints a NEW token and invalidates the old one, which is
-- what makes a link that went to the wrong address recoverable.
create or replace function request_guardian_consent(p_email text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_token uuid;
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;
  if p_email is null or position('@' in p_email) < 2 then
    raise exception 'A guardian email address is required.';
  end if;
  if not consent_required(auth.uid()) then
    raise exception 'This account does not need guardian consent.';
  end if;

  v_token := gen_random_uuid();
  update profiles
     set guardian_email = lower(trim(p_email)),
         guardian_consent_token = v_token
   where id = auth.uid();
  return v_token;
end;
$$;

-- What the guardian's link calls. Callable WITHOUT an account, because a
-- parent should not have to sign up to say yes — the token is the
-- authentication, exactly as it is for a shared report.
--
-- Returns the student's name so the page can say who is being consented
-- for. It returns nothing else: a guardian confirming consent has no
-- business reading the child's marks from this endpoint.
create or replace function guardian_consent_by_token(p_token uuid)
returns table (student_name text, already boolean)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id   uuid;
  v_name text;
  v_at   timestamptz;
begin
  if p_token is null then
    raise exception 'No such link.';
  end if;

  select p.id, p.full_name, p.guardian_consent_at
    into v_id, v_name, v_at
  from profiles p where p.guardian_consent_token = p_token;

  if v_id is null then
    raise exception 'No such link.';
  end if;

  if v_at is not null then
    return query select v_name, true;
    return;
  end if;

  update profiles
     set guardian_consent_at = now()
   where id = v_id;

  return query select v_name, false;
end;
$$;

-- Withdrawal. A consent that cannot be taken back was never consent.
--
-- This does NOT delete anything — that is delete_my_account, and conflating
-- the two would mean a guardian pausing an account destroyed a term of
-- work. It stops new work being recorded from this moment.
create or replace function withdraw_guardian_consent(p_token uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (select 1 from profiles where guardian_consent_token = p_token) then
    raise exception 'No such link.';
  end if;
  update profiles
     set guardian_consent_at = null
   where guardian_consent_token = p_token;
end;
$$;


-- ---------------------------------------------------------------------------
-- 5. ENFORCEMENT, AT THE TABLES
-- ---------------------------------------------------------------------------
--
-- One function, two triggers. A minor without consent cannot record work,
-- by any route.
--
-- The message is written for the student who sees it, not for a log.

create or replace function guard_consent_before_write()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if consent_required(new.student_id) then
    raise exception
      'This account is waiting for a parent or guardian to confirm it. '
      'Nothing you do is saved until they do.'
      using errcode = 'check_violation';
  end if;
  return new;
end;
$$;

drop trigger if exists attempts_require_consent on attempts;
create trigger attempts_require_consent
  before insert on attempts
  for each row execute function guard_consent_before_write();

drop trigger if exists lesson_reads_require_consent on lesson_reads;
create trigger lesson_reads_require_consent
  before insert on lesson_reads
  for each row execute function guard_consent_before_write();


-- ---------------------------------------------------------------------------
-- 6. EXPORT
-- ---------------------------------------------------------------------------
--
-- Everything held about the caller, as one JSON document they can keep.
--
-- Deliberately not a view or a set of tables: a person exercising a right of
-- access wants one file, and a tutor helping them wants to be able to see
-- what was in it.

create or replace function export_my_data()
returns jsonb
language sql
security definer
stable
set search_path = public
as $$
  select jsonb_build_object(
    'exported_at', now(),
    'profile', (
      select to_jsonb(p) - 'guardian_consent_token'
      from profiles p where p.id = auth.uid()),
    'attempts', coalesce((
      select jsonb_agg(to_jsonb(a) order by a.answered_at)
      from attempts a where a.student_id = auth.uid()), '[]'::jsonb),
    'unit_mastery', coalesce((
      select jsonb_agg(to_jsonb(m)) from unit_mastery m
      where m.student_id = auth.uid()), '[]'::jsonb),
    'lesson_reads', coalesce((
      select jsonb_agg(to_jsonb(r)) from lesson_reads r
      where r.student_id = auth.uid()), '[]'::jsonb),
    'practice_tests', coalesce((
      select jsonb_agg(to_jsonb(t)) from practice_tests t
      where t.student_id = auth.uid()), '[]'::jsonb),
    'enrolments', coalesce((
      select jsonb_agg(to_jsonb(e)) from enrolments e
      where e.student_id = auth.uid()), '[]'::jsonb),
    'tutor_notes', coalesce((
      select jsonb_agg(to_jsonb(n)) from tutor_notes n
      where n.student_id = auth.uid()), '[]'::jsonb),
    'progress_resets', coalesce((
      select jsonb_agg(to_jsonb(r)) from progress_resets r
      where r.student_id = auth.uid()), '[]'::jsonb),
    -- Deliberately excluded, and worth saying why rather than leaving a
    -- reader to wonder: subscriptions and etransfer_claims carry Stripe
    -- references and payment state that belong to the PAYER, who is
    -- usually a parent and not this account. A student exporting their own
    -- data should not receive their parent's billing identifiers.
    'not_included', jsonb_build_array(
      'payment and subscription records, which belong to the payer',
      'the guardian consent token, which is a credential')
  );
$$;


-- ---------------------------------------------------------------------------
-- 7. DELETION
-- ---------------------------------------------------------------------------
--
-- Deletes the auth user. Everything else follows, because profiles
-- references auth.users on delete cascade and every student table
-- references profiles the same way.
--
-- It is not reversible and it is not a soft delete. A "deleted" flag on a
-- row that still holds a child's academic record is not deletion, and
-- telling somebody their data is gone when it is not is worse than
-- refusing to delete it.
--
-- The avatar is removed first and explicitly: storage.objects does not
-- cascade from auth.users, so without this the photo of a child would
-- survive the account.

create or replace function delete_my_account()
returns void
language plpgsql
security definer
set search_path = public, storage
as $$
declare
  v_uid  uuid := auth.uid();
  v_path text;
begin
  if v_uid is null then
    raise exception 'Not signed in.';
  end if;

  select avatar_path into v_path from profiles where id = v_uid;
  if v_path is not null then
    delete from storage.objects
     where bucket_id = 'avatars' and name = v_path;
  end if;

  -- Cascades through profiles and every table that references it.
  delete from auth.users where id = v_uid;
end;
$$;


-- ---------------------------------------------------------------------------
-- 8. RATE LIMITING
-- ---------------------------------------------------------------------------
--
-- The privacy policy used to claim this existed. It did not: rate_limit_hits
-- was a table on the live project that nothing wrote to and nothing read,
-- and it is not created by any file in this repository. It is created here.
--
-- A fixed window rather than a sliding one. A sliding window is fairer and
-- needs a row per hit; a fixed window over-admits at a boundary and needs
-- one row per bucket. At this size the boundary case is somebody getting
-- eleven tries instead of ten, which is not the attack this stops.

create table if not exists rate_limit_hits (
  bucket      text        not null,
  window_start timestamptz not null,
  hits        int         not null default 0,
  primary key (bucket, window_start)
);

alter table rate_limit_hits enable row level security;
-- No policy, deliberately. Nothing reads this from a browser; the only
-- caller is the security definer function below.

create index if not exists rate_limit_hits_window_idx
  on rate_limit_hits (window_start);

-- Records one hit and says whether the caller is still under the limit.
--
-- Returns TRUE when the action may proceed. The caller decides what to do
-- on false, because "too many sign-in attempts" and "too many report
-- emails" want different words.
create or replace function note_rate_limit(
  p_bucket  text,
  p_limit   int  default 10,
  p_window  interval default '15 minutes'
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_start timestamptz;
  v_hits  int;
begin
  if p_bucket is null or length(p_bucket) = 0 then
    raise exception 'A bucket is required.';
  end if;

  -- Floor the clock to the window, so every caller in the same window
  -- lands on the same row and the upsert can do the counting.
  v_start := to_timestamp(
    floor(extract(epoch from now()) / extract(epoch from p_window))
    * extract(epoch from p_window));

  insert into rate_limit_hits (bucket, window_start, hits)
  values (p_bucket, v_start, 1)
  on conflict (bucket, window_start)
    do update set hits = rate_limit_hits.hits + 1
  returning hits into v_hits;

  return v_hits <= p_limit;
end;
$$;

-- Housekeeping. Nothing schedules this; it is here so that whoever notices
-- the table growing has the one-liner to hand.
create or replace function purge_rate_limits(p_older_than interval default '1 day')
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  v_gone int;
begin
  delete from rate_limit_hits where window_start < now() - p_older_than;
  get diagnostics v_gone = row_count;
  return v_gone;
end;
$$;


-- ---------------------------------------------------------------------------
-- 9. GRANTS
-- ---------------------------------------------------------------------------
--
-- The five-deliberate-denials rule applies here too: anything not granted
-- below is unreachable from a browser, and that absence is the protection.
-- Never add a blanket grant.

revoke all on function set_my_date_of_birth(date)        from public, anon;
revoke all on function request_guardian_consent(text)    from public, anon;
revoke all on function withdraw_guardian_consent(uuid)   from public, anon;
revoke all on function my_consent_status()               from public, anon;
revoke all on function export_my_data()                  from public, anon;
revoke all on function delete_my_account()               from public, anon;
revoke all on function note_rate_limit(text, int, interval) from public, anon;
revoke all on function purge_rate_limits(interval)       from public, anon;
revoke all on function consent_required(uuid)            from public, anon;
revoke all on function guard_consent_before_write()      from public, anon;

grant execute on function set_my_date_of_birth(date)      to authenticated;
grant execute on function request_guardian_consent(text)  to authenticated;
grant execute on function my_consent_status()             to authenticated;
grant execute on function export_my_data()                to authenticated;
grant execute on function delete_my_account()             to authenticated;

-- The guardian is not signed in. The token is the credential, so these two
-- are the ONLY functions in this file reachable by anon, and both of them
-- fail closed on an unknown token.
grant execute on function guardian_consent_by_token(uuid) to anon, authenticated;
grant execute on function withdraw_guardian_consent(uuid) to anon, authenticated;

-- note_rate_limit is called by the app before an action, so it has to be
-- callable by a signed-out browser: sign-in and password reset are exactly
-- the endpoints worth limiting.
grant execute on function note_rate_limit(text, int, interval) to anon, authenticated;

-- Verify:
--
--   select * from my_consent_status();
--   select note_rate_limit('test', 2, '1 minute');   -- true, true, false
--   select jsonb_object_keys(export_my_data());
