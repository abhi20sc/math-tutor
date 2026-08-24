#!/usr/bin/env python3
"""Import topicmindmap's Grade 9 and 10 lessons into our lessons table.

TWO PROBLEMS TO SOLVE, AND THE CHOICES MADE

1. HIS STRANDS ARE NOT OUR UNITS.
   He groups Grade 10 into three Ministry strands; our bank has six units and
   twenty-eight misconception tags. A lesson has to land on a TAG, because
   that is what the Improve section and the test breakdown link back to. The
   mapping below is done by hand, once, and reviewed — there is no clever
   automatic way to decide that "Angle of Elevation & Depression" teaches
   sub-trig-side-lengths.

   A few of his lessons teach a Grade 9 tag even though they sit in his Grade
   10 file (Pythagoras, Number of Solutions, Slope and Equation of a Line).
   Those are filed under MTH1W, where the questions that need them live.

2. HIS BODIES ARE HTML-IN-MARKDOWN.
   The content is markdown, but the diagrams are raw inline <svg> and the
   interactive graphs are <div class="desmos-embed" data-desmos-url="...">.
   Flutter's markdown renderer draws neither.

   So each is rewritten at import time into an explicit fenced block that a
   fifteen-line Dart splitter can handle:

       :::svg
       <svg ...>...</svg>
       :::caption A parabola's vertex, zeros and axis of symmetry.
       :::

       :::desmos https://www.desmos.com/calculator/tmanhslyfn
       :::

   The SVG keeps its var(--accent) colour tokens rather than having hex
   values baked in. Dart substitutes the current theme's colours before
   handing the string to flutter_svg, so the diagrams follow dark mode
   instead of glowing white on a dark page.
"""

import json, os, re, sys

SRC = "/home/claude/topicmindmap/assets/data"
OUT = os.path.dirname(os.path.abspath(__file__))

# (his id) -> (our course, our unit, our misconception tag)
MAP = {
    # ---- MPM2D ------------------------------------------------------------
    "a1":  ("MPM2D", "Quadratics",                  "sub-properties-of-quadratics"),
    "a2":  ("MPM2D", "Quadratics",                  "sub-vertex-form"),
    "a3":  ("MPM2D", "Factoring",                   "sub-multiplying-binomials"),
    "a4":  ("MPM2D", "Factoring",                   "sub-common-factoring"),
    "a5":  ("MPM2D", "Solving quadratic equations", "sub-solving-by-factoring"),
    "a6":  ("MPM2D", "Quadratics",                  "sub-completing-the-square"),
    "a7":  ("MPM2D", "Solving quadratic equations", "sub-quadratic-formula"),
    "a8":  ("MPM2D", "Solving quadratic equations", "sub-quadratic-applications"),
    "a9":  ("MPM2D", "Quadratics",                  "sub-factored-form"),
    "b1":  ("MPM2D", "Linear systems",              "sub-elimination"),
    "b2":  ("MPM2D", "Linear systems",              "sub-substitution"),
    "b3":  ("MPM2D", "Linear systems",              "sub-solving-by-graphing"),
    "b4":  ("MPM2D", "Analytic geometry",           "sub-midpoint-length"),
    "b5":  ("MPM2D", "Analytic geometry",           "sub-equation-of-circle"),
    "b6":  ("MPM2D", "Analytic geometry",           "sub-median-bisector-altitude"),
    "b7":  ("MPM2D", "Analytic geometry",           "sub-geometry-applications"),
    "b9":  ("MPM2D", "Linear systems",              "sub-linear-applications"),
    "b11": ("MPM2D", "Analytic geometry",           "sub-geometry-applications"),
    "c1":  ("MPM2D", "Trigonometry",                "sub-similar-triangles"),
    "c2":  ("MPM2D", "Trigonometry",                "sub-trig-ratios"),
    "c4":  ("MPM2D", "Trigonometry",                "sub-sine-law"),
    "c5":  ("MPM2D", "Trigonometry",                "sub-cosine-law"),
    "c6":  ("MPM2D", "Trigonometry",                "sub-trig-side-lengths"),
    "c7":  ("MPM2D", "Trigonometry",                "sub-trig-angles"),
    # These three sit in his Grade 10 file but teach Grade 9 tags.
    "b8":  ("MTH1W", "Linear relations part 2",     "sub-solution-count"),
    "b10": ("MTH1W", "Linear relations part 1",     "sub-line-from-points"),
    "c3":  ("MTH1W", "Geometry",                    "sub-pythagoras"),
    # ---- MTH1W ------------------------------------------------------------
    "g9-ns1":  ("MTH1W", "Number sense",           "sub-integers"),
    "g9-ns2":  ("MTH1W", "Number sense",           "sub-integers"),
    "g9-ns3":  ("MTH1W", "Powers",                 "sub-exponent-laws"),
    "g9-ns4":  ("MTH1W", "Number sense",           "sub-fractions"),
    "g9-ns5":  ("MTH1W", "Number sense",           "sub-ratios-rates"),
    "g9-alg1": ("MTH1W", "Algebraic expressions",  "sub-like-terms"),
    "g9-alg2": ("MTH1W", "Algebraic expressions",  "sub-distributive"),
    "g9-alg3": ("MTH1W", "Algebraic expressions",  "sub-algebra-terms"),
    "g9-alg4": ("MTH1W", "Solving equations",      "sub-solve-linear"),
    "g9-alg5": ("MTH1W", "Solving equations",      "sub-equations-fractions"),
    "g9-lin1": ("MTH1W", "Linear relations part 1", "sub-slope"),
    "g9-lin2": ("MTH1W", "Linear relations part 1", "sub-slope-intercept"),
    "g9-lin3": ("MTH1W", "Linear relations part 1", "sub-standard-form"),
    "g9-lin4": ("MTH1W", "Linear relations part 1", "sub-plotting-points"),
    "g9-lin5": ("MTH1W", "Linear relations part 1", "sub-linear-nonlinear"),
    "g9-geo1": ("MTH1W", "Geometry",               "sub-composite-shapes"),
    "g9-geo2": ("MTH1W", "Geometry",               "sub-composite-shapes"),
    "g9-geo3": ("MTH1W", "Geometry",               "sub-3d-geometry"),
    "g9-geo4": ("MTH1W", "Geometry",               "sub-angle-relationships"),
    "g9-dfl1": ("MTH1W", "Data",                   "sub-central-tendency"),
    "g9-dfl2": ("MTH1W", "Data",                   "sub-spread"),
    "g9-dfl3": ("MTH1W", "Data",                   "sub-scatterplots"),
    "g9-dfl4": ("MTH1W", "Financial literacy",     "sub-simple-interest"),
    "g9-dfl5": ("MTH1W", "Financial literacy",     "sub-budgeting"),
}


def rewrite_diagrams(body: str) -> str:
    """<div class="diagram">…<svg/>…caption…</div>  ->  :::svg fenced block."""
    def one(m):
        inner = m.group(1)
        svg = re.search(r"(<svg\b.*?</svg>)", inner, re.S)
        if not svg:
            return ""
        cap = re.search(r'<div class="diagram-caption">(.*?)</div>', inner, re.S)
        out = [":::svg", svg.group(1).strip()]
        if cap:
            out.append(":::caption " + re.sub(r"\s+", " ", cap.group(1)).strip())
        out.append(":::")
        return "\n" + "\n".join(out) + "\n"
    return re.sub(r'<div class="diagram">(.*?)</div>\s*</div>', one, body, flags=re.S)


def rewrite_desmos(body: str) -> str:
    """The interactive-graph card -> :::desmos <url>."""
    def one(m):
        url = m.group(1).replace("?embed", "")
        return "\n:::desmos " + url + "\n:::\n"
    body = re.sub(r'<div class="desmos-card">.*?data-desmos-url="([^"]+)".*?</button>\s*</div>\s*</div>',
                  one, body, flags=re.S)
    # Any card whose markup did not match the shape above is dropped rather
    # than left as raw HTML in the middle of a lesson.
    return re.sub(r'<div class="desmos-card">.*?</button>\s*</div>\s*</div>', "",
                  body, flags=re.S)


def clean(body: str) -> str:
    body = rewrite_diagrams(body)
    body = rewrite_desmos(body)
    body = re.sub(r"&mdash;", "—", body)
    body = re.sub(r"&amp;", "&", body)
    body = re.sub(r"\n{3,}", "\n\n", body)
    # Anything still carrying a raw div is a shape this importer did not know
    # about; fail loudly rather than shipping HTML into a markdown renderer.
    leftover = re.findall(r"<div\b", body)
    return body.strip(), len(leftover)


def authored():
    """Lessons written to fill the gaps his set does not cover.

    Same shape, same house style, same checks — they arrive as JSON so that
    the SQL is generated by one code path rather than two."""
    import glob
    out = []
    for fn in sorted(glob.glob(os.path.join(OUT, "authored", "*.json"))):
        for o in json.load(open(fn)):
            out.append(dict(
                src_id=os.path.basename(fn)[:-5] + ":" + o["tag"],
                course=o["course"], unit=o["unit"], tag=o["tag"],
                title=o["title"].strip(),
                summary=re.sub(r"\s+", " ", o["summary"]).strip(),
                minutes=max(1, min(30, int(o.get("minutes") or 2))),
                body=o["body"].strip(),
                video_title=None, video_url=None, video_source=None))
    return out


# ---------------------------------------------------------------------------
# PATCHES TO THE IMPORTED SOURCE
#
# His lesson a1 is the first thing a Grade 10 student reads and the only one
# of the 219 with no Common Mistakes section. That section is not decoration:
# it is the half of a lesson that ties it to the question bank, because every
# distractor in the bank IS a named mistake and the lesson is where the
# student meets that mistake first.
#
# The bullets below are not invented. They are the mistakes the distractors
# for sub-properties-of-quadratics actually encode, read back out of the
# feedback lines on those questions — so the lesson warns about exactly what
# the questions will catch.
#
# Patched here rather than edited in the database, because the database is
# rebuilt from this script: an UPDATE would survive until the next reload of
# that course and then vanish, which is the worst kind of fix.
# ---------------------------------------------------------------------------
PATCHES = {
    "a1": {
        "before": "## Quick Gut-Check",
        "insert": """## Common Mistakes

- **Taking second differences from the wrong pair.** They come from
  subtracting *neighbouring* first differences: if the first differences run
  3, 5, 7, the second differences are `5 - 3` and `7 - 5`, both 2.
- **Reading the second difference as `a`.** A constant second difference
  equals **2a**, so a second difference of -6 means `a = -3`, not -6.
- **Letting `b` decide which way it opens.** Only the sign of `a` does that.
  `b` shifts the curve sideways, and the number of terms tells you nothing
  at all.
- **Confusing the y-intercept with the coefficient of x.** The y-intercept is
  the value when `x = 0`, which leaves only the constant on its own.
- **Thinking a bigger `a` means a wider curve.** Values bigger than 1 stretch
  it upward and pull it *narrower*. Wider comes from an `a` between 0 and 1.

""",
    },
}


def apply_patch(lid, body):
    p = PATCHES.get(lid)
    if not p or p["insert"].strip().split("\n")[0] in body:
        return body
    if p["before"] not in body:
        raise SystemExit("patch anchor missing in %s" % lid)
    return body.replace(p["before"], p["insert"] + p["before"], 1)


def collect():
    rows, problems = [], []
    for fn in ("mth1w_topics_mindmap.json", "mpm2d_topics_mindmap.json"):
        doc = json.load(open(os.path.join(SRC, fn)))
        for strand in doc.get("children", []):
            for les in strand.get("children", []):
                lid = les.get("id")
                if lid not in MAP:
                    problems.append(("unmapped", lid, les.get("title")))
                    continue
                course, unit, tag = MAP[lid]
                body, leftover = clean(les.get("content", ""))
                body = apply_patch(lid, body)
                if leftover:
                    problems.append(("raw-html", lid, "%d divs left" % leftover))
                rows.append(dict(
                    src_id=lid, course=course, unit=unit, tag=tag,
                    title=les["title"].strip(),
                    summary=re.sub(r"\s+", " ", les.get("summary", "")).strip(),
                    minutes=max(1, min(30, int(les.get("estimatedReadMinutes") or 2))),
                    body=body,
                    video_title=les.get("videoTitle"),
                    video_url=les.get("videoUrl"),
                    video_source=les.get("videoSource"),
                ))
    rows.extend(authored())
    return rows, problems


DIAGRAM_RE = re.compile(r"^:::svg$\n(.*?)\n:::caption (.*?)\n:::$",
                        re.S | re.M)
DIAGRAM_NOCAP_RE = re.compile(r"^:::svg$\n(.*?)\n:::$", re.S | re.M)


def extract_diagrams(rows):
    """Pull every inline SVG out into a manifest and leave a PNG reference.

    Flutter draws no SVG without a package, and this app has deliberately
    avoided packages. It already knows how to show a picture beside a
    question — a PNG under web/figures, drawn with Image.network — so lesson
    diagrams take the same road. tools/render_diagrams.py turns this manifest
    into a light and a dark PNG for each one; Dart picks by brightness,
    because the source colours are theme tokens, not fixed hex.
    """
    manifest, seen = [], {}
    for r in rows:
        def swap(m, cap=True):
            svg = m.group(1).strip()
            caption = m.group(2).strip() if cap else ""
            base = "%s_%s" % (r["course"].lower(),
                              (r["tag"] or r["title"]).replace("sub-", ""))
            base = re.sub(r"[^a-z0-9]+", "-", base.lower()).strip("-")
            seen[base] = seen.get(base, -1) + 1
            name = "%s_%d" % (base, seen[base])
            manifest.append({"name": name, "svg": svg, "course": r["course"],
                             "tag": r["tag"], "caption": caption})
            out = ":::img " + name
            if caption:
                out += "\n:::caption " + caption
            return out + "\n:::"
        r["body"] = DIAGRAM_RE.sub(swap, r["body"])
        r["body"] = DIAGRAM_NOCAP_RE.sub(lambda m: swap(m, cap=False), r["body"])
    return manifest


def sql_literal(v):
    if v is None or v == "":
        return "null"
    return "$AMA$" + v + "$AMA$"


def main():
    rows, problems = collect()
    for kind, lid, detail in problems:
        print("  !! %-9s %-9s %s" % (kind, lid, detail), file=sys.stderr)

    manifest = extract_diagrams(rows)
    with open(os.path.join(OUT, "diagrams.json"), "w") as fh:
        json.dump(manifest, fh, indent=1)

    # sort_order is per (course, unit): the order a student should read them.
    order = {}
    lines = []
    for r in sorted(rows, key=lambda r: (r["course"], r["unit"], r["src_id"])):
        key = (r["course"], r["unit"])
        order[key] = order.get(key, 0) + 1
        r["sort"] = order[key]
        if "$AMA$" in r["body"]:
            raise SystemExit("dollar-quote delimiter appears in a body: " + r["src_id"])
        lines.append(
            "(%s, %s, %s, %d, %s, %s, %d, %s, %s, %s, %s)" % (
                sql_literal(r["course"]), sql_literal(r["unit"]),
                sql_literal(r["tag"]), r["sort"],
                sql_literal(r["title"]), sql_literal(r["summary"]),
                r["minutes"], sql_literal(r["body"]),
                sql_literal(r["video_title"]), sql_literal(r["video_url"]),
                sql_literal(r["video_source"])))

    header = """-- ===========================================================================
-- LESSONS — all six courses, Grades 9 to 12
-- ===========================================================================
--
-- GENERATED by tools/import_lessons.py. Two sources, one code path:
--   * Dileep Kumar's topicmindmap repository, remapped onto our units and
--     misconception tags (the MAP table in that script)
--   * lessons authored here to cover the subtopics his set does not reach
-- Edit the script and its sources, never this file.
--
-- %d lessons. Every one is keyed to a misconception tag from our own question
-- bank, so the Improve section and a finished test can both link a weak
-- subtopic to the lesson that covers it. Every subtopic in the bank has one:
-- a student can never be told to revise something with nothing to read.
--
-- Bodies are markdown with two extensions, both produced by the importer:
--
--   :::img <name>     a diagram. Two PNGs exist per name, <name>_light.png
--   :::caption …      and <name>_dark.png, under web/figures/lessons/;
--   :::               Dart picks by Theme.of(context).brightness. Generated
--                     from inline SVG by tools/render_diagrams.py, which
--                     substitutes the theme palette for the colour tokens.
--
--   :::desmos <url>   an interactive graph, opened in a browser tab.
--   :::
--
-- Safe to re-run: the delete below clears the table and rebuilds it whole.
-- ===========================================================================

delete from lessons where true;

insert into lessons (course_code, unit, tag, sort_order, title, summary,
                     read_minutes, body, video_title, video_url, video_source)
values
""" % len(rows)

    out = os.path.join(OUT, "lessons_all.sql")
    with open(out, "w") as fh:
        fh.write(header + ",\n".join(lines) + ";\n")

    print("%d lessons -> %s (%.1f KB)" % (len(rows), out, os.path.getsize(out) / 1024))
    from collections import Counter
    for c, n in sorted(Counter((r["course"], r["unit"]) for r in rows).items()):
        print("   %-7s %-28s %d" % (c[0], c[1], n))
    svg = sum(r["body"].count(":::img") for r in rows)
    des = sum(r["body"].count(":::desmos") for r in rows)
    vid = sum(1 for r in rows if r["video_url"])
    print("   diagrams %d · desmos %d · videos %d" % (svg, des, vid))


if __name__ == "__main__":
    main()
