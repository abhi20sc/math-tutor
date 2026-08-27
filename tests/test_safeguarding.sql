-- ===========================================================================
-- Tests for the age gate, guardian consent, export, deletion, rate limiting.
-- SCRATCH DATABASES ONLY — creates its own fixture users.
--   psql -d scratch -f tests/test_safeguarding.sql
--
-- Run on a database built from:
--   00_supabase_stub -> astro_math_assist_setup -> bundles/questions_all
--   -> astro_sections -> student_safeguarding
--
-- Every check raises NOTICE 'ok ...' or aborts the file with FAIL.
--
-- The point of this file is that every claim in student_safeguarding.sql is
-- either demonstrated here or is not a claim. A guard nobody has watched
-- refuse anything is a guard nobody knows works.
-- ===========================================================================
\set ON_ERROR_STOP on
\pset pager off

create or replace function sg_ok(p_name text, p_cond boolean)
returns void language plpgsql as $$
begin
  if p_cond then raise notice 'ok   %', p_name;
  else raise exception 'FAIL %', p_name; end if;
end $$;

-- Runs p_sql and reports whether it raised. Used for the refusals, which
-- are the whole point of a safeguard.
create or replace function sg_raises(p_name text, p_sql text)
returns void language plpgsql as $$
begin
  execute p_sql;
  raise exception 'FAIL % (expected an error, got none)', p_name;
exception
  when others then
    if sqlerrm like 'FAIL %' then raise; end if;
    raise notice 'ok   % (refused: %)', p_name, left(sqlerrm, 58);
end $$;

do $$
declare
  v_child  uuid;  -- 14, needs a guardian
  v_adult  uuid;  -- 19, does not
  v_legacy uuid;  -- no date of birth, predates the rule
  v_token  uuid;
  v_name   text;
  v_again  boolean;
  v_export jsonb;
  n int;
begin
  -- ---- fixtures -----------------------------------------------------------
  delete from auth.users where email in
    ('child@sg.test', 'adult@sg.test', 'legacy@sg.test');

  insert into auth.users (email) values ('child@sg.test')  returning id into v_child;
  insert into auth.users (email) values ('adult@sg.test')  returning id into v_adult;
  insert into auth.users (email) values ('legacy@sg.test') returning id into v_legacy;

  insert into profiles (id, email, full_name, grade, course) values
    (v_child,  'child@sg.test',  'Child Fixture',  10, 'MPM2D'),
    (v_adult,  'adult@sg.test',  'Adult Fixture',  12, 'MPM2D'),
    (v_legacy, 'legacy@sg.test', 'Legacy Fixture', 10, 'MPM2D');

  -- ---- A. the age gate ----------------------------------------------------
  perform set_config('test.uid', v_child::text, false);

  perform sg_raises('A1  under 13 is refused',
    format('select set_my_date_of_birth(%L)',
           (current_date - interval '11 years')::date));

  perform sg_raises('A2  a birth date in the future is refused',
    format('select set_my_date_of_birth(%L)',
           (current_date + interval '1 day')::date));

  perform sg_raises('A3  a null birth date is refused',
    'select set_my_date_of_birth(null)');

  perform set_my_date_of_birth((current_date - interval '14 years')::date);
  perform sg_ok('A4  a 14 year old is accepted',
    (select age_years(date_of_birth) from profiles where id = v_child) = 14);

  perform sg_raises('A5  and cannot then be changed by the student',
    format('select set_my_date_of_birth(%L)',
           (current_date - interval '19 years')::date));

  -- ---- B. who needs a guardian -------------------------------------------
  perform sg_ok('B1  a 14 year old needs one', consent_required(v_child));

  perform set_config('test.uid', v_adult::text, false);
  perform set_my_date_of_birth((current_date - interval '19 years')::date);
  perform sg_ok('B2  a 19 year old does not', not consent_required(v_adult));

  perform sg_ok('B3  an account with no birth date is not blocked',
    not consent_required(v_legacy));

  -- ---- C. nothing is recorded before consent ------------------------------
  -- The claim the whole file exists to make.
  perform sg_raises('C1  a minor without consent cannot record an attempt',
    format($q$insert into attempts
             (student_id, grade, course, unit, sort_order, difficulty,
              chosen_index, was_correct, was_first_attempt)
           values (%L, 10, 'MPM2D', 'Quadratics', 1, 'Easy', 0, true, true)$q$,
           v_child));

  perform sg_raises('C2  nor a lesson read',
    format($q$insert into lesson_reads (student_id, lesson_id)
             values (%L, 1)$q$, v_child));

  perform sg_ok('C3  and nothing of theirs was written',
    (select count(*) from attempts where student_id = v_child) = 0);

  -- An adult is unaffected, which is what proves the guard is scoped and
  -- not simply broken.
  insert into attempts
    (student_id, grade, course, unit, sort_order, difficulty,
     chosen_index, was_correct, was_first_attempt)
  values (v_adult, 12, 'MPM2D', 'Quadratics', 1, 'Easy', 0, true, true);
  perform sg_ok('C4  an adult is unaffected',
    (select count(*) from attempts where student_id = v_adult) = 1);

  -- ---- D. the guardian says yes -------------------------------------------
  perform set_config('test.uid', v_child::text, false);

  perform sg_raises('D1  a guardian address that is not one is refused',
    'select request_guardian_consent(''nope'')');

  select request_guardian_consent('parent@sg.test') into v_token;
  perform sg_ok('D2  requesting consent mints a token', v_token is not null);

  perform sg_raises('D3  an unknown token is refused',
    format('select * from guardian_consent_by_token(%L)', gen_random_uuid()));

  select student_name, already into v_name, v_again
    from guardian_consent_by_token(v_token);
  perform sg_ok('D4  the guardian sees who they are consenting for',
    v_name = 'Child Fixture');
  perform sg_ok('D5  and it is not already done', not v_again);
  perform sg_ok('D6  consent is recorded', not consent_required(v_child));

  select student_name, already into v_name, v_again
    from guardian_consent_by_token(v_token);
  perform sg_ok('D7  following the link twice is harmless', v_again);

  -- ---- E. and work is recorded from then on -------------------------------
  insert into attempts
    (student_id, grade, course, unit, sort_order, difficulty,
     chosen_index, was_correct, was_first_attempt)
  values (v_child, 10, 'MPM2D', 'Quadratics', 1, 'Easy', 0, true, true);
  perform sg_ok('E1  a consented minor can record work',
    (select count(*) from attempts where student_id = v_child) = 1);

  -- ---- F. withdrawal ------------------------------------------------------
  perform withdraw_guardian_consent(v_token);
  perform sg_ok('F1  withdrawing puts the account back to waiting',
    consent_required(v_child));
  perform sg_ok('F2  but destroys nothing already recorded',
    (select count(*) from attempts where student_id = v_child) = 1);
  perform sg_raises('F3  and stops new work being recorded',
    format($q$insert into attempts
             (student_id, grade, course, unit, sort_order, difficulty,
              chosen_index, was_correct, was_first_attempt)
           values (%L, 10, 'MPM2D', 'Quadratics', 2, 'Easy', 0, true, true)$q$,
           v_child));

  -- ---- G. export ----------------------------------------------------------
  perform set_config('test.uid', v_adult::text, false);
  select export_my_data() into v_export;
  perform sg_ok('G1  the export carries the profile',
    v_export -> 'profile' ->> 'email' = 'adult@sg.test');
  perform sg_ok('G2  and the attempts',
    jsonb_array_length(v_export -> 'attempts') = 1);
  perform sg_ok('G3  and never the consent token, which is a credential',
    not (v_export -> 'profile' ? 'guardian_consent_token'));
  perform sg_ok('G4  and says what it deliberately leaves out',
    jsonb_array_length(v_export -> 'not_included') > 0);

  -- ---- H. rate limiting ---------------------------------------------------
  delete from rate_limit_hits where bucket = 'sg-test';
  perform sg_ok('H1  the first hit is allowed',
    note_rate_limit('sg-test', 2, '1 hour'));
  perform sg_ok('H2  so is the second',
    note_rate_limit('sg-test', 2, '1 hour'));
  perform sg_ok('H3  the third is not',
    not note_rate_limit('sg-test', 2, '1 hour'));
  perform sg_ok('H4  a different bucket is counted separately',
    note_rate_limit('sg-test-other', 2, '1 hour'));
  perform sg_raises('H5  an empty bucket name is refused',
    'select note_rate_limit('''', 2, ''1 hour'')');
  perform sg_ok('H6  purging clears old windows',
    purge_rate_limits('0 seconds') > 0);

  -- ---- I. deletion --------------------------------------------------------
  perform set_config('test.uid', v_adult::text, false);
  perform delete_my_account();
  perform sg_ok('I1  the auth user is gone',
    not exists (select 1 from auth.users where id = v_adult));
  perform sg_ok('I2  the profile went with it',
    not exists (select 1 from profiles where id = v_adult));
  perform sg_ok('I3  and so did every attempt — no soft delete',
    (select count(*) from attempts where student_id = v_adult) = 0);

  -- ---- J. the grants that are the protection ------------------------------
  perform sg_ok('J1  anon cannot set a date of birth',
    not has_function_privilege('anon', 'set_my_date_of_birth(date)', 'execute'));
  perform sg_ok('J2  anon cannot export anybody''s data',
    not has_function_privilege('anon', 'export_my_data()', 'execute'));
  perform sg_ok('J3  anon cannot delete an account',
    not has_function_privilege('anon', 'delete_my_account()', 'execute'));
  perform sg_ok('J4  but a signed-out guardian CAN follow their link',
    has_function_privilege('anon', 'guardian_consent_by_token(uuid)', 'execute'));
  perform sg_ok('J5  and a signed-out browser can be rate limited',
    has_function_privilege('anon', 'note_rate_limit(text,int,interval)', 'execute'));

  -- ---- tidy ---------------------------------------------------------------
  delete from auth.users where email in ('child@sg.test', 'legacy@sg.test');
  delete from rate_limit_hits where bucket like 'sg-test%';

  raise notice '';
  raise notice 'Safeguarding checks passed.';
end $$;
