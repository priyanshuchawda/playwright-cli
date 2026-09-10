#!/usr/bin/env bash
# Sync your fork with Microsoft upstream, then refresh the Fedora Playwright build + CLI.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLAYWRIGHT_ROOT="${PLAYWRIGHT_ROOT:-$(dirname "$ROOT")/playwright}"
FEDORA_BRANCH="${FEDORA_BRANCH:-feat/fedora-linux-support}"

echo "==> playwright-cli: fetch upstream (microsoft/playwright-cli)"
(
  cd "$ROOT"
  git fetch upstream main
  git fetch origin main
)

echo "==> playwright: fetch upstream (microsoft/playwright) + fork Fedora branch"
if [[ ! -d "$PLAYWRIGHT_ROOT/.git" ]]; then
  echo "Missing $PLAYWRIGHT_ROOT — clone: git clone https://github.com/priyanshuchawda/playwright.git"
  exit 1
fi
(
  cd "$PLAYWRIGHT_ROOT"
  git remote add upstream https://github.com/microsoft/playwright.git 2>/dev/null || true
  git remote add fork https://github.com/priyanshuchawda/playwright.git 2>/dev/null || true
  git fetch upstream main
  git fetch fork "$FEDORA_BRANCH"
  git checkout "$FEDORA_BRANCH"
  git merge --no-edit "upstream/main" || {
    echo "Merge conflicts with upstream/main — resolve in $PLAYWRIGHT_ROOT, commit, then re-run scripts/setup-fedora.sh"
    exit 1
  }
)

echo "==> playwright-cli: merge upstream/main into current branch"
(
  cd "$ROOT"
  current="$(git branch --show-current)"
  git merge --no-edit upstream/main || {
    echo "Merge conflicts — resolve in $ROOT, commit, then re-run scripts/setup-fedora.sh"
    exit 1
  }
  echo "On branch: $current"
)

echo "==> Rebuild and reinstall (Fedora)"
exec "$ROOT/scripts/setup-fedora.sh"
