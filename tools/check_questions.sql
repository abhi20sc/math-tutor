-- ===========================================================================
-- Authoring checks for one course/unit of the question bank.
--
--   psql -d <db> -v course=MTH1W -v unit='Powers' -f tools/check_questions.sql
--
-- Every check prints zero rows when the unit is clean.  Anything that comes
-- back is a defect, and the first column names it.
-- ===========================================================================

\set ON_ERROR_STOP on

\echo '--- 1. every question has exactly four options'
select sort_order, jsonb_array_length(options) as n
from questions
where course_code = :'course' and unit = :'unit'
  and jsonb_array_length(options) <> 4;

\echo '--- 2. correct_index in range 0-3'
select sort_order, correct_index
from questions
where course_code = :'course' and unit = :'unit'
  and (correct_index is null or correct_index < 0 or correct_index > 3);

\echo '--- 3. the correct option feedback is exactly "Correct."'
select sort_order, options -> correct_index ->> 'feedback' as fb
from questions
where course_code = :'course' and unit = :'unit'
  and coalesce(options -> correct_index ->> 'feedback', '') <> 'Correct.';

\echo '--- 4. no wrong option is allowed to say "Correct."'
select q.sort_order, o.ord, o.val ->> 'feedback' as fb
from questions q
cross join lateral jsonb_array_elements(q.options) with ordinality as o(val, ord)
where q.course_code = :'course' and q.unit = :'unit'
  and o.ord - 1 <> q.correct_index
  and o.val ->> 'feedback' = 'Correct.';

\echo '--- 5. every option has non-empty text and feedback'
select q.sort_order, o.ord
from questions q
cross join lateral jsonb_array_elements(q.options) with ordinality as o(val, ord)
where q.course_code = :'course' and q.unit = :'unit'
  and (coalesce(trim(o.val ->> 'text'), '') = ''
       or coalesce(trim(o.val ->> 'feedback'), '') = '');

\echo '--- 6. no duplicate option text inside a question'
select sort_order, txt, count(*)
from (
  select q.sort_order, o.val ->> 'text' as txt
  from questions q
  cross join lateral jsonb_array_elements(q.options) as o(val)
  where q.course_code = :'course' and q.unit = :'unit'
) t
group by sort_order, txt
having count(*) > 1;

\echo '--- 7. sort_order sits inside its difficulty band, 1-40 with no gaps'
select sort_order, difficulty
from questions
where course_code = :'course' and unit = :'unit'
  and difficulty <> case
        when sort_order between  1 and 10 then 'Easy'
        when sort_order between 11 and 20 then 'Medium'
        when sort_order between 21 and 30 then 'Challenge'
        when sort_order between 31 and 40 then 'Advanced'
        else 'out of range' end;

select 'missing sort_order' as problem, g.n
from generate_series(1, 40) as g(n)
where not exists (
  select 1 from questions
  where course_code = :'course' and unit = :'unit' and sort_order = g.n);

\echo '--- 8. every question is tagged and every tag is labelled'
select sort_order, misconception_tag
from questions
where course_code = :'course' and unit = :'unit'
  and (misconception_tag is null
       or misconception_tag not in (select tag from misconception_labels));

\echo '--- 9. no apostrophes anywhere (they break the single-quoted SQL)'
select sort_order, 'prompt' as field
from questions
where course_code = :'course' and unit = :'unit' and prompt like '%''%'
union all
select q.sort_order, 'option'
from questions q
cross join lateral jsonb_array_elements(q.options) as o(val)
where q.course_code = :'course' and q.unit = :'unit'
  and (o.val ->> 'text' like '%''%' or o.val ->> 'feedback' like '%''%');

\echo '--- 10. LEAK: wrong-option feedback that hands over the right answer'
select q.sort_order,
       o.val ->> 'feedback' as fb,
       q.options -> q.correct_index ->> 'text' as answer
from questions q
cross join lateral jsonb_array_elements(q.options) with ordinality as o(val, ord)
where q.course_code = :'course' and q.unit = :'unit'
  and o.ord - 1 <> q.correct_index
  and (
        o.val ->> 'feedback' ~* '(the (right|correct) answer is|answer is |it is actually|should be |the answer would be|really equals|actually equals)'
     or (length(q.options -> q.correct_index ->> 'text') >= 2
         and position(lower(q.options -> q.correct_index ->> 'text')
                      in lower(q.prompt)) = 0
         and position(lower(q.options -> q.correct_index ->> 'text')
                      in lower(o.val ->> 'feedback')) > 0)
  );
-- Two exemptions on the substring arm, both there to stop this crying wolf.
--
-- A one-character answer such as "1" matches half the English language.
--
-- And a number the QUESTION already gave the student cannot be leaked back to
-- them: "A father is three times as old as his son. In 12 years..." has the
-- answer 12, so every sane hint mentions 12. Both are exempt here; a real leak
-- on either still trips the phrase arm above.

\echo '--- 11a. every subtopic must appear in every difficulty band'
-- A subtopic missing from a band means a student can never be diagnosed on it
-- at that level, so the traffic light for it is decided by too little evidence.
select s.misconception_tag, d.difficulty as missing_from
from (select distinct misconception_tag from questions
      where course_code = :'course' and unit = :'unit') s
cross join (values ('Easy'), ('Medium'), ('Challenge'), ('Advanced')) as d(difficulty)
where not exists (
  select 1 from questions q
  where q.course_code = :'course' and q.unit = :'unit'
    and q.misconception_tag = s.misconception_tag
    and q.difficulty = d.difficulty)
order by 1, 2;

\echo '--- 11b. no subtopic may dominate or barely register (5-10 per unit)'
select misconception_tag, count(*)
from questions
where course_code = :'course' and unit = :'unit'
group by 1
having count(*) < 5 or count(*) > 10
order by 1;

\echo '--- 12. answer position must not be predictable'
-- main.dart does not shuffle options, so the position the SQL puts the correct
-- answer in is the position the student sees. MCR3U Unit 1 shipped with 39 of
-- 40 answers at option A, which let a student score without reading and
-- inflated every first-try rate on the tutor dashboard. Anything above 40 percent
-- in one position is a leak. Fix with tools/balance_answer_positions.py.
select correct_index, count(*),
       round(100.0 * count(*) / sum(count(*)) over (), 0) as pct
from questions
where course_code = :'course' and unit = :'unit'
group by correct_index
having count(*) > 0.40 * (select count(*) from questions
                          where course_code = :'course' and unit = :'unit')
order by 1;

\echo '--- summary'
select difficulty, count(*) as questions, count(misconception_tag) as tagged
from questions
where course_code = :'course' and unit = :'unit'
group by difficulty
order by min(sort_order);
