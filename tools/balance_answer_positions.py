#!/usr/bin/env python3
"""
Balance which option letter holds the correct answer, across one unit file.

Why this exists
---------------
main.dart does not shuffle options, so whatever position the SQL file puts the
correct answer in is the position the student sees, every time. MCR3U Unit 1
shipped with the correct answer at option A in 39 of its 40 questions, which
teaches a student to tap A and move on. That is a leak: it lets a student score
without reading, and it poisons the first-try rate the tutor dashboard reports.

What it does
------------
Rotates each question option list so that, across the file, the correct answer
lands at A, B, C and D an equal number of times. Rotation is used rather than a
shuffle because it preserves the relative order of the options, so any list that
was written to read in a sensible sequence still does.

The target pattern is derived from a hash of the course and unit, so two units
never share the same sequence of answer positions, and re-running this tool on
the same file is a no-op.

Usage
-----
    python3 tools/balance_answer_positions.py <file.sql> [--check] [--write]

    --check   report the current distribution and exit non-zero if skewed
    --write   rewrite the file in place (default is to print a preview)
"""
import argparse
import hashlib
import json
import re
import sys
from collections import Counter

BLOCK = re.compile(
    r"\((?P<grade>\d+),\s*'(?P<course>[^']+)',\s*'(?P<unit>[^']+)',\s*"
    r"(?P<uorder>\d+),\s*(?P<sort>\d+),\s*'(?P<diff>[^']+)',",
    re.S,
)
OPTS = re.compile(r"'(?P<json>\[\s*\{.*?\}\s*\])'::jsonb,(?P<gap>\s*)(?P<idx>\d)(?=,)", re.S)


def target_positions(course, unit, n):
    """A balanced, deterministic permutation of 0-3 repeated to length n."""
    seed = int(hashlib.sha256(f"{course}|{unit}".encode()).hexdigest(), 16)
    pool = [i % 4 for i in range(n)]
    # Fisher-Yates driven by the seed: no randomness, same file same result.
    for i in range(len(pool) - 1, 0, -1):
        seed, j = divmod(seed, i + 1)
        pool[i], pool[j] = pool[j], pool[i]
    return pool


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("path")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()

    src = open(args.path, encoding="utf-8").read()

    heads = list(BLOCK.finditer(src))
    opts = list(OPTS.finditer(src))
    if not opts:
        sys.exit(f"{args.path}: no option blocks found")
    if len(heads) != len(opts):
        sys.exit(f"{args.path}: {len(heads)} question headers but {len(opts)} option blocks")

    course = heads[0].group("course")
    unit = heads[0].group("unit")
    before = Counter(int(m.group("idx")) for m in opts)

    if args.check:
        worst = max(before.values()) / len(opts)
        print(f"{args.path}: {course} / {unit}, {len(opts)} questions")
        for i in range(4):
            print(f"  option {'ABCD'[i]}: {before.get(i, 0)}")
        if worst > 0.40:
            print(f"  SKEWED: {worst:.0%} of answers sit in one position")
            return 1
        print("  balanced")
        return 0

    targets = target_positions(course, unit, len(opts))
    out, cursor, moved = [], 0, 0
    for m, want in zip(opts, targets):
        options = json.loads(m.group("json"))
        if len(options) != 4:
            sys.exit(f"{args.path}: a question has {len(options)} options")
        have = int(m.group("idx"))
        k = (want - have) % 4
        if k:
            options = options[-k:] + options[:-k]
            moved += 1
        body = ",\n   ".join(json.dumps(o, ensure_ascii=False) for o in options)
        out.append(src[cursor:m.start()])
        out.append(f"'[{body}]'::jsonb,{m.group('gap')}{want}")
        cursor = m.end()
    out.append(src[cursor:])
    result = "".join(out)

    after = Counter(targets)
    print(f"{args.path}: {course} / {unit}")
    print(f"  before  A={before.get(0,0)} B={before.get(1,0)} C={before.get(2,0)} D={before.get(3,0)}")
    print(f"  after   A={after[0]} B={after[1]} C={after[2]} D={after[3]}")
    print(f"  {moved} of {len(opts)} questions rotated")

    if args.write:
        open(args.path, "w", encoding="utf-8").write(result)
        print("  written")
    else:
        print("  (dry run, pass --write to apply)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
