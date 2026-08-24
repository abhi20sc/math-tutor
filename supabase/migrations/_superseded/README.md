# Superseded — do not run these

Kept only so that a database created before August 2026 can still be
understood. Against a current database they range from pointless to broken.

| File | Why it's here |
|---|---|
| `supabase_full_setup.sql` | Replaced by `../astro_math_assist_setup.sql`, which folds in the wiring fixes, the avatar bucket and the admin drill-down. |
| `avatars.sql` | Folded into the setup file. |
| `admin_teacher_students.sql` | Folded into the setup file. Running it now **fails outright** with `cannot change return type of existing function`, because the copy in the setup file returns more columns than this one. |
| `questions_sample.sql` | An early sample bank, long since replaced by the real 1,600. |

The current install path is in `docs/SQL_ORDER.md`.
