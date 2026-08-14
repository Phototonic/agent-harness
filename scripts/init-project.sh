#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s PROJECT_NAME [OWNER]\n' "$0" >&2
  printf '  PROJECT_NAME  project slug; lowercase letters, digits, hyphens, or underscores\n' >&2
  printf '  OWNER         license copyright holder; defaults to a <YOUR NAME> placeholder\n' >&2
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

project_name=$1
if [[ ! $project_name =~ ^[a-z0-9]+([_-][a-z0-9]+)*$ ]]; then
  printf 'PROJECT_NAME must use lowercase letters, numbers, hyphens, or underscores.\n' >&2
  exit 1
fi

# OWNER is everything after the project name, joined with spaces, so it survives
# make's word splitting (OWNER="Jane Doe" reaches here as two words).
owner=""
if [[ $# -ge 2 ]]; then
  owner=${*:2}
fi

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

replace_token() {
  local file=$1 old=$2 new=$3

  if grep -q "$old" "$file"; then
    sed -i "s/$old/$new/g" "$file"
    printf 'Updated %s\n' "${file#$root_dir/}"
  else
    printf 'No %s token in %s; nothing to change.\n' "$old" "${file#$root_dir/}"
  fi
}

replace_token "$root_dir/README.md" 'agent-harness' "$project_name"
replace_token "$root_dir/AGENTS.md" 'agent-harness' "$project_name"

# License copyright holder: OWNER when given, otherwise a placeholder to fill in.
# The copyright line is matched structurally so no author name is hardcoded here
# and forks of the template work unchanged.
set_license_holder() {
  local file=$1 holder=$2
  local holder_escaped copyright_line
  holder_escaped=$(printf '%s' "$holder" | sed 's/[&/\\]/\\&/g')

  copyright_line=$(grep '^Copyright (c) 20[0-9][0-9] ' "$file" | head -1 || true)
  if [[ -z $copyright_line ]]; then
    printf 'No copyright line in %s; nothing to change.\n' "${file#$root_dir/}"
    return
  fi
  if [[ $copyright_line == *" $holder" ]]; then
    printf 'License holder already set in %s; nothing to change.\n' "${file#$root_dir/}"
    return
  fi
  sed -i "s/^Copyright (c) \(20[0-9][0-9]\) .*$/Copyright (c) \\1 $holder_escaped/" "$file"
  printf 'Updated %s\n' "${file#$root_dir/}"
}

if [[ -n $owner ]]; then
  set_license_holder "$root_dir/LICENSE" "$owner"
else
  set_license_holder "$root_dir/LICENSE" '<YOUR NAME>'
fi

# Bootstrap-only content does not ship in the scaffolded project: the install
# prompt section of README (plus its TOC entry), the agent quick-start doc, and
# the template's own history records. They describe the template repo, not the
# project being created, and may reference the template's author and repository.
remove_install_section() {
  local file=$1

  if grep -q '^## Install with an agent' "$file"; then
    awk '
      /^## Install with an agent/ { skip = 1 }
      skip && /^---$/            { skip = 0; next }
      !skip
    ' "$file" > "$file.tmp"
    mv "$file.tmp" "$file"
    printf 'Removed bootstrap-only install section from %s\n' "${file#$root_dir/}"
  else
    printf 'No bootstrap-only install section in %s; nothing to change.\n' "${file#$root_dir/}"
  fi

  if grep -q '\[Install with an agent\]' "$file"; then
    sed -i 's/ • \[Install with an agent\](#install-with-an-agent)//; s/\[Install with an agent\](#install-with-an-agent) • //' "$file"
    printf 'Removed install link from the TOC in %s\n' "${file#$root_dir/}"
  fi
}

remove_install_section "$root_dir/README.md"

quickstart_doc="$root_dir/docs/AGENT_QUICKSTART.md"
if [[ -f $quickstart_doc ]]; then
  rm -f "$quickstart_doc"
  printf 'Removed bootstrap-only %s\n' "${quickstart_doc#$root_dir/}"
fi

for history_dir in "$root_dir"/docs/histories/*/; do
  [[ -d $history_dir ]] || continue
  rm -rf "$history_dir"
  printf 'Removed template history records in %s\n' "${history_dir#$root_dir/}"
done