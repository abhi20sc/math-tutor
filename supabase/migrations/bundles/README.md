# Generated bundles

Nothing in here is a source file. Every byte is a concatenation of files that
live one directory up, kept because the Supabase SQL editor is happier with a
few large pastes than with forty small ones.

| File | Same as |
|---|---|
| `questions_all.sql` | all 40 files under `../questions/`, in load order |
| `lessons_all.sql` | all 6 files under `../lessons/` |
| `by_course/questions_grade*.sql` | one course's slice of `../questions/` |

If a question changes, change it in `../questions/` and regenerate these.
Editing a bundle directly means the next regeneration silently reverts you.

**Ordering, which is baked into these files and matters:** each unit block
opens with `delete from questions where course_code = ... and unit = ...`, and
that delete takes the figure reference with it. So every course's figure
statements must come after all of its question statements. Get it backwards
and the images attach, then vanish, with no error.
