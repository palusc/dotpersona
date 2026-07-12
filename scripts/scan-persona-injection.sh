#!/usr/bin/env bash
# Deterministic pre-scan for a fetched community persona, run by `/persona remote` before
# Claude's own judgment pass (skills/persona/SKILL.md, "Remote install"). A visual or LLM
# skim-read can miss text hidden with invisible Unicode; this catches that class of trick
# mechanically, regardless of how the surrounding attack is phrased.
#
# This is a floor, not a ceiling: a clean run means these specific tricks weren't used, not
# that the persona is safe. It supplements the judgment-based scan, it doesn't replace it.
#
# Usage: scripts/scan-persona-injection.sh <file>
# Exit 0 = nothing flagged. Exit 1 = at least one flag (printed to stdout).
set -euo pipefail

file="${1:?usage: scan-persona-injection.sh <file>}"
[[ -f "$file" ]] || { echo "no such file: $file" >&2; exit 2; }

FLAGGED=0

# Invisible / bidi-override Unicode — hides text from a human or LLM reading the rendered
# body, since the characters occupy no visible space. Matched as raw UTF-8 bytes with
# fixed-string grep so this works with both BSD and GNU grep (no -P/PCRE dependency).
INVISIBLE_CHARS=(
  $'\xe2\x80\x8b' # U+200B ZERO WIDTH SPACE
  $'\xe2\x80\x8c' # U+200C ZERO WIDTH NON-JOINER
  $'\xe2\x80\x8d' # U+200D ZERO WIDTH JOINER
  $'\xe2\x81\xa0' # U+2060 WORD JOINER
  $'\xef\xbb\xbf' # U+FEFF ZERO WIDTH NO-BREAK SPACE / BOM
  $'\xe2\x80\xaa' # U+202A LEFT-TO-RIGHT EMBEDDING
  $'\xe2\x80\xab' # U+202B RIGHT-TO-LEFT EMBEDDING
  $'\xe2\x80\xac' # U+202C POP DIRECTIONAL FORMATTING
  $'\xe2\x80\xad' # U+202D LEFT-TO-RIGHT OVERRIDE
  $'\xe2\x80\xae' # U+202E RIGHT-TO-LEFT OVERRIDE
)
for c in "${INVISIBLE_CHARS[@]}"; do
  if grep -qF -- "$c" "$file"; then
    FLAGGED=1
    echo "flag: invisible/bidi-override Unicode present — can hide text from a visual read"
    break
  fi
done

# Known injection phrasing. A match is a lead, not a verdict — a persona can legitimately
# discuss these words (e.g. a security persona explaining prompt injection); Claude's own
# judgment pass decides whether it's actually an attack in context.
PATTERNS=(
  'ignore (all |the )?(previous|prior|above) instructions'
  'disregard (your|the) (system prompt|instructions)'
  '\brm[[:space:]]+-rf\b'
  'curl[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba)?sh'
  '\bexfiltrat'
  'send (this|the|all) (data|contents?|files?) to (http|ftp)'
)
for p in "${PATTERNS[@]}"; do
  if grep -qEi -- "$p" "$file"; then
    FLAGGED=1
    echo "flag: suspicious phrase matched pattern: $p"
  fi
done

if [[ $FLAGGED -eq 0 ]]; then
  echo "clean: no mechanical red flags (invisible Unicode, known injection phrasing)"
fi
exit $FLAGGED
