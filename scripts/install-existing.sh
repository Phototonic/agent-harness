#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s TARGET_DIR\n' "$0" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

target_arg=$1
if [[ ! -d $target_arg ]]; then
  printf 'Target must be an existing directory: %s\n' "$target_arg" >&2
  exit 1
fi

template_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
target_dir=$(cd "$target_arg" && pwd -P)

if [[ $target_dir == "$template_root" ]]; then
  printf 'Refusing to install into the template root: %s\n' "$target_dir" >&2
  exit 1
fi

manifest_paths=(
  'AGENTS.md'
  'docs/CORE_BELIEFS.md'
  'docs/PLANS_GUIDE.md'
  'docs/HISTORY_GUIDE.md'
  'docs/ARCHITECTURE.md'
  'docs/QUALITY_AND_VALIDATION.md'
  'docs/histories/template.md'
  '.plans/active/.gitkeep'
  '.plans/completed/.gitkeep'
  '.plans/templates/execution-plan.md'
  'scripts/new-plan.sh'
  'scripts/new-history.sh'
  'HARNESS_VERSION'
)

for relative_path in "${manifest_paths[@]}"; do
  if [[ ! -f $template_root/$relative_path ]]; then
    printf 'Missing harness source: %s\n' "$relative_path" >&2
    exit 1
  fi
done

generated_mk=$(mktemp "${TMPDIR:-/tmp}/agent-harness.mk.XXXXXX")
trap 'rm -f "$generated_mk"' EXIT HUP INT TERM

{
  printf '%s\n' '# Include this fragment in your Makefile:' '# include agent-harness.mk' ''
  printf '%s\n' 'export SLUG' ''
  printf '%s\n' '.PHONY: harness-new-plan harness-new-history harness-validate' ''
  printf '%s\n' 'harness-new-plan:' $'\t@scripts/new-plan.sh' ''
  printf '%s\n' 'harness-new-history:' $'\t@scripts/new-history.sh' ''
  printf '%s\n' 'harness-validate:' $'\t@bash -n scripts/new-plan.sh scripts/new-history.sh'
} > "$generated_mk"

collisions=()

path_has_symlink_component() {
  local relative_path=$1
  local current=$target_dir
  local remainder=$relative_path
  local component

  while [[ -n $remainder ]]; do
    if [[ $remainder == */* ]]; then
      component=${remainder%%/*}
      remainder=${remainder#*/}
    else
      component=$remainder
      remainder=
    fi
    current=$current/$component
    if [[ -L $current ]]; then
      return 0
    fi
  done
  return 1
}

ensure_parent_directory() {
  local relative_parent=$1
  local current=$target_dir
  local remainder=$relative_parent
  local component

  [[ $remainder == . ]] && return 0

  while [[ -n $remainder ]]; do
    if [[ $remainder == */* ]]; then
      component=${remainder%%/*}
      remainder=${remainder#*/}
    else
      component=$remainder
      remainder=
    fi
    current=$current/$component
    if [[ -L $current || ( -e $current && ! -d $current ) ]]; then
      return 1
    fi
    if [[ ! -e $current ]]; then
      mkdir "$current"
    fi
  done
}

install_file() {
  local relative_path=$1
  local source_path=$2
  local destination=$target_dir/$relative_path
  local relative_parent

  if path_has_symlink_component "$relative_path"; then
    collisions[${#collisions[@]}]=$relative_path
    return 0
  fi

  if [[ -e $destination || -L $destination ]]; then
    if [[ -f $destination ]] && cmp -s "$source_path" "$destination"; then
      return 0
    fi
    collisions[${#collisions[@]}]=$relative_path
    return 0
  fi

  if [[ $relative_path == */* ]]; then
    relative_parent=${relative_path%/*}
  else
    relative_parent=.
  fi
  if ! ensure_parent_directory "$relative_parent"; then
    collisions[${#collisions[@]}]=$relative_path
    return 0
  fi

  cp "$source_path" "$destination"
}

for relative_path in "${manifest_paths[@]}"; do
  install_file "$relative_path" "$template_root/$relative_path"
done
install_file 'agent-harness.mk' "$generated_mk"

if (( ${#collisions[@]} > 0 )); then
  printf 'Collisions (existing paths differ; left unchanged):\n'
  for relative_path in "${collisions[@]}"; do
    printf '  %s\n' "$relative_path"
  done
else
  printf 'Collisions: none\n'
fi
printf 'Manual step: add "include agent-harness.mk" to your Makefile.\n'
