-- ===========================================================================
-- ASTRO STEM LABS — the end-of-test review shows the answer
-- Run AFTER astro_sections.sql. Safe to re-run.
-- ===========================================================================
--
-- WHAT THIS CHANGES, AND WHY IT IS NOT A SMALL CHANGE
--
-- The founding rule of this app is that a wrong tap names the mistake and
-- never reveals the answer, because the student is going to meet that
-- question again and the second attempt is where the learning is.
-- test_item_review was built to hold that line even after the paper was
-- closed, and tests/test_sections.sql D7 asserted it in so many words:
-- "review still never prints the correct answer".
--
-- This file deliberately breaks D7, on the owner's decision. The argument
-- for it is that a test is not practice:
--
--   * it is summative — the paper is closed, the score is recorded, and
--     only the best score ever counts
--   * its attempts are written with source='test' and are never first
--     looks, so nothing a student learns here can flatter their bands
--   * a student who has just finished fifteen questions and cannot find out
--     which ones they got wrong has been given a mark, not a lesson
--
-- THE ROUTE THIS WOULD OPEN, AND WHAT CLOSES IT
--
-- Left alone, a student could start a paper, finish it without answering
-- anything, and read fifteen answers drawn from the same unit pool that
-- Quiz and Improve draw from. That is a real hole and worth closing.
--
-- The obvious guard — refuse to finish a paper with no answers — barely
-- helps: answer one question, read fifteen answers. So the rule here is
-- narrower and means something on its own terms:
--
--   THE REVIEW ONLY EVER SHOWS ITEMS THE STUDENT ACTUALLY ANSWERED.
--
-- It is a review of their work, not an answer key. A student who sat the
-- whole paper sees all fifteen. One who ran out of time sees exactly what
-- they attempted, which is the honest thing to show them anyway. Somebody
-- finishing an untouched paper to read the answers sees nothing at all,
-- and the abuse is not worth the trip.
--
-- No rate limit, no counter, no new table. One where clause.
--
-- Note this also means the row count from this function is the number of
-- items ANSWERED, not the number on the paper. test_result is where the
-- score over the full total lives, and that is unchanged.
--
-- WHAT DOES NOT CHANGE
--
--   * test_paper still ships no answer. The line that matters is that
--     nothing is revealed while the paper is LIVE, and T6 and T9 still
--     pin that.
--   * list_questions and submit_answer are untouched. Quiz and Improve
--     behave exactly as before.
--   * the guard on this function is unchanged: the test must be yours and
--     it must be finished.
-- ===========================================================================

\set ON_ERROR_STOP on

-- create or replace cannot widen a function's return type — it fails with
-- "cannot change return type of existing function", the same error the old
-- admin_teacher_students.sql now throws. Drop it first.
drop function if exists test_item_review(bigint);

create or replace function test_item_review(p_test bigint)
returns table (
  item_no       int,
  difficulty    text,
  prompt        text,
  chosen_text   text,
  was_correct   boolean,
  feedback      text,
  subtopic      text,
  -- New. Everything below this line is what the review can now show.
  chosen_index  int,
  correct_index int,
  options       jsonb
)
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_course text;
begin
  -- Unchanged, and load-bearing: yours, and finished. A live paper returns
  -- nothing from here at all.
  select t.course into v_course from practice_tests t
  where t.id = p_test and t.student_id = auth.uid()
    and t.finished_at is not null;
  if v_course is null then
    raise exception 'No such finished test.';
  end if;

  return query
  select i.item_no,
         i.difficulty,
         q.prompt,
         q.options -> i.chosen_index ->> 'text',
         coalesce(i.was_correct, false),
         case when coalesce(i.was_correct, false) then null
              else q.options -> i.chosen_index ->> 'feedback' end,
         misconception_label(i.tag),
         i.chosen_index,
         q.correct_index,
         -- Every option, with the line that names the mistake it comes
         -- from. The correct one's feedback is exactly 'Correct.' by the
         -- authoring rule, so there is no prose here explaining why the
         -- answer is right — the app must not pretend otherwise.
         q.options
  from practice_test_items i
  join questions q
    on q.course_code = v_course and q.unit = i.unit
   and q.sort_order = i.sort_order and q.difficulty = i.difficulty
  where i.test_id = p_test
    -- The whole guard. An unanswered item has no chosen_index, and its
    -- answer is not this student's to read.
    and i.chosen_index is not null
  order by i.item_no;
end;
$$;

revoke all on function test_item_review(bigint) from public, anon;
grant execute on function test_item_review(bigint) to authenticated;

-- Verify, after running:
--
--   select item_no, was_correct, chosen_index, correct_index,
--          jsonb_array_length(options)
--   from test_item_review(<a finished test id of your own>);
--
-- Expect one row per item you answered, options of length 4 on every one,
-- and no row at all for anything you left blank.
