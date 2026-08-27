"""Contrast checker for the Astro STEM Labs palette.

Run:  python3 tools/check_contrast.py

Keep the values here in step with AstroPalette in lib/main.dart. This is
what the palette was derived with rather than a report written after the
fact, so a colour that has to change should change here first.

The existing palette in main.dart documents measured ratios for every colour
it carries. Anything replacing it has to be held to the same standard, so
this computes WCAG 2.1 relative-luminance contrast rather than eyeballing.

Floors used below:
  4.5  normal text
  3.0  large text (>=18.66px bold or >=24px) and non-text UI (borders, fills
       that carry meaning, focus rings)
"""

def srgb(c):
    c = c / 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def lum(hexstr):
    h = hexstr.lstrip('#')
    r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4))
    return 0.2126 * srgb(r) + 0.7152 * srgb(g) + 0.0722 * srgb(b)


def ratio(a, b):
    la, lb = lum(a), lum(b)
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)


def check(label, fg, bg, floor=4.5):
    r = ratio(fg, bg)
    ok = 'PASS' if r >= floor else 'FAIL'
    if ok == 'FAIL':
        check.failures += 1
    print(f'  [{ok}] {r:5.2f} (need {floor})  {label}   {fg} on {bg}')
    return r


check.failures = 0


def section(name):
    print(f'\n=== {name} ===')


# ---------------------------------------------------------------------------
# Candidate palettes
# ---------------------------------------------------------------------------
# hint darkened from #9C6A12 (4.36 on the page, just under) and wash lightened
# from #E4F1F1 so accent text clears 4.5 sitting on it.
L = dict(
    surface='#F5F7F8', card='#FFFFFF',
    ink='#1B2430', inkSoft='#5C6670', line='#DCE1E4',
    accent='#0F7B7D', accentDeep='#0A5F61',
    wrong='#C2412E', hint='#8F620E',
    wash='#EAF4F4', warmTint='#FDF3E3', track='#E7ECEE', wrongWash='#FCEFEC',
    accentSurface='#1D3557', onAccent='#FFFFFF',
)
D = dict(
    surface='#10141A', card='#1E2530',
    ink='#E7ECF2', inkSoft='#9AA6B4', line='#333C48',
    accent='#4DBDBE', accentDeep='#7FD4D5',
    wrong='#EE8873', hint='#E3B45C',
    wash='#123033', warmTint='#2E2617', track='#2A323D', wrongWash='#3A2621',
    accentSurface='#3B5C86', onAccent='#FFFFFF',
)

for name, P in (('LIGHT', L), ('DARK', D)):
    section(f'{name} — text on page and card')
    for ground in ('surface', 'card'):
        for role in ('ink', 'inkSoft', 'accent', 'accentDeep', 'wrong', 'hint'):
            check(f'{role} on {ground}', P[role], P[ground])

    section(f'{name} — text on tinted washes')
    check('ink on wash', P['ink'], P['wash'])
    check('accent on wash', P['accent'], P['wash'])
    check('ink on warmTint', P['ink'], P['warmTint'])
    check('hint on warmTint', P['hint'], P['warmTint'])
    check('ink on wrongWash', P['ink'], P['wrongWash'])
    check('wrong on wrongWash', P['wrong'], P['wrongWash'])
    check('onAccent on accentSurface', P['onAccent'], P['accentSurface'])

# ---------------------------------------------------------------------------
# Bands. The fills are dots/bars/branches (3.0, non-text); bandText is words.
# The light-theme values are today's, unchanged. The dark set is new — the
# current app reuses the light one, which is the reported bug.
# ---------------------------------------------------------------------------
BAND_FILL_L = dict(green='#2E7D32', lightGreen='#66BB6A', yellow='#D9A404',
                   orange='#E8590C', grey='#9AA0A6')
BAND_TEXT_L = dict(green='#2E7D32', lightGreen='#33753B', yellow='#8A6803',
                   orange='#BC4708', grey='#5F6368')
BAND_FILL_D = dict(green='#5FBF63', lightGreen='#8CD98F', yellow='#E8BC3A',
                   orange='#F5834A', grey='#8A939B')
BAND_TEXT_D = dict(green='#7FD183', lightGreen='#A3E0A5', yellow='#EDC95C',
                   orange='#F79A69', grey='#9AA6B4')

section('LIGHT — band words (4.5)')
# The light band FILLS are deliberately bright and three of them measure
# under 3.0 as standalone non-text. They are not held to that floor here,
# because meaning never lives in them alone: every place a band fill is
# drawn, bandWord() is printed beside it in the colour checked below. That
# redundancy is the design, and it is asserted by a Dart test rather than
# by contrast arithmetic. The ratios are printed for information only.
for k in BAND_FILL_L:
    print(f'  [info ] {ratio(BAND_FILL_L[k], L["card"]):5.2f}          '
          f'fill {k} on card (paired with its word, not held to 3.0)')
    check(f'word {k} on card', BAND_TEXT_L[k], L['card'])
    check(f'word {k} on surface', BAND_TEXT_L[k], L['surface'])

section('DARK — band fills (3.0) and band words (4.5)')
for k in BAND_FILL_D:
    check(f'fill {k} on card', BAND_FILL_D[k], D['card'], 3.0)
    check(f'word {k} on card', BAND_TEXT_D[k], D['card'])
    check(f'word {k} on surface', BAND_TEXT_D[k], D['surface'])

# The bug this palette was built to fix, kept as a worked example rather
# than as a check — it is SUPPOSED to fail, so counting it as a failure
# would mean this script could never report zero and would stop being read.
section('For reference: what shipping the light band words into the dark did')
for k in BAND_TEXT_L:
    print(f'  [was  ] {ratio(BAND_TEXT_L[k], D["card"]):5.2f} (needed 4.5)  '
          f'word {k} on a dark card')

print()
if check.failures:
    print(f'{check.failures} failure(s) — fix before shipping')
    raise SystemExit(1)
print('All checks pass.')
