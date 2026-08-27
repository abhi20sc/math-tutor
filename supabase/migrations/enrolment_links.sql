-- ===========================================================================
-- ASTRO STEM LABS — the two functions the Astro+ flow was missing
-- Run AFTER astro_sections.sql. Safe to re-run.
-- ===========================================================================
--
-- THE GAP
--
-- astro_sections.sql built the whole Astro+ enrolment path and tested it:
-- a student submits a request, it lands in enrolment_requests with a
-- pay_token, an admin works the queue, and a parent opens a link with that
-- token to pay. Six functions, all of them working.
--
-- Except nothing ever returns the token.
--
-- request_enrolment returns (request_id, parent_email, plan, method).
-- my_enrolment_status returns eight columns, none of them the token.
-- admin_list_enrolments returns fifteen, none of them the token.
-- enrolment_by_token takes one, and nothing on earth could tell you what to
-- pass it.
--
-- So the flow was complete apart from the one value that makes it a flow.
-- The only way to get a parent their link was to read it out of the table
-- by hand in the SQL editor. That is why the interface was never written:
-- there was nothing to write it against.
--
-- WHY TWO NEW FUNCTIONS RATHER THAN AMENDING THE OLD ONES
--
-- The obvious fix is to add pay_token to admin_list_enrolments' return
-- type. That means dropping and recreating it, because Postgres refuses to
-- change a function's return type in place — the exact error that
-- admin_teacher_students.sql now fails with, and which this project has
-- already been bitten by once. It would also invalidate the tests that
-- pin the existing shape.
--
-- Adding is cheaper than reshaping. The existing six are untouched.
-- ===========================================================================

\set ON_ERROR_STOP on


-- ---------------------------------------------------------------------------
-- The admin's copy of the link
-- ---------------------------------------------------------------------------
--
-- Takes a request id from admin_list_enrolments and returns the token for
-- it. Admin only, and that is the whole access rule: the token is a
-- bearer credential for a payment page, so handing it out on a list
-- endpoint would mean it appeared in every log line that logged a roster.
-- One id at a time, deliberately.

create or replace function admin_enrolment_link(p_id bigint)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_token uuid;
begin
  if not is_admin() then
    raise exception 'Not allowed.';
  end if;

  select pay_token into v_token
  from enrolment_requests where id = p_id;

  if v_token is null then
    raise exception 'No such request.';
  end if;
  return v_token;
end;
$$;


-- ---------------------------------------------------------------------------
-- The student's copy of the link
-- ---------------------------------------------------------------------------
--
-- The same token, for the student's own open request only.
--
-- Giving it to the student is deliberate and is the same decision the
-- guardian consent link already makes: this app cannot send email, so the
-- person who can reach the parent is the student. Handing them the link to
-- pass on is honest about that, and it is what makes the flow work today
-- rather than after an email provider is chosen and paid for.
--
-- It is not a privilege escalation. The token opens a page showing the
-- student's own first name, the plan and the status, and a checkout button
-- that needs a card. A student who wanted to pay for their own subscription
-- could already do that from inside the app.
--
-- Returns null rather than raising when there is no open request, because
-- "you have not asked for Astro+" is a state the interface has to render,
-- not an error it has to catch.

create or replace function my_enrolment_link()
returns uuid
language sql
security definer
stable
set search_path = public
as $$
  select pay_token
  from enrolment_requests
  where student_id = auth.uid()
    and status in ('new', 'sent')
  order by created_at desc
  limit 1;
$$;


-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------
--
-- admin_enrolment_link checks is_admin() itself AND is granted only to
-- authenticated, so it is protected twice. That is not belt-and-braces
-- here: the grant is what stops a signed-out browser calling it at all,
-- and the check is what stops a signed-in student who does.

revoke all on function admin_enrolment_link(bigint) from public, anon;
revoke all on function my_enrolment_link()          from public, anon;

grant execute on function admin_enrolment_link(bigint) to authenticated;
grant execute on function my_enrolment_link()          to authenticated;

-- Verify, as an admin:
--   select admin_enrolment_link(id) from enrolment_requests limit 1;
-- As the student who owns it:
--   select my_enrolment_link();
