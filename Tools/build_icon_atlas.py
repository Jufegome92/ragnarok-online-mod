"""
Dragon Nest BG3 Mod - Icon Atlas Builder
=========================================
Converts individual PNG icons into a BG3-compatible texture atlas.

Generates:
  - Icons_DN_Warrior.png   (combined atlas image, 512x512)
  - Icons_DN_Warrior.lsx   (BG3 atlas definition with UV coordinates)

Usage:
  python build_icon_atlas.py

Requirements:
  pip install Pillow
"""

import os
import math
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("ERROR: Pillow not installed. Run:  pip install Pillow")
    exit(1)

# ── Configuration ──────────────────────────────────────────────────────────────

ICONS_SOURCE_DIR = Path(__file__).parent.parent / "Icons" / "Moonlord"
OUTPUT_DIR       = Path(__file__).parent.parent / "Mod" / "Public" \
                   / "DragonNest_Warrior_782925c0-02e7-42df-b9bb-c800923b9911" \
                   / "GUI"

ATLAS_NAME       = "Icons_DN_Warrior"
MOD_FOLDER       = "DragonNest_Warrior_782925c0-02e7-42df-b9bb-c800923b9911"

ICON_SIZE        = 64     # each icon is resized to 64×64
ATLAS_COLS       = 8      # icons per row  → atlas = 512px wide
ICON_BACKGROUND  = (0, 0, 0, 0)  # transparent background

# Maps filename (without .png) → BG3 icon name used in Stats files
# Format: "DN_AbilityName"  (this is the value you put in Icon: field)
ICON_MAP = {
    # ── Warrior class ──────────────────────────────────────────────────────────
    "warrior-class":          "DN_Warrior_Class",
    "impact-punch":           "DN_ImpactPunch",
    "impact-wave":            "DN_ImpactWave",
    "dash-kick":              "DN_DashKick",
    "destructive-swing":      "DN_DestructiveSwing",
    "breaking-point":         "DN_BreakingPoint",
    "brush-it-off":           "DN_BrushOff",
    # ── Moonlord subclass ──────────────────────────────────────────────────────
    "moonlord-subclass":      "DN_Moonlord_Class",
    "moonlight-splitter":     "DN_MoonlightSplitter",
    "moonlight-splitter-ex":  "DN_MoonlightSplitter_EX",
    "cyclone-slash":          "DN_CycloneSlash",
    "cyclone-slash-ex":       "DN_CycloneSlash_EX",
    "crescent-cleave":        "DN_CrescentCleave",
    "crescent-cleave-ex":     "DN_CrescentCleave_EX",
    "halfmoon-slash":         "DN_HalfmoonSlash",
    "halfmoon-slash-ex":      "DN_HalfmoonSlash_EX",
    "eclipse":                "DN_Eclipse",
    "flash-stance":           "DN_FlashStance",
    "moon-blade-dance":       "DN_MoonBladeDance",
    "mastery":                "DN_Mastery",
    "blade-storm":            "DN_BladeStorm",
    "corageous-shout":        "DN_CourageousShout",
    "parry":                  "DN_Parry",
    "luring-slice":           "DN_LuringSlice",
    # ── Dragon Force resource (also used as ability atlas entry) ───────────────
    "dragon-force":           "DN_DragonForce",
}

# ── Build atlas ────────────────────────────────────────────────────────────────

def build_atlas():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Load and resize all icons
    icons = []
    for filename, bg3_name in ICON_MAP.items():
        src = ICONS_SOURCE_DIR / f"{filename}.png"
        if not src.exists():
            print(f"  WARN: missing icon file: {src.name} — skipping")
            continue
        img = Image.open(src).convert("RGBA").resize((ICON_SIZE, ICON_SIZE), Image.LANCZOS)
        icons.append((bg3_name, img))
        print(f"  loaded: {filename}.png -> {bg3_name}")

    if not icons:
        print("ERROR: no icons found.")
        return

    # Calculate atlas dimensions
    cols       = ATLAS_COLS
    rows       = math.ceil(len(icons) / cols)
    atlas_w    = cols * ICON_SIZE
    atlas_h    = rows * ICON_SIZE

    print(f"\n  Atlas: {atlas_w}×{atlas_h}px  ({cols} cols × {rows} rows, {len(icons)} icons)")

    # Compose atlas image
    atlas = Image.new("RGBA", (atlas_w, atlas_h), ICON_BACKGROUND)
    uv_entries = []

    for idx, (bg3_name, img) in enumerate(icons):
        col = idx % cols
        row = idx // cols
        x   = col * ICON_SIZE
        y   = row * ICON_SIZE
        atlas.paste(img, (x, y))

        u1 = x / atlas_w
        u2 = (x + ICON_SIZE) / atlas_w
        v1 = y / atlas_h
        v2 = (y + ICON_SIZE) / atlas_h
        uv_entries.append((bg3_name, u1, u2, v1, v2))

    # Save atlas PNG
    atlas_png = OUTPUT_DIR / f"{ATLAS_NAME}.png"
    atlas.save(atlas_png, "PNG")
    print(f"  saved: {atlas_png}")

    # Generate atlas LSX
    atlas_lsx = OUTPUT_DIR / f"{ATLAS_NAME}.lsx"
    icon_nodes = "\n".join(
        f'                <node id="IconUV">\n'
        f'                    <attribute id="MapKey" type="FixedString" value="{name}"/>\n'
        f'                    <attribute id="U1" type="float" value="{u1:.8f}"/>\n'
        f'                    <attribute id="U2" type="float" value="{u2:.8f}"/>\n'
        f'                    <attribute id="V1" type="float" value="{v1:.8f}"/>\n'
        f'                    <attribute id="V2" type="float" value="{v2:.8f}"/>\n'
        f'                </node>'
        for name, u1, u2, v1, v2 in uv_entries
    )

    lsx_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<save>
    <version major="4" minor="8" revision="0" build="200"/>
    <region id="IconUVList">
        <node id="root">
            <attribute id="AtlasImage" type="LSString" value="Public/{MOD_FOLDER}/GUI/{ATLAS_NAME}.png"/>
            <attribute id="IconWidth" type="int32" value="{ICON_SIZE}"/>
            <attribute id="IconHeight" type="int32" value="{ICON_SIZE}"/>
            <children>
{icon_nodes}
            </children>
        </node>
    </region>
</save>
"""
    atlas_lsx.write_text(lsx_content, encoding="utf-8")
    print(f"  saved: {atlas_lsx}")
    print(f"\nDone. {len(icons)} icons packed.")

if __name__ == "__main__":
    print(f"Reading icons from: {ICONS_SOURCE_DIR}")
    build_atlas()
