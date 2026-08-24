# Installing Astro Math Assist

## The short version, for the database you already have

**You need to run one SQL file, not two.**

`astro_math_assist_setup.sql` is byte-for-byte identical to the
`supabase_full_setup.sql` you already ran, apart from its comment header. Your
live project already has that schema — the app works, so it must. Re-running it
would drop and rebuild the `questions` table for no reason.

So on the live project:

1. **`supabase/migrations/questions_all.sql`** — paste into the Supabase SQL
   Editor, press Run. 1600 questions, 40 units, six courses, 60 figures.
2. **Rebuild and redeploy the app** (see below). This is not optional: the new
   courses reference 27 figures your current deploy does not carry.

That is the whole thing.

If the editor chokes on 1.2 MB, use `supabase/migrations/by_course/` instead —
the same content split six ways, about 200 KB each. Run them in any order:

```
questions_grade09_mth1w.sql      360 questions
questions_grade10_mpm2d.sql      240   <- the live course
questions_grade11_mcr3u.sql      280
questions_grade12_mhf4u.sql      280
questions_grade12_mcv4u.sql      240
questions_grade12_mdm4u.sql      200
```

Each is self-contained and safe to run on its own. Within a file the order is
fixed and matters — see "Why the figure files come last" below.

---

## From a completely clean Supabase project

Two files, in this order:

| # | File | What it does |
|---|---|---|
| 1 | `supabase/migrations/astro_math_assist_setup.sql` | Every table, policy, function and grant — 103 functions, the avatar bucket, the admin drill-down. |
| 2 | `supabase/migrations/questions_all.sql` | All 1600 questions and 60 figures. |

There is no step 3.

---

## Rebuild and deploy

```bash
cd ~/Downloads/math_tutor
flutter pub get
flutter build web
# then drag build/web onto Netlify
```

Expect **98 files** in `build/web` — 38 app files and 60 figures. The old note
in this project said 71 files and 33 figures; that was before Grades 9, 11 and
12 existed. If figures are missing, check `web/figures/` still holds 60 PNGs.
They ship from source, and their absence once caused questions to reference
invisible diagrams.

After deploying, close the site tab completely and reopen it. Flutter's service
worker serves the old app for a load or two otherwise.

---

## Two files that must NOT be run any more

`avatars.sql` and `admin_teacher_students.sql` are both folded into
`astro_math_assist_setup.sql`.

**`admin_teacher_students.sql` now fails outright** against a current database:

```
ERROR: cannot change return type of existing function
```

because the copy inside the setup file returns more columns than the old
standalone one. The run order printed in `00_LOAD_ORDER.md` used to list it as
step 2, which would have stopped an install there. Both files are kept only for
a database that predates the merge.

---

## Why the figure files come last

Every unit file opens with

```sql
delete from questions where course_code = '...' and unit = '...';
```

and that delete takes the figure reference with the row. A `figures_*.sql` that
ran before its question files would attach every image and then have them
deleted straight back out, leaving the course imageless with no error to show
for it. The combined files already have this ordering baked in; it only matters
if you load the per-unit files by hand.

---

## What changes for students already using it

Grade 10 (MPM2D) is the only live course. Reloading it changes what those
students see:

- **Factoring Q21 becomes answerable.** It had a wrong key and *no correct
  option at all*, so every student who ever attempted it was marked wrong.
- About 60 feedback lines across the six units now name the mistake that
  actually produces the option the student picked, rather than a different one.
- 27 questions were retagged, so the tutor dashboard files them under the
  subtopic they actually test.
- **Option positions were rotated** so the answer sits at A, B, C and D equally
  often. This is what finally brings MPM2D through gate check 12.

That last one has a consequence you have already accepted, recorded here so it
is not rediscovered as a mystery. `attempts.chosen_index` stores the integer
position a student tapped, so a historical row saying `chosen_index = 2` now
points at a different option than it did at the time. Unaffected: their score,
`was_correct`, and the tutor dashboard's diagnosis of past work — all of those
were computed and stored at answer time, and `misconception_tag` is snapshotted
per attempt. Affected: any code that re-reads today's option list to display
which option a past attempt chose. Nothing currently does that.

Student accounts, rosters, classes, notes, subscriptions and every attempt row
survive untouched. Running the question files does not go near them.

The other five courses are new to the database; loading them costs nothing.

---

## Verifying afterwards

Against a scratch copy, never the live database:

```bash
# the thirteen-check gate, one unit at a time — every check prints zero rows
psql "$DB" -v course=MCR3U -v unit=Functions -f tools/check_questions.sql

# no question offers the same answer twice
python3 tools/check_distinct_options.py "$DB"

# a student picking the longest option scores at chance
python3 tools/check_option_lengths.py "$DB"

# the app's own suite — creates its own fixture users, so SCRATCH ONLY
psql -d scratch -f tests/test_ama.sql        # 212 checks
```

What the shipped bank scores:

| | |
|---|---|
| Units passing all thirteen checks | **40 / 40** |
| Longest-option guesser | 398 / 1600 = **24.9%** (chance 25.0%) |
| Distinct-option flags | 10, every one deliberate — the tool explains which |
| Figures attaching · ruler tests | 60 / 60 · 28 / 28 |
| App test suite | 212 / 212 |

A quick sanity check straight after loading, which needs no tooling:

```sql
select course_code, count(*) from questions group by 1 order by 1;
--  MCR3U 280 · MCV4U 240 · MDM4U 200 · MHF4U 280 · MPM2D 240 · MTH1W 360
select count(*) from questions where figure is not null;   -- 60
select * from list_courses();                              -- six rows
```

---

## One oddity in the courses table

The seed includes **MPM1D**, the pre-2021 Grade 9 academic course, which has no
question bank. It is harmless: `list_courses()` returns only courses that
actually have questions loaded, so MPM1D never reaches the signup screen. Delete
the row if you want the table tidy; nothing depends on it.
