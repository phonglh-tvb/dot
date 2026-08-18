#!/bin/bash

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILE="$DIR/Brewfile"

# Taps (needed for formulae living outside homebrew-core, e.g. hashicorp/tap)
brew tap | sed 's/^/tap "/; s/$/"/' >"$FILE"
echo "" >>"$FILE"

# Only formulae you installed on purpose (no auto-pulled dependencies)
brew leaves --installed-on-request | sed 's/^/brew "/; s/$/"/' >>"$FILE"
echo "" >>"$FILE"

# Casks (GUI apps + fonts)
brew list --cask | sed 's/^/cask "/; s/$/"/' >>"$FILE"

echo "Brewfile updated: $FILE"
