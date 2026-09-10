#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSHRC="${ZSHRC:-$HOME/.zshrc}"
MARKER="# playwright-cli (Fedora fork)"
SNIPPET='[[ -f "$HOME/playwright-cli/scripts/playwright-cli.zsh" ]] && source "$HOME/playwright-cli/scripts/playwright-cli.zsh"'

mkdir -p "$HOME/.config/playwright-cli"

if [[ -f "$ZSHRC" ]] && ! grep -qF "$MARKER" "$ZSHRC"; then
  cat >>"$ZSHRC" <<EOF

$MARKER
export PLAYWRIGHT_CLI_ROOT="\$HOME/playwright-cli"
$SNIPPET
EOF
  echo "Added playwright-cli block to $ZSHRC"
else
  echo "zsh already configured (marker present or no $ZSHRC)"
fi

echo "Reload: source ~/.zshrc   — helpers: pw, pw-check, pw-relink, pwo, pwc, pws, pwl"
