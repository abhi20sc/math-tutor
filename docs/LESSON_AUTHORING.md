# Writing a lesson for Astro Math Assist

You are finishing a Grade 9 / Grade 10 Ontario maths lesson set. Twenty-eight
subtopics in our question bank have no lesson yet. Yours are listed in your
prompt. Match the house style exactly — a reader must not be able to tell
which lessons were written by whom.

## Read first

- `/home/claude/lessons/STYLE_EXAMPLE.md` — one complete lesson, verbatim.
  This is the target. Read it before writing a word.
- `/home/claude/lessons/gaps.txt` — every remaining subtopic, pipe-separated:
  `course|unit|tag|label`.

## The shape of a lesson

Two minutes of reading. Not a textbook section. Sections, in this order:

1. `# Title` — the lesson's own H1, matching the title field.
2. `## The Idea` — the concept in plain words, opening with something
   physical or familiar where one exists. The exemplar opens by throwing a
   basketball.
3. The method — one or two `##` sections. Rules as bullets, formulas in
   fenced code blocks.
4. `## Worked Example` — one, fully worked, every line shown.
5. `## Common Mistakes` — **the most important section.** See below.
6. `## Quick Gut-Check` — one or two sentences a student can carry into the
   test.

## Common Mistakes is not filler

Our question bank is built on the principle that **wrong answers are the
product**: every distractor is the answer produced by one specific named
mistake, and the feedback names that mistake. Your Common Mistakes section is
the other half of that. Each bullet must describe a mistake a real student
makes, concretely enough that a student recognises themselves in it.

Write from the misconception tag you were given. `sub-negative-exponents`
means students think `2⁻³` is `-8`; say so.

Bad:  "Be careful with signs."
Good: "Applying a negative exponent to the sign instead of the base:
       `2⁻³` is `1/8`, not `-8`. The exponent never changes whether the
       answer is positive or negative."

## Diagrams

Include one **only where the picture carries information the words cannot**.
A parabola with its vertex and zeros labelled earns its place; a picture of
the words "like terms" does not. Roughly half the lessons should have one.

Format, exactly:

    :::svg
    <svg viewBox="0 0 320 210" role="img" aria-label="...">...</svg>
    :::caption One sentence saying what the picture shows.
    :::

Rules for the SVG:
- Hand-authored, no external references, no `<image>`, no fonts beyond
  `font-family="ui-monospace,SFMono-Regular,Menlo,Consolas,monospace"`.
- **Colours must be these tokens and nothing else** — the app substitutes the
  theme's palette at render time, and a hard-coded hex glows white in dark
  mode: `var(--accent)`, `var(--accent-2)`, `var(--code-accent)`,
  `var(--text)`, `var(--text-2)`, `var(--border)`.
- Always set `role="img"` and a real `aria-label`. A blind student gets the
  label; make it describe the content, not the shape.
- Keep it under about 40 elements. This is an illustration, not a plot.
- No `<animate>` unless the motion is the explanation.

## What you must NOT do

- **No answers to our questions.** You have not seen the question bank and you
  should not try to. Teach the method; do not work through a problem that
  might be one of ours.
- No links, no images, no HTML other than the `:::svg` block.
- No dollar signs in a run of two (`$$`) — the loader dollar-quotes bodies.
- No emoji.
- Do not exceed 3 minutes of reading. If it takes longer, the lesson is doing
  the job of two lessons.

## Output

Write ONE JSON file to `/home/claude/lessons/authored/<your-batch>.json`,
an array of objects, one per subtopic you were given:

```json
[{"course": "MTH1W",
  "unit": "Powers",
  "tag": "sub-negative-exponents",
  "title": "Negative Exponents",
  "summary": "One sentence, plain, that could sit under the title in a list.",
  "minutes": 2,
  "body": "# Negative Exponents\n\n## The Idea\n..."}]
```

`body` is the full markdown. Use real newlines in the JSON string (`\n`).
Validate the file parses with `python3 -c "import json;json.load(open(F))"`
before you finish, and confirm every tag you were given appears exactly once.
