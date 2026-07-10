#!/usr/bin/env bash
# A persona's behaviour is its contract. If a SKILL.md changes, its `version:` has to move
# too — otherwise two people both running "the-auditor 1.0.0" get different reviews, and
# nobody can say which one they had.
#
# CI runs this on every pull request. Run it yourself before opening one:
#
#   bash scripts/check-version-bump.sh              # compare against main
#   bash scripts/check-version-bump.sh some-branch  # compare against something else
#
# Exit 0 = every touched persona bumped its version. Exit 1 = at least one didn't.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

BASE_REF="${1:-${GITHUB_BASE_REF:-main}}"

# CI checkouts are frequently shallow or missing the base branch entirely.
if ! git rev-parse --verify -q "${BASE_REF}^{commit}" >/dev/null 2>&1; then
  git fetch --quiet origin "$BASE_REF" 2>/dev/null || true
  if git rev-parse --verify -q FETCH_HEAD >/dev/null 2>&1; then
    BASE_REF="FETCH_HEAD"
  fi
fi
if ! git rev-parse --verify -q "${BASE_REF}^{commit}" >/dev/null 2>&1; then
  echo "⚠ base ref '${1:-main}' not found — nothing to compare against, skipping."
  exit 0
fi

MERGE_BASE="$(git merge-base "$BASE_REF" HEAD)"

# Pull `version:` out of a persona's frontmatter, reading from stdin.
version_of() {
  awk '
    NR == 1 && /^---$/ { in_fm = 1; next }
    in_fm && /^---$/ { exit }
    in_fm && /^version:/ {
      sub(/^version:[[:space:]]*/, "")
      gsub(/[[:space:]]|"|'"'"'/, "")
      print
      exit
    }
  '
}

FAIL=0
CHECKED=0

while IFS= read -r f; do
  [[ -n "$f" ]] || continue
  [[ -f "$f" ]] || continue

  new="$(version_of <"$f")"
  # The /persona engine carries no version: key. Schema validation owns that rule.
  [[ -n "$new" ]] || continue

  # A brand-new persona has nothing to bump against.
  if ! git cat-file -e "$MERGE_BASE:$f" 2>/dev/null; then
    echo "✓ $f — new persona at $new"
    CHECKED=$((CHECKED + 1))
    continue
  fi

  old="$(git show "$MERGE_BASE:$f" | version_of)"
  CHECKED=$((CHECKED + 1))

  if [[ "$old" == "$new" ]]; then
    FAIL=1
    echo "✗ $f changed but version: is still $new"
    echo "    Bump it — patch for wording, minor for a sharper method or a new principle."
    continue
  fi

  # SemVer must move forwards, never back.
  lowest="$(printf '%s\n%s\n' "$old" "$new" | sort -V | head -1)"
  if [[ "$lowest" != "$old" ]]; then
    FAIL=1
    echo "✗ $f went backwards: $old → $new"
    continue
  fi

  echo "✓ $f — $old → $new"
done < <(git diff --name-only --diff-filter=d "$MERGE_BASE" HEAD -- 'skills/*/SKILL.md' 'custom-personas/*.md')

echo
if (( CHECKED == 0 )); then
  echo "✓ No persona files changed against $BASE_REF."
  exit 0
fi

if (( FAIL )); then
  echo "Version check failed. See the 'Improving an existing persona' section of CONTRIBUTING.md."
  exit 1
fi

echo "✓ All $CHECKED touched persona(s) bumped their version."
