"""Refined Memo mascot icon: three variants, each in default and dark appearance.

Follows the current Apple HIG for app icons: few solid shapes with clear edges,
a simple gradient background, no thin lines, no baked-in glow, primary content
centered. Each SVG keeps its layers in separate groups (background, back-card,
front-card) so they can be imported into Icon Composer. The flattened PNG has a
small crisp shadow for Android and the Play listing, where no system effects
are added.
"""
import subprocess
import sys
from pathlib import Path

OUT = Path(sys.argv[1])
OUT.mkdir(parents=True, exist_ok=True)

PALETTE = {
    "default": dict(bg0="#14B8A6", bg1="#0F766E", back="#115E59", back_mark="#5EEAD4",
                    front0="#FCD34D", front1="#F59E0B", frame="#FDE68A",
                    ink="#134E4A", mouth="#7C2D12", tongue="#FB7185", shadow="#042F2C",
                    shadow_op="0.28"),
    "dark": dict(bg0="#0E3F3A", bg1="#062824", back="#134E4A", back_mark="#2DD4BF",
                 front0="#FBBF24", front1="#D97706", frame="#FCD34D",
                 ink="#0B2E2B", mouth="#5A1E08", tongue="#F43F5E", shadow="#000000",
                 shadow_op="0.45"),
}

FRONT = dict(cx=412, cy=566, w=380, h=500, rx=66, angle=-9)
BACK = dict(cx=630, cy=468, w=340, h=452, rx=60, angle=14)


def rect(c, fill, extra=""):
    return (f'<rect x="{c["cx"] - c["w"] / 2}" y="{c["cy"] - c["h"] / 2}" width="{c["w"]}" '
            f'height="{c["h"]}" rx="{c["rx"]}" fill="{fill}" {extra}/>')


def frame(c, color, inset=26):
    return (f'<rect x="{c["cx"] - c["w"] / 2 + inset}" y="{c["cy"] - c["h"] / 2 + inset}" '
            f'width="{c["w"] - 2 * inset}" height="{c["h"] - 2 * inset}" rx="{c["rx"] - 18}" '
            f'fill="none" stroke="{color}" stroke-width="12"/>')


def shadow(c, p):
    extra = 'opacity="%s" filter="url(#soft)"' % p["shadow_op"]
    moved = dict(c, cy=c["cy"] + 20)
    return (f'<g transform="rotate({c["angle"]} {c["cx"]} {c["cy"] + 20})">'
            f'{rect(moved, p["shadow"], extra)}</g>')


def back_mark(kind, c, p):
    x, y = c["cx"], c["cy"]
    if kind == "m":
        # Monogram in the part of the back card the front card does not cover.
        mx, my, k = x + 78, y - 70, 0.62
        return (f'<path d="M{mx - 66 * k},{my + 62 * k} L{mx - 66 * k},{my - 58 * k} L{mx},{my + 14 * k} '
                f'L{mx + 66 * k},{my - 58 * k} L{mx + 66 * k},{my + 62 * k}" fill="none" '
                f'stroke="{p["back_mark"]}" stroke-width="26" stroke-linecap="round" stroke-linejoin="round"/>')
    # A bold diamond lattice: any visible part still reads as a card back.
    inset = 26
    left, top = x - c["w"] / 2 + inset, y - c["h"] / 2 + inset
    w, h = c["w"] - 2 * inset, c["h"] - 2 * inset
    cells = []
    step = 104
    for row in range(-1, int(h // step) + 2):
        for col in range(-1, int(w // step) + 2):
            cx = left + col * step + (step / 2 if row % 2 else 0)
            cy = top + row * step * 0.9
            cells.append(f'<rect x="{cx - 30}" y="{cy - 30}" width="60" height="60" rx="10" '
                         f'transform="rotate(45 {cx} {cy})"/>')
    return (f'<clipPath id="backclip"><rect x="{left}" y="{top}" width="{w}" height="{h}" rx="{c["rx"] - 18}"/></clipPath>'
            f'<g clip-path="url(#backclip)" fill="none" stroke="{p["back_mark"]}" stroke-width="14" '
            f'stroke-opacity="0.7">{"".join(cells)}</g>')


def face(kind, c, p):
    x, y = c["cx"], c["cy"]
    ex, ey = 82, -52          # eye offset from the card center
    parts = []
    # Brows: short, thick, rounded.
    if kind == "wink":
        parts.append(f'<path d="M{x - ex - 40},{y + ey - 92} Q{x - ex},{y + ey - 112} {x - ex + 40},{y + ey - 96}" '
                     f'fill="none" stroke="{p["ink"]}" stroke-width="20" stroke-linecap="round"/>')
        parts.append(f'<path d="M{x + ex - 40},{y + ey - 112} Q{x + ex},{y + ey - 134} {x + ex + 40},{y + ey - 110}" '
                     f'fill="none" stroke="{p["ink"]}" stroke-width="20" stroke-linecap="round"/>')
    else:
        for s in (-1, 1):
            parts.append(f'<path d="M{x + s * ex - 38},{y + ey - 100} Q{x + s * ex},{y + ey - 120} {x + s * ex + 38},{y + ey - 100}" '
                         f'fill="none" stroke="{p["ink"]}" stroke-width="20" stroke-linecap="round"/>')
    # Eyes.
    look = (10, -8) if kind == "look" else (4, 0)
    for s in (-1, 1):
        cx, cy = x + s * ex, y + ey
        if kind == "wink" and s == -1:
            parts.append(f'<path d="M{cx - 40},{cy + 4} Q{cx},{cy + 36} {cx + 40},{cy + 4}" fill="none" '
                         f'stroke="{p["ink"]}" stroke-width="22" stroke-linecap="round"/>')
            continue
        parts.append(f'<rect x="{cx - 46}" y="{cy - 58}" width="92" height="116" rx="46" fill="#FFFFFF"/>')
        parts.append(f'<circle cx="{cx + look[0]}" cy="{cy + 8 + look[1]}" r="32" fill="{p["ink"]}"/>')
        parts.append(f'<circle cx="{cx + look[0] + 11}" cy="{cy - 6 + look[1]}" r="11" fill="#FFFFFF"/>')
    # Mouth: a filled smile reads better than a stroke at small sizes.
    if kind == "wink":
        parts.append(f'<path d="M{x - 58},{y + 70} Q{x + 6},{y + 96} {x + 74},{y + 58} '
                     f'Q{x + 58},{y + 150} {x - 2},{y + 146} Q{x - 52},{y + 140} {x - 58},{y + 70} Z" fill="{p["mouth"]}"/>')
        parts.append(f'<path d="M{x - 26},{y + 128} Q{x + 8},{y + 106} {x + 40},{y + 124} '
                     f'Q{x + 26},{y + 146} {x - 2},{y + 146} Q{x - 18},{y + 142} {x - 26},{y + 128} Z" fill="{p["tongue"]}"/>')
    else:
        parts.append(f'<path d="M{x - 70},{y + 62} Q{x},{y + 82} {x + 70},{y + 62} '
                     f'Q{x + 62},{y + 148} {x},{y + 150} Q{x - 62},{y + 148} {x - 70},{y + 62} Z" fill="{p["mouth"]}"/>')
        parts.append(f'<path d="M{x - 34},{y + 132} Q{x},{y + 106} {x + 34},{y + 132} '
                     f'Q{x + 20},{y + 150} {x},{y + 150} Q{x - 20},{y + 150} {x - 34},{y + 132} Z" fill="{p["tongue"]}"/>')
    return "\n".join(parts)


def build(variant, appearance):
    p = PALETTE[appearance]
    mark = "m" if variant == "monogram" else "diamond"
    expr = {"classic": "smile", "wink": "wink", "monogram": "look"}[variant]
    f, b = FRONT, BACK
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
<defs>
  <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="{p['bg0']}"/><stop offset="1" stop-color="{p['bg1']}"/>
  </linearGradient>
  <linearGradient id="front" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="{p['front0']}"/><stop offset="1" stop-color="{p['front1']}"/>
  </linearGradient>
  <filter id="soft" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="10"/></filter>
</defs>
<g id="background"><rect width="1024" height="1024" fill="url(#bg)"/></g>
<g id="flat-only-shadow-back">{shadow(b, p)}</g>
<g id="back-card">
  <g transform="rotate({b['angle']} {b['cx']} {b['cy']})">
    {rect(b, p['back'])}
    {frame(b, p['back_mark'] + '" stroke-opacity="0.55')}
    {back_mark(mark, b, p)}
  </g>
</g>
<g id="flat-only-shadow-front">{shadow(f, p)}</g>
<g id="front-card">
  <g transform="rotate({f['angle']} {f['cx']} {f['cy']})">
    {rect(f, 'url(#front)')}
    {frame(f, p['frame'])}
    {face(expr, f, p)}
  </g>
</g>
</svg>"""


for variant in ("classic", "wink", "monogram"):
    if __name__ != "__main__":
        break
    for appearance in ("default", "dark"):
        name = f"memo-{variant}-{appearance}"
        svg_path = OUT / f"{name}.svg"
        svg_path.write_text(build(variant, appearance), encoding="utf-8")
        subprocess.run(["rsvg-convert", "-w", "1024", "-h", "1024", "-o",
                        str(OUT / f"{name}.png"), str(svg_path)], check=True)
        print("rendered", name)
