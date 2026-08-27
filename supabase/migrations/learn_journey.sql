-- ===========================================================================
-- ASTRO STEM LABS — Learn becomes a journey
-- Run AFTER astro_sections.sql. Safe to re-run.
-- ===========================================================================
--
-- WHAT THIS ADDS
--
-- One column on list_lessons: `solved`, the number of DISTINCT questions on
-- that subtopic the student has ever got right. That is the whole server
-- side of the Learn path.
--
-- WHY A NEW NUMBER RATHER THAN A NEW TABLE
--
-- The path needs to know whether a node is finished, and "finished" here
-- means read the lesson and then get some questions on it right. Both halves
-- already exist in the database: lesson_reads has the first, and attempts
-- has the second. A `learn_progress` table would be a third copy of facts
-- already recorded twice, and the first time it disagreed with attempts the
-- student would be told they had not done work they had actually done.
--
-- So nothing is stored. The path is derived, every time, from what the
-- student really did. Resetting progress resets the path for free, because
-- the reset already filters attempts and this counts the same rows.
--
-- WHY DISTINCT, AND WHY NOT FIRST-TRY
--
--   distinct — answering the SAME question right three times is one
--   question, not three. Without this a student could pass a gate by
--   reloading one question, which is the exact shape of not learning that
--   this app exists to refuse.
--
--   not first-try — the existing `band` is first-try and should stay that
--   way, because it measures how well the subtopic is known. A gate
--   measures something different: did you get there in the end. Getting a
--   question right on the second attempt, after the feedback named the
--   mistake, is the app working, and gating on first-try would punish a
--   student for using the one feature the whole app is built around.
--
-- Two numbers, two meanings, neither pretending to be the other — the same
-- rule the attempts table already follows for test rows.
--
-- WHAT DOES NOT CHANGE
--
-- No table is created, altered or dropped. No policy changes. No grant
-- changes. list_lessons keeps every column it had, in the same order, so a
-- client that has not been rebuilt reads exactly what it read before.
-- ===========================================================================

\set ON_ERROR_STOP on

-- create or replace cannot widen a return type. Drop first.
drop function if exists list_lessons(text, text);

create or replace function list_lessons(p_course text, p_unit text)
returns table (
  id            bigint,
  tag           text,
  subtopic      text,
  sort_order    int,
  title         text,
  summary       text,
  read_minutes  int,
  has_video     boolean,
  read_at       timestamptz,
  read_seconds  int,
  band          text,
  first_looks   int,
  -- New, and the only new thing.
  solved        int
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
    select a.* from attempts a
    where a.student_id = auth.uid()
      and a.course = p_course
      and a.unit = p_unit
      and (not exists (select 1 from reset)
           or a.answered_at > (select reset_at from reset))
  ),
  tagged as (
    -- misconception_tag is null on correct rows by design, so join back to
    -- the bank to recover which subtopic each attempt belonged to.
    select a.was_first_attempt, a.was_correct, a.sort_order, a.difficulty,
           q.misconception_tag
    from mine a
    join questions q
      on q.course_code = p_course and q.unit = a.unit
     and q.sort_order = a.sort_order and q.difficulty = a.difficulty
  ),
  per_tag as (
    select m.misconception_tag as tag,
           count(*) filter (where m.was_first_attempt) as looks,
           count(*) filter (where m.was_first_attempt and m.was_correct) as hits,
           -- One question answered right, however many attempts it took and
           -- however many times it has been revisited, counts once.
           count(distinct case when m.was_correct
                               then (m.sort_order, m.difficulty) end) as solved
    from tagged m
    group by m.misconception_tag
  )
  select l.id,
         l.tag,
         misconception_label(l.tag),
         l.sort_order,
         l.title,
         l.summary,
         l.read_minutes,
         (l.video_url is not null),
         r.first_read_at,
         coalesce(r.read_seconds, 0),
         case
           when l.tag is null            then null
           when coalesce(t.looks, 0) < 2 then 'grey'
           when 100.0 * t.hits / t.looks >= 90 then 'green'
           when 100.0 * t.hits / t.looks >= 70 then 'light-green'
           when 100.0 * t.hits / t.looks >= 50 then 'yellow'
           else 'orange'
         end,
         coalesce(t.looks, 0)::int,
         coalesce(t.solved, 0)::int
  from lessons l
  left join lesson_reads r
    on r.lesson_id = l.id and r.student_id = auth.uid()
  left join per_tag t on t.tag = l.tag
  where l.course_code = p_course
    and l.unit = p_unit
    and auth.uid() is not null
  order by l.sort_order;
$$;

revoke all on function list_lessons(text, text) from public, anon;
grant execute on function list_lessons(text, text) to authenticated;

-- Verify, after running:
--
--   select sort_order, title, read_at is not null as read, first_looks, solved
--   from list_lessons('MPM2D', 'Quadratics') order by sort_order;
--
-- solved must never exceed the number of questions carrying that tag, and
-- must never fall when a question is answered right a second time.
