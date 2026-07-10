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
  slug="$(grep -E '^persona:' <<<"$fm" | head -1 | awk '{print $2}')"
  if [[ -n "$slug" && "$slug" != "$base" ]]; then
    errs+=("persona slug '$slug' != expected name '$base'")
  fi

  # version: must be SemVer. scripts/check-version-bump.sh relies on being able to
  # sort -V these, and `/persona list` shows them to users.
  ver="$(grep -E '^version:' <<<"$fm" | head -1 | awk '{print $2}')"
  if [[ -n "$ver" && ! "$ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    errs+=("version '$ver' is not SemVer (expected MAJOR.MINOR.PATCH)")
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

# Manifest sync: plugin.json's "skills" array must list every skills/*/SKILL.md
# on disk, and nothing that no longer exists. Prevents a repeat of the bug where
# The DBA, The Tester, and The Wordsmith shipped but were never added to
# plugin.json, silently breaking installs via the plugin marketplace path.
if [[ -f "$ROOT/plugin.json" ]]; then
  manifest_skills="$(jq -r '.skills[]' "$ROOT/plugin.json" | LC_ALL=C sort)"
  disk_skills="$(cd "$ROOT" && find skills -mindepth 2 -maxdepth 2 -name SKILL.md | LC_ALL=C sort)"

  missing="$(comm -23 <(echo "$disk_skills") <(echo "$manifest_skills"))"
  stale="$(comm -13 <(echo "$disk_skills") <(echo "$manifest_skills"))"

  if [[ -n "$missing" ]]; then
    FAIL=1
    echo "✗ plugin.json is missing skills that exist on disk:"
    awk '{print "    - " $0}' <<<"$missing"
  fi
  if [[ -n "$stale" ]]; then
    FAIL=1
    echo "✗ plugin.json lists skills that no longer exist on disk:"
    awk '{print "    - " $0}' <<<"$stale"
  fi
  if [[ -z "$missing" && -z "$stale" ]]; then
    echo "✓ plugin.json matches skills/ on disk."
  fi

  # Release hygiene: whatever version plugin.json claims must be a real, released
  # heading in CHANGELOG.md. Catches a manifest bump that never got written up, and a
  # changelog entry whose release was never actually shipped in the manifest.
  plugin_version="$(jq -r '.version' "$ROOT/plugin.json")"
  if [[ -f "$ROOT/CHANGELOG.md" ]]; then
    if grep -qE "^## \[${plugin_version//./\\.}\]" "$ROOT/CHANGELOG.md"; then
      echo "✓ plugin.json version $plugin_version has a CHANGELOG entry."
    else
      FAIL=1
      echo "✗ plugin.json is at version $plugin_version, but CHANGELOG.md has no '## [$plugin_version]' heading."
    fi
  fi
fi

echo

# Roster-table sync: skills/persona/SKILL.md's own "Roster (shipped personas)" table must
# mention every shipped persona on disk. This is a repeat of the same drift bug that hit
# docs/banner.svg and docs/recommended-skills.md (The Product Manager, The DBA, The Tester and
# The Wordsmith all went missing from hand-maintained lists after shipping) — catch it here too.
if [[ -f "$ROOT/skills/persona/SKILL.md" ]]; then
  roster_section="$(awk '/^## Roster \(shipped personas\)/{f=1} f{print} f&&/^---$/{exit}' "$ROOT/skills/persona/SKILL.md")"
  roster_missing=()
  for f in "$ROOT"/skills/*/SKILL.md; do
    base="$(basename "$(dirname "$f")")"
    [[ "$base" == "persona" ]] && continue
    needle="$(sed -E 's/^the-//; s/-/ /g' <<<"$base")"
    grep -qi -- "$needle" <<<"$roster_section" || roster_missing+=("$base")
  done
  if [[ ${#roster_missing[@]} -gt 0 ]]; then
    FAIL=1
    echo "✗ skills/persona/SKILL.md's roster table is missing:"
    printf '    - %s\n' "${roster_missing[@]}"
  else
    echo "✓ skills/persona/SKILL.md roster table matches skills/ on disk."
  fi
fi

echo

# Trigger collisions: informational, not fatal. /persona routes by matching
# `triggers` against workspace context — two personas claiming the exact same
# trigger word is a real ambiguity signal (a legitimate soft overlap can still
# be fine, resolved by `consults`), so this is surfaced but doesn't fail CI.
trigfile="$(mktemp)"
trap 'rm -f "$trigfile"' EXIT
for f in "$ROOT"/skills/*/SKILL.md; do
  base="$(basename "$(dirname "$f")")"
  [[ "$base" == "persona" ]] && continue
  fm="$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f{print}' "$f")"
  while IFS= read -r trig; do
    [[ -n "$trig" ]] && echo "$(tr '[:upper:]' '[:lower:]' <<<"$trig")|$base" >> "$trigfile"
  done < <(awk '/^triggers:/{flag=1; next} /^[a-zA-Z_]+:/{flag=0} flag && /^[[:space:]]*-/{gsub(/^[[:space:]]*-[[:space:]]*/,""); print}' <<<"$fm")
done

collisions="$(sort "$trigfile" | cut -d'|' -f1 | uniq -d)"
if [[ -n "$collisions" ]]; then
  echo "ℹ triggers shared by more than one persona (routing may be ambiguous):"
  while IFS= read -r trig; do
    owners="$(grep -F "${trig}|" "$trigfile" | cut -d'|' -f2 | paste -sd' ' -)"
    echo "    - \"$trig\" → $owners"
  done <<<"$collisions"
else
  echo "✓ No trigger collisions across the roster."
fi
if [[ $FAIL -eq 0 ]]; then
  echo "All ${#files[@]} personas valid."
else
  echo "Validation failed. Fix the issues above (see docs/persona-schema.md)."
fi
exit $FAIL
