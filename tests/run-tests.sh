#!/usr/bin/env bash
set -u
set -o pipefail

SOURCE_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
WORKSPACE=$(mktemp -d "${TMPDIR:-/tmp}/agent-harness-tests.XXXXXX") || {
  printf 'Unable to create test workspace\n' >&2
  exit 1
}
if [[ -z $WORKSPACE || ! -d $WORKSPACE ]]; then
  printf 'Unable to create test workspace\n' >&2
  exit 1
fi
MODE=template
if [[ ! -f $SOURCE_ROOT/docs/AGENT_QUICKSTART.md ]]; then
  MODE=scaffold
fi

cleanup() {
  rm -rf "$WORKSPACE"
}
trap cleanup EXIT HUP INT TERM

passed=0
failed=0

fail() {
  printf 'ASSERTION FAILED: %s\n' "$*" >&2
  return 1
}

assert_file_exists() {
  local path=$1
  if [[ -f $path ]]; then
    return 0
  fi
  fail "expected file: $path"
}

assert_not_exists() {
  local path=$1
  if [[ ! -e $path && ! -L $path ]]; then
    return 0
  fi
  fail "expected path not to exist: $path"
}

assert_contains() {
  local path=$1 text=$2
  if grep -Fq -- "$text" "$path"; then
    return 0
  fi
  fail "expected $path to contain: $text"
}

assert_not_contains() {
  local path=$1 text=$2
  if ! grep -Fq -- "$text" "$path"; then
    return 0
  fi
  fail "expected $path not to contain: $text"
}

assert_line() {
  local path=$1 text=$2
  if grep -Fqx -- "$text" "$path"; then
    return 0
  fi
  fail "expected $path to contain the exact line: $text"
}

assert_same() {
  local first=$1 second=$2
  if cmp -s "$first" "$second"; then
    return 0
  fi
  fail "expected files to be unchanged: $first and $second"
}

assert_checksum_same() {
  local before=$1 after=$2 description=$3
  if [[ $before == "$after" ]]; then
    return 0
  fi
  fail "expected $description to be unchanged"
}

copy_template() {
  local destination=$1
  mkdir -p "$destination"
  cp -R "$SOURCE_ROOT"/. "$destination"/
}

tree_checksum() {
  local directory=$1
  (
    cd "$directory"
    {
      find . -type d -print | LC_ALL=C sort
      find . -type f -print | LC_ALL=C sort | while IFS= read -r path; do
        printf 'file %s ' "$path"
        cksum "$path"
      done
    } | cksum
  )
}

case_reinit_no_op() (
  set -e
  case_dir=$(mktemp -d "$WORKSPACE/case.XXXXXX")
  trap 'rm -rf "$case_dir"' EXIT
  repo=$case_dir/repo
  copy_template "$repo"

  PROJECT=reinit-check OWNER='Test Owner' \
    bash "$repo/scripts/init-project.sh" >"$case_dir/first.log" 2>&1
  assert_not_exists "$repo/.agent-harness-template"
  before=$(tree_checksum "$repo")
  PROJECT=reinit-check OWNER='Test Owner' \
    bash "$repo/scripts/init-project.sh" >"$case_dir/second.log" 2>&1
  after=$(tree_checksum "$repo")
  assert_checksum_same "$before" "$after" 'the second init tree'
)

case_preservation() (
  set -e
  case_dir=$(mktemp -d "$WORKSPACE/case.XXXXXX")
  trap 'rm -rf "$case_dir"' EXIT
  repo=$case_dir/repo
  copy_template "$repo"

  printf '%s\n' 'user documentation' > "$repo/docs/user-notes.md"
  printf '%s\n' 'user August history' > "$repo/docs/histories/2026-08/user-record.md"
  mkdir -p "$repo/docs/histories/2026-09"
  printf '%s\n' 'user September history' > "$repo/docs/histories/2026-09/user-record.md"

  PROJECT=preservation-check OWNER='Test Owner' \
    bash "$repo/scripts/init-project.sh" >"$case_dir/init.log" 2>&1

  assert_file_exists "$repo/docs/user-notes.md"
  assert_contains "$repo/docs/user-notes.md" 'user documentation'
  assert_file_exists "$repo/docs/histories/2026-08/user-record.md"
  assert_file_exists "$repo/docs/histories/2026-09/user-record.md"
  assert_not_exists "$repo/docs/histories/2026-08/agent-quickstart-guide.md"
  assert_file_exists "$repo/docs/histories/template.md"
)

case_invalid_project() (
  set -e
  case_dir=$(mktemp -d "$WORKSPACE/case.XXXXXX")
  trap 'rm -rf "$case_dir"' EXIT
  repo=$case_dir/repo
  copy_template "$repo"

  if [[ $MODE == template ]]; then
    if bash "$repo/scripts/init-project.sh" '../invalid-project' > /dev/null 2>&1; then
      fail 'positional invalid PROJECT was accepted'
    fi
  fi

  if [[ $MODE == template ]]; then
    if PROJECT='invalid/project' OWNER='Test Owner' \
      bash "$repo/scripts/init-project.sh" > /dev/null 2>&1; then
      fail 'environment invalid PROJECT was accepted'
    fi
  fi
)

case_invalid_slugs() (
  set -e
  case_dir=$(mktemp -d "$WORKSPACE/case.XXXXXX")
  trap 'rm -rf "$case_dir"' EXIT
  repo=$case_dir/repo
  copy_template "$repo"
  before=$(tree_checksum "$case_dir")

  invalid_slugs=(
    '../evil'
    '../../../README'
    'has.dot'
    'HasUppercase'
    'has space'
  )
  for slug in "${invalid_slugs[@]}"; do
    if bash "$repo/scripts/new-plan.sh" "$slug" > /dev/null 2>&1; then
      fail "new-plan accepted invalid slug: $slug"
    fi
    if bash "$repo/scripts/new-history.sh" "$slug" > /dev/null 2>&1; then
      fail "new-history accepted invalid slug: $slug"
    fi
  done

  after=$(tree_checksum "$case_dir")
  assert_checksum_same "$before" "$after" 'the invalid-slug test workspace'
)

case_no_overwrite() (
  set -e
  case_dir=$(mktemp -d "$WORKSPACE/case.XXXXXX")
  trap 'rm -rf "$case_dir"' EXIT
  repo=$case_dir/repo
  copy_template "$repo"

  today=$(date +%Y-%m-%d)
  month=$(date +%Y-%m)
  mkdir -p "$repo/.plans/active" "$repo/docs/histories/$month"
  printf '%s\n' 'existing plan content' > "$repo/.plans/active/$today-existing.md"
  printf '%s\n' 'existing history content' > "$repo/docs/histories/$month/existing.md"
  plan_before=$case_dir/plan.before
  history_before=$case_dir/history.before
  cp "$repo/.plans/active/$today-existing.md" "$plan_before"
  cp "$repo/docs/histories/$month/existing.md" "$history_before"

  if bash "$repo/scripts/new-plan.sh" existing > /dev/null 2>&1; then
    fail 'new-plan overwrote an existing destination'
  fi
  if bash "$repo/scripts/new-history.sh" existing > /dev/null 2>&1; then
    fail 'new-history overwrote an existing destination'
  fi

  assert_same "$plan_before" "$repo/.plans/active/$today-existing.md"
  assert_same "$history_before" "$repo/docs/histories/$month/existing.md"
)

case_fresh_init_cleanup() (
  set -e
  case_dir=$(mktemp -d "$WORKSPACE/case.XXXXXX")
  trap 'rm -rf "$case_dir"' EXIT
  repo=$case_dir/repo
  copy_template "$repo"

  PROJECT=fresh-check OWNER='Fresh Owner' \
    bash "$repo/scripts/init-project.sh" >"$case_dir/init.log" 2>&1

  assert_not_exists "$repo/.agent-harness-template"
  assert_not_exists "$repo/docs/AGENT_QUICKSTART.md"
  assert_not_contains "$repo/README.md" '## Install with an agent'
  assert_not_contains "$repo/README.md" '[Install with an agent](#install-with-an-agent)'
  assert_contains "$repo/LICENSE" 'Copyright (c) 2026 Fresh Owner'
  assert_line "$repo/HARNESS_VERSION" '0.1.0'
)

case_owner_env_injection() (
  set -e
  case_dir=$(mktemp -d "$WORKSPACE/case.XXXXXX")
  trap 'rm -rf "$case_dir"' EXIT
  repo=$case_dir/repo
  copy_template "$repo"

  make -C "$repo" init PROJECT=owner-check OWNER="x; touch $case_dir/pwned; #" \
    >"$case_dir/init.log" 2>&1

  assert_not_exists "$case_dir/pwned"
  assert_contains "$repo/LICENSE" "Copyright (c) 2026 x; touch $case_dir/pwned; #"

  if make -C "$repo" new-history SLUG='../evil' >"$case_dir/slug.log" 2>&1; then
    fail 'Make-level invalid SLUG was accepted'
  fi
)

case_marker_free_license_guard() (
  set -e
  case_dir=$(mktemp -d "$WORKSPACE/case.XXXXXX")
  trap 'rm -rf "$case_dir"' EXIT
  repo=$case_dir/repo
  mkdir -p "$repo/scripts"
  cp "$SOURCE_ROOT/scripts/init-project.sh" "$repo/scripts/init-project.sh"
  printf '%s\n' 'foreign repository mentioning agent-harness' > "$repo/README.md"
  printf '%s\n' 'foreign instructions' > "$repo/AGENTS.md"
  printf '%s\n' 'MIT License' '' 'Copyright (c) 2026 Original Holder' > "$repo/LICENSE"
  before=$(tree_checksum "$repo")

  bash "$repo/scripts/init-project.sh" marker-free 'Replacement Holder' >"$case_dir/init.log" 2>&1

  after=$(tree_checksum "$repo")
  assert_checksum_same "$before" "$after" 'the marker-free tree'
  assert_contains "$repo/LICENSE" 'Copyright (c) 2026 Original Holder'
)

case_preflight_missing_file() (
  set -e
  case_dir=$(mktemp -d "$WORKSPACE/case.XXXXXX")
  trap 'rm -rf "$case_dir"' EXIT
  repo=$case_dir/repo
  copy_template "$repo"
  rm "$repo/LICENSE"
  before=$(tree_checksum "$repo")

  if PROJECT=preflight-check OWNER='Preflight Owner' \
    bash "$repo/scripts/init-project.sh" >"$case_dir/init.log" 2>&1; then
    fail 'init accepted a missing required template file'
  fi

  after=$(tree_checksum "$repo")
  assert_checksum_same "$before" "$after" 'the preflight-failure tree'
)

case_temp_file_safety() (
  set -e
  case_dir=$(mktemp -d "$WORKSPACE/case.XXXXXX")
  trap 'rm -rf "$case_dir"' EXIT
  repo=$case_dir/repo
  copy_template "$repo"
  sentinel=$case_dir/sentinel
  sentinel_before=$case_dir/sentinel.before
  printf '%s\n' 'do not truncate this sentinel' > "$sentinel"
  cp "$sentinel" "$sentinel_before"
  ln -s "$sentinel" "$repo/README.md.tmp"

  PROJECT=temp-file-check OWNER='Temp Owner' \
    bash "$repo/scripts/init-project.sh" >"$case_dir/init.log" 2>&1

  assert_same "$sentinel_before" "$sentinel"
)

case_new_plan_parent_symlink() (
  set -e
  case_dir=$(mktemp -d "$WORKSPACE/case.XXXXXX")
  trap 'rm -rf "$case_dir"' EXIT
  repo=$case_dir/repo
  external=$case_dir/external
  copy_template "$repo"
  mkdir -p "$external"
  printf '%s\n' 'external sentinel' > "$external/sentinel"
  rm -rf "$repo/.plans/active"
  ln -s "$external" "$repo/.plans/active"
  repo_before=$(tree_checksum "$repo")
  external_before=$(tree_checksum "$external")

  if bash "$repo/scripts/new-plan.sh" symlink-check >"$case_dir/plan.log" 2>&1; then
    fail 'new-plan followed a parent symlink'
  fi

  assert_checksum_same "$repo_before" "$(tree_checksum "$repo")" 'the parent-symlink repository'
  assert_checksum_same "$external_before" "$(tree_checksum "$external")" 'the parent-symlink target'
  [[ -L $repo/.plans/active ]] || fail 'new-plan changed the symlinked parent'
)

case_existing_repo_symlink_parent() (
  set -e
  case_dir=$(mktemp -d "$WORKSPACE/case.XXXXXX")
  trap 'rm -rf "$case_dir"' EXIT
  target=$case_dir/target
  mkdir -p "$target/.git/docs"
  printf '%s\n' 'git metadata' > "$target/.git/keep"
  printf '%s\n' 'docs sentinel' > "$target/.git/docs/sentinel"
  ln -s .git/docs "$target/docs"
  git_before=$(tree_checksum "$target/.git")

  if ! bash "$SOURCE_ROOT/scripts/install-existing.sh" "$target" >"$case_dir/install.log" 2>&1; then
    fail 'existing-repo install returned non-zero for a symlink parent'
  fi

  assert_contains "$case_dir/install.log" 'docs/CORE_BELIEFS.md'
  assert_checksum_same "$git_before" "$(tree_checksum "$target/.git")" '.git after symlink-parent install'
)

case_existing_repo_install() (
  set -e
  case_dir=$(mktemp -d "$WORKSPACE/case.XXXXXX")
  trap 'rm -rf "$case_dir"' EXIT
  target=$case_dir/target
  mkdir -p "$target/docs" "$target/.git"
  printf '%s\n' 'user README' > "$target/README.md"
  printf '%s\n' 'user license' > "$target/LICENSE"
  printf '%s\n' 'user makefile' > "$target/Makefile"
  printf '%s\n' 'user gitignore' > "$target/.gitignore"
  printf '%s\n' 'user history guide' > "$target/docs/HISTORY_GUIDE.md"
  printf '%s\n' 'git metadata' > "$target/.git/keep"

  reference_dir=$case_dir/reference
  mkdir -p "$reference_dir"
  user_paths=(README.md LICENSE Makefile .gitignore docs/HISTORY_GUIDE.md)
  for index in "${!user_paths[@]}"; do
    cp "$target/${user_paths[$index]}" "$reference_dir/$index"
  done
  git_before=$(tree_checksum "$target/.git")

  if ! bash "$SOURCE_ROOT/scripts/install-existing.sh" "$target" >"$case_dir/install-first.log" 2>&1; then
    fail 'existing-repo install returned non-zero'
  fi

  for index in "${!user_paths[@]}"; do
    assert_same "$reference_dir/$index" "$target/${user_paths[$index]}"
  done
  assert_checksum_same "$git_before" "$(tree_checksum "$target/.git")" '.git after first install'
  assert_contains "$case_dir/install-first.log" 'docs/HISTORY_GUIDE.md'

  manifest_paths=(
    AGENTS.md
    docs/CORE_BELIEFS.md
    docs/PLANS_GUIDE.md
    docs/HISTORY_GUIDE.md
    docs/ARCHITECTURE.md
    docs/QUALITY_AND_VALIDATION.md
    docs/histories/template.md
    .plans/active/.gitkeep
    .plans/completed/.gitkeep
    .plans/templates/execution-plan.md
    scripts/new-plan.sh
    scripts/new-history.sh
    HARNESS_VERSION
    agent-harness.mk
  )
  for relative_path in "${manifest_paths[@]}"; do
    assert_file_exists "$target/$relative_path"
  done
  assert_contains "$target/agent-harness.mk" 'harness-new-plan:'
  assert_not_exists "$target/tests"
  assert_not_exists "$target/scripts/init-project.sh"
  assert_not_exists "$target/scripts/install-existing.sh"

  before_second=$(tree_checksum "$target")
  if ! bash "$SOURCE_ROOT/scripts/install-existing.sh" "$target" >"$case_dir/install-second.log" 2>&1; then
    fail 'second existing-repo install returned non-zero'
  fi
  after_second=$(tree_checksum "$target")
  assert_checksum_same "$before_second" "$after_second" 'the second existing-repo install tree'
  assert_checksum_same "$git_before" "$(tree_checksum "$target/.git")" '.git after second install'
  assert_contains "$case_dir/install-second.log" 'docs/HISTORY_GUIDE.md'
)

case_bash_syntax() (
  set -e
  case_dir=$(mktemp -d "$WORKSPACE/case.XXXXXX")
  trap 'rm -rf "$case_dir"' EXIT
  repo=$case_dir/repo
  copy_template "$repo"
  bash -n "$repo"/scripts/*.sh
)

run_case() {
  local name=$1 function_name=$2 status
  printf '[ RUN      ] %s\n' "$name"
  "$function_name"
  status=$?
  if [[ $status -eq 0 ]]; then
    passed=$((passed + 1))
    printf '[       OK ] %s\n' "$name"
  else
    failed=$((failed + 1))
    printf '[  FAILED  ] %s\n' "$name" >&2
  fi
}

printf 'Running %s-mode regression suite\n' "$MODE"
run_case 'bash syntax' case_bash_syntax
run_case 'invalid PROJECT' case_invalid_project
run_case 'invalid slugs' case_invalid_slugs
run_case 'no-overwrite refusal' case_no_overwrite
run_case 'new-plan parent symlink refusal' case_new_plan_parent_symlink

if [[ $MODE == template ]]; then
  run_case 're-init is a no-op' case_reinit_no_op
  run_case 'user and history preservation' case_preservation
  run_case 'fresh-init cleanup' case_fresh_init_cleanup
  run_case 'OWNER environment injection' case_owner_env_injection
  run_case 'marker-free LICENSE guard' case_marker_free_license_guard
  run_case 'preflight missing-file refusal' case_preflight_missing_file
  run_case 'temporary-file safety' case_temp_file_safety
  run_case 'existing-repo install' case_existing_repo_install
  run_case 'existing-repo parent symlink refusal' case_existing_repo_symlink_parent
fi

printf 'Passed: %d\n' "$passed"
printf 'Failed: %d\n' "$failed"
[[ $failed -eq 0 ]]
