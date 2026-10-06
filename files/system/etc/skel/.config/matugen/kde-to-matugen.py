#!/usr/bin/env python3
"""
Convert KDE Material You JSON output to Matugen JSON format.
Usage: python kde_to_matugen.py input.json -o matugen_output.json
"""

import json
import argparse
import sys

def convert_kde_to_matugen(kde_data):
    # Determine mode from KDE "light" flag (False = dark mode)
    is_dark_mode = not kde_data.get("light", False)
    mode = "dark" if is_dark_mode else "light"

    # Extract schemes and palettes
    schemes = kde_data.get("schemes", {})
    dark_scheme = schemes.get("dark", {})
    light_scheme = schemes.get("light", {})
    kde_palettes = kde_data.get("palettes", {})

    # Seed color (fallback to custom link source)
    seed_color = "#000000"
    if "seed" in kde_data and "color" in kde_data["seed"]:
        seed_color = kde_data["seed"]["color"]
    elif "custom" in kde_data and "link" in kde_data["custom"] and "source" in kde_data["custom"]["link"]:
        seed_color = kde_data["custom"]["link"]["source"]

    # Wallpaper path
    wallpaper = ""
    if "wallpaper" in kde_data and "data" in kde_data["wallpaper"]:
        wallpaper = kde_data["wallpaper"]["data"]

    # ------------------------------------------------------------
    # 1. base16 – build a grayscale ramp from the neutral palette
    # ------------------------------------------------------------
    neutral_palette = kde_palettes.get("neutral", [])
    if len(neutral_palette) < 101:
        neutral_palette += ["#000000"] * (101 - len(neutral_palette))

    # Indices for dark and light modes (0-100 scale)
    dark_indices  = [10, 20, 30, 40, 50, 60, 70, 80, 15, 25, 35, 45, 55, 65, 75, 85]
    light_indices = [80, 70, 60, 50, 40, 30, 20, 10, 85, 75, 65, 55, 45, 35, 25, 15]

    base16 = {}
    for i in range(16):
        key = f"base{i:02x}"
        dark_color  = neutral_palette[dark_indices[i]]  if dark_indices[i]  < len(neutral_palette) else "#000000"
        light_color = neutral_palette[light_indices[i]] if light_indices[i] < len(neutral_palette) else "#ffffff"
        default_color = dark_color if is_dark_mode else light_color
        base16[key] = {
            "dark":    {"color": dark_color},
            "default": {"color": default_color},
            "light":   {"color": light_color}
        }

    # ------------------------------------------------------------
    # 2. colors – map Material 3 roles from KDE schemes
    # ------------------------------------------------------------
    color_mapping = {
        "background": "background",
        "error": "error",
        "error_container": "errorContainer",
        "inverse_on_surface": "inverseOnSurface",
        "inverse_primary": "inversePrimary",
        "inverse_surface": "inverseSurface",
        "on_background": "onBackground",
        "on_error": "onError",
        "on_error_container": "onErrorContainer",
        "on_primary": "onPrimary",
        "on_primary_container": "onPrimaryContainer",
        "on_primary_fixed": "onPrimaryFixed",
        "on_primary_fixed_variant": "onPrimaryFixedVariant",
        "on_secondary": "onSecondary",
        "on_secondary_container": "onSecondaryContainer",
        "on_secondary_fixed": "onSecondaryFixed",
        "on_secondary_fixed_variant": "onSecondaryFixedVariant",
        "on_surface": "onSurface",
        "on_surface_variant": "onSurfaceVariant",
        "on_tertiary": "onTertiary",
        "on_tertiary_container": "onTertiaryContainer",
        "on_tertiary_fixed": "onTertiaryFixed",
        "on_tertiary_fixed_variant": "onTertiaryFixedVariant",
        "outline": "outline",
        "outline_variant": "outlineVariant",
        "primary": "primary",
        "primary_container": "primaryContainer",
        "primary_fixed": "primaryFixed",
        "primary_fixed_dim": "primaryFixedDim",
        "scrim": "scrim",
        "secondary": "secondary",
        "secondary_container": "secondaryContainer",
        "secondary_fixed": "secondaryFixed",
        "secondary_fixed_dim": "secondaryFixedDim",
        "shadow": "shadow",
        "source_color": None,          # special handling
        "surface": "surface",
        "surface_bright": "surfaceBright",
        "surface_container": "surfaceContainer",
        "surface_container_high": "surfaceContainerHigh",
        "surface_container_highest": "surfaceContainerHighest",
        "surface_container_low": "surfaceContainerLow",
        "surface_container_lowest": "surfaceContainerLowest",
        "surface_dim": "surfaceDim",
        "surface_tint": "surfaceTint",
        "surface_variant": "surfaceVariant",
        "tertiary": "tertiary",
        "tertiary_container": "tertiaryContainer",
        "tertiary_fixed": "tertiaryFixed",
        "tertiary_fixed_dim": "tertiaryFixedDim",
    }

    colors = {}
    for mat_key, kde_key in color_mapping.items():
        if kde_key is None:
            dark_val  = seed_color
            light_val = seed_color
        else:
            dark_val  = dark_scheme.get(kde_key, "#000000")
            light_val = light_scheme.get(kde_key, "#ffffff")
        default_val = dark_val if is_dark_mode else light_val
        colors[mat_key] = {
            "dark":    {"color": dark_val},
            "default": {"color": default_val},
            "light":   {"color": light_val}
        }

    # ------------------------------------------------------------
    # 3. palettes – map tonal palettes directly
    # ------------------------------------------------------------
    palette_mapping = {
        "error": "error",
        "neutral": "neutral",
        "neutral_variant": "neutralVariant",
        "primary": "primary",
        "secondary": "secondary",
        "tertiary": "tertiary"
    }
    keys = ["0", "5", "10", "15", "20", "25", "30", "35", "40",
            "50", "60", "70", "80", "90", "95", "98", "99", "100"]

    matugen_palettes = {}
    for mat_key, kde_key in palette_mapping.items():
        palette_array = kde_palettes.get(kde_key, [])
        if len(palette_array) < 101:
            palette_array += ["#000000"] * (101 - len(palette_array))
        palette_dict = {}
        for k in keys:
            idx = int(k)
            color = palette_array[idx] if idx < len(palette_array) else "#000000"
            palette_dict[k] = {"color": color}
        matugen_palettes[mat_key] = palette_dict

    # ------------------------------------------------------------
    # 4. assemble final Matugen JSON
    # ------------------------------------------------------------
    matugen_data = {
        "base16": base16,
        "colors": colors,
        "image": wallpaper,
        "is_dark_mode": is_dark_mode,
        "mode": mode,
        "palettes": matugen_palettes
    }
    return matugen_data


def main():
    parser = argparse.ArgumentParser(description="Convert KDE Material You JSON to Matugen JSON")
    parser.add_argument("input", help="Input KDE Material You JSON file")
    parser.add_argument("-o", "--output", default="matugen_output.json",
                        help="Output Matugen JSON file (default: matugen_output.json)")
    args = parser.parse_args()

    try:
        with open(args.input, 'r', encoding='utf-8') as f:
            kde_data = json.load(f)
    except Exception as e:
        print(f"Error reading input file: {e}")
        sys.exit(1)

    matugen_data = convert_kde_to_matugen(kde_data)

    try:
        with open(args.output, 'w', encoding='utf-8') as f:
            json.dump(matugen_data, f, indent=2)
        print(f"Successfully converted to {args.output}")
    except Exception as e:
        print(f"Error writing output file: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()