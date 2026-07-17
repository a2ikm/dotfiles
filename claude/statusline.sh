#!/bin/bash
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name')
dir=$(echo "$input" | jq -r '.workspace.current_dir' | xargs basename)
printf '\033[2m%s\033[0m \033[2m|\033[0m \033[2m%s\033[0m' "$model" "$dir"
