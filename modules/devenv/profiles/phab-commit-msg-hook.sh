#!/usr/bin/env bash
# Validate commit message sections
# Used as a commit-msg hook — receives the commit message file path as $1
set -euo pipefail

msg_file="$1"
msg=$(cat "$msg_file")

errors=0

# Check required sections
for section in "Summary:" "Test Plan:"; do
  if ! printf '%s' "$msg" | grep -qF "$section"; then
    echo "ERROR: Missing required section '${section}'" >&2
    errors=$((errors + 1))
  fi
done

if [ "$errors" -gt 0 ]; then
  echo "" >&2
  echo "Commit message must include 'Summary:' and 'Test Plan:' sections." >&2
  echo "Use 'cz commit' to generate the correct format interactively." >&2
  exit 1
fi

# Check Summary comes before Test Plan
summary_line=$(printf '%s' "$msg" | grep -n "^Summary:" | head -1 | cut -d: -f1)
testplan_line=$(printf '%s' "$msg" | grep -n "^Test Plan:" | head -1 | cut -d: -f1)
if [ -n "$summary_line" ] && [ -n "$testplan_line" ] && [ "$summary_line" -gt "$testplan_line" ]; then
  echo "ERROR: 'Summary:' must come before 'Test Plan:'" >&2
  exit 1
fi

# Validate title (first line) length
title=$(printf '%s' "$msg" | head -1)
if [ ${#title} -gt 72 ]; then
  echo "ERROR: Title exceeds 72 characters (${#title} chars)" >&2
  exit 1
fi

# Validate title does not end with punctuation
title_last_char="${title: -1}"
if [[ "$title_last_char" =~ [\!\.\,\;\:] ]]; then
  echo "ERROR: Title must not end with punctuation ('${title_last_char}')" >&2
  exit 1
fi
