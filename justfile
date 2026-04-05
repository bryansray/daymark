set shell := ["zsh", "-cu"]

default:
  @just --list

# Build the CLI in debug mode.
build:
  swift build

# Build the CLI in release mode.
release:
  swift build -c release

# Symlink the release binary into ~/.local/bin.
link:
  mkdir -p "$HOME/.local/bin"
  ln -sf "$PWD/.build/release/daymark" "$HOME/.local/bin/daymark"

# Build the release binary and install the local symlink.
install-local: release link

# Run the full SwiftPM test suite.
test:
  swift test

# Rebuild from scratch and run tests.
check: clean test

# Run the CLI with arbitrary arguments.
run *args:
  swift run daymark {{args}}

# Remove local SwiftPM build artifacts.
clean:
  rm -rf .build
