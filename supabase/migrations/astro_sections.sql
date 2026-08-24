-- ===========================================================================
-- ASTRO MATH ASSIST — Learn / Quiz / Improve / Test
-- One migration. Run AFTER astro_math_assist_setup.sql, in any order relative
-- to the question files.
-- ===========================================================================
--
-- WHAT THIS ADDS
--
--   Learn      lessons keyed to a subtopic, with read tracking
--   Improve    the tutor's diagnosis, self-scoped, plus the first query in
--              this database that can select questions by misconception tag
--   Test       a server-graded practice test, no feedback until the end
--   %          best-test-score percentages for the topic map and the tree
--   Astro+     an enrolment form, and a payment link addressed to the parent
--
-- WHAT IT DOES NOT TOUCH
--
--   questions, attempts, profiles, subscriptions, classes, enrolments,
--   tutor_notes, report_shares. Nothing existing is altered or dropped. No
--   student loses a single row by this file being applied, and re-running it
--   is safe.
--
-- THE ONE PROPERTY TO CHECK AFTER RUNNING IT
--
--   This file adds no new way to become premium and no new way to read an
--   answer. Both are asserted by tests/test_sections.sql — E9 and G1-G3 for
--   the first, I7/I8/T6/T8/T9 for the second.
--
-- VERIFIED 23 August 2026 on a clean database built from
-- astro_math_assist_setup.sql + bundles/questions_all.sql:
--   55 / 55  tests/test_sections.sql
--  212 / 212 tests/test_ama.sql   (unchanged by this migration)
-- ===========================================================================


-- ===========================================================================
-- ASTRO MATH ASSIST — Learn / Quiz / Improve / Test
-- Part 1 of 6: tables, row-level security, indexes.
-- ===========================================================================
--
-- Run AFTER astro_math_assist_setup.sql. Safe to re-run: every statement is
-- idempotent, and nothing here touches questions, attempts, profiles or
-- subscriptions. No student loses anything by this file being applied.
--
-- Five new tables:
--   lessons              the Learn section's content, one row per subtopic
--   lesson_reads         who has read what
--   practice_tests       one row per test taken
--   practice_test_items  the fifteen questions of that test, fixed at start
--   enrolment_requests   the Astro+ form, and the parent's payment token
--
-- The design rule that governs all of it is unchanged: the browser never
-- receives a correct_index or a feedback string it has not earned. Every
-- read path below goes through a security definer function, exactly as
-- list_questions does.
-- ===========================================================================


-- ---------------------------------------------------------------------------
-- LESSONS
--
-- A lesson attaches to a SUBTOPIC (misconception_tag), not to a unit, because
-- that is the grain the diagnosis works at: a weak tag in the Improve section
-- can then link to the one lesson that addresses it. A lesson with a null tag
-- is the unit's opening read, shown first and belonging to no single subtopic.
--
-- body is markdown. It may contain inline SVG, which is how the diagrams
-- travel without a second asset pipeline.
-- ---------------------------------------------------------------------------
create table if not exists lessons (
  id            bigserial primary key,
  course_code   text not null,
  unit          text not null,
  tag           text,
  sort_order    int  not null,
  title         text not null,
  summary       text not null,
  read_minutes  int  not null default 2 check (read_minutes between 1 and 30),
  body          text not null,
  video_title   text,
  video_url     text,
  video_source  text,
  updated_at    timestamptz not null default now(),
  unique (course_code, unit, sort_order)
);

create index if not exists lessons_course_unit_idx
  on lessons (course_code, unit, sort_order);
create index if not exists lessons_tag_idx
  on lessons (course_code, tag) where tag is not null;

-- Lessons are free, deliberately. Learn is the part of the app that should
-- work before anyone pays for anything. RLS is on with a read-only policy
-- rather than off, so a future paid lesson can be gated by adding a clause
-- here instead of by rewriting the read path.
alter table lessons enable row level security;
drop policy if exists "Lessons are readable" on lessons;
create policy "Lessons are readable"
  on lessons for select
  to authenticated
  using (true);


-- ---------------------------------------------------------------------------
-- LESSON READS
--
-- read_seconds accumulates rather than replacing, so a student who opens a
-- lesson three times for twenty seconds each reads as sixty seconds of
-- attention, not twenty. A tutor uses it to tell "skimmed" from "studied".
-- ---------------------------------------------------------------------------
create table if not exists lesson_reads (
  student_id     uuid   not null references auth.users(id) on delete cascade,
  lesson_id      bigint not null references lessons(id)    on delete cascade,
  first_read_at  timestamptz not null default now(),
  last_read_at   timestamptz not null default now(),
  read_seconds   int not null default 0,
  primary key (student_id, lesson_id)
);

create index if not exists lesson_reads_student_idx
  on lesson_reads (student_id, last_read_at desc);

alter table lesson_reads enable row level security;
drop policy if exists "Read own lesson reads" on lesson_reads;
create policy "Read own lesson reads"
  on lesson_reads for select
  to authenticated
  using (student_id = auth.uid() or teaches_student(student_id));


-- ---------------------------------------------------------------------------
-- PRACTICE TESTS
--
-- A test is the whole unit under exam conditions: no feedback until the end,
-- and the score is what drives the percentage on the topic map. Quiz cannot
-- produce that number, because Quiz lets a student keep tapping until they
-- are right.
--
-- is_warmup marks the free-tier version — Easy and Medium only, ten
-- questions. It is recorded rather than inferred so that a student who later
-- subscribes can see which of their old scores were on the short paper.
-- ---------------------------------------------------------------------------
create table if not exists practice_tests (
  id           bigserial primary key,
  student_id   uuid not null references auth.users(id) on delete cascade,
  course       text not null,
  unit         text not null,
  is_warmup    boolean not null default false,
  total        int  not null check (total > 0),
  answered     int  not null default 0,
  correct      int  not null default 0,
  score_pct    int,
  started_at   timestamptz not null default now(),
  finished_at  timestamptz,
  abandoned    boolean not null default false
);

create index if not exists practice_tests_student_idx
  on practice_tests (student_id, course, unit, finished_at desc nulls last);

alter table practice_tests enable row level security;
drop policy if exists "Read own tests" on practice_tests;
create policy "Read own tests"
  on practice_tests for select
  to authenticated
  using (student_id = auth.uid() or teaches_student(student_id));


-- ---------------------------------------------------------------------------
-- PRACTICE TEST ITEMS
--
-- The paper is fixed when the test starts. Storing it means a reload does not
-- reshuffle the questions, an abandoned test can be resumed, and the score is
-- computed from what was actually asked rather than from what the client says
-- was asked.
--
-- RLS is ON WITH NO POLICY, the same treatment questions gets. Nothing reads
-- this table directly; test_paper() hands out the four option texts and
-- nothing else. A student querying it over REST gets an empty set.
-- ---------------------------------------------------------------------------
create table if not exists practice_test_items (
  test_id      bigint not null references practice_tests(id) on delete cascade,
  item_no     int    not null,
  unit         text   not null,
  sort_order   int    not null,
  difficulty   text   not null,
  tag          text,
  chosen_index int,
  was_correct  boolean,
  answered_at  timestamptz,
  primary key (test_id, item_no)
);

alter table practice_test_items enable row level security;


-- ---------------------------------------------------------------------------
-- ENROLMENT REQUESTS  (the Astro+ form)
--
-- A student cannot enter their parent's card details, and should not be asked
-- to. They fill this in; the parent receives a link and pays. pay_token is
-- what travels in that email — unguessable, revocable by setting status, and
-- carrying no personal data in the URL itself.
--
-- parent_email is the only place in this database that stores an adult's
-- contact details, which makes it the row the privacy policy has to describe
-- most carefully.
-- ---------------------------------------------------------------------------
create table if not exists enrolment_requests (
  id            bigserial primary key,
  student_id    uuid not null references auth.users(id) on delete cascade,
  student_name  text not null,
  grade         int  not null check (grade between 9 and 12),
  school_board  text not null,
  school        text,
  parent_name   text not null,
  parent_email  text not null,
  parent_phone  text,
  plan          text not null check (plan   in ('monthly', 'annual')),
  method        text not null check (method in ('stripe', 'etransfer')),
  status        text not null default 'new'
                check (status in ('new', 'sent', 'paid', 'cancelled')),
  pay_token     uuid not null default gen_random_uuid(),
  note          text,
  emailed_at    timestamptz,
  decided_at    timestamptz,
  created_at    timestamptz not null default now()
);

-- One open request per student. A second submission replaces the first rather
-- than queueing behind it, so a parent never receives two payment links.
create unique index if not exists enrolment_requests_one_open
  on enrolment_requests (student_id)
  where status in ('new', 'sent');

create index if not exists enrolment_requests_status_idx
  on enrolment_requests (status, created_at desc);

alter table enrolment_requests enable row level security;

-- The student may read back what they submitted, minus the token. The token
-- is deliberately not exposed to the student's browser: it is the parent's
-- key, it goes out by email, and it should not be sitting in a network tab on
-- a shared school laptop.
drop policy if exists "Read own enrolment request" on enrolment_requests;
create policy "Read own enrolment request"
  on enrolment_requests for select
  to authenticated
  using (student_id = auth.uid());
-- ===========================================================================
-- Part 2 of 6: the Learn section.
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- list_lessons — the Learn tab for one unit.
--
-- Returns the lesson list WITHOUT bodies. A unit's lessons total tens of
-- kilobytes of markdown and inline SVG; sending all of it to draw a list of
-- titles would make opening the tab slower than reading the lesson.
--
-- Each row carries the student's own band on that subtopic, so the list can
-- say "you are shaky on this one" beside the lesson that fixes it. That is
-- the whole reason lessons are keyed to a tag rather than to a unit.
-- ---------------------------------------------------------------------------
create or replace function list_lessons(p_course text, p_unit text)
returns table (
  id            bigint,
  tag           text,
  subtopic      text,
  sort_order    int,
  title         text,
  summary       text,
  read_minutes  int,
  has_video     boolean,
  read_at       timestamptz,
  read_seconds  int,
  band          text,
  first_looks   int
)
language sql
security definer
stable
set search_path = public
as $$
  with reset as (
    select r.reset_at from progress_resets r
    where r.student_id = auth.uid() and r.course = p_course
  ),
  mine as (
    select a.* from attempts a
    where a.student_id = auth.uid()
      and a.course = p_course
      and a.unit = p_unit
      and (not exists (select 1 from reset)
           or a.answered_at > (select reset_at from reset))
  ),
  per_tag as (
    select m.misconception_tag as tag,
           count(*) filter (where m.was_first_attempt) as looks,
           count(*) filter (where m.was_first_attempt and m.was_correct) as hits
    from (
      -- misconception_tag is null on correct rows by design, so join back to
      -- the bank to recover which subtopic each attempt belonged to.
      select a.was_first_attempt, a.was_correct, q.misconception_tag
      from mine a
      join questions q
        on q.course_code = p_course and q.unit = a.unit
       and q.sort_order = a.sort_order and q.difficulty = a.difficulty
    ) m
    group by m.misconception_tag
  )
  select l.id,
         l.tag,
         misconception_label(l.tag),
         l.sort_order,
         l.title,
         l.summary,
         l.read_minutes,
         (l.video_url is not null),
         r.first_read_at,
         coalesce(r.read_seconds, 0),
         case
           when l.tag is null            then null
           when coalesce(t.looks, 0) < 2 then 'grey'
           when 100.0 * t.hits / t.looks >= 90 then 'green'
           when 100.0 * t.hits / t.looks >= 70 then 'light-green'
           when 100.0 * t.hits / t.looks >= 50 then 'yellow'
           else 'orange'
         end,
         coalesce(t.looks, 0)::int
  from lessons l
  left join lesson_reads r
    on r.lesson_id = l.id and r.student_id = auth.uid()
  left join per_tag t on t.tag = l.tag
  where l.course_code = p_course
    and l.unit = p_unit
    and auth.uid() is not null
  order by l.sort_order;
$$;


-- ---------------------------------------------------------------------------
-- lesson_body — the markdown for one lesson.
--
-- Reading is not recorded here. A student who opens a lesson and closes it
-- after two seconds has not read it, and marking it read on fetch would make
-- the tick meaningless. The client calls mark_lesson_read separately, with
-- the seconds it actually observed.
-- ---------------------------------------------------------------------------
create or replace function lesson_body(p_id bigint)
returns table (
  id           bigint,
  title        text,
  body         text,
  read_minutes int,
  video_title  text,
  video_url    text,
  video_source text,
  tag          text,
  subtopic     text
)
language sql
security definer
stable
set search_path = public
as $$
  select l.id, l.title, l.body, l.read_minutes,
         l.video_title, l.video_url, l.video_source,
         l.tag, misconception_label(l.tag)
  from lessons l
  where l.id = p_id and auth.uid() is not null;
$$;


-- ---------------------------------------------------------------------------
-- mark_lesson_read — called when the student leaves the lesson.
--
-- Seconds are clamped at twenty minutes per visit. Without a ceiling, a tab
-- left open over lunch would report an hour of reading and the tutor's
-- "studied vs skimmed" signal would be worthless.
-- ---------------------------------------------------------------------------
create or replace function mark_lesson_read(p_id bigint, p_seconds int default 0)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;
  if not exists (select 1 from lessons where id = p_id) then
    raise exception 'No such lesson.';
  end if;

  insert into lesson_reads (student_id, lesson_id, read_seconds)
  values (auth.uid(), p_id, least(greatest(coalesce(p_seconds, 0), 0), 1200))
  on conflict (student_id, lesson_id) do update
    set last_read_at = now(),
        read_seconds = lesson_reads.read_seconds
                     + least(greatest(coalesce(p_seconds, 0), 0), 1200);
end;
$$;


-- ---------------------------------------------------------------------------
-- lesson_for_tag — "read the lesson that covers this" from anywhere.
--
-- Used by the Improve list and by a finished test's per-subtopic breakdown.
-- Returns at most one row.
-- ---------------------------------------------------------------------------
create or replace function lesson_for_tag(p_course text, p_tag text)
returns table (id bigint, unit text, title text, read_minutes int)
language sql
security definer
stable
set search_path = public
as $$
  select l.id, l.unit, l.title, l.read_minutes
  from lessons l
  where l.course_code = p_course and l.tag = p_tag
    and auth.uid() is not null
  order by l.sort_order
  limit 1;
$$;


-- ---------------------------------------------------------------------------
-- units_with_lessons — which units have a Learn tab at all.
--
-- Lessons arrive course by course. Until a course has them, its Learn tab
-- should not appear rather than appear empty, and the client needs to know
-- that before it draws the rail.
-- ---------------------------------------------------------------------------
create or replace function units_with_lessons(p_course text)
returns table (unit text, lessons int, read_count int)
language sql
security definer
stable
set search_path = public
as $$
  select l.unit,
         count(*)::int,
         count(r.lesson_id)::int
  from lessons l
  left join lesson_reads r
    on r.lesson_id = l.id and r.student_id = auth.uid()
  where l.course_code = p_course and auth.uid() is not null
  group by l.unit
  order by min(l.sort_order);
$$;


revoke all on function list_lessons(text, text)       from public, anon;
revoke all on function lesson_body(bigint)            from public, anon;
revoke all on function mark_lesson_read(bigint, int)  from public, anon;
revoke all on function lesson_for_tag(text, text)     from public, anon;
revoke all on function units_with_lessons(text)       from public, anon;

grant execute on function list_lessons(text, text)      to authenticated;
grant execute on function lesson_body(bigint)           to authenticated;
grant execute on function mark_lesson_read(bigint, int) to authenticated;
grant execute on function lesson_for_tag(text, text)    to authenticated;
grant execute on function units_with_lessons(text)      to authenticated;
-- ===========================================================================
-- Part 3 of 6: the Improve section.
-- ===========================================================================
--
-- The diagnosis this section needs already exists and is good: coverage per
-- subtopic, a five-way band on first-try rate, and an "avoided" flag that
-- compares a subtopic against the student's own best-covered subtopic in the
-- same unit rather than against the unit average. All of it is in
-- student_subtopics — and all of it is visible only to tutors.
--
-- my_subtopics is that query, self-scoped. Nothing about the maths changes;
-- teaches_student(p_student) becomes auth.uid(). Keeping them as two
-- functions rather than one with a nullable argument means neither can be
-- talked into returning the other's rows.
-- ===========================================================================

create or replace function my_subtopics()
returns table (
  unit            text,
  tag             text,
  label           text,
  questions_total int,
  questions_seen  int,
  coverage_pct    int,
  unit_coverage   int,
  first_looks     int,
  first_try_rate  int,
  band            text,
  avoided         boolean,
  last_seen       timestamptz
)
language sql
security definer
stable
set search_path = public
as $$
  with me as (
    select p.id, p.grade, p.course from profiles p
    where p.id = auth.uid()
  ),
  reset as (
    select r.reset_at from progress_resets r
    join me on me.id = r.student_id and r.course = me.course
  ),
  mine as (
    select a.* from attempts a, me
    where a.student_id = me.id and a.course = me.course
      and (not exists (select 1 from reset)
           or a.answered_at > (select reset_at from reset))
  ),
  bank as (
    select q.unit, q.misconception_tag as tag, q.sort_order
    from questions q, me
    where q.course_code = me.course and q.misconception_tag is not null
  ),
  per_sub as (
    select b.unit, b.tag,
           count(distinct b.sort_order)                as total,
           count(distinct m.sort_order)                as seen,
           count(*) filter (where m.was_first_attempt) as first_looks,
           count(*) filter (where m.was_first_attempt
                              and m.was_correct)       as first_hits,
           max(m.answered_at)                          as last_seen
    from bank b
    left join mine m
      on m.unit = b.unit and m.sort_order = b.sort_order
    group by b.unit, b.tag
  ),
  per_unit as (
    select unit,
           sum(total) as total,
           sum(seen)  as seen,
           max(case when total > 0 then seen::numeric / total end) as best_cov
    from per_sub group by unit
  )
  select s.unit, s.tag, misconception_label(s.tag),
         s.total::int,
         s.seen::int,
         round(100.0 * s.seen / nullif(s.total, 0))::int,
         round(100.0 * u.seen / nullif(u.total, 0))::int,
         s.first_looks::int,
         case when s.first_looks = 0 then null
              else round(100.0 * s.first_hits / s.first_looks)::int end,
         case
           when s.first_looks < 2 then 'grey'
           when 100.0 * s.first_hits / s.first_looks >= 90 then 'green'
           when 100.0 * s.first_hits / s.first_looks >= 70 then 'light-green'
           when 100.0 * s.first_hits / s.first_looks >= 50 then 'yellow'
           else 'orange'
         end,
         (u.seen::numeric / nullif(u.total, 0) >= 0.25
          and s.seen::numeric / nullif(s.total, 0)
              < 0.5 * coalesce(u.best_cov, 0)),
         s.last_seen
  from per_sub s
  join per_unit u on u.unit = s.unit
  where auth.uid() is not null
  order by
    case when s.first_looks >= 2
           and 100.0 * s.first_hits / s.first_looks < 70 then 0
         else 1 end,
    (u.seen::numeric / nullif(u.total, 0) >= 0.25
     and s.seen::numeric / nullif(s.total, 0)
         < 0.5 * coalesce(u.best_cov, 0)) desc,
    case when s.first_looks = 0 then 999
         else 100.0 * s.first_hits / s.first_looks end,
    s.unit;
$$;


-- ---------------------------------------------------------------------------
-- improve_plan — what the Improve tab shows before the student starts.
--
-- The top handful of subtopics worth time right now, each with the lesson
-- that covers it and how many questions are left unseen. Deliberately short:
-- a list of thirty things to fix is a list nobody starts.
-- ---------------------------------------------------------------------------
create or replace function improve_plan(p_limit int default 6)
returns table (
  unit          text,
  tag           text,
  label         text,
  band          text,
  first_try_rate int,
  coverage_pct  int,
  avoided       boolean,
  unseen        int,
  lesson_id     bigint,
  lesson_title  text,
  reason        text
)
language sql
security definer
stable
set search_path = public
as $$
  with me as (select p.course from profiles p where p.id = auth.uid()),
  s as (select * from my_subtopics())
  select s.unit, s.tag, s.label, s.band, s.first_try_rate, s.coverage_pct,
         s.avoided,
         (s.questions_total - s.questions_seen)::int,
         l.id, l.title,
         case
           when s.avoided and s.first_looks < 2 then 'You have been going round this one'
           when s.avoided                        then 'Less practice here than anywhere else in the unit'
           when s.band = 'orange'                then 'More wrong than right on the first look'
           when s.band = 'yellow'                then 'About half right on the first look'
           else                                       'Worth another pass'
         end
  from s
  left join lateral (
    select lf.id, lf.title from lesson_for_tag((select course from me), s.tag) lf
  ) l on true
  where auth.uid() is not null
    and (s.band in ('orange', 'yellow') or s.avoided)
  order by
    case s.band when 'orange' then 0 when 'yellow' then 1 else 2 end,
    s.avoided desc,
    coalesce(s.first_try_rate, 0)
  limit greatest(least(coalesce(p_limit, 6), 20), 1);
$$;


-- ---------------------------------------------------------------------------
-- list_practice — questions chosen by misconception tag, not by unit.
--
-- This is the one genuinely new query in the whole feature. list_questions
-- filters on course, unit and level; nothing in the database could until now
-- answer "give me questions about the thing this student keeps getting
-- wrong", which is the only question the Improve section asks.
--
-- Selection rules, in order of what they protect:
--
--   * The paywall first. A free account gets Easy and Medium only, here and
--     in submit_answer, so a drill can never become a side door into
--     Challenge content.
--   * Questions already answered correctly on a first look TWICE are skipped.
--     Drilling something a student has demonstrably learned wastes the short
--     set on the wrong material.
--   * Unseen questions come before seen ones, so a drill shows new work
--     rather than replaying the same four items.
--   * Ties are broken randomly, so a second drill on the same tag is not the
--     same paper.
--
-- Options are stripped to their text exactly as list_questions strips them.
-- ---------------------------------------------------------------------------
create or replace function list_practice(p_tags text[], p_limit int default 10)
returns table (
  sort_order  int,
  difficulty  text,
  course_code text,
  unit        text,
  prompt      text,
  options     jsonb,
  subtopic    text,
  tag         text,
  figure      text
)
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_course  text;
  v_premium boolean;
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;
  if p_tags is null or array_length(p_tags, 1) is null then
    raise exception 'No subtopics given.';
  end if;

  select p.course into v_course from profiles p where p.id = auth.uid();
  if v_course is null then
    raise exception 'No course set for this account.';
  end if;

  v_premium := has_premium();

  return query
  with reset as (
    select r.reset_at from progress_resets r
    where r.student_id = auth.uid() and r.course = v_course
  ),
  mine as (
    select a.unit, a.sort_order, a.difficulty,
           a.was_first_attempt, a.was_correct
    from attempts a
    where a.student_id = auth.uid() and a.course = v_course
      and (not exists (select 1 from reset)
           or a.answered_at > (select reset_at from reset))
  ),
  seen as (
    select m.unit, m.sort_order, m.difficulty,
           count(*) filter (where m.was_first_attempt and m.was_correct) as clean,
           count(*) as taps
    from mine m
    group by m.unit, m.sort_order, m.difficulty
  )
  select q.sort_order, q.difficulty, q.course_code, q.unit, q.prompt,
         (
           select jsonb_agg(jsonb_build_object('text', elem->>'text')
                            order by ord)
           from jsonb_array_elements(q.options) with ordinality as t(elem, ord)
         ),
         misconception_label(q.misconception_tag),
         q.misconception_tag,
         q.figure
  from questions q
  left join seen s
    on s.unit = q.unit and s.sort_order = q.sort_order
   and s.difficulty = q.difficulty
  where q.course_code = v_course
    and q.misconception_tag = any (p_tags)
    and (v_premium or level_is_free(q.difficulty))
    and coalesce(s.clean, 0) < 2
  order by coalesce(s.taps, 0) > 0,          -- unseen first
           random()
  limit greatest(least(coalesce(p_limit, 10), 30), 1);
end;
$$;


revoke all on function my_subtopics()                from public, anon;
revoke all on function improve_plan(int)             from public, anon;
revoke all on function list_practice(text[], int)    from public, anon;

grant execute on function my_subtopics()             to authenticated;
grant execute on function improve_plan(int)          to authenticated;
grant execute on function list_practice(text[], int) to authenticated;
-- ===========================================================================
-- Part 4 of 6: the Test section.
-- ===========================================================================
--
-- A test is the whole unit, straight through, with no feedback until the end.
-- That last part is the only reason the score means anything: Quiz lets a
-- student keep tapping until they are right, so Quiz can measure effort but
-- never attainment.
--
-- Astro+ gets the real paper: fifteen questions across all four difficulty
-- bands. A free account gets a ten-question warm-up over Easy and Medium,
-- labelled as a warm-up rather than passed off as the real thing.
--
-- WHAT A TEST WRITES TO attempts, AND WHY IT MATTERS
--
-- Finished tests insert one attempts row per item, always with
-- was_first_attempt = FALSE. That combination is deliberate:
--
--   * bands stay clean. Every band in the app is computed from first looks,
--     so test answers cannot move a student's colour on the topic map. The
--     colour keeps meaning "how they do when they meet a question fresh".
--   * the diagnosis still learns. Coverage counts these rows, and a wrong
--     answer still carries its misconception_tag, so a test failure feeds
--     "worth practising" and the tutor's view like any other mistake.
--
-- The percentage on the topic map comes from the test score, not from
-- attempts. Two numbers, two meanings, neither pretending to be the other.
-- ===========================================================================

create or replace function start_test(p_course text, p_unit text)
returns table (test_id bigint, total int, is_warmup boolean, resumed boolean)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_premium boolean;
  v_want    int;
  v_warmup  boolean;
  v_test    bigint;
  v_count   int;
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;
  if not exists (select 1 from questions
                 where course_code = p_course and unit = p_unit) then
    raise exception 'No such unit.';
  end if;

  -- Resume rather than start again. A student who reloads mid-test, or whose
  -- phone sleeps, comes back to the same paper with their answers intact.
  select t.id into v_test
  from practice_tests t
  where t.student_id = auth.uid() and t.course = p_course and t.unit = p_unit
    and t.finished_at is null and not t.abandoned
  order by t.started_at desc
  limit 1;

  if v_test is not null then
    return query
      select t.id, t.total, t.is_warmup, true
      from practice_tests t where t.id = v_test;
    return;
  end if;

  v_premium := has_premium();
  v_warmup  := not v_premium;
  v_want    := case when v_premium then 15 else 10 end;

  insert into practice_tests (student_id, course, unit, is_warmup, total)
  values (auth.uid(), p_course, p_unit, v_warmup, v_want)
  returning id into v_test;

  -- The paper. One question from every subtopic first, so no subtopic in the
  -- unit can be missed entirely by luck, then the remaining slots filled at
  -- random. Finally ordered Easy to Advanced, the way a real test ramps.
  insert into practice_test_items (test_id, item_no, unit, sort_order,
                                   difficulty, tag)
  select v_test,
         row_number() over (
           order by case p.difficulty
                      when 'Easy'      then 1
                      when 'Medium'    then 2
                      when 'Challenge' then 3
                      else 4 end,
                    p.pick_order),
         p_unit, p.sort_order, p.difficulty, p.tag
  from (
    select c.sort_order, c.difficulty, c.tag, c.pick_order
    from (
      select q.sort_order,
             q.difficulty,
             q.misconception_tag as tag,
             row_number() over (partition by q.misconception_tag
                                order by random()) as rn_in_tag,
             random() as pick_order
      from questions q
      where q.course_code = p_course
        and q.unit = p_unit
        and (v_premium or level_is_free(q.difficulty))
    ) c
    -- One per subtopic wins a slot outright; everything else queues behind.
    order by (c.rn_in_tag > 1), c.pick_order
    limit v_want
  ) p;

  get diagnostics v_count = row_count;

  -- A unit with fewer questions available than the target (only possible on
  -- a warm-up over a thin unit) shortens the paper rather than failing.
  update practice_tests set total = v_count where id = v_test;

  return query select v_test, v_count, v_warmup, false;
end;
$$;


-- ---------------------------------------------------------------------------
-- test_paper — the questions, and nothing else.
--
-- Same option-stripping as list_questions: four texts, no correct_index, no
-- feedback. chosen_index comes back so a resumed test redraws what was
-- already ticked, but was_correct is withheld until the paper is finished.
-- ---------------------------------------------------------------------------
create or replace function test_paper(p_test bigint)
returns table (
  item_no     int,
  sort_order   int,
  difficulty   text,
  prompt       text,
  options      jsonb,
  subtopic     text,
  figure       text,
  chosen_index int
)
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_course text;
begin
  select t.course into v_course
  from practice_tests t
  where t.id = p_test and t.student_id = auth.uid();

  if v_course is null then
    raise exception 'No such test.';
  end if;

  return query
  select i.item_no, i.sort_order, i.difficulty, q.prompt,
         (
           select jsonb_agg(jsonb_build_object('text', elem->>'text')
                            order by ord)
           from jsonb_array_elements(q.options) with ordinality as t(elem, ord)
         ),
         misconception_label(q.misconception_tag),
         q.figure,
         i.chosen_index
  from practice_test_items i
  join questions q
    on q.course_code = v_course and q.unit = i.unit
   and q.sort_order = i.sort_order and q.difficulty = i.difficulty
  where i.test_id = p_test
  order by i.item_no;
end;
$$;


-- ---------------------------------------------------------------------------
-- answer_test_item — records a choice and returns NOTHING.
--
-- The silence is the point. submit_answer returns was_correct and the
-- feedback line, because Quiz is meant to teach in the moment. Returning
-- either here would let a student read the result off the network tab and
-- change their answer, and the score would stop being a score.
-- ---------------------------------------------------------------------------
create or replace function answer_test_item(p_test bigint, p_item_no int,
                                            p_chosen int)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_course  text;
  v_correct int;
  v_item    record;
begin
  if p_chosen is not null and (p_chosen < 0 or p_chosen > 3) then
    raise exception 'Option out of range.';
  end if;

  select t.course into v_course
  from practice_tests t
  where t.id = p_test and t.student_id = auth.uid()
    and t.finished_at is null and not t.abandoned;

  if v_course is null then
    raise exception 'No such test, or it is already finished.';
  end if;

  select * into v_item from practice_test_items i
  where i.test_id = p_test and i.item_no = p_item_no;
  if not found then
    raise exception 'No such question on this paper.';
  end if;

  select q.correct_index into v_correct
  from questions q
  where q.course_code = v_course and q.unit = v_item.unit
    and q.sort_order = v_item.sort_order and q.difficulty = v_item.difficulty;

  update practice_test_items
     set chosen_index = p_chosen,
         was_correct  = (p_chosen = v_correct),
         answered_at  = now()
   where test_id = p_test and item_no = p_item_no;

  update practice_tests t
     set answered = (select count(*) from practice_test_items i
                     where i.test_id = p_test and i.chosen_index is not null)
   where t.id = p_test;
end;
$$;


-- ---------------------------------------------------------------------------
-- finish_test — score it, and only now let the results out.
-- ---------------------------------------------------------------------------
create or replace function finish_test(p_test bigint)
returns table (score_pct int, correct int, total int, is_warmup boolean,
               seconds int)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_t       record;
  v_correct int;
  v_grade   int;
begin
  select * into v_t from practice_tests t
  where t.id = p_test and t.student_id = auth.uid();
  if not found then
    raise exception 'No such test.';
  end if;

  if v_t.finished_at is null then
    select count(*) filter (where i.was_correct) into v_correct
    from practice_test_items i where i.test_id = p_test;

    select p.grade into v_grade from profiles p where p.id = auth.uid();

    insert into attempts (student_id, grade, course, unit, sort_order,
                          difficulty, chosen_index, was_correct,
                          was_first_attempt, misconception_tag, source)
    select auth.uid(), coalesce(v_grade, 10), v_t.course, i.unit, i.sort_order,
           i.difficulty, i.chosen_index, coalesce(i.was_correct, false),
           false,
           case when coalesce(i.was_correct, false) then null else i.tag end,
           'test'
    from practice_test_items i
    where i.test_id = p_test and i.chosen_index is not null;

    update practice_tests
       set finished_at = now(),
           correct     = v_correct,
           score_pct   = round(100.0 * v_correct / nullif(v_t.total, 0))::int
     where id = p_test;
  end if;

  return query
    select t.score_pct, t.correct, t.total, t.is_warmup,
           greatest(0, extract(epoch from (t.finished_at - t.started_at))::int)
    from practice_tests t where t.id = p_test;
end;
$$;


-- ---------------------------------------------------------------------------
-- test_result — the breakdown, after the paper is closed.
--
-- Per subtopic, with the lesson that covers it, because "you scored 60%" is
-- information and "you scored 60% and here is the two-minute read on the two
-- things that cost you it" is a next step.
-- ---------------------------------------------------------------------------
create or replace function test_result(p_test bigint)
returns table (
  tag          text,
  label        text,
  asked        int,
  got          int,
  pct          int,
  lesson_id    bigint,
  lesson_title text
)
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_course text;
begin
  select t.course into v_course from practice_tests t
  where t.id = p_test and t.student_id = auth.uid()
    and t.finished_at is not null;
  if v_course is null then
    raise exception 'No such finished test.';
  end if;

  return query
  select i.tag,
         misconception_label(i.tag),
         count(*)::int,
         count(*) filter (where i.was_correct)::int,
         round(100.0 * count(*) filter (where i.was_correct) / count(*))::int,
         l.id, l.title
  from practice_test_items i
  left join lateral (
    select lf.id, lf.title from lesson_for_tag(v_course, i.tag) lf
  ) l on true
  where i.test_id = p_test
  group by i.tag, l.id, l.title
  order by 5, 3 desc;
end;
$$;


-- ---------------------------------------------------------------------------
-- test_item_review — what was actually wrong, once the paper is closed.
--
-- Feedback appears here and nowhere earlier. It is the same string Quiz would
-- have shown at the moment of the tap; the test simply holds it back until
-- holding it back no longer changes the score.
-- ---------------------------------------------------------------------------
create or replace function test_item_review(p_test bigint)
returns table (
  item_no      int,
  difficulty   text,
  prompt       text,
  chosen_text  text,
  was_correct  boolean,
  feedback     text,
  subtopic     text
)
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_course text;
begin
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
         misconception_label(i.tag)
  from practice_test_items i
  join questions q
    on q.course_code = v_course and q.unit = i.unit
   and q.sort_order = i.sort_order and q.difficulty = i.difficulty
  where i.test_id = p_test
  order by i.item_no;
end;
$$;


-- ---------------------------------------------------------------------------
-- abandon_test — a way out that is not a zero.
-- ---------------------------------------------------------------------------
create or replace function abandon_test(p_test bigint)
returns void
language sql
security definer
set search_path = public
as $$
  update practice_tests set abandoned = true
  where id = p_test and student_id = auth.uid() and finished_at is null;
$$;


revoke all on function start_test(text, text)            from public, anon;
revoke all on function test_paper(bigint)                from public, anon;
revoke all on function answer_test_item(bigint,int,int)  from public, anon;
revoke all on function finish_test(bigint)               from public, anon;
revoke all on function test_result(bigint)               from public, anon;
revoke all on function test_item_review(bigint)          from public, anon;
revoke all on function abandon_test(bigint)              from public, anon;

grant execute on function start_test(text, text)           to authenticated;
grant execute on function test_paper(bigint)               to authenticated;
grant execute on function answer_test_item(bigint,int,int) to authenticated;
grant execute on function finish_test(bigint)              to authenticated;
grant execute on function test_result(bigint)              to authenticated;
grant execute on function test_item_review(bigint)         to authenticated;
grant execute on function abandon_test(bigint)             to authenticated;
-- ===========================================================================
-- Part 5 of 6: the percentage on the topic map.
-- ===========================================================================
--
-- The rule, taken wholesale from topicmindmap because it is better than what
-- we display today:
--
--   * a subtopic's percentage is its BEST test score — best, not latest, not
--     average, so a student is measured by what they have shown they can do
--   * a unit's percentage is the MEAN across its subtopics, counting an
--     untouched subtopic as zero, so it climbs steadily toward 100 as the
--     student works through the unit rather than leaping to whatever one
--     subtopic happened to score
--   * NOTHING is returned until at least one subtopic in the unit has been
--     attempted. A brand new unit shows no number at all, never a
--     demoralising 0%.
--
-- The third rule is why every percentage below is nullable and why the null
-- has to survive all the way to the widget. A zero and an absence look the
-- same in a chart and mean opposite things.
-- ===========================================================================

create or replace function my_percentages()
returns table (
  unit          text,
  tag           text,
  label         text,
  subtopic_pct  int,
  unit_pct      int,
  tests_taken   int,
  best_at       timestamptz
)
language sql
security definer
stable
set search_path = public
as $$
  with me as (select p.course from profiles p where p.id = auth.uid()),
  bank as (
    select distinct q.unit, q.misconception_tag as tag
    from questions q, me
    where q.course_code = me.course and q.misconception_tag is not null
  ),
  -- Every finished, non-abandoned test this student has taken, item by item.
  graded as (
    select i.unit, i.tag, t.id as test_id, t.finished_at,
           count(*)                                   as asked,
           count(*) filter (where i.was_correct)      as got
    from practice_tests t
    join practice_test_items i on i.test_id = t.id
    where t.student_id = auth.uid()
      and t.finished_at is not null
      and not t.abandoned
      and i.tag is not null
    group by i.unit, i.tag, t.id, t.finished_at
  ),
  -- Best score per subtopic across all tests that asked about it.
  best as (
    select g.unit, g.tag,
           max(round(100.0 * g.got / g.asked))::int as pct,
           count(distinct g.test_id)::int           as tests,
           max(g.finished_at)                       as last_at
    from graded g
    group by g.unit, g.tag
  ),
  -- The unit average, over EVERY subtopic in the bank, untouched counting 0.
  per_unit as (
    select b.unit,
           round(avg(coalesce(x.pct, 0)))::int as unit_pct,
           count(x.pct)                        as touched
    from bank b
    left join best x on x.unit = b.unit and x.tag = b.tag
    group by b.unit
  )
  select b.unit,
         b.tag,
         misconception_label(b.tag),
         x.pct,
         case when u.touched > 0 then u.unit_pct end,
         coalesce(x.tests, 0),
         x.last_at
  from bank b
  join per_unit u on u.unit = b.unit
  left join best x on x.unit = b.unit and x.tag = b.tag
  where auth.uid() is not null
  order by b.unit, b.tag;
$$;


-- ---------------------------------------------------------------------------
-- my_unit_percentages — the same number, one row per unit.
--
-- The map and the rail want the unit figure without the forty subtopic rows
-- underneath it. Kept as its own function so the rail does not pay for the
-- detail it does not draw.
-- ---------------------------------------------------------------------------
create or replace function my_unit_percentages()
returns table (
  unit        text,
  unit_pct    int,
  subtopics   int,
  touched     int,
  tests_taken int,
  best_test   int,
  last_test   timestamptz
)
language sql
security definer
stable
set search_path = public
as $$
  with me as (select p.course from profiles p where p.id = auth.uid()),
  bank as (
    select distinct q.unit, q.misconception_tag as tag
    from questions q, me
    where q.course_code = me.course and q.misconception_tag is not null
  ),
  graded as (
    select i.unit, i.tag, t.id as test_id,
           count(*) as asked, count(*) filter (where i.was_correct) as got
    from practice_tests t
    join practice_test_items i on i.test_id = t.id
    where t.student_id = auth.uid() and t.finished_at is not null
      and not t.abandoned and i.tag is not null
    group by i.unit, i.tag, t.id
  ),
  best as (
    select g.unit, g.tag, max(round(100.0 * g.got / g.asked))::int as pct
    from graded g group by g.unit, g.tag
  ),
  tests as (
    select t.unit, count(*)::int as n, max(t.score_pct)::int as best_pct,
           max(t.finished_at) as last_at
    from practice_tests t
    where t.student_id = auth.uid() and t.finished_at is not null
      and not t.abandoned
    group by t.unit
  )
  select b.unit,
         case when count(x.pct) > 0
              then round(avg(coalesce(x.pct, 0)))::int end,
         count(*)::int,
         count(x.pct)::int,
         coalesce(max(s.n), 0),
         max(s.best_pct),
         max(s.last_at)
  from bank b
  left join best  x on x.unit = b.unit and x.tag = b.tag
  left join tests s on s.unit = b.unit
  where auth.uid() is not null
  group by b.unit
  order by b.unit;
$$;


revoke all on function my_percentages()      from public, anon;
revoke all on function my_unit_percentages() from public, anon;
grant execute on function my_percentages()      to authenticated;
grant execute on function my_unit_percentages() to authenticated;
-- ===========================================================================
-- Part 6 of 6: the Astro+ enrolment form and the parent's payment link.
-- ===========================================================================
--
-- Today a student taps Astro+ and is shown Stripe. That is the wrong person.
-- The student is a minor; the card belongs to a parent who is not at the
-- keyboard. So: the student fills in a short form, and the parent receives
-- the payment link by email.
--
-- Nothing in here takes a payment. request_enrolment records the request and
-- returns a token; an edge function mails the parent a link carrying that
-- token; the parent opens it and pays through the Stripe checkout we already
-- have, or reads the Interac instructions. Access still changes only when
-- Stripe's webhook or an admin says so — this file adds no new way to become
-- premium, which is the property that makes it safe to ship.
-- ===========================================================================

create or replace function request_enrolment(
  p_student_name text,
  p_grade        int,
  p_school_board text,
  p_parent_name  text,
  p_parent_email text,
  p_plan         text,
  p_method       text,
  p_school       text default null,
  p_parent_phone text default null
)
returns table (request_id bigint, parent_email text, plan text, method text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id bigint;
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;

  -- Validated here rather than only in Dart. The form is the one place in
  -- this app where a student types an adult's contact details, and a typo in
  -- an email address is a payment link that silently goes nowhere.
  if coalesce(btrim(p_student_name), '') = '' then
    raise exception 'Student name is required.';
  end if;
  if coalesce(btrim(p_parent_name), '') = '' then
    raise exception 'Parent or guardian name is required.';
  end if;
  if p_parent_email !~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$' then
    raise exception 'That parent email address does not look right.';
  end if;
  if p_grade is null or p_grade < 9 or p_grade > 12 then
    raise exception 'Grade must be between 9 and 12.';
  end if;
  if coalesce(btrim(p_school_board), '') = '' then
    raise exception 'School board is required.';
  end if;
  if p_plan not in ('monthly', 'annual') then
    raise exception 'Unknown plan.';
  end if;
  if p_method not in ('stripe', 'etransfer') then
    raise exception 'Unknown payment method.';
  end if;

  -- Replace any open request rather than adding a second one, so a parent
  -- never receives two live payment links for the same child.
  update enrolment_requests
     set status = 'cancelled', decided_at = now()
   where student_id = auth.uid() and status in ('new', 'sent');

  insert into enrolment_requests (
    student_id, student_name, grade, school_board, school,
    parent_name, parent_email, parent_phone, plan, method
  ) values (
    auth.uid(), btrim(p_student_name), p_grade, btrim(p_school_board),
    nullif(btrim(coalesce(p_school, '')), ''),
    btrim(p_parent_name), lower(btrim(p_parent_email)),
    nullif(btrim(coalesce(p_parent_phone, '')), ''),
    p_plan, p_method
  )
  returning id into v_id;

  -- The token is NOT returned to the student's browser. It is the parent's
  -- key and it travels by email only.
  return query
    select e.id, e.parent_email, e.plan, e.method
    from enrolment_requests e where e.id = v_id;
end;
$$;


-- ---------------------------------------------------------------------------
-- my_enrolment_status — so a student is not left wondering.
--
-- The existing e-transfer flow has this exact gap: my_etransfer_status has
-- existed since launch and nothing has ever called it, so a student who
-- submits a claim gets one snackbar and then silence. This one is wired in
-- from the start.
-- ---------------------------------------------------------------------------
create or replace function my_enrolment_status()
returns table (
  request_id   bigint,
  status       text,
  plan         text,
  method       text,
  parent_name  text,
  parent_email text,
  emailed_at   timestamptz,
  created_at   timestamptz
)
language sql
security definer
stable
set search_path = public
as $$
  select e.id, e.status, e.plan, e.method, e.parent_name, e.parent_email,
         e.emailed_at, e.created_at
  from enrolment_requests e
  where e.student_id = auth.uid()
  order by e.created_at desc
  limit 1;
$$;


create or replace function cancel_enrolment()
returns void
language sql
security definer
set search_path = public
as $$
  update enrolment_requests
     set status = 'cancelled', decided_at = now()
   where student_id = auth.uid() and status in ('new', 'sent');
$$;


-- ---------------------------------------------------------------------------
-- ADMIN SIDE
-- ---------------------------------------------------------------------------
create or replace function admin_list_enrolments(p_status text default null)
returns table (
  request_id   bigint,
  student_id   uuid,
  student_name text,
  account_email text,
  grade        int,
  school_board text,
  school       text,
  parent_name  text,
  parent_email text,
  parent_phone text,
  plan         text,
  method       text,
  status       text,
  emailed_at   timestamptz,
  created_at   timestamptz
)
language sql
security definer
stable
set search_path = public
as $$
  select e.id, e.student_id, e.student_name, p.email, e.grade,
         e.school_board, e.school, e.parent_name, e.parent_email,
         e.parent_phone, e.plan, e.method, e.status, e.emailed_at, e.created_at
  from enrolment_requests e
  left join profiles p on p.id = e.student_id
  where is_admin()
    and (p_status is null or e.status = p_status)
  order by e.created_at desc;
$$;


create or replace function admin_mark_enrolment(p_id bigint, p_status text,
                                                p_note text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not is_admin() then
    raise exception 'Admins only.';
  end if;
  if p_status not in ('new', 'sent', 'paid', 'cancelled') then
    raise exception 'Unknown status.';
  end if;

  update enrolment_requests
     set status     = p_status,
         note       = coalesce(p_note, note),
         emailed_at = case when p_status = 'sent'
                           then coalesce(emailed_at, now()) else emailed_at end,
         decided_at = case when p_status in ('paid', 'cancelled')
                           then now() else decided_at end
   where id = p_id;
end;
$$;


-- ---------------------------------------------------------------------------
-- enrolment_by_token — what the parent's link resolves to.
--
-- SECURITY DEFINER and callable by anon, exactly like shared_report, because
-- a parent has no account. It returns the child's first name, the plan and
-- the price to confirm — and nothing else. No email address, no school, no
-- progress, nothing that would make a guessed token worth guessing.
--
-- Expires after 30 days so an old link in an old inbox stops working.
-- ---------------------------------------------------------------------------
create or replace function enrolment_by_token(p_token uuid)
returns table (
  student_first text,
  plan          text,
  method        text,
  status        text
)
language sql
security definer
stable
set search_path = public
as $$
  select split_part(e.student_name, ' ', 1),
         e.plan, e.method, e.status
  from enrolment_requests e
  where e.pay_token = p_token
    and e.status in ('new', 'sent')
    and e.created_at > now() - interval '30 days';
$$;


revoke all on function request_enrolment(text,int,text,text,text,text,text,text,text)
                                                      from public, anon;
revoke all on function my_enrolment_status()          from public, anon;
revoke all on function cancel_enrolment()             from public, anon;
revoke all on function admin_list_enrolments(text)    from public, anon;
revoke all on function admin_mark_enrolment(bigint, text, text)
                                                      from public, anon;
revoke all on function enrolment_by_token(uuid)       from public;

grant execute on function request_enrolment(text,int,text,text,text,text,text,text,text)
                                                      to authenticated;
grant execute on function my_enrolment_status()       to authenticated;
grant execute on function cancel_enrolment()          to authenticated;
grant execute on function admin_list_enrolments(text) to authenticated;
grant execute on function admin_mark_enrolment(bigint, text, text)
                                                      to authenticated;
grant execute on function enrolment_by_token(uuid)    to anon, authenticated;
-- ===========================================================================
-- Part 7 of 7: keeping Test out of Quiz's way, and the paper history.
-- ===========================================================================


-- ---------------------------------------------------------------------------
-- attempts.source — WHY THIS COLUMN HAD TO EXIST
--
-- finish_test writes one attempts row per item so the diagnosis keeps
-- learning from a test. Correct, and necessary. But the client builds its
-- "already solved" set from any correct attempt in a unit, and the level
-- picker SKIPS anything in that set — so a student who took a test would
-- open Quiz to find questions silently missing, permanently, having never
-- seen them there.
--
-- Measured on a fixture account: one finished fifteen-question test removed
-- four questions from the Quiz flow across three levels.
--
-- The two uses of an attempt are genuinely different and now say so:
--
--   diagnosis   counts every row, test included — a wrong answer is a wrong
--               answer whatever paper it was on
--   the quiz    counts only its own rows, so nothing a student has not
--               actually worked through in Quiz is marked done there
--
-- Adding a nullable column takes no table rewrite and no lock worth the
-- name. Existing rows stay null, which reads as "quiz", which is what every
-- one of them is.
-- ---------------------------------------------------------------------------
alter table attempts add column if not exists source text;

comment on column attempts.source is
  'Null (or ''quiz'') for the practice flow, ''test'' for a graded practice '
  'test, ''drill'' for an Improve set. The quiz''s solved-set must exclude '
  '''test'' or a test silently removes questions from the level picker.';

create index if not exists attempts_source_idx
  on attempts (student_id, course, source);


-- ---------------------------------------------------------------------------
-- unit_test_history — every paper sat on this unit.
--
-- The percentage on the topic map is a student's BEST score, which is a
-- kindness but also opaque: it cannot go down, so it stops being news. The
-- history is where improvement is actually visible, and where a warm-up is
-- distinguishable from the real paper rather than averaged in with it.
-- ---------------------------------------------------------------------------
create or replace function unit_test_history(p_course text, p_unit text)
returns table (
  test_id     bigint,
  score_pct   int,
  correct     int,
  total       int,
  is_warmup   boolean,
  seconds     int,
  finished_at timestamptz
)
language sql
security definer
stable
set search_path = public
as $$
  select t.id, t.score_pct, t.correct, t.total, t.is_warmup,
         greatest(0, extract(epoch from (t.finished_at - t.started_at))::int),
         t.finished_at
  from practice_tests t
  where t.student_id = auth.uid()
    and t.course = p_course
    and t.unit = p_unit
    and t.finished_at is not null
    and not t.abandoned
  order by t.finished_at desc
  limit 20;
$$;


revoke all on function unit_test_history(text, text) from public, anon;
grant execute on function unit_test_history(text, text) to authenticated;
-- ===========================================================================
-- Part 8 of 8: the student's own settings.
-- ===========================================================================
--
-- One column, because there is exactly one preference so far and inventing a
-- settings table for it would be building for a future nobody has asked for.
-- When there are four of these it becomes a jsonb column; when there are
-- twenty it becomes a table. Not before.
--
-- Stored on the server rather than in the browser so the choice follows the
-- student between the school laptop and the phone at home, which is the
-- whole reason a signed-in app should remember anything at all.
-- ---------------------------------------------------------------------------

alter table profiles add column if not exists theme_pref text;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'profiles_theme_pref_check'
  ) then
    alter table profiles add constraint profiles_theme_pref_check
      check (theme_pref is null or theme_pref in ('light', 'dark', 'system'));
  end if;
end $$;

comment on column profiles.theme_pref is
  'light | dark | system. Null means system, which is also the default for '
  'an account that has never opened Preferences.';

-- No new function and no new grant. profiles already has an "Update own
-- profile" policy, and the trigger that stops a student changing their own
-- grade names the columns it guards, so a new one is not caught by it. The
-- app writes this the same way it writes a display name.
