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

echo "==> Building Playwright at $PLAYWRIGHT_ROOT"
(
  cd "$PLAYWRIGHT_ROOT"
  git fetch origin feat/fedora-linux-support 2>/dev/null || true
  git checkout feat/fedora-linux-support
  npm ci
  node utils/build/build.js --disable-install
)

echo "==> Linking playwright-cli at $ROOT"
(
  cd "$ROOT"
  npm ci
  npm install --no-save "file:${PLAYWRIGHT_ROOT}/packages/playwright-core" "file:${PLAYWRIGHT_ROOT}/packages/playwright"
  npm install -g .
)

echo "==> Verify Fedora install-deps dry-run"
playwright-cli install-browser chromium --with-deps --dry-run

echo "Done. Use: playwright-cli open https://example.com"
