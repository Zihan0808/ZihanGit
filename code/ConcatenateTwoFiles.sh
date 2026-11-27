#!/bin/bash
# Join two input files byte for byte in argument order (MQB Shell Scripting).
# Run from the repository root and name an output beneath results/.

if [[ $# -ne 3 ]]; then
    printf 'Usage: bash %s FIRST_FILE SECOND_FILE results/OUTPUT_FILE\n' "$0" >&2
    exit 2
fi

first_file=$1
second_file=$2
output_file=$3
for input_file in "$first_file" "$second_file"; do
    if [[ ! -f "$input_file" || ! -r "$input_file" ]]; then
        printf 'Error: input is not a readable regular file: %s\n' "$input_file" >&2
        exit 1
    fi
done

if [[ "$output_file" -ef "$first_file" || "$output_file" -ef "$second_file" ]]; then
    printf 'Error: output refers to an input file: %s\n' "$output_file" >&2
    exit 1
fi
if [[ -L "$output_file" || ( -e "$output_file" && ! -f "$output_file" ) ]]; then
    printf 'Error: output is not a regular file: %s\n' "$output_file" >&2
    exit 1
fi

output_directory=$(realpath -m -- "$(dirname -- "$output_file")") || exit 1
results_directory="$(pwd -P)/results"
if [[ "$output_directory" != "$results_directory" && "$output_directory" != "$results_directory/"* ]]; then
    printf 'Error: output must be under results/: %s\n' "$output_file" >&2
    exit 1
fi

mkdir -p -- "$output_directory" || exit 1
# Read both inputs successfully before replacing a previous generated output.
temp_output=$(mktemp -- "$output_directory/.concatenate.XXXXXX") || exit 1
trap 'rm -f -- "$temp_output"' EXIT
if ! { cat < "$first_file" && cat < "$second_file"; } > "$temp_output" ||
        ! mv -fT -- "$temp_output" "$output_file"; then
    printf 'Error: concatenation failed: %s\n' "$output_file" >&2
    exit 1
fi

printf 'Merged file: %s\n' "$output_file"
cat -- "$output_file"
