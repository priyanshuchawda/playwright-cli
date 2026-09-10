#!/usr/bin/env bash
# Build forked Playwright with Fedora support and install playwright-cli locally.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLAYWRIGHT_ROOT="${PLAYWRIGHT_ROOT:-$(dirname "$ROOT")/playwright}"

if [[ ! -d "$PLAYWRIGHT_ROOT/.git" ]]; then
  echo "Clone Playwright fork first:"
  echo "  git clone https://github.com/priyanshuchawda/playwright.git \"$PLAYWRIGHT_ROOT\""
  echo "  cd \"$PLAYWRIGHT_ROOT\" && git checkout feat/fedora-linux-support"
  exit 1
fi

FEDORA_BRANCH="${FEDORA_BRANCH:-feat/fedora-linux-support}"

echo "==> Building Playwright at $PLAYWRIGHT_ROOT"
(
  cd "$PLAYWRIGHT_ROOT"
  git remote add fork https://github.com/priyanshuchawda/playwright.git 2>/dev/null || true
  git remote add upstream https://github.com/microsoft/playwright.git 2>/dev/null || true
  git fetch fork "$FEDORA_BRANCH" 2>/dev/null || git fetch origin "$FEDORA_BRANCH" 2>/dev/null || true
  git checkout "$FEDORA_BRANCH"
  if [[ -d node_modules && "${PW_FORCE_NPM_CI:-}" != 1 ]]; then
    echo "Skipping playwright npm ci (node_modules present). Set PW_FORCE_NPM_CI=1 to reinstall."
  else
    npm ci
  fi
  node utils/build/build.js --disable-install
)

echo "==> Linking playwright-cli at $ROOT"
(
  cd "$ROOT"
  if [[ -d node_modules && "${PW_FORCE_NPM_CI:-}" != 1 ]]; then
    echo "Skipping playwright-cli npm ci (node_modules present). Set PW_FORCE_NPM_CI=1 to reinstall."
  else
    npm ci
  fi
  npm install --no-save "file:${PLAYWRIGHT_ROOT}/packages/playwright-core" "file:${PLAYWRIGHT_ROOT}/packages/playwright"
  npm install -g .
)

mkdir -p "$HOME/.config/playwright-cli"
date -Iseconds >"$HOME/.config/playwright-cli/fedora-linked"

echo "==> Agent skills (claude + agents)"
(
  cd "$ROOT"
  node playwright-cli.js install --skills 2>/dev/null || true
  node playwright-cli.js install --skills=agents 2>/dev/null || true
)

echo "==> zsh helpers"
"$ROOT/scripts/install-zsh.sh"

echo "==> Verify Fedora install-deps dry-run"
if playwright-cli install-browser chromium --with-deps --dry-run; then
  echo "All browser RPM dependencies present."
else
  code=$?
  if [[ "$code" -eq 1 ]]; then
    echo "(Exit 1 = some optional font/Xvfb RPMs missing — OK for headless chromium. Install with: sudo dnf install -y <packages above>)"
  else
    exit "$code"
  fi
fi

echo "==> Smoke test"
zsh -lic 'pw-check && pwo https://example.com >/dev/null && pwc' 2>/dev/null || {
  playwright-cli open https://example.com >/dev/null
  playwright-cli close
}

echo ""
echo "Ready on Fedora + zsh."
echo "  pw-check     — verify dnf deps"
echo "  pwo <url>    — open browser (after: source ~/.zshrc)"
echo "  pw-relink    — rebuild + relink after git pull"
