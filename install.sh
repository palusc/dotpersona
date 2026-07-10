#!/usr/bin/env bash
# Persona installer — makes /persona and all persona skills available in Claude Code.
#
#   ./install.sh             symlink all skills into ~/.claude/skills
#                            (recommended: `git pull` and you're instantly up to date,
#                             and `/persona update` works)
#   ./install.sh --copy      copy instead of symlink (no git updates)
#   ./install.sh --dry-run   print exactly what would change; write nothing
#   ./install.sh --update    git pull the repo and report what's new
#   ./install.sh --uninstall remove all installed persona skill links
#   ./install.sh --help      show this help
#
# --dry-run composes with the other modes: `--dry-run --uninstall` shows what an
# uninstall would remove. Piped through curl it clones into a temp directory and
# deletes it again, so `curl -fsSL … | bash -s -- --dry-run` never writes outside /tmp.
#
# Env: CLAUDE_SKILLS_DIR overrides the install target (default ~/.claude/skills).
set -euo pipefail

REPO_URL="https://github.com/palusc/dotpersona.git"
DRY_RUN=0
MODE="symlink"

# When run via `curl … | bash` there is no BASH_SOURCE, so there is no local checkout
# to install from. Get one first, then re-enter this script from disk.
if [[ -z "${BASH_SOURCE[0]:-}" ]]; then
  if [[ " $* " == *" --dry-run "* ]]; then
    TMP_DIR="$(mktemp -d)"
    echo "→ [dry-run] cloning a throwaway checkout into $TMP_DIR — nothing under \$HOME is touched"
    echo "→ [dry-run] a real install clones to ~/.dotpersona and links from there instead"
    echo
    git clone --quiet --depth 1 "$REPO_URL" "$TMP_DIR/dotpersona"
    status=0
    bash "$TMP_DIR/dotpersona/install.sh" "$@" || status=$?
    rm -rf "$TMP_DIR"
    echo "→ [dry-run] removed $TMP_DIR"
    exit "$status"
  fi

  REPO_DIR="$HOME/.dotpersona"
  echo "→ Preparing Dotpersona in $REPO_DIR ..."
  if [[ -d "$REPO_DIR/.git" ]]; then
    echo "→ Updating existing repository..."
    git -C "$REPO_DIR" pull --ff-only
  else
    echo "→ Cloning repository..."
    rm -rf "$REPO_DIR"
    git clone "$REPO_URL" "$REPO_DIR"
  fi
  echo "→ Running installer..."
  exec "$REPO_DIR/install.sh" "$@"
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

for arg in "$@"; do
  case "$arg" in
    --copy) MODE="copy" ;;
    --update) MODE="update" ;;
    --uninstall) MODE="uninstall" ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      # Print the contiguous comment block under the shebang, nothing else.
      awk 'NR>1 && /^#/ {sub(/^# ?/, ""); print; next} NR>1 {exit}' "$0"
      exit 0
      ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

# Sanity: are we actually in the repo?
if [[ ! -f "$REPO_DIR/skills/persona/SKILL.md" || ! -d "$REPO_DIR/skills" ]]; then
  echo "✗ This doesn't look like the dotpersona repo (no skills/persona/SKILL.md). Run install.sh from the repo root." >&2
  exit 1
fi

if (( DRY_RUN )); then
  echo "→ [dry-run] no files will be created, moved, or deleted."
  echo "  repo:   $REPO_DIR"
  echo "  target: $SKILLS_DIR"
  echo
fi

case "$MODE" in
  update)
    if [[ ! -d "$REPO_DIR/.git" ]]; then
      echo "✗ Not a git checkout — can't auto-update. Re-clone from $REPO_URL" >&2
      exit 1
    fi
    if (( DRY_RUN )); then
      echo "→ [dry-run] would run: git -C $REPO_DIR pull --ff-only"
      exit 0
    fi
    echo "→ Updating $REPO_DIR …"
    before="$(git -C "$REPO_DIR" rev-parse --short HEAD 2>/dev/null || echo none)"
    git -C "$REPO_DIR" pull --ff-only
    after="$(git -C "$REPO_DIR" rev-parse --short HEAD 2>/dev/null || echo none)"
    if [[ "$before" == "$after" ]]; then
      echo "✓ Already up to date ($after)."
    else
      echo "✓ Updated $before → $after. New personas & changes:"
      git -C "$REPO_DIR" --no-pager log --oneline "$before..$after" -- skills/ CHANGELOG.md || true
      echo "  See CHANGELOG.md for the full list. In Claude Code, run: /persona list"
    fi
    exit 0
    ;;
  uninstall)
    removed=0
    for skill_path in "$REPO_DIR/skills"/*; do
      [[ -d "$skill_path" ]] || continue
      TARGET="$SKILLS_DIR/$(basename "$skill_path")"
      if [[ -L "$TARGET" || -e "$TARGET" ]]; then
        removed=$((removed + 1))
        if (( DRY_RUN )); then
          echo "→ [dry-run] would remove $TARGET"
        else
          rm -rf "$TARGET"
          echo "✓ Removed $TARGET"
        fi
      fi
    done
    (( removed )) || echo "✓ Nothing to remove — no persona skills found in $SKILLS_DIR"
    exit 0
    ;;
esac

if (( DRY_RUN == 0 )); then
  mkdir -p "$SKILLS_DIR"
  mkdir -p "$REPO_DIR/custom-personas"
fi

# Iterate over all skills inside skills/ and install them
for skill_path in "$REPO_DIR/skills"/*; do
  [[ -d "$skill_path" ]] || continue
  skill_name="$(basename "$skill_path")"
  TARGET="$SKILLS_DIR/$skill_name"

  # Back up anything already there (unless it's our own symlink/copy).
  if [[ -e "$TARGET" || -L "$TARGET" ]]; then
    if [[ -L "$TARGET" && "$(readlink "$TARGET")" == "$skill_path" ]]; then
      echo "✓ Already linked: $TARGET → $skill_path"
      continue
    fi
    backup="$TARGET.backup.$$"
    if (( DRY_RUN )); then
      echo "→ [dry-run] would move existing $TARGET to $TARGET.backup.<pid>"
    else
      mv "$TARGET" "$backup"
      echo "! Existing $TARGET moved to $backup"
    fi
  fi

  if [[ "$MODE" == "copy" ]]; then
    if (( DRY_RUN )); then
      echo "→ [dry-run] would copy $skill_name → $TARGET"
    else
      cp -R "$skill_path" "$TARGET"
      echo "✓ Copied $skill_name → $TARGET"
    fi
  else
    if (( DRY_RUN )); then
      echo "→ [dry-run] would link $TARGET → $skill_path"
    else
      ln -s "$skill_path" "$TARGET"
      echo "✓ Linked $TARGET → $skill_path"
    fi
  fi
done

echo
if (( DRY_RUN )); then
  echo "Dry run complete. Nothing changed. Re-run without --dry-run to install."
  exit 0
fi

echo "Done. In Claude Code:"
echo "  /persona            → get recommended the best expert for your task"
echo "  /persona list       → see the whole roster"
echo "  /persona designer   → summon The Designer"
echo "  /persona new        → forge your own"
echo
echo "Not using Claude Code? scripts/persona-export.sh exports any persona as a"
echo "portable prompt for Claude.ai, the API, Cursor, or AGENTS.md — see docs/portability.md"
