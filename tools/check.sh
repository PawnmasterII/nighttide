#!/bin/bash
# NightTide quality gate — run before every commit (constitution gate)
set -e
cd "$(dirname "$0")/.."
export PATH="$HOME/.rokit/bin:$PATH"

echo "[1/4] blink codegen..."
blink net/Net.blink -y

echo "[2/5] selene..."
selene src

echo "[3/5] stylua..."
stylua --check src

echo "[4/5] luau-lsp analyze..."
rojo sourcemap default.project.json --output sourcemap.json
luau-lsp analyze --definitions=tools/globalTypes.d.luau --sourcemap=sourcemap.json src

echo "[5/5] rojo build..."
rojo build -o nighttide.rbxlx

echo "ALL GATES GREEN"
