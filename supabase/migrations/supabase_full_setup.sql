-- ===========================================================================
-- Math tutor — complete database setup
-- ===========================================================================
--
-- Paste this whole file into the Supabase SQL Editor and press Run, then run
-- questions_all_tagged.sql to load the 200 questions.
--
-- WARNING: this file is DESTRUCTIVE for the two structural tables. It drops
-- and rebuilds questions and profiles, which wipes every question and every
-- grade of every student. It does NOT drop attempts, progress_resets or
-- unit_mastery, so student history survives a re-run.
--
-- Run order from a clean project:
--   1. supabase_full_setup.sql   <- this file
--   2. questions_all_tagged.sql     all 200 questions, with tags
--
-- What is in here:
--   PART ONE — the student app
--     1  questions            the bank
--     2  profiles             who is signed in, and their grade
--     3  attempts             one row per tap, append only
--     4  progress_resets      the soft reset
--     5  unit_mastery         the medal cabinet
--     6  row level security
--     7  server-side grading  what the app calls instead of reading answers
--     8  staff_roles          who is a teacher
--
--   PART TWO — other people seeing a student's work
--     9  teacher access codes how somebody becomes a teacher
--    10  classes, enrolments  with invitations the student accepts
--    11  access checks        the definer functions the policies rely on
--    12  row level security   for classes
--    13  managing a class
--    14  the dashboard        roster, misconceptions, per-unit, per-student
--    15  parent reports       consent, the weekly report, the send queue
--    16  permissions
--    17  reporting views
--
-- BEFORE YOU START: turn off email confirmation while testing.
--   Authentication -> Sign In / Providers -> Email -> uncheck "Confirm email".
-- Turn it back on before real students use it.
--
-- Grade to course mapping:
--   9  MTH1W  Mathematics (destreamed)
--   10 MPM2D  Principles of Mathematics
--   11 MCR3U  Functions
--   12 MHF4U  Advanced Functions

-- ---------------------------------------------------------------------------
-- 1. Questions
-- ---------------------------------------------------------------------------

drop table if exists questions;

create table questions (
  id            bigint generated always as identity primary key,
  grade         int    not null check (grade between 9 and 12),
  unit_order    int    not null,   -- order of the unit chips
  sort_order    int    not null,   -- order of questions within a unit
  difficulty    text   not null check (difficulty in ('Easy','Medium','Hard')),
  course_code   text   not null,
  unit          text   not null,
  prompt        text   not null,
  correct_index int    not null,
  options       jsonb  not null,
  -- Short slug naming the mistake this question is built to catch. Recorded
  -- on an attempt only when a wrong option is tapped.
  misconception_tag text,
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

-- ---------------------------------------------------------------------------
-- 2. Student profiles
-- ---------------------------------------------------------------------------
-- Supabase manages the account itself in auth.users. This table holds the
-- extra thing we care about: which grade the student is in.

drop table if exists profiles;

-- full_name is asked for at signup and is what a teacher sees on a roster.
-- Email addresses are for signing in, not for identifying a child on a
-- screen a teacher scans quickly — half of them are variations on a first
-- name and a birth year, which is both hard to read and more personal
-- information than a roster needs to show.
create table profiles (
  id         uuid primary key references auth.users on delete cascade,
  email      text,
  full_name  text,
  grade      int not null check (grade between 9 and 12),
  created_at timestamptz not null default now()
);

alter table profiles enable row level security;

-- Each student can see and edit their own row, and no other row.
-- auth.uid() is the id of whoever is making the request.

create policy "Read own profile"
  on profiles for select
  to authenticated
  using (auth.uid() = id);

create policy "Create own profile"
  on profiles for insert
  to authenticated
  with check (auth.uid() = id);

create policy "Update own profile"
  on profiles for update
  to authenticated
  using (auth.uid() = id);

-- Older databases created profiles before names existed.
alter table profiles add column if not exists full_name text;

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
  unit              text not null,
  sort_order        int  not null,
  difficulty        text,
  chosen_index      int  not null check (chosen_index between 0 and 3),
  was_correct       boolean not null,
  was_first_attempt boolean not null,
  misconception_tag text,
  answered_at       timestamptz not null default now()
);

-- Resume and per-unit scoring read this constantly.
create index if not exists attempts_student_unit_idx
  on attempts (student_id, grade, unit, answered_at);

-- The teacher dashboard asks "which distractor is the whole class picking",
-- so it reads by question rather than by student.
create index if not exists attempts_question_idx
  on attempts (grade, unit, sort_order, chosen_index);

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
-- row per student per grade, so resetting Grade 11 leaves Grade 12 alone.

create table if not exists progress_resets (
  student_id uuid not null references auth.users (id) on delete cascade,
  grade      int  not null check (grade between 9 and 12),
  reset_at   timestamptz not null default now(),
  primary key (student_id, grade)
);

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
-- The rule that keeps it honest: values only ever move upward. A bad rerun
-- cannot cost a medal already earned, which also means a soft reset has
-- nothing to farm.

create table if not exists unit_mastery (
  student_id      uuid not null references auth.users (id) on delete cascade,
  grade           int  not null check (grade between 9 and 12),
  unit            text not null,
  best_first_try  int  not null default 0,
  total_questions int  not null default 0,
  hard_first_try  int  not null default 0,
  hard_total      int  not null default 0,
  medal           text not null default 'None'
                  check (medal in ('None', 'Bronze', 'Silver', 'Gold')),
  times_completed int  not null default 0,
  first_earned_at timestamptz,
  updated_at      timestamptz not null default now(),
  primary key (student_id, grade, unit)
);

create index if not exists unit_mastery_student_idx
  on unit_mastery (student_id, grade);

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

-- Unit list for the chips. Also returns how many questions are Hard, since
-- Gold requires every Hard question first try and the app needs the target.
create or replace function list_units(p_grade int)
returns table (unit text, unit_order int, total bigint, hard_total bigint)
language sql
security definer
stable
set search_path = public
as $$
  select q.unit,
         min(q.unit_order)::int,
         count(*),
         count(*) filter (where q.difficulty = 'Hard')
  from questions q
  where q.grade = p_grade
  group by q.unit
  order by min(q.unit_order);
$$;

-- The questions themselves, stripped of anything that gives away an answer.
--
-- The ordering is here rather than in the app: Easy, then Medium, then Hard,
-- with sort_order breaking ties. Doing it in SQL means the ramp cannot be
-- skipped by a client that asks differently. Note that ordering by the
-- difficulty column directly would sort alphabetically — Easy, Hard, Medium —
-- putting the hardest questions second, which is why the case expression
-- exists.
create or replace function list_questions(p_grade int, p_unit text)
returns table (
  sort_order  int,
  difficulty  text,
  course_code text,
  unit        text,
  prompt      text,
  options     jsonb
)
language sql
security definer
stable
set search_path = public
as $$
  select q.sort_order,
         q.difficulty,
         q.course_code,
         q.unit,
         q.prompt,
         (
           select jsonb_agg(jsonb_build_object('text', elem->>'text')
                            order by ord)
           from jsonb_array_elements(q.options) with ordinality as t(elem, ord)
         )
  from questions q
  where q.grade = p_grade
    and q.unit  = p_unit
  order by case q.difficulty
             when 'Easy'   then 0
             when 'Medium' then 1
             else 2
           end,
           q.sort_order;
$$;

-- One tap. Grades it, logs it, returns the feedback for that option only.
--
-- was_first_attempt is worked out here rather than taken from the app. If the
-- app supplied it, a student could claim every answer was a first try and
-- hand themselves a Gold. The server checks whether this question has already
-- been attempted since the last reset, which is a fact the student cannot
-- edit.
create or replace function submit_answer(
  p_grade      int,
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

  select q.correct_index, q.options, q.difficulty, q.misconception_tag
    into v_question
  from questions q
  where q.grade = p_grade
    and q.unit = p_unit
    and q.sort_order = p_sort_order;

  if not found then
    raise exception 'No such question.';
  end if;

  if p_chosen < 0 or p_chosen > 3 then
    raise exception 'Option out of range.';
  end if;

  select r.reset_at into v_reset_at
  from progress_resets r
  where r.student_id = auth.uid() and r.grade = p_grade;

  -- When this unit was last completed. Finishing a unit closes a pass, so
  -- anything after that timestamp belongs to a fresh attempt at it.
  select m.updated_at into v_last_pass
  from unit_mastery m
  where m.student_id = auth.uid() and m.grade = p_grade and m.unit = p_unit;

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
      and a.grade = p_grade
      and a.unit = p_unit
      and a.sort_order = p_sort_order
      and (v_since is null or a.answered_at > v_since)
  );

  insert into attempts (
    student_id, grade, unit, sort_order, difficulty,
    chosen_index, was_correct, was_first_attempt, misconception_tag
  ) values (
    auth.uid(), p_grade, p_unit, p_sort_order, v_question.difficulty,
    p_chosen, v_correct, v_first,
    -- Only a wrong tap represents a misconception. Tagging correct answers
    -- would poison every count in the teacher view.
    case when v_correct then null else v_question.misconception_tag end
  );

  return query select v_correct, v_first, v_feedback;
end;
$$;

-- Works out the medal for a finished unit from the attempts themselves, and
-- stores it only if it beats what is already there.
create or replace function award_medal(p_grade int, p_unit text)
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
  v_hard_total  int;
  v_first_try   int;
  v_hard_first  int;
  v_solved      int;
  v_earned      text;
  v_existing    text;
  v_rank        int;
  v_had_rank    int;
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;

  select count(*), count(*) filter (where difficulty = 'Hard')
    into v_total, v_hard_total
  from questions
  where grade = p_grade and unit = p_unit;

  if v_total = 0 then
    return 'None';
  end if;

  select r.reset_at into v_reset_at
  from progress_resets r
  where r.student_id = auth.uid() and r.grade = p_grade;

  -- The same window submit_answer used, so the medal is scored on exactly
  -- the taps that were marked as first attempts.
  select m.updated_at into v_last_pass
  from unit_mastery m
  where m.student_id = auth.uid() and m.grade = p_grade and m.unit = p_unit;

  v_since := greatest(v_reset_at, v_last_pass);

  -- Distinct questions, because a question answered right after three wrong
  -- taps must not count three times.
  select count(distinct a.sort_order)
       filter (where a.was_correct),
         count(distinct a.sort_order)
       filter (where a.was_correct and a.was_first_attempt),
         count(distinct a.sort_order)
       filter (where a.was_correct and a.was_first_attempt
                     and a.difficulty = 'Hard')
    into v_solved, v_first_try, v_hard_first
  from attempts a
  where a.student_id = auth.uid()
    and a.grade = p_grade
    and a.unit = p_unit
    and (v_since is null or a.answered_at > v_since);

  -- Not finished yet, so nothing to award.
  if v_solved < v_total then
    return 'None';
  end if;

  if v_first_try::numeric / v_total >= 0.9
     and (v_hard_total = 0 or v_hard_first = v_hard_total) then
    v_earned := 'Gold';
  elsif v_first_try::numeric / v_total >= 0.7 then
    v_earned := 'Silver';
  else
    v_earned := 'Bronze';
  end if;

  select m.medal into v_existing
  from unit_mastery m
  where m.student_id = auth.uid() and m.grade = p_grade and m.unit = p_unit;

  v_rank := case v_earned
              when 'Gold' then 3 when 'Silver' then 2
              when 'Bronze' then 1 else 0 end;
  v_had_rank := case coalesce(v_existing, 'None')
                  when 'Gold' then 3 when 'Silver' then 2
                  when 'Bronze' then 1 else 0 end;

  insert into unit_mastery (
    student_id, grade, unit, medal, best_first_try, total_questions,
    hard_first_try, hard_total, times_completed, first_earned_at, updated_at
  ) values (
    auth.uid(), p_grade, p_unit,
    case when v_rank >= v_had_rank then v_earned else v_existing end,
    v_first_try, v_total, v_hard_first, v_hard_total, 1, now(), now()
  )
  on conflict (student_id, grade, unit) do update set
    -- Upward only. A bad rerun never costs a medal already earned.
    medal = case
              when v_rank >= v_had_rank then v_earned
              else unit_mastery.medal
            end,
    best_first_try  = greatest(unit_mastery.best_first_try, v_first_try),
    total_questions = v_total,
    hard_first_try  = greatest(unit_mastery.hard_first_try, v_hard_first),
    hard_total      = v_hard_total,
    times_completed = unit_mastery.times_completed + 1,
    updated_at      = now();

  return v_earned;
end;
$$;

-- The soft reset, as a function so the app never writes the table directly.
create or replace function reset_progress(p_grade int)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;

  insert into progress_resets (student_id, grade, reset_at)
  values (auth.uid(), p_grade, now())
  on conflict (student_id, grade) do update set reset_at = now();
end;
$$;

-- Students may call these; anonymous visitors may not.
revoke all on function list_units(int)                from public, anon;
revoke all on function list_questions(int, text)      from public, anon;
revoke all on function submit_answer(int, text, int, int) from public, anon;
revoke all on function award_medal(int, text)         from public, anon;
revoke all on function reset_progress(int)            from public, anon;

grant execute on function list_units(int)                to authenticated;
grant execute on function list_questions(int, text)      to authenticated;
grant execute on function submit_answer(int, text, int, int) to authenticated;
grant execute on function award_medal(int, text)         to authenticated;
grant execute on function reset_progress(int)            to authenticated;

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
-- The hard question in this whole file: how does somebody become a teacher?
--
-- A button saying "I am a teacher" is out. It grants the ability to create a
-- class, and a class is how you get to read children's records. Any student
-- could take it, make a class, tell four friends it is for the maths quiz,
-- and read their results.
--
-- Requiring the database password for every teacher is safe but useless — it
-- means uncle running SQL every time a colleague joins.
--
-- So: access codes. Somebody with the database password generates one, hands
-- it to a real teacher, and that teacher redeems it once inside the app. The
-- code can be limited to a number of uses, expired, or switched off, and
-- every redemption is recorded against the person who used it.
--
-- To create one, run this as the project owner:
--
--   insert into teacher_invite_codes (code, label, max_uses, expires_at)
--   values ('STMARYS-2026', 'St Marys maths department', 8,
--           now() + interval '60 days');
--
-- To switch one off:
--
--   update teacher_invite_codes set disabled_at = now()
--   where code = 'STMARYS-2026';

create table if not exists teacher_invite_codes (
  code        text primary key,
  label       text,
  max_uses    int not null default 1 check (max_uses > 0),
  used_count  int not null default 0,
  created_at  timestamptz not null default now(),
  expires_at  timestamptz,
  disabled_at timestamptz
);

-- Row level security on, and deliberately not one single policy. No student,
-- no teacher, nobody signed in can read this table or write to it. The only
-- thing that touches it is claim_teacher_role below, which runs as the owner.
-- A table of valid codes that any user could read would be no protection at
-- all.
alter table teacher_invite_codes enable row level security;

-- Who redeemed what, so a code handed to the wrong person can be traced.
create table if not exists teacher_invite_uses (
  code       text not null references teacher_invite_codes (code) on delete cascade,
  user_id    uuid not null references auth.users (id) on delete cascade,
  claimed_at timestamptz not null default now(),
  primary key (code, user_id)
);

alter table teacher_invite_uses enable row level security;

drop policy if exists "Read own claim" on teacher_invite_uses;
create policy "Read own claim" on teacher_invite_uses
  for select to authenticated using (auth.uid() = user_id);

-- Redeem a code. Returns nothing useful on failure beyond an error message,
-- and deliberately gives the same message whether the code is unknown, spent,
-- expired or switched off — a different message for each would let somebody
-- probe for which codes exist.
create or replace function claim_teacher_role(p_code text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code teacher_invite_codes%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;

  -- Already a teacher, so nothing to do. Not an error.
  if exists (select 1 from staff_roles where user_id = auth.uid()) then
    return true;
  end if;

  select * into v_code
  from teacher_invite_codes
  where code = upper(trim(p_code))
    and disabled_at is null
    and (expires_at is null or expires_at > now())
    and used_count < max_uses
  for update;

  if not found then
    raise exception 'That code is not valid.';
  end if;

  insert into staff_roles (user_id, role, note)
  values (auth.uid(), 'teacher', 'redeemed ' || v_code.code)
  on conflict (user_id) do nothing;

  insert into teacher_invite_uses (code, user_id)
  values (v_code.code, auth.uid())
  on conflict do nothing;

  update teacher_invite_codes
     set used_count = used_count + 1
   where code = v_code.code;

  return true;
end;
$$;

-- ---------------------------------------------------------------------------
-- 10. Classes
-- ---------------------------------------------------------------------------
-- join_code is read aloud in a classroom, so the alphabet leaves out the
-- characters that get misheard: no O against 0, no I against 1.
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
  join_code   text not null unique,
  created_at  timestamptz not null default now(),
  archived_at timestamptz
);

create index if not exists classes_teacher_idx
  on classes (teacher_id) where archived_at is null;

-- status carries the consent model.
--
--   invited  a teacher has asked; the student has not agreed yet and NOTHING
--            of theirs is visible
--   active   the student joined, or accepted an invitation
--   removed  either side ended it
--
-- Only 'active' grants a teacher anything. That is the difference between
-- adding a student and enrolling one.
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

create or replace function generate_join_code()
returns text
language plpgsql
volatile
set search_path = public
as $$
declare
  v_alphabet constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  v_code text;
  v_try  int := 0;
begin
  loop
    v_code := '';
    for i in 1..6 loop
      v_code := v_code ||
        substr(v_alphabet, 1 + floor(random() * length(v_alphabet))::int, 1);
    end loop;
    exit when not exists (select 1 from classes where join_code = v_code);
    v_try := v_try + 1;
    if v_try > 50 then
      raise exception 'Could not allocate a join code.';
    end if;
  end loop;
  return v_code;
end;
$$;

create or replace function create_class(p_name text, p_grade int)
returns table (id bigint, name text, grade int, join_code text)
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
  if p_grade < 9 or p_grade > 12 then
    raise exception 'Grade must be between 9 and 12.';
  end if;
  if length(trim(coalesce(p_name, ''))) = 0 then
    raise exception 'Give the class a name.';
  end if;

  insert into classes (teacher_id, name, grade, join_code)
  values (auth.uid(), trim(p_name), p_grade, generate_join_code())
  returning classes.id into v_id;

  return query
    select c.id, c.name, c.grade, c.join_code from classes c where c.id = v_id;
end;
$$;

-- Everything a teacher needs for their class list, in one call.
create or replace function my_classes()
returns table (
  id           bigint,
  name         text,
  grade        int,
  join_code    text,
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
  select c.id, c.name, c.grade, c.join_code,
         -- distinct, because the join to attempts fans each student out into
         -- one row per tap. count(*) here would report taps as people.
         count(distinct e.student_id) filter (where e.status = 'active'),
         count(distinct e.student_id) filter (where e.status = 'invited'),
         count(distinct a.student_id) filter (
           where a.answered_at > now() - interval '1 day'),
         c.created_at
  from classes c
  left join enrolments e on e.class_id = c.id
  left join attempts a on a.student_id = e.student_id
                      and e.status = 'active'
                      and a.grade = c.grade
  where c.teacher_id = auth.uid()
    and c.archived_at is null
  group by c.id, c.name, c.grade, c.join_code, c.created_at
  order by c.created_at desc;
$$;

-- A teacher asking a student to join. Note what this does NOT do: it does not
-- enrol them. It creates an invitation the student has to accept, and until
-- they do, the teacher can see nothing of theirs. Adding somebody to a class
-- without their knowledge is exactly the thing worth preventing.
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
    raise exception 'No student with that email has an account yet. Ask them to sign up first, or give them the class code.';
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
create or replace function join_class(p_code text)
returns table (joined_class_id bigint, joined_class_name text,
               teacher_email text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_class classes%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;

  select * into v_class from classes
  where join_code = upper(trim(p_code)) and archived_at is null;

  if not found then
    raise exception 'No open class has that code.';
  end if;

  insert into enrolments (class_id, student_id, status, joined_at)
  values (v_class.id, auth.uid(), 'active', now())
  on conflict (class_id, student_id) do update
    set status = 'active', joined_at = now(), removed_at = null;

  return query
    select v_class.id, v_class.name,
           -- auth.users.email is varchar, and RETURNS TABLE demands an
           -- exact type match, so the cast is required rather than tidiness.
           (select email::text from auth.users
             where id = v_class.teacher_id);
end;
$$;

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

create or replace function regenerate_join_code(p_class_id bigint)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare v_code text;
begin
  if not owns_class(p_class_id) then
    raise exception 'That is not your class.';
  end if;
  v_code := generate_join_code();
  update classes set join_code = v_code where id = p_class_id;
  return v_code;
end;
$$;

-- ---------------------------------------------------------------------------
-- 14. The dashboard
-- ---------------------------------------------------------------------------

-- Slug to plain English.
--
-- A function rather than a table so it extends without a migration, and so an
-- untranslated slug degrades into something readable instead of a blank.
create or replace function misconception_label(p_tag text)
returns text
language sql
immutable
as $$
  select case p_tag
    when 'sign-error-negatives'         then 'losing track of minus signs'
    when 'distributive-sign-error'      then 'dropping the minus sign when expanding brackets'
    when 'order-of-operations'          then 'working left to right instead of following BEDMAS'
    when 'combines-unlike-terms'        then 'adding terms that cannot be combined'
    when 'fraction-common-denominator'  then 'adding fractions without a common denominator'
    when 'percent-as-decimal'           then 'converting percentages'
    when 'slope-vs-intercept-confusion' then 'mixing up slope and intercept'
    when 'slope-formula-inverted'       then 'using run over rise instead of rise over run'
    when 'chooses-wrong-ratio'          then 'picking the wrong trigonometric ratio'
    when 'composition-order'            then 'applying composed functions in the wrong order'
    when 'domain-denominator-zero'      then 'forgetting values that make a denominator zero'
    when 'completing-square-sign'       then 'the sign when completing the square'
    when 'scale-factor-direction'       then 'applying a scale factor the wrong way round'
    when 'unsorted-median'              then 'finding the median without sorting first'
    when 'perimeter-vs-area'            then 'confusing perimeter and area'
    when 'volume-vs-surface-area'       then 'confusing volume and surface area'
    when 'half-life-count'              then 'counting half-lives'
    when 'log-exponential-form-swap'    then 'rearranging logarithms into exponential form'
    when 'quadratic-formula-sign'       then 'a sign slip in the quadratic formula'
    when 'discriminant-sign-meaning'    then 'reading what the discriminant means'
    when 'inverse-operation-order'      then 'undoing operations in the wrong order'
    when 'radius-not-squared'           then 'forgetting to square the radius'
    when 'forgets-half-in-triangle-area' then 'forgetting the half in the triangle area formula'
    when 'exponent-division-rule'       then 'dividing powers'
    when 'reference-angle'              then 'finding the reference angle'
    when 'average-rate-of-change'       then 'working out an average rate of change'
    else replace(p_tag, '-', ' ')
  end;
$$;


-- One row per student. last_active is deliberately prominent: a student who
-- has not opened the app in three weeks is a different problem from one who
-- is practising and struggling, and a score cannot tell those apart.
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
  last_active    timestamptz
)
language sql
security definer
stable
set search_path = public
as $$
  select
    p.id,
    -- Fall back to the part of the address before the at sign, so a student
    -- who signed up before names existed still reads as a person.
    coalesce(nullif(trim(p.full_name), ''), split_part(p.email, '@', 1)),
    p.email,
    count(distinct a.unit),
    count(distinct m.unit) filter (where m.medal <> 'None'),
    count(distinct m.unit) filter (where m.medal = 'Gold'),
    count(distinct (a.unit, a.sort_order)),
    round(100.0 * count(*) filter (where a.was_correct and a.was_first_attempt)
          / nullif(count(*) filter (where a.was_first_attempt), 0), 0),
    max(a.answered_at)
  from enrolments e
  join classes  c on c.id = e.class_id
  join profiles p on p.id = e.student_id
  left join attempts     a on a.student_id = p.id and a.grade = c.grade
  left join unit_mastery m on m.student_id = p.id and m.grade = c.grade
  where e.class_id = p_class_id
    and e.status = 'active'
    and c.teacher_id = auth.uid()
  group by p.id, p.email, p.full_name
  order by max(a.answered_at) desc nulls last;
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
    select e.student_id, c.grade
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
  join roster r on r.student_id = a.student_id and r.grade = a.grade
  cross join class_size cs
  where not a.was_correct
    and a.misconception_tag is not null
    and (p_since is null or a.answered_at >= p_since)
  group by a.misconception_tag, a.unit, cs.n
  order by count(distinct a.student_id) desc, count(*) desc;
$$;

-- Which units the class as a whole is finding hard: what to reteach, rather
-- than who to chase.
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
    select e.student_id, c.grade
    from enrolments e
    join classes c on c.id = e.class_id
    where e.class_id = p_class_id
      and e.status = 'active'
      and c.teacher_id = auth.uid()
  ),
  size as (select count(*) as n from roster)
  select m.unit,
         count(*) filter (where m.medal <> 'None'),
         (select n from size),
         round(avg(100.0 * m.best_first_try / nullif(m.total_questions, 0)), 0),
         count(*) filter (where m.medal = 'Gold'),
         count(*) filter (where m.medal = 'Silver'),
         count(*) filter (where m.medal = 'Bronze')
  from unit_mastery m
  join roster r on r.student_id = m.student_id and r.grade = m.grade
  group by m.unit
  order by round(avg(100.0 * m.best_first_try
                     / nullif(m.total_questions, 0)), 0) asc nulls last;
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
    select e.student_id, c.grade
    from enrolments e
    join classes c on c.id = e.class_id
    where e.class_id = p_class_id
      and e.status = 'active'
      and c.teacher_id = auth.uid()
  ),
  class_attempts as (
    select a.*
    from attempts a
    join roster r on r.student_id = a.student_id and r.grade = a.grade
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
      where q.unit = ca.unit and q.grade = ca.grade),
    count(distinct ca.student_id),
    (select count(*) from unit_mastery m
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
  group by ca.unit, ca.grade
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
    select e.student_id, c.grade
    from enrolments e
    join classes c on c.id = e.class_id
    where e.class_id = p_class_id
      and e.status = 'active'
      and c.teacher_id = auth.uid()
  ),
  wrongs as (
    select a.grade, a.unit, a.sort_order, a.chosen_index, a.student_id
    from attempts a
    join roster r on r.student_id = a.student_id and r.grade = a.grade
    where not a.was_correct
  ),
  per_question as (
    select grade, unit, sort_order,
           count(*) as times_wrong,
           count(distinct student_id) as students_wrong
    from wrongs
    group by grade, unit, sort_order
  ),
  -- The single wrong option chosen most often. distinct on keeps the first
  -- row per question once ordered by frequency, which is the mode.
  top_choice as (
    select distinct on (grade, unit, sort_order)
           grade, unit, sort_order, chosen_index
    from (
      select grade, unit, sort_order, chosen_index, count(*) as n
      from wrongs
      group by grade, unit, sort_order, chosen_index
    ) t
    order by grade, unit, sort_order, n desc
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
    on tc.grade = pq.grade and tc.unit = pq.unit
   and tc.sort_order = pq.sort_order
  join questions q
    on q.grade = pq.grade and q.unit = pq.unit
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
               and um.grade = m.grade)                     as medal
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
create or replace function student_detail(p_student uuid)
returns table (
  unit           text,
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
  select m.unit, m.medal, m.best_first_try, m.total_questions,
    (select count(*) from attempts a
      where a.student_id = p_student and a.unit = m.unit
        and a.grade = m.grade and not a.was_correct),
    (select misconception_label(a.misconception_tag) from attempts a
      where a.student_id = p_student and a.unit = m.unit
        and a.grade = m.grade and not a.was_correct
        and a.misconception_tag is not null
      group by a.misconception_tag order by count(*) desc limit 1),
    (select max(a.answered_at) from attempts a
      where a.student_id = p_student and a.unit = m.unit and a.grade = m.grade)
  from unit_mastery m
  where m.student_id = p_student
    and teaches_student(p_student)
  order by m.unit;
$$;

-- ===========================================================================
-- 15. Parent reports
-- ===========================================================================
-- The report is a dozen counts. The hard part is consent, which is why most
-- of what follows is about that.
--
--   Double opt-in. A student names a guardian; nothing is sent until that
--   guardian clicks a link. An address typed into a box is not consent, and a
--   mistyped one must never receive a child's marks.
--
--   One-click revocation, no login. Requiring an account to stop receiving
--   mail about your own child is not a real opt-out.
--
--   Data minimisation. Counts and the names of misconceptions. No question
--   text, no answer log. A parent should learn their child struggles with
--   negative signs; they do not need a transcript, and the student should not
--   feel surveilled by the app that is meant to help them.
--
-- Before this reaches families beyond your own: Ontario schools fall under
-- MFIPPA, and anything collected outside a board falls under PIPEDA. Storing
-- guardian email addresses is the point where this stops being a hobby
-- project, and neither law is satisfied by a schema.

create table if not exists report_recipients (
  id            bigint generated always as identity primary key,
  student_id    uuid not null references auth.users (id) on delete cascade,
  email         text not null,
  display_name  text,
  status        text not null default 'pending'
                check (status in ('pending', 'active', 'revoked')),
  consent_token uuid not null default gen_random_uuid(),
  requested_at  timestamptz not null default now(),
  confirmed_at  timestamptz,
  revoked_at    timestamptz,
  unique (student_id, email)
);

create unique index if not exists report_recipients_token_idx
  on report_recipients (consent_token);

-- When the "do you want these reports" email was last sent, so a student
-- tapping Add three times does not send a guardian three identical emails.
alter table report_recipients
  add column if not exists consent_sent_at timestamptz;

-- Stops a retrying scheduler mailing the same week twice, and is the record
-- you would need if a parent asked what had been sent about their child.
create table if not exists report_log (
  id           bigint generated always as identity primary key,
  student_id   uuid not null references auth.users (id) on delete cascade,
  recipient_id bigint references report_recipients (id) on delete set null,
  week_start   date not null,
  -- 'weekly' for the Sunday run, 'manual' when a student sends one himself.
  -- The two are counted separately: the weekly job must never send twice for
  -- the same week, but a student showing a parent something they are proud of
  -- should not be blocked because Sunday already went out.
  kind         text not null default 'weekly'
               check (kind in ('weekly', 'manual')),
  payload      jsonb not null,
  sent_at      timestamptz not null default now()
);

alter table report_log add column if not exists kind text;
update report_log set kind = 'weekly' where kind is null;

do $$
begin
  -- The original table had unique(recipient_id, week_start), which would stop
  -- a manual send once the weekly one had gone. Dedupe now applies only to
  -- the scheduled run.
  if exists (select 1 from pg_constraint
             where conname = 'report_log_recipient_id_week_start_key') then
    alter table report_log
      drop constraint report_log_recipient_id_week_start_key;
  end if;
end
$$;

create unique index if not exists report_log_weekly_once_idx
  on report_log (recipient_id, week_start) where kind = 'weekly';

create index if not exists report_log_student_idx
  on report_log (student_id, week_start desc);

alter table report_recipients enable row level security;
alter table report_log        enable row level security;

-- A student can always see who is on their list and what was sent. Being
-- surprised by who is receiving reports on your work is the failure mode.
drop policy if exists "Read own recipients" on report_recipients;
create policy "Read own recipients" on report_recipients
  for select to authenticated using (auth.uid() = student_id);

drop policy if exists "Read own report log" on report_log;
create policy "Read own report log" on report_log
  for select to authenticated using (auth.uid() = student_id);


-- One week for one student.
--
-- Everything is a count or a label. The per-unit breakdown and the comparison
-- with last week are what make it worth reading: "42 percent" tells a parent
-- nothing, but "she practised on four days, finished two units, and keeps
-- dropping minus signs in Algebraic expressions" is something they can act on.
create or replace function weekly_report(
  p_student    uuid,
  p_week_start date
)
returns jsonb
language sql
security definer
stable
set search_path = public
as $$
  with bounds as (
    select p_week_start::timestamptz as starts,
           (p_week_start + 7)::timestamptz as ends,
           (p_week_start - 7)::timestamptz as prev_starts
  ),
  this_week as (
    select a.* from attempts a, bounds b
    where a.student_id = p_student
      and a.answered_at >= b.starts and a.answered_at < b.ends
  ),
  last_week as (
    select a.* from attempts a, bounds b
    where a.student_id = p_student
      and a.answered_at >= b.prev_starts and a.answered_at < b.starts
  ),
  totals as (
    select
      count(distinct (unit, sort_order))                    as questions_seen,
      count(*) filter (where was_correct and was_first_attempt) as first_try,
      count(*) filter (where was_first_attempt)             as first_taps,
      count(*) filter (where not was_correct)               as wrong_taps,
      count(distinct unit)                                  as units_touched,
      count(distinct date_trunc('day', answered_at))        as days_active,
      max(answered_at)                                      as last_active
    from this_week
  ),
  prev as (
    select
      count(distinct (unit, sort_order)) as questions_seen,
      round(100.0 * count(*) filter (where was_correct and was_first_attempt)
            / nullif(count(*) filter (where was_first_attempt), 0), 0)
                                         as first_try_rate,
      count(distinct date_trunc('day', answered_at)) as days_active
    from last_week
  ),
  per_unit as (
    select t.unit,
           count(distinct t.sort_order)                     as questions,
           count(*) filter (where t.was_correct and t.was_first_attempt)
                                                            as first_try,
           count(*) filter (where not t.was_correct)        as wrong_taps,
           (select m.medal from unit_mastery m
             where m.student_id = p_student and m.unit = t.unit
               and m.grade = t.grade)                       as medal
    from this_week t
    group by t.unit, t.grade
    order by count(distinct t.sort_order) desc
  ),
  medals_week as (
    select m.unit, m.medal
    from unit_mastery m, bounds b
    where m.student_id = p_student and m.medal <> 'None'
      and m.updated_at >= b.starts and m.updated_at < b.ends
  ),
  weak as (
    select misconception_tag as tag, unit, count(*) as times
    from this_week
    where not was_correct and misconception_tag is not null
    group by misconception_tag, unit
    order by count(*) desc
    limit 3
  )
  select jsonb_build_object(
    'week_start',     p_week_start,
    'questions_seen', coalesce(t.questions_seen, 0),
    'first_try',      coalesce(t.first_try, 0),
    'first_try_rate', round(100.0 * t.first_try / nullif(t.first_taps, 0), 0),
    'wrong_taps',     coalesce(t.wrong_taps, 0),
    'units_touched',  coalesce(t.units_touched, 0),
    'days_active',    coalesce(t.days_active, 0),
    'last_active',    t.last_active,
    'previous_week',  jsonb_build_object(
                        'questions_seen', coalesce(pv.questions_seen, 0),
                        'first_try_rate', pv.first_try_rate,
                        'days_active',    coalesce(pv.days_active, 0)),
    'units',          coalesce((
                        select jsonb_agg(jsonb_build_object(
                          'unit', pu.unit, 'questions', pu.questions,
                          'first_try', pu.first_try,
                          'wrong_taps', pu.wrong_taps,
                          'medal', coalesce(pu.medal, 'None')))
                        from per_unit pu), '[]'::jsonb),
    'medals_earned',  coalesce((
                        select jsonb_agg(jsonb_build_object(
                          'unit', mw.unit, 'medal', mw.medal))
                        from medals_week mw), '[]'::jsonb),
    'weak_spots',     coalesce((
                        select jsonb_agg(jsonb_build_object(
                          'tag', w.tag,
                          'label', misconception_label(w.tag),
                          'unit', w.unit,
                          'times', w.times))
                        from weak w), '[]'::jsonb)
  )
  from totals t, prev pv;
$$;

create or replace function request_report_recipient(
  p_email text,
  p_name  text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int;
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;

  if p_email !~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$' then
    raise exception 'That does not look like an email address.';
  end if;

  -- A cap, because an unbounded address list on the account of a child is a
  -- way to send unsolicited mail using this project as the sender.
  select count(*) into v_count from report_recipients
  where student_id = auth.uid() and status <> 'revoked';

  if v_count >= 3 then
    raise exception 'You can have at most three people on your list.';
  end if;

  insert into report_recipients (student_id, email, display_name)
  values (auth.uid(), lower(trim(p_email)), p_name)
  on conflict (student_id, email) do update
    set status = 'pending', display_name = excluded.display_name,
        requested_at = now(), confirmed_at = null, revoked_at = null,
        consent_sent_at = null,
        -- A fresh token, so any old link stops working.
        consent_token = gen_random_uuid();
end;
$$;

-- ---------------------------------------------------------------------------
-- Asking a guardian whether they want the reports
-- ---------------------------------------------------------------------------
-- service_role only, because it hands out the consent token. That token is
-- the entire authentication on the confirm link, so it goes from here to the
-- mail sender and nowhere else.
--
-- Only rows that have not been asked in the last day come back, so a student
-- tapping Add repeatedly cannot use this project to pester somebody.

create or replace function pending_consents_for(p_student uuid)
returns table (
  recipient_id  bigint,
  email         text,
  display_name  text,
  student_name  text,
  grade         int,
  token         uuid
)
language sql
security definer
stable
set search_path = public
as $$
  select r.id, r.email, r.display_name,
         coalesce(nullif(trim(p.full_name), ''),
                  split_part(p.email, '@', 1)),
         p.grade,
         r.consent_token
  from report_recipients r
  join profiles p on p.id = r.student_id
  where r.student_id = p_student
    and r.status = 'pending'
    and (r.consent_sent_at is null
         or r.consent_sent_at < now() - interval '1 day');
$$;

create or replace function mark_consent_sent(p_recipient_id bigint)
returns void
language sql
security definer
set search_path = public
as $$
  update report_recipients
     set consent_sent_at = now()
   where id = p_recipient_id;
$$;

create or replace function confirm_report_recipient(p_token uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare v_id bigint;
begin
  update report_recipients
     set status = 'active', confirmed_at = now(), revoked_at = null
   where consent_token = p_token and status = 'pending'
   returning id into v_id;
  return v_id is not null;
end;
$$;

-- Returns true for an already-revoked row too, so a second click does not
-- show an error to somebody who simply wants out.
create or replace function revoke_report_recipient(p_token uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare v_id bigint;
begin
  update report_recipients
     set status = 'revoked', revoked_at = now()
   where consent_token = p_token and status in ('pending', 'active')
   returning id into v_id;

  if v_id is not null then return true; end if;

  return exists (select 1 from report_recipients
                 where consent_token = p_token and status = 'revoked');
end;
$$;

create or replace function remove_report_recipient(p_recipient_id bigint)
returns void
language sql
security definer
set search_path = public
as $$
  update report_recipients
     set status = 'revoked', revoked_at = now()
   where id = p_recipient_id and student_id = auth.uid();
$$;

-- Reads across students, so service_role only. An Edge Function holding the
-- service key calls it, sends the mail, then calls record_report_sent.
--
-- The bar is deliberately not zero: a report saying a child did nothing this
-- week is not information, it is a nudge to nag, and it teaches families to
-- ignore the emails.
create or replace function reports_due(p_week_start date)
returns table (
  recipient_id bigint, student_id uuid, email text, display_name text,
  grade int, payload jsonb, unsubscribe uuid
)
language sql
security definer
stable
set search_path = public
as $$
  select r.id, r.student_id, r.email, r.display_name, p.grade,
         weekly_report(r.student_id, p_week_start), r.consent_token
  from report_recipients r
  join profiles p on p.id = r.student_id
  where r.status = 'active'
    and not exists (select 1 from report_log l
                    where l.recipient_id = r.id
                      and l.week_start = p_week_start)
    and (weekly_report(r.student_id, p_week_start)
         ->> 'questions_seen')::int > 0;
$$;

create or replace function record_report_sent(
  p_recipient_id bigint,
  p_week_start   date,
  p_payload      jsonb,
  p_kind         text default 'weekly'
)
returns void
language sql
security definer
set search_path = public
as $$
  insert into report_log (student_id, recipient_id, week_start, payload, kind)
  select r.student_id, r.id, p_week_start, p_payload, p_kind
  from report_recipients r where r.id = p_recipient_id
  on conflict do nothing;
$$;

-- ---------------------------------------------------------------------------
-- Sending a report on demand
-- ---------------------------------------------------------------------------
-- A student who has just earned a Gold should be able to show somebody
-- without waiting until Sunday. Two rules keep that from becoming a nuisance:
--
--   One a day. Not because the database would mind, but because a guardian
--   who receives six emails on a Tuesday stops opening any of them, and the
--   weekly one stops working.
--
--   Only to people who already agreed. This sends to confirmed recipients
--   and nobody else — it is not a way to email an address on the spot.

-- What the app needs to draw the button: who would receive it, and whether
-- one has already gone today.
create or replace function my_report_status()
returns jsonb
language sql
security definer
stable
set search_path = public
as $$
  select jsonb_build_object(
    'recipients', (
      select count(*) from report_recipients
      where student_id = auth.uid() and status = 'active'),
    'pending', (
      select count(*) from report_recipients
      where student_id = auth.uid() and status = 'pending'),
    'last_manual', (
      select max(sent_at) from report_log
      where student_id = auth.uid() and kind = 'manual'),
    'can_send_now', (
      select count(*) > 0 from report_recipients
      where student_id = auth.uid() and status = 'active'
    ) and not exists (
      select 1 from report_log
      where student_id = auth.uid() and kind = 'manual'
        and sent_at > now() - interval '20 hours'),
    'last_sent', (
      select max(sent_at) from report_log where student_id = auth.uid())
  );
$$;

-- What the sender needs for one student. service_role only, same as
-- reports_due: it hands out the consent token, which must never reach a
-- browser or a student could confirm their own guardian.
--
-- Note it reports on the CURRENT week rather than the last completed one.
-- Somebody pressing send today means "show them what I did today".
create or replace function manual_report_for(p_student uuid)
returns table (
  recipient_id bigint, student_id uuid, email text, display_name text,
  grade int, payload jsonb, unsubscribe uuid
)
language sql
security definer
stable
set search_path = public
as $$
  select r.id, r.student_id, r.email, r.display_name, p.grade,
         weekly_report(r.student_id, date_trunc('week', now())::date),
         r.consent_token
  from report_recipients r
  join profiles p on p.id = r.student_id
  where r.student_id = p_student
    and r.status = 'active'
    -- The daily limit is enforced here as well as in the app, because an
    -- app-side check is a suggestion and this one is not.
    and not exists (
      select 1 from report_log l
      where l.student_id = p_student and l.kind = 'manual'
        and l.sent_at > now() - interval '20 hours'
    );
$$;

-- ---------------------------------------------------------------------------
-- 16. Permissions
-- ---------------------------------------------------------------------------
-- Every dashboard function checks ownership inside its own query, so granting
-- execute to authenticated is safe: a student calling class_roster on a class
-- id they guessed gets an empty result, not somebody else's marks.
--
-- confirm and revoke are open to anon on purpose. Guardians click a link from
-- an email and have no account; the token is the authentication.

revoke all on function generate_join_code()              from public, anon, authenticated;
revoke all on function weekly_report(uuid, date)         from public, anon, authenticated;
revoke all on function reports_due(date)                 from public, anon, authenticated;
revoke all on function record_report_sent(bigint, date, jsonb, text)
                                                         from public, anon, authenticated;
revoke all on function manual_report_for(uuid)           from public, anon, authenticated;

grant execute on function claim_teacher_role(text)          to authenticated;
grant execute on function is_teacher()                      to authenticated;
grant execute on function is_enrolled_in(bigint)            to authenticated;
grant execute on function owns_class(bigint)                to authenticated;
grant execute on function create_class(text, int)           to authenticated;
grant execute on function my_classes()                      to authenticated;
grant execute on function my_classes_as_student()           to authenticated;
grant execute on function invite_student(bigint, text)      to authenticated;
grant execute on function join_class(text)                  to authenticated;
grant execute on function respond_to_invitation(bigint, boolean) to authenticated;
grant execute on function leave_class(bigint)               to authenticated;
grant execute on function remove_student(bigint, uuid)      to authenticated;
grant execute on function archive_class(bigint)             to authenticated;
grant execute on function regenerate_join_code(bigint)      to authenticated;
grant execute on function class_roster(bigint)              to authenticated;
grant execute on function class_misconceptions(bigint, timestamptz)
                                                            to authenticated;
grant execute on function class_unit_summary(bigint)        to authenticated;
grant execute on function student_detail(uuid)              to authenticated;
grant execute on function class_unit_breakdown(bigint)      to authenticated;
grant execute on function class_hard_questions(bigint)      to authenticated;
grant execute on function student_overview(uuid)            to authenticated;
grant execute on function misconception_label(text)         to anon, authenticated;
grant execute on function request_report_recipient(text, text) to authenticated;
grant execute on function remove_report_recipient(bigint)   to authenticated;
grant execute on function my_report_status()                to authenticated;

revoke all on function pending_consents_for(uuid)  from public, anon, authenticated;
revoke all on function mark_consent_sent(bigint)   from public, anon, authenticated;
grant execute on function pending_consents_for(uuid) to service_role;
grant execute on function mark_consent_sent(bigint)  to service_role;
grant execute on function confirm_report_recipient(uuid)    to anon, authenticated;
grant execute on function revoke_report_recipient(uuid)     to anon, authenticated;

grant execute on function weekly_report(uuid, date)               to service_role;
grant execute on function reports_due(date)                       to service_role;
grant execute on function record_report_sent(bigint, date, jsonb, text)
                                                                  to service_role;
grant execute on function manual_report_for(uuid)                 to service_role;

-- ---------------------------------------------------------------------------
-- 17. Reporting views
-- ---------------------------------------------------------------------------
-- Both inherit row level security from attempts, so a student sees their own
-- rows and a teacher sees their own students, without either query changing.

create or replace view my_weekly_progress as
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

create or replace view misconception_counts as
select grade, unit, sort_order, chosen_index, misconception_tag,
       count(*)                   as times_chosen,
       count(distinct student_id) as students_affected
from attempts
where not was_correct
group by grade, unit, sort_order, chosen_index, misconception_tag;

-- ---------------------------------------------------------------------------
-- 18. First run
-- ---------------------------------------------------------------------------
-- Load the questions:   questions_all_tagged.sql
--
-- Then make yourself a teacher. Create a code:
--
--   insert into teacher_invite_codes (code, label, max_uses)
--   values ('FAMILY-2026', 'Set up by uncle', 5);
--
-- and redeem it inside the app under Menu, I am a teacher. Codes can be
-- switched off later with:
--
--   update teacher_invite_codes set disabled_at = now() where code = '...';
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
