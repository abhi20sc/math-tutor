-- ===========================================================================
-- ASTRO MATH ASSIST — complete database setup
-- ===========================================================================
--
-- Paste this whole file into the Supabase SQL Editor and press Run. It is the
-- ONLY schema file. Everything that once lived in a separate file is folded in
-- here:
--
--   * wire_up_unused_functions.sql   — the wiring fixes
--   * avatars.sql                    — the private profile-photo bucket, its
--                                      policies, profiles.avatar_path, and
--                                      set_my_avatar / clear_my_avatar
--   * admin_teacher_students.sql     — the admin drill-down from one tutor to
--                                      the students they teach
--
-- Those two standalone files are RETIRED and must not be run against a
-- database that has had this file applied. `admin_teacher_students.sql` in
-- particular now fails outright with "cannot change return type of existing
-- function", because the copy in here returns more columns than the old one.
-- They are kept only for a database that predates this merge.
--
-- ---------------------------------------------------------------------------
-- RUN ORDER, from a clean project
-- ---------------------------------------------------------------------------
--   1. this file                     the schema, every function, every policy
--   2. bundles/questions_all.sql             all 1600 questions and all 60 figures,
--                                    six courses, in one run
--
-- That is the whole installation. There is no step 3.
--
-- If you prefer to load courses one at a time, the per-unit files are still
-- there under questions/ — see questions/00_LOAD_ORDER.md. The only rule is
-- that each course's figures_*.sql runs AFTER its question files, because the
-- per-unit delete takes the figure reference with the row.
--
-- After any re-run of THIS file, re-run the questions too: it rebuilds the
-- questions table, which takes the figures with it.
--
-- WHAT A RE-RUN DESTROYS, AND WHAT IT KEEPS.
--   DROPPED and rebuilt:  questions   (so: re-run the question files after)
--   KEPT:                 everything about people — profiles, attempts,
--                         progress_resets, unit_mastery, classes, enrolments,
--                         tutor_notes, subscriptions
--
-- Nobody has to sign in to reappear. Rosters, the admin list and every
-- dashboard read correctly the moment this file finishes.
--
-- profiles used to be dropped here too, and the effect was quiet and nasty:
-- every student vanished from their tutor's roster until they next happened
-- to sign in. Their work was never gone, but nothing on screen said so, and
-- the tutor could not fix it from their side. It is created-if-missing now
-- and migrated in place.
--
-- ---------------------------------------------------------------------------
-- What is in here
-- ---------------------------------------------------------------------------
--   PART ONE — the student app
--      0  courses              a student picks a course, not a grade
--      1  questions            the bank, with subtopic tags and figures
--      2  profiles             who is signed in, and which course
--      3  attempts             one row per tap, append only
--      4  progress_resets      the soft reset
--      5  unit_mastery         the medal cabinet
--      6  row level security   on the progress tables
--      7  server-side grading  what the app calls instead of reading answers
--      8  staff_roles          who is a teacher, who is an admin
--
--   PART TWO — other people seeing a student's work
--      9  becoming a teacher
--     10  classes and enrolments, with invitations the student accepts
--     11  the access checks    the definer functions the policies rely on
--     12  row level security   for classes
--     13  managing a class
--     14  the dashboard        roster, misconceptions, per-unit, per-student
--     15  the student report, and sharing it
--     16  the admin role       students, tutors, classes, courses
--     17  paying by Interac e-transfer
--     18  tutor review         subtopic diagnosis, and feedback to the student
--     19  permissions
--     20  reporting views
--     21  first run
--
-- ---------------------------------------------------------------------------
-- The one rule this whole file exists to enforce
-- ---------------------------------------------------------------------------
-- The correct answer never reaches the browser. The questions table is
-- readable by NOBODY through RLS — a signed-in student running
-- `select * from questions` gets zero rows. Everything arrives through
-- list_questions(), whose return type has no correct_index and no feedback
-- column, and grading happens in submit_answer() on this side of the wire.
--
-- Every policy in this file is `for select` only. Every write goes through a
-- security-definer function that re-checks who is asking.
--
-- ---------------------------------------------------------------------------
-- BEFORE YOU START
-- ---------------------------------------------------------------------------
-- While testing, turn email confirmation OFF:
--   Authentication -> Sign In / Providers -> Email -> uncheck "Confirm email".
-- Turn it back ON before real students use it.
--
-- Courses, and the grade each belongs to:
--   9   MTH1W  Mathematics (de-streamed)          active
--   9   MPM1D  Principles of Mathematics (old)    retired, not offered
--   10  MPM2D  Principles of Mathematics          active
--   11  MCR3U  Functions                          active
--   12  MHF4U  Advanced Functions                 active
--   12  MCV4U  Calculus and Vectors               active
--   12  MDM4U  Mathematics of Data Management     active
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- 0. Courses
-- ---------------------------------------------------------------------------
-- A student picks a COURSE, not a grade. That distinction only started to
-- matter when the other banks arrived: Grade 12 alone has three separate
-- courses (Advanced Functions, Calculus and Vectors, Data Management) and
-- Grade 9 has two (the new MTH1W and the old MPM1D it replaced). Keyed on
-- grade, all three Grade 12 courses would pour their units into one list
-- and a student would be offered Vectors questions inside a Data Management
-- course.
--
-- So course is the real dimension and grade is a property OF a course, kept
-- for the things that genuinely are about school year: which class a tutor
-- puts a student in, and how a roster reads.
--
-- Everything a student does is now keyed on course. Existing rows were all
-- MPM2D, so the backfills below are exact rather than a guess — no Grade 10
-- history moves or is lost.

create table if not exists courses (
  code    text primary key,          -- 'MPM2D'
  grade   int  not null check (grade between 9 and 12),
  title   text not null,
  ordinal int  not null default 0,   -- display order within a grade
  -- A retired course keeps working for students already in it, and stops
  -- being offered to new ones. MPM1D is the case this exists for.
  active  boolean not null default true
);

insert into courses (code, grade, title, ordinal, active) values
  ('MTH1W', 9,  'Mathematics (de-streamed)',        1, true),
  ('MPM1D', 9,  'Principles of Mathematics (old)',  2, false),
  ('MPM2D', 10, 'Principles of Mathematics',        1, true),
  ('MCR3U', 11, 'Functions',                        1, true),
  ('MHF4U', 12, 'Advanced Functions',               1, true),
  ('MCV4U', 12, 'Calculus and Vectors',             2, true),
  ('MDM4U', 12, 'Mathematics of Data Management',   3, true)
on conflict (code) do update
  set grade = excluded.grade, title = excluded.title,
      ordinal = excluded.ordinal, active = excluded.active;

alter table courses enable row level security;

-- The course list is public: it is what the signup screen offers, and there
-- is nothing in it worth hiding.
drop policy if exists "Courses are readable" on courses;
create policy "Courses are readable" on courses
  for select to anon, authenticated using (true);

-- ---------------------------------------------------------------------------
-- 1. Questions
-- ---------------------------------------------------------------------------

drop table if exists questions;

create table questions (
  id            bigint generated always as identity primary key,
  grade         int    not null check (grade between 9 and 12),
  unit_order    int    not null,   -- order of the unit chips
  sort_order    int    not null,   -- order of questions within a unit
  -- Four levels, and the level IS the difficulty value — no separate table.
  -- Easy and Medium are free; Challenge and Advanced need a subscription,
  -- and that gate lives in the functions below rather than in the interface,
  -- for the same reason the answers do.
  difficulty    text   not null check (difficulty in
                  ('Easy','Medium','Challenge','Advanced')),
  course_code   text   not null,
  unit          text   not null,
  prompt        text   not null,
  correct_index int    not null,
  options       jsonb  not null,
  -- Short slug naming the mistake this question is built to catch. Recorded
  -- on an attempt only when a wrong option is tapped.
  misconception_tag text,
  -- Optional figure shown above the prompt: a path like 'figures/tri_07.png',
  -- served as a static file alongside the app (the web/figures folder ships
  -- with every deploy). Content, not secrets — a figure illustrates the
  -- problem and must never hint at the answer; the review checklist in
  -- AUTHORING_GUIDE.md applies to it like any other part of the question.
  figure        text,
  created_at    timestamptz not null default now()
);

create index questions_grade_unit_idx on questions (grade, unit_order, sort_order);

-- Row level security is on, and there is deliberately NO read policy for
-- students. Nobody signed in can select from this table directly.
--
-- That is the point. correct_index and the per-option feedback both live in
-- here, and anything the browser can fetch, a student can read in the network
-- tab. Section 7 below provides three functions that hand out exactly what
-- the app needs and nothing more.
alter table questions enable row level security;

-- Which courses actually have questions loaded. A course with an empty bank
-- is worse than one that is not offered — the student signs up and finds
-- nothing — so the picker asks this rather than listing the table.
create or replace function list_courses()
returns table (code text, grade int, title text, questions bigint)
language sql
security definer
stable
set search_path = public
as $$
  select c.code, c.grade, c.title, count(q.id)
  from courses c
  join questions q on q.course_code = c.code
  where c.active
  group by c.code, c.grade, c.title, c.ordinal
  having count(q.id) > 0
  order by c.grade, c.ordinal;
$$;


-- ---------------------------------------------------------------------------
-- 2. Student profiles
-- ---------------------------------------------------------------------------
-- Supabase manages the account itself in auth.users. This table holds the
-- extra thing we care about: which grade the student is in.

-- This table is NOT dropped on a re-run, and that is deliberate.
--
-- It used to be. The consequence was quiet and horrible: re-running this file
-- emptied profiles, so every student vanished from their tutor's roster and
-- from the admin list until they happened to sign in again. Their attempts,
-- medals, class and payment were all still on disk the whole time — nothing
-- was lost — but for anyone looking at the screen the school had emptied out.
-- The tutor cannot fix that from their side. Only the student signing in can,
-- and they have no idea they need to.
--
-- So the table is created only if missing, and brought up to date in place by
-- the alters below. Those alters already existed underneath the old drop,
-- which is the tell: the safe path was written and then defeated by the line
-- above it.
--
-- full_name is asked for at signup and is what a teacher sees on a roster.
-- Email addresses are for signing in, not for identifying a child on a
-- screen a teacher scans quickly — half of them are variations on a first
-- name and a birth year, which is both hard to read and more personal
-- information than a roster needs to show.
create table if not exists profiles (
  id         uuid primary key references auth.users on delete cascade,
  email      text,
  full_name  text,
  -- grade stays because classes and rosters are genuinely about school
  -- year. course is what decides which questions this student sees.
  grade      int not null check (grade between 9 and 12),
  course     text references courses (code),
  created_at timestamptz not null default now()
);

-- Bring an older profiles table up to the current shape. Each of these is a
-- no-op on a table that already has the column or constraint, so the whole
-- block is safe on the fifth run as well as the first.
alter table profiles add column if not exists email      text;
alter table profiles add column if not exists created_at timestamptz not null default now();


alter table profiles enable row level security;

-- Each student can see and edit their own row, and no other row.
-- auth.uid() is the id of whoever is making the request.
--
-- Dropped before being created, because the table is no longer dropped: a
-- create policy on an existing policy name is an error, and this file has to
-- survive being run again.

-- The profile photo. The PATH, not a URL. Signed URLs expire by design, so storing one would
-- mean storing something that stops working an hour later. The path is
-- permanent and the URL is minted on demand.
alter table profiles add column if not exists avatar_path text;


-- ---------------------------------------------------------------------------

drop policy if exists "Read own profile" on profiles;
create policy "Read own profile"
  on profiles for select
  to authenticated
  using (auth.uid() = id);

drop policy if exists "Create own profile" on profiles;
create policy "Create own profile"
  on profiles for insert
  to authenticated
  with check (auth.uid() = id);

drop policy if exists "Update own profile" on profiles;
create policy "Update own profile"
  on profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Older databases created profiles before names existed.
alter table profiles add column if not exists full_name text;

-- ...and before courses existed. Every account was Grade 10 MPM2D.
alter table profiles add column if not exists course text;
update profiles set course = case grade when 9 then 'MTH1W'
    when 10 then 'MPM2D' when 11 then 'MCR3U' else 'MHF4U' end
 where course is null;

-- Constraints an older profiles table may predate. These run HERE, after the
-- columns above exist and have been backfilled — a foreign key cannot be
-- added to a column that is not there yet, and that ordering is the whole
-- reason this block is not up beside the create table.
do $$
begin
  if not exists (select 1 from pg_constraint
                 where conname = 'profiles_grade_check') then
    alter table profiles add constraint profiles_grade_check
      check (grade between 9 and 12);
  end if;

  if not exists (select 1 from pg_constraint
                 where conname = 'profiles_course_fkey') then
    alter table profiles add constraint profiles_course_fkey
      foreign key (course) references courses (code);
  end if;
end $$;

-- A student's grade is set at signup and then owned by their tutor
-- (add_student_to_class and set_student_course). The update policy above is
-- for the first-sign-in upsert and the name — but a policy cannot restrict
-- WHICH columns change, so without this trigger one REST call could move a
-- student to a grade their tutor never chose. The security audit caught it.
--
-- Why each caller still works:
--   * the definer functions run with the TEACHER or admin as auth.uid(),
--     which differs from the row id, so they pass;
--   * the app's first-sign-in upsert can race and re-write an identical
--     grade — identical is not distinct, so it passes;
--   * only a student moving their OWN grade to a DIFFERENT value is caught.
create or replace function profiles_guard_grade()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() = old.id
     and (new.grade is distinct from old.grade
          or new.course is distinct from old.course)
     and not exists (select 1 from staff_roles
                     where user_id = auth.uid()
                       and role = 'admin') then
    raise exception 'Your course is set by your tutor.';
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_grade_guard on profiles;
create trigger profiles_grade_guard
  before update on profiles
  for each row execute function profiles_guard_grade();

-- ---------------------------------------------------------------------------
-- 3. attempts — one row per tap, append only
-- ---------------------------------------------------------------------------
-- The source of truth for everything downstream. Scores, medals, resume
-- position, parent reports and the teacher dashboard are all derived from
-- this table, which is why nothing ever updates or deletes a row in it.
--
-- Note what is NOT here: a foreign key to questions.id.
--
-- The question file begins each grade with "delete from questions where
-- grade = N" and re-inserts. Because id is a generated identity column, every
-- re-run hands out brand new ids, so a stored question_id would point at a
-- different question after any content edit — and an "on delete cascade"
-- would wipe every student attempt the moment a typo was fixed.
--
-- So attempts record where a question sits rather than which row it was:
-- (grade, unit, sort_order). Those coordinates are typed by hand in the SQL
-- and stay put. difficulty and misconception_tag are copied onto the attempt
-- as well, so a report is still readable years later even if the question has
-- since been reworded.

create table if not exists attempts (
  id                bigint generated always as identity primary key,
  student_id        uuid not null references auth.users (id) on delete cascade,
  grade             int  not null check (grade between 9 and 12),
  -- The real key. Nullable only so an older table can be upgraded in place;
  -- the backfill below fills it and the column is set not null afterwards.
  course            text,
  unit              text not null,
  sort_order        int  not null,
  difficulty        text,
  chosen_index      int  not null check (chosen_index between 0 and 3),
  was_correct       boolean not null,
  was_first_attempt boolean not null,
  misconception_tag text,
  answered_at       timestamptz not null default now()
);

-- Upgrade an attempts table from before courses existed. Every row was
-- Grade 10 MPM2D, so this is exact, not a guess.
alter table attempts add column if not exists course text;
update attempts a set course = c.code
  from courses c where c.grade = a.grade and a.course is null
   and c.code = case a.grade when 9 then 'MTH1W' when 10 then 'MPM2D'
                             when 11 then 'MCR3U' else 'MHF4U' end;
alter table attempts alter column course set not null;

-- Resume and per-unit scoring read this constantly.
create index if not exists attempts_student_course_idx
  on attempts (student_id, course, unit, answered_at);

-- The teacher dashboard asks "which distractor is the whole class picking",
-- so it reads by question rather than by student.
create index if not exists attempts_question_course_idx
  on attempts (course, unit, sort_order, chosen_index);

-- Weekly parent reports slice by date.
create index if not exists attempts_recent_idx
  on attempts (student_id, answered_at desc);

-- ---------------------------------------------------------------------------
-- 4. progress_resets — the soft reset
-- ---------------------------------------------------------------------------
-- Resetting deletes nothing. It records a moment in time, and everything
-- before it stops counting toward position and score.
--
-- Two reasons it works this way: a student cannot quietly erase a bad week
-- before a parent report, and the teacher dashboard keeps its history. One
-- row per student per COURSE, so resetting Functions leaves Advanced
-- Functions alone — which matters now that one grade can hold three courses.

create table if not exists progress_resets (
  student_id uuid not null references auth.users (id) on delete cascade,
  grade      int  not null check (grade between 9 and 12),
  course     text,
  reset_at   timestamptz not null default now(),
  primary key (student_id, grade)
);

-- Upgrade in place: add course, backfill from grade, then repoint the key.
alter table progress_resets add column if not exists course text;
update progress_resets set course = case grade when 9 then 'MTH1W'
    when 10 then 'MPM2D' when 11 then 'MCR3U' else 'MHF4U' end
 where course is null;
alter table progress_resets alter column course set not null;
do $$
begin
  if exists (select 1 from pg_constraint
             where conname = 'progress_resets_pkey'
               and pg_get_constraintdef(oid) like '%grade%') then
    alter table progress_resets drop constraint progress_resets_pkey;
    alter table progress_resets
      add constraint progress_resets_pkey primary key (student_id, course);
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- 5. unit_mastery — the medal cabinet
-- ---------------------------------------------------------------------------
-- Everything here could be recomputed from attempts. It is stored anyway
-- because a teacher opening a class of thirty should not make the database
-- replay thousands of taps just to draw a list of medals.
--
--   Bronze  every question in the unit answered correctly, however many taps
--   Silver  70% or more right on the first tap
--   Gold    90% or more on the first tap, and every Hard question first try
--
-- Bronze rewards finishing rather than perfection, on purpose. The whole
-- premise of the app is that a wrong tap teaches you something, so the entry
-- tier must never punish a student for tapping one.
--
-- Medals are per LEVEL: finishing Easy earns a medal for Easy. A free
-- student earns real medals on the free levels — the paywall locks harder
-- questions, never recognition for work already done.
--
-- The rule that keeps it honest: values only ever move upward. A bad rerun
-- cannot cost a medal already earned, which also means a soft reset has
-- nothing to farm.

create table if not exists unit_mastery (
  student_id      uuid not null references auth.users (id) on delete cascade,
  grade           int  not null check (grade between 9 and 12),
  course          text,
  unit            text not null,
  level           text not null check (level in
                    ('Easy','Medium','Challenge','Advanced')),
  medal           text not null default 'None'
                  check (medal in ('None', 'Bronze', 'Silver', 'Gold')),
  best_first_try  int  not null default 0,
  total_questions int  not null default 0,
  times_completed int  not null default 0,
  first_earned_at timestamptz,
  updated_at      timestamptz not null default now(),
  primary key (student_id, grade, unit, level)
);

-- Upgrade in place, same shape as attempts and progress_resets.
alter table unit_mastery add column if not exists course text;
update unit_mastery set course = case grade when 9 then 'MTH1W'
    when 10 then 'MPM2D' when 11 then 'MCR3U' else 'MHF4U' end
 where course is null;
alter table unit_mastery alter column course set not null;
do $$
begin
  if exists (select 1 from pg_constraint
             where conname = 'unit_mastery_pkey'
               and pg_get_constraintdef(oid) like '%grade%') then
    alter table unit_mastery drop constraint unit_mastery_pkey;
    alter table unit_mastery add constraint unit_mastery_pkey
      primary key (student_id, course, unit, level);
  end if;
end $$;

-- Upgrading from before levels existed. The old table had one row per unit,
-- no level column, and medals computed under different rules — carrying them
-- across would claim something never earned under the new ones. The table is
-- rebuilt and medals get re-earned. Attempts survive untouched, so nothing a
-- teacher sees is lost.
do $$
begin
  if not exists (select 1 from information_schema.columns
                 where table_schema = 'public'
                   and table_name = 'unit_mastery'
                   and column_name = 'level') then
    drop table unit_mastery cascade;
    create table unit_mastery (
      student_id      uuid not null references auth.users (id) on delete cascade,
      grade           int  not null check (grade between 9 and 12),
      unit            text not null,
      level           text not null check (level in
                        ('Easy','Medium','Challenge','Advanced')),
      medal           text not null default 'None'
                      check (medal in ('None', 'Bronze', 'Silver', 'Gold')),
      best_first_try  int  not null default 0,
      total_questions int  not null default 0,
      times_completed int  not null default 0,
      first_earned_at timestamptz,
      updated_at      timestamptz not null default now(),
      primary key (student_id, grade, unit, level)
    );
  end if;
end
$$;

create index if not exists unit_mastery_student_idx
  on unit_mastery (student_id, grade);

-- ---------------------------------------------------------------------------
-- 5b. subscriptions — who has paid for the harder levels
-- ---------------------------------------------------------------------------
-- One row per student, written ONLY by the Stripe webhook running as
-- service_role. The app can read its own row and nothing else. There is no
-- way to write this table from a browser, which is what makes the paywall
-- real rather than decorative.
--
-- Who is expected to pay: a parent or guardian, not the student. The users
-- are minors, minors cannot form contracts, and Stripe's terms require the
-- purchaser to be an adult. The app's copy says "ask a parent or guardian",
-- and the Stripe account itself should belong to the adult running this.

create table if not exists subscriptions (
  student_id             uuid primary key references auth.users (id)
                         on delete cascade,
  status                 text not null default 'none',
  stripe_customer_id     text,
  stripe_subscription_id text unique,
  current_period_end     timestamptz,
  updated_at             timestamptz not null default now()
);

alter table subscriptions enable row level security;

drop policy if exists "Read own subscription" on subscriptions;
create policy "Read own subscription" on subscriptions
  for select to authenticated using (auth.uid() = student_id);

-- True while paid up. A cancelled subscription stays true until the period
-- already paid for runs out — taking away access a family paid for would be
-- theft with extra steps.
create or replace function has_premium()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  -- THE definition of premium — the admin list and any future check must
  -- defer to this, never re-derive it. 'manual' is an e-transfer grant; it
  -- always carries a period_end, but it is listed here too so the two
  -- halves of the rule cannot drift apart.
  select exists (
    select 1 from subscriptions
    where student_id = auth.uid()
      and (status in ('active', 'trialing', 'manual')
           or (current_period_end is not null
               and current_period_end > now()))
  );
$$;

-- The one place the free/paid line is drawn. Everything else asks this.
create or replace function level_is_free(p_level text)
returns boolean
language sql
immutable
set search_path = public
as $$
  select p_level in ('Easy', 'Medium');
$$;

-- The two writers, callable by the Stripe webhook only.
create or replace function upsert_subscription(
  p_student    uuid,
  p_customer   text,
  p_sub        text,
  p_status     text,
  p_period_end timestamptz
)
returns void
language sql
security definer
set search_path = public
as $$
  insert into subscriptions
    (student_id, stripe_customer_id, stripe_subscription_id, status,
     current_period_end, updated_at)
  values (p_student, p_customer, p_sub, p_status, p_period_end, now())
  on conflict (student_id) do update
    set stripe_customer_id     = excluded.stripe_customer_id,
        stripe_subscription_id = excluded.stripe_subscription_id,
        status                 = excluded.status,
        current_period_end     = excluded.current_period_end,
        updated_at             = now();
$$;

-- subscription.updated / .deleted events carry the Stripe id, not the student.
-- Sets ONLY the Stripe customer id, touching neither status nor period.
--
-- create-checkout needs to remember a newly created Stripe customer before
-- the family has paid anything. It used to do that through
-- upsert_subscription(..., 'none', null) — which, for a student already
-- granted premium by e-transfer, overwrote status 'manual' and wiped their
-- paid period the moment they opened the Astro+ menu. The security audit
-- caught it. This narrow write is what that call actually meant.
create or replace function set_stripe_customer(
  p_student  uuid,
  p_customer text
)
returns void
language sql
security definer
set search_path = public
as $$
  insert into subscriptions (student_id, stripe_customer_id, updated_at)
  values (p_student, p_customer, now())
  on conflict (student_id) do update
    set stripe_customer_id = excluded.stripe_customer_id,
        updated_at         = now();
$$;

create or replace function update_subscription_by_sid(
  p_sub        text,
  p_status     text,
  p_period_end timestamptz
)
returns void
language sql
security definer
set search_path = public
as $$
  update subscriptions
     set status = p_status,
         current_period_end = p_period_end,
         updated_at = now()
   where stripe_subscription_id = p_sub;
$$;

-- ---------------------------------------------------------------------------
-- 6. Row level security on the progress tables
-- ---------------------------------------------------------------------------
-- Same shape as profiles: a student sees only their own rows, and Postgres
-- applies this on every query, so the app cannot bypass it by asking
-- differently.
--
-- Read-only for students on all three. Every write goes through a function in
-- section 7, which is what stops somebody awarding themselves a Gold by
-- calling the REST API directly.

alter table attempts        enable row level security;
alter table progress_resets enable row level security;
alter table unit_mastery    enable row level security;

drop policy if exists "Read own attempts" on attempts;
create policy "Read own attempts" on attempts
  for select to authenticated using (auth.uid() = student_id);

drop policy if exists "Read own resets" on progress_resets;
create policy "Read own resets" on progress_resets
  for select to authenticated using (auth.uid() = student_id);

drop policy if exists "Read own mastery" on unit_mastery;
create policy "Read own mastery" on unit_mastery
  for select to authenticated using (auth.uid() = student_id);

-- ---------------------------------------------------------------------------
-- 7. Server-side grading
-- ---------------------------------------------------------------------------
-- The security fix. Before this, the app fetched whole question rows, so
-- correct_index and all four feedback strings arrived in the browser. Anyone
-- who opened the network tab could read the answer before tapping — and once
-- scores go to parents, that stops being a curiosity and becomes a way to
-- fake a perfect week.
--
-- These functions are "security definer", meaning they run with the rights of
-- the owner and so can read the questions table even though students cannot.
-- Each one hands back the minimum needed:
--
--   list_units      unit names and counts. No question content at all.
--   list_questions  prompts and option TEXT only. No correct_index, and no
--                   feedback, because a feedback string beginning "Correct."
--                   gives the answer away just as plainly as the index does.
--   submit_answer   takes a tap, returns whether it was right and the
--                   feedback for that one option, and logs the attempt.
--   award_medal     recomputes the score from attempts and stores the medal.
--
-- Notice what this also fixes: because submit_answer writes the attempt and
-- award_medal recomputes from attempts, a student cannot forge either one.
-- Integrity and the anti-cheat come from the same change.

-- Older databases carry the pre-level versions of the three functions below,
-- and two of them changed return shape, which "create or replace" cannot do.
-- Dropped here, immediately before their replacements — an earlier draft put
-- these drops AFTER this section, which deleted the new functions right
-- after creating them. Order matters more than tidiness.
drop function if exists list_units(int);
drop function if exists list_questions(int, text);
-- Gained the subtopic and figure output columns; a return type cannot be
-- changed by create or replace.
drop function if exists list_questions(int, text, text);

-- The whole student path moved from grade to course. Postgres cannot change
-- a function's argument types in place, so the grade-keyed versions go.
drop function if exists list_units(int);
drop function if exists list_levels(int, text);
drop function if exists list_questions(int, text, text);
drop function if exists submit_answer(int, text, int, int);
drop function if exists award_medal(int, text, text);
drop function if exists reset_progress(int);
drop function if exists award_medal(int, text);

-- Unit list for the chips: total questions, and how many sit behind the
-- subscription, so the card can say "20 free · 20 with Astro+" honestly.
create or replace function list_units(p_course text)
returns table (unit text, unit_order int, total bigint, locked_total bigint)
language sql
security definer
stable
set search_path = public
as $$
  select q.unit,
         min(q.unit_order)::int,
         count(*),
         count(*) filter (where not level_is_free(q.difficulty))
  from questions q
  where q.course_code = p_course
  group by q.unit
  order by min(q.unit_order);
$$;

-- The four levels of one unit, with this student's standing in each: what
-- exists, what is locked for them, how far they are, and the medal.
--
-- Locked levels still appear, with their question counts. Hiding them would
-- be simpler, but a student should see what the subscription actually buys —
-- and a level that silently does not exist looks like a bug, not a paywall.
create or replace function list_levels(p_course text, p_unit text)
returns table (
  level          text,
  total          bigint,
  locked         boolean,
  solved         bigint,
  first_try      bigint,
  medal          text,
  best_first_try int
)
language sql
security definer
stable
set search_path = public
as $$
  with reset as (
    select r.reset_at from progress_resets r
    where r.student_id = auth.uid() and r.course = p_course
  ),
  mine as (
    select a.difficulty, a.sort_order, a.was_correct, a.was_first_attempt
    from attempts a
    where a.student_id = auth.uid()
      and a.course = p_course and a.unit = p_unit
      and (not exists (select 1 from reset)
           or a.answered_at > (select reset_at from reset))
  )
  select q.difficulty,
         count(distinct q.sort_order),
         not level_is_free(q.difficulty) and not has_premium(),
         count(distinct m.sort_order) filter (where m.was_correct),
         count(distinct m.sort_order)
           filter (where m.was_correct and m.was_first_attempt),
         coalesce(um.medal, 'None'),
         coalesce(um.best_first_try, 0)
  from questions q
  left join mine m on m.difficulty = q.difficulty and m.sort_order = q.sort_order
  left join unit_mastery um
    on um.student_id = auth.uid() and um.course = p_course
   and um.unit = p_unit and um.level = q.difficulty
  where q.course_code = p_course and q.unit = p_unit
  group by q.difficulty, um.medal, um.best_first_try
  order by case q.difficulty
             when 'Easy' then 0 when 'Medium' then 1
             when 'Challenge' then 2 else 3 end;
$$;

-- The questions themselves, stripped of anything that gives away an answer.
--
-- The ordering is within one level, by sort_order. Which level is decided
-- by the caller, and whether the caller is ALLOWED that level is decided
-- right here: a free account asking for Challenge gets an error, not a quiz.
-- The browser of a free student therefore never contains a locked question.
create or replace function list_questions(p_course text, p_unit text,
                                           p_level text)
returns table (
  sort_order  int,
  difficulty  text,
  course_code text,
  unit        text,
  prompt      text,
  options     jsonb,
  -- The subtopic's display name ('Solving by substitution'), safe to show:
  -- it names what the question is about, never what the answer is. This is
  -- the same vocabulary the report and the teacher dashboard use, so a
  -- student sees the label their weak-spot list will later refer to.
  subtopic    text,
  -- Optional figure path for the question card. Null for most questions.
  figure      text
)
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;

  -- The paywall, where it counts. A free account asking for a locked level
  -- gets this error, not the questions — so nothing locked ever reaches
  -- their browser, and there is nothing in the network tab to find.
  if not level_is_free(p_level) and not has_premium() then
    raise exception 'That level needs an Astro+ subscription.';
  end if;

  return query
  select q.sort_order,
         q.difficulty,
         q.course_code,
         q.unit,
         q.prompt,
         (
           select jsonb_agg(jsonb_build_object('text', elem->>'text')
                            order by ord)
           from jsonb_array_elements(q.options) with ordinality as t(elem, ord)
         ),
         misconception_label(q.misconception_tag),
         q.figure
  from questions q
  where q.course_code = p_course
    and q.unit  = p_unit
    and q.difficulty = p_level
  order by q.sort_order;
end;
$$;

-- One tap. Grades it, logs it, returns the feedback for that option only.
--
-- was_first_attempt is worked out here rather than taken from the app. If the
-- app supplied it, a student could claim every answer was a first try and
-- hand themselves a Gold. The server checks whether this question has already
-- been attempted since the last reset, which is a fact the student cannot
-- edit.
create or replace function submit_answer(
  p_course     text,
  p_unit       text,
  p_sort_order int,
  p_chosen     int
)
returns table (was_correct boolean, was_first boolean, feedback text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_question   record;
  v_reset_at   timestamptz;
  v_last_pass  timestamptz;
  v_since      timestamptz;
  v_correct    boolean;
  v_first      boolean;
  v_feedback   text;
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;

  select q.correct_index, q.options, q.difficulty, q.misconception_tag,
         q.grade
    into v_question
  from questions q
  where q.course_code = p_course
    and q.unit = p_unit
    and q.sort_order = p_sort_order;

  if not found then
    raise exception 'No such question.';
  end if;

  if p_chosen < 0 or p_chosen > 3 then
    raise exception 'Option out of range.';
  end if;

  -- The paywall again, on the write path. list_questions already refused to
  -- hand a locked question out, but a hand-crafted REST call could still try
  -- to answer one by number. It gets the same answer here.
  if not level_is_free(v_question.difficulty) and not has_premium() then
    raise exception 'That level needs an Astro+ subscription.';
  end if;

  select r.reset_at into v_reset_at
  from progress_resets r
  where r.student_id = auth.uid() and r.course = p_course;

  -- When this LEVEL of the unit was last completed. Finishing a level closes
  -- a pass, so anything after that timestamp is a fresh attempt at it.
  select m.updated_at into v_last_pass
  from unit_mastery m
  where m.student_id = auth.uid() and m.course = p_course
    and m.unit = p_unit and m.level = v_question.difficulty;

  -- The current pass starts at whichever came later. greatest ignores nulls,
  -- so a student who has never reset and never finished the unit gets null,
  -- meaning every attempt so far counts.
  v_since := greatest(v_reset_at, v_last_pass);

  v_correct  := (p_chosen = v_question.correct_index);
  v_feedback := v_question.options -> p_chosen ->> 'feedback';

  -- First tap at this question IN THIS PASS.
  --
  -- Scoping it to the pass rather than to all time since the last reset is
  -- what makes "try this unit again" worth doing. Measured since the reset,
  -- a question answered once could never be a first attempt again, so a
  -- student stuck on Bronze could only improve by wiping every unit they had
  -- ever done. Now a second run through the unit is scored on its own terms,
  -- and because medals only ever move upward, that run carries no risk.
  v_first := not exists (
    select 1 from attempts a
    where a.student_id = auth.uid()
      and a.course = p_course
      and a.unit = p_unit
      and a.sort_order = p_sort_order
      -- The difficulty too: sort_order alone may repeat across levels once
      -- the new bank numbers each level 1 to 10.
      and a.difficulty = v_question.difficulty
      and (v_since is null or a.answered_at > v_since)
  );

  insert into attempts (
    student_id, grade, course, unit, sort_order, difficulty,
    chosen_index, was_correct, was_first_attempt, misconception_tag
  ) values (
    auth.uid(), v_question.grade, p_course, p_unit, p_sort_order,
    v_question.difficulty,
    p_chosen, v_correct, v_first,
    -- Only a wrong tap represents a misconception. Tagging correct answers
    -- would poison every count in the teacher view.
    case when v_correct then null else v_question.misconception_tag end
  );

  return query select v_correct, v_first, v_feedback;
end;
$$;

-- Works out the medal for a finished LEVEL from the attempts themselves,
-- and stores it only if it beats what is already there.
--
-- Thresholds, on however many questions the level has (ten by convention):
--   Bronze  finished it, however many tries — because tapping wrong answers
--           is how this app teaches, and the entry tier must not punish that
--   Silver  at least 70 percent right on the first tap
--   Gold    at least 90 percent
--
-- The old scheme also demanded every Hard question first-try for Gold. That
-- rule existed because difficulties were mixed inside one run; now a level
-- IS one difficulty, so the percentage already says it.
create or replace function award_medal(p_course text, p_unit text, p_level text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_reset_at    timestamptz;
  v_last_pass   timestamptz;
  v_since       timestamptz;
  v_total       int;
  v_first_try   int;
  v_solved      int;
  v_earned      text;
  v_existing    text;
  v_rank        int;
  v_had_rank    int;
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;

  select count(*) into v_total
  from questions
  where course_code = p_course and unit = p_unit and difficulty = p_level;

  if v_total = 0 then
    return 'None';
  end if;

  -- No medal for a level the student is not entitled to answer. The taps
  -- would have been refused anyway; this closes the loop.
  if not level_is_free(p_level) and not has_premium() then
    return 'None';
  end if;

  select r.reset_at into v_reset_at
  from progress_resets r
  where r.student_id = auth.uid() and r.course = p_course;

  select m.updated_at into v_last_pass
  from unit_mastery m
  where m.student_id = auth.uid() and m.course = p_course
    and m.unit = p_unit and m.level = p_level;

  v_since := greatest(v_reset_at, v_last_pass);

  -- Distinct questions, because a question answered right after three wrong
  -- taps must not count three times.
  select count(distinct a.sort_order) filter (where a.was_correct),
         count(distinct a.sort_order)
           filter (where a.was_correct and a.was_first_attempt)
    into v_solved, v_first_try
  from attempts a
  where a.student_id = auth.uid()
    and a.course = p_course
    and a.unit = p_unit
    and a.difficulty = p_level
    and (v_since is null or a.answered_at > v_since);

  if v_solved < v_total then
    return 'None';
  end if;

  if v_first_try::numeric / v_total >= 0.9 then
    v_earned := 'Gold';
  elsif v_first_try::numeric / v_total >= 0.7 then
    v_earned := 'Silver';
  else
    v_earned := 'Bronze';
  end if;

  select m.medal into v_existing
  from unit_mastery m
  where m.student_id = auth.uid() and m.course = p_course
    and m.unit = p_unit and m.level = p_level;

  v_rank := case v_earned
              when 'Gold' then 3 when 'Silver' then 2
              when 'Bronze' then 1 else 0 end;
  v_had_rank := case coalesce(v_existing, 'None')
                  when 'Gold' then 3 when 'Silver' then 2
                  when 'Bronze' then 1 else 0 end;

  insert into unit_mastery (
    student_id, grade, course, unit, level, medal, best_first_try,
    total_questions, times_completed, first_earned_at, updated_at
  ) values (
    auth.uid(), (select c2.grade from courses c2 where c2.code = p_course),
    p_course, p_unit, p_level,
    case when v_rank >= v_had_rank then v_earned else v_existing end,
    v_first_try, v_total, 1, now(), now()
  )
  on conflict (student_id, course, unit, level) do update set
    -- Upward only. A bad rerun never costs a medal already earned.
    medal = case
              when v_rank >= v_had_rank then v_earned
              else unit_mastery.medal
            end,
    best_first_try  = greatest(unit_mastery.best_first_try, v_first_try),
    total_questions = v_total,
    times_completed = unit_mastery.times_completed + 1,
    updated_at      = now();

  return v_earned;
end;
$$;

-- The soft reset, as a function so the app never writes the table directly.
create or replace function reset_progress(p_course text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;

  insert into progress_resets (student_id, grade, course, reset_at)
  values (auth.uid(), (select c2.grade from courses c2 where c2.code = p_course),
          p_course, now())
  on conflict (student_id, course) do update set reset_at = now();
end;
$$;

-- Students may call these; anonymous visitors may not.
revoke all on function list_units(text)                    from public, anon;
revoke all on function list_questions(text, text, text)    from public, anon;
revoke all on function submit_answer(text, text, int, int) from public, anon;
revoke all on function award_medal(text, text, text)       from public, anon;
revoke all on function list_levels(text, text)             from public, anon;
revoke all on function reset_progress(text)                from public, anon;

grant execute on function list_units(text)               to authenticated;
grant execute on function list_questions(text, text, text)     to authenticated;
grant execute on function submit_answer(text, text, int, int) to authenticated;
grant execute on function award_medal(text, text, text)        to authenticated;
grant execute on function reset_progress(text)           to authenticated;
grant execute on function list_courses()                 to anon, authenticated;

-- ---------------------------------------------------------------------------
-- 8. staff_roles — who is a teacher
-- ---------------------------------------------------------------------------
-- The role does NOT live on profiles, and that is the whole point.
--
-- profiles carries an "Update own profile" policy, because students change
-- their own grade. A role column there would be self-grantable: one REST call
-- and a student is a teacher. So it lives here instead, in a table with a
-- read policy and no write policy whatsoever — not for students, not for
-- teachers, not for admins.
--
-- The only two ways in are an insert from the SQL editor as project owner, or
-- redeeming a teacher access code (section 9). Both are deliberate acts by
-- somebody who already has authority.

create table if not exists staff_roles (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  role       text not null check (role in ('teacher', 'admin')),
  granted_at timestamptz not null default now(),
  note       text
);

alter table staff_roles enable row level security;

-- Read your own row, so the app knows whether to show teacher screens.
-- Nothing else.
drop policy if exists "Read own staff role" on staff_roles;
create policy "Read own staff role" on staff_roles
  for select to authenticated using (auth.uid() = user_id);


-- ===========================================================================
-- PART TWO — Classes, teachers, and parent reports
-- ===========================================================================
-- Everything above this line is the student-facing app. Everything below is
-- about other people seeing a student's work, which is a different problem
-- and a more careful one, because the students are minors.
--
-- Three rules run through the whole of it:
--
--   Nobody sees a student's work without that student knowing. Enrolment is
--   visible in the app, invitations are accepted rather than imposed, and
--   leaving is one tap.
--
--   Access follows a current relationship. A teacher reads a student through
--   a live enrolment in a class they own, checked on every query. End the
--   enrolment and the access ends in the same instant.
--
--   Reports say what to help with, not what happened. Counts and the names
--   of misconceptions, never question text or a log of answers.

-- ---------------------------------------------------------------------------
-- 8b. Retiring older versions of functions whose shape changed
-- ---------------------------------------------------------------------------
-- "create or replace function" can change what a function DOES, but it cannot
-- change what it RETURNS. Adding a column to a returns-table function, or an
-- argument to an existing one, both fail with "cannot change return type of
-- existing function" — and because psql keeps going after an error, the rest
-- of the file would appear to run while quietly leaving the old version in
-- place.
--
-- So anything whose signature has changed since an earlier version of this
-- file gets dropped first. All are "if exists", so this is a no-op on a fresh
-- database.
--
-- Only functions the policies do NOT depend on are listed. teaches_student,
-- is_teacher, is_enrolled_in and owns_class are referenced by row level
-- security policies, so Postgres refuses to drop them — and it never needs
-- to, because they still return a plain boolean.

-- Gained a full_name column, so a teacher sees a person rather than an
-- address.
drop function if exists class_roster(bigint);

-- Gained a kind argument, telling the weekly send apart from one a student
-- triggered. The three-argument version has to go, or a call with three
-- arguments becomes ambiguous between the two.
drop function if exists record_report_sent(bigint, date, jsonb);

-- Output columns were renamed to stop them colliding with the enrolments
-- columns of the same name.
drop function if exists join_class(text);

-- Changed from boolean to a status word so failed guesses commit their
-- rate-limit hit instead of rolling it back.
drop function if exists claim_teacher_role(text);
-- Gained a role argument.
drop function if exists grant_teacher_role(text);

-- Removed with the self-serve flows they belonged to.
drop function if exists join_class(text);

-- Join codes went with join_class. A code nobody can redeem is a button that
-- lies to a teacher, so the generator, the rotate call and the column itself
-- all go. Dropped before the table is touched, because generate_join_code
-- reads classes.join_code and would fail to re-create once the column is gone.
drop function if exists regenerate_join_code(bigint);
drop function if exists generate_join_code();

-- Both lost the join_code output column. A return type cannot be changed by
-- create or replace, so they have to go first.
drop function if exists create_class(text, int);
drop function if exists my_classes();
drop function if exists admin_list_classes();
drop function if exists admin_list_students();
drop function if exists my_classes();
drop function if exists request_report_recipient(text, text);
drop function if exists remove_report_recipient(bigint);
drop function if exists confirm_report_recipient(uuid);
drop function if exists revoke_report_recipient(uuid);
drop function if exists my_report_status();
drop function if exists weekly_report(uuid, date);
drop function if exists reports_due(date);
drop function if exists record_report_sent(bigint, date, jsonb, text);
drop function if exists manual_report_for(uuid);
drop function if exists pending_consents_for(uuid);
drop function if exists mark_consent_sent(bigint);
drop table if exists report_log cascade;
drop table if exists report_recipients cascade;

-- These gained columns as the dashboard grew.
drop function if exists my_classes();
drop function if exists my_classes_as_student();
drop function if exists class_misconceptions(bigint, timestamptz);
drop function if exists class_unit_summary(bigint);
drop function if exists student_detail(uuid);
drop function if exists reports_due(date);

-- Used to hand the consent token back to the caller. That was a mistake: the
-- caller is the student's browser, and a student who can read the token can
-- confirm their own guardian, which makes the whole double opt-in decorative.
-- It returns nothing now, and the token is only ever read server-side.
drop function if exists request_report_recipient(text, text);

-- ---------------------------------------------------------------------------
-- 9. Becoming a teacher
-- ---------------------------------------------------------------------------
-- Teachers are ONBOARDED, not self-declared. There is no code to redeem and
-- no "I am a teacher" button, because a student who finds their way into a
-- teacher account can read every classmate's record — that is too much to
-- hang on a secret string typed into a box.
--
-- The admin runs grant_teacher_role from the SQL editor, which is
-- service_role only. Being service_role means it cannot be reached from any
-- browser at all, however the request is shaped.
--
--   select grant_teacher_role('tutor@school.ca');
--
-- The role defaults to 'teacher'. Pass 'admin' as the second argument for
-- somebody who should also be able to onboard others:
--
--   select grant_teacher_role('you@yours.ca', 'admin');
--
-- The person must have signed up first, so there is an account to promote.
-- Removing a tutor is a delete from staff_roles, and it takes effect on their
-- next query.

create or replace function grant_teacher_role(
  p_email text,
  p_role  text default 'teacher'
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid;
begin
  if p_role not in ('teacher', 'admin') then
    return 'Role must be teacher or admin.';
  end if;

  select id into v_user from auth.users
  where lower(email) = lower(trim(p_email));

  if v_user is null then
    return 'No account with that email. Ask them to sign up first.';
  end if;

  insert into staff_roles (user_id, role, note)
  values (v_user, p_role, 'Onboarded by admin')
  on conflict (user_id) do update set role = excluded.role;

  return 'Done. ' || p_email || ' is now a ' || p_role || '.';
end;
$$;

-- Moving a student between grades. Students cannot do this to themselves any
-- more: the grade decides which question bank they see, and a student who can
-- switch it at will can dodge the work their tutor set. Only a teacher who
-- actually teaches them, or the admin, may change it.
create or replace function set_student_course(p_student uuid, p_course text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (select 1 from courses where code = p_course) then
    raise exception 'No such course.';
  end if;

  if not teaches_student(p_student) then
    raise exception 'You do not teach that student.';
  end if;

  update profiles
     set course = p_course,
         grade = (select c2.grade from courses c2 where c2.code = p_course)
   where id = p_student;
end;
$$;

-- Adding a student to a class by email, replacing the join-code flow. The
-- tutor enrols them; there is no code for a student to type, so there is no
-- code for anyone to guess or pass around.
--
-- Read this next part before changing it, because it is the one place the
-- consent model bends. This writes status = 'active' directly. It does not
-- create an invitation, and the student is not asked. invite_student is the
-- other path and does ask.
--
-- That is deliberate, and it is defensible only because of who this is for: a
-- private tutor enrolling students he already teaches, who already know he
-- sees their work — the enrolment records a relationship that exists off the
-- app rather than creating one. A school is the case where it stops being
-- defensible, because there the teacher and the family have not already had
-- that conversation.
--
-- Three things keep it honest, and all three have to stay true:
--   * the student sees every class they are in, on their front screen
--   * leave_class works without asking anyone, in one tap
--   * only owns_class passes, so no teacher can enrol into another's class
--
-- If this app is ever pointed at a school, invite_student becomes the only
-- way in and this function goes back to service_role.
create or replace function add_student_to_class(p_class_id bigint, p_email text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_student uuid;
  v_grade   int;
begin
  if not owns_class(p_class_id) then
    raise exception 'That is not your class.';
  end if;

  select id into v_student from auth.users
  where lower(email) = lower(trim(p_email));

  if v_student is null then
    return 'No account with that email yet. Ask them to sign up first.';
  end if;

  insert into enrolments (class_id, student_id, status, joined_at)
  values (p_class_id, v_student, 'active', now())
  on conflict (class_id, student_id) do update
    set status = 'active', joined_at = now();

  -- Enrolling also settles their grade, so the tutor never has to ask the
  -- student to pick the right one.
  update profiles p
     set grade = c.grade, course = c.course
    from classes c
   where c.id = p_class_id and p.id = v_student;

  return 'Added.';
end;
$$;

-- 10. Classes
-- ---------------------------------------------------------------------------
-- There is no join code. A class is not something a student can walk into by
-- typing six characters; the tutor puts them in it, and the student is told.
-- The column existed for the self-serve flow that was removed, and a code no
-- function can redeem is worse than no code at all — a teacher reads it out
-- and nothing happens.
--
-- Nothing is ever deleted. A student who leaves gets status 'removed', a
-- finished class gets archived_at. Both cut off teacher access immediately
-- while keeping the history, which is what a school would need if a mark
-- were queried months later.

create table if not exists classes (
  id          bigint generated always as identity primary key,
  teacher_id  uuid not null references auth.users (id) on delete cascade,
  name        text not null,
  grade       int  not null check (grade between 9 and 12),
  -- A class teaches one COURSE. Enrolling a student sets their course from
  -- it, which is what makes "move them to Advanced Functions" a one-tap
  -- action for the tutor rather than a conversation.
  course      text references courses (code),
  created_at  timestamptz not null default now(),
  archived_at timestamptz
);

alter table classes add column if not exists course text;
update classes set course = case grade when 9 then 'MTH1W'
    when 10 then 'MPM2D' when 11 then 'MCR3U' else 'MHF4U' end
 where course is null;

-- For databases created before the code was removed. create table if not
-- exists leaves an existing table alone, so without this the dead column
-- survives every re-run of this file.
alter table classes drop column if exists join_code;

create index if not exists classes_teacher_idx
  on classes (teacher_id) where archived_at is null;

-- status carries the consent model.
--
--   invited  a teacher has asked; the student has not agreed yet and NOTHING
--            of theirs is visible
--   active   the student accepted an invitation, or their tutor enrolled them
--            directly with add_student_to_class
--   removed  either side ended it
--
-- Only 'active' grants a teacher anything, and there are two honest ways to
-- reach it. invite_student asks first and waits. add_student_to_class does
-- not ask — see the long note on that function for why that is allowed here
-- and where it stops being allowed. Either way the student can see the class
-- and leave it in one tap, which is the floor this rests on.
create table if not exists enrolments (
  class_id    bigint not null references classes (id) on delete cascade,
  student_id  uuid   not null references auth.users (id) on delete cascade,
  status      text   not null default 'active'
              check (status in ('invited', 'active', 'removed')),
  invited_at  timestamptz,
  joined_at   timestamptz,
  removed_at  timestamptz,
  primary key (class_id, student_id)
);

-- Upgrade an enrolments table left over from an earlier version.
--
-- The first draft of this schema tracked membership with removed_at alone.
-- status replaced it so an invitation could exist as a state of its own —
-- somebody asked, and the student has not answered yet. Because the create
-- above says "if not exists", an older table survives untouched and the
-- index below would then reference a column that is not there.
--
-- Every statement is conditional, so this is a no-op on a fresh database and
-- a migration on an old one. Existing rows are read across honestly: anything
-- without a removed_at was a real membership, so it becomes active.
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'enrolments'
      and column_name = 'status'
  ) then
    alter table enrolments add column status text;
    alter table enrolments add column if not exists invited_at timestamptz;

    update enrolments
       set status = case when removed_at is null then 'active' else 'removed' end;

    alter table enrolments alter column status set default 'active';
    alter table enrolments alter column status set not null;
  end if;

  if not exists (
    select 1 from pg_constraint where conname = 'enrolments_status_check'
  ) then
    alter table enrolments add constraint enrolments_status_check
      check (status in ('invited', 'active', 'removed'));
  end if;
end
$$;

create index if not exists enrolments_student_idx
  on enrolments (student_id) where status = 'active';

-- ---------------------------------------------------------------------------
-- 11. The access checks
-- ---------------------------------------------------------------------------
-- All three are security definer, which is not a shortcut but a requirement.
-- A policy on classes that queried enrolments would trigger the policy on
-- enrolments, which queries classes, and Postgres aborts with "infinite
-- recursion detected in policy". Running as the owner skips the policy on the
-- inner table and breaks the loop. The auth.uid() test inside each function
-- is what keeps that safe.

create or replace function is_teacher()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from staff_roles
    where user_id = auth.uid() and role in ('teacher', 'admin')
  );
$$;

-- The single most important line in the file: a teacher reaches a student
-- only through a live enrolment in a live class that they own.
create or replace function teaches_student(p_student uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from enrolments e
    join classes c on c.id = e.class_id
    where e.student_id = p_student
      and e.status = 'active'
      and c.teacher_id = auth.uid()
      and c.archived_at is null
  );
$$;

create or replace function is_enrolled_in(p_class bigint)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from enrolments
    where class_id = p_class
      and student_id = auth.uid()
      and status in ('invited', 'active')
  );
$$;

create or replace function owns_class(p_class bigint)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from classes where id = p_class and teacher_id = auth.uid()
  );
$$;

-- ---------------------------------------------------------------------------
-- 12. Row level security for classes
-- ---------------------------------------------------------------------------

alter table classes    enable row level security;
alter table enrolments enable row level security;

drop policy if exists "Teachers read own classes" on classes;
create policy "Teachers read own classes" on classes
  for select to authenticated using (teacher_id = auth.uid());

-- A student can read a class they are in OR have been invited to. Reading an
-- invitation before accepting it is the point: they need to see who is asking.
drop policy if exists "Students read their classes" on classes;
create policy "Students read their classes" on classes
  for select to authenticated using (is_enrolled_in(classes.id));

drop policy if exists "Students read own enrolments" on enrolments;
create policy "Students read own enrolments" on enrolments
  for select to authenticated using (student_id = auth.uid());

drop policy if exists "Teachers read own enrolments" on enrolments;
create policy "Teachers read own enrolments" on enrolments
  for select to authenticated using (owns_class(enrolments.class_id));

-- The three that matter. These sit ALONGSIDE the existing "read own"
-- policies: Postgres ORs select policies together, so a student keeps their
-- own access and a teacher gains their own students, nobody else.

drop policy if exists "Teachers read student attempts" on attempts;
create policy "Teachers read student attempts" on attempts
  for select to authenticated using (teaches_student(student_id));

drop policy if exists "Teachers read student mastery" on unit_mastery;
create policy "Teachers read student mastery" on unit_mastery
  for select to authenticated using (teaches_student(student_id));

drop policy if exists "Teachers read student profiles" on profiles;
create policy "Teachers read student profiles" on profiles
  for select to authenticated using (teaches_student(id));

-- ---------------------------------------------------------------------------
-- 13. Managing a class
-- ---------------------------------------------------------------------------

create or replace function create_class(p_name text, p_course text)
returns table (id bigint, name text, grade int, course text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id bigint;
begin
  if not is_teacher() then
    raise exception 'Only a teacher can create a class.';
  end if;
  if not exists (select 1 from courses where code = p_course) then
    raise exception 'No such course.';
  end if;
  if length(trim(coalesce(p_name, ''))) = 0 then
    raise exception 'Give the class a name.';
  end if;

  insert into classes (teacher_id, name, grade, course)
  values (auth.uid(), trim(p_name),
          (select c2.grade from courses c2 where c2.code = p_course), p_course)
  returning classes.id into v_id;

  return query
    select c.id, c.name, c.grade, c.course from classes c where c.id = v_id;
end;
$$;

-- Everything a teacher needs for their class list, in one call.
--
-- Counted in separate CTEs rather than one grouped join, for the same reason
-- class_roster was rewritten: joining enrolments and attempts together fans
-- every student out into one row per tap, so a class of thirty with a term of
-- practice behind it builds tens of thousands of rows to return three
-- numbers. count(distinct ...) made that correct but not cheap — it hid the
-- cost instead of removing it. Each CTE now aggregates one table.
create or replace function my_classes()
returns table (
  id           bigint,
  name         text,
  grade        int,
  course       text,
  students     bigint,
  invited      bigint,
  active_today bigint,
  created_at   timestamptz
)
language sql
security definer
stable
set search_path = public
as $$
  with mine as (
    select c.id, c.name, c.grade, c.course, c.created_at
    from classes c
    where c.teacher_id = auth.uid()
      and c.archived_at is null
  ),
  heads as (
    -- enrolments is keyed (class_id, student_id), so a plain count is already
    -- one row per person. No distinct needed once attempts is not in the join.
    select e.class_id,
           count(*) filter (where e.status = 'active')  as students,
           count(*) filter (where e.status = 'invited') as invited
    from enrolments e
    join mine m on m.id = e.class_id
    group by e.class_id
  ),
  today as (
    select e.class_id, count(distinct a.student_id) as active_today
    from enrolments e
    join mine m on m.id = e.class_id
    join attempts a on a.student_id = e.student_id
                   and a.course = m.course
    where e.status = 'active'
      and a.answered_at > now() - interval '1 day'
    group by e.class_id
  )
  select m.id, m.name, m.grade, m.course,
         coalesce(h.students, 0),
         coalesce(h.invited, 0),
         coalesce(t.active_today, 0),
         m.created_at
  from mine m
  left join heads h on h.class_id = m.id
  left join today t on t.class_id = m.id
  order by m.created_at desc;
$$;

-- A teacher asking a student to join. Note what this does NOT do: it does not
-- enrol them. It creates an invitation the student has to accept, and until
-- they do, the teacher can see nothing of theirs.
--
-- This is the path the app uses, and the one to keep if this ever leaves the
-- family. add_student_to_class is the shortcut for a tutor enrolling students
-- he already teaches; it skips the asking, and the note on it explains the
-- limits of that.
create or replace function invite_student(p_class_id bigint, p_email text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_student uuid;
begin
  if not owns_class(p_class_id) then
    raise exception 'That is not your class.';
  end if;

  select id into v_student
  from auth.users where lower(email) = lower(trim(p_email));

  if v_student is null then
    raise exception 'No student with that email has an account yet. Ask them to sign up first.';
  end if;

  insert into enrolments (class_id, student_id, status, invited_at)
  values (p_class_id, v_student, 'invited', now())
  on conflict (class_id, student_id) do update
    set status = case when enrolments.status = 'active'
                      then 'active' else 'invited' end,
        invited_at = now(),
        removed_at = null;

  return 'Invitation sent. It appears next time they open the app.';
end;
$$;

-- A student joining with a code. Immediate, because they chose it.
-- join_class is gone. Students are enrolled by their tutor with
-- add_student_to_class, so there is no code to type, share, or guess.

-- What a student sees about who is watching. This function is the reason the
-- app can be honest with them.
create or replace function my_classes_as_student()
returns table (
  class_id      bigint,
  class_name    text,
  grade         int,
  teacher_email text,
  status        text,
  since         timestamptz
)
language sql
security definer
stable
set search_path = public
as $$
  select c.id, c.name, c.grade,
         (select u.email::text from auth.users u where u.id = c.teacher_id),
         e.status,
         coalesce(e.joined_at, e.invited_at)
  from enrolments e
  join classes c on c.id = e.class_id
  where e.student_id = auth.uid()
    and e.status in ('invited', 'active')
    and c.archived_at is null
  order by e.status, coalesce(e.joined_at, e.invited_at) desc;
$$;

create or replace function respond_to_invitation(
  p_class_id bigint,
  p_accept   boolean
)
returns void
language sql
security definer
set search_path = public
as $$
  update enrolments
     set status     = case when p_accept then 'active' else 'removed' end,
         joined_at  = case when p_accept then now() else joined_at end,
         removed_at = case when p_accept then null else now() end
   where class_id = p_class_id
     and student_id = auth.uid()
     and status = 'invited';
$$;

create or replace function leave_class(p_class_id bigint)
returns void
language sql
security definer
set search_path = public
as $$
  update enrolments
     set status = 'removed', removed_at = now()
   where class_id = p_class_id and student_id = auth.uid();
$$;

create or replace function remove_student(p_class_id bigint, p_student uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not owns_class(p_class_id) then
    raise exception 'That is not your class.';
  end if;
  update enrolments
     set status = 'removed', removed_at = now()
   where class_id = p_class_id and student_id = p_student;
end;
$$;

create or replace function archive_class(p_class_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not owns_class(p_class_id) then
    raise exception 'That is not your class.';
  end if;
  update classes set archived_at = now() where id = p_class_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- 14. The dashboard
-- ---------------------------------------------------------------------------

-- Subtopic slug to display name.
--
-- A table now, not a hardcoded case: every authored unit file carries an
-- upsert of its own subtopic names, taken from the material itself, so the
-- dashboard and the parent report speak the vocabulary the student hears in
-- class. An unknown slug degrades into readable words instead of a blank.
create table if not exists misconception_labels (
  tag   text primary key,
  label text not null
);

alter table misconception_labels enable row level security;

drop policy if exists "Labels readable" on misconception_labels;
create policy "Labels readable" on misconception_labels
  for select to anon, authenticated using (true);

create or replace function misconception_label(p_tag text)
returns text
language sql
stable
set search_path = public
as $$
  select coalesce(
    (select label from misconception_labels where tag = p_tag),
    replace(replace(p_tag, 'sub-', ''), '-', ' ')
  );
$$;


-- One row per student. last_active is deliberately prominent: a student who
-- has not opened the app in three weeks is a different problem from one who
-- is practising and struggling, and a score cannot tell those apart.
drop function if exists class_roster(bigint);
create or replace function class_roster(p_class_id bigint)
returns table (
  student_id     uuid,
  full_name      text,
  email          text,
  units_started  bigint,
  units_medalled bigint,
  gold           bigint,
  questions_seen bigint,
  first_try_rate numeric,
  last_active    timestamptz,
  avatar_path    text
)
language sql
security definer
stable
set search_path = public
as $$
  -- attempts and mastery are aggregated SEPARATELY, then joined one row per
  -- student. The obvious version — join both onto the student and count
  -- distinct — multiplies every attempt by every medal first: measured at 39
  -- attempts and 3 medals it built 117 rows to answer questions 39 could,
  -- and a year-end class of thirty would rebuild about 45,000 rows per load.
  -- count(distinct) hid the cost by keeping the answers right.
  with roster as (
    select e.student_id, c.grade, c.course
    from enrolments e
    join classes c on c.id = e.class_id
    where e.class_id = p_class_id
      and e.status = 'active'
      and c.teacher_id = auth.uid()
  ),
  from_attempts as (
    select a.student_id,
           count(distinct a.unit)                               as units_started,
           count(distinct (a.unit, a.difficulty, a.sort_order)) as questions_seen,
           round(100.0 * count(*) filter (where a.was_correct
                                            and a.was_first_attempt)
                 / nullif(count(*) filter (where a.was_first_attempt), 0), 0)
                                                                as first_try_rate,
           max(a.answered_at)                                   as last_active
    from attempts a
    join roster r on r.student_id = a.student_id and r.course = a.course
    group by a.student_id
  ),
  from_mastery as (
    select m.student_id,
           count(distinct m.unit) filter (where m.medal <> 'None')
                                                                as units_medalled,
           count(distinct m.unit) filter (where m.medal = 'Gold') as gold
    from unit_mastery m
    join roster r on r.student_id = m.student_id and r.grade = m.grade
    group by m.student_id
  )
  select
    p.id,
    coalesce(nullif(trim(p.full_name), ''), split_part(p.email, '@', 1)),
    p.email,
    coalesce(fa.units_started, 0),
    coalesce(fm.units_medalled, 0),
    coalesce(fm.gold, 0),
    coalesce(fa.questions_seen, 0),
    fa.first_try_rate,
    fa.last_active,
    p.avatar_path
  from roster r
  join profiles p on p.id = r.student_id
  left join from_attempts fa on fa.student_id = p.id
  left join from_mastery  fm on fm.student_id = p.id
  order by fa.last_active desc nulls last;
$$;

-- The query this whole project exists to make possible.
--
-- Not "the class average is 62%", which tells a teacher nothing they can act
-- on. This says: eleven of your thirty are dropping the minus sign when they
-- expand brackets, and here is the unit where it happens. That is a lesson
-- plan, and it only exists because every distractor was written to match a
-- specific misconception.
create or replace function class_misconceptions(
  p_class_id bigint,
  p_since    timestamptz default null
)
returns table (
  misconception_tag text,
  label             text,
  unit              text,
  times_chosen      bigint,
  students_affected bigint,
  share_of_class    numeric
)
language sql
security definer
stable
set search_path = public
as $$
  with roster as (
    select e.student_id, c.grade, c.course
    from enrolments e
    join classes c on c.id = e.class_id
    where e.class_id = p_class_id
      and e.status = 'active'
      and c.teacher_id = auth.uid()
  ),
  class_size as (select count(*)::numeric as n from roster)
  select a.misconception_tag,
         misconception_label(a.misconception_tag),
         a.unit,
         count(*),
         count(distinct a.student_id),
         round(100.0 * count(distinct a.student_id) / nullif(cs.n, 0), 0)
  from attempts a
  join roster r on r.student_id = a.student_id and r.course = a.course
  cross join class_size cs
  where not a.was_correct
    and a.misconception_tag is not null
    and (p_since is null or a.answered_at >= p_since)
  group by a.misconception_tag, a.unit, cs.n
  order by count(distinct a.student_id) desc, count(*) desc;
$$;

-- Which units the class as a whole is finding hard: what to reteach, rather
-- than who to chase. With per-level medals the gold/silver/bronze columns
-- count medalled LEVELS, not students — three students each with Gold on
-- Easy and Gold on Medium shows six golds.
-- Driven by ATTEMPTS, for the same reason as student_detail above: a unit
-- the class is halfway through, with nobody medalled yet, used to be
-- invisible here.
--
-- avg_first_try changed meaning too. It used to average over medallists
-- only, so a unit the class had struggled through without finishing reported
-- NULL — the worst units were the quietest ones. It now averages over
-- everyone who has attempted the unit.
create or replace function class_unit_summary(p_class_id bigint)
returns table (
  unit           text,
  students_done  bigint,
  students_total bigint,
  avg_first_try  numeric,
  gold           bigint,
  silver         bigint,
  bronze         bigint
)
language sql
security definer
stable
set search_path = public
as $$
  with roster as (
    select e.student_id, c.course
    from enrolments e
    join classes c on c.id = e.class_id
    where e.class_id = p_class_id
      and e.status = 'active'
      and c.teacher_id = auth.uid()
      and c.archived_at is null
  ),
  size as (select count(*) as n from roster),
  bank as (
    select q.unit, q.difficulty, count(*)::numeric as total
    from questions q
    where q.course_code = (select course from roster limit 1)
    group by q.unit, q.difficulty
  ),
  -- Every unit anybody in the class has opened, and how each of them is
  -- doing in it. Driven by attempts, so a unit in progress still appears.
  per_student as (
    select a.unit,
           a.student_id,
           count(distinct (a.difficulty, a.sort_order)) filter
             (where a.was_correct and a.was_first_attempt)::numeric as first_try,
           count(distinct (a.difficulty, a.sort_order))::numeric    as seen
    from attempts a
    join roster r on r.student_id = a.student_id and r.course = a.course
    group by a.unit, a.student_id
  ),
  medals as (
    select m.unit,
           count(*) filter (where m.medal <> 'None') as done,
           count(*) filter (where m.medal = 'Gold')   as gold,
           count(*) filter (where m.medal = 'Silver') as silver,
           count(*) filter (where m.medal = 'Bronze') as bronze
    from unit_mastery m
    join roster r on r.student_id = m.student_id and r.course = m.course
    group by m.unit
  ),
  units as (
    select unit from per_student
    union
    select unit from medals
  )
  select u.unit,
         coalesce(md.done, 0),
         (select n from size),
         (select round(avg(100.0 * ps.first_try / nullif(ps.seen, 0)), 0)
            from per_student ps where ps.unit = u.unit),
         coalesce(md.gold, 0),
         coalesce(md.silver, 0),
         coalesce(md.bronze, 0)
  from units u
  left join medals md on md.unit = u.unit
  order by (select round(avg(100.0 * ps.first_try / nullif(ps.seen, 0)), 0)
              from per_student ps where ps.unit = u.unit) asc nulls last,
           u.unit;
$$;

-- How the class is doing topic by topic.
--
-- This is the view a teacher actually plans from: not who is behind, but
-- which topics the room as a whole has not got. students_struggling counts
-- anyone with two or more wrong taps in the unit, which is a better signal
-- than an average — an average hides a split class, where half have it cold
-- and half are lost.
create or replace function class_unit_breakdown(p_class_id bigint)
returns table (
  unit                text,
  unit_order          int,
  students_attempted  bigint,
  students_finished   bigint,
  questions_attempted bigint,
  wrong_taps          bigint,
  first_try_rate      numeric,
  students_struggling bigint,
  top_mistake         text
)
language sql
security definer
stable
set search_path = public
as $$
  with roster as (
    select e.student_id, c.grade, c.course
    from enrolments e
    join classes c on c.id = e.class_id
    where e.class_id = p_class_id
      and e.status = 'active'
      and c.teacher_id = auth.uid()
  ),
  class_attempts as (
    select a.*
    from attempts a
    join roster r on r.student_id = a.student_id and r.course = a.course
  ),
  struggling as (
    select unit, count(*) as n
    from (
      select unit, student_id
      from class_attempts
      where not was_correct
      group by unit, student_id
      having count(*) >= 2
    ) t
    group by unit
  )
  select
    ca.unit,
    (select min(q.unit_order) from questions q
      where q.unit = ca.unit and q.course_code = ca.course),
    count(distinct ca.student_id),
    (select count(distinct m.student_id) from unit_mastery m
      join roster r2 on r2.student_id = m.student_id
      where m.unit = ca.unit and m.medal <> 'None'),
    count(distinct (ca.student_id, ca.sort_order)),
    count(*) filter (where not ca.was_correct),
    round(100.0 * count(*) filter (where ca.was_correct
                                     and ca.was_first_attempt)
          / nullif(count(*) filter (where ca.was_first_attempt), 0), 0),
    coalesce((select n from struggling s where s.unit = ca.unit), 0),
    (select misconception_label(w.misconception_tag)
       from class_attempts w
      where w.unit = ca.unit and not w.was_correct
        and w.misconception_tag is not null
      group by w.misconception_tag
      order by count(distinct w.student_id) desc, count(*) desc
      limit 1)
  from class_attempts ca
  group by ca.unit, ca.grade, ca.course
  -- Hardest first, since that is what a teacher is looking for.
  order by round(100.0 * count(*) filter (where ca.was_correct
                                            and ca.was_first_attempt)
                 / nullif(count(*) filter (where ca.was_first_attempt), 0), 0)
           asc nulls last;
$$;

-- The individual questions the class is failing, worst first.
--
-- This returns the prompt and the wrong option most of them picked, which
-- is more than a student is ever allowed to see. That is deliberate and it
-- is safe: the caller must own the class, and correct_index is still never
-- returned. A teacher needs to see the actual question to reteach it; a
-- student seeing the same payload would be able to eliminate an option.
create or replace function class_hard_questions(p_class_id bigint)
returns table (
  unit           text,
  sort_order     int,
  difficulty     text,
  prompt         text,
  students_wrong bigint,
  times_wrong    bigint,
  top_choice     text,
  top_feedback   text,
  mistake        text
)
language sql
security definer
stable
set search_path = public
as $$
  with roster as (
    select e.student_id, c.grade, c.course
    from enrolments e
    join classes c on c.id = e.class_id
    where e.class_id = p_class_id
      and e.status = 'active'
      and c.teacher_id = auth.uid()
  ),
  wrongs as (
    select a.course, a.unit, a.sort_order, a.chosen_index, a.student_id
    from attempts a
    join roster r on r.student_id = a.student_id and r.course = a.course
    where not a.was_correct
  ),
  per_question as (
    select course, unit, sort_order,
           count(*) as times_wrong,
           count(distinct student_id) as students_wrong
    from wrongs
    group by course, unit, sort_order
  ),
  -- The single wrong option chosen most often. distinct on keeps the first
  -- row per question once ordered by frequency, which is the mode.
  top_choice as (
    select distinct on (course, unit, sort_order)
           course, unit, sort_order, chosen_index
    from (
      select course, unit, sort_order, chosen_index, count(*) as n
      from wrongs
      group by course, unit, sort_order, chosen_index
    ) t
    order by course, unit, sort_order, n desc
  )
  select q.unit,
         q.sort_order,
         q.difficulty,
         q.prompt,
         pq.students_wrong,
         pq.times_wrong,
         q.options -> tc.chosen_index ->> 'text',
         q.options -> tc.chosen_index ->> 'feedback',
         misconception_label(q.misconception_tag)
  from per_question pq
  join top_choice tc
    on tc.course = pq.course and tc.unit = pq.unit
   and tc.sort_order = pq.sort_order
  join questions q
    on q.course_code = pq.course and q.unit = pq.unit
   and q.sort_order = pq.sort_order
  order by pq.students_wrong desc, pq.times_wrong desc;
$$;

-- Everything about one student, for a teacher opening their row.
--
-- Same shape as the parent report so the two can never tell different
-- stories about the same child, but all-time rather than one week, and it
-- includes the email because a teacher may need to contact them.
create or replace function student_overview(p_student uuid)
returns jsonb
language sql
security definer
stable
set search_path = public
as $$
  with allowed as (
    select teaches_student(p_student) as ok
  ),
  mine as (
    select a.* from attempts a, allowed
    where allowed.ok and a.student_id = p_student
  ),
  totals as (
    select count(distinct (unit, sort_order))                  as questions_seen,
           count(*) filter (where was_correct
                              and was_first_attempt)           as first_try,
           count(*) filter (where was_first_attempt)           as first_taps,
           count(*) filter (where not was_correct)             as wrong_taps,
           count(distinct unit)                                as units_touched,
           count(distinct date_trunc('day', answered_at))      as days_active,
           max(answered_at)                                    as last_active
    from mine
  ),
  per_unit as (
    select m.unit, count(distinct m.sort_order) as questions,
           count(*) filter (where m.was_correct
                              and m.was_first_attempt)     as first_try,
           count(*) filter (where not m.was_correct)       as wrong_taps,
           (select um.medal from unit_mastery um
             where um.student_id = p_student and um.unit = m.unit
               and um.grade = m.grade and um.medal <> 'None'
             order by case um.medal when 'Gold' then 3
                      when 'Silver' then 2 else 1 end desc
             limit 1)                                      as medal
    from mine m
    group by m.unit, m.grade
    order by count(distinct m.sort_order) desc
  ),
  weak as (
    select misconception_tag as tag, unit, count(*) as times,
           count(distinct sort_order) as questions
    from mine
    where not was_correct and misconception_tag is not null
    group by misconception_tag, unit
    order by count(*) desc
    limit 5
  )
  select case when not (select ok from allowed) then null else
    jsonb_build_object(
      'student_id',     p_student,
      'name',           (select coalesce(nullif(trim(full_name), ''),
                                split_part(email, '@', 1))
                           from profiles where id = p_student),
      'email',          (select email from profiles where id = p_student),
      'grade',          (select grade from profiles where id = p_student),
      'questions_seen', coalesce(t.questions_seen, 0),
      'first_try',      coalesce(t.first_try, 0),
      'first_try_rate', round(100.0 * t.first_try / nullif(t.first_taps, 0), 0),
      'wrong_taps',     coalesce(t.wrong_taps, 0),
      'units_touched',  coalesce(t.units_touched, 0),
      'days_active',    coalesce(t.days_active, 0),
      'last_active',    t.last_active,
      'units',          coalesce((select jsonb_agg(jsonb_build_object(
                            'unit', pu.unit, 'questions', pu.questions,
                            'first_try', pu.first_try,
                            'wrong_taps', pu.wrong_taps,
                            'medal', coalesce(pu.medal, 'None')))
                          from per_unit pu), '[]'::jsonb),
      'weak_spots',     coalesce((select jsonb_agg(jsonb_build_object(
                            'label', misconception_label(w.tag),
                            'unit', w.unit, 'times', w.times,
                            'questions', w.questions))
                          from weak w), '[]'::jsonb)
    )
  end
  from totals t;
$$;

-- One student in detail, for an intervention or a parents evening.
-- One row per unit and level, so "Silver on Easy, nothing on Challenge yet"
-- is visible rather than averaged away.
-- Driven by ATTEMPTS, not by unit_mastery.
--
-- This function used to read unit_mastery alone. That table is the medal
-- cabinet: a row appears only when award_medal runs, which happens only when
-- a student finishes a whole level. So the drill-down was blank for any
-- student who practises without finishing — which is exactly the student a
-- tutor opens this screen to look at. A real fixture had 25 attempts across
-- all four levels of one unit and returned nothing at all.
--
-- Now the driving set is the levels the student has actually opened, with
-- unit_mastery left-joined for the medal.
create or replace function student_detail(p_student uuid)
returns table (
  unit           text,
  level          text,
  medal          text,
  best_first_try int,
  total          int,
  wrong_taps     bigint,
  top_mistake    text,
  last_active    timestamptz
)
language sql
security definer
stable
set search_path = public
as $$
  with me as (
    -- Re-checked here rather than trusted from the caller, the same as every
    -- other function on the dashboard. No rows, not an error.
    select p.id, p.course
    from profiles p
    where p.id = p_student and teaches_student(p_student)
  ),
  reset as (
    select r.reset_at from progress_resets r
    join me on me.id = r.student_id and r.course = me.course
  ),
  mine as (
    select a.* from attempts a, me
    where a.student_id = me.id
      and a.course = me.course
      and (not exists (select 1 from reset)
           or a.answered_at > (select reset_at from reset))
  ),
  -- Levels the student has actually opened. This is the driving set now.
  touched as (
    select m.unit, m.difficulty as level,
           count(*) filter (where not m.was_correct)        as wrong_taps,
           count(distinct m.sort_order) filter
             (where m.was_correct and m.was_first_attempt)  as first_try_now,
           max(m.answered_at)                               as last_active
    from mine m
    group by m.unit, m.difficulty
  ),
  bank as (
    select q.unit, q.difficulty as level, count(*)::int as total
    from questions q, me
    where q.course_code = me.course
    group by q.unit, q.difficulty
  ),
  rows as (
    select t.unit,
           t.level,
           coalesce(um.medal, 'None')                       as medal,
           -- unit_mastery holds the best run ever recorded, which is what
           -- the medal was given for. The run in progress can be better than
           -- that and not yet claimed, so report whichever is higher.
           greatest(coalesce(um.best_first_try, 0),
                    t.first_try_now)::int                   as best_first_try,
           b.total,
           t.wrong_taps,
           (select misconception_label(a.misconception_tag)
              from mine a
             where a.unit = t.unit and a.difficulty = t.level
               and not a.was_correct and a.misconception_tag is not null
             group by a.misconception_tag
             order by count(*) desc, a.misconception_tag
             limit 1)                                       as top_mistake,
           t.last_active
    from touched t
    join bank b on b.unit = t.unit and b.level = t.level
    left join unit_mastery um
           on um.student_id = p_student
          and um.course = (select course from me)
          and um.unit  = t.unit
          and um.level = t.level
  )
  select r.unit, r.level, r.medal, r.best_first_try, r.total,
         r.wrong_taps, r.top_mistake, r.last_active
  from rows r
  -- Weakest unit first, because this list is a plan for the next session.
  -- Inside a unit, the natural Easy-to-Advanced order, because that is how a
  -- tutor reads a ladder.
  order by (select avg(100.0 * r2.best_first_try / nullif(r2.total, 0))
              from rows r2 where r2.unit = r.unit) asc nulls first,
           r.unit,
           case r.level when 'Easy' then 0 when 'Medium' then 1
                        when 'Challenge' then 2 else 3 end;
$$;

-- ===========================================================================
-- 15. The student report, and sharing it
-- ===========================================================================
-- The report belongs to the STUDENT. They open it, read it, and decide who
-- else sees it by generating a link. There is no email, no consent dance, and
-- no address list — the earlier design pushed reports at guardians, and this
-- one lets the student pull the report and pass it on.
--
-- Two callers, one body of statistics:
--
--   my_report()          the signed-in student, reading their own
--   shared_report(token) anyone holding a share link, no account needed
--
-- Both call report_payload(), so a shared link can never disagree with what
-- the student sees.
--
-- What a share link deliberately does NOT carry: surname, email address, or
-- class membership. A link can be forwarded anywhere, screenshotted into a
-- group chat, and lives until revoked. First name and marks are enough for
-- "look how I am doing"; the rest would make it a permanent public record of
-- a child's schooling. Revoking is one call and instantly kills the old URL.

create table if not exists report_shares (
  token       uuid primary key default gen_random_uuid(),
  student_id  uuid not null references auth.users (id) on delete cascade,
  created_at  timestamptz not null default now(),
  revoked_at  timestamptz,
  view_count  int not null default 0
);

create index if not exists report_shares_student_idx
  on report_shares (student_id) where revoked_at is null;

alter table report_shares enable row level security;

drop policy if exists "Read own shares" on report_shares;
create policy "Read own shares" on report_shares
  for select to authenticated using (auth.uid() = student_id);

-- ---------------------------------------------------------------------------
-- The statistics
-- ---------------------------------------------------------------------------
-- One jsonb document: headline numbers, a per-unit breakdown with a colour
-- band, per-level detail inside each unit, and the subtopics costing the most
-- wrong taps.
--
-- The colour band is decided HERE rather than in the app, so the mind map,
-- the bar chart and any future consumer all agree on what "struggling" means.
-- It is based on first-try rate, not on how much was completed: a student who
-- has finished a unit by guessing has not learned it, and a student halfway
-- through with every question right is doing fine.
--
--   green   70 percent or more first try
--   amber   45 to 69
--   red     under 45
--   grey    not enough attempts to judge (fewer than 4)

create or replace function report_payload(p_student uuid)
returns jsonb
language sql
security definer
stable
set search_path = public
as $$
  with me as (
    select p.id, p.grade, p.course,
           -- First name only. See the note at the top of this section.
           split_part(
             coalesce(nullif(trim(p.full_name), ''),
                      split_part(p.email, '@', 1)), ' ', 1) as first_name
    from profiles p where p.id = p_student
  ),
  reset as (
    select r.reset_at from progress_resets r
    join me on me.id = r.student_id and r.course = me.course
  ),
  mine as (
    select a.* from attempts a, me
    where a.student_id = me.id and a.course = me.course
      and (not exists (select 1 from reset)
           or a.answered_at > (select reset_at from reset))
  ),
  bank as (
    select q.unit, q.unit_order, q.difficulty, q.sort_order
    from questions q, me where q.course_code = me.course
  ),
  -- Per unit and level: how much exists, how much is solved, first-try count.
  per_level as (
    select b.unit, b.unit_order, b.difficulty as level,
           count(distinct b.sort_order) as total,
           count(distinct m.sort_order) filter (where m.was_correct) as solved,
           count(distinct m.sort_order)
             filter (where m.was_correct and m.was_first_attempt) as first_try
    from bank b
    left join mine m
      on m.unit = b.unit and m.difficulty = b.difficulty
     and m.sort_order = b.sort_order
    group by b.unit, b.unit_order, b.difficulty
  ),
  per_unit as (
    select pl.unit, pl.unit_order,
           sum(pl.total)::int     as total,
           sum(pl.solved)::int    as solved,
           sum(pl.first_try)::int as first_try,
           -- attempts that counted as a first look, for the rate below
           (select count(*) from mine m2
             where m2.unit = pl.unit and m2.was_first_attempt) as first_looks,
           (select count(*) from mine m3
             where m3.unit = pl.unit and m3.was_first_attempt
               and m3.was_correct) as first_hits
    from per_level pl
    group by pl.unit, pl.unit_order
  ),
  -- The subtopic vocabulary of this grade's bank, whether practised or not:
  -- the mindmap shows the whole course, grey where nothing has happened yet.
  sub_bank as (
    select q2.unit, q2.misconception_tag as tag,
           min(q2.sort_order) as first_seen,
           count(*) as questions
    from questions q2, me
    where q2.course_code = me.course and q2.misconception_tag is not null
    group by q2.unit, q2.misconception_tag
  ),
  -- Per-subtopic first-try numbers. Joined to questions by the attempt's
  -- coordinates, because the tag is only stored on the attempt when the tap
  -- was wrong — the question row always knows its subtopic.
  sub_stats as (
    select q2.unit, q2.misconception_tag as tag,
           count(*) filter (where m.was_first_attempt) as first_looks,
           count(*) filter (where m.was_first_attempt and m.was_correct)
             as first_hits
    from mine m
    join questions q2
      on q2.course_code = m.course and q2.unit = m.unit
     and q2.sort_order = m.sort_order
    where q2.misconception_tag is not null
    group by q2.unit, q2.misconception_tag
  ),
  unit_json as (
    select pu.unit_order, jsonb_build_object(
      'unit', pu.unit,
      'total', pu.total,
      'solved', pu.solved,
      'first_try', pu.first_try,
      'percent_complete',
        case when pu.total = 0 then 0
             else round(100.0 * pu.solved / pu.total)::int end,
      'first_try_rate',
        case when pu.first_looks = 0 then null
             else round(100.0 * pu.first_hits / pu.first_looks)::int end,
      -- Five bands, traffic-signal style, matching the mindmap design:
      -- grey (not enough evidence) → orange (struggling) → yellow
      -- (developing) → light-green (nearing) → green (mastered).
      -- Still first-try rate, never completion: a student who finished a
      -- unit by guessing has not learned it, and a green bar would lie.
      'band',
        case
          when pu.first_looks < 4 then 'grey'
          when 100.0 * pu.first_hits / pu.first_looks >= 90 then 'green'
          when 100.0 * pu.first_hits / pu.first_looks >= 70 then 'light-green'
          when 100.0 * pu.first_hits / pu.first_looks >= 50 then 'yellow'
          else 'orange'
        end,
      -- One node per subtopic for the mindmap: every subtopic in the bank
      -- appears (grey until practised), with its own first-try band. The
      -- join back to questions is what recovers the tag for CORRECT taps —
      -- attempts only store it on wrong ones.
      'subtopics', (
        select coalesce(jsonb_agg(jsonb_build_object(
                 'tag', sb.tag,
                 'label', misconception_label(sb.tag),
                 'questions', sb.questions,
                 'first_looks', coalesce(ss.first_looks, 0),
                 'first_try_rate',
                   case when coalesce(ss.first_looks, 0) = 0 then null
                        else round(100.0 * ss.first_hits / ss.first_looks)::int
                   end,
                 'band',
                   case
                     when coalesce(ss.first_looks, 0) < 2 then 'grey'
                     when 100.0 * ss.first_hits / ss.first_looks >= 90
                       then 'green'
                     when 100.0 * ss.first_hits / ss.first_looks >= 70
                       then 'light-green'
                     when 100.0 * ss.first_hits / ss.first_looks >= 50
                       then 'yellow'
                     else 'orange'
                   end
               ) order by sb.first_seen), '[]'::jsonb)
        from sub_bank sb
        left join sub_stats ss on ss.unit = sb.unit and ss.tag = sb.tag
        where sb.unit = pu.unit
      ),
      'levels', (
        select jsonb_agg(jsonb_build_object(
                 'level', pl.level,
                 'total', pl.total,
                 'solved', pl.solved,
                 'first_try', pl.first_try,
                 'medal', coalesce(um.medal, 'None'))
               order by case pl.level
                          when 'Easy' then 0 when 'Medium' then 1
                          when 'Challenge' then 2 else 3 end)
        from per_level pl
        left join unit_mastery um
          on um.student_id = p_student and um.unit = pl.unit
         and um.level = pl.level
         and um.course = (select course from me)
        where pl.unit = pu.unit
      )
    ) as j
    from per_unit pu
  ),
  -- What is costing them the most. Subtopics, ordered by wrong taps.
  weak as (
    select misconception_label(m.misconception_tag) as topic,
           count(*) as wrong_taps,
           m.unit
    from mine m
    where not m.was_correct and m.misconception_tag is not null
    group by m.misconception_tag, m.unit
    order by count(*) desc
    limit 6
  )
  select jsonb_build_object(
    'first_name',  (select first_name from me),
    'grade',       (select grade from me),
    'course',      (select course from me),
    'generated_at', now(),
    'questions_seen',
      (select count(distinct (unit, difficulty, sort_order)) from mine),
    'total_taps',   (select count(*) from mine),
    'days_practised',
      (select count(distinct date_trunc('day', answered_at)) from mine),
    'last_active',  (select max(answered_at) from mine),
    'first_try_rate',
      (select case when count(*) filter (where was_first_attempt) = 0
                   then null
                   else round(100.0 * count(*) filter (
                          where was_first_attempt and was_correct)
                        / count(*) filter (where was_first_attempt))::int end
       from mine),
    'medals', (
      select jsonb_build_object(
        'gold',   count(*) filter (where medal = 'Gold'),
        'silver', count(*) filter (where medal = 'Silver'),
        'bronze', count(*) filter (where medal = 'Bronze'))
      from unit_mastery
      where student_id = p_student and course = (select course from me)),
    'units', coalesce(
      (select jsonb_agg(j order by unit_order) from unit_json), '[]'::jsonb),
    'weak_topics', coalesce(
      (select jsonb_agg(jsonb_build_object(
                'topic', topic, 'unit', unit, 'wrong_taps', wrong_taps))
       from weak), '[]'::jsonb)
  );
$$;

-- The student reading their own report.
create or replace function my_report()
returns jsonb
language sql
security definer
stable
set search_path = public
as $$
  select report_payload(auth.uid());
$$;

-- ---------------------------------------------------------------------------
-- Sharing
-- ---------------------------------------------------------------------------

-- Returns the student's live share token, creating one on first use. Calling
-- it repeatedly hands back the SAME token, so a link already given to a
-- parent keeps working — only revoke_share breaks it on purpose.
create or replace function my_share_token()
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

  select token into v_token from report_shares
  where student_id = auth.uid() and revoked_at is null
  order by created_at desc limit 1;

  if v_token is null then
    insert into report_shares (student_id) values (auth.uid())
    returning token into v_token;
  end if;

  return v_token;
end;
$$;

-- Kills every live link and issues a fresh one. The old URL stops working
-- immediately, which is the whole point: a link that cannot be taken back is
-- a link that should never have been given.
create or replace function revoke_and_reissue_share()
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

  update report_shares set revoked_at = now()
  where student_id = auth.uid() and revoked_at is null;

  insert into report_shares (student_id) values (auth.uid())
  returning token into v_token;

  return v_token;
end;
$$;

-- Stops sharing altogether, with nothing reissued.
create or replace function revoke_share()
returns void
language sql
security definer
set search_path = public
as $$
  update report_shares set revoked_at = now()
  where student_id = auth.uid() and revoked_at is null;
$$;

-- The public read. Callable by anon — the token IS the authentication, which
-- is why it is a random uuid and why revoking has to work instantly.
--
-- A revoked or unknown token returns null rather than an error, so the page
-- can say "this link is no longer active" without leaking whether it ever
-- existed.
create or replace function shared_report(p_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_student uuid;
begin
  select student_id into v_student from report_shares
  where token = p_token and revoked_at is null;

  if v_student is null then
    return null;
  end if;

  update report_shares set view_count = view_count + 1 where token = p_token;

  return report_payload(v_student);
end;
$$;

-- Whether a share link is currently live, for the button state.
create or replace function my_share_status()
returns table (token uuid, created_at timestamptz, view_count int)
language sql
security definer
stable
set search_path = public
as $$
  select s.token, s.created_at, s.view_count
  from report_shares s
  where s.student_id = auth.uid() and s.revoked_at is null
  order by s.created_at desc limit 1;
$$;

-- ---------------------------------------------------------------------------
-- 16. The admin role
-- ---------------------------------------------------------------------------
-- One person — in practice the uncle — who runs the whole operation from
-- inside the app: sees every student and their plan, onboards tutors, puts a
-- paying student into a tutor's class, fixes a grade, confirms an e-transfer.
--
-- READ THIS BEFORE LOOSENING ANYTHING. Until now the teacher role could only
-- be granted from the SQL editor, unreachable from any browser. Moving that
-- into the app is a deliberate relaxation, and it is contained by three rules:
--
--   * admin_make_teacher grants 'teacher' and NOTHING ELSE. There is no
--     in-app path to the admin role — that still takes grant_teacher_role
--     from the SQL editor, service_role only. A stolen admin password can
--     mint tutors; it cannot mint another admin.
--   * every admin_* function re-checks is_admin() inside its own body, the
--     same pattern the teacher dashboard uses.
--   * admin_revoke_teacher refuses to touch an admin row, so an admin
--     cannot be locked out from the browser either.
--
-- What that leaves as the real exposure: the admin account IS the keys to
-- every student's data. One account, a strong password, and it belongs to
-- the person who runs the tutoring — nobody else.
--
-- "Reset a password" needs no function here: the app fires Supabase's own
-- reset email at the student's address. The admin never sees or sets a
-- password, which is exactly right.

create or replace function is_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from staff_roles
    where user_id = auth.uid() and role = 'admin'
  );
$$;

-- Every student, with the two things the admin actually manages: their plan
-- and their class. One row per student; classes aggregated into one label.
drop function if exists admin_list_students();
create or replace function admin_list_students()
returns table (
  student_id   uuid,
  full_name    text,
  email        text,
  grade        int,
  course       text,
  plan_status  text,
  premium      boolean,
  period_end   timestamptz,
  classes      text,
  last_active  timestamptz,
  avatar_path  text
)
language sql
security definer
stable
set search_path = public
as $$
  with cls as (
    select e.student_id,
           string_agg(c.name || ' (' || u.email || ')', ', '
                      order by c.name) as classes
    from enrolments e
    join classes c on c.id = e.class_id and c.archived_at is null
    join auth.users u on u.id = c.teacher_id
    where e.status = 'active'
    group by e.student_id
  ),
  act as (
    select a.student_id, max(a.answered_at) as last_active
    from attempts a group by a.student_id
  )
  select p.id, p.full_name, p.email, p.grade, p.course,
         coalesce(s.status, 'none'),
         (s.status in ('active', 'trialing', 'manual')
            or (s.current_period_end is not null
                and s.current_period_end > now())) is true,
         s.current_period_end,
         cls.classes,
         act.last_active,
         p.avatar_path
  from profiles p
  left join subscriptions s on s.student_id = p.id
  left join cls on cls.student_id = p.id
  left join act on act.student_id = p.id
  where is_admin()
    and not exists (select 1 from staff_roles r where r.user_id = p.id)
  order by p.full_name;
$$;

create or replace function admin_list_teachers()
returns table (
  user_id     uuid,
  email       text,
  role        text,
  granted_at  timestamptz,
  class_count bigint,
  student_count bigint
)
language sql
security definer
stable
set search_path = public
as $$
  select r.user_id, u.email, r.role, r.granted_at,
         count(distinct c.id),
         count(distinct e.student_id) filter (where e.status = 'active')
  from staff_roles r
  join auth.users u on u.id = r.user_id
  left join classes c on c.teacher_id = r.user_id and c.archived_at is null
  left join enrolments e on e.class_id = c.id
  where is_admin()
  group by r.user_id, u.email, r.role, r.granted_at
  order by r.granted_at;
$$;

-- ---------------------------------------------------------------------------
-- One tutor's students, for the admin panel
-- ---------------------------------------------------------------------------
-- admin_list_teachers tells you a tutor has 3 classes and 14 students. It
-- does not tell you WHO. Before this there was no edge from a tutor to the
-- people they teach: the only route was to open all forty students one at a
-- time and read their classes column.
--
-- class_roster already answers this shape of question, but it is deliberately
-- teacher-only: it filters on `c.teacher_id = auth.uid()`, meaning YOU teach
-- them. An admin teaches nobody, so it returns nothing for them — correct for
-- what it is, and useless here. This is the admin-side twin: same statistics,
-- same one-row-per-student shape, scoped to a NAMED teacher, gated on
-- is_admin() instead.
-- ---------------------------------------------------------------------------

drop function if exists admin_teacher_students(uuid);
create or replace function admin_teacher_students(p_teacher uuid)
returns table (
  class_id       bigint,
  class_name     text,
  course         text,
  student_id     uuid,
  full_name      text,
  email          text,
  questions_seen bigint,
  first_try_rate numeric,
  medals         bigint,
  last_active    timestamptz,
  avatar_path    text
)
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if not is_admin() then
    raise exception 'Admin only.';
  end if;

  return query
  with roster as (
    select c.id as class_id, c.name as class_name, c.course,
           e.student_id
    from classes c
    join enrolments e on e.class_id = c.id and e.status = 'active'
    where c.teacher_id = p_teacher
      and c.archived_at is null
  ),
  from_attempts as (
    select a.student_id,
           count(distinct (a.unit, a.difficulty, a.sort_order)) as questions_seen,
           round(100.0 * count(*) filter (where a.was_correct
                                            and a.was_first_attempt)
                 / nullif(count(*) filter (where a.was_first_attempt), 0), 0)
                                                                as first_try_rate,
           max(a.answered_at)                                   as last_active
    from attempts a
    where a.student_id in (select r.student_id from roster r)
    group by a.student_id
  ),
  from_mastery as (
    select m.student_id,
           count(distinct m.unit) filter (where m.medal <> 'None') as medals
    from unit_mastery m
    where m.student_id in (select r.student_id from roster r)
    group by m.student_id
  )
  select r.class_id,
         r.class_name,
         r.course,
         p.id,
         coalesce(nullif(trim(p.full_name), ''), split_part(p.email, '@', 1)),
         p.email,
         coalesce(fa.questions_seen, 0),
         fa.first_try_rate,
         coalesce(fm.medals, 0),
         fa.last_active,
         p.avatar_path
  from roster r
  join profiles p on p.id = r.student_id
  left join from_attempts fa on fa.student_id = p.id
  left join from_mastery  fm on fm.student_id = p.id
  order by r.class_name, fa.last_active asc nulls first;
end;
$$;

create or replace function admin_make_teacher(p_email text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid;
begin
  if not is_admin() then
    raise exception 'Admin only.';
  end if;

  select id into v_user from auth.users
  where lower(email) = lower(trim(p_email));

  if v_user is null then
    return 'No account with that email. Ask them to sign up first, then try again.';
  end if;

  -- 'teacher', hardcoded. See the note at the top of this section.
  insert into staff_roles (user_id, role, note)
  values (v_user, 'teacher', 'Onboarded from the admin panel')
  on conflict (user_id) do nothing;

  if exists (select 1 from staff_roles
             where user_id = v_user and role = 'admin') then
    return 'That account is the admin already.';
  end if;

  return 'Done. ' || trim(p_email) || ' is now a tutor.';
end;
$$;

create or replace function admin_revoke_teacher(p_user uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
begin
  if not is_admin() then
    raise exception 'Admin only.';
  end if;

  -- Refuses admins, so the admin role cannot be removed from a browser.
  delete from staff_roles where user_id = p_user and role = 'teacher';
  if not found then
    return 'Nothing removed. That account is not a tutor, or it is the admin.';
  end if;
  return 'Removed. Their classes stay, and can be archived or reassigned.';
end;
$$;

-- Every live class, for the assignment picker.
create or replace function admin_list_classes()
returns table (
  id            bigint,
  name          text,
  grade         int,
  course        text,
  teacher_email text,
  students      bigint
)
language sql
security definer
stable
set search_path = public
as $$
  select c.id, c.name, c.grade, c.course, u.email,
         count(e.student_id) filter (where e.status = 'active')
  from classes c
  join auth.users u on u.id = c.teacher_id
  left join enrolments e on e.class_id = c.id
  where is_admin() and c.archived_at is null
  group by c.id, c.name, c.grade, c.course, u.email
  order by u.email, c.name;
$$;

-- The matching the whole pro model rests on: admin puts a paying student
-- into a tutor's class. Same direct-enrol semantics as add_student_to_class
-- (the student is not asked, sees the class on their front screen, can leave
-- in one tap) and the same grade-settling side effect.
create or replace function admin_assign_student(p_class_id bigint, p_email text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_student uuid;
  v_grade   int;
begin
  if not is_admin() then
    raise exception 'Admin only.';
  end if;

  select id into v_student from auth.users
  where lower(email) = lower(trim(p_email));

  if v_student is null then
    return 'No account with that email yet. Ask them to sign up first.';
  end if;

  if not exists (select 1 from classes
                 where id = p_class_id and archived_at is null) then
    return 'That class does not exist or is archived.';
  end if;

  insert into enrolments (class_id, student_id, status, joined_at)
  values (p_class_id, v_student, 'active', now())
  on conflict (class_id, student_id) do update
    set status = 'active', joined_at = now(), removed_at = null;

  update profiles p
     set grade = c.grade, course = c.course
    from classes c
   where c.id = p_class_id and p.id = v_student;

  return 'Added.';
end;
$$;

create or replace function admin_remove_student(p_class_id bigint, p_student uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not is_admin() then
    raise exception 'Admin only.';
  end if;
  update enrolments
     set status = 'removed', removed_at = now()
   where class_id = p_class_id and student_id = p_student;
end;
$$;

create or replace function admin_set_course(p_email text, p_course text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_student uuid;
begin
  if not is_admin() then
    raise exception 'Admin only.';
  end if;
  if not exists (select 1 from courses where code = p_course) then
    return 'No such course.';
  end if;

  select id into v_student from auth.users
  where lower(email) = lower(trim(p_email));
  if v_student is null then
    return 'No account with that email.';
  end if;

  update profiles
     set course = p_course,
         grade = (select c2.grade from courses c2 where c2.code = p_course)
   where id = v_student;
  return 'Done.';
end;
$$;

-- ---------------------------------------------------------------------------
-- admin_student_classes — which classes a student is actually in
-- ---------------------------------------------------------------------------
-- admin_remove_student takes a class_id, and nothing else an admin can call
-- returns one: admin_list_students hands the classes back as a single display
-- string ("Saturday MPM2D (uncle@x.ca)"), which is fine to read and useless
-- to act on. class_roster would do it but is deliberately teacher-only —
-- teaches_student asks whether YOU teach them, and an admin teaches nobody.
--
-- This raises rather than returning nothing, unlike the admin_list_*
-- functions. Those feed lists, where an empty result reads correctly as
-- "nothing here". This feeds a decision, where an empty result would read as
-- "this student is in no classes" when the truth is "you may not ask".
create or replace function admin_student_classes(p_student uuid)
returns table (
  class_id      bigint,
  class_name    text,
  course        text,
  teacher_email text,
  joined_at     timestamptz
)
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if not is_admin() then
    raise exception 'Admin only.';
  end if;

  return query
  select c.id,
         c.name,
         c.course,
         u.email::text,
         e.joined_at
  from enrolments e
  join classes c    on c.id = e.class_id
  join auth.users u on u.id = c.teacher_id
  where e.student_id = p_student
    and e.status = 'active'
    and c.archived_at is null
  order by c.name;
end;
$$;

-- ---------------------------------------------------------------------------
-- 17. Paying by Interac e-transfer
-- ---------------------------------------------------------------------------
-- Stripe unlocks itself through the webhook. An e-transfer cannot — there is
-- no webhook for a bank inbox — so this is the honest version of that flow:
-- the student declares "I have sent it", a pending claim appears for the
-- admin, the admin checks the actual bank account, and one tap grants the
-- period. NOTHING is unlocked by the claim itself; a student who claims and
-- never sends gets nothing but a pending row.
--
-- The grant writes status 'manual' and a concrete current_period_end, and
-- touches nothing Stripe owns. has_premium() already honours any future
-- period_end, so no paywall change is needed — and if the same student later
-- subscribes through Stripe, the webhook simply takes over the row.

create table if not exists etransfer_claims (
  id          bigint generated always as identity primary key,
  student_id  uuid not null references auth.users (id) on delete cascade,
  plan        text not null check (plan in ('monthly', 'annual')),
  status      text not null default 'pending'
              check (status in ('pending', 'confirmed', 'rejected')),
  created_at  timestamptz not null default now(),
  decided_at  timestamptz,
  note        text
);

alter table etransfer_claims enable row level security;

drop policy if exists "Read own claims" on etransfer_claims;
create policy "Read own claims" on etransfer_claims
  for select to authenticated using (student_id = auth.uid());

-- Student says they have sent the money. One pending claim at a time.
create or replace function request_etransfer(p_plan text)
returns text
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;
  if p_plan not in ('monthly', 'annual') then
    raise exception 'Plan must be monthly or annual.';
  end if;
  if exists (select 1 from etransfer_claims
             where student_id = auth.uid() and status = 'pending') then
    return 'You already have a transfer waiting to be confirmed. It is usually checked within a day.';
  end if;

  insert into etransfer_claims (student_id, plan) values (auth.uid(), p_plan);
  return 'Noted. Astro+ unlocks as soon as the transfer is confirmed — usually within a day.';
end;
$$;

create or replace function my_etransfer_status()
returns table (plan text, status text, created_at timestamptz)
language sql
security definer
stable
set search_path = public
as $$
  select c.plan, c.status, c.created_at
  from etransfer_claims c
  where c.student_id = auth.uid()
  order by c.created_at desc limit 1;
$$;

create or replace function admin_list_etransfers()
returns table (
  claim_id   bigint,
  email      text,
  full_name  text,
  plan       text,
  status     text,
  created_at timestamptz
)
language sql
security definer
stable
set search_path = public
as $$
  select c.id, u.email, p.full_name, c.plan, c.status, c.created_at
  from etransfer_claims c
  join auth.users u on u.id = c.student_id
  left join profiles p on p.id = c.student_id
  where is_admin()
  order by (c.status = 'pending') desc, c.created_at desc;
$$;

-- The admin has seen the money in the bank. Extends from whichever is later,
-- now or the current period end, so confirming a renewal early never eats
-- days the family already paid for.
create or replace function admin_confirm_etransfer(p_claim_id bigint)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_claim record;
  v_until timestamptz;
begin
  if not is_admin() then
    raise exception 'Admin only.';
  end if;

  select * into v_claim from etransfer_claims
  where id = p_claim_id and status = 'pending';
  if v_claim is null then
    return 'That claim is not pending.';
  end if;

  select greatest(coalesce(s.current_period_end, now()), now())
         + case v_claim.plan when 'annual' then interval '12 months'
                             else interval '1 month' end
    into v_until
  from (select 1) one
  left join subscriptions s on s.student_id = v_claim.student_id;

  insert into subscriptions (student_id, status, current_period_end, updated_at)
  values (v_claim.student_id, 'manual', v_until, now())
  on conflict (student_id) do update
    set status = 'manual',
        current_period_end = excluded.current_period_end,
        updated_at = now();

  update etransfer_claims
     set status = 'confirmed', decided_at = now()
   where id = p_claim_id;

  return 'Confirmed. Astro+ until ' || to_char(v_until, 'DD Mon YYYY') || '.';
end;
$$;

create or replace function admin_reject_etransfer(p_claim_id bigint, p_note text)
returns text
language plpgsql
security definer
set search_path = public
as $$
begin
  if not is_admin() then
    raise exception 'Admin only.';
  end if;
  update etransfer_claims
     set status = 'rejected', decided_at = now(), note = p_note
   where id = p_claim_id and status = 'pending';
  if not found then
    return 'That claim is not pending.';
  end if;
  return 'Rejected.';
end;
$$;

-- ---------------------------------------------------------------------------
-- 18. Tutor review — subtopic diagnosis, and feedback back to the student
-- ---------------------------------------------------------------------------
-- This is the half of Astro+ that is not questions: a tutor looks at what a
-- student is actually weak at, and writes back.
--
-- The whole section exists because of one observation about how students
-- revise: they practise what they are already good at and steer around what
-- they are not. A dashboard that only reports scores rewards exactly that —
-- the avoided topic never appears, because avoiding it produces no data.
--
-- So student_subtopics reports TWO things per subtopic, and the second is
-- the one that is usually missing from this kind of tool:
--
--   how well  — first-try rate, banded the same five ways as the report
--   how much  — coverage: distinct questions attempted, out of what exists
--
-- A subtopic with a weak band is a difficulty. A subtopic with almost no
-- coverage, inside a unit the student has otherwise worked through, is an
-- avoidance — and the two together ("bad at it, and steering around it") is
-- the single most useful thing a tutor can be told. Absence of evidence is
-- reported as evidence here, deliberately.

create or replace function student_subtopics(p_student uuid)
returns table (
  unit            text,
  tag             text,
  label           text,
  questions_total int,
  questions_seen  int,
  coverage_pct    int,
  unit_coverage   int,
  first_looks     int,
  first_try_rate  int,
  band            text,
  avoided         boolean,
  last_seen       timestamptz
)
language sql
security definer
stable
set search_path = public
as $$
  with me as (
    -- teaches_student is re-checked here rather than trusted from the
    -- caller, the same as every other function on the dashboard. A teacher
    -- who does not teach this student gets no rows, not an error.
    select p.id, p.grade, p.course from profiles p
    where p.id = p_student and teaches_student(p_student)
  ),
  reset as (
    select r.reset_at from progress_resets r
    join me on me.id = r.student_id and r.course = me.course
  ),
  mine as (
    select a.* from attempts a, me
    where a.student_id = me.id and a.course = me.course
      and (not exists (select 1 from reset)
           or a.answered_at > (select reset_at from reset))
  ),
  bank as (
    select q.unit, q.misconception_tag as tag, q.sort_order
    from questions q, me
    where q.course_code = me.course and q.misconception_tag is not null
  ),
  -- Per subtopic: what exists, what has been touched, how it went.
  per_sub as (
    select b.unit, b.tag,
           count(distinct b.sort_order)                         as total,
           count(distinct m.sort_order)                         as seen,
           count(*) filter (where m.was_first_attempt)           as first_looks,
           count(*) filter (where m.was_first_attempt
                              and m.was_correct)                 as first_hits,
           max(m.answered_at)                                    as last_seen
    from bank b
    left join mine m
      on m.unit = b.unit and m.sort_order = b.sort_order
    group by b.unit, b.tag
  ),
  -- The same coverage figure for the whole unit, which is what makes an
  -- avoided subtopic visible: 10% coverage means nothing on its own, and
  -- means a great deal inside a unit that is otherwise 80% done.
  per_unit as (
    select unit,
           sum(total) as total,
           sum(seen)  as seen,
           -- The best-covered subtopic in this unit is the yardstick for
           -- avoidance, NOT the unit average. The average is dragged down
           -- by the very topics being avoided, so a student who has done
           -- one subtopic fully and skipped the rest looks "consistent"
           -- against it. Against their own best, the gap is obvious.
           max(case when total > 0 then seen::numeric / total end) as best_cov
    from per_sub group by unit
  )
  select s.unit, s.tag, misconception_label(s.tag),
         s.total::int,
         s.seen::int,
         round(100.0 * s.seen / nullif(s.total, 0))::int,
         round(100.0 * u.seen / nullif(u.total, 0))::int,
         s.first_looks::int,
         case when s.first_looks = 0 then null
              else round(100.0 * s.first_hits / s.first_looks)::int end,
         case
           when s.first_looks < 2 then 'grey'
           when 100.0 * s.first_hits / s.first_looks >= 90 then 'green'
           when 100.0 * s.first_hits / s.first_looks >= 70 then 'light-green'
           when 100.0 * s.first_hits / s.first_looks >= 50 then 'yellow'
           else 'orange'
         end,
         -- Avoided: the unit is genuinely under way, and this subtopic has
         -- had less than half the attention the student gave their
         -- best-covered subtopic in the same unit. The 25% floor stops
         -- every untouched subtopic in a brand-new unit being flagged on
         -- day one, which would be noise, not a finding.
         (u.seen::numeric / nullif(u.total, 0) >= 0.25
          and s.seen::numeric / nullif(s.total, 0)
              < 0.5 * coalesce(u.best_cov, 0)),
         s.last_seen
  from per_sub s
  join per_unit u on u.unit = s.unit
  order by
    -- Weakest and most-avoided first: this list is a plan for the next
    -- session, so it is sorted by where the time should go, not by unit.
    case when s.first_looks >= 2
           and 100.0 * s.first_hits / s.first_looks < 70 then 0
         else 1 end,
    (u.seen::numeric / nullif(u.total, 0) >= 0.25
     and s.seen::numeric / nullif(s.total, 0)
         < 0.5 * coalesce(u.best_cov, 0)) desc,
    case when s.first_looks = 0 then 999
         else 100.0 * s.first_hits / s.first_looks end,
    s.unit;
$$;

-- ---------------------------------------------------------------------------
-- Feedback a tutor writes to a student.
--
-- Plain text, optionally attached to one subtopic so it lands beside the
-- thing it is about. Append-only from the student's side — they read, they
-- do not edit — and the tutor can delete only their own.
--
-- seen_at exists so a tutor knows whether the advice was actually read
-- before they repeat it. It is set by the student's own app, not claimed by
-- anyone else.
create table if not exists tutor_notes (
  id         bigint generated always as identity primary key,
  student_id uuid not null references auth.users (id) on delete cascade,
  teacher_id uuid not null references auth.users (id) on delete cascade,
  tag        text,
  body       text not null check (length(trim(body)) between 1 and 2000),
  created_at timestamptz not null default now(),
  seen_at    timestamptz
);

create index if not exists tutor_notes_student_idx
  on tutor_notes (student_id, created_at desc);

alter table tutor_notes enable row level security;

-- Read-only policies, as everywhere else: the writes go through functions.
drop policy if exists "Students read own notes" on tutor_notes;
create policy "Students read own notes" on tutor_notes
  for select to authenticated using (student_id = auth.uid());

drop policy if exists "Teachers read notes for their students" on tutor_notes;
create policy "Teachers read notes for their students" on tutor_notes
  for select to authenticated using (teaches_student(student_id));

create or replace function write_tutor_note(
  p_student uuid,
  p_tag     text,
  p_body    text
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id bigint;
begin
  if not teaches_student(p_student) then
    raise exception 'You do not teach that student.';
  end if;
  if length(trim(coalesce(p_body, ''))) = 0 then
    raise exception 'Write something first.';
  end if;

  insert into tutor_notes (student_id, teacher_id, tag, body)
  values (p_student, auth.uid(), nullif(trim(p_tag), ''), trim(p_body))
  returning id into v_id;
  return v_id;
end;
$$;

-- What the tutor sees on a student: their own notes and any other tutor's,
-- because two tutors sharing a student should not talk past each other.
create or replace function student_notes(p_student uuid)
returns table (
  id            bigint,
  tag           text,
  label         text,
  body          text,
  created_at    timestamptz,
  seen_at       timestamptz,
  teacher_email text,
  mine          boolean
)
language sql
security definer
stable
set search_path = public
as $$
  select n.id, n.tag, misconception_label(n.tag), n.body, n.created_at,
         n.seen_at, u.email, n.teacher_id = auth.uid()
  from tutor_notes n
  join auth.users u on u.id = n.teacher_id
  where n.student_id = p_student
    and teaches_student(p_student)
  order by n.created_at desc;
$$;

create or replace function delete_tutor_note(p_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Only the author, and only while they still teach the student.
  delete from tutor_notes
   where id = p_id
     and teacher_id = auth.uid()
     and teaches_student(student_id);
  if not found then
    raise exception 'That note is not yours to delete.';
  end if;
end;
$$;

-- The student's side.
create or replace function my_tutor_notes()
returns table (
  id            bigint,
  tag           text,
  label         text,
  body          text,
  created_at    timestamptz,
  seen_at       timestamptz,
  teacher_email text
)
language sql
security definer
stable
set search_path = public
as $$
  select n.id, n.tag, misconception_label(n.tag), n.body, n.created_at,
         n.seen_at, u.email
  from tutor_notes n
  join auth.users u on u.id = n.teacher_id
  where n.student_id = auth.uid()
  order by n.created_at desc;
$$;

create or replace function mark_notes_seen()
returns void
language sql
security definer
set search_path = public
as $$
  update tutor_notes set seen_at = now()
   where student_id = auth.uid() and seen_at is null;
$$;

-- ---------------------------------------------------------------------------
-- 19. Permissions
-- ---------------------------------------------------------------------------
-- Every dashboard function checks ownership inside its own query, so granting
-- execute to authenticated is safe: a student calling class_roster on a class
-- id they guessed gets an empty result, not somebody else's marks.
--
-- shared_report is open to anon on purpose. Somebody opening a share link has
-- no account, and the random token is the authentication — which is why
-- revoking has to take effect immediately.

revoke all on function report_payload(uuid) from public, anon, authenticated;

grant execute on function is_teacher()                      to authenticated;
grant execute on function is_enrolled_in(bigint)            to authenticated;
grant execute on function owns_class(bigint)                to authenticated;
grant execute on function create_class(text, text)          to authenticated;
grant execute on function my_classes()                      to authenticated;
grant execute on function my_classes_as_student()           to authenticated;
grant execute on function invite_student(bigint, text)      to authenticated;
grant execute on function respond_to_invitation(bigint, boolean) to authenticated;
grant execute on function remove_student(bigint, uuid)      to authenticated;
grant execute on function archive_class(bigint)             to authenticated;
grant execute on function class_roster(bigint)              to authenticated;
grant execute on function class_misconceptions(bigint, timestamptz)
                                                            to authenticated;
grant execute on function class_unit_summary(bigint)        to authenticated;
grant execute on function student_detail(uuid)              to authenticated;
grant execute on function class_unit_breakdown(bigint)      to authenticated;
grant execute on function class_hard_questions(bigint)      to authenticated;
grant execute on function student_overview(uuid)            to authenticated;
grant execute on function misconception_label(text)         to anon, authenticated;
grant execute on function has_premium()                     to authenticated;
grant execute on function level_is_free(text)               to anon, authenticated;
grant execute on function list_levels(text, text)           to authenticated;

-- The admin panel. Same pattern as the dashboard: every one of these
-- re-checks is_admin() in its own body, so granting execute to authenticated
-- exposes nothing — a student calling admin_list_students() gets an
-- exception or an empty result, never data.
-- The avatars bucket and its policies. Down here rather than beside the
-- profiles table on purpose: the read policy calls is_admin() and
-- teaches_student(), and create policy resolves those at creation time —
-- placed any earlier in this file, a fresh run fails on a function that
-- does not exist yet.
-- ---------------------------------------------------------------------------
-- 2. The bucket and its policies
-- ---------------------------------------------------------------------------
-- Guarded on the storage schema existing, so this file also loads cleanly on
-- a plain Postgres — which is how the test suite runs, and a migration that
-- cannot be tested locally is a migration nobody tests.
do $$
begin
  if not exists (select 1 from information_schema.schemata
                 where schema_name = 'storage') then
    raise notice 'No storage schema — skipping bucket setup. '
                 'Expected on local Postgres, NOT on Supabase.';
    return;
  end if;

  insert into storage.buckets (id, name, public, file_size_limit,
                               allowed_mime_types)
  values ('avatars', 'avatars', false, 2097152,
          array['image/jpeg', 'image/png', 'image/webp'])
  on conflict (id) do update
    set public             = false,
        file_size_limit    = 2097152,
        allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp'];

  -- The size limit is a second fence, not the first. The app resizes to a
  -- 256px JPEG (about 15–25 kB) before uploading, so anything arriving near
  -- 2 MB did not come from the app.

  execute $p$
    drop policy if exists "Avatar read"   on storage.objects;
    drop policy if exists "Avatar write"  on storage.objects;
    drop policy if exists "Avatar update" on storage.objects;
    drop policy if exists "Avatar delete" on storage.objects;

    -- Read: yourself, a tutor who teaches you, or the admin. The first path
    -- segment is the student id, which is what makes this expressible.
    create policy "Avatar read" on storage.objects for select
      to authenticated
      using (
        bucket_id = 'avatars'
        and (
          (storage.foldername(name))[1] = auth.uid()::text
          or public.is_admin()
          -- The cast is guarded by a CASE rather than by an AND. Postgres is
          -- free to reorder the arms of an AND, so a folder name that is not
          -- a uuid could reach ::uuid and raise — and an error raised inside
          -- a SELECT policy does not deny one row, it fails the whole query.
          -- CASE is the one construct with a guaranteed evaluation order.
          or case
               when (storage.foldername(name))[1] ~
                    ('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
                     || '[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
               then public.teaches_student(
                      ((storage.foldername(name))[1])::uuid)
               else false
             end
        )
      );

    -- Write: your own folder only. Three separate policies rather than one
    -- FOR ALL, because an upsert from the client is an insert OR an update
    -- depending on whether the object already exists, and a missing update
    -- policy fails only on the second upload — which is the kind of bug that
    -- ships.
    create policy "Avatar write" on storage.objects for insert
      to authenticated
      with check (bucket_id = 'avatars'
                  and (storage.foldername(name))[1] = auth.uid()::text);

    create policy "Avatar update" on storage.objects for update
      to authenticated
      using (bucket_id = 'avatars'
             and (storage.foldername(name))[1] = auth.uid()::text)
      with check (bucket_id = 'avatars'
                  and (storage.foldername(name))[1] = auth.uid()::text);

    create policy "Avatar delete" on storage.objects for delete
      to authenticated
      using (bucket_id = 'avatars'
             and (storage.foldername(name))[1] = auth.uid()::text);
  $p$;

  raise notice 'avatars bucket and policies are ready.';
end $$;

create or replace function set_my_avatar(p_path text)
returns text
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;

  -- Must be inside the caller's own folder. Belt and braces with the storage
  -- policy: that one governs the bytes, this one governs the pointer.
  if p_path is null or p_path not like auth.uid()::text || '/%' then
    raise exception 'That is not your photo.';
  end if;

  update profiles set avatar_path = p_path where id = auth.uid();
  return 'Photo saved.';
end;
$$;

create or replace function clear_my_avatar()
returns text
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;
  update profiles set avatar_path = null where id = auth.uid();
  return 'Photo removed.';
end;
$$;

grant execute on function set_my_avatar(text)               to authenticated;
grant execute on function clear_my_avatar()                 to authenticated;

grant execute on function is_admin()                        to authenticated;
grant execute on function admin_list_students()             to authenticated;
grant execute on function admin_list_teachers()             to authenticated;
grant execute on function admin_make_teacher(text)          to authenticated;
grant execute on function admin_revoke_teacher(uuid)        to authenticated;
grant execute on function admin_list_classes()              to authenticated;
grant execute on function admin_assign_student(bigint, text) to authenticated;
grant execute on function admin_remove_student(bigint, uuid) to authenticated;
grant execute on function admin_student_classes(uuid)       to authenticated;
grant execute on function admin_teacher_students(uuid)      to authenticated;
grant execute on function admin_set_course(text, text)      to authenticated;
grant execute on function admin_list_etransfers()           to authenticated;
grant execute on function admin_confirm_etransfer(bigint)   to authenticated;
grant execute on function admin_reject_etransfer(bigint, text) to authenticated;

-- Paying by e-transfer
grant execute on function request_etransfer(text)           to authenticated;
grant execute on function my_etransfer_status()             to authenticated;

-- Tutor review. student_subtopics, student_notes, write_tutor_note and
-- delete_tutor_note all re-check teaches_student() inside their own body,
-- so granting execute to authenticated exposes nothing: a student calling
-- student_subtopics on a classmate gets an empty result.
grant execute on function student_subtopics(uuid)           to authenticated;
grant execute on function write_tutor_note(uuid, text, text) to authenticated;
grant execute on function student_notes(uuid)               to authenticated;
grant execute on function delete_tutor_note(bigint)         to authenticated;
grant execute on function my_tutor_notes()                  to authenticated;
grant execute on function mark_notes_seen()                 to authenticated;

-- The report and its sharing
grant execute on function my_report()                       to authenticated;
grant execute on function my_share_token()                  to authenticated;
grant execute on function my_share_status()                 to authenticated;
grant execute on function revoke_share()                    to authenticated;
grant execute on function revoke_and_reissue_share()        to authenticated;
grant execute on function shared_report(uuid)               to anon, authenticated;

-- Admin only: assigning tutors and moving students between grades and
-- classes. Students cannot call these, which is the point of them existing.
grant execute on function set_student_course(uuid, text)      to authenticated;
grant execute on function add_student_to_class(bigint, text) to authenticated;
revoke all on function grant_teacher_role(text, text) from public, anon, authenticated;
grant execute on function grant_teacher_role(text, text)    to service_role;

revoke all on function upsert_subscription(uuid, text, text, text, timestamptz)
                                                   from public, anon, authenticated;
revoke all on function update_subscription_by_sid(text, text, timestamptz)
                                                   from public, anon, authenticated;
revoke all on function set_stripe_customer(uuid, text)
                                                   from public, anon, authenticated;
grant execute on function upsert_subscription(uuid, text, text, text, timestamptz)
                                                            to service_role;
grant execute on function update_subscription_by_sid(text, text, timestamptz)
                                                            to service_role;
grant execute on function set_stripe_customer(uuid, text)   to service_role;

-- 20. Reporting views
-- ---------------------------------------------------------------------------
-- security_invoker below is NOT optional. A plain Postgres view runs with
-- its OWNER's privileges, and the owner bypasses RLS on attempts — so
-- without it, any signed-in student could read every student's rows through
-- these views, and misconception_counts would be worse still: it lists
-- which options are wrong per question, an answer-elimination oracle that
-- defeats the entire "answers never reach the browser" design. The security
-- audit caught exactly that. With security_invoker on, the querying user's
-- own RLS applies: a student sees only their own attempts, a teacher only
-- their students'.

drop view if exists my_weekly_progress;
create view my_weekly_progress with (security_invoker = true) as
select student_id, grade, unit,
       date_trunc('week', answered_at)           as week,
       count(*) filter (where was_first_attempt) as questions_attempted,
       count(*) filter (where was_correct and was_first_attempt)
                                                 as first_try_correct,
       count(*) filter (where not was_correct)   as wrong_taps,
       min(answered_at)                          as started_at,
       max(answered_at)                          as last_seen_at
from attempts
group by student_id, grade, unit, date_trunc('week', answered_at);

drop view if exists misconception_counts;
create view misconception_counts with (security_invoker = true) as
select grade, unit, sort_order, chosen_index, misconception_tag,
       count(*)                   as times_chosen,
       count(distinct student_id) as students_affected
from attempts
where not was_correct
group by grade, unit, sort_order, chosen_index, misconception_tag;

-- ---------------------------------------------------------------------------
-- 21. First run
-- ---------------------------------------------------------------------------
-- Load the questions:   questions_all_tagged.sql
--
-- Then make yourself a teacher. Create a code:
--
--   select grant_teacher_role('tutor@school.ca');
--
-- To remove one:
--   delete from staff_roles where user_id =
--     (select id from auth.users where email = 'tutor@school.ca');
--
-- Email sending is the one piece SQL cannot do. Two Edge Functions are
-- needed: one to send a consent email when a guardian is added, one weekly to
-- call reports_due, send each report and call record_report_sent. Every
-- message needs a working unsubscribe link built from the token — under CASL
-- that is a legal requirement in Canada, not a nicety.

-- ---------------------------------------------------------------------------
-- Check it worked
-- ---------------------------------------------------------------------------

select tablename, rowsecurity
from pg_tables
where schemaname = 'public'
order by tablename;

select routine_name
from information_schema.routines
where routine_schema = 'public' and routine_type = 'FUNCTION'
  and routine_name not like 'pgp%' and routine_name not like 'gen_%'
  and routine_name not in ('armor','dearmor','crypt','digest','hmac',
                           'encrypt','decrypt','encrypt_iv','decrypt_iv')
order by routine_name;


-- ---------------------------------------------------------------------------
-- 5. Hardening, from the Supabase security advisor
-- ---------------------------------------------------------------------------
-- The advisor flags every security definer function as executable by anon.
-- True, and by default unavoidable: Postgres grants EXECUTE on new functions
-- to PUBLIC, which anon inherits. Nothing leaked — every function re-checks
-- auth.uid() or is_admin() in its body, and the suite proves anon gets
-- nothing from any of them — but a signed-out browser being able to *dial*
-- 49 functions it can never use is surface with no purpose.
--
-- So: revoke the blanket PUBLIC grant, give authenticated and service_role
-- everything back (service_role is what the Stripe webhook and the email
-- functions run as — forgetting it here would break payments quietly), and
-- hand anon exactly the two things a person without an account genuinely
-- does: read the course list on the signup screen, and open a shared report.
-- The mechanics need care, because the file already contains two kinds of
-- statement this must not fight with:
--
--   * a curated allowlist of `grant ... to authenticated` — one per
--     app-facing function
--   * five deliberate denials, where the ONLY protection is that
--     authenticated has no grant: grant_teacher_role (would let a student
--     make themselves admin), the three Stripe subscription writers (would
--     let a student mint premium), and report_payload
--
-- An earlier draft did `grant execute on all functions to authenticated`
-- here. The suite failed within seconds: C1 self-granted admin, because the
-- blanket grant had re-opened all five denials. And the draft after that
-- granted nothing to authenticated — which broke differently, because RLS
-- policies call helpers like teaches_student AS THE SIGNED-IN USER, and
-- those helpers were riding on the PUBLIC default this block removes.
--
-- So: blanket to authenticated is on purpose, and the denials are re-stated
-- immediately after it, closed again before this transaction ever ends. The
-- net effect for a signed-in user is exactly the surface the file always
-- intended; the change is that a signed-out browser goes from being able to
-- dial 49 functions to exactly 2.
revoke execute on all functions in schema public from public, anon;
grant  execute on all functions in schema public to authenticated;
revoke all on function grant_teacher_role(text, text)  from authenticated;
revoke all on function report_payload(uuid)            from authenticated;
revoke all on function upsert_subscription(uuid, text, text, text, timestamptz)
                                                       from authenticated;
revoke all on function update_subscription_by_sid(text, text, timestamptz)
                                                       from authenticated;
revoke all on function set_stripe_customer(uuid, text) from authenticated;

-- service_role is the webhook and the email functions — server-side keys
-- only, never the browser. Blanket is correct for it: a trusted role that
-- loses a grant fails quietly at 3am when a subscription renews.
grant execute on all functions in schema public to service_role;

-- The two things a person without an account genuinely does: read the course
-- list on the signup screen, and open a report someone shared with them.
grant execute on function list_courses()      to anon;
grant execute on function shared_report(uuid) to anon;
