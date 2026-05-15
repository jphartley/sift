#!/usr/bin/env bash
# Runs GeminiBenchmark against the iPhone 17 Pro simulator.
#
# Reads the API key from sift/Services/GeminiAPIKey.local (gitignored).
# Skips automatically if that file is absent or empty.
#
# Usage: ./scripts/run-benchmark.sh

set -euo pipefail

xcodebuild test \
    -scheme sift \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    -only-testing:siftTests/GeminiBenchmark \
    2>&1 | grep -E "BENCHMARK|error:|Build succeeded|Test Suite|passed|failed"
