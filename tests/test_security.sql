\set ON_ERROR_STOP off
\pset pager off

-- Supabase grants these by default; the stub has to do it explicitly.
grant all on all tables in schema public to authenticated;
grant all on all sequences in schema public to authenticated;
grant select on all tables in schema public to anon;

insert into auth.users (id, email) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'alice@test.ca'),
  ('bbbbbbbb-0000-0000-0000-000000000002', 'bob@test.ca'),
  ('cccccccc-0000-0000-0000-000000000003', 'teacher1@test.ca'),
  ('dddddddd-0000-0000-0000-000000000004', 'teacher2@test.ca');

insert into profiles (id, email, grade) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'alice@test.ca', 12),
  ('bbbbbbbb-0000-0000-0000-000000000002', 'bob@test.ca', 12);

-- Only teacher1 is staff. Note this insert is only possible because psql is
-- running as the owner — that is the whole design.
insert into staff_roles (user_id, role) values
  ('cccccccc-0000-0000-0000-000000000003', 'teacher'),
  ('dddddddd-0000-0000-0000-000000000004', 'teacher');

-- Give Alice some history.
select set_config('test.uid', 'aaaaaaaa-0000-0000-0000-000000000001', false);
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
end $$;
select award_medal(12, 'Rational functions');

\echo ''
\echo '################ SECURITY TESTS (as role: authenticated) ################'
set role authenticated;

\echo ''
\echo '=== S1  a student CANNOT read the questions table (expect ERROR) ==='
select set_config('test.uid', 'aaaaaaaa-0000-0000-0000-000000000001', false);
select correct_index from questions limit 1;

\echo ''
\echo '=== S2  ...but CAN get questions through the function (expect 10) ==='
select count(*) as questions_via_rpc
from list_questions(12, 'Rational functions');

\echo ''
\echo '=== S3  Bob cannot see Alice attempts (expect 0) ==='
select set_config('test.uid', 'bbbbbbbb-0000-0000-0000-000000000002', false);
select count(*) as bob_sees_alice_rows from attempts
where student_id = 'aaaaaaaa-0000-0000-0000-000000000001';

\echo ''
\echo '=== S4  Alice sees her own (expect > 0) ==='
select set_config('test.uid', 'aaaaaaaa-0000-0000-0000-000000000001', false);
select count(*) as alice_sees_own from attempts;

\echo ''
\echo '=== S5  a student cannot insert a fake attempt (expect ERROR) ==='
insert into attempts (student_id, grade, unit, sort_order, chosen_index,
                      was_correct, was_first_attempt)
values (auth.uid(), 12, 'Rational functions', 1, 0, true, true);

\echo ''
\echo '=== S6  a student cannot award themselves a medal (expect ERROR) ==='
insert into unit_mastery (student_id, grade, unit, medal)
values (auth.uid(), 12, 'Polynomial functions', 'Gold');

\echo ''
\echo '=== S7  a student cannot make themselves a teacher (expect ERROR) ==='
insert into staff_roles (user_id, role) values (auth.uid(), 'teacher');

\echo ''
\echo '=== S8  is_teacher is false for a student (expect f) ==='
select is_teacher() as alice_is_teacher;

\echo ''
\echo '################ TEACHER TESTS ################'
\echo ''
\echo '=== S9  teacher1 creates a class ==='
select set_config('test.uid', 'cccccccc-0000-0000-0000-000000000003', false);
select id, name, grade, length(join_code) as code_len
from create_class('MHF4U Period 2', 12);
-- Stash the code the way a real class does it: the teacher reads it out.
-- A student cannot query it, which is why this cannot be a subquery below.
create temp table code as select join_code, id from classes limit 1;

\echo ''
\echo '=== S10  Alice joins it ==='
select set_config('test.uid', 'aaaaaaaa-0000-0000-0000-000000000001', false);
select joined_class_name from join_class((select join_code from code));

\echo ''
\echo '=== S11  teacher1 sees Alice on the roster (expect 1 row) ==='
select set_config('test.uid', 'cccccccc-0000-0000-0000-000000000003', false);
select email, units_medalled, questions_seen, first_try_rate
from class_roster((select id from code));

\echo ''
\echo '=== S12  ALICE calling class_roster gets nothing (expect 0 rows) ==='
select set_config('test.uid', 'aaaaaaaa-0000-0000-0000-000000000001', false);
select count(*) as rows_a_student_sees
from class_roster((select id from code));

\echo ''
\echo '=== S13  teacher2 reading teacher1 class gets nothing (expect 0) ==='
select set_config('test.uid', 'dddddddd-0000-0000-0000-000000000004', false);
select count(*) as rows_other_teacher_sees
from class_roster((select id from code));

\echo ''
\echo '=== S14  teacher1 can read Alice attempts through enrolment ==='
select set_config('test.uid', 'cccccccc-0000-0000-0000-000000000003', false);
select count(*) as teacher_sees_attempts from attempts
where student_id = 'aaaaaaaa-0000-0000-0000-000000000001';

\echo ''
\echo '=== S15  the payoff query ==='
select label, unit, students_affected, share_of_class
from class_misconceptions((select id from code))
limit 4;

\echo ''
\echo '=== S16  remove Alice, teacher access must stop immediately ==='
select remove_student((select id from code),
                      'aaaaaaaa-0000-0000-0000-000000000001');
select count(*) as roster_after_removal
from class_roster((select id from code));
select count(*) as attempts_after_removal from attempts
where student_id = 'aaaaaaaa-0000-0000-0000-000000000001';

\echo ''
\echo '################ PARENT REPORT TESTS ################'
\echo ''
\echo '=== S17  Alice adds a guardian; nothing is due while pending ==='
select set_config('test.uid', 'aaaaaaaa-0000-0000-0000-000000000001', false);
select request_report_recipient('parent@example.com', 'A Parent') is not null
       as token_issued;
reset role;
select status from report_recipients;
select count(*) as due_while_pending
from reports_due(date_trunc('week', now())::date);

\echo ''
\echo '=== S18  guardian confirms, now it is due ==='
select confirm_report_recipient((select consent_token from report_recipients))
       as confirmed;
select count(*) as due_after_consent
from reports_due(date_trunc('week', now())::date);

\echo ''
\echo '=== S19  the report contains counts and labels, no question text ==='
select jsonb_pretty(weekly_report('aaaaaaaa-0000-0000-0000-000000000001',
                                  date_trunc('week', now())::date));

\echo ''
\echo '=== S20  guardian unsubscribes, nothing due again ==='
select revoke_report_recipient((select consent_token from report_recipients))
       as revoked;
select count(*) as due_after_revoke
from reports_due(date_trunc('week', now())::date);
