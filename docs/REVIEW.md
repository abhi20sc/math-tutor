# REVIEW — security and scalability

Written after a read through the whole system. Ordered by what would actually
bite first, not by severity in the abstract.

Nothing here is on fire. Most of it does not matter at family scale and does
matter at school scale, and the difference is worth knowing before somebody
decides to try it with a real class.

---

## Do these before a real class uses it

### 1. Teacher access codes are guessable  — SECURITY, HIGH

`FAMILY-2026` is the sort of thing a person invents, and `claim_teacher_role`
has no rate limit, so nothing stops thousands of guesses through the REST API.
A student who lands one can create a class, persuade classmates to join it,
and read their records.

This is the highest-value fix on the list because it is the only one where the
consequence is a child's data.

```sql
-- Random, expiring, limited. Read the code out of the result and hand it over.
insert into teacher_invite_codes (code, label, max_uses, expires_at)
values (upper(substr(md5(random()::text), 1, 10)),
        'St Marys maths dept', 5, now() + interval '30 days')
returning code;
```

Also worth doing periodically:

```sql
-- Anyone who should not be a teacher any more
select u.email, s.granted_at, s.note
from staff_roles s join auth.users u on u.id = s.user_id;
```

### 2. `class_roster` multiplies its own data  — SCALABILITY, HIGH

It left-joins `attempts` and `unit_mastery` on the same student, so Postgres
builds every combination of the two. Measured on the test data: 39 attempts ×
3 medals = **117 rows where 39 would do**.

The `count(distinct …)` calls make the result correct, which is why no number
has ever looked wrong. They only hide the cost.

At year end a student with all five units done has roughly 300 attempts and 5
medals: 1,500 rows each, **45,000 for a class of thirty**, rebuilt on every
dashboard load.

Fix: aggregate `attempts` and `unit_mastery` separately in CTEs, then join the
two summaries. About half an hour, no change to what the function returns.

### 3. A student can put any address on their report list  — SECURITY, MEDIUM

`request_report_recipient` accepts any email that looks like one. Capped at
three per student and one consent email a day, which is real protection, but
three students with bad intentions could still send unsolicited mail from your
sending domain to arbitrary addresses.

The consequence is not data loss, it is your domain getting a spam
reputation — which quietly breaks the reports for everybody.

Worth watching once real students have accounts:

```sql
select p.email as student, r.email as guardian, r.status, r.requested_at
from report_recipients r join profiles p on p.id = r.student_id
order by r.requested_at desc limit 50;
```

If it ever becomes a problem, the fix is a domain allow-list or a teacher
approving each guardian.

---

## Worth knowing, not worth acting on yet

### 4. `reports_due` runs the report query twice per recipient — SCALABILITY

Once in the `select`, once in the `where` to check the student practised.
`weekly_report` has six CTEs, so that is two heavy queries per family. At 500
families that is 1,000 executions in one call, against an Edge Function limit
of 150 seconds.

Fix when it matters: compute it once in a CTE and filter on that.

### 5. The app downloads every attempt on load — SCALABILITY

`fetchProgress` pulls every row for the grade since the last reset, just to
draw the unit chips and the resume card. A heavy student ships a few hundred
rows to the browser to render about five numbers.

Fix: a database function returning one summary row per unit.

### 6. Join codes have no rate limit — SECURITY, LOW

Six characters from a 32-character alphabet is about 1.07 billion
combinations, so brute force is impractical. But nothing stops the attempt,
and a successful guess puts somebody on a class roster.

Mitigation available today: `regenerate_join_code` invalidates the old one, so
rotate a code once everybody has joined.

### 7. `invite_student` reveals whether an email has an account — SECURITY, LOW

"No student with that email has an account yet" is an account-existence
oracle. Teacher-only, so the audience is small.

### 8. The cron job holds the service role key in plaintext — SECURITY, LOW

`pg_cron` stores the job body in `cron.job`, readable by anyone with database
access. Standard for this setup, but it means database access equals full
access, with no second step.

### 9. Attempts grow forever — SCALABILITY, LOW

Nothing is ever deleted, deliberately, and that is the right call for a table
a teacher dashboard reads. The volume is small: 1,000 students at 200
questions and 1.5 taps each is roughly 300,000 rows, which Postgres does not
notice.

The Supabase free tier caps at 500 MB and **pauses a project after 7 days of
no activity**. The pause is the real constraint, not the size.

---

## What is genuinely solid

Worth stating, because these are the ones that would have been painful to
retrofit and they are right:

- **Answers never reach the browser.** No `correct_index`, no unpicked
  feedback. There is nothing in the network tab to find.
- **Every write goes through a function.** Attempts and medals cannot be
  forged through the REST API; the progress tables are read-only to students.
- **First-try status is decided by the server**, from attempt history, so it
  cannot be claimed.
- **Teacher access is re-checked on every query** against a live enrolment in
  a class they own. Removing a student cuts it in the same second.
- **The teacher role cannot be self-granted.** `staff_roles` has a read policy
  and no write policy at all.
- **Consent is real.** Pending sends nothing, and the token never passes
  through a browser.
- **`questions` and `teacher_invite_codes` have RLS on and no policy
  whatsoever** — nobody signed in can read either table directly. That is
  deliberate in both cases.

---

## Operational, not security

- **No password reset.** A student who forgets theirs needs it fixed by hand.
  Supabase supports `resetPasswordForEmail`; it needs a screen.
- **Sending domain not verified.** `onboarding@resend.dev` only delivers to
  the address the Resend account was registered with. A domain is needed
  before any real guardian can receive anything — see the handoff.
- **Grade 9 has no hard questions**, so MTH1W ramps and then stops.
- **`supabase_full_setup.sql` rebuilds `profiles`**, so after any re-run every
  student must sign in once before they appear on a roster. Caught this the
  hard way.
- **No automated tests.** The SQL has been exercised against a real Postgres;
  the Dart has never been tested beyond compiling.
