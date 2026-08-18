#!/bin/bash

set -e

function have {
  command -v "$1" &>/dev/null
}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install Homebrew if missing
have brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Make sure brew is on PATH for this session (Apple Silicon default)
have brew || eval "$(/opt/homebrew/bin/brew shellenv)"

# Install everything from the Brewfile (formulae + casks, deps resolved automatically)
brew bundle install --file="$DIR/Brewfile"
