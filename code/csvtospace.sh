if [[ $# -ne 1 ]]; then
    printf 'Usage: bash %s INPUT_FILE\n' "$0" >&2
    exit 2
fi

input_file="$1"
if [[ ! -f "$input_file" || ! -r "$input_file" ]]; then
    printf 'Error: input is not a readable regular file: %s\n' "$input_file" >&2
    exit 1
fi

input_name="${input_file##*/}"
output_file="../results/${input_name}.txt"

if ! mkdir -p ../results; then
    printf 'Error: cannot create ../results/\n' >&2
    exit 1
fi

if [[ "$input_file" -ef "$output_file" ]]; then
    printf 'Error: output refers to the input file: %s\n' "$output_file" >&2
    exit 1
fi

if ! tr ',' ' ' < "$input_file" > "$output_file"; then
    printf 'Error: conversion failed: %s\n' "$output_file" >&2
    exit 1
fi

printf 'Created: %s\n' "$output_file"
exit 0