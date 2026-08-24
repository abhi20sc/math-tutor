-- Call every new RPC exactly as the Dart calls it: BY NAME, with the app's
-- own parameter names. A signature comparison would have missed nothing
-- here, but this is the check that actually matches what PostgREST does —
-- it resolves an RPC by named arguments, so a renamed parameter is a
-- "function does not exist" at runtime and invisible to flutter analyze.
\set ON_ERROR_STOP on
do $$
declare
  v_uid uuid; v_test bigint; v_lesson bigint; v_tag text; n int;
begin
  delete from practice_tests where true;
  delete from lesson_reads where true;
  delete from attempts where student_id in
    (select id from auth.users where email = 'rpc@example.test');
  delete from profiles where email = 'rpc@example.test';
  delete from auth.users where email = 'rpc@example.test';
  insert into auth.users (email) values ('rpc@example.test') returning id into v_uid;
  insert into profiles (id, email, full_name, grade, course)
    values (v_uid, 'rpc@example.test', 'RPC Tester', 10, 'MPM2D');
  insert into subscriptions (student_id, status) values (v_uid, 'manual')
    on conflict (student_id) do update set status = 'manual';
  perform set_config('test.uid', v_uid::text, false);

  perform ok('rpc list_lessons(p_course, p_unit)',
    (select count(*) from list_lessons(p_course => 'MPM2D', p_unit => 'Quadratics')) > 0);

  select id into v_lesson from list_lessons(p_course => 'MPM2D', p_unit => 'Quadratics') limit 1;

  perform ok('rpc lesson_body(p_id)',
    (select count(*) from lesson_body(p_id => v_lesson)) = 1);

  perform mark_lesson_read(p_id => v_lesson, p_seconds => 60);
  perform ok('rpc mark_lesson_read(p_id, p_seconds)',
    (select read_seconds from lesson_reads where lesson_id = v_lesson) = 60);

  -- Give the account something to be weak at, so improve_plan is non-empty.
  select misconception_tag into v_tag from questions
   where course_code='MPM2D' and unit='Quadratics' and misconception_tag is not null
   order by misconception_tag limit 1;
  insert into attempts (student_id, grade, course, unit, sort_order, difficulty,
                        chosen_index, was_correct, was_first_attempt, misconception_tag)
  select v_uid, 10, 'MPM2D', 'Quadratics', q.sort_order, q.difficulty,
         0, false, true, v_tag
  from questions q
  where q.course_code='MPM2D' and q.unit='Quadratics' and q.misconception_tag = v_tag;

  perform ok('rpc improve_plan(p_limit)',
    (select count(*) from improve_plan(p_limit => 6)) > 0);

  perform ok('rpc list_practice(p_tags, p_limit)',
    (select count(*) from list_practice(p_tags => array[v_tag], p_limit => 10)) > 0);

  select test_id into v_test from start_test(p_course => 'MPM2D', p_unit => 'Quadratics');
  perform ok('rpc start_test(p_course, p_unit)', v_test is not null);

  perform ok('rpc test_paper(p_test)',
    (select count(*) from test_paper(p_test => v_test)) = 15);

  -- THE BUG. Before the rename this raised
  --   function answer_test_item(p_test => bigint, p_item_no => integer, ...)
  --   does not exist
  -- which is exactly what a student would have hit on their first answer.
  perform answer_test_item(p_test => v_test, p_item_no => 1, p_chosen => 0);
  perform ok('rpc answer_test_item(p_test, p_item_no, p_chosen)',
    (select chosen_index from practice_test_items
      where test_id = v_test and item_no = 1) = 0);

  for n in 2..15 loop
    perform answer_test_item(p_test => v_test, p_item_no => n, p_chosen => 1);
  end loop;

  perform ok('rpc finish_test(p_test)',
    (select count(*) from finish_test(p_test => v_test)) = 1);
  perform ok('rpc test_result(p_test)',
    (select count(*) from test_result(p_test => v_test)) > 0);
  perform ok('rpc test_item_review(p_test)',
    (select count(*) from test_item_review(p_test => v_test)) = 15);

  select test_id into v_test from start_test(p_course => 'MPM2D', p_unit => 'Trigonometry');
  perform abandon_test(p_test => v_test);
  perform ok('rpc abandon_test(p_test)',
    (select abandoned from practice_tests where id = v_test));

  raise notice '';
  raise notice 'Every RPC resolved by the app''s own parameter names.';
end $$;
