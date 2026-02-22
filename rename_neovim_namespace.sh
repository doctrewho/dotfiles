#!/usr/bin/env bash

set -e

NEW="$1"

if [ -z "$NEW" ]; then
  echo "usage: $0 <newname>"
  exit 1
fi

ROOT="$(cd "$(dirname "$0")" && pwd)"
LUA_DIR="${ROOT}/lua"

OLD="$(find "$LUA_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n")"

if [ -z "$OLD" ]; then
  echo "no namespace directory found in lua/"
  exit 1
fi

OLD_DIR="${LUA_DIR}/${OLD}"
NEW_DIR="${LUA_DIR}/${NEW}"

echo "current namespace: ${OLD}"
echo "new namespace:     ${NEW}"
echo
echo "directory:"
echo "  ${OLD_DIR} → ${NEW_DIR}"
echo
printf "continue? [y/N] "
read -r ans
[ "$ans" = "y" ] || exit 1

mv "$OLD_DIR" "$NEW_DIR"

find "$ROOT" -type f \
  ! -path "*/.git/*" \
  ! -path "*/node_modules/*" \
  -exec sed -i "s/${OLD}\.plugins\.lsp/${NEW}.plugins.lsp/g" {} +

find "$ROOT" -type f \
  ! -path "*/.git/*" \
  ! -path "*/node_modules/*" \
  -exec sed -i "s/require([\"']${OLD}\./require('${NEW}./g" {} +

find "$ROOT" -type f \
  ! -path "*/.git/*" \
  ! -path "*/node_modules/*" \
  -exec sed -i "s/lua\/${OLD}\//lua\/${NEW}\//g" {} +

echo "namespace updated."
