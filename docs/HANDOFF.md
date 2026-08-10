# HANDOFF — Ontario Math Tutor (Flutter Web + Supabase)

Supersedes the earlier handoff. All eight phases are built.

## 1. What this is

A maths practice web app for Ontario high-school students, built by **Jithu**
(Bengaluru, macOS) for his **uncle**, who directs product requirements.

**Core thesis (do not dilute):** the product is *error diagnosis*, not an
answer key. Photomath already solves any question. The differentiator is that
every wrong option matches a real student misconception, its feedback names
that mistake **without revealing the correct answer**, and every wrong tap is
logged with a misconception tag so a teacher can see what the class is
actually getting wrong. Writing good distractors is the slow, valuable part.

---

## 2. The three files

| File | Lines | What |
|---|---|---|
| `supabase_full_setup.sql` | 1792 | Every table, policy and function |
| `questions_all_tagged.sql` | 1938 | All 200 questions with misconception tags |
| `main.dart` | 4741 | The whole app, one file, heavily commented |

Run order from a clean project: setup, then questions, then replace
`lib/main.dart`.

**⚠ `supabase_full_setup.sql` drops and rebuilds `questions` and `profiles`.**
Re-running it wipes the question bank and every student's grade. It does NOT
drop attempts, resets or mastery, so student history survives. Always reload
`questions_all_tagged.sql` afterwards. That file is safe to re-run on its own.

---

## 3. Stack — decided, do not relitigate

Flutter Web (Dart) · Supabase (Postgres + Auth + RLS) · Netlify drag-and-drop.

Rejected: **MongoDB** (browsers cannot open TCP sockets; Atlas Data API shut
down 30 Sept 2025) and **Firebase Auth** (two auth systems; Firebase tokens do
not satisfy Supabase RLS).

```
supabaseUrl     = https://frkswzowskeqmgdrrwab.supabase.co
supabaseAnonKey = sb_publishable_QGTakKcrvWfpTL3SRiT9uQ_mpxnP6Fn
```

The anon key is safe in client code; RLS is the real protection. Never put the
service_role key in the app — it bypasses RLS entirely.

---

## 4. Phases, all delivered

| # | What | Notes |
|---|---|---|
| 1 | Question bank, units, difficulty, per-option feedback | 200 questions |
| 2 | Accounts, grades, per-grade banks | grade changeable in-app |
| 3 | Attempt logging, resume, soft reset | append-only `attempts` |
| 4 | Misconception tags, mastery medals | 166 distinct slugs |
| 5 | Content completion | G9/10/11/12 × 50 |
| 6 | Parent reports | schema + report done; email sending not built |
| 7 | Classes, teacher role, dashboard | invitation-based consent |
| 8 | Server-side grading | answers never reach the browser |

---

## 5. The five design decisions worth understanding

**Attempts key on `(grade, unit, sort_order)`, not `questions.id`.** The
question file deletes and re-inserts per grade, and identity ids get
reassigned on every run. A stored `question_id` would silently point at a
different question after any content edit, and a cascade would delete student
history the moment a typo was fixed.

**The app cannot read the `questions` table.** There is no read policy. Five
security-definer functions hand out the minimum: `list_units`,
`list_questions` (option text only — no `correct_index`, and no feedback,
since a string beginning "Correct." gives the answer away just as plainly),
`submit_answer`, `award_medal`, `reset_progress`. All writes go through
functions, so a student cannot forge an attempt or award themselves a medal.

**"First attempt" is scoped to the current pass**, meaning since the later of
your last reset or your last completion of that unit. Measured since the reset
instead, a finished question could never be a first attempt again, so a
student stuck on Bronze could only improve by wiping every unit they had ever
done. Medals move upward only, so replaying carries no risk.

**The teacher role lives in `staff_roles`, not on `profiles`.** `profiles` has
an "Update own profile" policy so students can change grade; a role column
there would be self-grantable with one REST call. `staff_roles` has a read
policy and no write policy at all. The only ways in are an insert from the SQL
editor or redeeming a teacher access code.

**A teacher reaches a student only through `teaches_student()`** — a live
enrolment in a live class they own, re-checked on every query. Inviting is not
enrolling: the student accepts first, and the teacher sees nothing until they
do. Leaving or being removed cuts access the same second.

---

## 6. Database

**Tables:** `questions` · `profiles` · `attempts` · `progress_resets` ·
`unit_mastery` · `staff_roles` · `teacher_invite_codes` ·
`teacher_invite_uses` · `classes` · `enrolments` · `report_recipients` ·
`report_log`

**Views:** `my_weekly_progress` · `misconception_counts` — unused by the app,
inherit RLS from `attempts`.

**Medals:** Bronze = unit finished, however many taps. Silver = 70% first try.
Gold = 90% first try **and every Hard question first try**. Bronze rewards
finishing rather than perfection on purpose: the app teaches through wrong
answers, so the entry tier must not punish a student for tapping one.

---

## 7. Running the thing

```bash
cd /path/to/math-tutor
flutter run -d chrome          # local, 2-3 min first build
flutter build web --base-href /   # then drag build/web to Netlify
```

Hard-reload the live site with **Cmd+Shift+R** after deploying.

**Adding a teacher.** Once, in the SQL editor:

```sql
insert into teacher_invite_codes (code, label, max_uses)
values ('FAMILY-2026', 'set up by uncle', 5);
```

Then each teacher registers normally and uses **… → I am a teacher**. No SQL
per person. To promote one known account directly instead:

```sql
insert into staff_roles (user_id, role)
select id, 'teacher' from auth.users where email = 'uncle@example.com';
```

**Before real students:** Authentication → Sign In / Providers → Email → turn
**Confirm email** back on.

---

## 8. What is NOT built

- **A verified sending domain. THIS IS THE ONE THING BLOCKING REAL USE.**

  All three Edge Functions are deployed and working, but they send from
  `onboarding@resend.dev`, which Resend only delivers to the address the
  account was registered with. Everything has been tested that way.

  A Gmail address cannot be used as the sender. Gmail publishes a DNS record
  saying only Google may send as gmail.com, so any other server claiming to be
  it gets binned as forgery. You cannot add DNS records to a domain you do not
  own.

  So: buy a domain (roughly ten pounds a year), add it in Resend under
  Domains, copy the four DNS records it gives you, wait for verification, then

      supabase secrets set REPORT_FROM="Math Tutor <reports@yourdomain.ca>"

  No redeploy needed; secrets are read at runtime. Consider setting a
  `reply_to` of a Gmail address you actually read, so replies land somewhere.

  Until this is done, reports work only when the guardian address is the
  Resend account address. Fine for testing, useless for a real family.
- **Password reset.** Supabase supports `auth.resetPasswordForEmail`; needs a
  screen.
- **Tests.** No Dart tests. Answer-checking in HomePage is worth covering
  first.
- **Known issues.** See `REVIEW.md` for the full security and scalability
  audit. Two items matter before a real class: teacher access codes are
  guessable (use random ones), and `class_roster` multiplies its own rows.
- **Grade 9 has no Hard questions.** Fifty questions, all Easy or Medium, so
  MTH1W ramps and then stops. Either that is right for destreamed Grade 9 or
  the bank needs a few multi-step problems per unit. Uncle's call.

---

## 9. Before this goes near a real school

- **Tell students.** They see their classes on the front screen and can leave
  in one tap. Keep it that way. Access a child does not know about is
  surveillance whatever the intent.
- **Decide the joining direction.** Both are built. A code is friendlier;
  invite-by-email is harder to abuse and probably right for a school.
- **Somebody reads MFIPPA and PIPEDA properly.** A dashboard holding minors'
  academic records and a table of guardian email addresses is where this stops
  being a family project. Neither law is satisfied by a schema.

---

## 10. Environment (macOS) — hard-won, read before debugging

**Machine:** Apple Silicon, macOS 26.5.2, Flutter 3.44.8 via Homebrew at
`/opt/homebrew/share/flutter`. Platform folders deleted — web only.

**The big one:** roughly six hours were lost to *silent hangs with zero error
output* on every `flutter` command. Root cause was the machine being out of
disk (3.75 GB free) and RAM. macOS produces hangs, not errors, in that state.
→ **If any Flutter command hangs with no output, check `df -h /` and
`top -l 1` BEFORE anything else.**

Other traps, in the order they were hit:

- `~/Desktop` and `~/Documents` are TCC-protected → `flutter pub add` fails on
  `ios/Flutter/ephemeral`. Deleting `ios/` fixes it for a web-only app.
- A manual SDK install truncated on a full disk, leaving a Flutter with no
  `dart-sdk`. Every command then hung. The Homebrew copy is the working one.
- `flutter --version` on a fresh SDK prints "Initializing the Flutter SDK" and
  then nothing for minutes. **Do not Ctrl+C.**
- Netlify white screen → build with `--base-href /` and drag **`build/web`**,
  the folder containing `index.html`, not `build` and not the project root.
- `flutter run -d chrome` sits at "Waiting for connection from debug service"
  for 2–3 min on first build. Normal.

---

## 11. Working style with this user

- **Beginner.** Needs exact click paths — menu names, which folder to drag —
  not just shell commands. Uses VS Code but is not fluent in it.
- **Prefers one big commented file** over a structured multi-file project. A
  7-file split was tried and rejected: *"just comment in the large dart file,
  this is tiresome to handle."*
- **Gets frustrated with long debugging loops.** Search rather than guess; ask
  for one diagnostic output at a time.
- Typos increase sharply when tired — near midnight local, keep replies short
  and directive.

---

## 12. Authoring conventions for new questions

- Grade sections begin `delete from questions where grade = N;` → idempotent.
- jsonb options written as `'[...]'::jsonb`.
- **No apostrophes anywhere in a string.** A single `'` inside a quoted string
  ends it and throws a syntax error. This bit once: `the ratio's size` in the
  Grade 11 file would have made the whole file fail on first run.
- Multi-line prompts use `E'...\n...'`.
- Every question needs a `misconception_tag`, reusing an existing slug where
  the underlying error is the same.
- **Check before delivering:** duplicate option text within a question, a
  distractor equal to the correct answer, and feedback that gives the answer
  away. Three authoring errors have been caught this way so far, all in the
  Grade 11 batch.
