#!/bin/bash

set -u

command -v opencode >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/starship"
cache_file="$cache_dir/opencode-sessions.json"
lock_dir="$cache_dir/opencode-sessions.lock"
now=$(date +%s)

mkdir -p "$cache_dir"

if [[ ! -f "$cache_file" ]] || (( now - $(stat -c %Y "$cache_file") >= 5 )); then
  if mkdir "$lock_dir" 2>/dev/null; then
    (
      trap 'rm -rf "$lock_dir"' EXIT
      tmp_file=$(mktemp "$cache_dir/opencode-sessions.XXXXXX")
      if opencode session list --format json >"$tmp_file" && jq -e 'type == "array"' "$tmp_file" >/dev/null; then
        mv "$tmp_file" "$cache_file"
      else
        rm -f "$tmp_file"
      fi
    ) </dev/null >/dev/null 2>&1 &
  fi
fi

[[ -s "$cache_file" ]] || exit 0

jq -r --arg directory "$PWD" --argjson now_ms "$((now * 1000))" '
  def duration($milliseconds):
    (($milliseconds / 1000) | if . < 0 then 0 else floor end) as $seconds
    | if $seconds < 60 then "\($seconds)s"
      elif $seconds < 3600 then "\(($seconds / 60) | floor)m"
      elif $seconds < 86400 then "\(($seconds / 3600) | floor)h"
      else "\(($seconds / 86400) | floor)d"
      end;

  map(select(.directory == $directory and (.updated | type) == "number" and (.created | type) == "number"))
  | if length == 0 then empty
    else
      length as $count
      | max_by(.updated)
      | (.title // "untitled" | tostring | gsub("[\\r\\n]+"; " ") | gsub("\\\""; "\\\\\"")) as $title
      | "- opencode \"\($title)\" \($count) \(duration($now_ms - .updated)) (cr \(duration($now_ms - .created)))"
    end
' "$cache_file" 2>/dev/null
