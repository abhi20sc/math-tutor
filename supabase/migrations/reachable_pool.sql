-- ===========================================================================
-- reachable_pool — how many questions in a subtopic this student can attempt
-- Run AFTER astro_math_assist_setup.sql. Safe to re-run. Changes nothing
-- that already exists.
-- ===========================================================================
--
-- WHY THIS EXISTS
--
-- The report bands a subtopic purely on FIRST-TRY RATE, with no notion of
-- how much of it has been seen. So two answers both right reads exactly
-- the same as seven answers all right: 100%, top band. One number is doing
-- two jobs, accuracy and coverage, and it can only do one.
--
-- Fixing that needs a denominator, and the obvious one is wrong. The bank
-- has 40 questions per unit and 20 of them — Challenge and Advanced — are
-- behind Astro+. If the denominator is every question, a student who has
-- not paid can answer every question available to them, perfectly, and
-- never reach the top band. They would have no way to find out why. Making
-- the top of a learning ladder purchasable rather than earnable is a real
-- cost, and an invisible one.
--
-- So the denominator is THE POOL THIS STUDENT CAN ACTUALLY ATTEMPT: Easy
-- and Medium for a free account, all four levels for Astro+. The top band
-- becomes reachable by everyone, and paying visibly enlarges the map
-- rather than unlocking a badge.
--
-- WHAT THIS DOES NOT DO
--
-- It adds a number. It does not change a band, a percentage or a colour —
-- report_payload is untouched, and the 212 checks over it still describe
-- it exactly. The ladder that uses this number lives in the app, where it
-- can be read and tested without a database.
-- ===========================================================================

\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
-- 1. Premium, for a named student
-- ---------------------------------------------------------------------------
--
-- has_premium() answers for auth.uid() and nothing else, which is right for
-- every existing caller and useless for the two that follow: the parent
-- reading a shared link is not the student, and the pool has to be the
-- STUDENT'S pool or the parent's copy of the report disagrees with the one
-- their child is looking at.
--
-- The rule itself is not restated here. has_premium() is redefined below as
-- a thin call to this, so the DATABASE still holds exactly one definition
-- of premium — which is what the setup file demands of anything that needs
-- to know.
--
-- The predicate below is that definition MOVED. The old copy is still
-- sitting in astro_math_assist_setup.sql, inside the has_premium() body
-- this file overwrites, so the two live in the same repository and only one
-- of them is ever in force. That is safe in the order the checklist runs
-- them (setup, then this) and it is worth knowing that re-running the setup
-- file afterwards would put the inline copy back. Nothing breaks if it
-- does: the two predicates are identical, so the answer does not change,
-- only the number of places it is written.
create or replace function student_has_premium(p_student uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from subscriptions
    where student_id = p_student
      and (status in ('active', 'trialing', 'manual')
           or (current_period_end is not null
               and current_period_end > now()))
  );
$$;

-- The original, now deferring rather than deciding. Same answer, same
-- callers, same grants — this is a redefinition, not a new function, so
-- everything already calling has_premium() picks it up untouched.
create or replace function has_premium()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select student_has_premium(auth.uid());
$$;

-- ---------------------------------------------------------------------------
-- 2. The pool
-- ---------------------------------------------------------------------------
--
-- The body both entry points share. Not granted to anyone: it takes a
-- student id and would otherwise let any signed-in account read any other
-- student's pool. The two wrappers below are where the permission lives —
-- one proves you ARE the student, the other proves you hold their link.
create or replace function reachable_pool_for(p_student uuid)
returns table (unit text, tag text, questions_open int)
language sql
security definer
stable
set search_path = public
as $$
  with them as (
    select p.course, student_has_premium(p_student) as paid
    from profiles p where p.id = p_student
  )
  select q.unit,
         q.misconception_tag,
         count(*)::int
  from questions q, them
  where q.course_code = them.course
    and q.misconception_tag is not null
    -- The whole rule. level_is_free is the single definition of which
    -- levels are open without Astro+, and student_has_premium is the single
    -- definition of who has it; this defers to both rather than repeating
    -- either, so a change to the paywall moves this automatically.
    and (them.paid or level_is_free(q.difficulty))
  group by q.unit, q.misconception_tag;
$$;

revoke all on function reachable_pool_for(uuid) from public, anon, authenticated;

create or replace function my_reachable_pool()
returns table (unit text, tag text, questions_open int)
language sql
security definer
stable
set search_path = public
as $$
  select * from reachable_pool_for(auth.uid());
$$;

revoke all on function my_reachable_pool() from public, anon;
grant execute on function my_reachable_pool() to authenticated;

-- The same numbers down a share link, so a parent's copy of the report says
-- the same words as the student's.
--
-- Without this the shared report has no pool at all, and the app withholds
-- the top rung when it does not know the pool. The child would see
-- "Completed" and the parent, on the same data, "Nearly there" — the exact
-- kind of one-screen contradiction this whole change exists to remove.
--
-- Token rules copied from shared_report deliberately: revoked or unknown
-- returns nothing rather than an error, and reveals nothing about whether
-- the link ever existed. It does NOT bump view_count — that counts report
-- views, and this is a second call within one of them.
create or replace function shared_reachable_pool(p_token uuid)
returns table (unit text, tag text, questions_open int)
language sql
security definer
stable
set search_path = public
as $$
  select r.* from report_shares s
  cross join lateral reachable_pool_for(s.student_id) r
  where s.token = p_token and s.revoked_at is null;
$$;

revoke all on function shared_reachable_pool(uuid) from public;
grant execute on function shared_reachable_pool(uuid) to anon, authenticated;

-- ===========================================================================
-- Verify
-- ===========================================================================
--
-- Signed in as a student:
--
--   select sum(questions_open) from my_reachable_pool();
--   -- half the course's tagged questions on a free account,
--   -- all of them on Astro+
--
-- The pool a small subtopic gives a free student, which is the number the
-- app's three-look guard has to bend to:
--
--   select min(questions_open) from my_reachable_pool();
--   -- 2 on a free account. 26 subtopics across the six courses are that
--   -- small, and the app scores them off two looks rather than leaving
--   -- them permanently "just started". See looksNeededToScore.
--
-- And that the two doors give the same answer for the same student:
--
--   select (select sum(questions_open) from my_reachable_pool())
--        = (select sum(questions_open) from shared_reachable_pool('<token>'));
