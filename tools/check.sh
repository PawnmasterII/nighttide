#!/bin/bash
# NightTide quality gate — run before every commit (constitution gate)
set -e
cd "$(dirname "$0")/.."
export PATH="$HOME/.rokit/bin:$PATH"

echo "[1/4] selene..."
selene src

echo "[2/4] stylua..."
stylua --check src

echo "[3/4] luau-lsp analyze..."
luau-lsp analyze --definitions=tools/globalTypes.d.luau src

echo "[4/4] rojo build..."
rojo build -o nighttide.rbxlx

echo "ALL GATES GREEN"
