#!/usr/bin/env bash
# Integration tests for scripts/persona-export.sh
set -euo pipefail

# Determine script directories
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TESTS_DIR/.." && pwd)"
EXPORT_SCRIPT="$ROOT_DIR/scripts/persona-export.sh"

# Create a temporary directory for test artifacts and register cleanup
TMP_DIR="$(mktemp -d)"
# shellcheck disable=SC2329
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Test assertion helpers
assert_success() {
  local cmd="$1"
  if ! eval "$cmd" >/dev/null 2>&1; then
    echo "✗ Expected success but command failed: $cmd" >&2
    exit 1
  fi
}

assert_failure() {
  local cmd="$1"
  if eval "$cmd" >/dev/null 2>&1; then
    echo "✗ Expected failure but command succeeded: $cmd" >&2
    exit 1
  fi
}

assert_grep() {
  local pattern="$1" file="$2"
  if ! grep -q "$pattern" "$file"; then
    echo "✗ Expected file '$file' to contain pattern: $pattern" >&2
    exit 1
  fi
}

assert_not_grep() {
  local pattern="$1" file="$2"
  if grep -q "$pattern" "$file"; then
    echo "✗ Expected file '$file' to NOT contain pattern: $pattern" >&2
    exit 1
  fi
}

assert_count() {
  local pattern="$1" file="$2" expected="$3" actual
  actual=$(grep -c "$pattern" "$file" || true)
  if [[ "$actual" -ne "$expected" ]]; then
    echo "✗ Expected file '$file' to contain pattern '$pattern' exactly $expected times, got $actual" >&2
    exit 1
  fi
}

echo "=== Running persona-export.sh Tests ==="

# 1. Test help and usage
echo "Testing help and usage..."
assert_success "bash '$EXPORT_SCRIPT' --help"
assert_success "bash '$EXPORT_SCRIPT' -h"
assert_failure "bash '$EXPORT_SCRIPT' --invalid-option"

# 2. Test roster list
echo "Testing --list..."
list_out="$TMP_DIR/list.txt"
assert_success "bash '$EXPORT_SCRIPT' --list > '$list_out'"
assert_grep "auditor" "$list_out"
assert_grep "dba" "$list_out"
assert_grep "architect" "$list_out"

# 3. Test single export: prompt
echo "Testing --target prompt..."
prompt_out="$TMP_DIR/prompt.txt"
assert_success "bash '$EXPORT_SCRIPT' auditor --target prompt > '$prompt_out'"
assert_grep "You are The Auditor" "$prompt_out"
assert_grep "Operating Principles" "$prompt_out"

# 4. Test single export: json
echo "Testing --target json..."
json_out="$TMP_DIR/prompt.json"
assert_success "bash '$EXPORT_SCRIPT' auditor --target json > '$json_out'"
# Ensure it is valid JSON and contains the correct structure
if ! command -v jq >/dev/null 2>&1; then
  echo "jq is missing, skipping json verification"
else
  test "$(jq -r '.slug' "$json_out")" = "the-auditor"
  test "$(jq -r '.name' "$json_out")" = "The Auditor"
  test "$(jq -r '.essence' "$json_out" | wc -c)" -gt 10
  test "$(jq -r '.system' "$json_out" | wc -c)" -gt 500
fi

# 5. Test single export: cursor (creates a rule file)
echo "Testing --target cursor..."
cursor_dir="$TMP_DIR/cursor_rules"
assert_success "bash '$EXPORT_SCRIPT' auditor --target cursor --out '$cursor_dir'"
assert_grep "alwaysApply: false" "$cursor_dir/the-auditor.mdc"
assert_grep "description: " "$cursor_dir/the-auditor.mdc"
assert_grep "You are The Auditor" "$cursor_dir/the-auditor.mdc"

# 6. Test --all export: cursor
echo "Testing --all --target cursor..."
all_cursor_dir="$TMP_DIR/all_cursor_rules"
assert_success "bash '$EXPORT_SCRIPT' --all --target cursor --out '$all_cursor_dir'"
# Roster size should be at least 10 official personas
official_count=$(find "$ROOT_DIR/skills" -mindepth 1 -maxdepth 1 -type d ! -name persona | wc -l)
shopt -s nullglob
files=("$all_cursor_dir"/*.mdc)
shopt -u nullglob
if [[ "${#files[@]}" -lt "$official_count" ]]; then
  echo "✗ Expected at least $official_count .mdc files, got ${#files[@]}" >&2
  exit 1
fi

# 7. Test single export: agents (creates an AGENTS.md block) and test IDEMPOTENCY
echo "Testing --target agents (idempotency checks)..."
agents_file="$TMP_DIR/AGENTS.md"

# Case A: Exporting to a non-existent file
assert_success "bash '$EXPORT_SCRIPT' auditor --target agents --out '$agents_file'"
assert_count '<!-- persona:start -->' "$agents_file" 1
assert_count '<!-- persona:end -->' "$agents_file" 1
assert_grep '## The Auditor' "$agents_file"

# Case B: Re-exporting to verify it overwrites the block rather than duplicating it
assert_success "bash '$EXPORT_SCRIPT' auditor --target agents --out '$agents_file'"
assert_count '<!-- persona:start -->' "$agents_file" 1
assert_count '<!-- persona:end -->' "$agents_file" 1

# Case C: Exporting with surrounding user content preserves it
cat > "$agents_file" <<EOF
# My Custom Config
This is some customized header content.

<!-- persona:start -->
original persona content to be replaced
<!-- persona:end -->

Some footer content.
EOF

assert_success "bash '$EXPORT_SCRIPT' auditor --target agents --out '$agents_file'"
assert_grep '# My Custom Config' "$agents_file"
assert_grep 'Some footer content.' "$agents_file"
assert_grep '## The Auditor' "$agents_file"
assert_not_grep 'original persona content to be replaced' "$agents_file"
assert_count '<!-- persona:start -->' "$agents_file" 1
assert_count '<!-- persona:end -->' "$agents_file" 1

# Verify re-running maintains the exact surrounding text and block
assert_success "bash '$EXPORT_SCRIPT' auditor --target agents --out '$agents_file'"
assert_grep '# My Custom Config' "$agents_file"
assert_grep 'Some footer content.' "$agents_file"
assert_count '<!-- persona:start -->' "$agents_file" 1
assert_count '<!-- persona:end -->' "$agents_file" 1

# Case D: Exporting with multiple personas in the agents target (--all)
echo "Testing --all --target agents..."
all_agents_file="$TMP_DIR/ALL_AGENTS.md"
assert_success "bash '$EXPORT_SCRIPT' --all --target agents --out '$all_agents_file'"
assert_count '<!-- persona:start -->' "$all_agents_file" 1
assert_count '<!-- persona:end -->' "$all_agents_file" 1
assert_grep '## The Auditor' "$all_agents_file"
assert_grep '## The DBA' "$all_agents_file"
assert_grep '## The Architect' "$all_agents_file"

# Case E: Re-exporting --all to verify idempotency
assert_success "bash '$EXPORT_SCRIPT' --all --target agents --out '$all_agents_file'"
assert_count '<!-- persona:start -->' "$all_agents_file" 1
assert_count '<!-- persona:end -->' "$all_agents_file" 1

# 8. Test error handling for invalid persona name
echo "Testing error cases..."
assert_failure "bash '$EXPORT_SCRIPT' non_existent_persona"
assert_failure "bash '$EXPORT_SCRIPT' non_existent_persona --target prompt"

echo "✓ All persona-export.sh tests passed successfully!"
exit 0
