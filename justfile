set shell := ["zsh", "-cu"]

default:
  @just --list

# Build the CLI in debug mode.
build:
  swift build

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
