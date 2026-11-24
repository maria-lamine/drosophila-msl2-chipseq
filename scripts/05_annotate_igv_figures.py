#!/usr/bin/env python3
"""Crop raw IGV-Web captures to a uniform viewport (1893x766) and prepend a 56 px metadata banner."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

TARGET_W = 1893
TARGET_H = 766

FIGURES = [
    (
        Path("reports/task_01/figures/raw/fig1_roX1_CES_raw.png"),
        Path("reports/task_01/figures/fig1_roX1_CES.png"),
        "dm6 (UCSC) | chrX:3,850,000-3,870,000 | bigWig 0-25 CPM",
    ),
    (
        Path("reports/task_01/figures/raw/fig2_Act5C_X_gene_raw.png"),
        Path("reports/task_01/figures/fig2_Act5C_X_gene.png"),
        "dm6 (UCSC) | chrX:5,893,000-5,913,000 | bigWig 0-25 CPM",
    ),
    (
        Path("reports/task_01/figures/raw/fig3_RpL32_autosomal_control_raw.png"),
        Path("reports/task_01/figures/fig3_RpL32_autosomal_control.png"),
        "dm6 (UCSC) | chr3R:30,035,000-30,055,000 | bigWig 0-25 CPM",
    ),
]

def load_font(size: int = 24):
    for fp in (
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
    ):
        try:
            return ImageFont.truetype(fp, size)
        except OSError:
            pass
    return ImageFont.load_default()

def main():
    font = load_font(24)
    banner_h = 56
    for raw_path, out_path, label in FIGURES:
        im = Image.open(raw_path).convert("RGB")
        left = max(0, (im.width - TARGET_W) // 2)
        top = max(0, im.height - TARGET_H)
        im = im.crop((left, top, left + min(TARGET_W, im.width), top + min(TARGET_H, im.height)))
        w, h = im.size
        out = Image.new("RGB", (w, h + banner_h), "white")
        out.paste(im, (0, banner_h))
        draw = ImageDraw.Draw(out)
        bbox = draw.textbbox((0, 0), label, font=font)
        tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
        draw.text(((w - tw) // 2, (banner_h - th) // 2), label, fill="black", font=font)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out.save(out_path)
    print("Annotated 3 IGV figures via Pillow.")

if __name__ == "__main__":
    main()
