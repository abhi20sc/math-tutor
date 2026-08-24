# TESTING PROCEDURE — everything changed this session

Ordered by what costs most if it is broken and goes unnoticed, not by what is
easiest to check. Part 1 is the one to do even if you do nothing else.

**Time:** about 40 minutes for all of it. Parts 1–3 are 15 minutes and cover
every change that can lose data or hide a student.

---

## Read this first — the SQL editor lies to you about permissions

The Supabase SQL editor runs as the database owner, which **bypasses row level
security entirely**. So in the SQL editor:

```sql
select * from questions;     -- returns all 240 rows, INCLUDING correct_index
```

That is **not** a leak and does not mean the answer key is exposed. A signed-in
student gets zero rows from that same query. Every permission check in this
document has to be done **through the app, signed in as the relevant person** —
the SQL editor can only tell you what data exists, never who can reach it.

---

## What you need

Four accounts. Make them through the app signup, not by hand in SQL.

| Role | Suggested email | Purpose |
|---|---|---|
| Admin | your own | Already exists |
| Tutor | `tutor.test@…` | Promote via Admin → Tutors → Add tutor |
| Student A | `stu.a@…` | The one who **finishes** a level |
| Student B | `stu.b@…` | The one who **practises and does not finish** — this is the case that was broken |

Both students on **Grade 10 / MPM2D**.

---

## Part 0 — confirm the new build is actually live (1 min)

Flutter web caches hard. A soft reload will show you the old build and make
everything below look broken for the wrong reason.

1. Open the site, press **Cmd-Shift-R** (or Ctrl-Shift-F5).
2. Sign in as the tutor, open any class.
3. Look at the **top right of the class screen** for a **⋮ menu**.

**Pass:** the ⋮ is there and contains "Archive class".
**Fail:** no ⋮ → you are on the old build. Re-upload `build/web/` and hard-reload
again before doing anything else.

---

## Part 1 — the re-run no longer empties your rosters ★ highest value

This is the change that, if wrong, quietly makes every student disappear from
your uncle's screen. Test it deliberately rather than discovering it during a
lesson.

1. Sign in as the tutor. Open the class. **Write down how many students are on
   the roster and their names.**
2. In the Supabase SQL editor, run `supabase_full_setup.sql` again, then
   `questions_grade10.sql` again. (Yes, on your live database. That is the
   point — this is exactly what you will do on every future update.)
3. **Do not sign in as any student.** Go straight back to the tutor's already-open
   browser tab and reload it.

**Pass:** the roster is identical. Same names, same question counts, same
medals — with nobody having signed in.

**Fail:** the roster is empty or short. Stop and tell me; it means the setup
file you ran was the older one that still drops `profiles`.

Then confirm the questions and figures came back together:

```sql
select count(*) as questions, count(figure) as figures from questions;
```

**Expect exactly `240` and `33`.** If figures is 0 you ran the old separate
questions file — the figures are inside `questions_grade10.sql` now.

---

## Part 2 — the drill-down that used to be blank ★ the main fix

This is the bug I found while wiring the screens up. Setting up the failing
case is most of the work.

**Set it up as Student B:**

1. Sign in as Student B.
2. Open **Factoring → Easy**.
3. Answer about five questions and **stop**. Get two or three deliberately
   wrong first, then correct them. **Do not finish the level** — that is the
   whole point. Do not tap anything that awards a medal.
4. Sign out.

**Check it as the tutor:**

5. Sign in as the tutor, open the class, tap Student B.
6. Scroll to **LEVEL BY LEVEL**.

**Pass:** a "Factoring" heading with a row like

```
   Easy    0 of 10 first try · 0%     5 wrong taps
   Mostly: Common factoring
```

**Fail:** the LEVEL BY LEVEL section is missing entirely. That is the old bug —
it means the SQL you ran did not include the rebuilt `student_detail`.

Now the contrast, which is the point of the feature:

7. Sign in as Student A, **finish** Factoring Easy properly and claim the medal.
8. Back as the tutor, open Student A.

**Pass:** their row shows the medal, `10 of 10 first try · 100%`, and
`clean` instead of a wrong-tap count.

---

## Part 3 — class completion (2 min)

Still as the tutor, in the class → **Class progress** tab.

**Pass:** a **HOW FAR THE CLASS HAS GOT** section above TOPICS, with a
Factoring row reading `1 of 2 finished`, a part-filled bar, and one medal dot.

Two things worth checking specifically, because both were wrong before:

- The unit appears **even though only one student finished it**. Previously a
  unit nobody had medalled was invisible here.
- The percentage is **not blank**. It now averages everyone who attempted the
  unit, not only the ones who finished.

---

## Part 4 — change course, and the round trip

I verified this end to end, so you are confirming rather than exploring.

1. Tutor → Student B → **⋮ → Change course** → pick **Grade 9 — MTH1W**.
2. Sign in as Student B.

**Expect: no topics at all.** MTH1W has **no questions loaded on your
database** — you have not run the Grade 9 files. An empty topic list here is
correct, not a failure.

3. Tutor → Student B → ⋮ → Change course → back to **MPM2D**.
4. Sign in as Student B again.

**Pass:** every Factoring attempt is back exactly as it was. Nothing was
deleted while they were away — the attempts are stored against the course, so
moving away hides them and moving back reveals them.

> Do not do this casually to a real student mid-term. It also changes their
> grade, because the grade comes from the course.

---

## Part 5 — remove from a class, and archive a class

Both are worded as ending a **view**, not deleting data. Verify that claim.

> **Do this first, or Part 5 proves nothing.** As the tutor, open Student B and
> write them a note (**FEEDBACK YOU HAVE SENT → Write**). The checks below ask
> whether removing and archiving destroy a student's feedback — and if no note
> exists, the count is 0 before and 0 after, which looks like a pass and tests
> nothing. I made exactly this mistake in the automated suite: the check read
> `count >= 0`, which is true of every count that has ever existed. It is now
> `> 0`, plus a check that the STUDENT can still read the note.

**Remove a student (admin):**

1. Admin → Students → Student B → **⋮ → Remove from a class** → pick the class →
   confirm.
2. Sign in as the tutor and open the class.

**Pass:** Student B is off the roster.

3. Sign in as **Student B**.

**Pass:** all their own progress, medals and history are exactly as before.
Only the tutor's sight of them ended.

**Archive a class (tutor):**

4. Tutor → open the class → **⋮ → Archive class** → read the warning → Archive.

**Pass:** you land back on the class list and the class is gone from it.

5. Confirm in SQL that nothing was destroyed:

```sql
select name, archived_at is not null as archived from classes;
select count(*) as enrolments_still_there from enrolments;
select count(*) as notes_still_there from tutor_notes;
```

**Pass:** the class row is still there with a timestamp, and the enrolment and
note counts are **the same as before you archived** — not merely non-zero.

6. Then the check that actually matters. Sign in as **Student B** and open
   their feedback.

**Pass:** the note is still there and still readable. Archiving is the tutor
closing a folder; it must not reach into the student's app and remove the
feedback they were given. I verified this behaviour directly: after archiving,
the note stays on disk, the STUDENT can still read it, and the TUTOR can no
longer see it — which is exactly the intended split.

---

## Part 6 — regressions: the things that already worked

Quick pass. If any of these break, something in this session broke them.

| Check | How | Pass |
|---|---|---|
| Paywall | As a free student, tap **Challenge** | Locked; it does not open |
| Answer never leaks | Free student, DevTools → Network → open a level → click the `list_questions` response | `options` have `text` only. No `correct_index`, no `feedback` |
| Consent | Tutor invites a **new** email → check the roster before they accept | Roster does **not** show them yet |
| Wrong-answer feedback | Answer one deliberately wrong | Names the mistake, never states the answer |
| Figures | Trigonometry → Medium | Diagrams render, not broken icons |
| e-transfer | Student raises a claim → admin confirms | Challenge unlocks immediately |
| Tutor note | Tutor writes one → sign in as that student | Appears, marked unread |

---

## Part 7 — Stripe annual

Only after `STRIPE_PRICE_ID_ANNUAL` is set and `create-checkout` redeployed.

1. As a student without Astro+, open the upgrade screen and pick **Annual**.

**Pass:** Stripe checkout opens.
**Fail:** a snackbar reading `Unknown plan: annual` → the secret is not set, or
the function was not redeployed after setting it.

2. Pay with `4242 4242 4242 4242`, any future date, any CVC.
3. **Pass:** Challenge and Advanced unlock.
4. Confirm the term is a **year**, not a month — this is the check that catches
   a wrong price id for the cost of a test card instead of a refund:

```sql
select s.status, s.current_period_end
from subscriptions s join auth.users u on u.id = s.student_id
where u.email = 'stu.a@…';
```

**Pass:** `current_period_end` is roughly **12 months** away.
**Fail:** about one month away → `STRIPE_PRICE_ID_ANNUAL` is pointing at the
monthly price.

5. ⋮ → **Manage subscription** → the Stripe billing portal loads.

---

## Part 9 — profile photos

**Before any of this:** photos need two new packages, so this is the one change
in the app that does not work from a straight rebuild.

```
cd ~/Desktop/math_tutor
flutter pub get          # picks up image_picker and image from pubspec.yaml
flutter build web
```

And in Supabase, run **`avatars.sql`** (or re-run the full setup, which now
contains it). Then check the bucket exists: **Storage → Buckets → `avatars`**,
and that it is marked **Private**. If it says Public, stop — re-run the file.

1. Sign in as Student A. The tile at the top left of the account bar is now
   their initials in a coloured circle instead of the grade numeral.
2. Tap it → pick any photo.

**Pass:** it uploads and the circle becomes the photo within a second or two.
**Fail:** `new row violates row-level security policy` → the storage policies
did not get created; you ran the old setup file.

3. Sign in as their tutor and open the class.

**Pass:** the photo is on their roster row.

4. Sign in as a **different** tutor who does not teach them.

**Pass:** they cannot see the student at all, photo included.

5. The one worth checking properly, because it is the one that would matter.
   As Student A, open **My report → share link** and open that link in a
   private window.

**Pass:** the report loads with their progress and **no photo anywhere on it**.
A share link is a URL a fourteen-year-old sends to a friend; it carries their
marks on purpose and must never carry their face. The suite asserts this too
(J6a–c), but it is worth seeing once.

6. Right-click the photo in the roster → copy image address. Paste it into a
   private window.

**Pass:** it loads (the URL is signed and valid for an hour). Leave it an hour
and reload: **it should stop working.** That expiry is the whole reason the
bucket is private rather than public.

7. ⋮ → **Remove my photo** → confirm.

**Pass:** the initials come back, on their screen and on the tutor's.

---

## Part 8 — the automated suite (optional, 1 min)

`test_ama.sql` builds its own fixture users and **is not safe to run on your
live database**. Run it on a scratch Supabase project, or skip it — I run it
here on every change.

For the record it is currently **212 checks, all passing** — including 24 for
the admin drill-down (Block I), 32 for profile photos (Block J) covering the
storage policies as well as the database ones, and 4 (F5) pinning the
function-grant surface: what a signed-out browser may dial, and what a
signed-in student may not.

---

## Resetting between runs

To put a test student back to nothing without touching anybody else:

```sql
-- their own screen, from the app: Profile → Reset progress
-- or, from SQL, for one student only:
delete from attempts     where student_id = (select id from auth.users where email='stu.b@…');
delete from unit_mastery where student_id = (select id from auth.users where email='stu.b@…');
```

Never `delete from attempts` unqualified. It is the only record of every
student's work and nothing regenerates it.
