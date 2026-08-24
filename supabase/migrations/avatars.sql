-- ===========================================================================
-- avatars.sql — profile photos
-- ===========================================================================
--
-- Safe to re-run. Additive, except for three functions that are dropped and
-- rebuilt because they gain a column and Postgres will not change a return
-- type in place.
--
-- RUN ORDER: supabase_full_setup.sql -> questions -> this file.
-- (It is also merged into supabase_full_setup.sql, so a fresh database gets
-- it without running this separately. This copy is for a database that is
-- already live.)
--
-- ---------------------------------------------------------------------------
-- The shape of the decision
-- ---------------------------------------------------------------------------
-- The users are children. That sets three rules everything below follows:
--
--   1. The bucket is PRIVATE. A public bucket means anybody holding the URL
--      can fetch the picture forever, and URLs leak — into browser history,
--      into a screenshot, into a copied link. Every read here goes through a
--      short-lived signed URL instead.
--
--   2. A photo is visible to the student, to the tutors who actually teach
--      them, and to the admin. Nobody else. In particular NOT to other
--      students, and NOT on a shared report link — a share link is a URL a
--      fourteen-year-old sends to a friend, and it must not carry their face.
--
--   3. A student writes only their own folder. Enforced by path, in the
--      storage policy, not by asking nicely in the app.
--
-- The app re-encodes every upload to a 256px JPEG before it is sent, which
-- also strips EXIF — phone photos otherwise carry the GPS coordinates of
-- wherever the picture was taken, and for this user group that is a location
-- of a child's home or school.
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- 1. Where the path lives
-- ---------------------------------------------------------------------------
-- The PATH, not a URL. Signed URLs expire by design, so storing one would
-- mean storing something that stops working an hour later. The path is
-- permanent and the URL is minted on demand.
alter table profiles add column if not exists avatar_path text;

-- ---------------------------------------------------------------------------
-- 2. The bucket and its policies
-- ---------------------------------------------------------------------------
-- Guarded on the storage schema existing, so this file also loads cleanly on
-- a plain Postgres — which is how the test suite runs, and a migration that
-- cannot be tested locally is a migration nobody tests.
do $$
begin
  if not exists (select 1 from information_schema.schemata
                 where schema_name = 'storage') then
    raise notice 'No storage schema — skipping bucket setup. '
                 'Expected on local Postgres, NOT on Supabase.';
    return;
  end if;

  insert into storage.buckets (id, name, public, file_size_limit,
                               allowed_mime_types)
  values ('avatars', 'avatars', false, 2097152,
          array['image/jpeg', 'image/png', 'image/webp'])
  on conflict (id) do update
    set public             = false,
        file_size_limit    = 2097152,
        allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp'];

  -- The size limit is a second fence, not the first. The app resizes to a
  -- 256px JPEG (about 15–25 kB) before uploading, so anything arriving near
  -- 2 MB did not come from the app.

  execute $p$
    drop policy if exists "Avatar read"   on storage.objects;
    drop policy if exists "Avatar write"  on storage.objects;
    drop policy if exists "Avatar update" on storage.objects;
    drop policy if exists "Avatar delete" on storage.objects;

    -- Read: yourself, a tutor who teaches you, or the admin. The first path
    -- segment is the student id, which is what makes this expressible.
    create policy "Avatar read" on storage.objects for select
      to authenticated
      using (
        bucket_id = 'avatars'
        and (
          (storage.foldername(name))[1] = auth.uid()::text
          or public.is_admin()
          -- The cast is guarded by a CASE rather than by an AND. Postgres is
          -- free to reorder the arms of an AND, so a folder name that is not
          -- a uuid could reach ::uuid and raise — and an error raised inside
          -- a SELECT policy does not deny one row, it fails the whole query.
          -- CASE is the one construct with a guaranteed evaluation order.
          or case
               when (storage.foldername(name))[1] ~
                    ('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
                     || '[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
               then public.teaches_student(
                      ((storage.foldername(name))[1])::uuid)
               else false
             end
        )
      );

    -- Write: your own folder only. Three separate policies rather than one
    -- FOR ALL, because an upsert from the client is an insert OR an update
    -- depending on whether the object already exists, and a missing update
    -- policy fails only on the second upload — which is the kind of bug that
    -- ships.
    create policy "Avatar write" on storage.objects for insert
      to authenticated
      with check (bucket_id = 'avatars'
                  and (storage.foldername(name))[1] = auth.uid()::text);

    create policy "Avatar update" on storage.objects for update
      to authenticated
      using (bucket_id = 'avatars'
             and (storage.foldername(name))[1] = auth.uid()::text)
      with check (bucket_id = 'avatars'
                  and (storage.foldername(name))[1] = auth.uid()::text);

    create policy "Avatar delete" on storage.objects for delete
      to authenticated
      using (bucket_id = 'avatars'
             and (storage.foldername(name))[1] = auth.uid()::text);
  $p$;

  raise notice 'avatars bucket and policies are ready.';
end $$;

-- ---------------------------------------------------------------------------
-- 3. Recording the path
-- ---------------------------------------------------------------------------
-- The upload itself goes straight to storage from the browser, where the
-- storage policy above is the guard. This function records WHERE it went, and
-- re-checks the path belongs to the caller — otherwise a student could point
-- their profile row at somebody else's photo and the app would happily sign
-- a URL for it.
create or replace function set_my_avatar(p_path text)
returns text
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;

  -- Must be inside the caller's own folder. Belt and braces with the storage
  -- policy: that one governs the bytes, this one governs the pointer.
  if p_path is null or p_path not like auth.uid()::text || '/%' then
    raise exception 'That is not your photo.';
  end if;

  update profiles set avatar_path = p_path where id = auth.uid();
  return 'Photo saved.';
end;
$$;

create or replace function clear_my_avatar()
returns text
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not signed in.';
  end if;
  update profiles set avatar_path = null where id = auth.uid();
  return 'Photo removed.';
end;
$$;

grant execute on function set_my_avatar(text) to authenticated;
grant execute on function clear_my_avatar()   to authenticated;

-- ---------------------------------------------------------------------------
-- 4. The three lists that show people
-- ---------------------------------------------------------------------------
-- Each gains one column: avatar_path. Dropped and recreated rather than
-- replaced, because Postgres refuses to change a function's return type in
-- place — "cannot change return type of existing function".
--
-- report_payload and shared_report deliberately do NOT gain it. A shared
-- report is a link a student sends to a friend or a grandparent; it carries
-- their progress on purpose and must not start carrying their face.

drop function if exists class_roster(bigint);
create or replace function class_roster(p_class_id bigint)
returns table (
  student_id     uuid,
  full_name      text,
  email          text,
  units_started  bigint,
  units_medalled bigint,
  gold           bigint,
  questions_seen bigint,
  first_try_rate numeric,
  last_active    timestamptz,
  avatar_path    text
)
language sql
security definer
stable
set search_path = public
as $$
  -- attempts and mastery are aggregated SEPARATELY, then joined one row per
  -- student. The obvious version — join both onto the student and count
  -- distinct — multiplies every attempt by every medal first: measured at 39
  -- attempts and 3 medals it built 117 rows to answer questions 39 could,
  -- and a year-end class of thirty would rebuild about 45,000 rows per load.
  -- count(distinct) hid the cost by keeping the answers right.
  with roster as (
    select e.student_id, c.grade, c.course
    from enrolments e
    join classes c on c.id = e.class_id
    where e.class_id = p_class_id
      and e.status = 'active'
      and c.teacher_id = auth.uid()
  ),
  from_attempts as (
    select a.student_id,
           count(distinct a.unit)                               as units_started,
           count(distinct (a.unit, a.difficulty, a.sort_order)) as questions_seen,
           round(100.0 * count(*) filter (where a.was_correct
                                            and a.was_first_attempt)
                 / nullif(count(*) filter (where a.was_first_attempt), 0), 0)
                                                                as first_try_rate,
           max(a.answered_at)                                   as last_active
    from attempts a
    join roster r on r.student_id = a.student_id and r.course = a.course
    group by a.student_id
  ),
  from_mastery as (
    select m.student_id,
           count(distinct m.unit) filter (where m.medal <> 'None')
                                                                as units_medalled,
           count(distinct m.unit) filter (where m.medal = 'Gold') as gold
    from unit_mastery m
    join roster r on r.student_id = m.student_id and r.grade = m.grade
    group by m.student_id
  )
  select
    p.id,
    coalesce(nullif(trim(p.full_name), ''), split_part(p.email, '@', 1)),
    p.email,
    coalesce(fa.units_started, 0),
    coalesce(fm.units_medalled, 0),
    coalesce(fm.gold, 0),
    coalesce(fa.questions_seen, 0),
    fa.first_try_rate,
    fa.last_active,
    p.avatar_path
  from roster r
  join profiles p on p.id = r.student_id
  left join from_attempts fa on fa.student_id = p.id
  left join from_mastery  fm on fm.student_id = p.id
  order by fa.last_active desc nulls last;
$$;

drop function if exists admin_list_students();
create or replace function admin_list_students()
returns table (
  student_id   uuid,
  full_name    text,
  email        text,
  grade        int,
  course       text,
  plan_status  text,
  premium      boolean,
  period_end   timestamptz,
  classes      text,
  last_active  timestamptz,
  avatar_path  text
)
language sql
security definer
stable
set search_path = public
as $$
  with cls as (
    select e.student_id,
           string_agg(c.name || ' (' || u.email || ')', ', '
                      order by c.name) as classes
    from enrolments e
    join classes c on c.id = e.class_id and c.archived_at is null
    join auth.users u on u.id = c.teacher_id
    where e.status = 'active'
    group by e.student_id
  ),
  act as (
    select a.student_id, max(a.answered_at) as last_active
    from attempts a group by a.student_id
  )
  select p.id, p.full_name, p.email, p.grade, p.course,
         coalesce(s.status, 'none'),
         (s.status in ('active', 'trialing', 'manual')
            or (s.current_period_end is not null
                and s.current_period_end > now())) is true,
         s.current_period_end,
         cls.classes,
         act.last_active,
         p.avatar_path
  from profiles p
  left join subscriptions s on s.student_id = p.id
  left join cls on cls.student_id = p.id
  left join act on act.student_id = p.id
  where is_admin()
    and not exists (select 1 from staff_roles r where r.user_id = p.id)
  order by p.full_name;
$$;

drop function if exists admin_teacher_students(uuid);
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
  last_active    timestamptz,
  avatar_path    text
)
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if not is_admin() then
    raise exception 'Admin only.';
  end if;

  return query
  with roster as (
    select c.id as class_id, c.name as class_name, c.course,
           e.student_id
    from classes c
    join enrolments e on e.class_id = c.id and e.status = 'active'
    where c.teacher_id = p_teacher
      and c.archived_at is null
  ),
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
         fa.last_active,
         p.avatar_path
  from roster r
  join profiles p on p.id = r.student_id
  left join from_attempts fa on fa.student_id = p.id
  left join from_mastery  fm on fm.student_id = p.id
  order by r.class_name, fa.last_active asc nulls first;
end;
$$;

grant execute on function class_roster(bigint)              to authenticated;
grant execute on function admin_list_students()             to authenticated;
grant execute on function admin_teacher_students(uuid)      to authenticated;

-- ---------------------------------------------------------------------------
-- 5. Hardening, from the Supabase security advisor
-- ---------------------------------------------------------------------------
-- The advisor flags every security definer function as executable by anon.
-- True, and by default unavoidable: Postgres grants EXECUTE on new functions
-- to PUBLIC, which anon inherits. Nothing leaked — every function re-checks
-- auth.uid() or is_admin() in its body, and the suite proves anon gets
-- nothing from any of them — but a signed-out browser being able to *dial*
-- 49 functions it can never use is surface with no purpose.
--
-- So: revoke the blanket PUBLIC grant, give authenticated and service_role
-- everything back (service_role is what the Stripe webhook and the email
-- functions run as — forgetting it here would break payments quietly), and
-- hand anon exactly the two things a person without an account genuinely
-- does: read the course list on the signup screen, and open a shared report.
-- The mechanics need care, because the file already contains two kinds of
-- statement this must not fight with:
--
--   * a curated allowlist of `grant ... to authenticated` — one per
--     app-facing function
--   * five deliberate denials, where the ONLY protection is that
--     authenticated has no grant: grant_teacher_role (would let a student
--     make themselves admin), the three Stripe subscription writers (would
--     let a student mint premium), and report_payload
--
-- An earlier draft did `grant execute on all functions to authenticated`
-- here. The suite failed within seconds: C1 self-granted admin, because the
-- blanket grant had re-opened all five denials. And the draft after that
-- granted nothing to authenticated — which broke differently, because RLS
-- policies call helpers like teaches_student AS THE SIGNED-IN USER, and
-- those helpers were riding on the PUBLIC default this block removes.
--
-- So: blanket to authenticated is on purpose, and the denials are re-stated
-- immediately after it, closed again before this transaction ever ends. The
-- net effect for a signed-in user is exactly the surface the file always
-- intended; the change is that a signed-out browser goes from being able to
-- dial 49 functions to exactly 2.
revoke execute on all functions in schema public from public, anon;
grant  execute on all functions in schema public to authenticated;
revoke all on function grant_teacher_role(text, text)  from authenticated;
revoke all on function report_payload(uuid)            from authenticated;
revoke all on function upsert_subscription(uuid, text, text, text, timestamptz)
                                                       from authenticated;
revoke all on function update_subscription_by_sid(text, text, timestamptz)
                                                       from authenticated;
revoke all on function set_stripe_customer(uuid, text) from authenticated;

-- service_role is the webhook and the email functions — server-side keys
-- only, never the browser. Blanket is correct for it: a trusted role that
-- loses a grant fails quietly at 3am when a subscription renews.
grant execute on all functions in schema public to service_role;

-- The two things a person without an account genuinely does: read the course
-- list on the signup screen, and open a report someone shared with them.
grant execute on function list_courses()      to anon;
grant execute on function shared_report(uuid) to anon;

-- level_is_free was the one function without a pinned search_path. It touches
-- no tables at all, so nothing could actually be hijacked — but one function
-- configured differently from the other sixty is a question every future
-- reader has to stop and answer. Now it matches.
create or replace function level_is_free(p_level text)
returns boolean
language sql
immutable
set search_path = public
as $$
  select p_level in ('Easy', 'Medium');
$$;

do $$
begin
  if not exists (select 1 from information_schema.columns
                 where table_name = 'profiles' and column_name = 'avatar_path')
  then
    raise exception 'avatar_path did not get added to profiles.';
  end if;
  raise notice 'avatars.sql is done.';
end $$;
