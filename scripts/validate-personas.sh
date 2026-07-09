#!/usr/bin/env bash
# Validate that every persona in personas/*.md matches the schema.
# Checks required frontmatter keys and the exact section headings.
# Exit 0 = all good; exit 1 = at least one persona is malformed. CI runs this on PRs.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIR="$ROOT/personas"
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

shopt -s nullglob
files=("$DIR"/*.md)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "✗ No personas found in $DIR"; exit 1
fi

for f in "${files[@]}"; do
  base="$(basename "$f" .md)"
  errs=()

  # Frontmatter must be the first block delimited by --- … ---
  if ! head -1 "$f" | grep -q '^---$'; then
    errs+=("missing YAML frontmatter (file must start with ---)")
  fi
  fm="$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f{print}' "$f")"

  for key in "${REQUIRED_KEYS[@]}"; do
    grep -qE "^${key}:" <<<"$fm" || errs+=("frontmatter missing key: ${key}:")
  done

  # persona slug must match filename
  slug="$(grep -E '^persona:' <<<"$fm" | head -1 | sed 's/^persona:[[:space:]]*//')"
  if [[ -n "$slug" && "$slug" != "$base" ]]; then
    errs+=("persona slug '$slug' != filename '$base'")
  fi

  for sec in "${REQUIRED_SECTIONS[@]}"; do
    grep -qF "$sec" "$f" || errs+=("missing section: $sec")
  done

  if [[ ${#errs[@]} -eq 0 ]]; then
    echo "✓ $base"
  else
    FAIL=1
    echo "✗ $base"
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
