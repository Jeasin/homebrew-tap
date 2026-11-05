#!/usr/bin/env bash
#
# Refresh `version` and `sha256` in Casks/*.rb from each upstream's latest
# GitHub release, using the rules in .github/casks.json.
#
# Only those two lines are rewritten, so everything else in the cask
# (livecheck, zap, caveats, depends_on, ...) is left untouched.
#
# Usage:
#   scripts/bump-casks.sh              # every cask in the config
#   scripts/bump-casks.sh astris       # just one
#
# Requires: bash, curl, jq, awk, sha256sum or shasum.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config="$repo_root/.github/casks.json"
casks_dir="$repo_root/Casks"

log() { printf '%s\n' "$*"; }

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

command -v curl >/dev/null 2>&1 || die "curl is required"
command -v jq >/dev/null 2>&1 || die "jq is required"
[[ -f "$config" ]] || die "config not found: $config"

digest() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{ print $1 }'
  else
    shasum -a 256 | awk '{ print $1 }'
  fi
}

stanza_value() {
  awk -F'"' -v key="$2" '$0 ~ "^  " key " \"" { print $2; exit }' "$1"
}

targets=("$@")
if (( ${#targets[@]} == 0 )); then
  while IFS= read -r name; do
    targets+=("$name")
  done < <(jq -r 'keys[]' "$config")
fi
(( ${#targets[@]} > 0 )) || die "no casks configured in $config"

status=0

for cask in "${targets[@]}"; do
  cfg="$(jq -c --arg c "$cask" '.[$c] // empty' "$config")"
  [[ -n "$cfg" ]] || die "no entry for '$cask' in .github/casks.json"

  gh_repo="$(jq -r '.repo' <<<"$cfg")"
  tag_pattern="$(jq -r '.tag' <<<"$cfg")"
  asset_pattern="$(jq -r '.asset' <<<"$cfg")"
  version_template="$(jq -r '.version' <<<"$cfg")"
  cask_file="$casks_dir/$cask.rb"

  [[ -f "$cask_file" ]] || die "cask file not found: $cask_file"

  api="https://api.github.com/repos/$gh_repo/releases/latest"
  if ! release="$(curl -fsSL --retry 3 --retry-delay 2 \
      -H "Accept: application/vnd.github+json" \
      ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
      "$api")"; then
    log "$cask: could not fetch $api"
    status=1
    continue
  fi

  if ! tag="$(jq -er '.tag_name' <<<"$release")"; then
    log "$cask: release has no tag_name"
    status=1
    continue
  fi

  tag_vars="$(jq -n --arg s "$tag" --arg re "$tag_pattern" \
    '$s | try capture($re) catch empty')"
  if [[ -z "$tag_vars" ]]; then
    log "$cask: tag '$tag' does not match /$tag_pattern/"
    status=1
    continue
  fi

  asset="$(jq -c --arg re "$asset_pattern" \
    '[ .assets[] | select(.name | test($re)) ] | if length == 1 then .[0] else empty end' \
    <<<"$release")"
  if [[ -z "$asset" ]]; then
    log "$cask: expected exactly one asset matching /$asset_pattern/"
    status=1
    continue
  fi
  asset_name="$(jq -r '.name' <<<"$asset")"
  asset_url="$(jq -r '.browser_download_url' <<<"$asset")"

  asset_vars="$(jq -n --arg s "$asset_name" --arg re "$asset_pattern" \
    '$s | try capture($re) catch empty')"
  [[ -n "$asset_vars" ]] || asset_vars="{}"

  # Guard against a mismatched asset slipping through (e.g. a -debug build).
  asset_version="$(jq -r '.version // empty' <<<"$asset_vars")"
  tag_version="$(jq -r '.version // empty' <<<"$tag_vars")"
  if [[ -n "$asset_version" && -n "$tag_version" && "$asset_version" != "$tag_version" ]]; then
    log "$cask: asset '$asset_name' version ($asset_version) != tag version ($tag_version)"
    status=1
    continue
  fi

  # Placeholders may come from the tag ($tag_vars) or the asset ($asset_vars).
  vars="$(jq -cn --argjson t "$tag_vars" --argjson a "$asset_vars" '$t + $a')"
  version="$version_template"
  for key in $(printf '%s' "$version_template" | grep -o '{[a-z_]*}' | tr -d '{}'); do
    value="$(jq -r --arg k "$key" '.[$k] // empty' <<<"$vars")"
    if [[ -z "$value" ]]; then
      log "$cask: no '$key' capture in tag /$tag_pattern/ or asset /$asset_pattern/"
      status=1
      continue 2
    fi
    version="${version//\{$key\}/$value}"
  done

  if ! sha="$(curl -fsSL --retry 3 "$asset_url" | digest)"; then
    log "$cask: could not download $asset_url"
    status=1
    continue
  fi
  if [[ ! "$sha" =~ ^[0-9a-f]{64}$ ]]; then
    log "$cask: invalid SHA-256 for $asset_url"
    status=1
    continue
  fi

  current_version="$(stanza_value "$cask_file" version)"
  current_sha="$(stanza_value "$cask_file" sha256)"
  if [[ "$current_version" == "$version" && "$current_sha" == "$sha" ]]; then
    log "$cask: already at $version"
    continue
  fi

  tmp="$cask_file.tmp"
  awk -v v="$version" -v s="$sha" '
    /^  version "/ { print "  version \"" v "\""; next }
    /^  sha256 "/  { print "  sha256 \"" s "\""; next }
    { print }
  ' "$cask_file" >"$tmp"
  mv "$tmp" "$cask_file"

  if ! grep -Fq "version \"$version\"" "$cask_file"; then
    log "$cask: failed to write version into $cask_file"
    status=1
    continue
  fi

  log "$cask: $current_version -> $version"
done

exit "$status"
