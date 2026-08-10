\set ON_ERROR_STOP on
\pset pager off

insert into auth.users (id, email)
values ('44444444-4444-4444-4444-444444444444', 'retry@test.ca');
insert into profiles (id, email, grade)
values ('44444444-4444-4444-4444-444444444444', 'retry@test.ca', 12);

select set_config('test.uid', '44444444-4444-4444-4444-444444444444', false);

create temp table k as
select sort_order, correct_index, difficulty
from questions where grade = 12 and unit = 'Rational functions';

\echo '=== R1  first pass, every question fumbled once => Bronze ==='
do $$
declare r record;
begin
  for r in select * from k loop
    perform submit_answer(12, 'Rational functions', r.sort_order,
                          (r.correct_index + 1) % 4);
    perform submit_answer(12, 'Rational functions', r.sort_order,
                          r.correct_index);
  end loop;
end $$;
select award_medal(12, 'Rational functions') as pass1_expect_bronze;

\echo '=== R2  second pass, all correct first tap => should UPGRADE to Gold ==='
do $$
declare r record;
begin
  for r in select * from k loop
    perform submit_answer(12, 'Rational functions', r.sort_order,
                          r.correct_index);
  end loop;
end $$;
select award_medal(12, 'Rational functions') as pass2_expect_gold;
select medal as on_record, times_completed, best_first_try
from unit_mastery where unit = 'Rational functions';

\echo '=== R3  third pass, done badly => medal must NOT drop ==='
do $$
declare r record;
begin
  for r in select * from k loop
    perform submit_answer(12, 'Rational functions', r.sort_order,
                          (r.correct_index + 1) % 4);
    perform submit_answer(12, 'Rational functions', r.sort_order,
                          r.correct_index);
  end loop;
end $$;
select award_medal(12, 'Rational functions') as pass3_scored;
select medal as still_on_record from unit_mastery
where unit = 'Rational functions';

\echo '=== R4  Gold needs the Hard ones: 9/10 first try, one Hard missed ==='
create temp table p as
select sort_order, correct_index, difficulty
from questions where grade = 12 and unit = 'Polynomial functions';

do $$
declare r record; v_hard int;
begin
  select min(sort_order) into v_hard from p where difficulty = 'Hard';
  for r in select * from p loop
    if r.sort_order = v_hard then
      -- fumble exactly one Hard question, then get it right
      perform submit_answer(12, 'Polynomial functions', r.sort_order,
                            (r.correct_index + 1) % 4);
    end if;
    perform submit_answer(12, 'Polynomial functions', r.sort_order,
                          r.correct_index);
  end loop;
end $$;
select award_medal(12, 'Polynomial functions') as expect_silver_not_gold;
select hard_first_try, hard_total, best_first_try, total_questions
from unit_mastery where unit = 'Polynomial functions';

\echo '=== R5  an unfinished unit earns nothing ==='
do $$
declare r record;
begin
  for r in select * from questions
           where grade = 12 and unit = 'Trigonometric functions (radians)'
           limit 3 loop
    perform submit_answer(12, 'Trigonometric functions (radians)',
                          r.sort_order, r.correct_index);
  end loop;
end $$;
select award_medal(12, 'Trigonometric functions (radians)') as expect_none;
