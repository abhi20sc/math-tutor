#!/usr/bin/env python3
# ===========================================================================
# make_figures.py — renders the question figures into web/figures/
# ===========================================================================
#
# Run from the project root:   python3 tools/make_figures.py
#
# Output lands in web/figures/, which `flutter build web` copies into every
# deploy, so the images ship with the app and load from the same host — no
# storage bucket, no third party, nothing extra to break. The script also
# regenerates supabase/migrations/figures_grade10.sql.
#
# ---------------------------------------------------------------------------
# THE RULE
# ---------------------------------------------------------------------------
# A figure sets up the picture. It must never hand over the answer:
#
#   * no grids, rulers or axes a value could be counted off
#   * unknowns are labelled '?', never drawn at a suggestive size
#   * every figure says 'not drawn to scale', and MEANS it
#
# That last one used to be enforced by good intentions, and good intentions
# lost: an audit found trig_13 drawn at 47 degrees against a stated 52, so a
# student measuring the picture computed 9.5 m — and the nearest option to
# 9.5 was 8.6, the correct answer. The figure was quietly doing the question.
#
# So it is mechanical now. Every figure whose picture carries a measurable
# number registers a RULER TEST: what a student measuring the drawing would
# compute, the real answer, and the four options. The script asserts the
# measured value lands nearest a WRONG option, and refuses to write the file
# otherwise. Draw angles 15-20 degrees off, not 5.
#
# ---------------------------------------------------------------------------
# ADDING A FIGURE
# ---------------------------------------------------------------------------
# 1. Check the five families below — most new questions are an existing
#    function called with different arguments, not a new function.
# 2. Add an entry to FIGURES: (unit, sort_order, filename, draw_callable,
#    optional Ruler(...)).
# 3. Run the script. Look at the PNG. Then read docs/AUTHORING_GUIDE.md's
#    selection rubric before adding one to a question that does not need it.

import math
import os

import matplotlib

matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Arc

# The app's palette, so figures look native to the card they sit on.
INK = '#1E2422'
SOFT = '#6E7772'
ACCENT = '#2F6F62'
HINT = '#B9791C'
WATER = '#DCE9F2'

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..', 'web', 'figures')
QDIR = os.path.join(HERE, '..', 'supabase', 'migrations', 'questions')
SQL = os.path.join(QDIR, 'grade10_mpm2d', 'figures_grade10.sql')
SQL_MCR3U = os.path.join(QDIR, 'grade11_mcr3u', 'figures_mcr3u.sql')
SQL_MHF4U = os.path.join(QDIR, 'grade12_mhf4u', 'figures_mhf4u.sql')
SQL_MCV4U = os.path.join(QDIR, 'grade12_mcv4u', 'figures_mcv4u.sql')
SQL_MDM4U = os.path.join(QDIR, 'grade12_mdm4u', 'figures_mdm4u.sql')


# ---------------------------------------------------------------------------
# The ruler test
# ---------------------------------------------------------------------------

class Ruler:
    """What a student measuring the drawing would compute, and whether that
    betrays the answer.

    measured — the value obtained by measuring the PICTURE and applying the
               stated scale (compute it from the drawn geometry, not the
               real geometry)
    answer   — the correct answer
    options  — all four options, as numbers
    """

    def __init__(self, measured, answer, options):
        self.measured = measured
        self.answer = answer
        self.options = options

    def check(self, name):
        nearest = min(self.options, key=lambda o: abs(o - self.measured))
        if abs(nearest - self.answer) < 1e-9:
            raise AssertionError(
                '%s LEAKS: measuring the drawing gives %.2f, whose nearest '
                'option is %.2f — the correct answer. Redraw it further '
                'off-true.' % (name, self.measured, self.answer))
        return 'measures %.1f -> nearest option %.1f (answer %.1f)' % (
            self.measured, nearest, self.answer)


# ---------------------------------------------------------------------------
# Drawing helpers
# ---------------------------------------------------------------------------

def fig_ax(w=6.4, h=4.2):
    fig, ax = plt.subplots(figsize=(w, h), dpi=125)
    ax.set_aspect('equal')
    ax.axis('off')
    return fig, ax


def finish(fig, ax, name, note=True):
    """note=False for the statistical displays.

    Every geometric figure says 'not drawn to scale' and means it. A bar
    chart is a different animal: it IS drawn to its own axis, and the whole
    question on the truncated one is whether the reader notices where that
    axis starts. Stamping 'not drawn to scale' on it would be both false and
    a hint.
    """
    if note:
        ax.text(0.99, 0.01, 'not drawn to scale', transform=ax.transAxes,
                ha='right', va='bottom', fontsize=8, color=SOFT, style='italic')
    fig.tight_layout(pad=0.4)
    fig.savefig(os.path.join(OUT, name), facecolor='white')
    plt.close(fig)


def seg(ax, a, b, color=INK, lw=2.2, ls='-'):
    ax.plot([a[0], b[0]], [a[1], b[1]], color=color, lw=lw, ls=ls,
            solid_capstyle='round', zorder=3)


def arrow(ax, a, b, color=INK, lw=2.2, ls='-'):
    """A directed segment. Vectors need the head; plain segments do not."""
    ax.annotate('', xy=(b[0], b[1]), xytext=(a[0], a[1]),
                arrowprops=dict(arrowstyle='-|>', color=color, lw=lw,
                                linestyle=ls, shrinkA=0, shrinkB=0,
                                mutation_scale=18), zorder=3)


def label(ax, xy, text, color=INK, size=12, ha='center', va='center',
          weight='normal'):
    if text is None or text == '':
        return
    ax.text(xy[0], xy[1], text, color=color, fontsize=size, ha=ha, va=va,
            fontweight=weight, zorder=5)


def angle_mark(ax, vertex, a_deg, b_deg, r=0.55, color=HINT, text=None,
               text_r=None, size=11):
    ax.add_patch(Arc(vertex, 2 * r, 2 * r, angle=0, theta1=a_deg,
                     theta2=b_deg, color=color, lw=1.8, zorder=4))
    if text:
        mid = math.radians((a_deg + b_deg) / 2)
        tr = text_r if text_r is not None else r + 0.45
        label(ax, (vertex[0] + tr * math.cos(mid),
                   vertex[1] + tr * math.sin(mid)), text, color=color,
              size=size)


def right_angle(ax, corner, size=0.28, dx=1, dy=1):
    x, y = corner
    seg(ax, (x + dx * size, y), (x + dx * size, y + dy * size), SOFT, 1.4)
    seg(ax, (x + dx * size, y + dy * size), (x, y + dy * size), SOFT, 1.4)


def _ang(a, b):
    return math.degrees(math.atan2(b[1] - a[1], b[0] - a[0]))


def vertex_arc(ax, at, p1, p2, text=None, r=0.6, size=11):
    """Arc at `at`, spanning the angle between the rays to p1 and p2."""
    a1, a2 = _ang(at, p1), _ang(at, p2)
    if a2 < a1:
        a1, a2 = a2, a1
    if a2 - a1 > 180:
        a1, a2 = a2, a1 + 360
    angle_mark(ax, at, a1, a2, r=r, text=text, size=size)


def side_label(ax, a, b, text, out=(0, 0), size=12, color=INK,
               weight='bold'):
    """Label the midpoint of a-b, nudged by `out` so it clears the line."""
    label(ax, ((a[0] + b[0]) / 2 + out[0], (a[1] + b[1]) / 2 + out[1]),
          text, size=size, color=color, weight=weight)


def outward(tri, i, amount=0.5):
    """Offset vector pushing away from a triangle's centroid, for the side
    opposite vertex i."""
    a, b = tri[(i + 1) % 3], tri[(i + 2) % 3]
    mid = ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2)
    cx = sum(p[0] for p in tri) / 3.0
    cy = sum(p[1] for p in tri) / 3.0
    dx, dy = mid[0] - cx, mid[1] - cy
    d = math.hypot(dx, dy) or 1
    return (dx / d * amount, dy / d * amount)


def ticks(ax, a, b, count=1, color=INK):
    """Equal-length marks across the middle of a-b."""
    mx, my = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
    dx, dy = b[0] - a[0], b[1] - a[1]
    d = math.hypot(dx, dy) or 1
    ux, uy = dx / d, dy / d
    px, py = -uy, ux
    for k in range(count):
        off = (k - (count - 1) / 2.0) * 0.13
        cx, cy = mx + ux * off, my + uy * off
        seg(ax, (cx - px * 0.11, cy - py * 0.11),
            (cx + px * 0.11, cy + py * 0.11), color, 1.6)


def fit(ax, pts, pad=1.0):
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    ax.set_xlim(min(xs) - pad, max(xs) + pad)
    ax.set_ylim(min(ys) - pad, max(ys) + pad)


# ===========================================================================
# FAMILY A — right triangle, one marked angle, labelled sides
# ===========================================================================
# Trig 6, 8, 15, 16, 17, 23, 28, 37.
#
# Skeleton: right angle bottom-right. A = bottom-left, B = bottom-right,
# C = top-right. `drawn` fixes the shape and is deliberately NOT the stated
# angle — see the ruler tests in FIGURES.

def right_tri(name, drawn=40, arc_at='A', arc_text=None,
              opp=None, adj=None, hyp=None, letters=None, base=5.6):
    def draw():
        fig, ax = fig_ax()
        h = base * math.tan(math.radians(drawn))
        A, B, C = (0.0, 0.0), (base, 0.0), (base, h)
        seg(ax, A, B, ACCENT, 2.6)
        seg(ax, B, C, INK, 2.4)
        seg(ax, A, C, INK, 2.4)
        right_angle(ax, B, dx=-1, dy=1)

        if arc_at == 'A':
            vertex_arc(ax, A, B, C, text=arc_text, r=0.95)
        else:
            vertex_arc(ax, C, B, A, text=arc_text, r=0.95)

        side_label(ax, A, B, adj, out=(0, -0.42), color=ACCENT)
        side_label(ax, B, C, opp, out=(0.8, 0))
        hx, hy = C[0] - A[0], C[1] - A[1]
        hd = math.hypot(hx, hy) or 1
        side_label(ax, A, C, hyp, out=(-hy / hd * 0.88, hx / hd * 0.88))

        if letters:
            label(ax, (A[0] - 0.34, A[1] - 0.3), letters[0], size=13,
                  weight='bold', color=SOFT)
            label(ax, (B[0] + 0.36, B[1] - 0.3), letters[1], size=13,
                  weight='bold', color=SOFT)
            label(ax, (C[0] + 0.36, C[1] + 0.28), letters[2], size=13,
                  weight='bold', color=SOFT)

        fit(ax, [A, B, C], pad=1.55)
        finish(fig, ax, name)

    return draw


# ===========================================================================
# FAMILY B — oblique triangle ABC for the sine and cosine laws
# ===========================================================================
# Trig 18, 19, 20, 24, 25, 26, 32, 33, 38 + Analytic geometry 27 (cevian).
#
# Two fixed skeletons, reused by everyone. The drawn shape is chosen FIRST
# and the labels hung on it second, so drawn lengths are never proportional
# to the stated ones. For SSS questions the drawn ORDER of the sides is kept
# honest (the reasoning is about which side is longest) while the ratios are
# crushed.

SKELETONS = {
    #                 A            B            C
    'acute':   [(0.0, 0.0), (6.4, 0.0), (2.3, 4.1)],
    'obtuse':  [(0.0, 0.0), (6.8, 0.0), (-1.5, 3.2)],
    'wide':    [(0.0, 0.0), (6.0, 0.0), (3.7, 3.0)],
}


def oblique_tri(name, preset='acute', letters=('A', 'B', 'C'),
                arcs=(None, None, None), sides=(None, None, None),
                tick_sides=(), cevian=None, note=None):
    """arcs  — text at A, B, C (None for no arc)
    sides — label for a (opposite A), b (opposite B), c (opposite C)
    cevian — dict(from_vertex=2, to='mid', note='not 90 degrees')
    """

    def draw():
        fig, ax = fig_ax(6.4, 4.4)
        tri = SKELETONS[preset]
        A, B, C = tri
        seg(ax, A, B, INK, 2.4)
        seg(ax, B, C, INK, 2.4)
        seg(ax, C, A, INK, 2.4)

        for i, txt in enumerate(arcs):
            if not txt:
                continue
            at = tri[i]
            p1, p2 = tri[(i + 1) % 3], tri[(i + 2) % 3]
            vertex_arc(ax, at, p1, p2, text=txt, r=0.72)

        # side a is BC (opposite A), b is CA, c is AB
        pairs = [(B, C), (C, A), (A, B)]
        for i, txt in enumerate(sides):
            if not txt:
                continue
            a, b = pairs[i]
            side_label(ax, a, b, txt, out=outward(tri, i, 0.78),
                       color=ACCENT)

        for i in tick_sides:
            a, b = pairs[i]
            ticks(ax, a, b, count=1)

        if cevian:
            src = tri[cevian['from_vertex']]
            o1 = tri[(cevian['from_vertex'] + 1) % 3]
            o2 = tri[(cevian['from_vertex'] + 2) % 3]
            foot = ((o1[0] + o2[0]) / 2, (o1[1] + o2[1]) / 2)
            seg(ax, src, foot, ACCENT, 2.0, ls='--')
            ticks(ax, o1, foot, count=2)
            ticks(ax, foot, o2, count=2)
            if cevian.get('note'):
                label(ax, (foot[0], foot[1] - 0.45), cevian['note'],
                      color=SOFT, size=10.5)

        for i, L in enumerate(letters):
            if not L:
                continue
            v = tri[i]
            cx = sum(p[0] for p in tri) / 3.0
            cy = sum(p[1] for p in tri) / 3.0
            dx, dy = v[0] - cx, v[1] - cy
            d = math.hypot(dx, dy) or 1
            label(ax, (v[0] + dx / d * 0.42, v[1] + dy / d * 0.42), L,
                  size=13, weight='bold', color=SOFT)

        if note:
            ax.text(0.02, 0.96, note, transform=ax.transAxes, ha='left',
                    va='top', fontsize=10.5, color=SOFT)

        fit(ax, tri, pad=1.1)
        finish(fig, ax, name)

    return draw


# ===========================================================================
# FAMILY C — two similar triangles side by side
# ===========================================================================
# Trig 2, 11.
#
# Correspondence is shown with matching arcs, NEVER by drawing to scale:
# the drawn scale factor is deliberately not the real one.

def similar_pair(name, drawn_ratio=1.7, left=(None, None, None),
                 right=(None, None, None), caption=None, small=2.3):
    def draw():
        fig, ax = fig_ax(7.0, 4.0)
        shape = [(0.0, 0.0), (1.0, 0.0), (0.42, 1.35)]

        def place(scale, ox):
            return [(p[0] * scale + ox, p[1] * scale) for p in shape]

        L = place(small, 0.0)
        R = place(small * drawn_ratio, small * 1.45)

        for tri, labels in ((L, left), (R, right)):
            seg(ax, tri[0], tri[1], INK, 2.3)
            seg(ax, tri[1], tri[2], INK, 2.3)
            seg(ax, tri[2], tri[0], INK, 2.3)
            pairs = [(tri[1], tri[2]), (tri[2], tri[0]), (tri[0], tri[1])]
            for i, txt in enumerate(labels):
                if not txt:
                    continue
                a, b = pairs[i]
                side_label(ax, a, b, txt, out=outward(tri, i, 0.52),
                           color=ACCENT, size=11.5)
            # matching arcs: single at vertex 0, double at vertex 1
            vertex_arc(ax, tri[0], tri[1], tri[2], r=0.4)
            vertex_arc(ax, tri[1], tri[2], tri[0], r=0.34)
            vertex_arc(ax, tri[1], tri[2], tri[0], r=0.46)

        if caption:
            allp = L + R
            cx = (min(p[0] for p in allp) + max(p[0] for p in allp)) / 2
            ax.text(cx, max(p[1] for p in allp) + 0.7, caption,
                    ha='center', fontsize=10.5, color=SOFT)

        fit(ax, L + R, pad=1.0)
        finish(fig, ax, name)

    return draw


# ===========================================================================
# FAMILY D — rectangle with a boundary feature
# ===========================================================================
# Solving quadratic equations 31 (uniform border) and 36 (fence against a
# wall).
#
# border mode: the border width IS the answer, so it is drawn deliberately
# fat and the inner rectangle is nudged off its true ratio.
# wall mode: every label is algebraic, so there is nothing to measure.

def rect_feature(name, mode='border', inner=('8 m', '6 m'),
                 border_label='x', outer_note=None, wall_labels=None):
    def draw():
        fig, ax = fig_ax(6.2, 4.4)
        if mode == 'border':
            iw, ih = 5.0, 4.4          # drawn 8:7, not the true 8:6
            b = 1.25                   # drawn fat: reads as x ~ 6, not 2
            ax.add_patch(plt.Rectangle((0, 0), iw + 2 * b, ih + 2 * b,
                                       facecolor='#F1F4F2',
                                       edgecolor=INK, lw=2.2, zorder=2))
            ax.add_patch(plt.Rectangle((b, b), iw, ih, facecolor='white',
                                       edgecolor=ACCENT, lw=2.2, zorder=3))
            label(ax, (b + iw / 2, b + ih / 2), '%s by %s'
                  % (inner[0], inner[1]), size=13, weight='bold',
                  color=ACCENT)
            for (x0, y0, x1, y1) in [
                    (b + iw / 2, 0, b + iw / 2, b),
                    (b + iw / 2, ih + b, b + iw / 2, ih + 2 * b),
                    (0, b + ih / 2, b, b + ih / 2),
                    (iw + b, b + ih / 2, iw + 2 * b, b + ih / 2)]:
                ax.annotate('', xy=(x1, y1), xytext=(x0, y0),
                            arrowprops=dict(arrowstyle='<->', color=HINT,
                                            lw=1.4), zorder=6)
            label(ax, (b + iw / 2 + 0.42, b / 2), border_label, color=HINT,
                  size=13, weight='bold')
            label(ax, (b / 2 - 0.05, b + ih / 2 + 0.42), border_label,
                  color=HINT, size=13, weight='bold')
            if outer_note:
                label(ax, (b + iw / 2, ih + 2 * b + 0.45), outer_note,
                      color=SOFT, size=11.5)
            fit(ax, [(0, 0), (iw + 2 * b, ih + 2 * b)], pad=0.9)
        else:
            w, h = 6.4, 3.4
            # the wall: hatched, no fence along it
            ax.add_patch(plt.Rectangle((0, h), w, 0.34, facecolor='#E8E6DF',
                                       edgecolor=SOFT, hatch='///', lw=1.4,
                                       zorder=2))
            label(ax, (w / 2, h + 0.62), 'wall', color=SOFT, size=11)
            seg(ax, (0, 0), (0, h), ACCENT, 2.8)
            seg(ax, (w, 0), (w, h), ACCENT, 2.8)
            seg(ax, (0, 0), (w, 0), ACCENT, 2.8)
            wl = wall_labels or ('w', '60 - 2w')
            label(ax, (-0.45, h / 2), wl[0], color=ACCENT, size=13,
                  weight='bold')
            label(ax, (w + 0.45, h / 2), wl[0], color=ACCENT, size=13,
                  weight='bold')
            label(ax, (w / 2, -0.45), wl[1], color=ACCENT, size=13,
                  weight='bold')
            label(ax, (w / 2, h / 2), 'fenced on three sides', color=SOFT,
                  size=11)
            fit(ax, [(0, 0), (w, h + 0.9)], pad=1.0)
        finish(fig, ax, name)

    return draw


# ===========================================================================
# FAMILY E — a shape carrying algebraic dimensions
# ===========================================================================
# Solving quadratic equations 29 (right triangle) and 40 (triangle + area).
# Algebraic labels cannot be measured, so this family is safe by
# construction — except where one dimension is numeric (SQE 29).

def algebra_shape(name, shape='right_tri', labels=None, note=None):
    labels = labels or {}

    def draw():
        if shape == 'right_tri':
            fig, ax = fig_ax(5.8, 4.2)
            # short leg drawn at ~0.6 of the hypotenuse: a measurer reads a
            # distractor, not the answer
            w, h = 3.4, 4.4
            A, B, C = (0.0, 0.0), (w, 0.0), (w, h)
            seg(ax, A, B, ACCENT, 2.6)
            seg(ax, B, C, ACCENT, 2.6)
            seg(ax, A, C, INK, 2.4)
            right_angle(ax, B, dx=-1, dy=1)
            side_label(ax, A, B, labels.get('base'), out=(0, -0.44),
                       color=ACCENT)
            side_label(ax, B, C, labels.get('height'), out=(0.62, 0),
                       color=ACCENT)
            side_label(ax, A, C, labels.get('hyp'), out=(-0.45, 0.36))
            fit(ax, [A, B, C], pad=1.05)
        else:  # tri_altitude
            fig, ax = fig_ax(5.6, 3.9)
            b, h = 5.2, 2.9
            apex = (b * 0.68, h)
            seg(ax, (0, 0), (b, 0), ACCENT, 2.8)
            seg(ax, (0, 0), apex, INK, 2.2)
            seg(ax, (b, 0), apex, INK, 2.2)
            seg(ax, apex, (b * 0.68, 0), SOFT, 1.4, ls='--')
            right_angle(ax, (b * 0.68, 0), dx=1, dy=1)
            label(ax, (b / 2, -0.42), labels.get('base'), color=ACCENT,
                  size=14, weight='bold')
            label(ax, (b * 0.68 - 0.72, h * 0.52), labels.get('height'),
                  size=13, weight='bold')
            fit(ax, [(0, 0), (b, h)], pad=0.9)
        if note:
            ax.text(0.03, 0.10, note, transform=ax.transAxes, ha='left',
                    fontsize=11, color=SOFT)
        finish(fig, ax, name)

    return draw


# ===========================================================================
# Scene figures — one-off word problems that earn a bespoke picture
# ===========================================================================

def draw_ladder(name, angle_true, drawn, length_label, unknown, unknown_on):
    def draw():
        fig, ax = fig_ax()
        ang = math.radians(drawn)
        base = 6.0 * math.cos(ang)
        top = 6.0 * math.sin(ang)
        seg(ax, (0, 0), (base + 1.2, 0), SOFT, 2.6)
        seg(ax, (base, 0), (base, top + 0.7), SOFT, 2.6)
        seg(ax, (0, 0), (base, top), ACCENT, 3)
        right_angle(ax, (base, 0), dx=-1, dy=1)
        angle_mark(ax, (0, 0), 0, drawn, r=0.9, text='%d°' % angle_true)
        label(ax, (base / 2 - 0.55, top / 2 + 0.25), length_label,
              color=ACCENT, size=13, weight='bold')
        if unknown_on == 'base':
            label(ax, (base / 2, -0.42), unknown, size=13, weight='bold')
        else:
            label(ax, (base + 0.42, top / 2), unknown, size=13,
                  weight='bold')
        ax.set_xlim(-1.2, base + 1.8)
        ax.set_ylim(-1.1, top + 1.1)
        finish(fig, ax, name)

    return draw


def draw_elevation_tree():
    fig, ax = fig_ax()
    d, drawn = 6.4, 24
    h = d * math.tan(math.radians(drawn))
    seg(ax, (-0.8, 0), (d + 1.0, 0), SOFT, 2.6)
    seg(ax, (d, 0), (d, h + 0.4), ACCENT, 3)
    seg(ax, (0, 0), (d, h), INK, 1.6, ls='--')
    right_angle(ax, (d, 0), dx=-1, dy=1)
    angle_mark(ax, (0, 0), 0, drawn, r=1.0, text='41°')
    ax.plot([0], [0], 'o', color=INK, ms=6, zorder=5)
    label(ax, (d / 2, -0.45), '25 m', size=13, weight='bold')
    label(ax, (d + 0.45, h / 2), '?', color=ACCENT, size=15, weight='bold')
    ax.plot([d], [h + 0.55], marker='^', ms=26, color=ACCENT, zorder=4)
    ax.set_xlim(-1.3, d + 1.6)
    ax.set_ylim(-1.0, h + 1.6)
    finish(fig, ax, 'trig_14.png')


def draw_shadows():
    fig, ax = fig_ax(7.0, 4.0)
    ph, ps = 1.7, 2.1
    seg(ax, (-0.5, 0), (12.6, 0), SOFT, 2.6)
    seg(ax, (ps, 0), (ps, ph), ACCENT, 3)
    seg(ax, (0, 0), (ps, ph), INK, 1.4, ls='--')
    label(ax, (ps / 2, -0.42), '2.4 m', size=11.5, weight='bold')
    label(ax, (ps + 0.75, ph / 2 + 0.1), '1.8 m', size=11.5, weight='bold')
    ax.plot([ps], [ph + 0.22], 'o', color=ACCENT, ms=9)
    tx, ts, th = 5.2, 6.4, 3.4
    seg(ax, (tx + ts, 0), (tx + ts, th), ACCENT, 3)
    seg(ax, (tx, 0), (tx + ts, th), INK, 1.4, ls='--')
    label(ax, (tx + ts / 2, -0.42), '14 m', size=11.5, weight='bold')
    label(ax, (tx + ts + 0.55, th / 2), '?', color=ACCENT, size=15,
          weight='bold')
    ax.plot([tx + ts], [th + 0.5], marker='^', ms=30, color=ACCENT)
    label(ax, (6.3, 3.95), 'same sun, same moment', color=SOFT, size=10)
    ax.set_xlim(-0.9, 12.9)
    ax.set_ylim(-1.0, 4.5)
    finish(fig, ax, 'trig_21.png')


def draw_cliff():
    fig, ax = fig_ax()
    ch, drawn = 4.2, 38
    d = ch / math.tan(math.radians(drawn))
    seg(ax, (0, 0), (0, ch), ACCENT, 3)
    seg(ax, (-1.0, 0), (d + 1.2, 0), SOFT, 2.6)
    seg(ax, (0, ch), (d * 0.65, ch), SOFT, 1.4, ls=':')
    seg(ax, (0, ch), (d, 0), INK, 1.6, ls='--')
    angle_mark(ax, (0, ch), -drawn, 0, r=1.15, text='25°')
    right_angle(ax, (0, 0), dx=1, dy=1)
    label(ax, (-0.55, ch / 2), '80 m', color=ACCENT, size=13, weight='bold')
    label(ax, (d / 2, -0.5), '?', color=ACCENT, size=15, weight='bold')
    ax.plot([d], [0.12], marker='>', ms=13, color=INK)
    label(ax, (d, 0.6), 'boat', color=SOFT, size=10)
    ax.set_xlim(-1.6, d + 1.7)
    ax.set_ylim(-1.1, ch + 1.2)
    finish(fig, ax, 'trig_22.png')


# Drawn angles, chosen so the picture cannot be solved with a protractor.
# They are the ACTUAL drawn geometry — an arc labelled 30 while the line
# sits at some other angle would be a different kind of lie.
TOWER_FAR, TOWER_NEAR = 33.0, 58.0


def draw_tower_two_angles():
    fig, ax = fig_ax(7.2, 4.4)
    h = 3.2
    d_near = h / math.tan(math.radians(TOWER_NEAR))
    d_far = h / math.tan(math.radians(TOWER_FAR))
    base = 7.4
    seg(ax, (-0.6, 0), (base + 1.0, 0), SOFT, 2.6)
    seg(ax, (base, 0), (base, h), ACCENT, 3.2)
    p_far = (base - d_far, 0)
    p_near = (base - d_near, 0)
    seg(ax, p_far, (base, h), INK, 1.4, ls='--')
    seg(ax, p_near, (base, h), INK, 1.4, ls='--')
    ax.plot([p_far[0], p_near[0]], [0, 0], 'o', color=INK, ms=6, zorder=5)
    angle_mark(ax, p_far, 0, TOWER_FAR, r=1.0, text='30°', text_r=1.5)
    angle_mark(ax, p_near, 0, TOWER_NEAR, r=0.7, text='45°', text_r=1.2)
    label(ax, ((p_far[0] + p_near[0]) / 2, -0.48), '20 m', size=12.5,
          weight='bold')
    label(ax, (base + 0.45, h / 2), '?', color=ACCENT, size=15,
          weight='bold')
    right_angle(ax, (base, 0), dx=-1, dy=1)
    ax.set_xlim(p_far[0] - 1.6, base + 1.6)
    ax.set_ylim(-1.05, h + 0.9)
    finish(fig, ax, 'trig_31.png')


def draw_two_roads():
    fig, ax = fig_ax()
    drawn = 74
    a, b = 5.2, 5.8
    p1 = (a, 0)
    p2 = (b * math.cos(math.radians(drawn)), b * math.sin(math.radians(drawn)))
    seg(ax, (0, 0), p1, ACCENT, 2.6)
    seg(ax, (0, 0), p2, ACCENT, 2.6)
    seg(ax, p1, p2, INK, 1.7, ls='--')
    angle_mark(ax, (0, 0), 0, drawn, r=0.85, text='50°')
    ax.plot([0], [0], 's', color=INK, ms=9, zorder=5)
    label(ax, (-0.35, -0.4), 'town', color=SOFT, size=10.5)
    label(ax, (a / 2, -0.42), '40 km', size=12.5, weight='bold')
    label(ax, (p2[0] / 2 - 0.85, p2[1] / 2 + 0.15), '65 km', size=12.5,
          weight='bold')
    label(ax, ((p1[0] + p2[0]) / 2 + 0.7, (p1[1] + p2[1]) / 2), '?',
          color=ACCENT, size=15, weight='bold')
    ax.plot([p1[0]], [p1[1]], 'o', color=ACCENT, ms=7, zorder=5)
    ax.plot([p2[0]], [p2[1]], 'o', color=ACCENT, ms=7, zorder=5)
    fit(ax, [(0, 0), p1, p2], pad=1.2)
    finish(fig, ax, 'trig_34.png')


def draw_kite():
    fig, ax = fig_ax(6.0, 4.8)
    drawn = 40
    hand = (0.6, 0.9)
    L = 4.6
    kite = (hand[0] + L * math.cos(math.radians(drawn)),
            hand[1] + L * math.sin(math.radians(drawn)))
    seg(ax, (-0.6, 0), (6.2, 0), SOFT, 2.6)
    seg(ax, (hand[0], 0), hand, INK, 1.6)
    ax.plot([hand[0]], [hand[1]], 'o', color=INK, ms=6, zorder=5)
    label(ax, (hand[0] - 0.75, hand[1] / 2), '1.2 m', size=11, weight='bold')
    seg(ax, hand, kite, ACCENT, 2.4)
    seg(ax, hand, (hand[0] + 2.1, hand[1]), SOFT, 1.3, ls=':')
    angle_mark(ax, hand, 0, drawn, r=0.8, text='62°')
    label(ax, (hand[0] + 1.5, (hand[1] + kite[1]) / 2 + 0.42), '50 m',
          color=ACCENT, size=12.5, weight='bold')
    kx, ky = kite
    ax.fill([kx, kx + 0.28, kx, kx - 0.28],
            [ky + 0.38, ky, ky - 0.38, ky], color=HINT, zorder=5)
    seg(ax, (kx + 0.28, ky - 0.12), (kx + 0.62, ky - 0.5), HINT, 1.2)
    label(ax, (kx + 1.05, ky / 2 + 0.4), '?', color=ACCENT, size=15,
          weight='bold')
    seg(ax, (kx + 0.85, 0), (kx + 0.85, ky), SOFT, 1.2, ls=':')
    ax.set_xlim(-1.0, kx + 1.8)
    ax.set_ylim(-0.9, ky + 1.0)
    finish(fig, ax, 'trig_40.png')


def draw_river_survey():
    fig, ax = fig_ax(7.2, 4.0)
    # The small triangle is 1 m base by 0.7 m high in the question. Drawn
    # nearly square so the ratio cannot be measured off the picture.
    sb, sh = 1.3, 1.9
    seg(ax, (0, 0), (sb, 0), ACCENT, 2.6)
    seg(ax, (sb, 0), (sb, sh), INK, 2.0)
    seg(ax, (0, 0), (sb, sh), INK, 1.5, ls='--')
    right_angle(ax, (sb, 0), dx=-1, dy=1)
    label(ax, (sb / 2, -0.42), '1 m', size=11.5, weight='bold')
    label(ax, (sb + 0.62, sh / 2), '0.7 m', size=11.5, weight='bold')
    ax.fill_between([3.4, 4.9], -0.7, 3.6, color=WATER, zorder=1)
    label(ax, (4.15, 3.3), 'river', color=SOFT, size=10.5)
    lb, lh = 3.2, 2.9
    lx = 5.4
    seg(ax, (lx, 0), (lx + lb, 0), ACCENT, 2.6)
    seg(ax, (lx + lb, 0), (lx + lb, lh), INK, 2.0)
    seg(ax, (lx, 0), (lx + lb, lh), INK, 1.5, ls='--')
    right_angle(ax, (lx + lb, 0), dx=-1, dy=1)
    label(ax, (lx + lb / 2, -0.42), '40 m', size=11.5, weight='bold')
    label(ax, (lx + lb + 0.5, lh / 2), '?', color=ACCENT, size=15,
          weight='bold')
    label(ax, (4.15, -0.9), 'matching angles', color=SOFT, size=10)
    ax.set_xlim(-0.7, lx + lb + 1.3)
    ax.set_ylim(-1.3, 3.8)
    finish(fig, ax, 'trig_36.png')


# ===========================================================================
# MCR3U scene figures
# ===========================================================================

def angle_sum_tri(name, drawn=(52.0, 83.0), arcs=('40°', '75°', '?')):
    """Triangle with two angles given and the third asked for.

    The DRAWN angles are chosen so the third one measures about 45 degrees
    while the stated pair sum to 115. A student with a protractor therefore
    reads 45, which is a wrong option; the answer, 65, is 20 degrees away.
    """

    def draw():
        fig, ax = fig_ax(6.4, 4.0)
        a_deg, b_deg = drawn
        base = 6.2
        # apex where the two drawn rays meet
        ta, tb = math.tan(math.radians(a_deg)), math.tan(math.radians(b_deg))
        x = base * tb / (ta + tb)
        y = x * ta
        A, B, C = (0.0, 0.0), (base, 0.0), (x, y)
        tri = [A, B, C]
        seg(ax, A, B, INK, 2.4)
        seg(ax, B, C, INK, 2.4)
        seg(ax, C, A, INK, 2.4)
        for i, txt in enumerate(arcs):
            if not txt:
                continue
            at = tri[i]
            vertex_arc(ax, at, tri[(i + 1) % 3], tri[(i + 2) % 3], text=txt,
                       r=0.78)
        for i, L in enumerate(('A', 'B', 'C')):
            v = tri[i]
            cx = sum(p[0] for p in tri) / 3.0
            cy = sum(p[1] for p in tri) / 3.0
            dx, dy = v[0] - cx, v[1] - cy
            d = math.hypot(dx, dy) or 1
            label(ax, (v[0] + dx / d * 0.44, v[1] + dy / d * 0.44), L,
                  size=13, weight='bold', color=SOFT)
        fit(ax, tri, pad=1.15)
        finish(fig, ax, name)

    return draw


def draw_tree_shadow():
    """Tree and its shadow. Drawn at 35 degrees against a true 61.1, so a
    protractor reads 35, whose nearest option is 33.5 — a wrong one."""
    fig, ax = fig_ax(6.6, 4.2)
    drawn = 35.0
    shadow = 6.2
    h = shadow * math.tan(math.radians(drawn))
    seg(ax, (-0.7, 0), (shadow + 1.1, 0), SOFT, 2.6)
    seg(ax, (shadow, 0), (shadow, h), ACCENT, 3.2)
    seg(ax, (0, 0), (shadow, h), INK, 1.5, ls='--')
    right_angle(ax, (shadow, 0), dx=-1, dy=1)
    angle_mark(ax, (0, 0), 0, drawn, r=1.0, text='?', text_r=1.5)
    ax.plot([0], [0], 'o', color=INK, ms=6, zorder=5)
    label(ax, (shadow / 2, -0.46), 'shadow 10.2 m', size=12, weight='bold')
    label(ax, (shadow + 0.55, h / 2), '18.5 m', color=ACCENT, size=12.5,
          weight='bold')
    ax.plot([shadow], [h + 0.42], marker='^', ms=26, color=ACCENT, zorder=4)
    label(ax, (0.35, 0.55), 'sun', color=HINT, size=10.5)
    ax.set_xlim(-1.2, shadow + 1.7)
    ax.set_ylim(-1.0, h + 1.5)
    finish(fig, ax, 'mcr3u_trig_27.png')


def draw_balloon_two_houses():
    """Rhonda, two houses and a balloon over the midpoint.

    The scene IS the question: without it, working out which triangle the
    64 degrees sits in, and that Dave is over the midpoint rather than over a
    house, is guesswork.

    The ground is drawn in oblique projection and Dave is lifted straight up
    the page, so a protractor laid on the drawing reads about 20 degrees for
    the elevation. The nearest option to 20 is 10.4, which is wrong, and the
    answer 6.7 is a long way off it.
    """
    fig, ax = fig_ax(7.4, 5.0)
    R = (1.3, 0.0)                 # Rhonda
    H1 = (0.6, 3.1)                # House 1
    H2 = (6.2, 2.0)                # House 2
    M = ((H1[0] + H2[0]) / 2, (H1[1] + H2[1]) / 2)
    D = (M[0], 6.0)                # Dave, straight up from the midpoint

    seg(ax, R, H1, INK, 2.0)
    seg(ax, R, H2, INK, 2.0)
    seg(ax, H1, H2, SOFT, 1.6, ls='--')
    seg(ax, M, D, ACCENT, 2.6)
    seg(ax, R, D, HINT, 1.8, ls='--')
    seg(ax, R, M, SOFT, 1.5, ls=':')
    ticks(ax, H1, M, count=1, color=SOFT)
    ticks(ax, M, H2, count=1, color=SOFT)
    right_angle(ax, M, size=0.3, dx=-1, dy=1)

    vertex_arc(ax, R, H1, H2, text='64°', r=0.9, size=11.5)
    vertex_arc(ax, R, M, D, text='?', r=2.6, size=13)

    side_label(ax, R, H1, '4.6 km', out=(-0.5, 0.42), size=11.5)
    side_label(ax, R, H2, '3.4 km', out=(0.35, -0.5), size=11.5)
    label(ax, (D[0] + 0.68, (M[1] + D[1]) / 2), '400 m', color=ACCENT,
          size=12, weight='bold')

    for pt, txt, dxy in ((H1, 'House 1', (0.0, 0.42)),
                         (H2, 'House 2', (0.0, 0.42)),
                         (R, 'Rhonda', (0.0, -0.42))):
        ax.plot([pt[0]], [pt[1]], 'o', color=INK, ms=7, zorder=5)
        label(ax, (pt[0] + dxy[0], pt[1] + dxy[1]), txt, color=SOFT,
              size=10.5)
    ax.plot([D[0]], [D[1]], 'o', color=ACCENT, ms=12, zorder=5)
    label(ax, (D[0], D[1] + 0.42), 'Dave', color=ACCENT, size=11)
    label(ax, (M[0] + 0.95, M[1] - 0.34), 'midpoint', color=SOFT, size=10)

    fit(ax, [R, H1, H2, D], pad=0.95)
    finish(fig, ax, 'mcr3u_trig_38.png')


# ===========================================================================
# The register
# ===========================================================================
# (unit, sort_order, filename, draw callable, ruler test or None)

T = 'Trigonometry'
SQE = 'Solving quadratic equations'
AG = 'Analytic geometry'


def _cos(d):
    return math.cos(math.radians(d))


def _sin(d):
    return math.sin(math.radians(d))


def _tan(d):
    return math.tan(math.radians(d))


FIGURES = [
    # ---- scenes (existing, offsets widened to pass the ruler test) ----
    (T, 13, 'trig_13.png',
     draw_ladder('trig_13.png', 52, 38, '14 m', '?', 'base'),
     # drawn 38 deg: 14*cos38 = 11.0 -> nearest option 11.0 (wrong)
     Ruler(14 * _cos(38), 8.6, [11.0, 8.6, 7.0, 22.7])),

    (T, 14, 'trig_14.png', draw_elevation_tree,
     Ruler(25 * _tan(24), 21.7, [28.8, 21.7, 25.0, 16.4])),

    (T, 21, 'trig_21.png', draw_shadows, None),

    (T, 22, 'trig_22.png', draw_cliff,
     Ruler(80 / _tan(38), 172, [172, 80, 37, 189])),

    (T, 29, 'trig_29.png',
     draw_ladder('trig_29.png', 75, 84, '10 m', '?', 'wall'),
     Ruler(10 * _sin(84), 9.7, [37.3, 9.7, 2.6, 10.0])),

    (T, 31, 'trig_31.png', draw_tower_two_angles,
     Ruler(20 / (1 / _tan(TOWER_FAR) - 1 / _tan(TOWER_NEAR)), 27.3,
           [12.7, 11.5, 27.3, 20.0])),

    (T, 34, 'trig_34.png', draw_two_roads,
     Ruler(math.sqrt(40 ** 2 + 65 ** 2 - 2 * 40 * 65 * _cos(74)), 49.8,
           [49.8, 105.0, 76.3, 20.0])),

    (T, 36, 'trig_36.png', draw_river_survey, None),

    (T, 40, 'trig_40.png', draw_kite,
     Ruler(50 * _sin(40) + 1.2, 45.3, [44.1, 24.7, 51.2, 45.3])),

    # ---- family E ----
    (SQE, 40, 'sqe_40.png',
     algebra_shape('sqe_40.png', 'tri_altitude',
                   labels={'base': 'x', 'height': 'x − 3'},
                   note='Area = 27 cm²'), None),

    (SQE, 29, 'sqe_29.png',
     algebra_shape('sqe_29.png', 'right_tri',
                   labels={'base': 'x', 'height': 'x + 7', 'hyp': '13'}),
     Ruler(13 * (3.4 / math.hypot(3.4, 4.4)), 5, [6, 5, 13, 12])),

    # ---- family D ----
    (SQE, 31, 'sqe_31.png',
     rect_feature('sqe_31.png', 'border', inner=('8 m', '6 m'),
                  border_label='x', outer_note='total area 80 m²'),
     # options are 8, 2, 8/7 and 1; the old register said 16, read off the
     # leading digits of a distractor that was written 16/28 and has since
     # been corrected to 8/7
     Ruler(8 * (1.25 / 5.0), 1, [8, 2, 1, 8 / 7])),

    (SQE, 36, 'sqe_36.png',
     rect_feature('sqe_36.png', 'wall', wall_labels=('w', '60 − 2w')),
     None),

    # ---- family C ----
    (T, 2, 'trig_2.png',
     similar_pair('trig_2.png', drawn_ratio=1.7,
                  left=(None, None, 'AB = 4 cm'),
                  right=(None, None, 'DE = ?'),
                  caption='similar triangles'),
     Ruler(4 * 1.7, 12, [7, 1.33, 12, 4])),

    (T, 11, 'trig_11.png',
     similar_pair('trig_11.png', drawn_ratio=1.45,
                  left=(None, '6', 'x'),
                  right=(None, '9', '12'),
                  caption='matching sides'),
     # x is measured against 6 INSIDE the left triangle: side c over
     # side b of the drawn shape, which is deliberately not 8/6.
     Ruler(6 * (1.0 / math.hypot(0.42, 1.35)), 8, [8, 4.5, 18, 9])),

    # ---- family A ----
    (T, 6, 'trig_6.png',
     right_tri('trig_6.png', drawn=34, arc_at='A', arc_text='θ',
               opp='3', adj='4', hyp='5'), None),

    (T, 8, 'trig_8.png',
     right_tri('trig_8.png', drawn=55, arc_at='A', arc_text='35°',
               hyp='10 cm', opp='?'),
     Ruler(10 * _sin(55), 5.7, [35.0, 5.7, 8.2, 7.0])),

    (T, 15, 'trig_15.png',
     right_tri('trig_15.png', drawn=55, arc_at='A', arc_text='32°',
               opp='8 cm', hyp='?'),
     Ruler(8 / _sin(55), 15.1, [9.4, 4.0, 4.2, 15.1])),

    (T, 16, 'trig_16.png',
     right_tri('trig_16.png', drawn=52, arc_at='A', arc_text='?',
               opp='5', adj='12'),
     Ruler(52.0, 22.6, [67.4, 22.6, 24.6, 0.4])),

    (T, 17, 'trig_17.png',
     right_tri('trig_17.png', drawn=30, arc_at='A', arc_text='θ = ?',
               opp='7', hyp='10'),
     Ruler(30.0, 44.4, [45.6, 44.4, 0.7, 35.0])),

    (T, 23, 'trig_23.png',
     right_tri('trig_23.png', drawn=55, arc_at='A', arc_text='?',
               hyp='15', opp='9'),
     Ruler(55.0, 36.9, [53.1, 0.6, 31.0, 36.9])),

    (T, 28, 'trig_28.png',
     right_tri('trig_28.png', drawn=42, arc_at='A', arc_text=None,
               letters=('B', 'A', 'C')), None),

    (T, 37, 'trig_37.png',
     right_tri('trig_37.png', drawn=30, arc_at='A', arc_text='45°',
               hyp='12', opp='?', adj='?'),
     Ruler(12 * _sin(30), 8.5, [6.0, 17.0, 8.5, 12.0])),

    # ---- family B ----
    (T, 18, 'trig_18.png',
     oblique_tri('trig_18.png', 'acute', arcs=('40°', '75°', None),
                 sides=('a = ?', 'b = 12 cm', None)), None),

    (T, 19, 'trig_19.png',
     oblique_tri('trig_19.png', 'acute', arcs=('?', '80°', None),
                 sides=('a = 9', 'b = 14', None)), None),

    (T, 20, 'trig_20.png',
     oblique_tri('trig_20.png', 'acute', arcs=('60°', None, None),
                 sides=('a = ?', 'b = 7', 'c = 9')), None),

    (T, 24, 'trig_24.png',
     oblique_tri('trig_24.png', 'acute', arcs=('35°', '65°', None),
                 sides=('a = 10 cm', None, 'c = ?')), None),

    (T, 25, 'trig_25.png',
     oblique_tri('trig_25.png', 'wide', letters=(None, None, None),
                 arcs=(None, None, '?'), sides=('5', '7', '10')),
     None),

    (T, 26, 'trig_26.png',
     oblique_tri('trig_26.png', 'obtuse', arcs=('120°', None, None),
                 sides=('a = ?', 'b = 6', 'c = 8')), None),

    (T, 32, 'trig_32.png',
     oblique_tri('trig_32.png', 'obtuse', arcs=('100°', '35°', None),
                 sides=('a = 14', 'b = ?', None)), None),

    (T, 33, 'trig_33.png',
     oblique_tri('trig_33.png', 'wide', letters=(None, None, None),
                 arcs=('?', '?', '?'), sides=('8', '11', '15'),
                 note='which angle is smallest?'), None),

    (T, 38, 'trig_38.png',
     oblique_tri('trig_38.png', 'wide', letters=(None, None, None),
                 arcs=(None, None, '?'), sides=('6', '6', '10'),
                 tick_sides=(0, 1)), None),

    (AG, 27, 'ag_27.png',
     oblique_tri('ag_27.png', 'acute',
                 cevian={'from_vertex': 2, 'to': 'mid',
                         'note': 'equal halves, and not a right angle'}),
     None),
]


def draw_windmill():
    """Windmill tower with one blade tip marked.

    The tower is stated at 40 m and the blades at 10 m. It is drawn with the
    blade THREE times too long relative to the tower, so a student who
    measures reads a maximum of about 70 m. The nearest option to 70 is 80 —
    a wrong one — and the answer, 50, is a long way from it.
    """
    fig, ax = fig_ax(6.0, 5.0)
    tower_h = 4.0            # stands for 40 m
    blade = 3.0              # stands for 10 m, drawn three times too long
    hub = (2.6, tower_h)
    seg(ax, (-0.6, 0), (5.8, 0), SOFT, 2.6)
    # tower, tapering
    ax.fill([hub[0] - 0.42, hub[0] + 0.42, hub[0] + 0.16, hub[0] - 0.16],
            [0, 0, tower_h, tower_h], color='#EDEFEE', edgecolor=INK, lw=2.0,
            zorder=2)
    for a in (90.0, 210.0, 330.0):
        tip = (hub[0] + blade * math.cos(math.radians(a)),
               hub[1] + blade * math.sin(math.radians(a)))
        seg(ax, hub, tip, ACCENT, 3.0)
    ax.plot([hub[0]], [hub[1]], 'o', color=INK, ms=9, zorder=6)
    top = (hub[0], hub[1] + blade)
    ax.plot([top[0]], [top[1]], 'o', color=HINT, ms=10, zorder=6)
    label(ax, (top[0] + 0.55, top[1]), 'tip', color=HINT, size=11)
    ax.annotate('', xy=(hub[0] - 1.5, tower_h), xytext=(hub[0] - 1.5, 0),
                arrowprops=dict(arrowstyle='<->', color=INK, lw=1.4))
    label(ax, (hub[0] - 1.95, tower_h / 2), '40 m', size=12.5, weight='bold')
    label(ax, (hub[0] + 0.42, hub[1] + blade / 2), '10 m', color=ACCENT,
          size=12.5, weight='bold')
    ax.set_xlim(-0.9, 6.1)
    ax.set_ylim(-0.9, tower_h + blade + 0.9)
    finish(fig, ax, 'mcr3u_trig_29.png')


def draw_ferris_wheel():
    """Ferris wheel with the boarding point at the bottom.

    The question asks for an EQUATION, and no drawing can state one, so
    there is no ruler test to register here. The radius and the centre
    height are both given in the text; the picture only settles which of
    them is which, and that a rider who boards at the bottom starts at the
    lowest point rather than the highest.
    """
    fig, ax = fig_ax(5.6, 5.2)
    R = 1.9
    centre = (2.6, 2.4)
    ax.add_patch(plt.Circle(centre, R, fill=False, edgecolor=INK, lw=2.4,
                            zorder=3))
    for a in range(0, 360, 45):
        t = (centre[0] + R * math.cos(math.radians(a)),
             centre[1] + R * math.sin(math.radians(a)))
        seg(ax, centre, t, SOFT, 1.2)
    seg(ax, (-0.4, 0), (5.6, 0), SOFT, 2.6)
    seg(ax, (centre[0], 0), centre, INK, 2.0, ls='--')
    ax.annotate('', xy=(centre[0] + R, centre[1]), xytext=centre,
                arrowprops=dict(arrowstyle='->', color=ACCENT, lw=2.0))
    label(ax, (centre[0] + R / 2, centre[1] + 0.34), '9 m', color=ACCENT,
          size=12.5, weight='bold')
    label(ax, (centre[0] - 0.68, 0.24), '11 m', size=12.5, weight='bold')
    ax.plot([centre[0]], [centre[1]], 'o', color=INK, ms=7, zorder=6)
    board = (centre[0], centre[1] - R)
    ax.plot([board[0]], [board[1]], 'o', color=HINT, ms=11, zorder=6)
    label(ax, (board[0] + 1.15, board[1]), 'board here', color=HINT,
          size=11)
    ax.set_xlim(-0.7, 5.9)
    ax.set_ylim(-0.8, centre[1] + R + 0.9)
    finish(fig, ax, 'mcr3u_trig_39.png')


def draw_pascal_rows():
    """The first four rows of Pascal triangle, with the row numbers written
    beside them.

    Question 20 asks WHICH row supplies the coefficients of a binomial power,
    and that question cannot be asked fairly without showing what a row
    number means. It stops at row 3 on purpose: row 4 would state the five
    entries question 10 asks for and the coefficients 1, 4, 6, 4, 1 that
    question 40 needs. There is nothing measurable here, so no ruler test.
    """
    fig, ax = fig_ax(6.0, 4.0)
    rows = [[1], [1, 1], [1, 2, 1], [1, 3, 3, 1]]
    dx, dy = 0.9, 0.85
    for i, row in enumerate(rows):
        y = -i * dy
        for j, v in enumerate(row):
            x = (j - (len(row) - 1) / 2.0) * dx
            ax.add_patch(plt.Circle((x, y), 0.3, facecolor='white',
                                    edgecolor=ACCENT, lw=1.6, zorder=3))
            label(ax, (x, y), str(v), size=13, weight='bold', color=INK)
        label(ax, (-2.9, y), 'row %d' % i, size=11.5, color=SOFT, ha='left')
    y = -len(rows) * dy
    for j in range(5):
        x = (j - 2) * dx
        label(ax, (x, y + 0.1), '?', size=14, color=SOFT)
    label(ax, (-2.9, y + 0.1), 'row 4', size=11.5, color=SOFT, ha='left')
    label(ax, (0.0, y - 0.62), 'and so on', size=11, color=SOFT)
    ax.set_xlim(-3.1, 2.4)
    ax.set_ylim(y - 1.1, 0.62)
    finish(fig, ax, 'mcr3u_disc_20.png')


def draw_ski_lodge():
    """A ski lodge built against a vertical cliff.

    Two right triangles share a brace. The cliff is the hypotenuse of the
    first, the brace is the hypotenuse of the second, and the base is what
    the question asks for. Which angle belongs to which triangle is the whole
    difficulty, and no amount of text makes that as clear as the picture.

    Deliberately out of proportion: the cliff is drawn 10 units for a stated
    15 m and the base 8 units, so measuring gives a base of about 12 m. The
    nearest option to 12 is 12.99, which is wrong; the answer is about 6.5.
    """
    fig, ax = fig_ax(6.6, 4.8)
    cliff_h = 10.0 * 0.42      # drawn height of the cliff
    base_w = 8.0 * 0.42        # drawn length of the base
    brace_h = cliff_h * 0.56   # where the brace meets the post

    V = (0.0, 0.0)                     # foot of the cliff
    W = (0.0, cliff_h)                 # top of the cliff
    Y = (base_w, 0.0)                  # far end of the base
    X = (base_w, brace_h)              # top of the post, where the roof lands

    # the cliff face, hatched
    ax.add_patch(plt.Rectangle((-0.5, 0), 0.5, cliff_h + 0.5,
                               facecolor='#E8E6DF', edgecolor=SOFT,
                               hatch='///', lw=1.4, zorder=2))
    seg(ax, (-0.7, 0), (base_w + 0.7, 0), SOFT, 2.6)      # ground
    seg(ax, V, W, ACCENT, 3.0)                            # cliff face, 15 m
    seg(ax, W, X, INK, 2.4)                               # roof
    seg(ax, X, Y, INK, 2.4)                               # post
    seg(ax, V, X, HINT, 2.0, ls='--')                     # brace
    seg(ax, V, Y, ACCENT, 3.0)                            # base, b
    right_angle(ax, Y, size=0.26, dx=-1, dy=1)

    vertex_arc(ax, V, W, X, text='π/3', r=0.95, size=11.5)
    vertex_arc(ax, V, X, Y, text='π/6', r=1.85, size=11.5)

    label(ax, (-0.92, cliff_h / 2), '15 m', color=ACCENT, size=12.5,
          weight='bold')
    label(ax, (base_w / 2, -0.42), 'b', color=ACCENT, size=14, weight='bold')
    label(ax, (base_w * 0.30, brace_h * 0.30 + 0.34), 'brace', color=HINT,
          size=10.5)
    label(ax, (-0.25, cliff_h + 0.62), 'cliff', color=SOFT, size=10.5)

    ax.set_xlim(-1.6, base_w + 1.0)
    ax.set_ylim(-0.95, cliff_h + 1.15)
    finish(fig, ax, 'mhf4u_trig_20.png')


def draw_ladder_wall_angle():
    """A ladder against a wall, with the angle marked at the WALL.

    Every ladder question a student has met before marks the angle at the
    ground. This one does not, and that is the entire trap — which is
    exactly why it needs a picture rather than a sentence.

    Drawn leaning about 32 degrees off the wall against a stated π/12, which
    is 15 degrees. A protractor and the stated 15 m therefore give a foot
    distance of about 8 m, whose nearest option is 9.19 — wrong. The answer
    is about 3.88.
    """
    fig, ax = fig_ax(5.4, 5.4)
    drawn = 32.0
    L = 5.2
    foot = L * math.sin(math.radians(drawn))
    top = L * math.cos(math.radians(drawn))
    ax.add_patch(plt.Rectangle((-0.55, 0), 0.55, top + 0.6,
                               facecolor='#E8E6DF', edgecolor=SOFT,
                               hatch='///', lw=1.4, zorder=2))
    seg(ax, (-0.75, 0), (foot + 1.0, 0), SOFT, 2.6)
    seg(ax, (0, 0), (0, top + 0.6), SOFT, 2.2)
    seg(ax, (0, top), (foot, 0), ACCENT, 3.2)
    right_angle(ax, (0, 0), size=0.3, dx=1, dy=1)
    angle_mark(ax, (0, top), -90.0, -90.0 + drawn, r=1.25, text='π/12',
               text_r=1.85, size=12)
    label(ax, (foot / 2 + 0.55, top / 2 + 0.32), '15 m', color=ACCENT,
          size=13, weight='bold')
    label(ax, (foot / 2, -0.44), 'x', size=14, weight='bold')
    label(ax, (-0.28, top + 0.85), 'wall', color=SOFT, size=10.5)
    ax.set_xlim(-1.0, foot + 1.3)
    ax.set_ylim(-0.95, top + 1.25)
    finish(fig, ax, 'mhf4u_trig_31.png')


# ===========================================================================
# The MCR3U register
# ===========================================================================
# Grade 11 figures. Filenames are prefixed mcr3u_ so they can never collide
# with the Grade 10 set in the same web/figures/ folder.
#
# Only five questions in MCR3U Unit 5 earn a picture. The reasoning, and the
# four families that were considered and rejected, is written out at the top
# of questions_mcr3u_u5.sql.

TG = 'Trig Geometry'
TF = 'Trig Functions'
DF = 'Discrete Functions'

FIGURES_MCR3U = [
    # Two angles given, third asked for. Drawn 52 and 83, so the third
    # measures 45 — a wrong option — while the answer 65 is 20 degrees away.
    (TG, 9, 'mcr3u_trig_9.png',
     angle_sum_tri('mcr3u_trig_9.png', drawn=(52.0, 83.0),
                   arcs=('40°', '75°', '?')),
     Ruler(45.0, 65.0, [65.0, 115.0, 45.0, 105.0])),

    # Sine law. The acute skeleton measures A = 60.7 and B = 45.0, and its
    # sides are 5.80 and 4.70 rather than the stated 8 and 12. Measuring
    # either the angles or the side lengths gives a = 14.8, whose nearest
    # option is 18.0 — wrong.
    (TG, 19, 'mcr3u_trig_19.png',
     oblique_tri('mcr3u_trig_19.png', 'acute', arcs=('40°', '75°', None),
                 sides=('a = ?', 'b = 12 cm', None)),
     Ruler(14.8, 8.0, [8.0, 18.0, 11.3, 7.7])),

    # Cosine law, SSS. The angle at A measures 60.7 in the drawing against a
    # true 117.3; the nearest option to 60.7 is 62.7 — wrong.
    #
    # This one breaks the usual SSS courtesy of keeping the drawn side ORDER
    # honest, and it has to. The true angle A is 117.3, so any drawing that
    # looks obtuse measures somewhere between 90 and 140, and every value in
    # that range rounds to 117.3 — the answer. Honest side order forces an
    # obtuse A; the ruler test forbids it. The ruler test wins, so A is drawn
    # acute and the side labels have to be read rather than eyeballed. That
    # is the harder skill anyway, and it is exactly what the two wrong-angle
    # distractors are there to catch.
    (TG, 26, 'mcr3u_trig_26.png',
     oblique_tri('mcr3u_trig_26.png', 'acute', arcs=('?', None, None),
                 sides=('a = 42 cm', 'b = 21 cm', 'c = 28 cm')),
     Ruler(60.7, 117.3, [117.3, 62.7, 26.4, 36.3])),

    # Tree and shadow, drawn at 35 degrees against a true 61.1.
    (TG, 27, 'mcr3u_trig_27.png', draw_tree_shadow,
     Ruler(35.0, 61.1, [61.1, 28.9, 33.5, 1.1])),

    # Balloon over the midpoint of two houses. Oblique projection; the
    # elevation measures about 20 degrees against a true 6.7.
    (TG, 38, 'mcr3u_trig_38.png', draw_balloon_two_houses,
     Ruler(20.2, 6.7, [6.7, 5.2, 10.4, 71.5])),

    # ---- Unit 6, Trig Functions ----
    # Only two questions in Unit 6 earn a picture, and both are scenes. Every
    # other question there is about a curve, and a curve on a grid has the
    # amplitude and the period countable off the squares.
    (TF, 29, 'mcr3u_trig_29.png', draw_windmill,
     # tower drawn 4.0 units for 40 m, blade drawn 3.0 for 10 m: a measurer
     # reads a maximum of 40 + 30 = 70 m, nearest option 80 (wrong)
     Ruler(70.0, 50.0, [50.0, 30.0, 40.0, 80.0])),

    # No ruler test: the answer is an equation, and no drawing states one.
    (TF, 39, 'mcr3u_trig_39.png', draw_ferris_wheel, None),

    # ---- Unit 7, Discrete Functions ----
    # No ruler test: there is no measurable quantity in a Pascal triangle,
    # and the figure deliberately stops before the row any question needs.
    (DF, 20, 'mcr3u_disc_20.png', draw_pascal_rows, None),
]


# ===========================================================================
# The MHF4U register
# ===========================================================================
# Grade 12 Advanced Functions. Almost nothing in this course earns a picture:
# it is polynomials, logs and trig identities, and every candidate figure is
# a curve on a grid with the answer countable off the axes. The one exception
# is the ski lodge, where the arrangement of the two nested right triangles
# IS the question.

TR = 'Trig in Radians'
TI = 'Trig Identities and Equations'

FIGURES_MHF4U = [
    # Cliff drawn 10 units for a stated 15 m, base drawn 8 units: measuring
    # gives about 12 m, whose nearest option is 12.99 — wrong. Answer 6.50.
    (TR, 20, 'mhf4u_trig_20.png', draw_ski_lodge,
     Ruler(12.0, 6.50, [6.50, 12.99, 7.50, 25.98])),

    # ---- Unit 5, Trig Identities and Equations ----
    # Ladder drawn 32 degrees off the wall against a stated 15 degrees:
    # measuring gives a foot distance of about 8 m, nearest option 9.19
    # (wrong). Answer 3.88.
    (TI, 31, 'mhf4u_trig_31.png', draw_ladder_wall_angle,
     Ruler(15.0 * math.sin(math.radians(32.0)), 3.882,
           [3.882, 14.489, -3.882, 9.186])),
]


# ---------------------------------------------------------------------------
# Family six: a position-time curve with no vertical scale
# ---------------------------------------------------------------------------

def draw_position_time():
    """The graph of s(t) = t^3 - 12t^2 + 36t on 0 <= t <= 8.

    This is the one figure in MCV4U Unit 1, and it earns its place because the
    question cannot be asked without it: given the SHAPE of a position-time
    curve, decide where the particle is speeding up. That is a judgement about
    the sign of the slope multiplied by the sign of the concavity, and both of
    those live in the picture.

    It cannot leak. There is no vertical scale and no grid, so no s-value can
    be counted off and the curve cannot be reverse engineered into an
    equation. The t-axis carries the four boundary marks the options refer to
    and nothing else. A student who wants the answer has to look at whether
    the curve is rising or falling and whether it is bending up or down.
    """
    fig, ax = plt.subplots(figsize=(6.4, 4.4), dpi=125)
    ax.axis('off')

    ts = [i * 8.0 / 400 for i in range(401)]
    ss = [t ** 3 - 12 * t ** 2 + 36 * t for t in ts]
    lo, hi = min(ss), max(ss)
    span = hi - lo

    ax.plot(ts, ss, color=ACCENT, lw=3.0, solid_capstyle='round', zorder=3)

    # the t-axis, with only the four interval boundaries marked
    base = lo - 0.16 * span
    ax.plot([-0.35, 8.5], [base, base], color=SOFT, lw=2.0, zorder=2)
    ax.annotate('', xy=(8.75, base), xytext=(8.5, base),
                arrowprops=dict(arrowstyle='-|>', color=SOFT, lw=2.0))
    for mark in (2, 4, 6, 8):
        ax.plot([mark, mark], [base - 0.035 * span, base + 0.035 * span],
                color=SOFT, lw=2.0, zorder=2)
        ax.text(mark, base - 0.10 * span, str(mark), ha='center', va='top',
                fontsize=11, color=INK)
    ax.text(8.95, base, 't', ha='left', va='center', fontsize=12,
            color=SOFT, style='italic')

    # the s-axis: a bare arrow. No ticks, no numbers, nothing to count.
    ax.plot([0, 0], [base, hi + 0.10 * span], color=SOFT, lw=2.0, zorder=2)
    ax.annotate('', xy=(0, hi + 0.20 * span), xytext=(0, hi + 0.10 * span),
                arrowprops=dict(arrowstyle='-|>', color=SOFT, lw=2.0))
    ax.text(-0.30, hi + 0.16 * span, 's(t)', ha='right', va='center',
            fontsize=12, color=ACCENT, style='italic')

    ax.set_xlim(-1.4, 9.6)
    ax.set_ylim(base - 0.30 * span, hi + 0.34 * span)
    finish(fig, ax, 'mcv4u_motion_29.png')


def draw_extrema_points():
    """A curve on a closed interval with five labelled points.

    The question is which point is the ABSOLUTE maximum, and the whole
    difficulty is that the tallest LOCAL maximum is not it: the curve starts
    at the left-hand end higher than any peak it later reaches. A student who
    has learnt to hunt for turning points and stop picks C. A student who
    remembers that endpoints compete picks A.

    Built segment by segment so the five labelled points are exactly the
    features they are meant to be. The three interior joints use a half
    cosine, which arrives and leaves with zero slope, so B, C and D are
    genuine turning points rather than shoulders. The first and last segments
    use profiles that are flat at the interior end and sloped at the outer
    one, so A and E read as ends of the interval and not as turning points.

    No grid and no vertical scale, so nothing can be counted off. The
    relative heights are the content of the question, not a leak: reading
    which point sits highest IS the skill, and the mistake being tested is
    conceptual, not a misreading.
    """
    fig, ax = plt.subplots(figsize=(6.6, 4.2), dpi=125)
    ax.axis('off')

    KNOTS = [(0.0, 8.5), (2.5, 3.0), (5.0, 7.0), (7.5, 1.5), (10.0, 5.5)]

    def curve(t):
        for i in range(4):
            t0, y0 = KNOTS[i]
            t1, y1 = KNOTS[i + 1]
            if t <= t1 or i == 3:
                u = (t - t0) / (t1 - t0)
                if i == 0:                       # sloped at A, flat into B
                    g = 2 * u - u * u
                elif i == 3:                     # flat out of D, sloped at E
                    g = u * u
                else:                            # flat at both ends
                    g = (1 - math.cos(math.pi * u)) / 2
                return y0 + (y1 - y0) * g
        return KNOTS[-1][1]

    ts = [i * 10.0 / 800 for i in range(801)]
    ys = [curve(t) for t in ts]
    ax.plot(ts, ys, color=ACCENT, lw=3.0, solid_capstyle='round', zorder=3)

    lo, hi = min(ys), max(ys)
    span = hi - lo
    marks = [('A', 0.0, 'left', 'bottom'), ('B', 2.5, 'center', 'top'),
             ('C', 5.0, 'center', 'bottom'), ('D', 7.5, 'center', 'top'),
             ('E', 10.0, 'right', 'bottom')]
    for name, t, ha, va in marks:
        y = curve(t)
        ax.plot([t], [y], 'o', color=HINT, ms=8, zorder=4)
        dy = 0.08 * span if va == 'bottom' else -0.08 * span
        ax.text(t, y + dy, name, ha=ha, va=va, fontsize=13, color=INK,
                fontweight='bold')

    base = lo - 0.34 * span
    ax.plot([0, 10], [base, base], color=SOFT, lw=2.0, zorder=2)
    for mark in (0, 10):
        ax.plot([mark, mark], [base - 0.04 * span, base + 0.04 * span],
                color=SOFT, lw=2.0, zorder=2)
        ax.text(mark, base - 0.10 * span, str(mark), ha='center', va='top',
                fontsize=11, color=INK)
    ax.text(5, base - 0.10 * span, 'closed interval', ha='center', va='top',
            fontsize=10, color=SOFT, style='italic')

    ax.set_xlim(-1.0, 11.0)
    ax.set_ylim(base - 0.40 * span, hi + 0.26 * span)
    finish(fig, ax, 'mcv4u_extrema_08.png')


def draw_beach_rectangle():
    """The lifeguard rectangle: rope on three sides, beach on the fourth.

    The picture carries the one fact the words make heavy work of - which
    side is NOT roped - and it labels the two equal sides x and the third
    side with a question mark, which is exactly what the question asks for.

    Drawn deliberately close to square, at about 1.25 to 1. The real answer
    is 2 to 1, so a student who measures the drawing and assumes it is to
    scale gets the wrong shape. Nothing on it carries a number, so there is
    no ruler test to register; this note is the record that the proportion
    was chosen against the answer rather than towards it.
    """
    fig, ax = fig_ax(6.4, 4.0)
    w, h = 5.0, 4.0

    ax.add_patch(plt.Rectangle((-0.6, h), w + 1.2, 0.75,
                               facecolor='#F2EBD8', edgecolor=SOFT,
                               hatch='...', lw=1.4, zorder=1))
    ax.text(w / 2, h + 0.36, 'beach', ha='center', va='center', fontsize=12,
            color=SOFT, style='italic', zorder=2)

    seg(ax, (0, h), (0, 0), ACCENT, 3.2)
    seg(ax, (0, 0), (w, 0), ACCENT, 3.2)
    seg(ax, (w, 0), (w, h), ACCENT, 3.2)
    seg(ax, (0, h), (w, h), SOFT, 1.6, ls='--')

    label(ax, (-0.35, h / 2), 'x', ACCENT, 14, ha='right')
    label(ax, (w + 0.35, h / 2), 'x', ACCENT, 14, ha='left')
    label(ax, (w / 2, -0.40), '?', ACCENT, 15)
    label(ax, (w / 2, h / 2), 'swimming area', SOFT, 11)

    ax.set_xlim(-1.5, w + 1.5)
    ax.set_ylim(-1.1, h + 1.3)
    finish(fig, ax, 'mcv4u_optim_10.png')


def draw_derivative_graph():
    """The graph of f PRIME, not of f.

    An upward parabola crossing the axis at two marked values. The question
    asks where f itself has a local maximum, and the answer is the crossing
    where f prime goes from positive to negative - the LEFT one. A student
    who reads the picture as the graph of f picks the vertex instead, which
    is why the vertex is drawn as a visible low point.

    No vertical scale and no grid: only the two crossings are named, and the
    names are letters rather than numbers so nothing can be computed off the
    drawing. The reasoning is a sign change, which is exactly what the
    picture shows and nothing else.
    """
    fig, ax = plt.subplots(figsize=(6.4, 4.2), dpi=125)
    ax.axis('off')

    a, b = -1.0, 3.0
    xs = [-2.6 + i * 5.8 / 400 for i in range(401)]
    ys = [0.62 * (t - a) * (t - b) for t in xs]
    ax.plot(xs, ys, color=ACCENT, lw=3.0, solid_capstyle='round', zorder=3)

    lo, hi = min(ys), max(ys)
    ax.plot([-2.9, 3.5], [0, 0], color=SOFT, lw=2.0, zorder=2)
    ax.annotate('', xy=(3.8, 0), xytext=(3.5, 0),
                arrowprops=dict(arrowstyle='-|>', color=SOFT, lw=2.0))
    ax.text(3.95, 0, 'x', ha='left', va='center', fontsize=12, color=SOFT,
            style='italic')

    for name, t in (('p', a), ('q', b)):
        ax.plot([t], [0], 'o', color=HINT, ms=8, zorder=4)
        ax.text(t, -0.09 * (hi - lo), name, ha='center', va='top',
                fontsize=13, color=INK, fontweight='bold')

    ax.text(0.35, hi * 0.86, 'y = f prime of x', ha='left', va='center',
            fontsize=12, color=ACCENT, style='italic')

    ax.set_xlim(-3.3, 4.4)
    ax.set_ylim(lo - 0.22 * (hi - lo), hi + 0.22 * (hi - lo))
    finish(fig, ax, 'mcv4u_deriv_18.png')


# ---------------------------------------------------------------------------
# Family seven: vector diagrams
# ---------------------------------------------------------------------------

def draw_resolution_triangle():
    """A force resolved into its horizontal and vertical components.

    Carries no numbers at all. The question asks which of cosine or sine
    gives the HORIZONTAL component, and the only way to answer it is to see
    which side of the right triangle sits next to the marked angle. A
    sentence describing this picture takes four lines and is still worse
    than the picture.

    Nothing here is measurable into a number, so there is no ruler test.
    """
    fig, ax = fig_ax(6.2, 4.0)
    L, th = 5.2, math.radians(36.0)
    O = (0.0, 0.0)
    H = (L * math.cos(th), 0.0)
    T = (L * math.cos(th), L * math.sin(th))

    arrow(ax, O, T, ACCENT, 3.0)                    # the force itself
    arrow(ax, O, H, HINT, 2.4, ls='--')             # horizontal component
    arrow(ax, H, T, '#3E6FA8', 2.4, ls='--')        # vertical component

    ax.add_patch(plt.Rectangle((H[0] - 0.30, 0.0), 0.30, 0.30,
                               fill=False, edgecolor=SOFT, lw=1.6, zorder=4))
    ax.add_patch(Arc(O, 1.7, 1.7, theta1=0, theta2=36.0, color=SOFT, lw=1.8))
    label(ax, (1.20, 0.28), 'theta', SOFT, 12, ha='left')

    label(ax, (T[0] / 2 - 0.35, T[1] / 2 + 0.32), 'f', ACCENT, 15)
    label(ax, (H[0] / 2, -0.42), 'horizontal component', HINT, 11)
    label(ax, (H[0] + 0.25, T[1] / 2), 'vertical', '#3E6FA8', 11, ha='left')
    label(ax, (H[0] + 0.25, T[1] / 2 - 0.38), 'component', '#3E6FA8', 11,
          ha='left')

    ax.set_xlim(-0.9, H[0] + 2.6)
    ax.set_ylim(-1.1, T[1] + 0.9)
    finish(fig, ax, 'mcv4u_vect_06.png')


def draw_vector_triangle():
    """Three vectors closing a triangle, head to tail.

    u runs from A to B, v runs from B to C, and w runs from A straight to C.
    The question asks which equation the picture shows, and the answer is
    settled entirely by where the arrowheads sit. No lengths are asked for
    and none are given, so there is nothing to measure.
    """
    fig, ax = fig_ax(6.2, 4.0)
    A = (0.0, 0.0)
    B = (3.4, 2.5)
    C = (6.4, 0.9)

    arrow(ax, A, B, ACCENT, 3.0)
    arrow(ax, B, C, '#3E6FA8', 3.0)
    arrow(ax, A, C, HINT, 3.0)

    label(ax, (A[0] - 0.34, A[1] - 0.20), 'A', INK, 13)
    label(ax, (B[0] - 0.10, B[1] + 0.38), 'B', INK, 13)
    label(ax, (C[0] + 0.36, C[1] - 0.02), 'C', INK, 13)

    label(ax, (1.30, 1.62), 'u', ACCENT, 15)
    label(ax, (5.20, 2.06), 'v', '#3E6FA8', 15)
    label(ax, (3.20, 0.10), 'w', HINT, 15)

    ax.set_xlim(-1.0, 7.4)
    ax.set_ylim(-0.9, 3.5)
    finish(fig, ax, 'mcv4u_vect_13.png')


def draw_two_ropes():
    """A mass hung from a ceiling by two ropes at different angles.

    Which angle belongs to which rope, and that both ropes pull upward and
    inward, is what the picture is for. In words it takes a paragraph and
    students still draw it wrong.

    Deliberately out of proportion. The rope LABELLED 60 degrees is drawn at
    about 42, and the one labelled 45 is drawn at about 62. A student who
    measures the drawing and trusts it computes a tension of about 95 N for
    the first rope. The nearest option to 95 is 98, which is wrong; the
    answer is about 143.5.
    """
    fig, ax = fig_ax(6.6, 4.2)
    drawn_left, drawn_right = 42.0, 62.0        # NOT the stated 60 and 45
    Lrope = 4.0

    M = (0.0, 0.0)                              # the mass hangs here
    Lp = (-Lrope * math.cos(math.radians(drawn_left)),
          Lrope * math.sin(math.radians(drawn_left)))
    Rp = (Lrope * math.cos(math.radians(drawn_right)),
          Lrope * math.sin(math.radians(drawn_right)))
    top = max(Lp[1], Rp[1])

    # the ceiling
    ax.add_patch(plt.Rectangle((Lp[0] - 1.0, top), (Rp[0] - Lp[0]) + 2.0, 0.55,
                               facecolor='#E8E6DF', edgecolor=SOFT,
                               hatch='///', lw=1.4, zorder=1))
    seg(ax, (Lp[0] - 1.0, top), (Rp[0] + 1.0, top), SOFT, 2.2)

    # both ropes drawn from the ceiling down to the mass
    seg(ax, (Lp[0], top), M, ACCENT, 2.8)
    seg(ax, (Rp[0], top), M, ACCENT, 2.8)

    ax.add_patch(Arc((Lp[0], top), 1.9, 1.9, theta1=-drawn_left - 6, theta2=0,
                     color=HINT, lw=1.8))
    label(ax, (Lp[0] + 1.20, top - 0.46), '60 deg', HINT, 12, ha='left')
    ax.add_patch(Arc((Rp[0], top), 1.9, 1.9, theta1=180,
                     theta2=180 + drawn_right + 6, color=HINT, lw=1.8))
    label(ax, (Rp[0] - 1.20, top - 0.56), '45 deg', HINT, 12, ha='right')

    ax.add_patch(plt.Rectangle((M[0] - 0.62, M[1] - 1.05), 1.24, 1.05,
                               facecolor=WATER, edgecolor=INK, lw=2.0,
                               zorder=3))
    label(ax, (M[0], M[1] - 0.52), '20 kg', INK, 12)

    ax.set_xlim(Lp[0] - 1.6, Rp[0] + 1.6)
    ax.set_ylim(M[1] - 1.9, top + 1.1)
    finish(fig, ax, 'mcv4u_vect_27.png')


def draw_ramp_box():
    """A box at rest on an incline, with its weight resolved.

    The picture fixes which component runs DOWN the slope and which presses
    INTO it, and shows that the angle at the foot of the ramp reappears
    between the weight and the perpendicular. Students working from the
    words alone routinely swap the sine and the cosine.

    The ramp is LABELLED 20 degrees and drawn at about 35. A student who
    measures it and trusts the drawing computes a component along the slope
    of about 80 N. The nearest option to 80 is 51.0, which is wrong; the
    answer is about 47.9.
    """
    fig, ax = fig_ax(7.0, 4.6)
    ang = 35.0                                   # drawn, NOT the stated 20
    a = math.radians(ang)
    base = 7.0

    F = (0.0, 0.0)                               # foot of the ramp, at right
    Bk = (-base, 0.0)                            # back of the ramp
    Tp = (-base, base * math.tan(a))             # top of the ramp

    seg(ax, Bk, F, SOFT, 1.8, ls='--')           # the ground
    seg(ax, Bk, Tp, SOFT, 1.8, ls='--')          # the vertical back
    seg(ax, F, Tp, INK, 3.2)                     # the slope surface

    ax.add_patch(Arc(F, 3.0, 3.0, theta1=180 - ang, theta2=180,
                     color=HINT, lw=1.8))
    label(ax, (-2.30, 0.62), '20 deg', HINT, 12, ha='right')

    # the box, high on the slope so its arrows have room below
    mid = (-base * 0.62, base * 0.62 * math.tan(a))
    ax.add_patch(plt.Rectangle((mid[0] - 0.80, mid[1] + 0.04), 1.6, 1.05,
                               angle=ang, rotation_point='center',
                               facecolor=WATER, edgecolor=INK, lw=2.0,
                               zorder=3))

    W = (mid[0], mid[1] + 0.55)                  # centre of the box
    arrow(ax, W, (W[0], W[1] - 2.9), ACCENT, 3.0)
    label(ax, (W[0] - 0.30, W[1] - 3.05), '140 N', ACCENT, 12, ha='right')

    # down the slope points RIGHT and down; into the slope is 90 further round
    down = (math.cos(math.radians(-ang)), math.sin(math.radians(-ang)))
    into = (math.cos(math.radians(-ang - 90)), math.sin(math.radians(-ang - 90)))
    arrow(ax, W, (W[0] + 2.0 * down[0], W[1] + 2.0 * down[1]), HINT, 2.2, ls='--')
    arrow(ax, W, (W[0] + 2.0 * into[0], W[1] + 2.0 * into[1]), '#3E6FA8', 2.2,
          ls='--')
    label(ax, (W[0] + 2.35 * down[0] + 0.20, W[1] + 2.35 * down[1] + 0.34),
          '?', HINT, 16)
    label(ax, (W[0] + 2.35 * into[0] - 0.42, W[1] + 2.35 * into[1] - 0.10),
          '?', '#3E6FA8', 16)

    ax.set_xlim(-base - 1.4, 2.2)
    ax.set_ylim(-4.2, Tp[1] + 1.0)
    finish(fig, ax, 'mcv4u_vect_39.png')


def draw_projection():
    """The projection of one vector onto another.

    Two vectors from a common tail, with a dashed perpendicular dropped from
    the head of a onto the line carrying b, and the piece of that line from
    the tail to the foot picked out. The question asks which formula produces
    that piece, and the picture is what makes clear that it lies ALONG b
    rather than along a.

    No numbers anywhere, so there is nothing to measure and no ruler test.
    """
    fig, ax = fig_ax(6.4, 4.0)
    O = (0.0, 0.0)
    A = (3.1, 3.0)
    B = (5.8, 0.9)

    bx, by = B
    bb = bx * bx + by * by
    t = (A[0] * bx + A[1] * by) / bb
    Foot = (t * bx, t * by)

    seg(ax, O, Foot, '#C6DCC9', 9.0)              # the projection, highlighted
    arrow(ax, O, B, '#3E6FA8', 3.0)
    arrow(ax, O, A, ACCENT, 3.0)
    seg(ax, A, Foot, SOFT, 1.8, ls='--')          # the perpendicular
    arrow(ax, O, Foot, HINT, 3.0)

    label(ax, (A[0] - 0.28, A[1] + 0.34), 'a', ACCENT, 15)
    label(ax, (B[0] + 0.34, B[1] + 0.08), 'b', '#3E6FA8', 15)
    label(ax, (Foot[0] * 0.52, Foot[1] * 0.52 - 0.60), 'this piece', HINT, 11)

    ax.set_xlim(-1.0, 7.0)
    ax.set_ylim(-1.5, 4.0)
    finish(fig, ax, 'mcv4u_vect_25.png')


def draw_right_hand_rule():
    """Two vectors lying in the plane of the page, from a common tail.

    The question asks which way a cross b points, and the only way to answer
    it is to apply the right-hand rule to the arrangement shown. Nothing on
    the figure names a direction, and there are no numbers on it, so it can
    neither leak nor be measured.

    a is drawn along the horizontal and b above it, so curling from a to b
    is counter-clockwise. What that means for the thumb is left to the
    student.
    """
    fig, ax = fig_ax(6.2, 4.0)
    O = (0.0, 0.0)
    A = (5.2, 0.0)
    B = (3.0, 3.4)

    arrow(ax, O, A, ACCENT, 3.2)
    arrow(ax, O, B, '#3E6FA8', 3.2)
    ax.add_patch(Arc(O, 3.0, 3.0, theta1=0, theta2=48.6, color=SOFT, lw=1.6,
                     ls='--'))

    label(ax, (A[0] + 0.34, A[1] - 0.04), 'a', ACCENT, 15)
    label(ax, (B[0] - 0.06, B[1] + 0.38), 'b', '#3E6FA8', 15)
    label(ax, (2.6, -0.95), 'both vectors lie in the plane of the page', SOFT,
          11)

    ax.set_xlim(-1.0, 6.4)
    ax.set_ylim(-1.7, 4.2)
    finish(fig, ax, 'mcv4u_vect_28.png')


def draw_wrench():
    """A wrench on a bolt, with a force applied at the far end of the handle.

    The picture fixes what the arm is measured from and where the angle
    between the arm and the force sits. In words that takes a paragraph and
    students still put the angle between the force and the vertical.

    The angle is LABELLED 80 degrees and drawn at about 30. A student who
    measures the drawing and trusts it computes a torque of about 6.0 N m.
    The nearest option to 6.0 is 2.08, which is wrong; the answer is about
    11.82. Sine is flat near 90 degrees, so a mild distortion would not have
    been enough here: anything drawn above about 55 degrees rounds back to
    the correct answer, and the drawn angle had to go well below that for
    the test to bite.
    """
    fig, ax = fig_ax(6.8, 4.0)
    drawn = 30.0                                  # NOT the stated 80
    handle = 5.4

    Bolt = (0.0, 0.0)
    End = (handle, 0.0)

    ax.add_patch(plt.Circle(Bolt, 0.62, facecolor='#E8E6DF', edgecolor=INK,
                            lw=2.2, zorder=3))
    ax.add_patch(plt.Circle(Bolt, 0.30, facecolor='white', edgecolor=INK,
                            lw=1.8, zorder=4))
    seg(ax, (0.55, -0.22), (End[0] + 0.35, -0.22), INK, 2.4)
    seg(ax, (0.55, 0.22), (End[0] + 0.35, 0.22), INK, 2.4)
    seg(ax, (End[0] + 0.35, -0.22), (End[0] + 0.35, 0.22), INK, 2.4)

    arrow(ax, Bolt, End, HINT, 2.6, ls='--')
    label(ax, (handle / 2, 0.58), 'r = 20 cm', HINT, 12)

    a = math.radians(drawn)
    Ftip = (End[0] + 3.0 * math.cos(-a), End[1] + 3.0 * math.sin(-a))
    arrow(ax, End, Ftip, ACCENT, 3.0)
    label(ax, (Ftip[0] + 0.30, Ftip[1] - 0.28), 'F = 60 N', ACCENT, 12,
          ha='left')

    ax.add_patch(Arc(End, 2.0, 2.0, theta1=-drawn, theta2=0, color=SOFT,
                     lw=1.8))
    label(ax, (End[0] + 1.32, -0.56), '80 deg', SOFT, 12, ha='left')

    ax.set_xlim(-1.4, End[0] + 4.8)
    ax.set_ylim(-3.2, 1.8)
    finish(fig, ax, 'mcv4u_vect_39b.png')


def draw_line_vector_equation():
    """The picture behind the vector equation of a line.

    A line L, the origin, and four labelled vectors. Exactly ONE of them
    lies along L, and the question asks which. The others are two position
    vectors reaching points on the line from the origin, and a vector from
    the origin that misses the line altogether.

    This is where the whole vector equation of a line comes from, and where
    students go wrong: a position vector to a point ON the line is not a
    direction vector FOR the line, however much it looks like one when both
    are drawn from the same origin.

    No coordinates, no grid, no numbers. Nothing to count and nothing to
    measure, so there is no ruler test.
    """
    fig, ax = fig_ax(6.8, 4.4)

    O = (0.0, 0.0)
    P0 = (1.6, 2.4)
    P1 = (5.0, 3.9)
    Off = (4.6, 0.7)                     # a point that is NOT on the line

    # the line itself, drawn well past both marked points
    dx, dy = P1[0] - P0[0], P1[1] - P0[1]
    seg(ax, (P0[0] - 0.75 * dx, P0[1] - 0.75 * dy),
        (P1[0] + 0.45 * dx, P1[1] + 0.45 * dy), INK, 2.4)
    label(ax, (P1[0] + 0.45 * dx + 0.30, P1[1] + 0.45 * dy + 0.10), 'L', INK,
          14, ha='left')

    arrow(ax, O, P0, '#3E6FA8', 2.8)          # position vector to a point on L
    arrow(ax, O, P1, '#8A5FA8', 2.8)          # position vector to another point
    arrow(ax, P0, P1, HINT, 3.2)              # the one lying ALONG L
    arrow(ax, O, Off, ACCENT, 2.8)            # misses the line entirely

    ax.plot([P0[0], P1[0]], [P0[1], P1[1]], 'o', color=INK, ms=6, zorder=4)
    ax.plot([O[0]], [O[1]], 'o', color=SOFT, ms=6, zorder=4)
    label(ax, (-0.34, -0.30), 'O', SOFT, 12)

    label(ax, (0.52, 1.62), 'p', '#3E6FA8', 15)
    label(ax, (2.90, 2.42), 'q', '#8A5FA8', 15)
    label(ax, (3.20, 3.62), 'r', HINT, 15)
    label(ax, (2.30, 0.14), 's', ACCENT, 15)

    ax.set_xlim(-1.2, 7.6)
    ax.set_ylim(-1.0, 5.4)
    finish(fig, ax, 'mcv4u_line_01.png')


# ---------------------------------------------------------------------------
# Family eight: statistical displays
# ---------------------------------------------------------------------------

def draw_truncated_bars():
    """A bar chart whose vertical axis does not start at zero.

    Three values that are within a few per cent of one another, drawn on an
    axis that begins at 85. The bars come out looking roughly one, two and
    three units tall, so the middle region appears to sell twice what the
    first does when in truth it sells about four per cent more.

    The axis IS labelled, and honestly: 85, 90, 95, 100. That is the whole
    point. The question asks what makes the chart misleading, and the answer
    is a fact about the drawing that a reader has to notice rather than be
    told. Nothing on the figure uses the word truncated, and no option can
    be reached by measuring the bars, because the answer is a sentence.
    """
    fig, ax = plt.subplots(figsize=(6.2, 4.2), dpi=125)
    ax.axis('off')

    LOW, HIGH = 85.0, 100.0
    data = [('North', 88.0), ('Central', 92.0), ('South', 96.0)]
    W = 1.0
    GAP = 0.55

    def h(v):
        return (v - LOW) / (HIGH - LOW) * 4.6

    for i, (name, v) in enumerate(data):
        x = i * (W + GAP)
        ax.add_patch(plt.Rectangle((x, 0), W, h(v), facecolor=ACCENT,
                                   edgecolor=INK, lw=1.4, zorder=3))
        ax.text(x + W / 2, -0.22, name, ha='center', va='top', fontsize=11,
                color=INK)

    right = 2 * (W + GAP) + W
    ax.plot([-0.28, -0.28], [0, 4.9], color=SOFT, lw=2.0, zorder=2)
    ax.plot([-0.28, right + 0.30], [0, 0], color=SOFT, lw=2.0, zorder=2)
    for v in (85, 90, 95, 100):
        y = h(float(v))
        ax.plot([-0.42, -0.28], [y, y], color=SOFT, lw=1.8, zorder=2)
        ax.text(-0.55, y, str(v), ha='right', va='center', fontsize=10,
                color=INK)

    ax.text(right / 2, 5.35, 'Units sold (thousands)', ha='center',
            va='center', fontsize=12, color=INK)

    ax.set_xlim(-1.8, right + 0.9)
    ax.set_ylim(-1.2, 6.0)
    finish(fig, ax, 'mdm4u_stat_10.png', note=False)


def draw_curved_scatter():
    """A scatter plot whose points follow a clear curve.

    Every point sits close to a symmetric U, so the relationship between the
    two variables could hardly be tighter. The correlation coefficient of
    that same data is almost zero, because the best straight line through a
    symmetric U is flat.

    The axes carry no numbers and there is no grid, so nothing can be
    counted off and no coefficient can be reconstructed. What the picture
    supplies is the SHAPE, and the shape is the whole question.
    """
    fig, ax = plt.subplots(figsize=(6.2, 4.2), dpi=125)
    ax.axis('off')

    # a symmetric parabola, sampled evenly, with a small deterministic wobble
    pts = []
    for i in range(19):
        x = -3.0 + i * 6.0 / 18
        wob = 0.16 * math.sin(4.7 * i + 1.3)
        pts.append((x, 0.62 * x * x + wob))

    ax.plot([p[0] for p in pts], [p[1] for p in pts], 'o', color=ACCENT,
            ms=7, zorder=3)

    lo = min(p[1] for p in pts)
    hi = max(p[1] for p in pts)
    base = lo - 0.55
    ax.plot([-3.6, 3.6], [base, base], color=SOFT, lw=2.0, zorder=2)
    ax.annotate('', xy=(3.9, base), xytext=(3.6, base),
                arrowprops=dict(arrowstyle='-|>', color=SOFT, lw=2.0))
    ax.text(4.1, base, 'x', ha='left', va='center', fontsize=12, color=SOFT,
            style='italic')
    ax.plot([-3.6, -3.6], [base, hi + 0.7], color=SOFT, lw=2.0, zorder=2)
    ax.annotate('', xy=(-3.6, hi + 1.0), xytext=(-3.6, hi + 0.7),
                arrowprops=dict(arrowstyle='-|>', color=SOFT, lw=2.0))
    ax.text(-3.85, hi + 0.85, 'y', ha='right', va='center', fontsize=12,
            color=SOFT, style='italic')

    ax.set_xlim(-4.8, 4.8)
    ax.set_ylim(base - 0.9, hi + 1.5)
    finish(fig, ax, 'mdm4u_stat_17.png', note=False)


# ===========================================================================
# The MCV4U register
# ===========================================================================
# Grade 12 Calculus and Vectors. Unit 1 is symbolic differentiation, and a
# drawn curve with a tangent on it would let a student count the rise over
# the run instead of differentiating — so there is exactly one figure, for
# the one question whose whole content is reading a shape. Units 4 to 6 are
# vectors and will need considerably more.

DR = 'Derivative Rules'
CS = 'Curve Sketching'
GV = 'Geometric Vectors'
AV = 'Algebraic Vectors'
LP = 'Lines and Planes'

FIGURES_MCV4U = [
    # No ruler test on any of these four: nothing on them is measurable into
    # a number. Every answer is a letter, an interval or an expression, and
    # every one of them comes from a sign change the picture shows and does
    # not label.

    # ---- Unit 1, Derivative Rules ----
    (DR, 29, 'mcv4u_motion_29.png', draw_position_time, None),

    # ---- Unit 2, Curve Sketching ----
    (CS,  8, 'mcv4u_extrema_08.png', draw_extrema_points, None),
    (CS, 10, 'mcv4u_optim_10.png', draw_beach_rectangle, None),
    (CS, 18, 'mcv4u_deriv_18.png', draw_derivative_graph, None),

    # ---- Unit 4, Geometric Vectors ----
    # The first two carry no numbers at all, so there is nothing to measure.
    (GV,  6, 'mcv4u_vect_06.png', draw_resolution_triangle, None),
    (GV, 13, 'mcv4u_vect_13.png', draw_vector_triangle, None),

    # Ropes labelled 60 and 45 but drawn at 42 and 62: measuring gives about
    # 95 N, whose nearest option is 98.0 — wrong. Answer 143.5.
    (GV, 27, 'mcv4u_vect_27.png', draw_two_ropes,
     Ruler(94.83, 143.48, [143.48, 101.46, 98.0, 196.0])),

    # Ramp labelled 20 degrees but drawn at 35: measuring gives about 80 N,
    # whose nearest option is 51.0 — wrong. Answer 47.9.
    (GV, 39, 'mcv4u_vect_39.png', draw_ramp_box,
     Ruler(140.0 * math.sin(math.radians(35.0)), 47.88,
           [47.88, 131.56, 140.0, 50.96])),

    # ---- Unit 5, Algebraic Vectors ----
    # The first two carry no numbers at all, so there is nothing to measure.
    (AV, 25, 'mcv4u_vect_25.png', draw_projection, None),
    (AV, 28, 'mcv4u_vect_28.png', draw_right_hand_rule, None),

    # Wrench angle labelled 80 degrees but drawn at 30: measuring gives about
    # 6.0 N m, whose nearest option is 2.08 — wrong. Answer 11.82.
    (AV, 39, 'mcv4u_vect_39b.png', draw_wrench,
     Ruler(0.20 * 60 * math.sin(math.radians(30.0)), 11.82,
           [11.82, 12.00, 2.08, 1181.77])),

    # ---- Unit 6, Lines and Planes ----
    # No numbers, no grid: the answer is which arrow lies along the line.
    (LP, 1, 'mcv4u_line_01.png', draw_line_vector_equation, None),
]


def draw_two_spreads():
    """Two distributions with the same centre and different spreads.

    A is tall and narrow, B is short and wide, and both are centred on the
    same mark. The question asks which has the larger standard deviation,
    and the answer is a judgement about width that a sentence cannot make as
    quickly as a picture.

    No vertical scale and no grid, and the horizontal axis carries a single
    unlabelled tick at the shared centre. Nothing can be counted off, so no
    standard deviation can be reconstructed from the drawing; what it
    supplies is which curve is wider, which is exactly the concept being
    tested. The heights differ because both curves enclose the same area,
    and a student who reads HEIGHT as spread will pick the wrong one.
    """
    fig, ax = plt.subplots(figsize=(6.4, 4.0), dpi=125)
    ax.axis('off')

    def bell(x, sd):
        # scaled so both curves enclose the same area, which is what forces
        # the wider one to be shorter
        return math.exp(-0.5 * (x / sd) ** 2) / sd

    SD_A, SD_B = 1.0, 2.4
    xs = [-6.0 + i * 12.0 / 600 for i in range(601)]
    ysA = [bell(x, SD_A) for x in xs]
    ysB = [bell(x, SD_B) for x in xs]
    top = max(ysA)

    ax.plot(xs, ysA, color=ACCENT, lw=3.0, solid_capstyle='round', zorder=3)
    ax.plot(xs, ysB, color='#8A5FA8', lw=3.0, solid_capstyle='round', zorder=3)

    ax.text(0.95, bell(0.95, SD_A) + 0.03 * top, 'A', color=ACCENT,
            fontsize=15, ha='left', va='bottom', fontweight='bold', zorder=4)
    ax.text(2.90, bell(2.90, SD_B) + 0.04 * top, 'B', color='#8A5FA8',
            fontsize=15, ha='left', va='bottom', fontweight='bold', zorder=4)

    ax.plot([-6.5, 6.5], [0, 0], color=SOFT, lw=2.0, zorder=2)
    ax.plot([0, 0], [-0.030 * top, 0.030 * top], color=SOFT, lw=2.0, zorder=2)
    ax.text(0, -0.075 * top, 'same centre', ha='center', va='top',
            fontsize=11, color=SOFT, style='italic')

    ax.set_xlim(-7.3, 7.3)
    ax.set_ylim(-0.24 * top, 1.16 * top)
    finish(fig, ax, 'mdm4u_stat_25.png', note=False)


def draw_venn_shaded():
    """A Venn diagram with one region shaded and no numbers anywhere.

    The shading covers the part of A that lies outside B. The question asks
    which set expression that region is, and the answer comes from looking
    at which overlap is included and which is not.

    Deliberately NOT the Jensen version with counts written in each region.
    A Venn with 5, 13 and 7 printed on it turns the additive principle into
    an addition: a student sums the three numbers and never meets the idea
    that the overlap would otherwise be counted twice. With no numbers on
    it, there is nothing to add and nothing to leak.
    """
    fig, ax = fig_ax(6.4, 4.0)

    rA, rB = 1.85, 1.85
    cA, cB = (-0.95, 0.0), (0.95, 0.0)

    # the universe
    ax.add_patch(plt.Rectangle((-3.9, -2.5), 7.8, 5.0, fill=False,
                               edgecolor=SOFT, lw=2.0, zorder=2))
    label(ax, (3.45, 2.05), 'S', SOFT, 14)

    # shade all of A, then paint the overlap back out with white
    ax.add_patch(plt.Circle(cA, rA, facecolor='#BFE0D6', edgecolor='none',
                            zorder=1))
    inter = plt.Circle(cB, rB, facecolor='white', edgecolor='none', zorder=1)
    ax.add_patch(inter)

    ax.add_patch(plt.Circle(cA, rA, fill=False, edgecolor=INK, lw=2.4,
                            zorder=3))
    ax.add_patch(plt.Circle(cB, rB, fill=False, edgecolor=INK, lw=2.4,
                            zorder=3))

    label(ax, (-2.15, 1.25), 'A', INK, 15)
    label(ax, (2.15, 1.25), 'B', INK, 15)

    ax.set_xlim(-4.4, 4.4)
    ax.set_ylim(-3.0, 3.0)
    finish(fig, ax, 'mdm4u_venn_14.png', note=False)


def draw_two_geometrics():
    """Two geometric distributions with different success probabilities.

    Both are bar charts of the waiting time to a first success, drawn side by
    side over the same run of trial numbers. The left one decays slowly and
    the right one drops away almost at once. The question asks which has the
    larger probability of success on each trial, and the answer is the one
    that finishes quickly.

    Neither axis carries a number. Without a vertical scale no probability
    can be read off, and without labelled trial numbers no expected value
    can be counted. What survives is the SHAPE, which is the whole content:
    a large p makes early successes likely and long waits rare, so the bars
    collapse; a small p spreads the waiting time out over a long tail.
    """
    fig, ax = plt.subplots(figsize=(6.8, 3.6), dpi=125)
    ax.axis('off')

    def geo(k, pr):
        return (1 - pr) ** (k - 1) * pr

    N = 16
    for panel, (pr, tag, x0) in enumerate(
            [(0.10, 'A', 0.0), (0.34, 'B', N + 4.0)]):
        top = geo(1, pr)
        for k in range(1, N + 1):
            h = geo(k, pr) / top * 2.6
            ax.add_patch(plt.Rectangle((x0 + k - 0.38, 0), 0.76, h,
                                       facecolor='#9C7FBC', edgecolor=INK,
                                       lw=0.9, zorder=3))
        ax.plot([x0 + 0.2, x0 + N + 0.8], [0, 0], color=SOFT, lw=1.8,
                zorder=2)
        ax.plot([x0 + 0.2, x0 + 0.2], [0, 3.1], color=SOFT, lw=1.8, zorder=2)
        ax.text(x0 + N / 2 + 0.5, -0.62, 'number of trials to first success',
                ha='center', va='top', fontsize=9.5, color=SOFT)
        ax.text(x0 + N / 2 + 0.5, 3.35, tag, ha='center', va='bottom',
                fontsize=15, color=INK, fontweight='bold')

    ax.set_xlim(-1.6, 2 * N + 6.0)
    ax.set_ylim(-1.5, 4.1)
    finish(fig, ax, 'mdm4u_geo_21.png', note=False)


# ===========================================================================
# The MDM4U register
# ===========================================================================
# Grade 12 Data Management. Almost every display in this course is a graph
# with a numbered axis, and a numbered axis is a leak: asking a student to
# read a median off a box plot is asking them to count squares. The two
# figures here are the exceptions, and both are about a PROPERTY of a
# picture rather than a value in it.

DD = 'Displays of Data'
ND = 'Normal Distributions'
PR = 'Probability'
PD = 'Probability Distributions'

FIGURES_MDM4U = [
    # No ruler test on either: both answers are sentences, not numbers, and
    # neither figure can be measured into one.
    # ---- Unit 1, Displays of Data ----
    (DD, 10, 'mdm4u_stat_10.png', draw_truncated_bars, None),
    (DD, 17, 'mdm4u_stat_17.png', draw_curved_scatter, None),

    # ---- Unit 3, Normal Distributions ----
    (ND, 25, 'mdm4u_stat_25.png', draw_two_spreads, None),

    # ---- Unit 4, Probability ----
    (PR, 14, 'mdm4u_venn_14.png', draw_venn_shaded, None),

    # ---- Unit 5, Probability Distributions ----
    (PD, 21, 'mdm4u_geo_21.png', draw_two_geometrics, None),
]


def write_sql_for(path, grade, course, entries, extra_note=''):
    """One figure file per course. Regenerated from this script every run."""
    lines = [
        '-- ======================================================================',
        '-- %s — attaches figures to questions' % os.path.basename(path),
        '-- ======================================================================',
        '-- GENERATED by tools/make_figures.py — edit that script, not this file.',
        '--',
        '-- Run AFTER the question files for this course, and after any re-run of',
        '-- one: the per-unit delete wipes the figure column with the rest of the',
        '-- row. Safe to re-run on its own at any time.',
        '--',
        '-- The PNGs live in web/figures/ and ship inside every deploy. A null',
        '-- figure renders no image, and a missing file shows a short "could not',
        '-- load" line in the app rather than a broken icon.',
    ]
    if extra_note:
        lines += ['--', extra_note]
    lines += [
        '',
        "update questions set figure = null where course_code = '%s';" % course,
        '',
    ]
    for unit, sort_order, name, _, _r in entries:
        lines.append(
            "update questions set figure = 'figures/%s'\n"
            " where course_code = '%s' and unit = '%s' and sort_order = %d;"
            % (name, course, unit.replace("'", "''"), sort_order))
    lines += [
        '',
        '-- Check: every figure attached, and none orphaned.',
        'select unit, sort_order, figure from questions',
        " where course_code = '%s' and figure is not null" % course,
        ' order by unit, sort_order;',
    ]
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write('\n'.join(lines) + '\n')


def write_sql():
    lines = [
        '-- ======================================================================',
        '-- figures_grade10.sql — attaches figures to questions',
        '-- ======================================================================',
        '-- GENERATED by tools/make_figures.py — edit that script, not this file.',
        '--',
        '-- Run AFTER questions_grade10.sql (the questions must exist), and after',
        '-- any re-run of it: the per-unit delete wipes the figure column with the',
        '-- rest of the row. Safe to re-run on its own at any time.',
        '--',
        '-- The PNGs live in web/figures/ and ship inside every deploy. A null',
        '-- figure renders no image, and a missing file shows a short "could not',
        '-- load" line in the app rather than a broken icon.',
        '',
        'update questions set figure = null where grade = 10;',
        '',
    ]
    for unit, sort_order, name, _, _r in FIGURES:
        lines.append(
            "update questions set figure = 'figures/%s'\n"
            " where grade = 10 and unit = '%s' and sort_order = %d;"
            % (name, unit.replace("'", "''"), sort_order))
    lines += [
        '',
        '-- Check: every figure attached, and none orphaned.',
        'select unit, sort_order, figure from questions',
        " where grade = 10 and figure is not null",
        ' order by unit, sort_order;',
    ]
    os.makedirs(os.path.dirname(SQL), exist_ok=True)
    with open(SQL, 'w') as f:
        f.write('\n'.join(lines) + '\n')


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    leaks = []
    for unit, sort_order, name, draw, ruler in (FIGURES + FIGURES_MCR3U
                                               + FIGURES_MHF4U + FIGURES_MCV4U
                                               + FIGURES_MDM4U):
        draw()
        note = ''
        if ruler:
            try:
                note = '   ' + ruler.check(name)
            except AssertionError as e:
                leaks.append(str(e))
                note = '   *** LEAK ***'
        print('%-14s %-3d %-14s%s' % (unit[:14], sort_order, name, note))

    write_sql()
    write_sql_for(SQL_MCR3U, 11, 'MCR3U', FIGURES_MCR3U)
    write_sql_for(SQL_MHF4U, 12, 'MHF4U', FIGURES_MHF4U)
    write_sql_for(SQL_MCV4U, 12, 'MCV4U', FIGURES_MCV4U)
    write_sql_for(SQL_MDM4U, 12, 'MDM4U', FIGURES_MDM4U)
    allf = (FIGURES + FIGURES_MCR3U + FIGURES_MHF4U + FIGURES_MCV4U
            + FIGURES_MDM4U)
    print('\n%d figures (%d MPM2D, %d MCR3U, %d MHF4U, %d MCV4U, %d MDM4U),'
          ' %d with a ruler test'
          % (len(allf), len(FIGURES), len(FIGURES_MCR3U), len(FIGURES_MHF4U),
             len(FIGURES_MCV4U), len(FIGURES_MDM4U),
             sum(1 for f in allf if f[4])))
    if leaks:
        print('\nFAILED — these figures give the answer away:\n')
        for msg in leaks:
            print('  ' + msg + '\n')
        raise SystemExit(1)
    print('all ruler tests passed')
