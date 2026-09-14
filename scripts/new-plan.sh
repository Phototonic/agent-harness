#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s SLUG\n' "$0" >&2
}

if [[ $# -eq 1 ]]; then
  slug=$1
elif [[ $# -eq 0 && -n ${SLUG:-} ]]; then
  slug=$SLUG
else
  usage
  exit 1
fi

if [[ ! $slug =~ ^[a-z0-9]+([_-][a-z0-9]+)*$ ]]; then
  printf 'Invalid slug: %s\n' "$slug" >&2
  exit 1
fi

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
destination_relative=".plans/active/$(date +%Y-%m-%d)-$slug.md"
destination="$root_dir/$destination_relative"

path_has_symlink_component() {
  local relative_path=$1
  local current=$root_dir
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

if path_has_symlink_component "$destination_relative"; then
  printf 'Refusing destination through symlink: %s\n' "$destination_relative" >&2
  exit 1
fi

if [[ -e $destination || -L $destination ]]; then
  printf 'Destination already exists: %s\n' "${destination#$root_dir/}" >&2
  exit 1
fi

if ! (set -o noclobber; cat "$root_dir/.plans/templates/execution-plan.md" > "$destination"); then
  printf 'Destination already exists: %s\n' "${destination#$root_dir/}" >&2
  exit 1
fi
printf '%s\n' "${destination#$root_dir/}"
