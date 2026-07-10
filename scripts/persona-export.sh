#!/usr/bin/env bash
# Export a persona as a portable prompt. Personas are plain markdown — nothing about
# them needs Claude Code. This script lifts one out of the repo and reshapes it for
# wherever you actually work: Claude.ai, the Messages API, Cursor, or an AGENTS.md.
#
#   scripts/persona-export.sh --list                     show the roster
#   scripts/persona-export.sh auditor                    system prompt → stdout
#   scripts/persona-export.sh auditor --target json      {"system": …} for the API
#   scripts/persona-export.sh auditor --target cursor    → .cursor/rules/the-auditor.mdc
#   scripts/persona-export.sh auditor --target agents    → AGENTS.md (idempotent block)
#   scripts/persona-export.sh --all --target cursor      the whole roster at once
#
# Options:
#   --target prompt|json|cursor|agents  output shape (default: prompt)
#   --out <path>                        write here instead of the target's default
#   --all                               export every persona in the roster
#   --list                              list personas and exit
#   -h, --help                          show this help
#
# Slugs resolve loosely: `auditor`, `the-auditor`, and a custom-personas/ file all work.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="prompt"
OUT=""
ALL=0

die() { echo "✗ $*" >&2; exit 1; }

usage() { awk 'NR>1 && /^#/ {sub(/^# ?/, ""); print; next} NR>1 {exit}' "$0"; }

# Read one key out of a file's YAML frontmatter. Handles folded scalars (`essence: >-`),
# which every shipped persona uses for its one-line essence.
fm_value() {
  awk -v key="$2" '
    NR==1 && /^---$/ { in_fm = 1; next }
    in_fm && /^---$/ { exit }
    !in_fm { next }
    folding {
      if ($0 ~ /^[[:space:]]/) {
        sub(/^[[:space:]]+/, "")
        buf = buf (buf == "" ? "" : " ") $0
        next
      }
      exit
    }
    $0 ~ "^" key ":" {
      v = substr($0, length(key) + 2)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
      if (v == "" || v == ">" || v == ">-" || v == "|" || v == "|-") { folding = 1; next }
      buf = v
      exit
    }
    END { print buf }
  ' "$1"
}

# The persona itself, with the frontmatter stripped off.
fm_body() {
  awk 'NR==1 && /^---$/ { in_fm = 1; next }
       in_fm && /^---$/ { in_fm = 0; past = 1; next }
       past' "$1"
}

# the-auditor → The Auditor;  the-dba → The DBA
display_name() {
  awk '
    BEGIN { split("dba api cli ui ux qa sre seo", a, " "); for (k in a) acronym[a[k]] = 1 }
    {
      gsub(/-/, " ")
      for (i = 1; i <= NF; i++) {
        w = tolower($i)
        $i = (w in acronym) ? toupper(w) : toupper(substr($i, 1, 1)) substr($i, 2)
      }
    } 1' <<<"$1"
}

# Every persona on disk, official then custom. Excludes the /persona engine itself.
roster() {
  local f
  shopt -s nullglob
  for f in "$ROOT"/skills/*/SKILL.md; do
    if [[ -f "$f" && "$(basename "$(dirname "$f")")" != "persona" ]]; then printf '%s\n' "$f"; fi
  done
  for f in "$ROOT"/custom-personas/*.md; do
    if [[ -f "$f" ]]; then printf '%s\n' "$f"; fi
  done
  shopt -u nullglob
}

slug_of() {
  if [[ "$(basename "$1")" == "SKILL.md" ]]; then
    basename "$(dirname "$1")"
  else
    basename "$1" .md
  fi
}

resolve() {
  local want="$1" candidate
  for candidate in \
    "$ROOT/skills/$want/SKILL.md" \
    "$ROOT/skills/the-$want/SKILL.md" \
    "$ROOT/custom-personas/$want.md" \
    "$ROOT/custom-personas/the-$want.md"; do
    if [[ -f "$candidate" ]]; then printf '%s\n' "$candidate"; return 0; fi
  done
  die "no persona named '$want'. Run --list to see the roster."
}

# The portable prompt: identity, essence, the degradation contract, then the persona.
render_prompt() {
  local file="$1" name essence
  name="$(display_name "$(slug_of "$file")")"
  essence="$(fm_value "$file" essence)"

  cat <<EOF
You are $name.

$essence

Adopt this identity for the rest of this conversation — its mindset, its method, its
quality bar, and its voice. The "Skills I Wield" section names tools that exist in
Claude Code; where you don't have one, fall back to the method below and do the work
by hand rather than asking the user to install anything. Work as this specialist would.
Don't narrate that you are following a persona file.

EOF
  fm_body "$file"
}

render_cursor() {
  local file="$1" essence
  essence="$(fm_value "$file" essence)"
  printf -- '---\ndescription: %s\nalwaysApply: false\n---\n\n' "$essence"
  render_prompt "$file"
}

# Send stdin to --out if given, otherwise to stdout.
emit() {
  if [[ -n "$OUT" ]]; then
    cat >"$OUT"
    echo "✓ Wrote $OUT" >&2
  else
    cat
  fi
}

# Replace the block between the markers if it exists, otherwise append it.
write_agents_block() {
  local out="$1" block_file="$2" tmp
  if [[ -f "$out" ]] && grep -q '<!-- persona:start -->' "$out"; then
    tmp="$(mktemp)"
    awk -v bf="$block_file" '
      /<!-- persona:start -->/ { while ((getline line < bf) > 0) print line; skipping = 1; next }
      /<!-- persona:end -->/   { skipping = 0; next }
      !skipping
    ' "$out" >"$tmp"
    mv "$tmp" "$out"
    echo "✓ Updated the persona block in $out"
  else
    if [[ -f "$out" ]]; then printf '\n' >>"$out"; fi
    cat "$block_file" >>"$out"
    echo "✓ Appended a persona block to $out"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="${2:-}"; [[ -n "$TARGET" ]] || die "--target needs a value"; shift 2 ;;
    --out)    OUT="${2:-}";    [[ -n "$OUT" ]]    || die "--out needs a path";    shift 2 ;;
    --all)    ALL=1; shift ;;
    --list)
      while IFS= read -r f; do
        printf '  %-22s %s\n' "$(slug_of "$f")" "$(fm_value "$f" essence)"
      done < <(roster)
      exit 0
      ;;
    -h|--help) usage; exit 0 ;;
    -*) die "unknown option: $1" ;;
    *)  PERSONA="$1"; shift ;;
  esac
done

case "$TARGET" in
  prompt|json|cursor|agents) ;;
  *) die "unknown target '$TARGET' (expected: prompt, json, cursor, agents)" ;;
esac

files=()
if (( ALL )); then
  while IFS= read -r f; do files+=("$f"); done < <(roster)
  [[ ${#files[@]} -gt 0 ]] || die "no personas found under $ROOT/skills"
else
  [[ -n "${PERSONA:-}" ]] || { usage; exit 1; }
  resolved="$(resolve "$PERSONA")"
  files=("$resolved")
fi

case "$TARGET" in
  prompt)
    for i in "${!files[@]}"; do
      if (( i > 0 )); then printf '\n\n===\n\n'; fi
      render_prompt "${files[$i]}"
    done | emit
    ;;

  json)
    # One object per persona: name, slug, essence, and the system prompt to send.
    # A single export is emitted as an object; --all as an array.
    if (( ALL )); then reshape='.'; else reshape='.[0]'; fi
    for f in "${files[@]}"; do
      jq -n \
        --arg slug "$(slug_of "$f")" \
        --arg name "$(display_name "$(slug_of "$f")")" \
        --arg essence "$(fm_value "$f" essence)" \
        --arg system "$(render_prompt "$f")" \
        '{slug: $slug, name: $name, essence: $essence, system: $system}'
    done | jq -s "$reshape" | emit
    ;;

  cursor)
    dir="${OUT:-$PWD/.cursor/rules}"
    mkdir -p "$dir"
    for f in "${files[@]}"; do
      out="$dir/$(slug_of "$f").mdc"
      render_cursor "$f" >"$out"
      echo "✓ Wrote $out"
    done
    echo "  Cursor loads these as rules. Invoke one with @$(slug_of "${files[0]}") in chat."
    ;;

  agents)
    out="${OUT:-$PWD/AGENTS.md}"
    block="$(mktemp)"
    trap 'rm -f "$block"' EXIT
    {
      echo '<!-- persona:start -->'
      echo '<!-- Generated by scripts/persona-export.sh — https://github.com/palusc/dotpersona -->'
      echo
      echo '# Personas'
      echo
      echo 'Adopt one of these identities when the user asks for it by name. Each is a complete'
      echo 'operating mode: a mindset, a method, a quality bar, and a voice.'
      for f in "${files[@]}"; do
        echo
        printf '## %s\n\n' "$(display_name "$(slug_of "$f")")"
        printf '> %s\n\n' "$(fm_value "$f" essence)"
        echo '<details><summary>Full definition</summary>'
        echo
        fm_body "$f"
        echo
        echo '</details>'
      done
      echo
      echo '<!-- persona:end -->'
    } >"$block"
    write_agents_block "$out" "$block"
    echo "  Read by Codex, Cursor, Zed, Amp, and anything else that honors AGENTS.md."
    ;;
esac
