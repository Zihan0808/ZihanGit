#!/bin/bash
# Author: Zihan Gao <zihan.gao.040808@gmail.com>
# Script: variables.sh
# Desc: Demonstrate positional parameters, variables and interactive input
# Arguments: Optional demonstration arguments; prompts for text and two integers
# Date: November 2026
# Source: MQB content/notebooks/shell-scripting.ipynb

printf 'This script was called with %s parameters\n' "$#"
printf 'The script was invoked as %s\n' "$0"
printf 'Argument: <%s>\n' "$@"
printf 'The first argument is <%s>\n' "$1"
printf 'The second argument is <%s>\n' "$2"

my_value='some string'
printf 'Current value: <%s>\n' "$my_value"
printf 'Please enter a new string: '
IFS= read -r my_value
printf 'New value: <%s>\n' "$my_value"

# This introductory example assumes the entered numbers are valid integers.
printf 'Enter two integers separated by spaces: '
read -r first_number second_number
printf 'You entered %s and %s\n' "$first_number" "$second_number"
my_sum=$(expr "$first_number" + "$second_number")
printf 'Their sum is: %s\n' "$my_sum"
