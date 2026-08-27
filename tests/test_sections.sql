-- ===========================================================================
-- Tests for Learn / Improve / Test / Percentages / Enrolment.
-- SCRATCH DATABASES ONLY — creates its own fixture users.
--   psql -d scratch -f tests/test_sections.sql
--
-- RUN THIS *AFTER* tests/test_ama.sql, OR ON A DIFFERENT DATABASE.
-- Both suites create their own fixture accounts and neither clears the
-- other's, so running this one first leaves rows that make one of
-- test_ama's counts come out high. Nothing is wrong with either suite; they
-- simply are not designed to share a database in that order.
-- Every check raises NOTICE 'ok ...' or aborts the file with FAIL.
-- ===========================================================================
\set ON_ERROR_STOP on
\pset pager off

create or replace function ok(p_name text, p_cond boolean)
returns void language plpgsql as $$
begin
  if p_cond then raise notice 'ok   %', p_name;
  else raise exception 'FAIL %', p_name; end if;
end $$;

do $$
declare
  v_free uuid; v_paid uuid;
  v_t1 bigint; v_t2 bigint; v_total int; v_warm boolean;
  v_score int; v_correct int; v_easy int;
  v_bad text; v_good text; v_tag text;
  v_id bigint; v_e1 bigint; v_e2 bigint; v_tok uuid;
  r record; v_ci int; n int;
begin
  -- ---- fixtures -----------------------------------------------------------
  delete from enrolment_requests where true;
  delete from practice_tests    where true;
  delete from lesson_reads      where true;
  delete from attempts where student_id in
    (select id from auth.users where email like 'sec-%@example.test');
  delete from profiles where email like 'sec-%@example.test';
  delete from auth.users where email like 'sec-%@example.test';

  insert into auth.users (email) values ('sec-free@example.test') returning id into v_free;
  insert into auth.users (email) values ('sec-paid@example.test') returning id into v_paid;
  insert into profiles (id, email, full_name, grade, course) values
    (v_free, 'sec-free@example.test', 'Free Student', 10, 'MPM2D'),
    (v_paid, 'sec-paid@example.test', 'Jithu Pradeep', 10, 'MPM2D');
  insert into subscriptions (student_id, status) values (v_paid, 'manual')
    on conflict (student_id) do update set status = 'manual';

  insert into lessons (course_code, unit, tag, sort_order, title, summary,
                       read_minutes, body, video_title, video_url, video_source)
  select 'MPM2D', 'Quadratics', t.tag, row_number() over (order by t.tag),
         'Lesson on ' || misconception_label(t.tag), 'A two-minute read.', 2,
         '# Heading' || E'\n\nBody for ' || t.tag,
         'Video', 'https://example.test/v', 'JensenMath'
  from (select distinct misconception_tag as tag from questions
        where course_code='MPM2D' and unit='Quadratics'
          and misconception_tag is not null) t
  on conflict do nothing;

  -- =========================================================================
  -- LEARN
  -- =========================================================================
  perform set_config('test.uid', v_paid::text, false);

  perform ok('L1  list_lessons returns the unit''s lessons',
             (select count(*) from list_lessons('MPM2D','Quadratics')) > 0);
  perform ok('L2  every lesson starts unread',
             (select bool_and(read_at is null) from list_lessons('MPM2D','Quadratics')));
  perform ok('L3  the list never ships lesson bodies',
             not exists (select 1 from information_schema.columns
                         where table_name='list_lessons' and column_name='body'));

  select id into v_id from list_lessons('MPM2D','Quadratics') order by sort_order limit 1;
  perform mark_lesson_read(v_id, 95);
  perform mark_lesson_read(v_id, 40);

  perform ok('L4  reading is recorded and seconds accumulate',
             (select read_seconds from list_lessons('MPM2D','Quadratics')
              where id = v_id) = 135);
  perform mark_lesson_read(v_id, 99999);
  perform ok('L5  a tab left open all afternoon is clamped',
             (select read_seconds from lesson_reads where lesson_id = v_id) = 1335);
  perform ok('L6  lesson_body returns the markdown',
             (select body from lesson_body(v_id)) like '#%');
  perform ok('L7  units_with_lessons counts what has been read',
             (select read_count from units_with_lessons('MPM2D')
              where unit='Quadratics') = 1);

  -- =========================================================================
  -- IMPROVE
  -- =========================================================================
  select misconception_tag into v_bad from questions
   where course_code='MPM2D' and unit='Quadratics' and misconception_tag is not null
   order by misconception_tag limit 1;
  select misconception_tag into v_good from questions
   where course_code='MPM2D' and unit='Quadratics' and misconception_tag is not null
     and misconception_tag <> v_bad order by misconception_tag limit 1;

  for r in select sort_order, difficulty, grade, misconception_tag as tg
           from questions
           where course_code='MPM2D' and unit='Quadratics'
             and misconception_tag in (v_bad, v_good) loop
    insert into attempts (student_id, grade, course, unit, sort_order, difficulty,
                          chosen_index, was_correct, was_first_attempt,
                          misconception_tag)
    values (v_paid, r.grade, 'MPM2D', 'Quadratics', r.sort_order, r.difficulty,
            0, r.tg = v_good, true,
            case when r.tg = v_good then null else v_bad end);
  end loop;

  -- A second clean first look at the strong subtopic. Two is the threshold
  -- list_practice uses for "this one is learned, stop drilling it", and a
  -- second first look is exactly what finishing the level a second time
  -- produces in the real app.
  for r in select sort_order, difficulty, grade from questions
           where course_code='MPM2D' and unit='Quadratics'
             and misconception_tag = v_good loop
    insert into attempts (student_id, grade, course, unit, sort_order, difficulty,
                          chosen_index, was_correct, was_first_attempt,
                          misconception_tag)
    values (v_paid, r.grade, 'MPM2D', 'Quadratics', r.sort_order, r.difficulty,
            0, true, true, null);
  end loop;

  perform ok('I1  my_subtopics covers the whole bank, not just what was seen',
             (select count(*) from my_subtopics()) >=
             (select count(distinct (unit, misconception_tag)) from questions
              where course_code='MPM2D' and misconception_tag is not null));
  perform ok('I2  an all-wrong subtopic bands orange',
             (select band from my_subtopics() where tag = v_bad) = 'orange');
  perform ok('I3  an all-right subtopic bands green',
             (select band from my_subtopics() where tag = v_good) = 'green');
  perform ok('I4  the weak subtopic tops the improve plan',
             (select tag from improve_plan(6) limit 1) = v_bad);
  perform ok('I5  the plan links the lesson that covers it',
             (select lesson_id from improve_plan(6) limit 1) is not null);
  perform ok('I6  the strong subtopic is NOT in the plan',
             not exists (select 1 from improve_plan(20) where tag = v_good));
  perform ok('I7  list_practice returns questions for that tag',
             (select count(*) from list_practice(array[v_bad], 10)) > 0);
  perform ok('I8  list_practice ships option text and nothing else',
             (select bool_and(ks = array['text'])
              from (select array(select jsonb_object_keys(opt) order by 1) as ks
                    from list_practice(array[v_bad], 5) p,
                         lateral jsonb_array_elements(p.options) opt) z));
  perform ok('I9  a question answered right twice is not drilled again',
             not exists (select 1 from list_practice(array[v_good], 30)));

  perform set_config('test.uid', v_free::text, false);
  perform ok('I10 a free account gets no locked question in a drill',
             not exists (select 1 from list_practice(
               (select array_agg(distinct misconception_tag) from questions
                where course_code='MPM2D' and misconception_tag is not null), 30)
               where difficulty in ('Challenge','Advanced')));
  perform set_config('test.uid', v_paid::text, false);
  perform ok('I11 a paid account does get them',
             exists (select 1 from list_practice(
               (select array_agg(distinct misconception_tag) from questions
                where course_code='MPM2D' and misconception_tag is not null), 30)
               where difficulty in ('Challenge','Advanced')));

  -- =========================================================================
  -- TEST
  -- =========================================================================
  select test_id, total, is_warmup into v_t1, v_total, v_warm
    from start_test('MPM2D','Quadratics');

  perform ok('T1  a paid paper is fifteen questions', v_total = 15);
  perform ok('T2  and is not a warm-up', not v_warm);
  perform ok('T3  it spans all four difficulty bands',
             (select count(distinct difficulty) from test_paper(v_t1)) = 4);
  perform ok('T4  every subtopic in the unit appears on it',
             (select count(distinct tag) from practice_test_items where test_id = v_t1)
             = (select count(distinct misconception_tag) from questions
                where course_code='MPM2D' and unit='Quadratics'
                  and misconception_tag is not null));
  perform ok('T5  it is ordered Easy first, the way a real test ramps',
             (select difficulty from test_paper(v_t1) order by item_no limit 1) = 'Easy');
  perform ok('T6  the paper never ships an answer',
             not exists (select 1 from information_schema.columns
                         where table_name='test_paper'
                           and column_name in ('correct_index','feedback','was_correct')));
  perform ok('T7  starting again resumes the same paper',
             (select test_id from start_test('MPM2D','Quadratics')) = v_t1);
  perform ok('T8  practice_test_items has RLS on and no policy at all',
             (select relrowsecurity from pg_class where relname='practice_test_items')
             and not exists (select 1 from pg_policies
                             where tablename='practice_test_items'));

  -- Answer it: right on Easy, wrong everywhere else.
  for r in select i.item_no, i.unit, i.sort_order, i.difficulty
           from practice_test_items i where i.test_id = v_t1 order by i.item_no loop
    select q.correct_index into v_ci from questions q
     where q.course_code='MPM2D' and q.unit=r.unit
       and q.sort_order=r.sort_order and q.difficulty=r.difficulty;
    perform answer_test_item(v_t1, r.item_no,
      case when r.difficulty='Easy' then v_ci else (v_ci + 1) % 4 end);
  end loop;

  perform ok('T9  answering reveals nothing before the paper is closed',
             (select count(*) from information_schema.parameters
              where specific_name like 'answer_test_item%'
                and parameter_mode = 'OUT') = 0);

  select count(*) into v_easy from practice_test_items
   where test_id = v_t1 and difficulty = 'Easy';
  select score_pct, correct into v_score, v_correct from finish_test(v_t1);

  perform ok('T10 the score is correct over total',
             v_score = round(100.0 * v_correct / v_total)::int);
  perform ok('T11 exactly the Easy answers scored', v_correct = v_easy);
  perform ok('T12 finishing writes one attempt per answered item',
             (select count(*) from attempts
              where student_id = v_paid and not was_first_attempt) = v_total);
  perform ok('T13 test answers are never first looks, so bands stay clean',
             (select count(*) from attempts
              where student_id = v_paid and was_first_attempt
                and answered_at > now() - interval '2 minutes') > 0
             and (select count(distinct was_first_attempt) from attempts
                  where student_id = v_paid) = 2);
  perform ok('T14 a wrong test answer still carries its misconception tag',
             exists (select 1 from attempts where student_id = v_paid
                     and not was_first_attempt and not was_correct
                     and misconception_tag is not null));
  perform ok('T15 the result breaks down by subtopic',
             (select count(*) from test_result(v_t1)) > 1);
  perform ok('T16 review shows feedback only where the answer was wrong',
             (select bool_and((was_correct and feedback is null)
                           or ((not was_correct) and feedback is not null))
              from test_item_review(v_t1)));
  perform finish_test(v_t1);
  perform ok('T17 finishing twice does not double-count the attempts',
             (select count(*) from attempts
              where student_id = v_paid and not was_first_attempt) = v_total);

  perform set_config('test.uid', v_free::text, false);
  select test_id, total, is_warmup into v_t2, v_total, v_warm
    from start_test('MPM2D','Quadratics');
  perform ok('W1  a free paper is ten questions', v_total = 10);
  perform ok('W2  and is flagged a warm-up rather than passed off', v_warm);
  perform ok('W3  it contains nothing locked',
             not exists (select 1 from test_paper(v_t2)
                         where difficulty in ('Challenge','Advanced')));
  -- Not "returns no rows" — refuses outright. A student poking at test ids
  -- learns nothing from the difference between "empty" and "not yours",
  -- because they get the same error either way.
  begin
    perform count(*) from test_paper(v_t1);
    perform ok('W4  one student cannot open another student''s paper', false);
  exception when others then
    perform ok('W4  one student cannot open another student''s paper', true);
  end;

  -- =========================================================================
  -- PERCENTAGES
  -- =========================================================================
  perform set_config('test.uid', v_paid::text, false);
  perform ok('P1  a unit percentage appears once a test is finished',
             (select unit_pct from my_unit_percentages() where unit='Quadratics')
             is not null);
  perform ok('P2  an untouched unit shows NO percentage, never a zero',
             (select count(*) from my_unit_percentages()
              where unit <> 'Quadratics' and unit_pct is not null) = 0);
  perform ok('P3  a subtopic percentage is a real score',
             (select subtopic_pct from my_percentages()
              where unit='Quadratics' and subtopic_pct is not null limit 1)
             between 0 and 100);
  perform ok('P4  the unit average counts untouched subtopics as zero',
             (select unit_pct from my_unit_percentages() where unit='Quadratics')
             <= (select round(avg(subtopic_pct))::int from my_percentages()
                 where unit='Quadratics' and subtopic_pct is not null));

  -- =========================================================================
  -- ENROLMENT
  -- =========================================================================
  select request_id into v_e1 from request_enrolment(
    'Jithu Pradeep', 10, 'Toronto DSB', 'A Parent', 'parent@example.test',
    'annual', 'stripe', 'Northview SS', '416-555-0100');
  perform ok('E1  the request is recorded',
             (select status from my_enrolment_status()) = 'new');
  perform ok('E2  the payment token never reaches the student',
             not exists (select 1 from information_schema.columns
                         where table_name in ('request_enrolment','my_enrolment_status')
                           and column_name = 'pay_token'));

  select request_id into v_e2 from request_enrolment(
    'Jithu Pradeep', 10, 'Toronto DSB', 'A Parent', 'parent@example.test',
    'monthly', 'etransfer');
  perform ok('E3  resubmitting replaces, so no parent gets two live links',
             (select count(*) from enrolment_requests
              where student_id = v_paid and status in ('new','sent')) = 1);

  select pay_token into v_tok from enrolment_requests where id = v_e2;
  perform ok('E4  the parent''s link resolves to a first name and a plan',
             (select student_first from enrolment_by_token(v_tok)) = 'Jithu');
  perform ok('E5  and exposes no contact details or school',
             not exists (select 1 from information_schema.columns
                         where table_name='enrolment_by_token'
                           and column_name in ('parent_email','parent_phone','school')));
  perform cancel_enrolment();
  perform ok('E6  a cancelled request stops resolving',
             not exists (select 1 from enrolment_by_token(v_tok)));

  begin
    perform request_enrolment('X', 10, 'B', 'P', 'not-an-email',
                              'annual', 'stripe');
    perform ok('E7  a bad parent email is refused', false);
  exception when others then
    perform ok('E7  a bad parent email is refused', true);
  end;

  begin
    perform request_enrolment('X', 13, 'B', 'P', 'p@e.test', 'annual', 'stripe');
    perform ok('E8  a grade outside 9-12 is refused', false);
  exception when others then
    perform ok('E8  a grade outside 9-12 is refused', true);
  end;

  perform ok('E9  none of this creates a new route to premium',
             has_premium() = exists (select 1 from subscriptions
                                     where student_id = v_paid
                                       and status in ('active','trialing','manual')));

  -- =========================================================================
  -- GRANTS — the property the whole security model rests on
  -- =========================================================================
  select count(*) into n from pg_proc p
   join pg_namespace ns on ns.oid = p.pronamespace
   where ns.nspname='public'
     and p.proname in ('list_lessons','lesson_body','mark_lesson_read',
                       'lesson_for_tag','units_with_lessons',
                       'my_subtopics','improve_plan','list_practice',
                       'start_test','test_paper','answer_test_item',
                       'finish_test','test_result','test_item_review',
                       'abandon_test','request_enrolment','my_enrolment_status',
                       'cancel_enrolment','admin_list_enrolments',
                       'admin_mark_enrolment','my_percentages',
                       'my_unit_percentages')
     and has_function_privilege('anon', p.oid, 'EXECUTE');
  perform ok('G1  nothing new is callable by anon', n = 0);
  perform ok('G2  except the parent payment link, by design',
             has_function_privilege('anon', 'enrolment_by_token(uuid)', 'EXECUTE'));
  perform ok('G3  the five dangerous functions are still ungranted',
             (select count(*) from pg_proc p
              join pg_namespace ns on ns.oid = p.pronamespace
              where ns.nspname='public'
                and p.proname in ('grant_teacher_role','report_payload',
                                  'upsert_subscription','update_subscription_by_sid',
                                  'set_stripe_customer')
                and (has_function_privilege('authenticated', p.oid, 'EXECUTE')
                  or has_function_privilege('anon', p.oid, 'EXECUTE'))) = 0);

  raise notice '';
  raise notice 'All section tests passed.';
end $$;


-- ===========================================================================
-- DEPTH: the source column, the review, and the paper history.
-- ===========================================================================
do $$
declare
  v_uid uuid; v_test bigint; r record; v_ci int; n int; v_secs int;
begin
  delete from practice_tests where true;
  delete from attempts where student_id in
    (select id from auth.users where email='depth@example.test');
  delete from profiles where email='depth@example.test';
  delete from auth.users where email='depth@example.test';
  insert into auth.users (email) values ('depth@example.test') returning id into v_uid;
  insert into profiles (id,email,full_name,grade,course)
    values (v_uid,'depth@example.test','Depth',10,'MPM2D');
  insert into subscriptions (student_id,status) values (v_uid,'manual')
    on conflict (student_id) do update set status='manual';
  perform set_config('test.uid', v_uid::text, false);

  select test_id into v_test from start_test('MPM2D','Quadratics');
  for r in select i.item_no, i.unit, i.sort_order, i.difficulty
           from practice_test_items i where i.test_id=v_test order by i.item_no loop
    select q.correct_index into v_ci from questions q
      where q.course_code='MPM2D' and q.unit=r.unit
        and q.sort_order=r.sort_order and q.difficulty=r.difficulty;
    perform answer_test_item(v_test, r.item_no,
      case when r.difficulty='Easy' then v_ci else (v_ci+1)%4 end);
  end loop;
  select seconds into v_secs from finish_test(v_test);

  perform ok('D1  finish_test reports how long the paper took', v_secs >= 0);
  perform ok('D2  every attempt the test wrote is stamped source = test',
    (select count(*) from attempts where student_id=v_uid and source='test') =
    (select count(*) from attempts where student_id=v_uid));
  perform ok('D3  and none of them is a first look, so bands stay clean',
    not exists (select 1 from attempts
                where student_id=v_uid and was_first_attempt));

  -- The regression this column exists to stop.
  perform ok('D4  the quiz solved-set, excluding test rows, is empty',
    (select count(*) from attempts
      where student_id=v_uid and was_correct
        and coalesce(source,'quiz') <> 'test') = 0);
  perform ok('D5  while the diagnosis still sees every one of them',
    (select count(*) from attempts where student_id=v_uid and was_correct) > 0);

  perform ok('D6  review carries the difficulty, so a result reads by band too',
    (select count(distinct difficulty) from test_item_review(v_test)) = 4);
  -- D7 used to assert the opposite: that review never printed the answer.
  -- It does now, on a finished paper only, and the reasoning is in
  -- ../supabase/migrations/test_review_answers.sql. What replaced it is the
  -- line that actually has to hold — the answer appears only AFTER the
  -- paper is closed, and never while it is live. T6 and T9 above pin the
  -- live half; these three pin the rest.
  perform ok('D7a review returns the answer once the paper is finished',
    (select bool_and(correct_index between 0 and 3)
     from test_item_review(v_test)));
  perform ok('D7b review returns all four options, with their feedback',
    (select bool_and(jsonb_array_length(options) = 4
                 and options -> correct_index ->> 'text' is not null)
     from test_item_review(v_test)));
  perform ok('D7c a live paper still reveals nothing',
    (select count(*) from information_schema.columns
      where table_name='test_paper'
        and column_name in ('correct_index','feedback')) = 0);
  perform ok('D8  feedback appears only where the answer was wrong',
    (select bool_and((was_correct and feedback is null)
                  or ((not was_correct) and feedback is not null))
     from test_item_review(v_test)));

  perform ok('D9  the paper appears in this unit''s history',
    (select count(*) from unit_test_history('MPM2D','Quadratics')) = 1);
  perform ok('D10 an abandoned paper never appears in it',
    (select count(*) from (
       select abandon_test((select test_id from start_test('MPM2D','Trigonometry')))) z) = 1
    and (select count(*) from unit_test_history('MPM2D','Trigonometry')) = 0);
  perform ok('D11 history is scoped to the signed-in student',
    (select count(*) from unit_test_history('MPM2D','Quadratics')
      where test_id not in (select id from practice_tests where student_id=v_uid)) = 0);

  -- D12 is the one that closes the answer-farming route. Without it a
  -- student could finish an untouched paper purely to read fifteen answers
  -- out of a unit they are about to practise. Sit a paper, answer exactly
  -- one item of it, and the review must show exactly that one.
  declare
    v_farm bigint;
    v_rows int;
  begin
    select test_id into v_farm from start_test('MPM2D','Factoring');
    perform answer_test_item(v_farm, 1, 0);
    perform finish_test(v_farm);

    select count(*) into v_rows from test_item_review(v_farm);
    perform ok('D12 review shows only the items that were answered',
      v_rows = 1);
    perform ok('D13 and the paper itself is still the full fifteen',
      (select total from practice_tests where id = v_farm) = 15);
  end;

  raise notice '';
  raise notice 'Depth checks passed.';
end $$;
