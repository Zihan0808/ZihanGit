#!/bin/bash
# Author: Zihan Gao <zihan.gao.040808@gmail.com>
# Script: MyExampleScript.sh
# Desc: Print a greeting using the USER environment variable
# Arguments: None
# Date: November 2026
# Source: MQB content/notebooks/shell-scripting.ipynb

greeting="Hello"
user_name=$USER
printf '%s %s\n' "$greeting" "$user_name"
