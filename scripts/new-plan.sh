#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s SLUG\n' "$0" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

slug=$1
root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
destination="$root_dir/.plans/active/$(date +%Y-%m-%d)-$slug.md"

cp "$root_dir/.plans/templates/execution-plan.md" "$destination"
printf '%s\n' "${destination#$root_dir/}"
