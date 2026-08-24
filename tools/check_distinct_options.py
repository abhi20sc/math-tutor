#!/usr/bin/env python3
"""Distractor-uniqueness check: does any question offer the same answer twice?

The thirteen-check gate in tools/check_questions.sql catches a lot, but not
this. The August 2026 audit found thirteen questions whose four options were
really three — the same value or the same expression wearing different clothes:

    (x - 7)(x - 7)   and   (x - 7)²
    5/6              and   10/12
    3^16             and   9^8
    -(√6 - √2)/4     and   (√2 - √6)/4
    (200 - 2x)/2     and   100 - x

None of those trips a text comparison, because the strings differ. All of them
waste a distractor slot, and one of them made a question unanswerable.

    python3 tools/check_distinct_options.py <database>

Prints one block per question where two options evaluate equal, and exits 1 if
any survive. Requires sympy.

## It is deliberately noisy

A flag is a thing to READ, not a verdict. Two options being equal in value is
correct by design in at least three places in this bank:

  * "Factor completely" items, where the distractors are valid but INCOMPLETE
    factorings of the same polynomial — that is the entire question.
  * "Which is written correctly in scientific notation?", where every option is
    the same number and only the form differs.
  * Any item where the question is about FORM rather than value.

Everywhere else, two equal options is a defect. On the bank as it stands the
check flags ten questions and every one of them is one of the cases above:
nine "factor completely" items in MPM2D Factoring, and the scientific-notation
item at MTH1W Powers Q3.

## What it cannot see

Options it cannot parse into an expression — sentences, direction bearings,
vector names like AB — are skipped rather than guessed at. Conceptual units
(MDM4U Collecting Data, most of Displays of Data) are therefore barely covered
by this, and still need reading.
"""

import re
import subprocess
import sys

try:
    import sympy as sp
    from sympy.parsing.sympy_parser import (
        parse_expr, standard_transformations,
        implicit_multiplication_application, convert_xor)
except ImportError:
    sys.exit('needs sympy:  pip3 install sympy')

TR = (standard_transformations
      + (implicit_multiplication_application, convert_xor))

SUPMAP = {'⁰': '0', '¹': '1', '²': '2', '³': '3', '⁴': '4', '⁵': '5',
          '⁶': '6', '⁷': '7', '⁸': '8', '⁹': '9', '⁻': '-'}
SUPRE = re.compile('[' + ''.join(SUPMAP) + ']+')
SUBRE = re.compile('[₀₁₂₃₄₅₆₇₈₉]+')

# Whole words are safe to strip anywhere. Single letters only when glued to a
# number, because m, s, g, N, J, W and L are all variables somewhere here.
UNITWORD = re.compile(
    r'\b(cm|mm|km|kg|mL|hrs?|mins?|secs?|degrees|deg|units?|sides?|'
    r'solutions?|roots?|years?|dollars?|percent|radians?|square|cubic)\b', re.I)
# 'h' is deliberately NOT here: across MHF4U and MCV4U it is the increment in a
# Newton quotient far more often than it is an hour, and stripping it collapses
# 2a + h - 3 onto 2a - 3.
UNITCHAR = re.compile(r'(?<=\d)\s*(m|s|g|N|J|W|L|%)\b')

# sympy pre-defines S, E, N, O and I. An option like 'S30E' (a quadrant bearing)
# or 'BA' (a vector name) parses into those objects and compares nonsensically,
# so anything that looks like a bare letter-code is refused outright.
LETTERCODE = re.compile(r'^[A-Za-z]{1,2}\d*[A-Za-z]{0,2}$')


def canon(text):
    """Turn one option into a sympy expression, or None if it is not safely
    comparable. Returning None is always the right answer when in doubt: a
    missed pair costs a manual read, a wrong parse costs a false alarm."""
    s = text.strip()
    if not s:
        return None
    s = SUPRE.sub(lambda m: '**(' + ''.join(SUPMAP[c] for c in m.group()) + ')', s)
    s = SUBRE.sub('', s)
    s = (s.replace('−', '-').replace('–', '-').replace('×', '*')
          .replace('·', '*').replace('π', 'pi').replace('θ', 'theta')
          .replace('°', '').replace('√', 'sqrt').replace('$', ''))
    s = re.sub(r'(?<=\d),(?=\d\d\d)', '', s)        # 10,000 -> 10000
    s = re.sub(r'(?<=\d) (?=\d\d\d\b)', '', s)      # 10 000 -> 10000
    s = UNITWORD.sub(' ', s)
    s = UNITCHAR.sub(' ', s)
    s = re.sub(r'\bsqrt\s*(\d+)', r'sqrt(\1)', s)
    s = re.sub(r'(?<![.\d])0+(?=\d)', '', s)        # 077 -> 77, leaves 0.058
    s = s.strip(' .')
    if not s or len(s) > 80:
        return None
    probe = re.sub(r'sqrt|theta|sin|cos|tan|log|ln|exp|pi', '', s)
    if re.search(r'[A-Za-z]{3,}', probe):           # prose
        return None
    if LETTERCODE.match(s.replace(' ', '')):        # AB, BA, S30E, N30E
        return None
    try:
        e = parse_expr(s, transformations=TR, evaluate=True)
    except Exception:
        return None
    if not isinstance(e, sp.Basic) or len(e.free_symbols) > 3:
        return None
    return e


def equal(a, b):
    try:
        d = sp.simplify(sp.expand(a - b))
        if d == 0:
            return True
        if d.is_number:
            return abs(complex(d)) < 1e-12
    except Exception:
        pass
    return False


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__.strip().split('\n\n')[0] +
                 '\n\n  usage: python3 tools/check_distinct_options.py <database>')
    db = sys.argv[1]
    import json
    sql = ("select coalesce(json_agg(row_to_json(t))::text, '[]') from ("
           "select course_code, unit, sort_order, prompt, options, correct_index "
           "from questions order by 1, 2, 3) t")
    raw = subprocess.run(['psql', '-d', db, '-tAc', sql],
                         capture_output=True, text=True)
    if raw.returncode:
        sys.exit(raw.stderr.strip())
    rows = json.loads(raw.stdout)

    flagged = {}
    for q in rows:
        opts = [o['text'] for o in q['options']]
        vals = [canon(t) for t in opts]
        for i in range(4):
            for j in range(i + 1, 4):
                if vals[i] is None or vals[j] is None:
                    continue
                if opts[i].strip() == opts[j].strip():
                    continue
                if equal(vals[i], vals[j]):
                    flagged.setdefault(
                        (q['course_code'], q['unit'], q['sort_order'],
                         q['prompt'], q['correct_index']), []).append((i, j))

    print('scanned %d questions' % len(rows))
    if not flagged:
        print('no question offers the same answer twice')
        return 0

    print('%d questions offer the same value in two options:\n' % len(flagged))
    for (course, unit, so, prompt, ci), pairs in flagged.items():
        print('%s / %s / Q%d   key = option %d' % (course, unit, so, ci))
        print('   %s' % prompt.replace('\n', ' ')[:100])
        q = next(x for x in rows if (x['course_code'], x['unit'],
                                     x['sort_order']) == (course, unit, so))
        for i, j in pairs:
            key = '   <-- one of them is the KEY' if ci in (i, j) else ''
            print('   option %d  %-32s == option %d  %s%s'
                  % (i, q['options'][i]['text'], j, q['options'][j]['text'], key))
        print()
    print('Read each one. Equal options are correct by design where the question '
          'is about FORM\nrather than value — "factor completely", "written '
          'correctly in scientific notation".\nEverywhere else this is a defect.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
