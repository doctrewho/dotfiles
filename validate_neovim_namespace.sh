#!/usr/bin/env bash

set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
LUA_DIR="${ROOT}/lua"

NS="$(find "$LUA_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n")"

if [ -z "$NS" ]; then
  echo "no namespace directory found in lua/"
  exit 1
fi

echo "namespace: ${NS}"

BAD=0

check_ref() {
  if grep -R "$1" "$ROOT" --exclude-dir=.git --exclude-dir=node_modules --exclude=*.swp --exclude=*.bak >/dev/null 2>&1; then
    echo "invalid reference: $1"
    BAD=1
  fi
}

check_missing() {
  if ! grep -R "$1" "$ROOT" --exclude-dir=.git --exclude-dir=node_modules --exclude=*.swp --exclude=*.bak >/dev/null 2>&1; then
    echo "missing reference: $1"
    BAD=1
  fi
}

check_missing "require(\"${NS}.plugins.lsp"
check_missing "${NS}.plugins.lsp"
check_missing "lua/${NS}/"

for d in $(find "$LUA_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n"); do
  if [ "$d" != "$NS" ]; then
    check_ref "require(\"${d}.plugins.lsp"
    check_ref "${d}.plugins.lsp"
    check_ref "lua/${d}/"
  fi
done

if [ $BAD -eq 1 ]; then
  echo "namespace validation failed."
  exit 1
fi

echo "namespace valid."
