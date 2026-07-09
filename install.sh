#!/usr/bin/env bash
# Persona installer — makes /persona and all persona skills available in Claude Code.
#
#   ./install.sh            symlink all skills into ~/.claude/skills
#                           (recommended: `git pull` then instantly up to date, and
#                            `/persona update` works)
#   ./install.sh --copy     copy instead of symlink (no git updates)
#   ./install.sh --update   git pull the repo and report what's new
#   ./install.sh --uninstall remove all installed persona skill links
#
set -euo pipefail

# Get the directory of this script, handling cases where it is run via stdin/curl
if [[ -z "${BASH_SOURCE[0]:-}" ]]; then
  echo "✗ install.sh cannot be run directly via curl | bash." >&2
  echo "  Please clone the repository first, then run install.sh from the repository root:" >&2
  echo "    git clone https://github.com/palusc/dotpersona.git" >&2
  echo "    cd dotpersona" >&2
  echo "    ./install.sh" >&2
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
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
if [[ ! -f "$REPO_DIR/skills/persona/SKILL.md" || ! -d "$REPO_DIR/skills" ]]; then
  echo "✗ This doesn't look like the dotpersona repo (no skills/persona/SKILL.md). Run install.sh from the repo root." >&2
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
        git -C "$REPO_DIR" --no-pager log --oneline "$before..$after" -- skills/ CHANGELOG.md || true
        echo "  See CHANGELOG.md for the full list. In Claude Code, run: /persona list"
      fi
    else
      echo "✗ Not a git checkout — can't auto-update. Re-clone from https://github.com/palusc/dotpersona" >&2
      exit 1
    fi
    exit 0
    ;;
  uninstall)
    for skill_path in "$REPO_DIR/skills"/*; do
      if [[ -d "$skill_path" ]]; then
        skill_name="$(basename "$skill_path")"
        TARGET="$SKILLS_DIR/$skill_name"
        if [[ -L "$TARGET" || -e "$TARGET" ]]; then
          rm -rf "$TARGET"
          echo "✓ Removed $TARGET"
        fi
      fi
    done
    exit 0
    ;;
esac

mkdir -p "$SKILLS_DIR"
mkdir -p "$REPO_DIR/custom-personas"

# Iterate over all skills inside skills/ and install them
for skill_path in "$REPO_DIR/skills"/*; do
  if [[ -d "$skill_path" ]]; then
    skill_name="$(basename "$skill_path")"
    TARGET="$SKILLS_DIR/$skill_name"
    
    # Back up anything already there (unless it's our own symlink/copy).
    if [[ -e "$TARGET" || -L "$TARGET" ]]; then
      if [[ -L "$TARGET" && "$(readlink "$TARGET")" == "$skill_path" ]]; then
        echo "✓ Already linked: $TARGET → $skill_path"
        continue
      fi
      backup="$TARGET.backup.$$"
      mv "$TARGET" "$backup"
      echo "! Existing $TARGET moved to $backup"
    fi

    if [[ "$MODE" == "copy" ]]; then
      cp -R "$skill_path" "$TARGET"
      echo "✓ Copied $skill_name → $TARGET"
    else
      ln -s "$skill_path" "$TARGET"
      echo "✓ Linked $TARGET → $skill_path"
    fi
  fi
done

echo
echo "Done. In Claude Code:"
echo "  /persona            → get recommended the best expert for your task"
echo "  /persona list       → see the whole roster"
echo "  /persona designer   → summon The Designer"
echo "  /persona new        → forge your own"
