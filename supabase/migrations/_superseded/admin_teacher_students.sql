-- ===========================================================================
-- admin_teacher_students.sql
-- ===========================================================================
-- The admin panel could list tutors, and could list students, but had no way
-- to get from ONE tutor to the students they teach. The tutor row offered
-- only "Remove". If you wanted to know who Uncle Dileep actually teaches, the
-- only route was to open every student in turn and read their classes column.
--
-- class_roster already answers this shape of question, but it is deliberately
-- teacher-only: it filters on `c.teacher_id = auth.uid()`, meaning YOU teach
-- them. An admin teaches nobody, so it returns nothing for them — correct for
-- what it is, and useless here.
--
-- So this is the admin-side twin: same statistics, same one-row-per-student
-- shape, but scoped to a NAMED teacher and gated on is_admin() instead.
--
-- Safe to re-run. Additive only.
--
-- RUN ORDER: supabase_full_setup.sql -> questions -> this file.
-- ===========================================================================

create or replace function admin_teacher_students(p_teacher uuid)
returns table (
  class_id       bigint,
  class_name     text,
  course         text,
  student_id     uuid,
  full_name      text,
  email          text,
  questions_seen bigint,
  first_try_rate numeric,
  medals         bigint,
  last_active    timestamptz
)
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  -- Raises rather than returning nothing. The admin_list_* functions return
  -- an empty set to a non-admin because they feed LISTS, where empty reads
  -- correctly as "nothing here". This feeds a question about a specific
  -- person, where empty would read as "this tutor has no students" when the
  -- truth is "you may not ask".
  if not is_admin() then
    raise exception 'Admin only.';
  end if;

  return query
  -- Every active enrolment in every live class this teacher owns.
  with roster as (
    select c.id as class_id, c.name as class_name, c.course,
           e.student_id
    from classes c
    join enrolments e on e.class_id = c.id and e.status = 'active'
    where c.teacher_id = p_teacher
      and c.archived_at is null
  ),
  -- Aggregated separately and joined once, for the reason class_roster
  -- documents: joining attempts and mastery onto the student together
  -- multiplies one by the other before either is counted.
  from_attempts as (
    select a.student_id,
           count(distinct (a.unit, a.difficulty, a.sort_order)) as questions_seen,
           round(100.0 * count(*) filter (where a.was_correct
                                            and a.was_first_attempt)
                 / nullif(count(*) filter (where a.was_first_attempt), 0), 0)
                                                                as first_try_rate,
           max(a.answered_at)                                   as last_active
    from attempts a
    where a.student_id in (select r.student_id from roster r)
    group by a.student_id
  ),
  from_mastery as (
    select m.student_id,
           count(distinct m.unit) filter (where m.medal <> 'None') as medals
    from unit_mastery m
    where m.student_id in (select r.student_id from roster r)
    group by m.student_id
  )
  select r.class_id,
         r.class_name,
         r.course,
         p.id,
         coalesce(nullif(trim(p.full_name), ''), split_part(p.email, '@', 1)),
         p.email,
         coalesce(fa.questions_seen, 0),
         fa.first_try_rate,
         coalesce(fm.medals, 0),
         fa.last_active
  from roster r
  join profiles p on p.id = r.student_id
  left join from_attempts fa on fa.student_id = p.id
  left join from_mastery  fm on fm.student_id = p.id
  -- Grouped by class in the app, so class first. Then QUIETEST FIRST:
  -- never-practised at the top, then longest-silent, then today's workers
  -- at the bottom. Same direction as student_detail, and for the same
  -- reason — a screen you open to check on people should lead with the
  -- ones nobody has noticed, not with the ones who are already fine.
  order by r.class_name, fa.last_active asc nulls first;
end;
$$;

grant execute on function admin_teacher_students(uuid) to authenticated;

do $$
begin
  if not exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'admin_teacher_students'
  ) then
    raise exception 'admin_teacher_students did not get created.';
  end if;
  raise notice 'admin_teacher_students is ready.';
end $$;
