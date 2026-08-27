#!/usr/bin/env python3
"""Astro STEM Labs — brand mark and app icons.

THE MARK
--------
A rocket, in a gold-to-coral gradient, on a near-black rounded tile.

This is not this app's own mark. It is the parent company's, taken from
astrostemlabs.com by way of the topicmindmap app, so a student meets one
identity across the website, the physics app and this one. The version that
used to live here — a parabola cradling a star, drawn in the app's teal —
was a good mark for a maths app and the wrong mark for one subject inside a
STEM company. It is kept in git history.

The rocket is drawn rather than illustrated, for the same reason the
parabola was: one geometry produces every size, supersampled 4x and stepped
down with LANCZOS, so the silhouette survives being shrunk to a 16-pixel
favicon. Nothing here depends on a font, so nothing silently falls back.

The gradient runs top-left to bottom-right at the same angle as
kBrandGradient in lib/main.dart. If one moves, move the other.

COLOURS
-------
Fixed in both themes, unlike everything else in the app. See the note on
BrandBadge in lib/main.dart: a mark that restyles itself is not a mark.

OUTPUTS  (web/)
    favicon.png              64x64   rocket on the badge tile
    icons/Icon-192.png       192     rocket on the badge tile
    icons/Icon-512.png       512     rocket on the badge tile
    icons/Icon-maskable-192  192     full-bleed badge, rocket inset for the
    icons/Icon-maskable-512  512     safe zone Android crops to a circle
    brand/app_tile.png       1024    the badge at press size
    brand/mark_rocket.png    1024    the rocket alone, transparent
"""

import os

from PIL import Image, ImageDraw

BADGE_INK = (18, 25, 43, 255)     # #12192B  kBrandBadgeInk
GOLD = (244, 169, 59, 255)        # #F4A93B  kBrandGold
CORAL = (232, 96, 76, 255)        # #E8604C  kBrandCoral

SS = 4  # supersample factor


def gradient_box(w, h, a=GOLD, b=CORAL):
    """The brand gradient as a w x h image, top-left to bottom-right.

    Built per-pixel along the diagonal rather than as a vertical ramp,
    because a 45-degree gradient faked with a vertical one goes flat exactly
    where the rocket is widest.
    """
    img = Image.new("RGBA", (max(w, 1), max(h, 1)))
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            # 0 at top-left, 1 at bottom-right of this box.
            fx = x / (img.width - 1) if img.width > 1 else 0.0
            fy = y / (img.height - 1) if img.height > 1 else 0.0
            t = (fx + fy) / 2
            px[x, y] = tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(4))
    return img


# The fuselage as ONE closed outline, tip first and down the right side.
# Drawn as a single polygon rather than a cone stacked on a capsule: where
# a triangle's base meets a rounded rectangle's top, the rectangle's corners
# poke out past the triangle's edges and the join reads as two small
# shoulders. Cheaper to draw the silhouette once than to fight the seam.
_FUSELAGE = [
    (0.500, 0.055),
    (0.556, 0.205), (0.590, 0.330), (0.606, 0.450),
    (0.612, 0.560), (0.612, 0.700),
    (0.588, 0.762), (0.412, 0.762),
    (0.388, 0.700), (0.388, 0.560),
    (0.394, 0.450), (0.410, 0.330), (0.444, 0.205),
]


def rocket_mask(size):
    """The rocket silhouette, white on black, as an alpha source.

    Proportions are set against `size` so the shape scales exactly. The
    window is punched back OUT of the fuselage — that hole is what stops
    the shape reading as a plain arrowhead once it is 32 pixels wide.
    """
    m = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(m)
    s = size

    # Fins, first, so the fuselage draws over where they meet it.
    d.polygon([(0.392 * s, 0.545 * s), (0.225 * s, 0.790 * s),
               (0.392 * s, 0.735 * s)], fill=255)
    d.polygon([(0.608 * s, 0.545 * s), (0.775 * s, 0.790 * s),
               (0.608 * s, 0.735 * s)], fill=255)
    d.polygon([(x * s, y * s) for x, y in _FUSELAGE], fill=255)

    # Exhaust, detached from the fins so the two do not read as one wedge.
    d.polygon([(0.452 * s, 0.800 * s), (0.500 * s, 0.945 * s),
               (0.548 * s, 0.800 * s)], fill=255)

    # Window.
    d.ellipse([0.447 * s, 0.345 * s, 0.553 * s, 0.451 * s], fill=0)
    return m


def badge(size, inset=1.0, tile=True, radius=0.26):
    """One rendered mark.

    inset shrinks the rocket without shrinking the tile, which is what the
    maskable icons need: Android crops them to a circle and anything in the
    outer ~10% can be cut.
    """
    big = size * SS
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))

    if tile:
        tile_img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
        ImageDraw.Draw(tile_img).rounded_rectangle(
            [0, 0, big - 1, big - 1], radius=radius * big, fill=BADGE_INK)
        img.alpha_composite(tile_img)

    inner = round(big * 0.66 * inset)
    mask = rocket_mask(inner)
    # The gradient is built across the rocket's own bounding box, not the
    # square it is drawn in. Over the full square the mark only samples the
    # middle third of the ramp and comes out one flat orange — which is
    # what the first render of this did.
    box = mask.getbbox()
    grad = Image.new("RGBA", (inner, inner), (0, 0, 0, 0))
    grad.paste(gradient_box(box[2] - box[0], box[3] - box[1]), (box[0], box[1]))
    grad.putalpha(mask)
    img.alpha_composite(grad, (round((big - inner) / 2),
                               round((big - inner) / 2)))
    return img.resize((size, size), Image.LANCZOS)


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    web = os.path.join(root, "web")
    icons = os.path.join(web, "icons")
    brand = os.path.join(root, "brand")
    for d in (icons, brand):
        os.makedirs(d, exist_ok=True)

    badge(64).save(os.path.join(web, "favicon.png"))
    for size in (192, 512):
        badge(size).save(os.path.join(icons, f"Icon-{size}.png"))
        # Full bleed, square corners, rocket pulled well inside the safe
        # zone — Android masks these to whatever shape the launcher uses.
        badge(size, inset=0.72, radius=0.0).save(
            os.path.join(icons, f"Icon-maskable-{size}.png"))

    badge(1024).save(os.path.join(brand, "app_tile.png"))
    badge(1024, tile=False).save(os.path.join(brand, "mark_rocket.png"))

    print("Wrote:")
    for path in (
        os.path.join(web, "favicon.png"),
        os.path.join(icons, "Icon-192.png"),
        os.path.join(icons, "Icon-512.png"),
        os.path.join(icons, "Icon-maskable-192.png"),
        os.path.join(icons, "Icon-maskable-512.png"),
        os.path.join(brand, "app_tile.png"),
        os.path.join(brand, "mark_rocket.png"),
    ):
        print("  " + os.path.relpath(path, root))


if __name__ == "__main__":
    main()
