-- ===========================================================================
-- ASTRO STEM LABS — the indexes Postgres does not create for you
-- Run any time, on any database. Safe to re-run. Changes no behaviour.
-- ===========================================================================
--
-- Postgres indexes a PRIMARY KEY and a UNIQUE constraint automatically. It
-- does NOT index a foreign key. That surprises people, and it stays quiet
-- for exactly as long as the tables are small: every one of these is a
-- sequential scan today over a few hundred rows, and the same scan over a
-- few hundred thousand when a school is using this.
--
-- Found by Supabase's own performance advisor, which flagged five unindexed
-- foreign keys and one table with no primary key at all.
--
-- CONCURRENTLY is deliberately NOT used. It cannot run inside a transaction
-- block, and the Supabase SQL editor wraps a paste in one, so it would fail
-- for the person most likely to run this. These tables are small enough
-- that a plain CREATE INDEX takes milliseconds and the brief lock does not
-- matter. On a table with real volume, run them one at a time from psql
-- with CONCURRENTLY instead.
-- ===========================================================================

\set ON_ERROR_STOP on

-- The five foreign keys with no covering index. Each one is a column the
-- planner has to scan a whole table to satisfy, and each is on a join the
-- app actually makes: a tutor opening a class, a student opening Learn, an
-- admin opening the e-transfer queue.
--
-- Guarded on the table existing, and that is not belt-and-braces. The live
-- database and a fresh install are NOT the same shape: teacher_invite_uses
-- is a leftover of the old teacher invite-code system, still present on the
-- live project and no longer created by astro_math_assist_setup.sql. An
-- unguarded create index on it fails outright against a clean database,
-- which is how this file was written the first time and how the difference
-- was found.
--
-- The same is true in reverse of anything a future setup file adds, so the
-- guard is the right shape here regardless of which tables happen to
-- diverge today.
do $$
declare
  target record;
begin
  for target in
    select * from (values
      ('etransfer_claims',    'student_id', 'etransfer_claims_student_idx'),
      ('lesson_reads',        'lesson_id',  'lesson_reads_lesson_idx'),
      ('profiles',            'course',     'profiles_course_idx'),
      ('teacher_invite_uses', 'user_id',    'teacher_invite_uses_user_idx'),
      ('tutor_notes',         'teacher_id', 'tutor_notes_teacher_idx')
    ) as t(tbl, col, idx)
  loop
    if to_regclass('public.' || target.tbl) is null then
      raise notice 'skipped %: no such table here', target.tbl;
      continue;
    end if;
    execute format('create index if not exists %I on public.%I (%I)',
                   target.idx, target.tbl, target.col);
    raise notice 'indexed %.%', target.tbl, target.col;
  end loop;
end $$;

-- rate_limit_hits was, when this file was written, a table with no primary
-- key that nothing wrote to — a table for a feature that was never built.
-- That is no longer true: student_safeguarding.sql now creates it properly,
-- with a primary key on (bucket, window_start), and note_rate_limit writes
-- to it on every sign-in, signup and password reset.
--
-- Nothing to do here. The note is kept because the old shape may still be
-- sitting on a database that predates that migration, and a reader finding
-- a keyless rate_limit_hits should know which of the two they are looking
-- at. student_safeguarding.sql uses create table if not exists, so it will
-- NOT reshape an existing one — on the live project, drop the old empty
-- table before running it.

-- Verify:
--
--   select indexname from pg_indexes
--   where indexname like '%_idx' and schemaname = 'public'
--     and indexname in ('etransfer_claims_student_idx',
--                       'lesson_reads_lesson_idx',
--                       'profiles_course_idx',
--                       'teacher_invite_uses_user_idx',
--                       'tutor_notes_teacher_idx');
--
-- Five rows on the live database. Four on a database built from this repo,
-- because teacher_invite_uses is not created there — the NOTICE output says
-- which were skipped and why.
