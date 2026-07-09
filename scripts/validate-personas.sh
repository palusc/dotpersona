#!/usr/bin/env bash
# Validate that every persona (official in skills/*/SKILL.md and custom in custom-personas/*.md) matches the schema.
# Checks required frontmatter keys and the exact section headings.
# Exit 0 = all good; exit 1 = at least one persona is malformed. CI runs this on PRs.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

REQUIRED_KEYS=(persona name essence version skills triggers)
REQUIRED_SECTIONS=(
  "## Identity"
  "## Operating Principles"
  "## Method"
  "## Skills I Wield"
  "## Definition of Done"
  "## How I Communicate"
  "## Summon Me When / Not"
)

# Collect all persona files
files=()

# 1. Official personas (exclude skills/persona/SKILL.md)
for f in "$ROOT"/skills/*/SKILL.md; do
  if [[ -f "$f" && "$(basename "$(dirname "$f")")" != "persona" ]]; then
    files+=("$f")
  fi
done

# 2. Custom personas
shopt -s nullglob
for f in "$ROOT"/custom-personas/*.md; do
  if [[ -f "$f" ]]; then
    files+=("$f")
  fi
done

if [[ ${#files[@]} -eq 0 ]]; then
  echo "✓ No personas found to validate."
  exit 0
fi

for f in "${files[@]}"; do
  errs=()
  
  # Determine if it's an official skill or custom persona
  if [[ "$(basename "$f")" == "SKILL.md" ]]; then
    base="$(basename "$(dirname "$f")")"
    is_skill=true
  else
    base="$(basename "$f" .md)"
    is_skill=false
  fi

  # Frontmatter must be the first block delimited by --- … ---
  if ! head -1 "$f" | grep -q '^---$'; then
    errs+=("missing YAML frontmatter (file must start with ---)")
  fi
  fm="$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f{print}' "$f")"

  # Validate required keys
  for key in "${REQUIRED_KEYS[@]}"; do
    grep -qE "^${key}:" <<<"$fm" || errs+=("frontmatter missing key: ${key}:")
  done

  # Official skills must have a description for the skill manager
  if $is_skill; then
    grep -qE "^description:" <<<"$fm" || errs+=("frontmatter missing key: description:")
  fi

  # persona slug must match filename/foldername
  slug="$(grep -E '^persona:' <<<"$fm" | head -1 | sed 's/^persona:[[:space:]]*//')"
  if [[ -n "$slug" && "$slug" != "$base" ]]; then
    errs+=("persona slug '$slug' != expected name '$base'")
  fi

  for sec in "${REQUIRED_SECTIONS[@]}"; do
    grep -qF "$sec" "$f" || errs+=("missing section: $sec")
  done

  if [[ ${#errs[@]} -eq 0 ]]; then
    echo "✓ $base ($f)"
  else
    FAIL=1
    echo "✗ $base ($f)"
    for e in "${errs[@]}"; do echo "    - $e"; done
  fi
done

echo
if [[ $FAIL -eq 0 ]]; then
  echo "All ${#files[@]} personas valid."
else
  echo "Validation failed. Fix the issues above (see docs/persona-schema.md)."
fi
exit $FAIL
