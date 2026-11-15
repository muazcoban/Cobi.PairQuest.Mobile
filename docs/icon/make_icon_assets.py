"""Exports the Memoko app icon (winking Memo) for iOS, Android and the stores.

Usage: python3 make_icon_assets.py <output-dir>
Needs rsvg-convert and Pillow. The drawing itself lives in make_mascot.py.

Outputs:
  memoko-icon.svg              source, with layers (background, back-card, front-card)
  app_icon.png                 1024 px, flat, with card shadows (Android legacy, web)
  app_icon_ios.png             1024 px, no shadows (iOS adds its own effects)
  app_icon_ios_dark.png        dark appearance
  app_icon_ios_tinted.png      grayscale for the tinted appearance
  adaptive_background.png      Android adaptive icon background
  adaptive_foreground.png      Android adaptive icon foreground, fits the safe zone
  adaptive_monochrome.png      Android 13+ themed icon
  play_store_512.png           Google Play listing icon
"""
import math
import re
import subprocess
import sys
from pathlib import Path

from PIL import Image

import make_mascot as m

OUT = Path(sys.argv[1])
OUT.mkdir(parents=True, exist_ok=True)

m.PALETTE["tinted"] = dict(bg0="#000000", bg1="#000000", back="#4A4A4A", back_mark="#8C8C8C",
                           front0="#C8C8C8", front1="#A8A8A8", frame="#E0E0E0",
                           ink="#141414", mouth="#2A2A2A", tongue="#6E6E6E",
                           shadow="#000000", shadow_op="0")
m.PALETTE["mono"] = dict(bg0="#000000", bg1="#000000", back="#FFFFFF", back_mark="#000000",
                         front0="#FFFFFF", front1="#FFFFFF", frame="#000000",
                         ink="#000000", mouth="#000000", tongue="#000000",
                         shadow="#000000", shadow_op="0")

VARIANT = "wink"


def strip_groups(svg, *ids):
    for gid in ids:
        svg = re.sub(rf'<g id="{gid}">.*?</g>\n', "", svg, flags=re.S, count=1)
    return svg


def remove_shadows(svg):
    # Each shadow group holds one nested <g>; remove the whole block.
    return re.sub(r'<g id="flat-only-shadow-[a-z]+"><g [^>]*>.*?</g></g>\n', "", svg, flags=re.S)


def remove_background(svg):
    return re.sub(r'<g id="background">.*?</g>\n', "", svg, flags=re.S)


def render(svg, name, size=1024, background=None):
    src = OUT / f"_{name}.svg"
    src.write_text(svg, encoding="utf-8")
    cmd = ["rsvg-convert", "-w", str(size), "-h", str(size), "-o", str(OUT / name), str(src)]
    if background:
        cmd[1:1] = ["-b", background]
    subprocess.run(cmd, check=True)
    src.unlink()
    return OUT / name


default_svg = m.build(VARIANT, "default")
(OUT / "memoko-icon.svg").write_text(default_svg, encoding="utf-8")

render(default_svg, "app_icon.png")
render(remove_shadows(default_svg), "app_icon_ios.png")
render(remove_shadows(m.build(VARIANT, "dark")), "app_icon_ios_dark.png")
render(remove_shadows(m.build(VARIANT, "tinted")), "app_icon_ios_tinted.png")
Image.open(OUT / "app_icon_ios_tinted.png").convert("L").save(OUT / "app_icon_ios_tinted.png")

# Android adaptive icon. The launcher masks the 108 dp layer to a shape that is
# at least a 66 dp circle; flutter_launcher_icons insets the foreground by 16 %
# on each side. Scale the foreground so its farthest opaque pixel lands inside
# that circle after the inset.
bg_only = re.sub(r'<g id="flat-only-shadow.*', "</svg>", default_svg, flags=re.S)
render(bg_only, "adaptive_background.png")

fg = render(remove_background(default_svg), "_fg.png")
img = Image.open(fg).convert("RGBA")
alpha = img.split()[3]
bbox = alpha.point(lambda a: 255 if a > 60 else 0).getbbox()
crop = img.crop(bbox)
cx, cy = crop.width / 2, crop.height / 2
pix = crop.split()[3].load()
r_max = max(math.hypot(x - cx, y - cy)
            for y in range(0, crop.height, 4) for x in range(0, crop.width, 4) if pix[x, y] > 60)
inset = 0.16
target_r = 0.33 * 1024 / (1 - 2 * inset) - 6      # px in the pre-inset canvas
scale = target_r / r_max
crop = crop.resize((round(crop.width * scale), round(crop.height * scale)), Image.LANCZOS)
canvas = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
canvas.paste(crop, ((1024 - crop.width) // 2, (1024 - crop.height) // 2), crop)
canvas.save(OUT / "adaptive_foreground.png")
fg.unlink()

# Monochrome: white shapes, face and pattern cut out. Rendered on black, then
# luminance becomes alpha. A black outline separates the front card from the
# back card. Same placement as the foreground.
mono_svg = remove_background(remove_shadows(m.build(VARIANT, "mono")))
mono_svg = mono_svg.replace("fill=\"url(#front)\" ", "fill=\"url(#front)\" stroke=\"#000000\" stroke-width=\"30\" ", 1)
mono = Image.open(render(mono_svg, "_mono.png", background="black")).convert("L")
mono = mono.crop(bbox).resize(crop.size, Image.LANCZOS)
white = Image.new("RGBA", crop.size, (255, 255, 255, 0))
white.putalpha(mono)
mono_canvas = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
mono_canvas.paste(white, ((1024 - crop.width) // 2, (1024 - crop.height) // 2), white)
mono_canvas.save(OUT / "adaptive_monochrome.png")
(OUT / "_mono.png").unlink()

Image.open(OUT / "app_icon.png").convert("RGB").resize((512, 512), Image.LANCZOS).save(OUT / "play_store_512.png")
for p in sorted(OUT.glob("*.png")):
    print(p.name, Image.open(p).mode, Image.open(p).size)
