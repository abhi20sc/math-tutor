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

create or replace function my_reachable_pool()
returns table (unit text, tag text, questions_open int)
language sql
security definer
stable
set search_path = public
as $$
  with me as (
    select p.course from profiles p where p.id = auth.uid()
  )
  select q.unit,
         q.misconception_tag,
         count(*)::int
  from questions q, me
  where q.course_code = me.course
    and q.misconception_tag is not null
    -- The whole rule. level_is_free is the single definition of which
    -- levels are open without Astro+, and has_premium is the single
    -- definition of who has it; this defers to both rather than repeating
    -- either, so a change to the paywall moves this automatically.
    and (has_premium() or level_is_free(q.difficulty))
  group by q.unit, q.misconception_tag;
$$;

revoke all on function my_reachable_pool() from public, anon;
grant execute on function my_reachable_pool() to authenticated;

-- Verify, signed in as a student:
--
--   select sum(questions_open) from my_reachable_pool();
--   -- half the course's tagged questions on a free account,
--   -- all of them on Astro+
