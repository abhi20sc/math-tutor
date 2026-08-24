# Deploying everything built in August 2026

Astro Math Assist — Learn / Quiz / Improve / Test, 219 lessons, dark mode,
branding, privacy policy and terms.

Read the whole thing once before starting. It is about 40 minutes, most of
which is waiting for a build.

**Nothing here deletes student data.** There are 8 accounts and 296 recorded
attempts on the live project; every step below either adds a table, adds a
nullable column, or replaces rows in tables that hold no student work.

---

## Before you start

```bash
cd ~/Downloads/math_tutor
git status          # if this is a git repo, commit or stash first
```

If `flutter analyze` is not already clean, stop and send me the output. Do
not deploy on top of an analyzer error.

---

## Step 1 — Unzip the lesson diagrams

316 PNGs, two per diagram, one for each theme.

```bash
cd ~/Downloads/math_tutor/web/figures
unzip -q lesson_figures.zip -d lessons
rm lesson_figures.zip
ls lessons/*.png | wc -l      # must print 316
```

If it prints anything else, stop — the lessons will render with "This
diagram could not load" where every picture should be.

---

## Step 2 — The schema

Supabase → SQL Editor → **New query** each time. Paste, Run, check the
result, then move on.

### 2a. `supabase/migrations/astro_sections.sql`  (62 KB)

Creates five tables, adds two nullable columns, and 25 functions. Safe to run
twice; it is written to be re-runnable.

Expect: `Success. No rows returned.`

Check it landed:

```sql
select
  (select count(*) from information_schema.tables
    where table_schema='public' and table_name='lessons')          as lessons,
  (select count(*) from information_schema.tables
    where table_schema='public' and table_name='practice_tests')   as tests,
  (select count(*) from information_schema.columns
    where table_name='attempts' and column_name='source')          as source_col,
  (select count(*) from information_schema.columns
    where table_name='profiles' and column_name='theme_pref')      as theme_col;
```

All four must be `1`.

### 2b. The lessons — six files, in any order

`supabase/migrations/lessons/`

| File | Lessons | Size |
|---|---|---|
| `lessons_mth1w.sql` | 50 | 149 KB |
| `lessons_mpm2d.sql` | 29 | 76 KB |
| `lessons_mcr3u.sql` | 38 | 140 KB |
| `lessons_mhf4u.sql` | 36 | 144 KB |
| `lessons_mcv4u.sql` | 36 | 136 KB |
| `lessons_mdm4u.sql` | 30 | 132 KB |

Six files rather than the one 787 KB `bundles/lessons_all.sql`, because the editor
struggled with a file that size last time. Each one deletes and reloads only
its own course, so re-running one is safe and does not touch the others.

Check:

```sql
select course_code, count(*) from lessons group by 1 order by 1;
-- MCR3U 38 · MCV4U 36 · MDM4U 30 · MHF4U 36 · MPM2D 29 · MTH1W 50

select count(*) from lessons;                        -- 219
select count(*) from (
  select distinct course_code, misconception_tag from questions
  where misconception_tag is not null) q
left join lessons l
  on l.course_code = q.course_code and l.tag = q.misconception_tag
where l.id is null;                                  -- 0
```

That last one is the one that matters: **zero subtopics without a lesson.** A
student can never be told to revise something with nothing to read.

---

## Step 3 — Build and deploy

```bash
cd ~/Downloads/math_tutor
flutter pub get
flutter analyze          # send me anything it says
flutter test             # 18 checks
flutter clean
flutter build web
```

Then check what you are about to upload:

```bash
ls build/web/figures/*.png       | wc -l   # 60   question figures
ls build/web/figures/lessons/*.png | wc -l # 316  lesson diagrams
find build/web -type f           | wc -l   # ~414
```

Drag `build/web` onto Netlify. Then **close the site tab completely and
reopen it** — Flutter's service worker serves the old app for a load or two
otherwise.

---

## Step 4 — Check it in the browser

In this order, because each one depends on the last:

1. **The tab says Astro Math Assist** and the favicon is a teal parabola with
   a gold star. If it still says `math_tutor`, the build did not deploy.
2. **Sign in.** The rail now shows Learn · Quiz · Improve · Test above the
   topic list.
3. **Learn** → pick a topic → a list of lessons → open one. You should see
   headings, a worked example, a diagram, Common Mistakes, and at the bottom
   *Try questions on this* and *Next lesson*.
4. **Quiz** → unchanged. Answer one question to confirm grading still works.
5. **Improve** → after a few wrong answers, subtopics appear with a reason.
   *Practise this* opens a short set.
6. **Test** → pick a topic → *Start the test*. Fifteen questions if you are
   on Astro+, ten and labelled "warm-up" if not. **No feedback until you hand
   it in.** Then: score, by-level bars, by-subtopic breakdown, and *Go through
   the questions*.
7. **Profile → Appearance → Dark.** The whole app should switch, including
   dialogs and menus. Sign out and back in — it should still be dark.
8. **Collapse the rail** with the arrow by the title. Start a quiz — it should
   fold itself away as the question appears.
9. **Your report** → the topic map has a Map / List toggle. List is the
   default now.

---

## Step 5 — The settings that are not code

Supabase dashboard:

- **Authentication → Providers → Email → Confirm email: ON.**
  It is currently off. This is the one on this list I would not launch
  without.
- **Authentication → Policies → leaked password protection: ON.** Free, and
  checks new passwords against HaveIBeenPwned.
- **Authentication → minimum password length: 8**, so the server agrees with
  the app.
- **Add your Netlify URL to the allowed redirect list**, then send yourself a
  password reset and open it **on a phone**. That path has never been tested
  end to end.

---

## What is still not done after all this

Not blockers, but do not lose track of them:

- **The privacy policy and terms are not linked from anywhere in the app.**
  Both pages are live at `/privacy.html` and `/terms.html` once you deploy,
  but nothing in the app points to them. That is an hour, and it is the
  remaining launch blocker.
- **The topic map shows first-try rate, not best test score.** The widgets
  read `test_scores`; `report_payload` does not send it yet.
- **The brand mark is not inside the app** — only on the tab and the home
  screen icon.
- **The Astro+ parent form** is built in the database and not in the app.
- **Nobody has opened any of this on a phone.**

---

## If something goes wrong

**The SQL editor errors on a lessons file.** Note the exact message and which
file. Each file is independent, so the others are unaffected.

**Learn says "No lessons written for this unit yet".** Step 2b did not run
for that course, or ran against a different project.

**Diagrams show "This diagram could not load".** Step 1, or `build/web` was
uploaded before the unzip.

**The app looks broken after deploying.** Hard-reload once — the service
worker. If it survives that, the build is bad; `flutter clean` and build
again.

**Anything in `flutter analyze`.** Send it to me rather than working around
it. I cannot compile here, so your analyzer is the only compiler this code
has seen.

---

## Rolling back

Everything in Step 2 is additive. To undo it completely:

```sql
drop table if exists practice_test_items, practice_tests,
                     lesson_reads, lessons, enrolment_requests cascade;
alter table attempts  drop column if exists source;
alter table profiles  drop column if exists theme_pref;
```

Then redeploy the previous `build/web`. No student loses anything —
`questions`, `attempts`, `profiles`, `subscriptions` and every class are
untouched by all of it.
