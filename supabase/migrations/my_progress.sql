-- ===========================================================================
-- my_progress — one row per unit instead of one row per attempt
-- Run AFTER astro_math_assist_setup.sql. Safe to re-run.
-- ===========================================================================
--
-- WHAT THIS REPLACES
--
-- The app's fetchProgress downloaded every attempt row a student had ever
-- made, over the wire, and reduced them in the browser to two sets of
-- question numbers per unit. Five columns times every question they have
-- ever answered, to draw a progress bar.
--
-- At eight students and 316 attempts that is invisible. It is also exactly
-- the shape that stops being invisible without warning: the query has no
-- limit, the payload grows for the whole life of an account, and it runs on
-- every single load of the app. A student two years in, on a phone, on a
-- school connection, is the case nobody tests.
--
-- WHY IT RETURNS ARRAYS AND NOT COUNTS
--
-- The obvious fix is to return "23 of 40 solved" and be done. That does not
-- work, because the level picker needs to know WHICH questions are solved
-- so it can put the student on the next unsolved one. A count cannot do
-- that.
--
-- So this returns, per unit, the sort_orders as arrays. The result is
-- bounded by the number of units in a course — six to nine — rather than by
-- how long the student has been using the app. The same information, in a
-- shape whose size stops growing.
--
-- THE TWO RULES THAT HAD TO COME WITH IT
--
-- Both of these were in the Dart and are easy to lose in a rewrite, so they
-- are stated here rather than left to be rediscovered:
--
--   1. source = 'test' rows are EXCLUDED from solved. A practice test
--      writes an attempt per item so the diagnosis keeps learning from it,
--      but the level picker skips anything solved — so counting test rows
--      would silently remove questions from Quiz that the student had never
--      worked through there. One fifteen-question test removed four.
--
--   2. first-try is a SET, not a counter. A question answered correctly
--      after three wrong taps must not be able to count more than once.
--      distinct does that; count(*) filter would not.
-- ===========================================================================

\set ON_ERROR_STOP on

create or replace function my_progress(p_course text)
returns table (
  unit             text,
  solved_orders    int[],
  first_try_orders int[]
)
language sql
security definer
stable
set search_path = public
as $$
  with reset as (
    -- The student's last "start over" for this course, if any. Attempts
    -- before it do not count toward the current run.
    select max(r.reset_at) as at
    from progress_resets r
    where r.student_id = auth.uid() and r.course = p_course
  ),
  live as (
    select a.unit, a.sort_order, a.was_first_attempt
    from attempts a, reset
    where a.student_id = auth.uid()
      and a.course = p_course
      and a.was_correct
      -- Rule 1. coalesce because rows written before the column existed
      -- carry null and every one of those is a quiz row.
      and coalesce(a.source, 'quiz') <> 'test'
      and (reset.at is null or a.answered_at > reset.at)
  )
  select l.unit,
         array_agg(distinct l.sort_order) as solved_orders,
         -- Rule 2. array_agg(distinct ...) filtered, so a question answered
         -- right on the fourth tap appears once or not at all, never twice.
         coalesce(
           array_agg(distinct l.sort_order)
             filter (where l.was_first_attempt),
           '{}'::int[]) as first_try_orders
  from live l
  group by l.unit;
$$;

revoke all on function my_progress(text) from public, anon;
grant execute on function my_progress(text) to authenticated;

-- The index this leans on. attempts already has one on (student_id, course)
-- from the setup file; this adds answered_at so the reset cutoff is a range
-- scan rather than a filter over everything the student has ever done.
create index if not exists attempts_student_course_time_idx
  on attempts (student_id, course, answered_at);

-- Verify, as a signed-in student:
--   select * from my_progress('MPM2D');
--   -- one row per unit, not one per attempt
