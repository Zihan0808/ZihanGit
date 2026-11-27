#!/bin/bash
# Author: Zihan Gao
# Script: tabtocsv.sh
# Description: Replace tabs with commas; write results/INPUT_BASENAME.csv.
# Usage: bash code/tabtocsv.sh INPUT_FILE (from repository root)
# Updated: 2026-11-25

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
output_file="results/${input_name}.csv"

if ! mkdir -p results; then
    printf 'Error: cannot create results/\n' >&2
    exit 1
fi

if [[ "$input_file" -ef "$output_file" ]]; then
    printf 'Error: output refers to the input file: %s\n' "$output_file" >&2
    exit 1
fi

if [[ -L "$output_file" || ( -e "$output_file" && ! -f "$output_file" ) ]]; then
    printf 'Error: output is not a regular file: %s\n' "$output_file" >&2
    exit 1
fi

# Publish the result only after a successful conversion.
temp_output=$(mktemp -- "results/.$input_name.XXXXXX") || exit 1
trap 'rm -f -- "$temp_output"' EXIT
if ! tr '\t' ',' < "$input_file" > "$temp_output" ||
        ! mv -fT -- "$temp_output" "$output_file"; then
    printf 'Error: conversion failed: %s\n' "$output_file" >&2
    exit 1
fi

printf 'Created: %s\n' "$output_file"
exit 0
