#!/usr/bin/env python3
"""Astro Math Assist — brand mark and app icons.

THE MARK
--------
A parabola cradling a star.

The parabola is the one curve every course in this app shares: MPM2D is
built on it, MHF4U generalises it, MCV4U differentiates it, and the very
first lesson in the bank opens by throwing a basketball. The star is the
"Astro". Together they read in one glance as maths-about-the-sky, and the
silhouette — an open cup with a point of light inside it — survives being
shrunk to a 16-pixel favicon, which a wordmark never would.

Drawn here rather than in SVG so the same geometry produces every size,
supersampled 4x and stepped down with LANCZOS so the curve stays smooth at
32 pixels. Nothing here depends on a font, so nothing silently falls back.

COLOURS
-------
Teal is the app's existing accent (kAccent in main.dart); the gold is the
gold medal already used on MedalDot. Both are lifted from the running app
rather than invented, so the icon and the interface agree.

OUTPUTS  (web/)
    favicon.png              64x64   teal mark, transparent
    icons/Icon-192.png       192     teal mark, transparent
    icons/Icon-512.png       512     teal mark, transparent
    icons/Icon-maskable-192  192     full-bleed teal, cream mark
    icons/Icon-maskable-512  512     full-bleed teal, cream mark
    brand/wordmark.png               for docs and the brand sheet
"""

import math
import os
from PIL import Image, ImageDraw

TEAL = (47, 111, 98, 255)        # #2F6F62  kAccent
TEAL_DEEP = (32, 81, 74, 255)    # #20514A  kAccentDeep
CREAM = (246, 245, 241, 255)     # #F6F5F1  kSurface
GOLD = (199, 154, 46, 255)       # #C79A2E  MedalDot gold
GOLD_BRIGHT = (224, 180, 74, 255)

SS = 4  # supersample factor


def parabola_points(cx, cy_vertex, half_width, rise, n=400):
    """Points along y = vertex - a*x^2, sampled evenly in x."""
    a = rise / (half_width ** 2)
    pts = []
    for i in range(n + 1):
        x = -half_width + (2 * half_width) * i / n
        pts.append((cx + x, cy_vertex - a * x * x))
    return pts


def thick_stroke(d, pts, width, colour):
    """Fill a constant-width band around a polyline.

    PIL's line(width=..., joint='curve') draws each segment as its own
    quadrilateral, which leaves hairline seams along the inside of a tight
    curve — visible as white slashes once the icon is scaled down. Offsetting
    the path along its normals and filling one closed polygon avoids them
    entirely.
    """
    r = width / 2.0
    left, right = [], []
    n = len(pts)
    for i, (x, y) in enumerate(pts):
        px, py = pts[max(i - 1, 0)]
        nx, ny = pts[min(i + 1, n - 1)]
        tx, ty = nx - px, ny - py
        m = math.hypot(tx, ty) or 1.0
        ox, oy = -ty / m * r, tx / m * r      # unit normal * radius
        left.append((x + ox, y + oy))
        right.append((x - ox, y - oy))
    d.polygon(left + right[::-1], fill=colour)
    for (ex, ey) in (pts[0], pts[-1]):        # round the open ends
        d.ellipse([ex - r, ey - r, ex + r, ey + r], fill=colour)


def star_polygon(cx, cy, outer, inner, points=6, rotation=-math.pi / 2):
    """A regular star. Six points reads as a star at any size; five reads
    as a sheriff's badge once it is small enough to lose its proportions."""
    verts = []
    for i in range(points * 2):
        r = outer if i % 2 == 0 else inner
        ang = rotation + math.pi * i / points
        verts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    return verts


def draw_mark(size, curve_colour, star_colour, bg=None, scale=1.0,
              corner_radius=None):
    """Render the mark at `size` px. `scale` shrinks the artwork inside the
    canvas — maskable icons need everything inside the middle 80%."""
    S = size * SS
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    if bg is not None:
        if corner_radius:
            d.rounded_rectangle([0, 0, S - 1, S - 1],
                                radius=int(corner_radius * S), fill=bg)
        else:
            d.rectangle([0, 0, S - 1, S - 1], fill=bg)

    cx = S / 2
    box = S * scale                  # artwork box, centred
    # Proportions: deep enough that the artwork fills a square instead of
    # sitting in a wide, short band, shallow enough at the vertex that it
    # still reads as a curve rather than a V.
    half_width = box * 0.410
    rise = box * 0.700
    stroke = box * 0.098
    vertex_y = S / 2 + rise / 2      # centres the artwork's bounding box

    thick_stroke(d, parabola_points(cx, vertex_y, half_width, rise),
                 stroke, curve_colour)

    # The star sits inside the cup with clear space all round it, high
    # enough that its lower point never touches the curve.
    star_cy = vertex_y - box * 0.300
    outer = box * 0.132
    d.polygon(star_polygon(cx, star_cy, outer, outer * 0.40),
              fill=star_colour)

    return img.resize((size, size), Image.LANCZOS)


def main():
    out = os.path.join(os.path.dirname(__file__), "out")
    icons = os.path.join(out, "icons")
    os.makedirs(icons, exist_ok=True)

    # Transparent-background marks: browser tab, and Android "any" purpose.
    for name, size in (("favicon.png", 64),):
        draw_mark(size, TEAL, GOLD).save(os.path.join(out, name))
    for size in (192, 512):
        draw_mark(size, TEAL, GOLD).save(
            os.path.join(icons, "Icon-%d.png" % size))

    # Maskable: full bleed, artwork inside the middle 80% so a circular or
    # squircle crop never clips the curve's arms.
    for size in (192, 512):
        draw_mark(size, CREAM, GOLD_BRIGHT, bg=TEAL_DEEP, scale=0.62).save(
            os.path.join(icons, "Icon-maskable-%d.png" % size))

    # A larger square lockup for docs, the brand sheet and any store listing.
    draw_mark(1024, CREAM, GOLD_BRIGHT, bg=TEAL_DEEP, scale=0.60,
              corner_radius=0.22).save(os.path.join(out, "app_tile.png"))
    draw_mark(1024, TEAL, GOLD).save(os.path.join(out, "mark_teal.png"))

    for root, _, files in os.walk(out):
        for f in sorted(files):
            p = os.path.join(root, f)
            print("%-34s %6d bytes  %s" % (
                os.path.relpath(p, out), os.path.getsize(p),
                Image.open(p).size))


if __name__ == "__main__":
    main()
