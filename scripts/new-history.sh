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
destination_dir="$root_dir/docs/histories/$(date +%Y-%m)"
destination="$destination_dir/$slug.md"

mkdir -p "$destination_dir"
cp "$root_dir/docs/histories/template.md" "$destination"
printf '%s\n' "${destination#$root_dir/}"
