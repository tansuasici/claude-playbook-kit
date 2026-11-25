#!/usr/bin/env bash
# Local copy of the Lint & Link Check workflow. CI runs it only on push to
# main (no pull_request trigger), so run this before you open a PR.
#   scripts/lint.sh
set -euo pipefail
cd "$(dirname "$0")/.."

npx -y markdownlint-cli2@0.17 "**/*.md" "!CHANGELOG.md" "#node_modules"

if ! command -v lychee >/dev/null; then
  echo "lint: lychee not found (brew install lychee); the link check needs it" >&2
  exit 1
fi
lychee --no-progress --exclude-path CHANGELOG.md \
  --exclude "example.com" --exclude "localhost" --exclude "wiki.internal" \
  --exclude "docs.api.com" --exclude "grafana.internal" --exclude "external-api" \
  --exclude "api.example.com" --max-retries 3 --accept "200..=299,429,503" \
  "**/*.md"
