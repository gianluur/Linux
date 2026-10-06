#!/usr/bin/env python3
"""
Determine the nearest MacTahoe folder-color variant for the current KDE accent.
Uses hue-based classification (robust to Material You's desaturated palette).
Prefers the raw source color over the muted 'primary'.
"""
import colorsys
import json
import os
import subprocess
import sys

def hex_to_rgb(h: str):
    h = h.lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

def classify(rgb):
    r, g, b = (x / 255.0 for x in rgb)
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    hue = h * 360.0

    # Too desaturated → grey
    if s < 0.20:
        return "grey"

    # Hue buckets (tuned for the MacTahoe family names)
    if hue < 15 or hue >= 345:
        return "red"
    if hue < 45:
        return "orange"
    if hue < 70:
        return "yellow"
    if hue < 165:
        return "green"
    if hue < 260:
        return "blue"
    if hue < 310:
        return "purple"
    return "pink"

def from_kde_json():
    user = os.environ.get("USER") or os.environ.get("LOGNAME")
    path = f"/tmp/kde-material-you-colors-{user}.json"
    if not os.path.isfile(path):
        return None
    with open(path) as f:
        data = json.load(f)

    # Prefer the raw wallpaper/source color — it's fully saturated and
    # unambiguous. Fall back to the Material You primary only if needed.
    def find_key(obj, keys):
        if isinstance(obj, dict):
            for k in keys:
                if k in obj and isinstance(obj[k], str) and obj[k].startswith("#"):
                    return obj[k]
            for v in obj.values():
                r = find_key(v, keys)
                if r:
                    return r
        return None

    hexval = find_key(data, ("source_color", "source", "accent"))
    if hexval is None:
        hexval = find_key(data, ("primary", "primary_container"))
    return hex_to_rgb(hexval) if hexval else None

def from_kreadconfig():
    for tool in ("kreadconfig6", "kreadconfig5"):
        try:
            out = subprocess.check_output(
                [tool, "--file", "kdeglobals", "--group", "General", "--key", "AccentColor"],
                stderr=subprocess.DEVNULL,
            ).decode().strip()
            if out and "," in out:
                return tuple(map(int, out.split(",")))
        except (FileNotFoundError, subprocess.CalledProcessError):
            continue
    return None

def main():
    rgb = from_kde_json() or from_kreadconfig()
    if rgb is None:
        print("Error: could not determine accent color from any source", file=sys.stderr)
        sys.exit(1)

    # Debug info so you can see what's actually being used
    r, g, b = (x / 255.0 for x in rgb)
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    print(
        f"# DEBUG: rgb={rgb} hue={h*360:.1f} sat={s:.2f} val={v:.2f}",
        file=sys.stderr,
    )

    print(classify(rgb))

if __name__ == "__main__":
    main()