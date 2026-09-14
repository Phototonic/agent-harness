#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s PROJECT_NAME [OWNER]\n' "$0" >&2
  printf '  PROJECT_NAME  project slug; lowercase letters, digits, hyphens, or underscores\n' >&2
  printf '  OWNER         license copyright holder; defaults to a <YOUR NAME> placeholder\n' >&2
  printf '  This script is for fresh template checkouts only; use scripts/install-existing.sh for existing repos.\n' >&2
}

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
marker_file="$root_dir/.agent-harness-template"
BUNDLED_HISTORY_RECORDS=(
  'docs/histories/2026-08/agent-quickstart-guide.md'
)

if [[ ! -f $marker_file || -L $marker_file ]]; then
  printf 'nothing to do; not a fresh template checkout\n'
  exit 0
fi

if [[ $# -gt 0 ]]; then
  if [[ $# -gt 2 ]]; then
    usage
    exit 1
  fi
  project_name=$1
  owner=${2-}
else
  project_name=${PROJECT:-}
  owner=${OWNER:-}
  if [[ -z $project_name ]]; then
    usage
    exit 1
  fi
fi

if [[ ! $project_name =~ ^[a-z0-9]+([_-][a-z0-9]+)*$ ]]; then
  printf 'PROJECT_NAME must use lowercase letters, numbers, hyphens, or underscores.\n' >&2
  exit 1
fi

if [[ $owner =~ $'[\r\n]' ]]; then
  printf 'OWNER must not contain newline or carriage return characters.\n' >&2
  exit 1
fi

quickstart_doc="$root_dir/docs/AGENT_QUICKSTART.md"

required_template_files=(README.md AGENTS.md LICENSE)
for required_file in "${required_template_files[@]}"; do
  if [[ ! -f $root_dir/$required_file || -L $root_dir/$required_file ]]; then
    printf 'Required template file is missing or not a regular file: %s\n' "$required_file" >&2
    exit 1
  fi
done

replace_in_place() {
  local expression=$1 file=$2 tmp

  if ! tmp=$(mktemp "${file}.tmp.XXXXXX"); then
    return 1
  fi
  if ! cp -p "$file" "$tmp"; then
    rm -f "$tmp"
    return 1
  fi
  if ! sed "$expression" "$file" > "$tmp"; then
    rm -f "$tmp"
    return 1
  fi
  if ! mv "$tmp" "$file"; then
    rm -f "$tmp"
    return 1
  fi
}

replace_token() {
  local file=$1 old=$2 new=$3

  if grep -q "$old" "$file"; then
    replace_in_place "s/$old/$new/g" "$file"
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
  replace_in_place "s/^Copyright (c) \(20[0-9][0-9]\) .*$/Copyright (c) \\1 $holder_escaped/" "$file"
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
  local file=$1 tmp

  if grep -q '^## Install with an agent' "$file"; then
    if ! tmp=$(mktemp "${file}.tmp.XXXXXX"); then
      return 1
    fi
    if ! cp -p "$file" "$tmp"; then
      rm -f "$tmp"
      return 1
    fi
    if ! awk '
      /^## Install with an agent/ { skip = 1 }
      skip && /^---$/            { skip = 0; next }
      !skip
    ' "$file" > "$tmp"; then
      rm -f "$tmp"
      return 1
    fi
    if ! mv "$tmp" "$file"; then
      rm -f "$tmp"
      return 1
    fi
    printf 'Removed bootstrap-only install section from %s\n' "${file#$root_dir/}"
  else
    printf 'No bootstrap-only install section in %s; nothing to change.\n' "${file#$root_dir/}"
  fi

  if grep -q '\[Install with an agent\]' "$file"; then
    replace_in_place 's/ • \[Install with an agent\](#install-with-an-agent)//; s/\[Install with an agent\](#install-with-an-agent) • //' "$file"
    printf 'Removed install link from the TOC in %s\n' "${file#$root_dir/}"
  fi
}

remove_install_section "$root_dir/README.md"

if [[ -f $quickstart_doc ]]; then
  rm -f "$quickstart_doc"
  printf 'Removed bootstrap-only %s\n' "${quickstart_doc#$root_dir/}"
fi

for bundled_history in "${BUNDLED_HISTORY_RECORDS[@]}"; do
  history_record="$root_dir/$bundled_history"
  if [[ -f $history_record ]]; then
    rm -f "$history_record"
    printf 'Removed template history record %s\n' "${history_record#$root_dir/}"
  fi
  rmdir "${history_record%/*}" 2>/dev/null || true
done

rm -f "$marker_file"
printf 'Removed template marker %s\n' "${marker_file#$root_dir/}"
