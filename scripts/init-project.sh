#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s PROJECT_NAME\n' "$0" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

project_name=$1
if [[ ! $project_name =~ ^[a-z0-9]+([_-][a-z0-9]+)*$ ]]; then
  printf 'PROJECT_NAME must use lowercase letters, numbers, hyphens, or underscores.\n' >&2
  exit 1
fi

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

replace_token() {
  local file=$1

  if grep -q 'agent-harness' "$file"; then
    sed -i "s/agent-harness/$project_name/g" "$file"
    printf 'Updated %s\n' "${file#$root_dir/}"
  else
    printf 'No agent-harness token in %s; nothing to change.\n' "${file#$root_dir/}"
  fi
}

replace_token "$root_dir/README.md"
replace_token "$root_dir/AGENTS.md"
