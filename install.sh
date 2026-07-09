#!/usr/bin/env bash
# Persona installer — makes /persona available in Claude Code.
#
#   ./install.sh            symlink this repo into ~/.claude/skills/persona
#                           (recommended: `git pull` then instantly up to date, and
#                            `/persona update` works)
#   ./install.sh --copy     copy instead of symlink (no git updates)
#   ./install.sh --update   git pull the repo and report what's new
#   ./install.sh --uninstall remove the /persona skill link
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
TARGET="$SKILLS_DIR/persona"
MODE="symlink"

for arg in "$@"; do
  case "$arg" in
    --copy) MODE="copy" ;;
    --update) MODE="update" ;;
    --uninstall) MODE="uninstall" ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//' | tail -n +2; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

# Sanity: are we actually in the repo?
if [[ ! -f "$REPO_DIR/SKILL.md" || ! -d "$REPO_DIR/personas" ]]; then
  echo "✗ This doesn't look like the dotpersona repo (no SKILL.md / personas/). Run install.sh from the repo root." >&2
  exit 1
fi

case "$MODE" in
  update)
    if [[ -d "$REPO_DIR/.git" ]]; then
      echo "→ Updating $REPO_DIR …"
      before="$(git -C "$REPO_DIR" rev-parse --short HEAD 2>/dev/null || echo none)"
      git -C "$REPO_DIR" pull --ff-only
      after="$(git -C "$REPO_DIR" rev-parse --short HEAD 2>/dev/null || echo none)"
      if [[ "$before" == "$after" ]]; then
        echo "✓ Already up to date ($after)."
      else
        echo "✓ Updated $before → $after. New personas & changes:"
        git -C "$REPO_DIR" --no-pager log --oneline "$before..$after" -- personas/ CHANGELOG.md || true
        echo "  See CHANGELOG.md for the full list. In Claude Code, run: /persona list"
      fi
    else
      echo "✗ Not a git checkout — can't auto-update. Re-clone from https://github.com/palusc/dotpersona" >&2
      exit 1
    fi
    exit 0
    ;;
  uninstall)
    if [[ -L "$TARGET" || -e "$TARGET" ]]; then
      rm -rf "$TARGET"; echo "✓ Removed $TARGET"
    else
      echo "Nothing to remove at $TARGET"
    fi
    exit 0
    ;;
esac

mkdir -p "$SKILLS_DIR"

# Back up anything already there (unless it's our own symlink).
if [[ -e "$TARGET" || -L "$TARGET" ]]; then
  if [[ -L "$TARGET" && "$(readlink "$TARGET")" == "$REPO_DIR" ]]; then
    echo "✓ Already linked: $TARGET → $REPO_DIR"
    echo "  Run '/persona' in Claude Code to start."
    exit 0
  fi
  backup="$TARGET.backup.$$"
  mv "$TARGET" "$backup"
  echo "! Existing $TARGET moved to $backup"
fi

if [[ "$MODE" == "copy" ]]; then
  cp -R "$REPO_DIR" "$TARGET"
  rm -rf "$TARGET/.git"
  echo "✓ Copied repo → $TARGET (no auto-updates; re-run install.sh after a manual pull)"
else
  ln -s "$REPO_DIR" "$TARGET"
  echo "✓ Linked $TARGET → $REPO_DIR"
  echo "  'git pull' in the repo (or './install.sh --update') keeps /persona current."
fi

echo
echo "Done. In Claude Code:"
echo "  /persona            → get recommended the best expert for your task"
echo "  /persona list       → see the whole roster"
echo "  /persona designer   → summon The Designer"
echo "  /persona new        → forge your own"
