#!/bin/sh
# One-time setup: configures git hooks and initializes submodules
git config core.hooksPath .githooks
git submodule update --init --recursive
echo "Done! Submodules initialized and hooks configured."
