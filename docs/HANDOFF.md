# HANDOFF — Astro Math Assist (Flutter Web + Supabase)

> **This file does not describe current status.** That lives in
> **PROJECT_STATE.md**, and it is the only file that should.
>
> This one holds the things that do not change week to week: why the stack is
> what it is, the design decisions worth not re-litigating, the environment
> traps, and how to work with the person maintaining it. It got rewritten
> after three docs — this one, the README and HOW_IT_WORKS — were all found
> describing features that had been removed. Anything status-shaped that gets
> added here will go stale the same way, so put it in PROJECT_STATE instead.

---

## 1. What this is

A maths practice web app for Ontario Grade 10 (MPM2D), built by **Jithu**
(Bengaluru, macOS) for his **uncle**, who directs product requirements and
teaches the students.

**Core thesis (do not dilute):** the product is *error diagnosis*, not an
answer key. Photomath already solves any question. The differentiator is that
every wrong option matches a real student misconception, its feedback names
that mistake **without revealing the correct answer**, and every wrong tap is
logged with a subtopic tag so a teacher can see what the class is actually
getting wrong. Writing good distractors is the slow, valuable part.

Anything that undermines that — leaking the answer in feedback, punishing
mistakes, hiding the hint below the fold — is a bug, not a preference.

---

## 2. The files that matter

| File | What |
|---|---|
| `lib/main.dart` | The whole app, one file, heavily commented |
| `supabase/migrations/supabase_full_setup.sql` | Every table, policy and function |
| `supabase/migrations/questions_grade10.sql` | The 240 Grade 10 questions |
| `tests/test_ama.sql` | The SQL suite. 62 checks, asserts rather than prints |

Run order from a clean project: setup, then questions, then re-grant admin,
then replace `lib/main.dart` and build.

**⚠ `supabase_full_setup.sql` drops and rebuilds `questions`, `profiles` and
`staff_roles`.** Re-running it wipes the question bank, every student's grade,
and every teacher role. It does NOT drop attempts, resets or mastery, so
student history survives. Always reload the questions file afterwards, and
always re-grant admin. The questions file is safe to re-run on its own.

---

## 3. Stack — decided, do not relitigate

Flutter Web (Dart) · Supabase (Postgres + Auth + RLS + Edge Functions) ·
Netlify drag-and-drop · Stripe.

Rejected: **MongoDB** (browsers cannot open TCP sockets; Atlas Data API shut
down 30 Sept 2025) and **Firebase Auth** (two auth systems; Firebase tokens do
not satisfy Supabase RLS).

```
supabaseUrl     = https://frkswzowskeqmgdrrwab.supabase.co
supabaseAnonKey = sb_publishable_QGTakKcrvWfpTL3SRiT9uQ_mpxnP6Fn
```

The publishable key is safe in client code; RLS is the real protection. Never
put the service_role key or the Stripe secret key in the app — the first
bypasses RLS entirely and the second is money.

**One file, on purpose.** A seven-file split was tried and rejected: *"just
comment in the large dart file, this is tiresome to handle."* Do not split it.

---

## 4. The design decisions worth understanding

**Attempts key on `(grade, unit, sort_order)`, not `questions.id`.** The
question file deletes and re-inserts per unit, and identity ids get reassigned
on every run. A stored `question_id` would silently point at a different
question after any content edit, and a cascade would delete student history
the moment a typo was fixed.

**The app cannot read the `questions` table.** RLS is on and there is no
policy at all, so a signed-in student selecting from it gets zero rows rather
than an error. Security-definer functions hand out the minimum:
`list_questions` returns option **text only** — no `correct_index`, and no
feedback, because a string beginning "Correct." gives the answer away just as
plainly as the index does. All writes go through functions, so a student
cannot forge an attempt or award themselves a medal.

*Consequence for testing:* a harness running as `authenticated` reads nothing
from `questions`. Fetch answer keys as the owner first, then `set role
authenticated`. This has caught people out more than once.

**The paywall is enforced in four places, not one.** `list_questions` and
`submit_answer` both refuse a locked level — the second matters because a
hand-built REST call can name a question by number without ever listing it.
`award_medal` returns `None` for a locked level. And `has_premium()` treats a
cancelled subscription as premium until `current_period_end` actually passes,
because taking back time a family paid for would be theft with extra steps.

**"First attempt" is scoped to the current pass**, meaning since the later of
the last reset or the last completion of that level. Measured since the reset
instead, a finished question could never be a first attempt again, so a
student stuck on Bronze could only improve by wiping every unit they had ever
done. Medals move upward only, so replaying carries no risk.

**Medals are per level, not per unit.** A level is one difficulty, so the
first-try percentage says it all: Gold at 90%, Silver at 70%, Bronze for
finishing. The old "Gold requires every Hard question" rule went with the
old bank, where a unit mixed difficulties.

**Colour bands are computed in SQL, not Dart.** `report_payload()` decides
green/amber/red/grey so the bar chart and the mind map can never disagree.
Based on first-try rate, not completion — a student who finished a unit by
guessing has not learned it.

**The teacher role lives in `staff_roles`, not on `profiles`.** `profiles` has
an "Update own profile" policy so students can change grade; a role column
there would be self-grantable with one REST call. `staff_roles` has a read
policy and no write policy at all. `grant_teacher_role` is granted to
`service_role` only, so the sole route in is the SQL editor. There is no
self-serve path: no "I am a teacher" button, no access codes, no join codes.

**A teacher reaches a student only through `teaches_student()`** — a live
enrolment in a live class they own, re-checked on every query. Leaving or
being removed cuts access the same second. The dashboard functions return
*nothing* rather than raising when the check fails, which matches
`class_roster` and is what the app expects.

**Two enrolment paths, and one of them bends the consent model.**
`invite_student` asks and waits. `add_student_to_class` does not ask. The
second is defensible here because a private tutor is recording a relationship
that already exists — and only because the student sees every class they are
in and can leave in one tap. For a school, invitation becomes the only way in.
The long comment on the function says the same thing; keep them in step.

**Report sharing is deliberately minimal.** A share link carries **first name
only** — no surname, no email, no class. It is a public URL that can be
forwarded anywhere, so `revoke_and_reissue_share()` kills the old one
instantly. This was a considered child-privacy decision; if it changes, change
it knowingly.

---

## 5. Database shape

**Tables:** `questions` · `profiles` · `attempts` · `progress_resets` ·
`unit_mastery` · `subscriptions` · `staff_roles` · `classes` · `enrolments` ·
`misconception_labels` · `report_shares`

Every one has RLS enabled. **Every policy on every table is `for select`** —
there is not a single insert, update or delete policy anywhere except on
`profiles`. That is the spine of the design, not an oversight.

**Views:** `my_weekly_progress` · `misconception_counts` — unused by the app,
inherit RLS from `attempts`.

---

## 6. Running the thing

```bash
cd ~/Desktop/math_tutor
flutter run -d chrome              # local, 2-3 min first build
flutter build web --base-href /    # then drag build/web to Netlify
```

Hard-reload the live site with **Cmd+Shift+R** after deploying.

The SQL suite needs a local Postgres, never the live project:

```bash
dropdb --if-exists ama && createdb ama
psql -d ama -f tests/00_supabase_stub.sql
psql -d ama -f supabase/migrations/supabase_full_setup.sql
psql -d ama -f supabase/migrations/questions_grade10.sql
psql -d ama -f tests/test_ama.sql
```

**Before real students:** Authentication → Sign In / Providers → Email → turn
**Confirm email** back on. And add the Netlify URL to the allowed redirect
URLs, or password reset links will not come back to the app.

---

## 7. Environment (macOS) — hard-won, read before debugging

**Machine:** Apple Silicon, macOS 26.5.2, Flutter 3.44.8 via Homebrew at
`/opt/homebrew/share/flutter`. Project at `~/Desktop/math_tutor`. Platform
folders deleted — web only.

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
- **Regex-based bulk edits to `main.dart` have twice eaten class boundaries**,
  producing "Method not found: 'QuestionRepository'" and "'fromJson' isn't
  defined". After any bulk deletion, verify: all 19 models have `fromJson`
  factories, every repository method still exists, and the braces balance.
- **Supabase does not error on duplicate-email signup.** It returns something
  resembling "confirm your email". The tell is an empty `identities` list.
  Already handled via `RegisterOutcome.alreadyExists`.

---

## 8. Authoring conventions for new questions

The full pipeline is in **AUTHORING_GUIDE.md**. The rules that break a file if
ignored:

- Unit blocks begin `delete from questions where grade = N and unit = '...'`,
  so a corrected unit re-runs cleanly and student history survives.
- jsonb options written as `'[...]'::jsonb`.
- **No apostrophes anywhere in any string.** A single `'` ends the SQL string
  and kills the whole file. Write "cannot", "it is", "the students". This
  nearly shipped once as `the ratio's size`.
- Multi-line prompts use `E'...\n...'`.
- Correct option feedback is exactly `Correct.` — anything longer leaks
  information through its length.
- Every question needs a `misconception_tag`, and every new slug needs a row
  in `misconception_labels` or the dashboard shows a blank.

`tests/test_ama.sql` now checks most of this mechanically — option counts,
index range, duplicate options, sort_order bands, missing tags and missing
labels are all assertions. It also *reports* wrong-option feedback that states
the correct answer, without failing on it, because that is an authoring call.

---

## 9. Working style with this user

- **Beginner, and says so.** Explain *why*, not just what. Needs exact click
  paths — menu names, which folder to drag — not only shell commands. Uses VS
  Code but is not fluent in it.
- **Tests things properly and reports back accurately.** Trust his reports.
- **Wants to be told when something is a bad idea**, and has changed direction
  several times on being given a straight reason. Say it plainly.
- **Deliverables should be complete files**, not patches to apply by hand.
- **Flag privacy and child-safety implications before building, not after.**
  This has mattered repeatedly — parent emails, then share links.
- **Prefers one big commented file** over a structured multi-file project.
- Gets frustrated with long debugging loops. Search rather than guess; ask for
  one diagnostic output at a time.
- Typos increase sharply when tired — near midnight local, keep replies short
  and directive.
