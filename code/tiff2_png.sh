#!/bin/bash
# Convert copies of lowercase .tif images in the current directory.
if (( $# != 0 )); then
    printf 'Usage: %s (run from the image directory)\n' "$0" >&2
    exit 2
fi

shopt -s nullglob
images=(./*.tif)
if (( ${#images[@]} == 0 )); then
    printf 'No .tif files found in the current directory.\n' >&2
    exit 1
fi

if command -v magick >/dev/null 2>&1; then
    converter=magick
elif command -v convert >/dev/null 2>&1; then
    converter=convert
else
    printf 'ImageMagick is required (magick or convert).\n' >&2
    exit 127
fi

for filename in "${images[@]}"; do
    printf 'Converting %s\n' "$filename"
    "$converter" "$filename" "${filename%.tif}.png" || exit 1
done
