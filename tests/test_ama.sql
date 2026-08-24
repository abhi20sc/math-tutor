-- ===========================================================================
-- AMA test suite — run against a local Postgres, not against production.
-- ===========================================================================
--
--   dropdb --if-exists ama && createdb ama
--   psql -d ama -f tests/00_supabase_stub.sql
--   psql -d ama -f supabase/migrations/supabase_full_setup.sql
--   psql -d ama -f supabase/migrations/questions_grade10.sql
--   psql -d ama -f tests/test_ama.sql
--
-- The previous version of this file printed results for a human to read, and
-- targeted grade 12 'Polynomial functions' — a bank that was retired. Every
-- one of its assertions had been running against zero rows for some time and
-- passing by looking blank. ON_ERROR_STOP was off, so its dead references to
-- claim_teacher_role and teacher_invite_codes printed an error and the run
-- carried on.
--
-- So this version asserts instead of printing. Each check records PASS or
-- FAIL, and the last statement raises if anything failed — which means a
-- broken run cannot be mistaken for a quiet one, whether a person is reading
-- the output or not.
--
-- Four blocks:
--   A  the paywall            (kept from the old file, retargeted to grade 10)
--   B  the answer never leaks (the thesis; was untested)
--   C  teachers and consent   (the half that handles minors; was untested)
--   D  share links            (was untested)
--
-- Plus a REVIEW block at the end that reports content problems rather than
-- failing on them, because fixing those is an authoring decision, not a code
-- one.
-- ===========================================================================

\set ON_ERROR_STOP on
\pset pager off
\set QUIET on

-- Supabase grants these to authenticated by default. RLS, not the absence of
-- a grant, is what protects the tables — so the tests have to run with the
-- same grants production has, or they would prove nothing.
grant all on all tables in schema public to authenticated;
grant all on all sequences in schema public to authenticated;

-- ---------------------------------------------------------------------------
-- Assertion helpers
-- ---------------------------------------------------------------------------
-- t_ok is security definer so it can record a result whatever role the test
-- has switched to. t_raises is deliberately NOT security definer: it has to
-- execute the statement as the current role, or a permission test would run
-- as the owner and pass for the wrong reason.

drop table if exists test_results;
create table test_results (
  id      serial primary key,
  block   text,
  label   text,
  passed  boolean,
  detail  text
);

create or replace function t_ok(p_label text, p_cond boolean,
                                p_detail text default null)
returns void
language plpgsql
security definer
as $$
begin
  insert into test_results (block, label, passed, detail)
  values (left(p_label, 1), p_label, coalesce(p_cond, false), p_detail);
  if coalesce(p_cond, false) then
    raise notice 'PASS  %', p_label;
  else
    raise warning 'FAIL  %  <- %', p_label, coalesce(p_detail, 'no detail');
  end if;
end;
$$;

-- Asserts that a statement is refused. Passing means the server said no.
create or replace function t_raises(p_label text, p_sql text)
returns void
language plpgsql
as $$
declare v_err text;
begin
  begin
    execute p_sql;
  exception when others then
    v_err := sqlerrm;
  end;
  if v_err is null then
    perform t_ok(p_label, false, 'expected an error, got none');
  else
    perform t_ok(p_label, true, left(v_err, 60));
  end if;
end;
$$;

create or replace function t_note(p_block text, p_label text, p_detail text)
returns void
language plpgsql
security definer
as $$
begin
  insert into test_results (block, label, passed, detail)
  values (p_block, p_label, true, p_detail);
end;
$$;

grant execute on function t_ok(text, boolean, text)   to authenticated, anon;
grant execute on function t_raises(text, text)        to authenticated, anon;
grant execute on function t_note(text, text, text)    to authenticated, anon;

-- ---------------------------------------------------------------------------
-- Fixtures
-- ---------------------------------------------------------------------------
-- Grade 10, MPM2D, because that is the only bank that exists. 'Linear
-- systems' is unit 1 and has all four levels.

insert into auth.users (id, email) values
  ('f1000000-0000-0000-0000-000000000001', 'free@test.ca'),
  ('f2000000-0000-0000-0000-000000000002', 'paid@test.ca'),
  ('f3000000-0000-0000-0000-000000000003', 'shy@test.ca'),
  ('f4000000-0000-0000-0000-000000000004', 'tutor@test.ca'),
  ('f5000000-0000-0000-0000-000000000005', 'other@test.ca');

insert into profiles (id, email, full_name, grade, course) values
  ('f1000000-0000-0000-0000-000000000001', 'free@test.ca',
   'Freya Nolan-Baptiste', 10, 'MPM2D'),
  ('f2000000-0000-0000-0000-000000000002', 'paid@test.ca', 'Paid Student',
   10, 'MPM2D'),
  ('f3000000-0000-0000-0000-000000000003', 'shy@test.ca',  'Shy Student',
   11, 'MCR3U'),
  ('f4000000-0000-0000-0000-000000000004', 'tutor@test.ca', 'The Tutor',
   12, 'MHF4U'),
  ('f5000000-0000-0000-0000-000000000005', 'other@test.ca', 'Other Tutor',
   12, 'MHF4U');

-- The webhook grants premium; simulated here exactly as service_role would.
select upsert_subscription('f2000000-0000-0000-0000-000000000002',
  'cus_test', 'sub_test', 'active', now() + interval '30 days');

-- Two teachers, so "a teacher can only reach their own class" is testable.
select grant_teacher_role('tutor@test.ca', 'teacher');
select grant_teacher_role('other@test.ca', 'teacher');

\set free    '''f1000000-0000-0000-0000-000000000001'''
\set paid    '''f2000000-0000-0000-0000-000000000002'''
\set shy     '''f3000000-0000-0000-0000-000000000003'''
\set tutor   '''f4000000-0000-0000-0000-000000000004'''
\set other   '''f5000000-0000-0000-0000-000000000005'''

\set QUIET off
\echo ''
\echo '=========================================================='
\echo ' A — the paywall'
\echo '=========================================================='

set role authenticated;
select set_config('test.uid', :free, false);

-- A1  Locked levels are still listed, with honest counts. The student is
--     meant to see what a subscription would buy; only the questions are
--     withheld.
do $$
declare r record; v_ok boolean := true; v_detail text := '';
begin
  for r in select level, total, locked from list_levels('MPM2D', 'Linear systems')
  loop
    if r.total <> 10 then
      v_ok := false; v_detail := v_detail || r.level || ' total=' || r.total || ' ';
    end if;
    if (r.level in ('Easy', 'Medium')) = r.locked then
      v_ok := false; v_detail := v_detail || r.level || ' locked=' || r.locked || ' ';
    end if;
  end loop;
  perform t_ok('A1  free student sees 4 levels of 10, Challenge+Advanced locked',
               v_ok, v_detail);
end $$;

-- A2  The read path refuses.
select t_raises('A2  free student cannot list Challenge questions',
  $q$ select count(*) from list_questions('MPM2D', 'Linear systems', 'Challenge') $q$);

-- A3  The write path refuses too. This is the one that matters: a hand-built
--     REST call can name a question by number without ever listing it.
select t_raises('A3  free student cannot answer a Challenge question by number',
  $q$ select * from submit_answer('MPM2D', 'Linear systems',
        (select min(sort_order) from questions
          where course_code = 'MPM2D' and unit = 'Linear systems'
            and difficulty = 'Challenge'), 0) $q$);

-- A4  ...and the free levels still work.
select t_ok('A4  free student gets all 10 Easy questions',
  (select count(*) from list_questions('MPM2D', 'Linear systems', 'Easy')) = 10);

-- A5  A paid student gets the locked levels.
select set_config('test.uid', :paid, false);
select t_ok('A5a paid student has premium', has_premium());
select t_ok('A5b paid student gets all 10 Challenge questions',
  (select count(*) from list_questions('MPM2D', 'Linear systems', 'Challenge')) = 10);

-- A6  A perfect run earns Gold.
select set_config('test.uid', :free, false);
reset role;
do $$
declare r record;
begin
  perform set_config('test.uid', 'f1000000-0000-0000-0000-000000000001', false);
  for r in select sort_order, correct_index from questions
           where course_code = 'MPM2D' and unit = 'Linear systems' and difficulty = 'Easy'
  loop
    perform submit_answer('MPM2D', 'Linear systems', r.sort_order, r.correct_index);
  end loop;
end $$;
select t_ok('A6  perfect Easy run earns Gold',
  award_medal('MPM2D', 'Linear systems', 'Easy') = 'Gold');

-- A7  One wrong tap per question is still a finish: Bronze, and Easy keeps
--     its Gold, because medals only ever move up.
do $$
declare r record;
begin
  for r in select sort_order, correct_index from questions
           where course_code = 'MPM2D' and unit = 'Linear systems' and difficulty = 'Medium'
  loop
    perform submit_answer('MPM2D', 'Linear systems', r.sort_order,
                          (r.correct_index + 1) % 4);
    perform submit_answer('MPM2D', 'Linear systems', r.sort_order, r.correct_index);
  end loop;
end $$;
select t_ok('A7a fumbled Medium run earns Bronze, not nothing',
  award_medal('MPM2D', 'Linear systems', 'Medium') = 'Bronze');
select t_ok('A7b Easy still holds Gold — medals never go down',
  (select medal from unit_mastery
    where student_id = :free and unit = 'Linear systems'
      and level = 'Easy') = 'Gold');

-- A8  Even called directly, a locked level cannot be medalled.
set role authenticated;
select set_config('test.uid', :free, false);
select t_ok('A8  award_medal on a locked level returns None',
  award_medal('MPM2D', 'Linear systems', 'Challenge') = 'None');

-- A9  Cancelled and the paid period is over: access ends.
reset role;
select update_subscription_by_sid('sub_test', 'canceled', now() - interval '1 day');
set role authenticated;
select set_config('test.uid', :paid, false);
select t_ok('A9a lapsed subscription loses premium', not has_premium());
select t_raises('A9b lapsed subscription re-locks Challenge',
  $q$ select count(*) from list_questions('MPM2D', 'Linear systems', 'Challenge') $q$);

-- A10 Cancelled but the paid period is not over: access continues. Taking
--     back time a family paid for would be theft with extra steps.
reset role;
select update_subscription_by_sid('sub_test', 'canceled', now() + interval '10 days');
set role authenticated;
select set_config('test.uid', :paid, false);
select t_ok('A10 cancelled but still inside the paid period keeps premium',
  has_premium());

-- A11 The paywall depends on subscriptions being unwritable from a browser.
select t_raises('A11 a student cannot write the subscriptions table',
  $q$ insert into subscriptions (student_id, status)
      values (auth.uid(), 'active') $q$);

-- A12 The unit chips advertise honestly: 20 of 40 behind Astro+.
select set_config('test.uid', :free, false);
select t_ok('A12 list_units reports 20 locked of 40 per unit',
  (select bool_and(total = 40 and locked_total = 20) from list_units('MPM2D')));

\echo ''
\echo '=========================================================='
\echo ' B — the answer never reaches the browser'
\echo '=========================================================='

-- This block is the product thesis expressed as tests. If any of it fails,
-- the app still works and is no longer worth using.

-- B1  Everything list_questions hands out, for every question in the bank.
--     Not a sample: one leaky row is one student who stops learning.
do $$
declare r record; v_bad int := 0; v_detail text := '';
begin
  for r in select unit, difficulty from questions
           where grade = 10 and difficulty in ('Easy', 'Medium')
           group by unit, difficulty
  loop
    select count(*) into v_bad from list_questions('MPM2D', r.unit, r.difficulty) lq,
      lateral jsonb_array_elements(lq.options) e
      where (select count(*) from jsonb_object_keys(e)) <> 1
         or e ? 'feedback';
    if v_bad > 0 then
      v_detail := v_detail || r.unit || '/' || r.difficulty || ' ';
    end if;
  end loop;
  perform t_ok('B1  list_questions options carry text and nothing else',
               v_detail = '', v_detail);
end $$;

-- B2  list_questions has no correct_index column at all. Not blank — absent.
select t_ok('B2  list_questions has no correct_index column',
  not exists (
    select 1 from information_schema.columns
    where table_name = 'list_questions' and column_name = 'correct_index'));

-- B3  A wrong tap returns the feedback for that option, and says it is wrong.
--
--     Note the reset role. questions has RLS on and no policy, so a test
--     running as authenticated reads zero rows from it and would silently
--     submit a null sort_order. Fetch the answer key as owner, then act as
--     the student. This has caught people out before; it is in the gotchas.
reset role;
do $$
declare v_row record; v_q record;
begin
  select sort_order, correct_index into v_q from questions
   where grade = 10 and unit = 'Analytic geometry' and difficulty = 'Easy'
   order by sort_order limit 1;
  select * into v_row from submit_answer('MPM2D', 'Analytic geometry',
    v_q.sort_order, (v_q.correct_index + 1) % 4);
  perform t_ok('B3a a wrong tap is reported wrong', not v_row.was_correct);
  perform t_ok('B3b a wrong tap returns feedback for that option',
    v_row.feedback is not null and v_row.feedback <> 'Correct.',
    v_row.feedback);
end $$;
set role authenticated;

-- B4  The correct option's feedback is exactly 'Correct.' everywhere. Any
--     longer string leaks the answer through its length alone, before a word
--     of it is read.
select t_ok('B4  every correct option feedback is exactly "Correct."',
  (select count(*) from questions
    where (options -> correct_index ->> 'feedback') is distinct from 'Correct.')
  = 0);

-- B5  Nothing signed in can read the questions table directly. There is no
--     policy on it, which is the point — a select returns nothing rather than
--     being refused.
select t_ok('B5  a signed-in student reads zero rows from questions',
  (select count(*) from questions) = 0);

-- B6  Structural sanity of the bank, from the authoring checklist. These have
--     each been an actual authoring bug at some point.
select t_ok('B6a every question has exactly 4 options',
  (select count(*) from questions where jsonb_array_length(options) <> 4) = 0);
select t_ok('B6b correct_index is always 0-3',
  (select count(*) from questions where correct_index not between 0 and 3) = 0);
select t_ok('B6c no question repeats an option',
  (select count(*) from (
     select q.id from questions q, lateral jsonb_array_elements(q.options) e
     group by q.id having count(distinct e ->> 'text') <> 4) x) = 0);
select t_ok('B6d sort_order matches the difficulty band',
  (select count(*) from questions where
      (difficulty = 'Easy'      and sort_order not between  1 and 10) or
      (difficulty = 'Medium'    and sort_order not between 11 and 20) or
      (difficulty = 'Challenge' and sort_order not between 21 and 30) or
      (difficulty = 'Advanced'  and sort_order not between 31 and 40)) = 0);
select t_ok('B6e every question carries a subtopic tag',
  (select count(*) from questions where misconception_tag is null) = 0);
select t_ok('B6f every tag has a label, so no dashboard row reads blank',
  (select count(*) from (select distinct misconception_tag t from questions) q
    left join misconception_labels l on l.tag = q.t where l.tag is null) = 0);

\echo ''
\echo '=========================================================='
\echo ' C — teachers, and the consent boundary'
\echo '=========================================================='

-- C1  The role cannot be self-granted. grant_teacher_role is revoked from
--     authenticated, so this is a permission error, not a logic check that
--     could be reasoned around.
select set_config('test.uid', :free, false);
select t_raises('C1  a student cannot grant themselves the teacher role',
  $q$ select grant_teacher_role('free@test.ca', 'admin') $q$);

-- C2  ...and cannot create a class.
select t_raises('C2  a student cannot create a class',
  $q$ select * from create_class('Sneaky', 'MPM2D') $q$);

-- C3  A teacher can.
select set_config('test.uid', :tutor, false);
do $$
declare v_id bigint;
begin
  select id into v_id from create_class('MPM2D Tuesday', 'MPM2D');
  perform t_ok('C3  a teacher creates a class', v_id is not null);
  perform set_config('test.class', v_id::text, false);
end $$;

-- C4  Inviting is not enrolling. Until the student accepts, the teacher gets
--     nothing — not a name, not a number, not a row.
select invite_student(current_setting('test.class')::bigint, 'free@test.ca');
select t_ok('C4a an invitation is stored as invited, not active',
  (select status from enrolments
    where class_id = current_setting('test.class')::bigint
      and student_id = :free) = 'invited');
select t_ok('C4b teaches_student is false while only invited',
  not teaches_student(:free));
select t_ok('C4c the roster does not show an invited student',
  (select count(*) from class_roster(current_setting('test.class')::bigint)) = 0);
-- Note the shape: the dashboard functions return NOTHING rather than raising,
-- which is the same choice class_roster makes. An empty result and an error
-- are both safe, but only one of them is consistent, and the app already
-- treats a null overview as "not your student".
select t_ok('C4d student_detail returns no rows while only invited',
  (select count(*) from student_detail(:free)) = 0);
select t_ok('C4e student_overview returns null while only invited',
  student_overview(:free) is null);

-- C5  The student accepts, and access begins.
select set_config('test.uid', :free, false);
select t_ok('C5a the student can see who is asking, before deciding',
  (select count(*) from my_classes_as_student()
    where status = 'invited' and teacher_email = 'tutor@test.ca') = 1);
select respond_to_invitation(current_setting('test.class')::bigint, true);
select set_config('test.uid', :tutor, false);
select t_ok('C5b teaches_student is true once accepted', teaches_student(:free));
select t_ok('C5c the roster shows the student and their real first-try rate',
  (select count(*) from class_roster(current_setting('test.class')::bigint)) = 1);

-- C6  add_student_to_class is the other path, and it does NOT ask. That is
--     deliberate for a private tutor and is documented on the function; the
--     test exists so the behaviour cannot change by accident, in either
--     direction. It also settles the student's grade from the class.
select add_student_to_class(current_setting('test.class')::bigint, 'shy@test.ca');
select t_ok('C6a add_student_to_class enrols directly, without asking',
  (select status from enrolments
    where class_id = current_setting('test.class')::bigint
      and student_id = :shy) = 'active');
select t_ok('C6b ...and sets the student course from the class',
  (select course = 'MPM2D' and grade = 10
     from profiles where id = :shy));

-- C7  A second teacher cannot reach the first one's class. Ownership is
--     re-checked inside every function rather than trusted from the caller.
select set_config('test.uid', :other, false);
select t_ok('C7a another teacher gets nothing from the roster',
  (select count(*) from class_roster(current_setting('test.class')::bigint)) = 0);
select t_ok('C7b ...and teaches_student is false for them',
  not teaches_student(:free));
select t_ok('C7b2 ...and student_overview gives them nothing',
  student_overview(:free) is null and student_overview(:shy) is null);
select t_raises('C7c ...and they cannot invite into it',
  $q$ select invite_student(current_setting('test.class')::bigint,
                            'paid@test.ca') $q$);
select t_raises('C7d ...and they cannot rename or archive it',
  $q$ select archive_class(current_setting('test.class')::bigint) $q$);

-- C8  Leaving cuts access in the same second. This is the promise made to the
--     student on their front screen, so it is the one worth a test.
select set_config('test.uid', :free, false);
select leave_class(current_setting('test.class')::bigint);
select set_config('test.uid', :tutor, false);
select t_ok('C8a leaving cuts teacher access immediately',
  not teaches_student(:free));
select t_ok('C8b ...and drops them off the roster',
  (select count(*) from class_roster(current_setting('test.class')::bigint)) = 1);
select t_ok('C8c ...and empties student_detail again',
  (select count(*) from student_detail(:free)) = 0);
select t_ok('C8d ...and student_overview goes back to null',
  student_overview(:free) is null);

-- C9  One student cannot read another, at any point in the above.
select set_config('test.uid', :paid, false);
select t_ok('C9  a student reads only their own attempts',
  (select count(distinct student_id) from attempts) <= 1);

\echo ''
\echo '=========================================================='
\echo ' D — share links'
\echo '=========================================================='

select set_config('test.uid', :free, false);

-- D1  Asking twice gives the same link. A student who taps Share twice must
--     not quietly leave two live links behind.
do $$
declare a uuid; b uuid;
begin
  a := my_share_token();
  b := my_share_token();
  perform t_ok('D1  my_share_token is stable across calls', a = b);
  perform set_config('test.token', a::text, false);
end $$;

-- D2  The link works with no account at all — the token is the credential.
set role anon;
select t_ok('D2  an anonymous visitor can open a share link',
  shared_report(current_setting('test.token')::uuid) is not null);

-- D3  ...and carries a first name only. This is the child-privacy decision:
--     the URL is public and forwardable, so anything in the payload is
--     effectively published.
do $$
declare v jsonb;
begin
  v := shared_report(current_setting('test.token')::uuid);
  perform t_ok('D3a the payload carries a first name only',
    v ->> 'first_name' = 'Freya', v ->> 'first_name');
  perform t_ok('D3b no surname anywhere in the payload',
    position('Nolan-Baptiste' in v::text) = 0);
  perform t_ok('D3c no email address anywhere in the payload',
    position('@' in v::text) = 0);
  perform t_ok('D3d no class or teacher name anywhere in the payload',
    position('MPM2D Tuesday' in v::text) = 0
    and position('The Tutor' in v::text) = 0);
end $$;

-- D4  An unknown token returns null rather than raising, so a stranger
--     cannot tell a revoked link from one that never existed.
select t_ok('D4  an unknown token returns null, not an error',
  shared_report('00000000-0000-0000-0000-000000000000'::uuid) is null);

-- D5  Revoking is immediate, because the link may already be anywhere.
reset role;
set role authenticated;
select set_config('test.uid', :free, false);
select revoke_share();
set role anon;
select t_ok('D5  a revoked link stops working at once',
  shared_report(current_setting('test.token')::uuid) is null);

-- D6  Reissuing gives a working link and leaves the old one dead.
reset role;
set role authenticated;
select set_config('test.uid', :free, false);
do $$
declare v_new uuid;
begin
  v_new := revoke_and_reissue_share();
  perform set_config('test.token2', v_new::text, false);
  perform t_ok('D6a reissue returns a different token',
    v_new::text <> current_setting('test.token'));
end $$;
set role anon;
select t_ok('D6b the new link works',
  shared_report(current_setting('test.token2')::uuid) is not null);
select t_ok('D6c the old link is still dead',
  shared_report(current_setting('test.token')::uuid) is null);

-- D7  A student cannot fetch somebody else's report by id.
reset role;
set role authenticated;
select set_config('test.uid', :paid, false);
select t_raises('D7  report_payload is unreachable from a browser session',
  $q$ select report_payload('f1000000-0000-0000-0000-000000000001') $q$);

reset role;

\echo ''
\echo '=========================================================='
\echo ' E — the admin role, and paying by e-transfer'
\echo '=========================================================='

-- A fresh account for the admin, made admin the only way possible: as
-- service_role would, from outside any browser session.
insert into auth.users (id, email) values
  ('f6000000-0000-0000-0000-000000000006', 'admin@test.ca');
insert into profiles (id, email, full_name, grade, course) values
  ('f6000000-0000-0000-0000-000000000006', 'admin@test.ca', 'The Admin',
   12, 'MHF4U');
select grant_teacher_role('admin@test.ca', 'admin');

\set admin '''f6000000-0000-0000-0000-000000000006'''

set role authenticated;

-- E1  A student gets nothing from the admin surface. The list functions
--     return empty (the dashboard pattern), the write functions raise.
select set_config('test.uid', :free, false);
select t_ok('E1a a student reads zero rows from admin_list_students',
  (select count(*) from admin_list_students()) = 0);
select t_ok('E1b ...and zero from admin_list_etransfers',
  (select count(*) from admin_list_etransfers()) = 0);
select t_raises('E1c a student cannot make a teacher',
  $q$ select admin_make_teacher('free@test.ca') $q$);
select t_raises('E1d a student cannot confirm an e-transfer',
  $q$ select admin_confirm_etransfer(1) $q$);
select t_raises('E1e a student cannot assign anyone to a class',
  $q$ select admin_assign_student(
        current_setting('test.class')::bigint, 'paid@test.ca') $q$);

-- E2  The admin sees the operation whole.
select set_config('test.uid', :admin, false);
select t_ok('E2a admin is_admin, and is_teacher too',
  is_admin() and is_teacher());
select t_ok('E2b admin sees every student, and no staff among them',
  (select count(*) from admin_list_students()) = 3
  and not exists (select 1 from admin_list_students()
                  where email in ('tutor@test.ca', 'other@test.ca',
                                  'admin@test.ca')));
select t_ok('E2c admin sees both tutors',
  (select count(*) from admin_list_teachers() where role = 'teacher') = 2);
select t_ok('E2d admin sees classes they do not own',
  (select count(*) from admin_list_classes()) >= 1);

-- E3  Onboarding a tutor from the panel grants teacher and only teacher.
select t_ok('E3a admin makes a tutor of an existing account',
  admin_make_teacher('paid@test.ca') like 'Done.%');
-- Verification reads run as owner: staff_roles, enrolments and profiles are
-- rightly invisible to the admin through direct selects (RLS), and proving
-- the write happened means bypassing that, not weakening it.
reset role;
select t_ok('E3b ...and the grant is teacher, not admin',
  (select role from staff_roles where user_id = :paid) = 'teacher');
set role authenticated;
select set_config('test.uid', :admin, false);
select t_ok('E3c an unknown email is refused politely',
  admin_make_teacher('nobody@test.ca') like 'No account%');
select t_ok('E3d revoking a tutor works',
  admin_revoke_teacher(:paid) like 'Removed.%');
select t_ok('E3e revoking the admin from the browser is refused',
  admin_revoke_teacher(:admin) like 'Nothing removed.%');

-- E4  The matching: admin assigns a student into a tutor's class the admin
--     does not own, and the class settles the student's grade.
select t_ok('E4a admin assigns a student to another teacher''s class',
  admin_assign_student(current_setting('test.class')::bigint,
                       'paid@test.ca') = 'Added.');
reset role;
select t_ok('E4b ...enrolment is active',
  (select status from enrolments
    where class_id = current_setting('test.class')::bigint
      and student_id = :paid) = 'active');
select t_ok('E4c ...and the class set their course',
  (select course from profiles where id = :paid) = 'MPM2D');
set role authenticated;
select set_config('test.uid', :admin, false);
select t_ok('E4d admin_set_course returns Done',
  admin_set_course('paid@test.ca', 'MCR3U') = 'Done.');
reset role;
select t_ok('E4e ...and the course moved, taking the grade with it',
  (select course = 'MCR3U' and grade = 11 from profiles where id = :paid));
set role authenticated;
select set_config('test.uid', :admin, false);

-- E5  E-transfer: claiming grants nothing; confirming grants exactly the
--     period paid for. The paid student's Stripe period has lapsed (A9/A10
--     left them cancelled), so they are the honest test subject.
select set_config('test.uid', :shy, false);
select t_ok('E5a a student can declare an e-transfer',
  request_etransfer('monthly') like 'Noted.%');
select t_ok('E5b the claim alone unlocks nothing', not has_premium());
select t_ok('E5c a second claim while pending is refused politely',
  request_etransfer('annual') like 'You already have%');
select t_ok('E5d the student can see their claim is pending',
  (select status from my_etransfer_status()) = 'pending');

select set_config('test.uid', :admin, false);
select t_ok('E5e admin sees the pending claim first in the list',
  (select status from admin_list_etransfers() limit 1) = 'pending');
do $$
declare v_id bigint; v_msg text;
begin
  select claim_id into v_id from admin_list_etransfers()
   where status = 'pending' limit 1;
  v_msg := admin_confirm_etransfer(v_id);
  perform t_ok('E5f admin confirms the claim', v_msg like 'Confirmed.%', v_msg);
  perform t_ok('E5g confirming twice is refused',
    admin_confirm_etransfer(v_id) = 'That claim is not pending.');
end $$;

select set_config('test.uid', :shy, false);
select t_ok('E5h the student now has premium', has_premium());
select t_ok('E5i ...for about a month',
  (select current_period_end between now() + interval '27 days'
                                 and now() + interval '32 days'
     from subscriptions where student_id = :shy));

-- E6  Renewal extends from the period end, not from today — confirming an
--     annual early must never eat days already paid for.
select t_ok('E6a a renewal claim can be made while premium',
  request_etransfer('annual') like 'Noted.%');
select set_config('test.uid', :admin, false);
do $$
declare v_id bigint;
begin
  select claim_id into v_id from admin_list_etransfers()
   where status = 'pending' limit 1;
  perform admin_confirm_etransfer(v_id);
end $$;
-- The student reads their own subscription row; the admin rightly cannot.
select set_config('test.uid', :shy, false);
select t_ok('E6b the year stacks on top of the remaining month',
  (select current_period_end > now() + interval '12 months'
     from subscriptions where student_id = :shy));

-- E7  Rejection closes a claim without granting anything.
select set_config('test.uid', :free, false);
select request_etransfer('monthly');
select set_config('test.uid', :admin, false);
do $$
declare v_id bigint;
begin
  select claim_id into v_id from admin_list_etransfers()
   where status = 'pending' limit 1;
  perform t_ok('E7a admin can reject with a note',
    admin_reject_etransfer(v_id, 'No transfer arrived') = 'Rejected.');
end $$;
select set_config('test.uid', :free, false);
select t_ok('E7b the student sees rejected, and has no premium',
  (select status from my_etransfer_status()) = 'rejected'
  and not has_premium());

-- E8  One student cannot read another's claims through the table.
select t_ok('E8  claims are invisible across students',
  (select count(*) from etransfer_claims
    where student_id <> auth.uid()) = 0);

reset role;

\echo ''
\echo '=========================================================='
\echo ' F — regressions the security audit caught'
\echo '=========================================================='
-- Each of these was a real finding. The test exists so the fix cannot be
-- quietly undone by a later edit.

set role authenticated;

-- F1  The reporting views run as the invoker, so RLS applies. Before the
--     fix they ran as the owner and any student could read every student's
--     rows — and misconception_counts listed which options are wrong per
--     question, an answer-elimination oracle.
select set_config('test.uid', :paid, false);
select t_ok('F1a my_weekly_progress shows a student only their own rows',
  (select count(*) from my_weekly_progress
    where student_id <> auth.uid()) = 0);
select t_ok('F1b misconception_counts reflects only their own wrong taps',
  (select coalesce(sum(times_chosen), 0) from misconception_counts)
  = (select count(*) from attempts
      where student_id = auth.uid() and not was_correct));

-- F2  A student cannot move their own grade by PATCHing profiles — grade
--     belongs to the tutor. The name stays self-editable (same table, same
--     policy), which proves the guard is column-specific, not a lockout.
select set_config('test.uid', :free, false);
select t_raises('F2a a student cannot change their own course via the table',
  $q$ update profiles set course = 'MHF4U' where id = auth.uid() $q$);
do $$
begin
  update profiles set full_name = 'Freya N.' where id = auth.uid();
  perform t_ok('F2b ...but can still edit their own name', found);
end $$;

-- F3  create-checkout remembers a Stripe customer through
--     set_stripe_customer, which must not touch status or period end. The
--     old path wiped an e-transfer grant the moment the student opened the
--     Astro+ menu. shy@ holds a manual grant from block E.
reset role;
select set_stripe_customer(:shy, 'cus_new_from_checkout');
set role authenticated;
select set_config('test.uid', :shy, false);
select t_ok('F3a setting the Stripe customer preserves the manual grant',
  has_premium());
select t_ok('F3b ...the status and period end are untouched',
  (select status = 'manual' and current_period_end > now()
     from subscriptions where student_id = :shy));
select t_ok('F3c ...and the customer id was stored',
  (select stripe_customer_id = 'cus_new_from_checkout'
     from subscriptions where student_id = :shy));

-- F4  set_stripe_customer is service_role machinery, like the other
--     subscription writers.
select t_raises('F4  a student cannot call set_stripe_customer',
  $q$ select set_stripe_customer(auth.uid(), 'cus_forged') $q$);

-- F5  The grant surface itself. Both directions of this went wrong for real
--     during development, in the same afternoon, in opposite ways:
--
--     A hardening pass added `grant execute on all functions to
--     authenticated` — which re-opened grant_teacher_role and the Stripe
--     writers, whose entire protection is the missing grant. C1 caught it:
--     a student self-granted admin. Then the over-correction granted
--     authenticated nothing — and RLS policies call teaches_student AS THE
--     SIGNED-IN USER, so every roster in the app broke. C4b caught that.
--
--     These four checks pin the balance point so the next hardening pass
--     fails here, loudly, instead of in production.
select set_config('test.uid', :free, false);
select t_raises('F5a a student cannot even dial upsert_subscription',
  $q$ select upsert_subscription(auth.uid(), 'c', 's', 'active',
                                 now() + interval '30 days') $q$);
select t_ok('F5b a signed-in student can call the helpers RLS leans on',
  teaches_student(:paid) = false);

reset role;
set role anon;
select set_config('test.uid', '', false);
select t_raises('F5c anon cannot dial the app surface at all',
  $q$ select * from my_report() $q$);
select t_ok('F5d ...but the signup screen course list still answers',
  (select count(*) from list_courses()) > 0);
reset role;
set role authenticated;

reset role;

\echo ''
\echo '=========================================================='
\echo ' G — tutor review: subtopic diagnosis and feedback'
\echo '=========================================================='
-- The pro half of the product. A tutor sees not only how a student is
-- doing but WHAT THEY ARE AVOIDING, which is the thing a score-only
-- dashboard structurally cannot report: skipping a topic produces no data,
-- so the topic simply goes quiet.

-- The fixture is the habit itself. shy@ is enrolled in the tutor's class
-- (block C) and premium (block E), so all four levels are reachable.
reset role;
do $$
declare r record; n int := 0;
begin
  perform set_config('test.uid', 'f3000000-0000-0000-0000-000000000003', false);
  -- course was set to MPM2D by add_student_to_class in block C
  -- STRONG at elimination: every question, all first try
  for r in select sort_order, correct_index from questions
           where course_code = 'MPM2D' and unit = 'Linear systems'
             and misconception_tag = 'sub-elimination' loop
    perform submit_answer('MPM2D', 'Linear systems', r.sort_order, r.correct_index);
  end loop;
  -- SOLID at graphing: every question, occasional slip
  for r in select sort_order, correct_index from questions
           where course_code = 'MPM2D' and unit = 'Linear systems'
             and misconception_tag = 'sub-solving-by-graphing' loop
    n := n + 1;
    if n % 4 = 0 then
      perform submit_answer('MPM2D', 'Linear systems', r.sort_order,
                            (r.correct_index + 1) % 4);
    end if;
    perform submit_answer('MPM2D', 'Linear systems', r.sort_order, r.correct_index);
  end loop;
  -- STRUGGLING at substitution, and quietly stops after two
  for r in (select sort_order, correct_index from questions
            where course_code = 'MPM2D' and unit = 'Linear systems'
              and misconception_tag = 'sub-substitution'
            order by sort_order limit 2) loop
    perform submit_answer('MPM2D', 'Linear systems', r.sort_order,
                          (r.correct_index + 1) % 4);
    perform submit_answer('MPM2D', 'Linear systems', r.sort_order,
                          (r.correct_index + 2) % 4);
  end loop;
  -- applications: never opened
end $$;

set role authenticated;

-- G1  A student cannot read another student's diagnosis, and cannot read
--     their own through this door either — it is a teacher's view.
select set_config('test.uid', :paid, false);
select t_ok('G1  a student gets nothing from student_subtopics',
  (select count(*) from student_subtopics(:shy)) = 0);

-- G2  The tutor sees the whole subtopic map, including topics with no data.
select set_config('test.uid', :tutor, false);
select t_ok('G2a the tutor sees every subtopic in the grade, touched or not',
  (select count(*) from student_subtopics(:shy)) > 4);
select t_ok('G2b ...including one with zero attempts',
  (select count(*) from student_subtopics(:shy)
    where questions_seen = 0) >= 1);

-- G3  Strength is reported as strength.
select t_ok('G3  a fully-practised, all-first-try subtopic reads green',
  (select band = 'green' and coverage_pct = 100
     from student_subtopics(:shy)
    where tag = 'sub-elimination') );

-- G4  The point of the whole section: a topic that is both weak AND being
--     steered around is flagged, and a topic that is merely untouched in a
--     unit under way is flagged too.
select t_ok('G4a a struggled-then-abandoned subtopic is flagged as avoided',
  (select avoided and band = 'orange'
     from student_subtopics(:shy) where tag = 'sub-substitution'));
select t_ok('G4b a never-opened subtopic in a live unit is flagged too',
  (select avoided and questions_seen = 0
     from student_subtopics(:shy)
    where tag = 'sub-linear-applications'));
select t_ok('G4c a strong, fully-covered subtopic is NOT flagged',
  (select not avoided from student_subtopics(:shy)
    where tag = 'sub-elimination'));

-- G5  Ordering is the plan for the next session: weakest first.
select t_ok('G5  the weakest subtopic sorts to the top',
  (select tag from student_subtopics(:shy) limit 1) = 'sub-substitution');

-- G6  Feedback: written by the tutor, read by the student, nobody else.
do $$
declare v_id bigint;
begin
  v_id := write_tutor_note(
    'f3000000-0000-0000-0000-000000000003', 'sub-substitution',
    'You are picking the harder variable to isolate. Look for a '
    'coefficient of 1 first.');
  perform t_ok('G6a a tutor can write a note against a subtopic',
               v_id is not null);
end $$;
select t_ok('G6b ...and sees it on that student',
  (select count(*) from student_notes(:shy)) = 1);
select t_ok('G6c ...marked as theirs, and not yet read',
  (select mine and seen_at is null from student_notes(:shy) limit 1));

-- G7  A teacher who does not teach them cannot write to them.
select set_config('test.uid', :other, false);
select t_raises('G7a another teacher cannot write a note',
  $q$ select write_tutor_note(
        'f3000000-0000-0000-0000-000000000003', null, 'hello') $q$);
select t_ok('G7b ...and cannot read the notes',
  (select count(*) from student_notes(:shy)) = 0);
select t_ok('G7c ...nor the subtopic diagnosis',
  (select count(*) from student_subtopics(:shy)) = 0);

-- G8  The student reads it, and reading it is recorded.
select set_config('test.uid', :shy, false);
select t_ok('G8a the student sees the note',
  (select count(*) from my_tutor_notes()) = 1);
select t_ok('G8b ...with the topic label attached',
  (select label from my_tutor_notes() limit 1) = 'Solving by substitution');
select mark_notes_seen();
select t_ok('G8c ...and marking it read sticks',
  (select seen_at is not null from my_tutor_notes() limit 1));
select set_config('test.uid', :tutor, false);
select t_ok('G8d the tutor can now tell it was read',
  (select seen_at is not null from student_notes(:shy) limit 1));

-- G9  Another student cannot read it, by any door.
select set_config('test.uid', :paid, false);
select t_ok('G9a notes are invisible to other students',
  (select count(*) from tutor_notes where student_id <> auth.uid()) = 0);
select t_ok('G9b ...and my_tutor_notes only ever returns your own',
  (select count(*) from my_tutor_notes()) = 0);

-- G10 Only the author may delete.
select set_config('test.uid', :other, false);
select t_raises('G10a a different teacher cannot delete the note',
  $q$ select delete_tutor_note(
        (select id from tutor_notes limit 1)) $q$);
reset role;
set role authenticated;
select set_config('test.uid', :tutor, false);
do $$
declare v_id bigint;
begin
  select id into v_id from student_notes(
    'f3000000-0000-0000-0000-000000000003') limit 1;
  perform delete_tutor_note(v_id);
  perform t_ok('G10b the author can delete their own note',
    (select count(*) from student_notes(
       'f3000000-0000-0000-0000-000000000003')) = 0);
end $$;

reset role;

reset role;

\echo ''
\echo '=========================================================='
\echo ' H — the five functions that had no button until now'
\echo '=========================================================='
-- student_detail, class_unit_summary, archive_class, admin_remove_student
-- and set_student_course were all built, granted and covered by nothing.
-- The app now calls every one of them, so their guards are load-bearing and
-- belong under test.

set role authenticated;

-- H1  student_detail is the per-level drill-down behind the student report.
select set_config('test.uid', :tutor, false);
select t_ok('H1a a tutor reads the level detail of their own student',
  (select count(*) from student_detail(:shy)) > 0);
select t_ok('H1b it reports a level the student has actually worked',
  exists (select 1 from student_detail(:shy)
          where unit = 'Linear systems' and total > 0));

select set_config('test.uid', :other, false);
select t_ok('H1c a teacher who does not teach them gets nothing',
  (select count(*) from student_detail(:shy)) = 0);
select set_config('test.uid', :free, false);
select t_ok('H1d a student cannot read another student this way',
  (select count(*) from student_detail(:shy)) = 0);
select t_ok('H1e ...nor themselves; this is the tutor surface',
  (select count(*) from student_detail(:free)) = 0);

-- H2  class_unit_summary is completion, not score, for a whole class.
select set_config('test.uid', :tutor, false);
select t_ok('H2a a tutor summarises their own class',
  (select count(*) from
     class_unit_summary(current_setting('test.class')::bigint)) > 0);
select t_ok('H2b students_done never exceeds students_total',
  not exists (select 1 from
    class_unit_summary(current_setting('test.class')::bigint)
    where students_done > students_total));
select set_config('test.uid', :other, false);
select t_ok('H2c another teacher gets nothing from it',
  (select count(*) from
     class_unit_summary(current_setting('test.class')::bigint)) = 0);

-- H3  set_student_course. The tutor owns the course; the student does not.
select set_config('test.uid', :free, false);
select t_raises('H3a a student cannot move themselves to another course',
  $q$ select set_student_course(
        'f1000000-0000-0000-0000-000000000001', 'MTH1W') $q$);
select set_config('test.uid', :other, false);
select t_raises('H3b nor can a teacher who does not teach them',
  $q$ select set_student_course(
        'f3000000-0000-0000-0000-000000000003', 'MTH1W') $q$);
select set_config('test.uid', :tutor, false);
select t_raises('H3c and no course can be invented',
  $q$ select set_student_course(
        'f3000000-0000-0000-0000-000000000003', 'NOT-A-COURSE') $q$);

-- H4  admin_remove_student and the lookup that makes it reachable.
select set_config('test.uid', :free, false);
select t_raises('H4a a student cannot remove anybody from a class',
  $q$ select admin_remove_student(
        current_setting('test.class')::bigint,
        'f3000000-0000-0000-0000-000000000003') $q$);
select t_raises('H4b ...nor list which classes another student is in',
  $q$ select * from admin_student_classes(
        'f3000000-0000-0000-0000-000000000003') $q$);
select set_config('test.uid', :tutor, false);
select t_raises('H4c a teacher cannot either — this is the admin surface',
  $q$ select * from admin_student_classes(
        'f3000000-0000-0000-0000-000000000003') $q$);

select set_config('test.uid', :admin, false);
select t_ok('H4d an admin sees the classes a student is in, with ids',
  (select count(*) from admin_student_classes(:shy)) > 0);
select t_ok('H4e the class id it returns is the real one',
  exists (select 1 from admin_student_classes(:shy)
          where class_id = current_setting('test.class')::bigint));

-- The removal itself, and what survives it.
--
-- Block G deleted its own note on the way out (G10b), so a fresh one is
-- written here. Without it the survival checks below would be asserting
-- against an empty table, which is how the first version of H4h ended up
-- saying `count >= 0` and passing no matter what happened.
set role authenticated;
select set_config('test.uid', :tutor, false);
select write_tutor_note(:shy, 'sub-elimination',
  'Survives removal and archiving.') as note_for_the_survival_checks;

reset role;
select count(*) as attempts_before_removal from attempts
 where student_id = 'f3000000-0000-0000-0000-000000000003';
set role authenticated;
select set_config('test.uid', :admin, false);
select admin_remove_student(current_setting('test.class')::bigint, :shy);
reset role;
select t_ok('H4f the enrolment is marked removed, not deleted',
  (select status from enrolments
    where class_id = current_setting('test.class')::bigint
      and student_id = :shy) = 'removed');
select t_ok('H4g the student keeps every attempt',
  (select count(*) from attempts
    where student_id = 'f3000000-0000-0000-0000-000000000003') > 0);
-- >= 0 was the first version of this check, and it was worthless: a count is
-- always >= 0, so it passed whether the notes survived or were deleted. The
-- claim being tested is that removal ends a VIEW without destroying anything,
-- so the assertion has to be that the row is still there AND the student can
-- still read it.
select t_ok('H4h ...and the feedback written to them survives on disk',
  (select count(*) from tutor_notes
    where student_id = 'f3000000-0000-0000-0000-000000000003') > 0);
set role authenticated;
select set_config('test.uid', :shy, false);
select t_ok('H4i the student can still READ that feedback',
  (select count(*) from my_tutor_notes()) > 0);
select set_config('test.uid', :tutor, false);
select t_ok('H4j but the tutor immediately loses sight of them',
  (select count(*) from student_detail(:shy)) = 0);

-- H5  archive_class. Same shape: nothing destroyed, the view ends.
select set_config('test.uid', :other, false);
select t_raises('H5a a teacher cannot archive somebody elses class',
  $q$ select archive_class(current_setting('test.class')::bigint) $q$);
select set_config('test.uid', :tutor, false);
select archive_class(current_setting('test.class')::bigint);
select t_ok('H5b the class is stamped archived, not deleted',
  (select archived_at is not null from classes
    where id = current_setting('test.class')::bigint));
select t_ok('H5c it disappears from the teachers class list',
  not exists (select 1 from my_classes()
              where id = current_setting('test.class')::bigint));
reset role;
select t_ok('H5d the enrolment rows are still on disk',
  (select count(*) from enrolments
    where class_id = current_setting('test.class')::bigint) > 0);
select t_ok('H5e the tutor notes are still on disk',
  (select count(*) from tutor_notes
    where student_id = 'f3000000-0000-0000-0000-000000000003') > 0);
-- The one that matters to the student. Archiving is the tutor closing a
-- folder; it must not reach into the student's app and delete the feedback
-- they were given.
set role authenticated;
select set_config('test.uid', :shy, false);
select t_ok('H5f and the student can still read them after the archive',
  (select count(*) from my_tutor_notes()) > 0);
reset role;

reset role;


\echo ''
\echo '=========================================================='
\echo ' I — admin_teacher_students: the tutor-to-student edge'
\echo '=========================================================='
-- The admin panel could list tutors and could list students and had no edge
-- between them. This function is that edge, and it is the only place in the
-- codebase where one person's roster is handed to somebody who does not
-- teach them — so its guard is the whole safety story.
--
-- Block H archived the shared class, so this block builds its own from
-- scratch rather than reading whatever H left behind. A test that depends on
-- the block above it fails for the wrong reason later.

set role authenticated;

do $$
declare v_a bigint; v_b bigint;
begin
  perform set_config('test.uid', 'f4000000-0000-0000-0000-000000000004', false);
  select id into v_a from create_class('I-block Alpha', 'MPM2D');
  select id into v_b from create_class('I-block Beta',  'MPM2D');
  perform set_config('test.classA', v_a::text, false);
  perform set_config('test.classB', v_b::text, false);

  -- free: accepts both classes, and has practised (block A gave them
  --       attempts on Linear systems).
  -- paid: accepts Alpha only, has never answered anything.
  -- shy : INVITED to Alpha and never answers the invitation.
  perform invite_student(v_a, 'free@test.ca');
  perform invite_student(v_b, 'free@test.ca');
  perform invite_student(v_a, 'paid@test.ca');
  perform invite_student(v_a, 'shy@test.ca');

  perform set_config('test.uid', 'f1000000-0000-0000-0000-000000000001', false);
  perform respond_to_invitation(v_a, true);
  perform respond_to_invitation(v_b, true);
  perform set_config('test.uid', 'f2000000-0000-0000-0000-000000000002', false);
  perform respond_to_invitation(v_a, true);
end $$;

-- I1  Who may ask. Everything else in this block is meaningless if this is
--     not airtight: the answer is a named third party's whole roster.
select set_config('test.uid', :free, false);
select t_raises('I1a a student cannot read a tutors roster',
  $q$ select * from admin_teacher_students(
        'f4000000-0000-0000-0000-000000000004') $q$);
select set_config('test.uid', :tutor, false);
select t_raises('I1b nor can a tutor — not even about themselves',
  $q$ select * from admin_teacher_students(
        'f4000000-0000-0000-0000-000000000004') $q$);
select set_config('test.uid', :other, false);
select t_raises('I1c nor can another tutor about a colleague',
  $q$ select * from admin_teacher_students(
        'f4000000-0000-0000-0000-000000000004') $q$);
reset role;
set role anon;
select set_config('test.uid', '', false);
select t_raises('I1d nor can a signed-out browser',
  $q$ select * from admin_teacher_students(
        'f4000000-0000-0000-0000-000000000004') $q$);
reset role;
set role authenticated;

-- I2  What the admin actually gets.
select set_config('test.uid', :admin, false);
select t_ok('I2a an admin reads the roster',
  (select count(*) from admin_teacher_students(:tutor)) > 0);
select t_ok('I2b every row carries the class it belongs to',
  not exists (select 1 from admin_teacher_students(:tutor)
              where class_name is null or class_id is null));
select t_ok('I2c and the course, which is what the app groups on',
  not exists (select 1 from admin_teacher_students(:tutor)
              where coalesce(course, '') = ''));
select t_ok('I2d a name is always present, even with a blank profile',
  not exists (select 1 from admin_teacher_students(:tutor)
              where coalesce(trim(full_name), '') = ''));

-- I3  Consent survives the admin surface. An invitation is not a roster
--     entry anywhere else in this codebase, and it must not become one here
--     just because the person looking is an admin.
select t_ok('I3a an invited student who never accepted is absent',
  not exists (select 1 from admin_teacher_students(:tutor)
              where student_id = :shy));

-- I4  One student, two classes, two rows. The app groups by class, so this
--     is correct rather than duplicated — and the pair must differ by class.
select t_ok('I4a a student in two classes appears once per class',
  (select count(*) from admin_teacher_students(:tutor)
    where student_id = :free) = 2);
select t_ok('I4b ...and those two rows name different classes',
  (select count(distinct class_id) from admin_teacher_students(:tutor)
    where student_id = :free) = 2);

-- I5  The numbers. The one that matters is that a student who has never
--     answered gets NULL and not 0 — the app paints 0% orange, and calling
--     someone who has not started "struggling" is a lie the tutor acts on.
select t_ok('I5a a student who never answered has a NULL first-try rate',
  (select first_try_rate from admin_teacher_students(:tutor)
    where student_id = :paid limit 1) is null);
select t_ok('I5b ...and zero questions seen, and no last-active stamp',
  exists (select 1 from admin_teacher_students(:tutor)
          where student_id = :paid
            and questions_seen = 0 and last_active is null));
select t_ok('I5c a student who has practised reports a rate in 0..100',
  (select first_try_rate from admin_teacher_students(:tutor)
    where student_id = :free limit 1) between 0 and 100);
-- I5d  The count has to be checked against the raw table, and the raw table
--      has to be read AS THE OWNER. Reading it as the admin returns zero —
--      RLS on attempts admits nobody but the student themselves, admins
--      included — and a zero on both sides would have passed while proving
--      nothing. That near-miss is worth an assertion of its own, so I5f
--      pins the behaviour rather than leaving it as a footnote.
select t_ok('I5d0 an admins DB role cannot read attempts directly',
  (select count(*) from attempts where student_id = :free) = 0);
reset role;
select t_ok('I5d questions_seen matches the students own distinct questions',
  (select questions_seen from admin_teacher_students(:tutor)
    where student_id = :free limit 1)
  = (select count(distinct (unit, difficulty, sort_order))
       from attempts where student_id = :free));
select t_ok('I5f ...and that count is not zero, so I5d is not vacuous',
  (select count(distinct (unit, difficulty, sort_order))
     from attempts where student_id = :free) > 0);
set role authenticated;

-- I5e  The join fan-out bug that class_roster documents. If attempts and
--      unit_mastery were joined onto the student together, each would
--      multiply the other and questions_seen would inflate. Two classes
--      makes that visible: the same student's two rows must agree.
select t_ok('I5e the two rows for one student report identical statistics',
  (select count(distinct (questions_seen, first_try_rate, medals))
     from admin_teacher_students(:tutor) where student_id = :free) = 1);

-- I6  Quietest first, because that is what the screen is for.
select t_ok('I6a never-practised students sort above active ones',
  (select bool_and(ok) from (
     select (array_agg(student_id order by ord))[1] = :paid as ok
     from (select student_id, row_number() over () as ord
             from admin_teacher_students(:tutor)
            where class_id = current_setting('test.classA')::bigint) s
   ) t));

-- I7  Archiving ends this view too. Otherwise the admin panel would keep
--     showing a roster the tutor themselves can no longer reach.
select t_ok('I7a a live class is in the list before archiving',
  exists (select 1 from admin_teacher_students(:tutor)
          where class_id = current_setting('test.classB')::bigint));
set role authenticated;
select set_config('test.uid', :tutor, false);
select archive_class(current_setting('test.classB')::bigint);
select set_config('test.uid', :admin, false);
select t_ok('I7b and gone from it after',
  not exists (select 1 from admin_teacher_students(:tutor)
              where class_id = current_setting('test.classB')::bigint));
select t_ok('I7c while the other class is untouched',
  exists (select 1 from admin_teacher_students(:tutor)
          where class_id = current_setting('test.classA')::bigint));

-- I8  A teacher with nothing is an empty list, not an error. The admin
--     panel renders that as "no classes yet"; an exception would render as
--     a red box that looks like a fault.
select t_ok('I8a a tutor with no classes returns zero rows, quietly',
  (select count(*) from admin_teacher_students(:other)) = 0);
select t_ok('I8b so does a user id that is nobody',
  (select count(*) from admin_teacher_students(
     '00000000-0000-0000-0000-000000000000')) = 0);

reset role;

\echo ''
\echo '=========================================================='
\echo ' J — profile photos'
\echo '=========================================================='
-- The users are children, so the interesting assertions here are all about
-- who CANNOT see a face. The bytes themselves live in Supabase Storage and
-- are guarded by policies on storage.objects, which local Postgres has no
-- schema for — those are checked by hand against the live project. What IS
-- testable here is the pointer: who can set it, whose folder it may name,
-- and which surfaces carry it.

set role authenticated;

-- J1  The pointer must name your own folder. Without this a student could
--     aim their profile row at another student's photo and the app would
--     mint a signed URL for it quite happily — the storage policy guards the
--     bytes, and would never see this request at all.
select set_config('test.uid', :free, false);
select t_raises('J1a a student cannot point at another students folder',
  $q$ select set_my_avatar(
        'f3000000-0000-0000-0000-000000000003/avatar.jpg') $q$);
select t_raises('J1b nor at a bare filename with no folder',
  $q$ select set_my_avatar('avatar.jpg') $q$);
select t_raises('J1c nor at null',
  $q$ select set_my_avatar(null) $q$);
select t_raises('J1d nor at a folder that merely starts with their id',
  $q$ select set_my_avatar(
        'f1000000-0000-0000-0000-000000000001-evil/avatar.jpg') $q$);

-- J2  The happy path.
select t_ok('J2a a student sets their own photo',
  set_my_avatar('f1000000-0000-0000-0000-000000000001/avatar.jpg')
    = 'Photo saved.');
select t_ok('J2b and it lands on their profile row',
  (select avatar_path from profiles where id = :free)
    = 'f1000000-0000-0000-0000-000000000001/avatar.jpg');

-- J3  Their own row is the only one that moved.
select t_ok('J3a nobody elses profile was touched',
  (select count(*) from profiles
    where avatar_path is not null and id <> :free) = 0);

-- J4  The tutor who teaches them gets the path; the one who does not, does
--     not. Block I left :free enrolled in I-block Alpha, which :tutor owns.
select set_config('test.uid', :tutor, false);
select t_ok('J4a their own tutor sees the path on the roster',
  exists (select 1 from class_roster(current_setting('test.classA')::bigint)
          where student_id = :free and avatar_path is not null));
select set_config('test.uid', :other, false);
select t_ok('J4b a teacher who does not teach them sees no roster at all',
  (select count(*) from
     class_roster(current_setting('test.classA')::bigint)) = 0);

-- J5  The admin surfaces carry it too, which is what makes a face useful
--     for telling two students apart.
select set_config('test.uid', :admin, false);
select t_ok('J5a admin_list_students carries the path',
  exists (select 1 from admin_list_students()
          where student_id = :free and avatar_path is not null));
select t_ok('J5b so does the tutor drill-down',
  exists (select 1 from admin_teacher_students(:tutor)
          where student_id = :free and avatar_path is not null));

-- J6  THE ONE THAT MATTERS. A share link is a URL a fourteen-year-old sends
--     to a friend or posts in a group chat. It carries their progress on
--     purpose. It must never start carrying their face, and the way that
--     regresses is somebody adding avatar_path to report_payload for
--     convenience — so this asserts on the payload itself rather than on
--     the current column list.
select set_config('test.uid', :free, false);
do $$
declare v_token uuid; v_payload jsonb;
begin
  v_token := my_share_token();
  perform set_config('test.uid', '', false);
  v_payload := shared_report(v_token);
  perform t_ok('J6a a shared report carries no avatar path anywhere in it',
    position('avatar' in v_payload::text) = 0);
  perform t_ok('J6b ...and no storage path either',
    position('f1000000-0000-0000-0000-000000000001/' in v_payload::text) = 0);
  perform t_ok('J6c but it is still a real report, so J6a is not vacuous',
    jsonb_typeof(v_payload) = 'object' and v_payload ? 'units');
end $$;

-- J6d The bucket itself. Public would mean anyone holding the URL can fetch
--     a child's photo forever, and URLs leak.
reset role;
select t_ok('J6d the avatars bucket is private',
  (select not public from storage.buckets where id = 'avatars'));
set role authenticated;

-- ---------------------------------------------------------------------------
-- The storage policies
-- ---------------------------------------------------------------------------
-- These guard the BYTES, where everything above guards the pointer. The stub
-- in 00_supabase_stub.sql gives us storage.objects and foldername(), which is
-- all the policies actually reference — so the rules are testable here even
-- though nothing is uploading anything.
--
-- Rows are planted as the owner, then read back as each person in turn.
reset role;
insert into storage.objects (bucket_id, name) values
  ('avatars', 'f1000000-0000-0000-0000-000000000001/avatar.jpg'),
  ('avatars', 'f3000000-0000-0000-0000-000000000003/avatar.jpg')
on conflict do nothing;
set role authenticated;

select set_config('test.uid', :free, false);
select t_ok('J9a a student can see their own photo object',
  (select count(*) from storage.objects
    where name like :free || '/%') = 1);
select t_ok('J9b but not another students',
  (select count(*) from storage.objects
    where name like :shy || '/%') = 0);

select set_config('test.uid', :tutor, false);
select t_ok('J9c a tutor can see a photo of a student they teach',
  (select count(*) from storage.objects
    where name like :free || '/%') = 1);
select t_ok('J9d and not one of a student they do not',
  (select count(*) from storage.objects
    where name like :shy || '/%') = 0);

select set_config('test.uid', :other, false);
select t_ok('J9e an unrelated tutor sees no photos at all',
  (select count(*) from storage.objects where bucket_id = 'avatars') = 0);

select set_config('test.uid', :admin, false);
select t_ok('J9f the admin sees both',
  (select count(*) from storage.objects where bucket_id = 'avatars') = 2);

reset role; set role anon;
select set_config('test.uid', '', false);
select t_ok('J9g a signed-out browser sees none',
  (select count(*) from storage.objects where bucket_id = 'avatars') = 0);
reset role; set role authenticated;

-- Writes. The policy is a path rule, so the test is a path test.
select set_config('test.uid', :free, false);
select t_raises('J10a a student cannot write into another students folder',
  $q$ insert into storage.objects (bucket_id, name)
      values ('avatars',
              'f3000000-0000-0000-0000-000000000003/sneaky.jpg') $q$);
select t_raises('J10b nor rename their way into one',
  $q$ update storage.objects
         set name = 'f3000000-0000-0000-0000-000000000003/taken.jpg'
       where name like 'f1000000-0000-0000-0000-000000000001/%' $q$);
-- Delete is the one that does NOT raise, and the difference matters. An
-- insert that breaks WITH CHECK is an error; a delete that cannot see a row
-- simply removes nothing and reports success. So the assertion has to be
-- about what survived, not about what was thrown — checking for an exception
-- here would have failed while the policy was working perfectly.
delete from storage.objects
 where name = 'f3000000-0000-0000-0000-000000000003/avatar.jpg';
reset role;
select t_ok('J10c a delete aimed at somebody elses photo removes nothing',
  (select count(*) from storage.objects
    where name = 'f3000000-0000-0000-0000-000000000003/avatar.jpg') = 1);
set role authenticated;
select set_config('test.uid', :free, false);
select t_ok('J10d ...while their own is theirs to delete',
  (select count(*) from storage.objects
    where name like 'f1000000-0000-0000-0000-000000000001/%') = 1);

-- A folder name that is not a uuid must not blow up the read policy. Before
-- the CASE guard this raised 'invalid input syntax for type uuid' — and an
-- error inside a SELECT policy fails the whole query, so ONE bad object would
-- have made the bucket unreadable for every tutor at once.
reset role;
insert into storage.objects (bucket_id, name)
  values ('avatars', 'not-a-uuid/avatar.jpg') on conflict do nothing;
set role authenticated;
select set_config('test.uid', :tutor, false);
select t_ok('J11a a non-uuid folder does not break the read policy',
  (select count(*) from storage.objects
    where name like :free || '/%') = 1);
select t_ok('J11b and the odd object itself stays hidden',
  (select count(*) from storage.objects
    where name = 'not-a-uuid/avatar.jpg') = 0);

-- J7  Signed out, nothing.
reset role;
set role anon;
select set_config('test.uid', '', false);
select t_raises('J7a a signed-out browser cannot set a photo',
  $q$ select set_my_avatar('x/avatar.jpg') $q$);
select t_raises('J7b nor clear one',
  $q$ select clear_my_avatar() $q$);
reset role;
set role authenticated;

-- J8  Removing it.
select set_config('test.uid', :free, false);
select t_ok('J8a a student can remove their own photo',
  clear_my_avatar() = 'Photo removed.');
select t_ok('J8b and the row is null again, not an empty string',
  (select avatar_path from profiles where id = :free) is null);

reset role;
\echo ''
\echo '=========================================================='
\echo ' REVIEW — reported, not failed'
\echo '=========================================================='
\echo ''
\echo 'Feedback on a wrong option that states the correct answer. These are'
\echo 'authoring calls, not code, so they are listed rather than failed —'
\echo 'but every one of them hands a student the answer they were meant to'
\echo 'work out, which is the one thing the app exists not to do.'
\echo ''

-- Two ways feedback can give the game away, and two exemptions that stop
-- this list crying wolf.
--
-- The exemptions matter more than they look. Before them this check flagged
-- three questions that leak nothing at all:
--
--   Linear systems 35  "A father is three times as old as his son. In 12
--                       years..."  The answer is 12. Every sane hint about
--                       that question says "12 years", because the QUESTION
--                       says it.
--   Quadratics 23      Answer 2, and the vertex in the prompt is (3, -2).
--
-- A number the question already handed the student cannot be leaked back to
-- them, so arm 2 skips any answer text that appears in the prompt. It also
-- skips single-character answers, because "1" matches half the English
-- language and no wording of a hint can avoid it.
--
-- A warning that fires on things that are fine is worse than no warning:
-- it teaches you to scroll past the section.
select q.unit, q.sort_order, q.difficulty,
       q.options -> q.correct_index ->> 'text' as answer,
       t.elem ->> 'feedback' as leaking_feedback
from questions q,
  lateral jsonb_array_elements(q.options) with ordinality as t(elem, ord)
where t.ord - 1 <> q.correct_index
  and (
    -- Arm 1: the feedback announces the answer in words. No exemptions —
    -- there is no innocent reason to write this sentence on a distractor.
    t.elem ->> 'feedback' ~* ('(the (right|correct) answer is|it is actually'
                           || '|the answer would be|really equals|actually equals)')

    -- Arm 2: the feedback repeats the correct option verbatim.
    or (
      length(q.options -> q.correct_index ->> 'text') > 1
      and position(lower(q.options -> q.correct_index ->> 'text')
                   in lower(q.prompt)) = 0
      and t.elem ->> 'feedback' ~ ('(^|[^0-9A-Za-z.])'
          || regexp_replace(q.options -> q.correct_index ->> 'text',
                            '([.^$*+?()\[\]{}|\\-])', '\\\1', 'g')
          || '($|[^0-9A-Za-z.]|[.](?![0-9]))')
    )
  )
order by q.unit, q.sort_order;

\echo ''
\echo '=========================================================='
\echo ' Summary'
\echo '=========================================================='

select block,
       count(*) filter (where passed)     as passed,
       count(*) filter (where not passed) as failed
from test_results
group by block
order by block;

\echo ''
select label, coalesce(detail, '') as detail
from test_results where not passed order by id;

do $$
declare v_failed int;
begin
  select count(*) into v_failed from test_results where not passed;
  if v_failed > 0 then
    raise exception '% test(s) FAILED — see the list above', v_failed;
  end if;
  raise notice 'All % checks passed.',
    (select count(*) from test_results);
end $$;
