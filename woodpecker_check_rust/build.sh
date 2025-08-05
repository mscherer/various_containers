#!/bin/bash
set -e

cargo fmt --all -- --check

cargo build

cargo test

cargo clippy -- -D warnings
