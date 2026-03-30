#!/usr/bin/env python3
"""
PNG <-> DDS helper for BG3 mod icons.

Requires Pillow with DDS support:
  pip install pillow

Examples:
  python Tools/png_to_dds.py convert \
    --input RagnarokOnlineMod/Icons/basic_skill.png \
    --out-dir RagnarokOnlineMod/Icons/dds \
    --sizes 24x24 64x64 \
    --pixel-format DXT5

  python Tools/png_to_dds.py convert \
    --input RagnarokOnlineMod/ragnarok-online-logo-png_seeklogo-491164.png \
    --out-dir RagnarokOnlineMod \
    --spec Tools/png_to_dds_spec.example.json

  python Tools/png_to_dds.py inspect RagnarokOnlineMod/*.dds
"""

from __future__ import annotations

import argparse
import json
import struct
import sys
from pathlib import Path

try:
    from PIL import Image
except Exception as exc:
    print("[ERROR] Pillow is required. Install with: pip install pillow", file=sys.stderr)
    print(f"[DETAIL] {exc}", file=sys.stderr)
    sys.exit(2)


def parse_size(text: str) -> tuple[int, int]:
    parts = text.lower().split("x")
    if len(parts) != 2:
        raise ValueError(f"Invalid size '{text}'. Use WxH, e.g. 300x300")
    w, h = int(parts[0]), int(parts[1])
    if w <= 0 or h <= 0:
        raise ValueError(f"Invalid size '{text}'. Width/height must be > 0")
    return w, h


def load_spec(spec_path: Path) -> list[tuple[str, tuple[int, int]]]:
    raw = json.loads(spec_path.read_text(encoding="utf-8"))
    if not isinstance(raw, list):
        raise ValueError("Spec JSON must be a list of objects")

    out: list[tuple[str, tuple[int, int]]] = []
    for i, row in enumerate(raw, start=1):
        if not isinstance(row, dict):
            raise ValueError(f"Spec row {i} must be an object")
        name = row.get("name")
        size = row.get("size")
        if not isinstance(name, str) or not name:
            raise ValueError(f"Spec row {i} missing valid 'name'")
        if (
            not isinstance(size, list)
            or len(size) != 2
            or not isinstance(size[0], int)
            or not isinstance(size[1], int)
        ):
            raise ValueError(f"Spec row {i} has invalid 'size'. Use [w, h]")
        if size[0] <= 0 or size[1] <= 0:
            raise ValueError(f"Spec row {i} has non-positive size")
        out.append((name, (size[0], size[1])))
    return out


def convert(args: argparse.Namespace) -> int:
    input_path = Path(args.input)
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    if not input_path.exists():
        print(f"[ERROR] Input not found: {input_path}", file=sys.stderr)
        return 1

    img = Image.open(input_path).convert("RGBA")

    jobs: list[tuple[str, tuple[int, int]]] = []
    if args.spec:
        jobs.extend(load_spec(Path(args.spec)))
    if args.sizes:
        base = args.basename or input_path.stem
        for size_text in args.sizes:
            w, h = parse_size(size_text)
            name = f"{base}_{w}x{h}.dds"
            jobs.append((name, (w, h)))

    if not jobs:
        print("[ERROR] No outputs requested. Use --sizes and/or --spec", file=sys.stderr)
        return 1

    resample = Image.Resampling.LANCZOS
    for name, (w, h) in jobs:
        out_path = out_dir / name
        resized = img.resize((w, h), resample)
        resized.save(out_path, format="DDS", pixel_format=args.pixel_format)
        print(f"[OK] {out_path} ({w}x{h}, {args.pixel_format})")

    return 0


def inspect(files: list[str]) -> int:
    any_missing = False
    for pat in files:
        matches = list(Path().glob(pat))
        if not matches:
            any_missing = True
            print(f"[WARN] No matches for: {pat}")
            continue

        for p in matches:
            data = p.read_bytes()
            if len(data) < 128 or data[:4] != b"DDS ":
                print(f"[WARN] {p}: not a DDS file")
                continue

            size, flags, height, width, pitch, depth, mipmaps = struct.unpack("<7I", data[4:32])
            pf_size, pf_flags, fourcc, bitcount = struct.unpack("<4I", data[76:92])
            fourcc_bytes = fourcc.to_bytes(4, "little")
            print(
                f"{p} | {width}x{height} | mipmaps={mipmaps} | fourcc={fourcc_bytes!r} | bitcount={bitcount}"
            )

    return 1 if any_missing else 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Convert PNG icons to DDS and inspect DDS headers")
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_convert = sub.add_parser("convert", help="Convert PNG -> DDS")
    p_convert.add_argument("--input", required=True, help="Input PNG path")
    p_convert.add_argument("--out-dir", required=True, help="Output directory")
    p_convert.add_argument(
        "--sizes",
        nargs="*",
        default=[],
        help="Output sizes in WxH (auto filename: <basename>_WxH.dds)",
    )
    p_convert.add_argument("--basename", default=None, help="Basename used with --sizes")
    p_convert.add_argument(
        "--spec",
        default=None,
        help="Path to JSON spec: [{\"name\":\"file.dds\",\"size\":[w,h]}, ...]",
    )
    p_convert.add_argument(
        "--pixel-format",
        default="DXT5",
        help="DDS pixel format (common: DXT1, DXT3, DXT5)",
    )

    p_inspect = sub.add_parser("inspect", help="Inspect DDS header(s)")
    p_inspect.add_argument("files", nargs="+", help="One or more paths/globs to DDS files")

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    if args.cmd == "convert":
        return convert(args)
    if args.cmd == "inspect":
        return inspect(args.files)

    parser.print_help()
    return 1


if __name__ == "__main__":
    raise SystemExit(main())