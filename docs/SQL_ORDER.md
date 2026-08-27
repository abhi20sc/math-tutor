# The SQL files, and the order to run them

Two situations. **Yours is the first one** — read that and stop.

---

## A. Your live project (`frkswzowskeqmgdrrwab`)

**Two files to run, in any order.**

| # | File | Size | What it does |
|---|---|---|---|
| 1 | `supabase/migrations/test_review_answers.sql` | 6 KB | Widens `test_item_review` so the end-of-test review can show the answer |
| 2 | `supabase/migrations/learn_journey.sql` | 6 KB | Adds `solved` to `list_lessons`, which is what the Learn path gates on |

Each drops and recreates one function and touches no table, so no student
loses a row and neither depends on the other.

Read the header of the first before running it: it deliberately relaxes the
answers-never-reach-the-browser rule for a finished paper, and says what
that costs.

The second is safe to delay. Until it is run the Learn path draws but locks
nothing, which is exactly how Learn behaves today.

Everything else is applied. Checked on 24 August 2026: 1,600 questions,
60 figures, **219 lessons**, 92 functions, 8 accounts, 316 attempts, and two
practice tests taken. The schema, the whole question bank, `astro_sections.sql`
and all six lesson files are all in.

This section used to list seven files to run, in this order:

| # | File | Size | What it does |
|---|---|---|---|
| 1 | `supabase/migrations/astro_sections.sql` | 62 KB | 5 tables, 2 nullable columns, 25 functions |
| 2 | `supabase/migrations/lessons/lessons_mth1w.sql` | 149 KB | 50 lessons |
| 3 | `…/lessons_mpm2d.sql` | 76 KB | 29 lessons |
| 4 | `…/lessons_mcr3u.sql` | 140 KB | 38 lessons |
| 5 | `…/lessons_mhf4u.sql` | 144 KB | 36 lessons |
| 6 | `…/lessons_mcv4u.sql` | 136 KB | 36 lessons |
| 7 | `…/lessons_mdm4u.sql` | 132 KB | 30 lessons |

Step 1 has to come first, because it creates the `lessons` table the other six
write into. Files 2–7 are independent and can go in any order. The order is
kept here because it is the order to use again on any second project, and
because re-running any one of the six is how you would correct a lesson.

**Do NOT re-run the setup file or the question files.** They are already
applied. Re-running the setup would drop and rebuild `questions` for no
reason, and the question files would replace 1,600 rows with the same 1,600
rows. Neither is dangerous; both are pointless, and pointless steps against a
live database are how mistakes happen.

---

## B. From an empty Supabase project

Only if you are rebuilding from scratch, or setting up a second project to
test against.

| # | File | Size | Why here |
|---|---|---|---|
| 1 | `astro_math_assist_setup.sql` | 159 KB | Every table, policy, function, the avatar bucket, the admin drill-down. Nothing works before this. |
| 2 | `bundles/questions_all.sql` | 1.2 MB | 1,600 questions and 60 figures |
| 3 | `astro_sections.sql` | 62 KB | Learn / Improve / Test / preferences |
| 4–9 | the six `lessons/*.sql` | 76–149 KB | 219 lessons |
| 10 | `test_review_answers.sql` | 6 KB | The end-of-test review shows the answer |
| 11 | `learn_journey.sql` | 6 KB | The Learn path, and what it gates on |

**If the editor chokes on the 1.2 MB file at step 2**, use the six in
`bundles/by_course/` instead — same content, one course each, any order:

```
questions_grade09_mth1w.sql   360 questions   242 KB
questions_grade10_mpm2d.sql   240            156 KB
questions_grade11_mcr3u.sql   280            203 KB
questions_grade12_mhf4u.sql   280            211 KB
questions_grade12_mcv4u.sql   240            201 KB
questions_grade12_mdm4u.sql   200            176 KB
```

### One ordering rule that is easy to miss

Inside every question file the figure statements come **last**, and they have
to. Each unit's block opens with

```sql
delete from questions where course_code = '...' and unit = '...';
```

and that delete takes the figure reference with the row. A figure block that
ran first would attach 60 images and then have them deleted straight back
out, leaving the course imageless with no error to show for it. The combined
and per-course files already have this baked in; it only matters if you ever
load the per-unit files by hand.

---

## Grade 12 Calculus and Vectors, on its own

`bundles/by_course/questions_grade12_mcv4u.sql` — 201 KB, **240 questions, 6 units,
12 figures**, the most of any course, because vectors are the one topic where
the arrangement of the arrows *is* the question.

| Unit | Questions | Figures |
|---|---|---|
| Derivative Rules | 40 | 1 |
| Curve Sketching | 40 | 3 |
| Derivatives of Trig and Exponential Functions | 40 | — |
| Geometric Vectors | 40 | 4 |
| Algebraic Vectors | 40 | 3 |
| Lines and Planes | 40 | 1 |

Self-contained and safe to run on its own at any time — it deletes and
reloads only MCV4U. I loaded this exact file into a clean database before
sending it: 240 rows, 12 figures attached, no errors.

It also carries the fix for the bug that broke MDM4U: an apostrophe in a
comment header. Line 16 reads *"keeps the history of every student"*, and
there are zero apostrophes in any comment in the file. That mattered because
a stray quote inverts every string boundary after it, and the error surfaces
somewhere else entirely — in MDM4U's case 168 lines later, on the words
`into two`.

**Note the unit name for unit 3 is long** — `Derivatives of Trig and
Exponential Functions` — and has to be quoted exactly when running the gate
against it.

---

## After the last file, whichever route you took

```sql
select course_code, count(*) from questions group by 1 order by 1;
-- MCR3U 280 · MCV4U 240 · MDM4U 200 · MHF4U 280 · MPM2D 240 · MTH1W 360

select count(*) from questions where figure is not null;   -- 60
select count(*) from lessons;                              -- 219
select * from list_courses();                              -- six rows

-- the one that matters: no subtopic without a lesson
select count(*) from (
  select distinct course_code, misconception_tag from questions
  where misconception_tag is not null) q
left join lessons l
  on l.course_code = q.course_code and l.tag = q.misconception_tag
where l.id is null;                                        -- 0
```

---

## Files that must never be run again

`avatars.sql` and `admin_teacher_students.sql` are both folded into
`astro_math_assist_setup.sql`. **`admin_teacher_students.sql` now fails
outright** against a current database:

```
ERROR: cannot change return type of existing function
```

because the copy inside the setup file returns more columns than the old
standalone one. Both are kept only for a database that predates the merge, and
both now sit in `supabase/migrations/_superseded/` alongside
`supabase_full_setup.sql`, which the current setup file replaced.
