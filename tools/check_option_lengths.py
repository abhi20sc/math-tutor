#!/usr/bin/env python3
"""Length-tell check: can a student score by picking the longest option?

    python3 tools/check_option_lengths.py <database> [course] [unit]

## The statistic that matters

Not "how often is the correct option the longest" — that number is inflated by
ties, and a tie is not exploitable, because the student still has to guess
between the options that tie. The number that matters is what a student who
knows no mathematics actually scores by always picking the longest option and
breaking ties at random:

    score = sum over questions of  1/(number of options tying for longest)
            counted only when the correct option is one of them

On four options that comes to 10 out of 40 per unit by chance, whatever the
option lengths happen to be. A unit at 14 is handing away a mark in ten.

The same is computed for a student who always picks the SHORTEST option, so
that over-correcting one way does not quietly open the other.

## Thresholds

    warn   above 13.0 or below 7.0 out of 40, either direction
    fail   above 15.0 or below 5.0

A unit exactly at 10.0 is not the goal and chasing it is a waste of effort;
what matters is that neither extreme is worth a student's while.

## History

The August 2026 audit measured the whole bank at 453 out of 1600 for the
longest-option guesser, against a chance baseline of 400 — a real but modest
edge, concentrated in about fifteen units. MDM4U Displays of Data was the worst
at 21 out of 40. An earlier read of this same data reported the edge as roughly
50 per cent; that was wrong, because it counted ties as wins.
"""

import json
import subprocess
import sys
from collections import OrderedDict

WARN_HI, FAIL_HI = 13.0, 15.0
WARN_LO, FAIL_LO = 7.0, 5.0


def guesser(questions, pick_longest=True):
    """Expected score for a student who always picks the longest (or shortest)
    option and breaks ties uniformly at random."""
    total = 0.0
    for q in questions:
        lengths = [len(o['text']) for o in q['options']]
        target = max(lengths) if pick_longest else min(lengths)
        winners = [i for i, n in enumerate(lengths) if n == target]
        if q['correct_index'] in winners:
            total += 1.0 / len(winners)
    return total


def main():
    if len(sys.argv) < 2:
        sys.exit('usage: python3 tools/check_option_lengths.py <database> '
                 '[course] [unit]')
    db = sys.argv[1]
    where = ''
    if len(sys.argv) > 2:
        where += " where course_code = '%s'" % sys.argv[2].replace("'", "''")
        if len(sys.argv) > 3:
            where += " and unit = '%s'" % sys.argv[3].replace("'", "''")
    sql = ("select coalesce(json_agg(row_to_json(t))::text, '[]') from ("
           "select course_code, unit, sort_order, options, correct_index "
           "from questions%s order by 1, 2, 3) t" % where)
    raw = subprocess.run(['psql', '-d', db, '-tAc', sql],
                         capture_output=True, text=True)
    if raw.returncode:
        sys.exit(raw.stderr.strip())
    rows = json.loads(raw.stdout)
    if not rows:
        sys.exit('no questions matched')

    units = OrderedDict()
    for q in rows:
        units.setdefault((q['course_code'], q['unit']), []).append(q)

    print('%-8s %-44s %9s %9s  %s'
          % ('COURSE', 'UNIT', 'LONGEST', 'SHORTEST', 'verdict'))
    fails = warns = 0
    tl = ts = 0.0
    for (course, unit), qs in units.items():
        n = len(qs)
        lo = guesser(qs, True) * 40.0 / n
        sh = guesser(qs, False) * 40.0 / n
        tl += guesser(qs, True)
        ts += guesser(qs, False)
        bad = max(lo, sh) >= FAIL_HI or min(lo, sh) <= FAIL_LO
        soft = max(lo, sh) >= WARN_HI or min(lo, sh) <= WARN_LO
        verdict = 'FAIL' if bad else ('warn' if soft else '')
        fails += bad
        warns += soft and not bad
        print('%-8s %-44s %6.1f/40 %6.1f/40  %s'
              % (course, unit, lo, sh, verdict))

    total = len(rows)
    print()
    print('longest-option guesser : %.1f / %d = %.1f%%  (chance %.1f%%)'
          % (tl, total, 100 * tl / total, 25.0))
    print('shortest-option guesser: %.1f / %d = %.1f%%'
          % (ts, total, 100 * ts / total))
    print()
    if fails:
        print('%d unit(s) FAIL, %d warn.' % (fails, warns))
        print('Fix by rephrasing option TEXT only — never by changing a value, '
              'moving an option,\nor touching correct_index. Usually the '
              'cheapest move is to give a distractor the\nsame level of detail '
              'the correct option already has, rather than to cut the answer '
              'short.')
        return 1
    print('no unit fails; %d warn.' % warns)
    return 0


if __name__ == '__main__':
    sys.exit(main())
