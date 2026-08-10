\set ON_ERROR_STOP off
\pset pager off

grant all on all tables in schema public to authenticated;
grant all on all sequences in schema public to authenticated;

insert into auth.users (id, email) values
  ('aaaa0000-0000-0000-0000-000000000001', 'alice@test.ca'),
  ('bbbb0000-0000-0000-0000-000000000002', 'bob@test.ca'),
  ('cccc0000-0000-0000-0000-000000000003', 'ms.roy@school.ca');
insert into profiles (id, email, grade) values
  ('aaaa0000-0000-0000-0000-000000000001', 'alice@test.ca', 12),
  ('bbbb0000-0000-0000-0000-000000000002', 'bob@test.ca', 12);

-- Uncle creates one code, good for two teachers.
insert into teacher_invite_codes (code, label, max_uses)
values ('FAMILY-2026', 'set up by uncle', 2);

-- Give Alice a week of work.
select set_config('test.uid', 'aaaa0000-0000-0000-0000-000000000001', false);
do $$
declare r record;
begin
  for r in select sort_order, correct_index from questions
           where grade = 12 and unit = 'Rational functions' loop
    perform submit_answer(12, 'Rational functions', r.sort_order,
                          (r.correct_index + 1) % 4);
    perform submit_answer(12, 'Rational functions', r.sort_order,
                          r.correct_index);
  end loop;
  for r in select sort_order, correct_index from questions
           where grade = 12 and unit = 'Polynomial functions' loop
    perform submit_answer(12, 'Polynomial functions', r.sort_order,
                          r.correct_index);
  end loop;
end $$;
select award_medal(12, 'Rational functions'), award_medal(12, 'Polynomial functions');

set role authenticated;

\echo ''
\echo '=== C1  a student cannot read the code table (expect 0 rows) ==='
select count(*) as codes_a_student_can_see from teacher_invite_codes;

\echo ''
\echo '=== C2  a student guessing a code (expect ERROR: not valid) ==='
select claim_teacher_role('GUESS-123');

\echo ''
\echo '=== C3  Ms Roy redeems the real code ==='
select set_config('test.uid', 'cccc0000-0000-0000-0000-000000000003', false);
select claim_teacher_role('family-2026') as claimed;
select is_teacher() as she_is_now_a_teacher;

\echo ''
\echo '=== C4  a student is still not a teacher ==='
select set_config('test.uid', 'aaaa0000-0000-0000-0000-000000000001', false);
select is_teacher() as alice_is_teacher;
select create_class('Fake class', 12);

\echo ''
\echo '=== C5  Ms Roy creates a class ==='
select set_config('test.uid', 'cccc0000-0000-0000-0000-000000000003', false);
select id, name, join_code from create_class('MHF4U Period 2', 12);
reset role;
create temp table code as select id, join_code from classes limit 1;
grant select on code to authenticated;
set role authenticated;

\echo ''
\echo '=== C6  she invites Bob by email ==='
select set_config('test.uid', 'cccc0000-0000-0000-0000-000000000003', false);
select invite_student((select id from code), 'bob@test.ca') as result;

\echo ''
\echo '=== C7  an invitation shows nothing until accepted (expect 0 rows) ==='
select count(*) as bob_on_roster from class_roster((select id from code));

\echo ''
\echo '=== C8  Bob sees the invitation and who sent it ==='
select set_config('test.uid', 'bbbb0000-0000-0000-0000-000000000002', false);
select class_name, teacher_email, status from my_classes_as_student();

\echo ''
\echo '=== C9  Bob accepts; Alice joins with the code instead ==='
select respond_to_invitation((select id from code), true);
select set_config('test.uid', 'aaaa0000-0000-0000-0000-000000000001', false);
select joined_class_name from join_class((select join_code from code));

\echo ''
\echo '=== C10  Alice can see who is watching her work ==='
select class_name, teacher_email, status from my_classes_as_student();

\echo ''
\echo '=== C11  the class list a teacher lands on ==='
select set_config('test.uid', 'cccc0000-0000-0000-0000-000000000003', false);
select name, grade, students, invited from my_classes();

\echo ''
\echo '=== C12  the roster ==='
select email, units_medalled, gold, questions_seen, first_try_rate
from class_roster((select id from code));

\echo ''
\echo '=== C13  the payoff query ==='
select label, unit, students_affected, share_of_class
from class_misconceptions((select id from code)) limit 3;

\echo ''
\echo '=== C14  Alice leaves; teacher access stops at once ==='
select set_config('test.uid', 'aaaa0000-0000-0000-0000-000000000001', false);
select leave_class((select id from code));
select set_config('test.uid', 'cccc0000-0000-0000-0000-000000000003', false);
select count(*) as roster_now from class_roster((select id from code));
select count(*) as alice_attempts_visible from attempts
where student_id = 'aaaa0000-0000-0000-0000-000000000001';

\echo ''
\echo '=== C15  code use is capped: a third teacher is refused ==='
reset role;
insert into auth.users (id, email)
values ('eeee0000-0000-0000-0000-000000000005', 'third@school.ca');
update teacher_invite_codes set used_count = 2 where code = 'FAMILY-2026';
set role authenticated;
select set_config('test.uid', 'eeee0000-0000-0000-0000-000000000005', false);
select claim_teacher_role('FAMILY-2026');

\echo ''
\echo '=== C16  the comprehensive weekly report ==='
reset role;
select jsonb_pretty(weekly_report('aaaa0000-0000-0000-0000-000000000001',
                                  date_trunc('week', now())::date));
