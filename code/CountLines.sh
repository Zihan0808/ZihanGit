#!/bin/bash
# Count newline characters in one readable file (MQB Shell Scripting).

if [[ $# -ne 1 ]]; then
    printf 'Usage: bash %s INPUT_FILE\n' "$0" >&2
    exit 2
fi

input_file=$1
if [[ ! -f "$input_file" || ! -r "$input_file" ]]; then
    printf 'Error: input is not a readable regular file: %s\n' "$input_file" >&2
    exit 1
fi

# An unterminated final line adds no newline to this count.
if ! newline_count=$(wc -l < "$input_file"); then
    printf 'Error: could not count newlines in %s\n' "$input_file" >&2
    exit 1
fi

printf '%s has a newline count of %s.\n' "$input_file" "$newline_count"
